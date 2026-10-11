import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/entity_type.dart';
import '../database/local_store.dart';

/// Operasi antrean yang masih tertunda, dikelompokkan per data.
class PendingIndex {
  PendingIndex(Iterable<OutboxRow> ops) {
    for (final op in ops) {
      _byEntity.putIfAbsent(_key(op.entityType, op.entityId), () => []).add(op);
      _idsByType.putIfAbsent(op.entityType, () => {}).add(op.entityId);
    }
  }

  final Map<String, List<OutboxRow>> _byEntity = {};
  final Map<String, Set<String>> _idsByType = {};

  static String _key(String type, String id) => '$type/$id';

  List<OutboxRow> of(EntityType type, String id) => _byEntity[_key(type.name, id)] ?? const [];

  /// ID semua data berjenis [type] yang masih punya operasi di antrean.
  Set<String> idsOf(EntityType type) => _idsByType[type.name] ?? const {};
}

/// Menerapkan baris dari server (sync, balasan `PUT`/`PATCH`, atau `current`) ke cache lokal.
///
/// Aturannya dari bagian "Aturan di HP" di kontrak:
/// - baris ditimpa berdasarkan `id`, tanpa pengecekan foreign key;
/// - kolom yang masih punya operasi di antrean tidak ditimpa;
/// - baris yang `DELETE`-nya masih di antrean tidak muncul lagi;
/// - baris yang `updated_at`-nya lebih tua dari salinan lokal diabaikan;
/// - induk yang tiba terhapus ikut menghapus anaknya, kecuali anak yang masih punya operasi.
class RowApplier {
  RowApplier(this.store);

  final LocalStore store;

  /// Kolom yang nilainya ikut ditentukan kolom lain, jadi dilindungi bersama-sama.
  /// `completed_by` dan `remind_at` diisi server dari `completed_at` dan tenggat.
  static const Map<String, List<String>> _linkedColumns = {
    'completed_at': ['completed_by'],
    'due_date': ['due_time', 'remind_at'],
    'due_time': ['due_date', 'remind_at'],
  };

  Future<PendingIndex> loadPending() async => PendingIndex(await store.db.select(store.db.outboxOps).get());

  Future<PendingIndex> _loadPendingFor(EntityType type, String id) async {
    final db = store.db;
    final ops =
        await (db.select(db.outboxOps)..where(
              (t) =>
                  (t.entityType.equals(type.name) & t.entityId.equals(id)) |
                  // Anak yang punya operasi tertunda tidak ikut terhapus bersama induknya.
                  (type.child == null ? const Constant(false) : t.entityType.equals(type.child!.$1.name)),
            ))
            .get();
    return PendingIndex(ops);
  }

  /// Terapkan satu baris.
  ///
  /// [force] melewati pengecekan umur; dipakai untuk `current`, yang selalu
  /// merupakan keadaan server saat itu. [pending] diisi saat menerapkan banyak
  /// baris sekaligus, supaya antrean cukup dibaca sekali.
  Future<void> apply(
    EntityType type,
    Map<String, dynamic> incoming, {
    bool force = false,
    PendingIndex? pending,
  }) async {
    final id = incoming['id'] as String;
    final index = pending ?? await _loadPendingFor(type, id);
    final ops = index.of(type, id);

    if (ops.any((op) => op.method == 'DELETE')) return;

    final local = await store.read(type, id);
    final incomingStamp = incoming['updated_at'] as String?;

    if (!force && local != null && incomingStamp != null) {
      final localStamp = await store.serverUpdatedAt(type, id);
      if (localStamp != null && DateTime.parse(incomingStamp).isBefore(localStamp)) return;
    }

    final merged = Map<String, dynamic>.of(incoming);
    if (local != null) {
      for (final column in _protectedColumns(ops)) {
        if (local.containsKey(column)) merged[column] = local[column];
      }
    }

    await store.write(type, merged, serverUpdatedAt: incomingStamp);

    final deletedAt = merged['deleted_at'] as String?;
    if (deletedAt != null && type.child != null) {
      await store.markChildrenDeleted(type, id, deletedAt: deletedAt, except: index.idsOf(type.child!.$1));
    }
  }

  Set<String> _protectedColumns(List<OutboxRow> ops) {
    final columns = <String>{};
    for (final op in ops) {
      final payload = op.payload;
      if (payload == null) continue;
      for (final column in (jsonDecode(payload) as Map<String, dynamic>).keys) {
        columns
          ..add(column)
          ..addAll(_linkedColumns[column] ?? const []);
      }
    }
    return columns;
  }
}
