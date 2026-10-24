import 'dart:convert';

import 'package:drift/drift.dart';

import '../../features/auth/domain/user.dart';
import '../../features/memories/domain/memory.dart';
import '../../features/memories/domain/memory_photo.dart';
import '../../features/savings/domain/savings_entry.dart';
import '../../features/savings/domain/savings_goal.dart';
import '../../features/spaces/domain/space.dart';
import '../../features/special_dates/domain/special_date.dart';
import '../../features/tasks/domain/task.dart';
import '../../features/tasks/domain/task_list.dart';
import '../../features/trips/domain/trip.dart';
import 'app_database.dart';
import 'entity_type.dart';
import 'mappers.dart';

/// Kunci di tabel meta.
abstract final class MetaKeys {
  /// `server_time` dari halaman terakhir sync, dikirim sebagai `since` berikutnya.
  static const String syncSince = 'sync_since';

  /// Profil sendiri (sumber user) sebagai JSON.
  static const String profile = 'profile';

  /// Token FCM yang terakhir didaftarkan lewat `POST /devices`.
  static const String deviceToken = 'device_token';

  /// Versi daftar koleksi sync yang sudah pernah ditarik penuh oleh database ini.
  /// Koleksi baru (v0.2: `special_dates`, lalu `trips`; v0.3: `memories` dan `memory_photos`)
  /// membuat sync berikutnya berjalan penuh sekali.
  static const String syncCollections = 'sync_collections';
}

/// Satu-satunya pintu ke cache lokal.
///
/// UI membaca lewat `watch...`; antrean dan sync menulis lewat [read] dan [write],
/// yang bekerja pada JSON berbentuk sama dengan kontrak supaya satu logika
/// berlaku untuk semua jenis data.
class LocalStore {
  LocalStore(this.db);

  final AppDatabase db;

  Future<T> transaction<T>(Future<T> Function() action) => db.transaction(action);

  // ---------------------------------------------------------------- baca dan tulis generik

