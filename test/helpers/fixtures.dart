import 'dart:async';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/api/api_transport.dart';
import 'package:todolist/core/database/app_database.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/session/account.dart';
import 'package:todolist/core/storage/key_value_store.dart';

import 'fake_api.dart';
import 'fake_photos.dart';

// ID dari contoh di `docs/kontrak-api.md`.
const String meId = '01m4dg5jegv6sp4xav8efqzcqe';
const String partnerId = '01m4dga4y03c5ratqsc31zc916';
const String sharedSpaceId = '01m4dgdt40te98hy85v3fe2t18';
const String personalSpaceId = '01m4dg5jf0v6sp4xav8efqzcq0';
const String listId = '01m4dh0420zqexwxs1n4yw5jn2';
const String otherListId = '01m4dh0421zqexwxs1n4yw5jn3';
const String taskId = '01m4dh1yn0t6cdn39q4f091895';
const String goalId = '01m4djq1w0ystkpbz7mqd22k3n';
const String entryId = '01m4dk06v0p3ew0dm0dk94s1k0';
const String specialDateId = '01m4dm2k70z5bq7rn3xw8c4v1e';
const String tripId = '01m4dp5r20vbx9k3ws7ty6hn2q';
const String checklistId = '01m4dp5r21vbx9k3ws7ty6hn2r';
const String memoryId = '01m4dr8c50jk2mt7xw3pq9vb6e';
const String photoId = '01m4drb7k0qz3n8st5vw2hx4cy';
const String photo2Id = '01m4drb7k1qz3n8st5vw2hx4cz';

const String t0 = '2026-10-08T10:00:00.000000Z';
const String t1 = '2026-10-08T10:30:00.000000Z';
const String t2 = '2026-10-08T11:00:00.000000Z';

Map<String, dynamic> userJson({String id = meId, String name = 'Iqbal', String color = 'mawar'}) => {
  'id': id,
  'name': name,
  'email': 'nama@email.com',
  'color': color,
  'timezone': 'Asia/Jakarta',
  'locale': 'id',
  'default_currency': 'IDR',
  'birth_date': '--03-02',
  'notification_prefs': {
    'task_reminders': true,
    'partner_activity': true,
    'savings_activity': true,
    'special_dates': true,
    'trip_reminders': true,
    'savings_reminders': true,
  },
  'avatar_url': null,
  'avatar_version': 0,
  'invitation': null,
  'created_at': t0,
  'updated_at': t0,
};

Map<String, dynamic> memberJson({
  required String id,
  required String name,
  required String color,
  String role = 'member',
  String? birthDate,
}) => {
  'id': id,
  'name': name,
  'color': color,
  'avatar_url': null,
  'avatar_version': 0,
  'birth_date': birthDate,
  'role': role,
  'joined_at': t0,
};

Map<String, dynamic> sharedSpaceJson({String updatedAt = t0, String? myBirthDate, String? partnerBirthDate}) => {
  'id': sharedSpaceId,
  'name': 'Ruang Bersama',
  'type': 'shared',
  'timezone': 'Asia/Jakarta',
  'owner_id': meId,
  'members': [
    memberJson(id: meId, name: 'Iqbal', color: 'mawar', role: 'owner', birthDate: myBirthDate),
    memberJson(id: partnerId, name: 'Sari', color: 'ungu', birthDate: partnerBirthDate),
  ],
  'created_at': t0,
  'updated_at': updatedAt,
  'deleted_at': null,
};

Map<String, dynamic> personalSpaceJson() => {
  'id': personalSpaceId,
  'name': 'Ruang Pribadi',
  'type': 'personal',
  'timezone': 'Asia/Jakarta',
  'owner_id': meId,
  'members': [memberJson(id: meId, name: 'Iqbal', color: 'mawar', role: 'owner')],
  'created_at': t0,
  'updated_at': t0,
  'deleted_at': null,
};

