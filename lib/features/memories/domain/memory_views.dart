import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../spaces/domain/household.dart';
import '../../spaces/domain/space.dart';
import '../../trips/domain/trip.dart';
import 'memory.dart';
import 'memory_photo.dart';

/// Kenangan beserta foto dan perjalanannya.
class MemoryItem {
  const MemoryItem({required this.memory, required this.space, required this.photos, this.trip});

  final Memory memory;
  final Space space;

  /// Foto yang belum dihapus, urut `position`; yang pertama jadi sampul.
  final List<MemoryPhoto> photos;

  /// Perjalanan yang ditautkan, kalau masih ada di HP ini.
  final Trip? trip;

  MemoryPhoto? get cover => photos.firstOrNull;

  int get year => int.parse(memory.visitedOn.substring(0, 4));

  int get month => int.parse(memory.visitedOn.substring(5, 7));
}

/// Satu bulan di linimasa.
class MemoryMonth {
  const MemoryMonth({required this.year, required this.month, required this.items});

  final int year;
  final int month;
  final List<MemoryItem> items;
}

/// Satu tahun di linimasa, bulan terbaru dulu.
class MemoryYear {
  const MemoryYear({required this.year, required this.months});

  final int year;
  final List<MemoryMonth> months;

  int get count => months.fold(0, (sum, month) => sum + month.items.length);
}

/// Gabungkan kenangan dengan foto dan perjalanannya, terbaru dulu menurut `visited_on`
/// (yang tanggalnya sama: yang terakhir dibuat dulu).
///
/// Kenangan yang terhapus atau berada di ruang yang tidak dikenal tidak ikut.
List<MemoryItem> buildMemoryItems({
  required List<Memory> memories,
  required List<MemoryPhoto> photos,
  required List<Trip> trips,
  required Household household,
}) {
  final photosByMemory = <String, List<MemoryPhoto>>{};
  for (final photo in photos) {
    if (photo.deletedAt == null) photosByMemory.putIfAbsent(photo.memoryId, () => []).add(photo);
  }
  final tripsById = {
    for (final trip in trips)
      if (trip.deletedAt == null) trip.id: trip,
  };

  final result = <MemoryItem>[];
  for (final memory in memories) {
    final space = household.spaceOf(memory.spaceId);
    if (space == null || memory.deletedAt != null) continue;

    final own = (photosByMemory[memory.id] ?? <MemoryPhoto>[])..sort(comparePhotos);
    result.add(MemoryItem(memory: memory, space: space, photos: own, trip: tripsById[memory.tripId]));
  }
  return result..sort(compareMemories);
}

/// Urutan foto: `position`, lalu ID supaya urutannya sama di kedua HP.
int comparePhotos(MemoryPhoto a, MemoryPhoto b) {
  final byPosition = a.position.compareTo(b.position);
  return byPosition != 0 ? byPosition : a.id.compareTo(b.id);
}

/// Terbaru dulu menurut `visited_on`, lalu yang terakhir dibuat.
int compareMemories(MemoryItem a, MemoryItem b) {
  final byDate = b.memory.visitedOn.compareTo(a.memory.visitedOn);
  if (byDate != 0) return byDate;
  final byCreated = b.memory.createdAt.compareTo(a.memory.createdAt);
  return byCreated != 0 ? byCreated : b.memory.id.compareTo(a.memory.id);
}

/// Kelompokkan [sorted] (urutan [compareMemories]) per tahun dan bulan dari `visited_on`.
List<MemoryYear> memoryTimeline(List<MemoryItem> sorted) {
  final years = <MemoryYear>[];
  for (final item in sorted) {
    if (years.isEmpty || years.last.year != item.year) {
      years.add(MemoryYear(year: item.year, months: []));
    }
    final months = years.last.months;
    if (months.isEmpty || months.last.month != item.month) {
      months.add(MemoryMonth(year: item.year, month: item.month, items: []));
    }
    months.last.items.add(item);
  }
  return years;
}

/// Semua kenangan dalam urutan linimasa; `null` selama cache belum terbaca.
final memoryItemsProvider = Provider<List<MemoryItem>?>((ref) {
  final memories = ref.watch(memoriesProvider).value;
  final photos = ref.watch(memoryPhotosProvider).value;
  final trips = ref.watch(tripsProvider).value;
  final household = ref.watch(householdProvider);
  if (memories == null || photos == null || trips == null || household == null) return null;

  return buildMemoryItems(memories: memories, photos: photos, trips: trips, household: household);
});

/// Kenangan yang ditautkan ke perjalanan [tripId], terbaru dulu.
List<MemoryItem> memoriesOfTrip(List<MemoryItem>? items, String tripId) => [
  for (final item in items ?? const <MemoryItem>[])
    if (item.memory.tripId == tripId) item,
];