  /// Baris lokal sebagai JSON kontrak, termasuk yang sudah ditandai terhapus.
  Future<Map<String, dynamic>?> read(EntityType type, String id) async {
    switch (type) {
      case EntityType.space:
        final row = await (db.select(db.spaces)..where((t) => t.id.equals(id))).getSingleOrNull();
        return row?.toModel().toJson();
      case EntityType.list:
        final row = await (db.select(db.taskLists)..where((t) => t.id.equals(id))).getSingleOrNull();
        return row?.toModel().toJson();
      case EntityType.task:
        final row = await (db.select(db.tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
        return row?.toModel().toJson();
      case EntityType.goal:
        final row = await (db.select(db.savingsGoals)..where((t) => t.id.equals(id))).getSingleOrNull();
        return row?.toModel().toJson();
      case EntityType.entry:
        final row = await (db.select(db.savingsEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
        return row?.toModel().toJson();
      case EntityType.specialDate:
        final row = await (db.select(db.specialDates)..where((t) => t.id.equals(id))).getSingleOrNull();
        return row?.toModel().toJson();
      case EntityType.trip:
        final row = await (db.select(db.trips)..where((t) => t.id.equals(id))).getSingleOrNull();
        return row?.toModel().toJson();
      case EntityType.memory:
        final row = await (db.select(db.memories)..where((t) => t.id.equals(id))).getSingleOrNull();
        return row?.toModel().toJson();
      case EntityType.memoryPhoto:
        final row = await (db.select(db.memoryPhotos)..where((t) => t.id.equals(id))).getSingleOrNull();
        return row?.toModel().toJson();
      case EntityType.me:
        final raw = await meta(MetaKeys.profile);
        return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
    }
  }

  /// `updated_at` terakhir yang datang dari server, atau `null` kalau baris belum pernah dibalas server.
  Future<DateTime?> serverUpdatedAt(EntityType type, String id) async {
    final String? stamp;
    switch (type) {
      case EntityType.space:
        stamp =
            await (db.selectOnly(db.spaces)
                  ..addColumns([db.spaces.serverUpdatedAt])
                  ..where(db.spaces.id.equals(id)))
                .map((row) => row.read(db.spaces.serverUpdatedAt))
                .getSingleOrNull();
      case EntityType.list:
        stamp =
            await (db.selectOnly(db.taskLists)
                  ..addColumns([db.taskLists.serverUpdatedAt])
                  ..where(db.taskLists.id.equals(id)))
                .map((row) => row.read(db.taskLists.serverUpdatedAt))
                .getSingleOrNull();
      case EntityType.task:
        stamp =
            await (db.selectOnly(db.tasks)
                  ..addColumns([db.tasks.serverUpdatedAt])
                  ..where(db.tasks.id.equals(id)))
                .map((row) => row.read(db.tasks.serverUpdatedAt))
                .getSingleOrNull();
      case EntityType.goal:
        stamp =
            await (db.selectOnly(db.savingsGoals)
                  ..addColumns([db.savingsGoals.serverUpdatedAt])
                  ..where(db.savingsGoals.id.equals(id)))
                .map((row) => row.read(db.savingsGoals.serverUpdatedAt))
                .getSingleOrNull();
      case EntityType.entry:
        stamp =
            await (db.selectOnly(db.savingsEntries)
                  ..addColumns([db.savingsEntries.serverUpdatedAt])
                  ..where(db.savingsEntries.id.equals(id)))
                .map((row) => row.read(db.savingsEntries.serverUpdatedAt))
                .getSingleOrNull();
      case EntityType.specialDate:
        stamp =
            await (db.selectOnly(db.specialDates)
                  ..addColumns([db.specialDates.serverUpdatedAt])
                  ..where(db.specialDates.id.equals(id)))
                .map((row) => row.read(db.specialDates.serverUpdatedAt))
                .getSingleOrNull();
      case EntityType.trip:
        stamp =
            await (db.selectOnly(db.trips)
                  ..addColumns([db.trips.serverUpdatedAt])
                  ..where(db.trips.id.equals(id)))
                .map((row) => row.read(db.trips.serverUpdatedAt))
                .getSingleOrNull();
      case EntityType.memory:
        stamp =
            await (db.selectOnly(db.memories)
                  ..addColumns([db.memories.serverUpdatedAt])
                  ..where(db.memories.id.equals(id)))
                .map((row) => row.read(db.memories.serverUpdatedAt))
                .getSingleOrNull();
      case EntityType.memoryPhoto:
        stamp =
            await (db.selectOnly(db.memoryPhotos)
                  ..addColumns([db.memoryPhotos.serverUpdatedAt])
                  ..where(db.memoryPhotos.id.equals(id)))
                .map((row) => row.read(db.memoryPhotos.serverUpdatedAt))
                .getSingleOrNull();
      case EntityType.me:
        stamp = null;
    }
    return stamp == null ? null : DateTime.parse(stamp);
  }

  /// Simpan atau timpa baris berdasarkan `id`.
  ///
  /// [serverUpdatedAt] diisi hanya saat baris berasal dari server; tulisan lokal
  /// tidak menyentuhnya, supaya jam HP yang meleset tidak mengalahkan data server.
  Future<void> write(EntityType type, Map<String, dynamic> json, {String? serverUpdatedAt}) async {
    switch (type) {
      case EntityType.space:
        await db
            .into(db.spaces)
            .insertOnConflictUpdate(spaceCompanion(Space.fromJson(json), serverUpdatedAt: serverUpdatedAt));
      case EntityType.list:
        await db
            .into(db.taskLists)
            .insertOnConflictUpdate(taskListCompanion(TaskList.fromJson(json), serverUpdatedAt: serverUpdatedAt));
      case EntityType.task:
        await db
            .into(db.tasks)
            .insertOnConflictUpdate(taskCompanion(Task.fromJson(json), serverUpdatedAt: serverUpdatedAt));
      case EntityType.goal:
        await db
            .into(db.savingsGoals)
            .insertOnConflictUpdate(savingsGoalCompanion(SavingsGoal.fromJson(json), serverUpdatedAt: serverUpdatedAt));
      case EntityType.entry:
        await db
            .into(db.savingsEntries)
            .insertOnConflictUpdate(
              savingsEntryCompanion(SavingsEntry.fromJson(json), serverUpdatedAt: serverUpdatedAt),
            );
      case EntityType.specialDate:
        await db
            .into(db.specialDates)
            .insertOnConflictUpdate(specialDateCompanion(SpecialDate.fromJson(json), serverUpdatedAt: serverUpdatedAt));
      case EntityType.trip:
        await db
            .into(db.trips)
            .insertOnConflictUpdate(tripCompanion(Trip.fromJson(json), serverUpdatedAt: serverUpdatedAt));
      case EntityType.memory:
        await db
            .into(db.memories)
            .insertOnConflictUpdate(memoryCompanion(Memory.fromJson(json), serverUpdatedAt: serverUpdatedAt));
      case EntityType.memoryPhoto:
        await db
            .into(db.memoryPhotos)
            .insertOnConflictUpdate(memoryPhotoCompanion(MemoryPhoto.fromJson(json), serverUpdatedAt: serverUpdatedAt));
      case EntityType.me:
        await setMeta(MetaKeys.profile, jsonEncode(User.fromJson(json).toJson()));
    }
  }

  /// Ubah beberapa kolom baris lokal. Mengembalikan nilai kolom itu sebelum diubah,
  /// atau `null` kalau barisnya tidak ada.
  Future<Map<String, dynamic>?> patch(EntityType type, String id, Map<String, dynamic> changes) async {
    final current = await read(type, id);
    if (current == null) return null;

    final before = <String, dynamic>{for (final key in changes.keys) key: current[key]};
    await write(type, {...current, ...changes});
    return before;
  }

  /// Buang baris dari cache (bukan sekadar menandai terhapus).
  Future<void> remove(EntityType type, String id) async {
    switch (type) {
      case EntityType.space:
        await (db.delete(db.spaces)..where((t) => t.id.equals(id))).go();
      case EntityType.list:
        await (db.delete(db.taskLists)..where((t) => t.id.equals(id))).go();
      case EntityType.task:
        await (db.delete(db.tasks)..where((t) => t.id.equals(id))).go();
      case EntityType.goal:
        await (db.delete(db.savingsGoals)..where((t) => t.id.equals(id))).go();
      case EntityType.entry:
        await (db.delete(db.savingsEntries)..where((t) => t.id.equals(id))).go();
      case EntityType.specialDate:
        await (db.delete(db.specialDates)..where((t) => t.id.equals(id))).go();
      case EntityType.trip:
        await (db.delete(db.trips)..where((t) => t.id.equals(id))).go();
      case EntityType.memory:
        await (db.delete(db.memories)..where((t) => t.id.equals(id))).go();
      case EntityType.memoryPhoto:
        await (db.delete(db.memoryPhotos)..where((t) => t.id.equals(id))).go();
      case EntityType.me:
        break;
    }
  }

  /// Tandai terhapus semua anak dari induk [parentId], kecuali ID di [except].
  Future<void> markChildrenDeleted(
    EntityType parentType,
    String parentId, {
    required String deletedAt,
    Set<String> except = const {},
  }) async {
    switch (parentType) {
      case EntityType.list:
        await (db.update(db.tasks)
              ..where((t) => t.taskListId.equals(parentId) & t.deletedAt.isNull() & t.id.isNotIn(except)))
            .write(TasksCompanion(deletedAt: Value(deletedAt)));
      case EntityType.goal:
        await (db.update(db.savingsEntries)
              ..where((t) => t.savingsGoalId.equals(parentId) & t.deletedAt.isNull() & t.id.isNotIn(except)))
            .write(SavingsEntriesCompanion(deletedAt: Value(deletedAt)));
      case EntityType.memory:
        await (db.update(db.memoryPhotos)
              ..where((t) => t.memoryId.equals(parentId) & t.deletedAt.isNull() & t.id.isNotIn(except)))
            .write(MemoryPhotosCompanion(deletedAt: Value(deletedAt)));
      case EntityType.space ||
          EntityType.task ||
          EntityType.entry ||
          EntityType.specialDate ||
          EntityType.trip ||
          EntityType.memoryPhoto ||
          EntityType.me:
        break;
    }
  }

  // ---------------------------------------------------------------- meta

  Future<String?> meta(String key) async {
    final row = await (db.select(db.metaEntries)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setMeta(String key, String? value) async {
    if (value == null) {
      await (db.delete(db.metaEntries)..where((t) => t.key.equals(key))).go();
      return;
    }
    await db.into(db.metaEntries).insertOnConflictUpdate(MetaEntriesCompanion.insert(key: key, value: value));
  }

  Stream<String?> watchMeta(String key) =>
      (db.select(db.metaEntries)..where((t) => t.key.equals(key))).watchSingleOrNull().map((row) => row?.value);

  // ---------------------------------------------------------------- profil

  Future<User?> profile() async {
    final raw = await meta(MetaKeys.profile);
    return raw == null ? null : User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Stream<User?> watchProfile() =>
      watchMeta(MetaKeys.profile)
          .map((raw) => raw == null ? null : User.fromJson(jsonDecode(raw) as Map<String, dynamic>));

  // ---------------------------------------------------------------- untuk UI

  /// Ruang yang belum dihapus, Ruang Bersama lebih dulu.
  Stream<List<Space>> watchSpaces() => (db.select(db.spaces)..where((t) => t.deletedAt.isNull())).watch().map(
    (rows) => rows.map((row) => row.toModel()).toList()..sort(_bySharedFirst),
  );

  Future<List<Space>> spaces() async {
    final rows = await (db.select(db.spaces)..where((t) => t.deletedAt.isNull())).get();
    return rows.map((row) => row.toModel()).toList()..sort(_bySharedFirst);
  }

  /// Daftar yang belum dihapus (termasuk yang diarsipkan), urut `position`.
  Stream<List<TaskList>> watchTaskLists() =>
      (db.select(db.taskLists)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm(expression: t.position), (t) => OrderingTerm(expression: t.id)]))
          .watch()
          .map((rows) => rows.map((row) => row.toModel()).toList());

  Future<List<TaskList>> taskLists() async {
    final rows =
        await (db.select(db.taskLists)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm(expression: t.position), (t) => OrderingTerm(expression: t.id)]))
            .get();
    return rows.map((row) => row.toModel()).toList();
  }

  /// Tugas yang belum dihapus, urut `position`.
  Stream<List<Task>> watchTasks() =>
      (db.select(db.tasks)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm(expression: t.position), (t) => OrderingTerm(expression: t.id)]))
          .watch()
          .map((rows) => rows.map((row) => row.toModel()).toList());

  Future<List<Task>> tasks() async {
    final rows = await (db.select(db.tasks)..where((t) => t.deletedAt.isNull())).get();
    return rows.map((row) => row.toModel()).toList();
  }

  /// Target yang belum dihapus (termasuk yang diarsipkan), yang paling lama dibuat lebih dulu.
  Stream<List<SavingsGoal>> watchGoals() =>
      (db.select(db.savingsGoals)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt), (t) => OrderingTerm(expression: t.id)]))
          .watch()
          .map((rows) => rows.map((row) => row.toModel()).toList());

  /// Setoran yang belum dihapus, yang terbaru lebih dulu.
  Stream<List<SavingsEntry>> watchEntries() =>
      (db.select(db.savingsEntries)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([
              (t) => OrderingTerm(expression: t.entryDate, mode: OrderingMode.desc),
              (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
              (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
            ]))
          .watch()
          .map((rows) => rows.map((row) => row.toModel()).toList());

  /// Tanggal penting yang belum dihapus. Urutan tampil dihitung di HP dari hari jatuhnya berikutnya.
  Stream<List<SpecialDate>> watchSpecialDates() =>
      (db.select(db.specialDates)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm(expression: t.id)]))
          .watch()
          .map((rows) => rows.map((row) => row.toModel()).toList());

  /// Perjalanan yang belum dihapus. Urutan tampil dihitung di HP dari tanggal dan statusnya.
  Stream<List<Trip>> watchTrips() =>
      (db.select(db.trips)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm(expression: t.id)]))
          .watch()
          .map((rows) => rows.map((row) => row.toModel()).toList());

  /// Checklist perjalanan [tripId] yang belum dihapus. Biasanya satu, tapi bisa kosong
  /// selama checklist buatan HP pasangan belum sampai lewat sync.
  Future<List<TaskList>> checklistsOf(String tripId) async {
    final rows = await (db.select(db.taskLists)..where((t) => t.tripId.equals(tripId) & t.deletedAt.isNull())).get();
    return rows.map((row) => row.toModel()).toList();
  }

  /// Kenangan yang belum dihapus. Linimasanya diurutkan di HP dari `visited_on`.
  Stream<List<Memory>> watchMemories() =>
      (db.select(db.memories)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm(expression: t.id)]))
          .watch()
          .map((rows) => rows.map((row) => row.toModel()).toList());

  /// Foto kenangan yang belum dihapus, urut `position`.
  Stream<List<MemoryPhoto>> watchMemoryPhotos() =>
      (db.select(db.memoryPhotos)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm(expression: t.position), (t) => OrderingTerm(expression: t.id)]))
          .watch()
          .map((rows) => rows.map((row) => row.toModel()).toList());

  /// Foto kenangan [memoryId] yang belum dihapus, urut `position`.
  Future<List<MemoryPhoto>> memoryPhotos(String memoryId) async {
    final rows =
        await (db.select(db.memoryPhotos)
              ..where((t) => t.memoryId.equals(memoryId) & t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm(expression: t.position), (t) => OrderingTerm(expression: t.id)]))
            .get();
    return rows.map((row) => row.toModel()).toList();
  }

  static int _bySharedFirst(Space a, Space b) {
    if (a.isShared != b.isShared) return a.isShared ? -1 : 1;
    return a.createdAt.compareTo(b.createdAt);
  }
}
