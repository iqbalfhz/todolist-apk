import 'package:flutter/widgets.dart' show Characters;

import '../../../core/database/entity_type.dart';
import '../../../core/database/local_writer.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/ulid.dart';
import '../../../core/utils/validators.dart';
import '../../tasks/domain/task_list.dart';
import '../domain/trip.dart';

/// Perjalanan (v0.2): dibaca dari cache lokal, ditulis lewat antrean.
///
/// Checklist persiapannya (daftar tugas dengan `trip_id`) dibuat di sini juga, tepat
/// setelah perjalanannya, supaya bisa langsung diisi walau offline. Checklist tidak
/// bisa dihapus atau diarsipkan sendiri; ia ikut terhapus bersama perjalanannya.
/// Kedua anggota Ruang Bersama boleh mengubah dan menghapus perjalanan siapa pun.
class TripRepository {
  TripRepository({required this.writer, required this.userId});

  final LocalWriter writer;
  final String userId;

  /// Tanggal perjalanan dicek server berpasangan, jadi selalu dikirim bersama.
  static const Set<String> _dates = {'start_date', 'end_date'};

  Stream<List<Trip>> watchAll() => writer.store.watchTrips();

  /// Buat perjalanan beserta checklistnya. [startDate] dan [endDate] berformat `YYYY-MM-DD`.
  Future<Trip> create({
    required String spaceId,
    required String title,
    String? destination,
    String? startDate,
    String? endDate,
    String? notes,
    String? savingsGoalId,
  }) async {
    final fields = _validated(
      title: title,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      notes: notes,
    );
    final nowIso = writer.nowIso();

    final payload = <String, dynamic>{'space_id': spaceId, ...fields, 'savings_goal_id': savingsGoalId};
    final row = <String, dynamic>{
      ...payload,
      'id': newUlid(now: writer.now()),
      'created_by': userId,
      'created_at': nowIso,
      'updated_at': nowIso,
      'deleted_at': null,
    };
    final trip = Trip.fromJson(row);

    await writer.store.transaction(() async {
      await writer.create(EntityType.trip, row, payload);
      await _createChecklist(trip);
    });
    return trip;
  }

  /// Ubah isi perjalanan; hanya kolom yang berubah yang dikirim. Nama checklist ikut judulnya.
  Future<void> edit(
    String id, {
    required String title,
    required String? destination,
    required String? startDate,
    required String? endDate,
    required String? notes,
  }) async {
    final fields = _validated(
      title: title,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      notes: notes,
    );

    await writer.store.transaction(() async {
      await writer.update(EntityType.trip, id, fields, linked: _dates);
      for (final checklist in await writer.store.checklistsOf(id)) {
        await writer.update(EntityType.list, checklist.id, {'name': checklistNameFor(fields['title'] as String)});
      }
    });
  }

  /// Tautkan target tabungan di ruang yang sama, atau lepas tautannya dengan `null`.
  Future<void> linkGoal(String id, String? goalId) => writer.update(EntityType.trip, id, {'savings_goal_id': goalId});

  /// Hapus perjalanan. Server ikut menghapus checklist beserta tugasnya, jadi di HP
  /// keduanya cukup ditandai terhapus, tanpa operasi antrean sendiri.
  Future<void> delete(String id) => writer.store.transaction(() async {
    final opId = await writer.delete(EntityType.trip, id);
    if (opId == null) return;

    final deletedAt = writer.nowIso();
    for (final checklist in await writer.store.checklistsOf(id)) {
      await writer.store.patch(EntityType.list, checklist.id, {'deleted_at': deletedAt});
      await writer.store.markChildrenDeleted(EntityType.task, checklist.id, deletedAt: deletedAt);
    }
  });

  /// Checklist perjalanan [trip]. Biasanya sudah dibuat bersama perjalanannya; kalau belum
  /// ada di HP ini, dibuat sekarang supaya item pertama tetap bisa dicatat.
  Future<TaskList> checklistFor(Trip trip) => writer.store.transaction(() async {
    final existing = await writer.store.checklistsOf(trip.id);
    return existing.firstOrNull ?? await _createChecklist(trip);
  });

  Future<TaskList> _createChecklist(Trip trip) async {
    final nowIso = writer.nowIso();

    final payload = <String, dynamic>{
      'space_id': trip.spaceId,
      'trip_id': trip.id,
      'name': checklistNameFor(trip.title),
      'emoji': null,
      'color': 'mawar',
      'position': await writer.nextPosition(EntityType.list, parentId: trip.spaceId),
    };

    final row = <String, dynamic>{
      ...payload,
      'id': newUlid(now: writer.now()),
      'archived_at': null,
      'created_by': userId,
      'created_at': nowIso,
      'updated_at': nowIso,
      'deleted_at': null,
    };

    await writer.create(EntityType.list, row, payload);
    return TaskList.fromJson(row);
  }

  // ---------------------------------------------------------------- validasi

  /// Kolom isi perjalanan yang sudah dirapikan, dengan aturan yang sama seperti server.
  static Map<String, dynamic> _validated({
    required String title,
    required String? destination,
    required String? startDate,
    required String? endDate,
    required String? notes,
  }) {
    final cleanTitle = title.trim();
    if (!isValidRequiredText(cleanTitle, Limits.tripTitle)) {
      throw ArgumentError.value(title, 'title', 'Judul wajib diisi, paling banyak ${Limits.tripTitle} karakter.');
    }

    final cleanDestination = nullIfBlank(destination);
    if (cleanDestination != null && textLength(cleanDestination) > Limits.tripDestination) {
      throw ArgumentError.value(destination, 'destination', 'Tujuan paling banyak ${Limits.tripDestination} karakter.');
    }

    final cleanNotes = nullIfBlank(notes);
    if (cleanNotes != null && textLength(cleanNotes) > Limits.tripNotes) {
      throw ArgumentError.value(notes, 'notes', 'Catatan paling banyak ${Limits.tripNotes} karakter.');
    }

    if (startDate != null && !isValidYmd(startDate)) {
      throw ArgumentError.value(startDate, 'startDate', 'Tanggal mulai harus YYYY-MM-DD.');
    }
    if (endDate != null && (startDate == null || !isValidYmd(endDate) || endDate.compareTo(startDate) < 0)) {
      throw ArgumentError.value(endDate, 'endDate', 'Tanggal selesai butuh tanggal mulai dan tidak boleh lebih awal.');
    }

    return {
      'title': cleanTitle,
      'destination': cleanDestination,
      'start_date': startDate,
      'end_date': endDate,
      'notes': cleanNotes,
    };
  }
}

/// Nama checklist perjalanan berjudul [tripTitle], misalnya "Persiapan Liburan ke Bali".
///
/// Disimpan di server sebagai nama daftar, jadi dipotong supaya muat [Limits.name] karakter.
String checklistNameFor(String tripTitle) {
  const prefix = 'Persiapan ';
  const ellipsis = '…';
  final title = tripTitle.trim();
  if (textLength('$prefix$title') <= Limits.name) return '$prefix$title';

  // Dipotong per gugus grafem, supaya emoji tidak terbelah.
  final kept = StringBuffer();
  for (final cluster in Characters(title)) {
    if (textLength('$prefix$kept$cluster$ellipsis') > Limits.name) break;
    kept.write(cluster);
  }
  return '$prefix${kept.toString().trimRight()}$ellipsis';
}