Map<String, dynamic> listJson({
  String id = listId,
  String spaceId = sharedSpaceId,
  String name = 'Belanja',
  String color = 'toska',
  num position = 1024,
  String? archivedAt,
  String? tripId,
  String? deletedAt,
  String updatedAt = t0,
}) => {
  'id': id,
  'space_id': spaceId,
  'name': name,
  'emoji': null,
  'color': color,
  'position': position,
  'archived_at': archivedAt,
  'trip_id': tripId,
  'created_by': meId,
  'created_at': t0,
  'updated_at': updatedAt,
  'deleted_at': deletedAt,
};

Map<String, dynamic> taskJson({
  String id = taskId,
  String taskListId = listId,
  String spaceId = sharedSpaceId,
  String title = 'Beli galon',
  String? notes,
  String? dueDate,
  String? dueTime,
  int priority = 0,
  num position = 2048,
  List<String> assigneeIds = const [meId],
  String? completedAt,
  String? completedBy,
  String? repeatFrequency,
  int? repeatInterval,
  String? nextTaskId,
  String? deletedAt,
  String updatedAt = t0,
}) => {
  'id': id,
  'task_list_id': taskListId,
  'space_id': spaceId,
  'title': title,
  'notes': notes,
  'due_date': dueDate,
  'due_time': dueTime,
  'priority': priority,
  'position': position,
  'assignee_ids': assigneeIds,
  'repeat_frequency': repeatFrequency,
  'repeat_interval': repeatFrequency == null ? null : (repeatInterval ?? 1),
  'remind_at': null,
  'completed_at': completedAt,
  'completed_by': completedBy,
  'next_task_id': nextTaskId,
  'created_by': meId,
  'updated_by': meId,
  'created_at': t0,
  'updated_at': updatedAt,
  'deleted_at': deletedAt,
};

Map<String, dynamic> goalJson({
  String id = goalId,
  String spaceId = sharedSpaceId,
  String name = 'Dana Liburan',
  int targetAmount = 10000000,
  String currency = 'IDR',
  String? targetDate = '2027-02-28',
  String? reminderFrequency,
  int? reminderDay,
  String? archivedAt,
  String? deletedAt,
  String updatedAt = t0,
}) => {
  'id': id,
  'space_id': spaceId,
  'name': name,
  'emoji': null,
  'target_amount': targetAmount,
  'currency': currency,
  'target_date': targetDate,
  'reminder_frequency': reminderFrequency,
  'reminder_day': reminderDay,
  'achieved_at': null,
  'archived_at': archivedAt,
  'created_by': meId,
  'created_at': t0,
  'updated_at': updatedAt,
  'deleted_at': deletedAt,
};

Map<String, dynamic> entryJson({
  String id = entryId,
  String savingsGoalId = goalId,
  String userId = meId,
  int amount = 200000,
  String entryDate = '2026-10-08',
  String? note = 'Gajian',
  String? deletedAt,
  String updatedAt = t0,
}) => {
  'id': id,
  'savings_goal_id': savingsGoalId,
  'space_id': sharedSpaceId,
  'user_id': userId,
  'type': 'deposit',
  'amount': amount,
  'entry_date': entryDate,
  'note': note,
  'created_at': t0,
  'updated_at': updatedAt,
  'deleted_at': deletedAt,
};

/// Tanggal penting, sama dengan contoh di kontrak: hari jadi di Ruang Bersama.
Map<String, dynamic> specialDateJson({
  String id = specialDateId,
  String spaceId = sharedSpaceId,
  String type = 'anniversary',
  String title = 'Hari jadi kita',
  String date = '2023-10-29',
  String? deletedAt,
  String updatedAt = t0,
}) => {
  'id': id,
  'space_id': spaceId,
  'type': type,
  'title': title,
  'date': date,
  'created_by': meId,
  'created_at': t0,
  'updated_at': updatedAt,
  'deleted_at': deletedAt,
};

