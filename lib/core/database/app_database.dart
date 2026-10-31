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

  /// Terisi berarti daftar ini checklist persiapan sebuah perjalanan (v0.2).
  TextColumn get tripId => text().nullable()();
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

  /// Aturan ulang (v1.0).
  TextColumn get repeatFrequency => text().nullable()();
  IntColumn get repeatInterval => integer().nullable()();
  TextColumn get remindAt => text().nullable()();
  TextColumn get completedAt => text().nullable()();
  TextColumn get completedBy => text().nullable()();

  /// Tugas berikutnya dari tugas berulang yang sudah selesai (v1.0).
  TextColumn get nextTaskId => text().nullable()();
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

  /// Pengingat setor rutin (v0.2): `weekly` atau `monthly`, dan hari atau tanggalnya.
  TextColumn get reminderFrequency => text().nullable()();
  IntColumn get reminderDay => integer().nullable()();
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

/// Perjalanan (v0.2). Checklist persiapannya adalah daftar tugas dengan `tripId` terisi.
@DataClassName('TripRow')
class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  TextColumn get title => text()();
  TextColumn get destination => text().nullable()();

  /// `YYYY-MM-DD`; kosong berarti tanggalnya belum pasti.
  TextColumn get startDate => text().nullable()();
  TextColumn get endDate => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get savingsGoalId => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();
  TextColumn get serverUpdatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Kenangan (v0.3): tempat yang pernah didatangi, dengan cerita dan fotonya.
@DataClassName('MemoryRow')
class Memories extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  TextColumn get tripId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get placeName => text().nullable()();

  /// Pin lokasi (v1.x), selalu berpasangan.
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();

  /// `YYYY-MM-DD`; tanggal kenangan di linimasa.
  TextColumn get visitedOn => text()();
  TextColumn get story => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();
  TextColumn get serverUpdatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Foto kenangan (v0.3). `url` dan `thumbUrl` kosong selama foto belum terunggah;
/// berkasnya yang menunggu diunggah disimpan di luar database.
@DataClassName('MemoryPhotoRow')
class MemoryPhotos extends Table {
  TextColumn get id => text()();
  TextColumn get memoryId => text()();
  TextColumn get spaceId => text()();
  TextColumn get uploadedBy => text().nullable()();
  RealColumn get position => real()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  TextColumn get takenAt => text().nullable()();
  TextColumn get url => text().nullable()();
  TextColumn get thumbUrl => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();
  TextColumn get serverUpdatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Komentar pada tugas, setoran, atau kenangan (v1.x).
@DataClassName('CommentRow')
class Comments extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  TextColumn get subjectType => text()();
  TextColumn get subjectId => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get body => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();
  TextColumn get serverUpdatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Reaksi emoji pada tugas, setoran, atau kenangan (v1.x).
@DataClassName('ReactionRow')
class Reactions extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  TextColumn get subjectType => text()();
  TextColumn get subjectId => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get emoji => text()();
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

@DriftDatabase(
  tables: [
    Spaces,
    TaskLists,
    Tasks,
    SavingsGoals,
    SavingsEntries,
    SpecialDates,
    Trips,
    Memories,
    MemoryPhotos,
    Comments,
    Reactions,
    OutboxOps,
    MetaEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Database milik satu akun. Akun lain di HP yang sama memakai berkas berbeda,
  /// jadi antrean akun sebelumnya tidak terkirim atas nama akun baru.
  AppDatabase.forAccount(String userId) : super(driftDatabase(name: fileNameFor(userId)));

  /// Nama berkas database akun [userId], tanpa `.sqlite`.
  static String fileNameFor(String userId) => 'akun_$userId';

  /// 1: v0.1. 2: tabel tanggal penting. 3: tabel perjalanan, `trip_id` di daftar,
  /// dan jadwal pengingat setor di target (semuanya v0.2). 4: kenangan dan fotonya (v0.3).
  /// 5: aturan ulang tugas (v1.0). 6: pin lokasi kenangan. 7: komentar dan reaksi (v1.x).
  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) await migrator.createTable(specialDates);
      if (from < 3) {
        await migrator.createTable(trips);
        await migrator.addColumn(taskLists, taskLists.tripId);
        await migrator.addColumn(savingsGoals, savingsGoals.reminderFrequency);
        await migrator.addColumn(savingsGoals, savingsGoals.reminderDay);
      }
      if (from < 4) {
        await migrator.createTable(memories);
        await migrator.createTable(memoryPhotos);
      }
      if (from < 5) {
        await migrator.addColumn(tasks, tasks.repeatFrequency);
        await migrator.addColumn(tasks, tasks.repeatInterval);
        await migrator.addColumn(tasks, tasks.nextTaskId);
      }
      // Pin lokasi kenangan (v1.x). Database sebelum versi 4 baru saja membuat tabel kenangan
      // dengan kolom ini.
      if (from >= 4 && from < 6) {
        await migrator.addColumn(memories, memories.latitude);
        await migrator.addColumn(memories, memories.longitude);
      }
      if (from < 7) {
        await migrator.createTable(comments);
        await migrator.createTable(reactions);
      }
    },
  );
}
