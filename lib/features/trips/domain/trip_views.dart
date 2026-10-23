import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/time/space_clock.dart';
import '../../../core/utils/dates.dart';
import '../../savings/domain/savings_views.dart';
import '../../spaces/domain/household.dart';
import '../../spaces/domain/space.dart';
import '../../tasks/domain/task_list.dart';
import '../../tasks/domain/task_views.dart';
import 'trip.dart';

/// Status perjalanan, dihitung di HP dari tanggal lokal ruangnya (kontrak, bagian Perjalanan).
enum TripStatus {
  /// Tanggalnya belum pasti, atau belum tiba.
  planned,

  /// Dari tanggal mulai sampai tanggal selesai (atau hanya di tanggal mulai kalau sehari).
  ongoing,

  /// Sesudah tanggal selesai.
  done,
}

/// Perjalanan beserta checklist, progres persiapan, dan dana yang ditautkan.
class TripItem {
  const TripItem({
    required this.trip,
    required this.space,
    required this.today,
    required this.checklist,
    required this.items,
    required this.goal,
  });

  final Trip trip;
  final Space space;

  /// Tanggal hari ini (`YYYY-MM-DD`) di zona waktu ruang perjalanan ini.
  final String today;

  /// Checklist persiapannya, atau `null` selama checklist buatan HP pasangan belum sampai.
  final TaskList? checklist;

  /// Item checklist yang belum dihapus, urut `position`.
  final List<TaskItem> items;

  /// Target tabungan yang ditautkan, kalau masih ada di HP ini.
  final GoalProgress? goal;

  TripStatus get status {
    final start = trip.startDate;
    if (start == null || today.compareTo(start) < 0) return TripStatus.planned;
    return today.compareTo(trip.lastDate!) <= 0 ? TripStatus.ongoing : TripStatus.done;
  }

  bool get isDone => status == TripStatus.done;

  /// Hari menuju keberangkatan; `null` kalau tanggalnya belum pasti atau sudah berangkat.
  int? get daysUntilStart {
    final start = trip.startDate;
    return start == null || status != TripStatus.planned ? null : daysBetween(today, start);
  }

  /// Lama perjalanan dalam hari, hari mulai dan selesai ikut dihitung.
  int? get durationDays {
    final start = trip.startDate;
    return start == null ? null : daysBetween(start, trip.lastDate!) + 1;
  }

  /// Hari ke berapa, selama perjalanan berlangsung.
  int? get dayNumber => status == TripStatus.ongoing ? daysBetween(trip.startDate!, today) + 1 : null;

  int get done => items.where((item) => item.isCompleted).length;

  int get total => items.length;

  /// Item selesai dibagi total, 0 sampai 1.
  double get fraction => total == 0 ? 0 : done / total;

  /// Persen dibulatkan ke bawah, supaya 100% hanya tampil saat semuanya beres.
  int get percent => (fraction * 100).floor();

  /// Item yang belum selesai, urut `position`.
  List<TaskItem> get openItems => [
    for (final item in items)
      if (!item.isCompleted) item,
  ];
}

/// Gabungkan perjalanan dengan checklist, tugas, dan tabungannya.
///
/// Perjalanan yang terhapus atau berada di ruang yang tidak dikenal tidak ikut.
List<TripItem> buildTripItems({
  required List<Trip> trips,
  required List<TaskList> lists,
  required List<TaskItem> taskItems,
  required List<GoalProgress> goals,
  required Household household,
  required SpaceClock clock,
}) {
  final checklists = <String, List<TaskList>>{};
  for (final list in lists) {
    final tripId = list.tripId;
    if (tripId != null && list.deletedAt == null) checklists.putIfAbsent(tripId, () => []).add(list);
  }
  final goalsById = {for (final goal in goals) goal.goal.id: goal};
  final todays = <String, String>{};

  final result = <TripItem>[];
  for (final trip in trips) {
    final space = household.spaceOf(trip.spaceId);
    if (space == null || trip.deletedAt != null) continue;

    // Biasanya satu checklist; kalau ada lebih, semua isinya tetap dihitung.
    final ownLists = (checklists[trip.id] ?? const <TaskList>[]).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final listIds = {for (final list in ownLists) list.id};
    final items = taskItems.where((item) => listIds.contains(item.task.taskListId)).toList()
      ..sort((a, b) => a.task.position.compareTo(b.task.position));

    result.add(
      TripItem(
        trip: trip,
        space: space,
        today: todays.putIfAbsent(space.timezone, () => clock.today(space.timezone)),
        checklist: ownLists.firstOrNull,
        items: items,
        goal: goalsById[trip.savingsGoalId],
      ),
    );
  }
  return result;
}

/// Urutan tampil: yang sedang berlangsung, lalu yang paling dekat berangkat, lalu yang
/// tanggalnya belum pasti (terbaru dulu), dan yang sudah selesai paling bawah (terbaru dulu).
int compareTrips(TripItem a, TripItem b) {
  int rank(TripItem item) => switch (item.status) {
    TripStatus.ongoing => 0,
    TripStatus.planned => item.trip.startDate == null ? 2 : 1,
    TripStatus.done => 3,
  };

  final byRank = rank(a).compareTo(rank(b));
  if (byRank != 0) return byRank;

  return switch (rank(a)) {
    0 || 1 => a.trip.startDate!.compareTo(b.trip.startDate!),
    3 => b.trip.lastDate!.compareTo(a.trip.lastDate!),
    _ => b.trip.createdAt.compareTo(a.trip.createdAt),
  };
}

/// Perjalanan untuk kartu Persiapan liburan di Beranda: yang sedang berlangsung atau yang
/// paling dekat berangkat, lalu rencana yang tanggalnya belum pasti. `null` kalau tidak ada.
TripItem? featuredTrip(List<TripItem> sorted) => sorted.where((item) => !item.isDone).firstOrNull;

/// Semua perjalanan dalam urutan tampil; `null` selama cache belum terbaca.
final tripItemsProvider = Provider<List<TripItem>?>((ref) {
  final trips = ref.watch(tripsProvider).value;
  final lists = ref.watch(taskListsProvider).value;
  final taskItems = ref.watch(taskItemsProvider);
  final goals = ref.watch(goalProgressProvider);
  final household = ref.watch(householdProvider);
  if (trips == null || lists == null || taskItems == null || goals == null || household == null) return null;

  // Dihitung ulang saat waktu berjalan, supaya status dan hitung mundur ikut berganti.
  ref.watch(nowProvider);

  return buildTripItems(
    trips: trips,
    lists: lists,
    taskItems: taskItems,
    goals: goals,
    household: household,
    clock: ref.watch(spaceClockProvider),
  )..sort(compareTrips);
});