/// Perjalanan, sama dengan contoh di kontrak: Liburan ke Bali di Ruang Bersama.
Map<String, dynamic> memoryJson({
  String id = memoryId,
  String spaceId = sharedSpaceId,
  String? tripId,
  String title = 'Liburan ke Bali',
  String? placeName = 'Ubud, Bali',
  String visitedOn = '2027-06-20',
  String? story = 'Hari pertama hujan, tapi sawahnya tetap hijau.',
  String createdAt = t0,
  String? deletedAt,
  String updatedAt = t0,
}) => {
  'id': id,
  'space_id': spaceId,
  'trip_id': tripId,
  'title': title,
  'place_name': placeName,
  'visited_on': visitedOn,
  'story': story,
  'created_by': meId,
  'created_at': createdAt,
  'updated_at': updatedAt,
  'deleted_at': deletedAt,
};

/// URL R2 bertanda tangan palsu, ditandatangani [signedAt] (`YYYYMMDDTHHMMSSZ`) dan berlaku 7 hari.
String signedPhotoUrl(String id, {bool thumb = false, String signedAt = '20261008T100000Z'}) =>
    'https://r2.contoh.test/memories/$id${thumb ? '-thumb' : ''}.jpg?X-Amz-Date=$signedAt&X-Amz-Expires=604800&X-Amz-Signature=palsu';

Map<String, dynamic> memoryPhotoJson({
  String id = photoId,
  String memory = memoryId,
  String spaceId = sharedSpaceId,
  num position = 1024,
  String signedAt = '20261008T100000Z',
  String? takenAt = '2027-06-20T03:12:45.000000Z',
  String? deletedAt,
  String updatedAt = t0,
}) => {
  'id': id,
  'memory_id': memory,
  'space_id': spaceId,
  'uploaded_by': partnerId,
  'position': position,
  'width': 2560,
  'height': 1920,
  'taken_at': takenAt,
  'url': deletedAt == null ? signedPhotoUrl(id, signedAt: signedAt) : null,
  'thumb_url': deletedAt == null ? signedPhotoUrl(id, thumb: true, signedAt: signedAt) : null,
  'created_at': t0,
  'updated_at': updatedAt,
  'deleted_at': deletedAt,
};

Map<String, dynamic> tripJson({
  String id = tripId,
  String spaceId = sharedSpaceId,
  String title = 'Liburan ke Bali',
  String? destination = 'Bali',
  String? startDate = '2027-06-20',
  String? endDate = '2027-06-25',
  String? notes,
  String? savingsGoalId,
  String? deletedAt,
  String updatedAt = t0,
}) => {
  'id': id,
  'space_id': spaceId,
  'title': title,
  'destination': destination,
  'start_date': startDate,
  'end_date': endDate,
  'notes': notes,
  'savings_goal_id': savingsGoalId,
  'created_by': meId,
  'created_at': t0,
  'updated_at': updatedAt,
  'deleted_at': deletedAt,
};

/// Checklist persiapan perjalanan [trip]: daftar tugas dengan `trip_id`.
Map<String, dynamic> checklistJson({
  String id = checklistId,
  String trip = tripId,
  String spaceId = sharedSpaceId,
  String name = 'Persiapan Liburan ke Bali',
  String? deletedAt,
}) =>
    listJson(id: id, spaceId: spaceId, name: name, color: 'mawar', position: 9216, tripId: trip, deletedAt: deletedAt);

/// Jam yang bisa dimajukan dari tes.
class TestClock {
  TestClock([DateTime? start]) : now = start ?? DateTime.utc(2026, 10, 8, 10);

  DateTime now;

  DateTime call() => now;

  void advance(Duration duration) => now = now.add(duration);
}

/// Pengganti `Timer` yang tidak pernah berbunyi sendiri; tes yang memicunya.
class ManualTimers {
  final List<ManualTimer> created = [];

