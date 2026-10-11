import 'dart:convert';

import 'package:drift/drift.dart';

import '../queue/outbox.dart';
import 'entity_type.dart';
import 'local_store.dart';

/// Jarak `position` antara dua baris yang bersebelahan.
const double positionStep = 1024;

/// Cara semua repository menulis: ubah cache lokal dulu (UI langsung berubah),
/// lalu masukkan operasinya ke antrean, dalam satu transaksi.
class LocalWriter {
  LocalWriter({required this.store, required this.outbox, DateTime Function()? now}) : _now = now ?? DateTime.now;

  final LocalStore store;
  final Outbox outbox;
  final DateTime Function() _now;

  DateTime now() => _now();

  /// Waktu sekarang dalam bentuk yang dikirim ke server: ISO 8601 UTC dengan `Z`.
  String nowIso() => _now().toUtc().toIso8601String();

  /// Buat baris baru. [row] adalah baris lengkap untuk cache, [payload] body `PUT`-nya.
  Future<void> create(EntityType type, Map<String, dynamic> row, Map<String, dynamic> payload) =>
      store.transaction(() async {
        await store.write(type, row);
        await outbox.enqueueCreate(type, row['id'] as String, payload);
      });

  /// Ubah kolom di [changes]. [localOnly] ikut ditulis ke cache tapi tidak dikirim,
  /// misalnya `completed_by`, yang diisi server.
  ///
  /// Hanya kolom yang nilainya benar-benar berubah yang dikirim, supaya perubahan
  /// pasangan di kolom lain tidak ikut tertimpa. Dengan [sendTogether], semua kolom
  /// di [changes] dikirim begitu salah satunya berubah (kolom berpasangan seperti
  /// `due_date` dan `due_time`).
  Future<void> update(
    EntityType type,
    String id,
    Map<String, dynamic> changes, {
    Map<String, dynamic> localOnly = const {},
    bool sendTogether = false,
  }) => store.transaction(() async {
    final current = await store.read(type, id);
    if (current == null) return;

    final changed = {
      for (final entry in changes.entries)
        if (jsonEncode(current[entry.key]) != jsonEncode(entry.value)) entry.key: entry.value,
    };
    if (changed.isEmpty) return;

    final payload = sendTogether ? changes : changed;
    final local = {...payload, ...localOnly};

    await store.write(type, {...current, ...local});
    await outbox.enqueueUpdate(type, id, payload, {for (final key in local.keys) key: current[key]});
  });

  /// Seperti [update], tapi sebagai operasi tersendiri yang bisa diurungkan selama 5 detik.
  /// Mengembalikan ID operasinya, atau `null` kalau barisnya tidak ada.
  Future<int?> updateUndoable(
    EntityType type,
    String id,
    Map<String, dynamic> changes, {
    Map<String, dynamic> localOnly = const {},
  }) => store.transaction(() async {
    final before = await store.patch(type, id, {...changes, ...localOnly});
    if (before == null) return null;
    return outbox.enqueueUndoableUpdate(type, id, changes, before);
  });

  /// Tandai terhapus di cache dan antrekan `DELETE`.
  /// Mengembalikan ID operasinya, atau `null` kalau barisnya tidak ada.
  Future<int?> delete(EntityType type, String id, {bool undoable = false}) => store.transaction(() async {
    final before = await store.patch(type, id, {'deleted_at': nowIso()});
    if (before == null) return null;
    return outbox.enqueueDelete(type, id, before: before, undoable: undoable);
  });

  /// `position` untuk baris baru di ujung: yang terbesar ditambah [positionStep].
  Future<double> nextPosition(EntityType type, {required String parentId}) async {
    final db = store.db;
    final double? max;

    switch (type) {
      case EntityType.list:
        final expression = db.taskLists.position.max();
        max =
            await (db.selectOnly(db.taskLists)
                  ..addColumns([expression])
                  ..where(db.taskLists.spaceId.equals(parentId)))
                .map((row) => row.read(expression))
                .getSingle();
      case EntityType.task:
        final expression = db.tasks.position.max();
        max =
            await (db.selectOnly(db.tasks)
                  ..addColumns([expression])
                  ..where(db.tasks.taskListId.equals(parentId)))
                .map((row) => row.read(expression))
                .getSingle();
      case EntityType.space || EntityType.goal || EntityType.entry || EntityType.me:
        max = null;
    }

    return (max ?? 0) + positionStep;
  }
}
