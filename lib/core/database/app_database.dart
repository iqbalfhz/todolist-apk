import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Cache lokal dan antrean untuk satu akun.
///
/// Semua waktu disimpan sebagai teks ISO 8601 persis seperti dikirim server
/// (mikrodetik), dan tidak ada foreign key: saat sync, tugas bisa tiba sebelum daftarnya.
/// `serverUpdatedAt` berisi `updated_at` terakhir yang datang dari server; kosong
/// berarti baris itu baru dibuat di HP dan belum pernah dibalas server.

@DataClassName('SpaceRow')
class Spaces extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get timezone => text()();
  TextColumn get ownerId => text()();

  /// JSON larik anggota, sama bentuknya dengan `members` di kontrak.
  TextColumn get members => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();
  TextColumn get serverUpdatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TaskListRow')
class TaskLists extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  TextColumn get name => text()();
  TextColumn get emoji => text().nullable()();
  TextColumn get color => text()();
  RealColumn get position => real()();
  TextColumn get archivedAt => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();
  TextColumn get serverUpdatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TaskRow')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get taskListId => text()();
  TextColumn get spaceId => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get dueDate => text().nullable()();
  TextColumn get dueTime => text().nullable()();
  IntColumn get priority => integer()();
  RealColumn get position => real()();

  /// JSON larik ID penanggung jawab.
  TextColumn get assigneeIds => text()();
  TextColumn get remindAt => text().nullable()();
  TextColumn get completedAt => text().nullable()();
  TextColumn get completedBy => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get updatedBy => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();
  TextColumn get serverUpdatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SavingsGoalRow')
class SavingsGoals extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  TextColumn get name => text()();
  TextColumn get emoji => text().nullable()();
  IntColumn get targetAmount => integer()();
  TextColumn get currency => text()();
  TextColumn get targetDate => text().nullable()();
  TextColumn get achievedAt => text().nullable()();
  TextColumn get archivedAt => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();
  TextColumn get serverUpdatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SavingsEntryRow')
class SavingsEntries extends Table {
  TextColumn get id => text()();
  TextColumn get savingsGoalId => text()();
  TextColumn get spaceId => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get type => text()();
  IntColumn get amount => integer()();
  TextColumn get entryDate => text()();
  TextColumn get note => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();
  TextColumn get serverUpdatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Tanggal penting (v0.2).
@DataClassName('SpecialDateRow')
class SpecialDates extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  TextColumn get type => text()();
  TextColumn get title => text()();

  /// `YYYY-MM-DD`, atau `--MM-DD` kalau tahunnya tidak diketahui.
  TextColumn get date => text()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();
  TextColumn get serverUpdatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Antrean operasi tulis yang belum sampai ke server, dikirim berurutan menurut `id`.
@DataClassName('OutboxRow')
class OutboxOps extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();

  /// `PUT`, `PATCH`, atau `DELETE`.
  TextColumn get method => text()();

  /// JSON body request; kosong untuk `DELETE`.
  TextColumn get payload => text().nullable()();

  /// JSON nilai kolom sebelum diubah (yang paling awal), untuk Urungkan.
  TextColumn get before => text().nullable()();

  /// Ditandai sebelum dikirim. Operasi yang pernah dikirim tidak boleh digabung lagi.
  BoolColumn get attempted => boolean().withDefault(const Constant(false))();

  /// Milidetik epoch; selama belum lewat, operasi menunggu tombol Urungkan.
  IntColumn get holdUntil => integer().nullable()();
  IntColumn get createdAt => integer()();
}

/// Nilai tunggal per akun: kursor sync, profil sendiri, dan sejenisnya.
@DataClassName('MetaRow')
class MetaEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [Spaces, TaskLists, Tasks, SavingsGoals, SavingsEntries, SpecialDates, OutboxOps, MetaEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Database milik satu akun. Akun lain di HP yang sama memakai berkas berbeda,
  /// jadi antrean akun sebelumnya tidak terkirim atas nama akun baru.
  AppDatabase.forAccount(String userId) : super(driftDatabase(name: 'akun_$userId'));

  /// 1: v0.1. 2: tabel tanggal penting (v0.2).
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) await migrator.createTable(specialDates);
    },
  );
}