  Timer create(Duration delay, void Function() callback) {
    final timer = ManualTimer(delay, callback);
    created.add(timer);
    return timer;
  }

  /// Timer aktif yang paling baru dibuat.
  ManualTimer? get pending => created.where((timer) => timer.isActive).lastOrNull;
}

class ManualTimer implements Timer {
  ManualTimer(this.delay, this._callback);

  final Duration delay;
  final void Function() _callback;
  bool _active = true;

  void fire() {
    if (!_active) return;
    _active = false;
    _callback();
  }

  @override
  void cancel() => _active = false;

  @override
  bool get isActive => _active;

  @override
  int get tick => 0;
}

/// Penyimpanan kunci-nilai di memori.
class MemoryKeyValueStore implements KeyValueStore {
  MemoryKeyValueStore([Map<String, String>? initial]) : values = {...?initial};

  final Map<String, String> values;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String? value) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }
}

/// Pengirim yang bisa dialihkan. Mula-mula langsung ke API palsu; di tes widget dialihkan
/// ke klien API milik app, supaya banner offline dan sesi yang berakhir ikut teruji.
class SwitchableTransport implements ApiTransport {
  SwitchableTransport(this.inner);

  ApiTransport inner;

  @override
  Future<ApiResponse> send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    ApiUpload? upload,
  }) => inner.send(method, path, body: body, query: query, upload: upload);
}

/// Akun dengan database di memori, API palsu, jam palsu, dan timer manual.
class Harness {
  Harness({bool autoFlush = false}) {
    // Setiap tes membuka database di memori sendiri; itu disengaja.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    api = FakeApi(now: clock.call);
    transport = SwitchableTransport(api);
    account = Account(
      userId: meId,
      db: AppDatabase(NativeDatabase.memory()),
      api: transport,
      photoCache: photoCache,
      photoFiles: photoFiles,
      now: clock.call,
      createTimer: timers.create,
      autoFlush: autoFlush,
    );
  }

  final TestClock clock = TestClock();
  final ManualTimers timers = ManualTimers();

  /// Cache gambar yang dikosongkan saat keluar.
  final FakeMediaCaches mediaCaches = FakeMediaCaches();

  /// Token yang dipakai untuk mencabut token lama dari keluar saat offline.
  final List<String> revocationTokens = [];

  /// Foto kenangan (v0.3): cache dan berkas tunggu unggah di memori.
  final FakePhotoCache photoCache = FakePhotoCache();
  late final FakePhotoFiles photoFiles = FakePhotoFiles(photoCache);
  late final FakeApi api;
  late final SwitchableTransport transport;
  late final Account account;

  /// Isi cache seolah baru selesai sync: profil, dua ruang, dan satu daftar di Ruang Bersama.
  /// Datanya juga ada "di server".
  Future<void> seed({bool withTask = false, bool withGoal = false}) async {
    final store = account.store;
    await store.write(EntityType.me, userJson());
    await store.write(EntityType.space, sharedSpaceJson(), serverUpdatedAt: t0);
    await store.write(EntityType.space, personalSpaceJson(), serverUpdatedAt: t0);
    await store.write(EntityType.list, listJson(), serverUpdatedAt: t0);
    api.rows.putIfAbsent('lists', () => {})[listId] = listJson();
    api.me = userJson();

    if (withTask) {
      await store.write(EntityType.task, taskJson(), serverUpdatedAt: t0);
      api.rows.putIfAbsent('tasks', () => {})[taskId] = taskJson();
    }
    if (withGoal) {
      await store.write(EntityType.goal, goalJson(), serverUpdatedAt: t0);
      api.rows.putIfAbsent('savings-goals', () => {})[goalId] = goalJson();
    }
  }

  Future<Map<String, dynamic>?> local(EntityType type, String id) => account.store.read(type, id);

  Future<List<OutboxRow>> ops() => account.db.select(account.db.outboxOps).get();

  Future<void> dispose() => account.dispose();
}
