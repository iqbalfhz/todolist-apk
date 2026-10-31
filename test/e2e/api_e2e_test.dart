// Tes ujung ke ujung terhadap API Laravel yang sungguhan.
//
// Dilewati kecuali variabel lingkungan E2E_API_URL diisi, misalnya:
//
//   E2E_API_URL=http://127.0.0.1:8000/api/v1 flutter test test/e2e
//
// Jalankan hanya ke API lokal dengan database khusus tes: tes ini mendaftarkan akun baru.
// Sekali jalan memakai tiga permintaan daftar dan batas server 5 per menit, jadi beri jeda
// satu menit sebelum menjalankannya lagi. Kalau terlalu cepat, tes "email yang sudah
// terdaftar" gagal karena dibalas 429.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/api/api_transport.dart';
import 'package:todolist/core/database/app_database.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/media/photo_picker.dart';
import 'package:todolist/core/queue/outbox.dart';
import 'package:todolist/core/session/account.dart';
import 'package:todolist/core/utils/ulid.dart';
import 'package:todolist/features/auth/data/auth_repository.dart';
import 'package:todolist/features/auth/domain/user.dart';
import 'package:todolist/features/memories/domain/memory.dart';
import 'package:todolist/features/savings/domain/savings_goal.dart';
import 'package:todolist/features/spaces/domain/space.dart';
import 'package:todolist/features/tasks/domain/task.dart';
import 'package:todolist/features/tasks/domain/task_list.dart';
import 'package:todolist/features/trips/domain/trip.dart';

/// JPEG 2 × 2 px yang sah, untuk unggahan yang ditolak sebelum fotonya disimpan.
/// API lokal tidak punya kunci R2, jadi foto yang benar-benar tersimpan tidak diuji di sini.
final Uint8List tinyJpeg = base64Decode(
  '/9j/4AAQSkZJRgABAQEAYABgAAD//gA7Q1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkcgSlBFRyB2ODApLCBxdWFsaXR5ID0gODAK/9sAQwAGBAUGBQQGBgUGBwcGCAoQCgoJCQoUDg8MEBcUGBgXFBYWGh0lHxobIxwWFiAsICMmJykqKRkfLTAtKDAlKCko/9sAQwEHBwcKCAoTCgoTKBoWGigoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgo/8AAEQgAAgACAwEiAAIRAQMRAf/EAB8AAAEFAQEBAQEBAAAAAAAAAAABAgMEBQYHCAkKC//EALUQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+v/EAB8BAAMBAQEBAQEBAQEAAAAAAAABAgMEBQYHCAkKC//EALURAAIBAgQEAwQHBQQEAAECdwABAgMRBAUhMQYSQVEHYXETIjKBCBRCkaGxwQkjM1LwFWJy0QoWJDThJfEXGBkaJicoKSo1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoKDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uLj5OXm5+jp6vLz9PX29/j5+v/aAAwDAQACEQMRAD8AqUUUUH6Cf//Z',
);

/// Satu HP: token, klien API sungguhan, dan database lokal di memori.
class Device {
  Device(this.baseUrl) {
    api = ObservedTransport(
      DioApiTransport(baseUrl: baseUrl, token: () => token),
      onUnauthenticated: () => unauthenticated++,
    );
  }

  final String baseUrl;
  late final ApiTransport api;
  late Account account;
  late User user;
  String? token;
  int unauthenticated = 0;

  /// Dimajukan untuk melewati jeda Urungkan tanpa benar-benar menunggu.
  Duration skew = Duration.zero;

  DateTime now() => DateTime.now().add(skew);

  Future<void> signIn(AuthResult result) async {
    token = result.token;
    user = result.user;
    account = Account(userId: user.id, db: AppDatabase(NativeDatabase.memory()), api: api, now: now, autoFlush: false);
    await account.profile.save(user);
  }

  Future<List<TaskList>> lists() => account.store.taskLists();

  Future<List<Task>> tasks() => account.store.tasks();

  Future<List<Space>> spaces() => account.store.spaces();

  Future<Space> sharedSpace() async => (await spaces()).firstWhere((space) => space.isShared);

  Future<TaskList> sharedList() async {
    final space = await sharedSpace();
    return (await lists()).firstWhere((list) => list.spaceId == space.id && !list.isChecklist);
  }

  /// Kirim antrean (melewati jeda Urungkan) lalu tarik perubahan.
  Future<void> syncNow() async {
    skew += Outbox.undoWindow;
    expect(await account.sync.sync(retryNow: true), isTrue, reason: 'sync harus berhasil');
  }

  Future<void> close() => account.dispose();
}

void main() {
  final baseUrl = Platform.environment['E2E_API_URL'];
  final skipReason = baseUrl == null ? 'E2E_API_URL belum diisi' : null;

  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  final run = DateTime.now().millisecondsSinceEpoch;
  late Device a;
  late Device b;

  setUpAll(() async {
    if (baseUrl == null) return;
    a = Device(baseUrl);
    b = Device(baseUrl);

    await a.signIn(
      await AuthRepository(a.api).register(
        name: 'Aku E2E',
        email: 'aku-$run@contoh.test',
        password: 'rahasia-banget',
        deviceName: 'Tes E2E A',
        timezone: 'Asia/Jakarta',
      ),
    );
    await b.signIn(
      await AuthRepository(b.api).register(
        name: 'Pasangan E2E',
        email: 'pasangan-$run@contoh.test',
        password: 'rahasia-banget',
        deviceName: 'Tes E2E B',
        timezone: 'Asia/Jakarta',
      ),
    );
  });

  tearDownAll(() async {
    if (baseUrl == null) return;
    await a.close();
    await b.close();
  });

  test('daftar: token diterima, lalu sync penuh membawa Ruang Pribadi berisi satu daftar "Tugas"', () async {
    expect(a.token, isNotEmpty);
    expect(ulidPattern.hasMatch(a.user.id), isTrue);
    expect(a.user.timezone, 'Asia/Jakarta');
    expect(a.user.defaultCurrency, 'IDR');

    expect(await a.account.sync.hasSynced, isFalse);
    await a.syncNow();
    expect(await a.account.sync.hasSynced, isTrue);

    final spaces = await a.spaces();
    expect(spaces.single.isPersonal, isTrue);
    expect(spaces.single.members.single.id, a.user.id);

    final lists = await a.lists();
    expect(lists.single.name, 'Tugas');
    expect(lists.single.spaceId, spaces.single.id);
  }, skip: skipReason);

  test('salah kata sandi dibalas 422 invalid_credentials, bukan 401', () async {
    final attempt = Device(baseUrl!);

    await expectLater(
      AuthRepository(attempt.api).login(email: a.user.email, password: 'salah-total', deviceName: 'Tes'),
      throwsA(
        isA<ApiError>()
            .having((error) => error.code, 'code', ApiErrorCode.invalidCredentials)
            .having((error) => error.status, 'status', 422)
            .having((error) => error.message, 'message', 'Email atau kata sandi salah.'),
      ),
    );
    expect(attempt.unauthenticated, 0);
  }, skip: skipReason);

  test('masuk dengan Google: token yang bukan dari Google dibalas 422 google_token_invalid', () async {
    final attempt = Device(baseUrl!);

    // Kepala tokennya tidak terbaca, jadi server menolaknya tanpa menghubungi Google.
    await expectLater(
      AuthRepository(attempt.api).signInWithGoogle(idToken: 'bukan.token.google', deviceName: 'Tes'),
      throwsA(
        isA<ApiError>()
            .having((error) => error.code, 'code', ApiErrorCode.googleTokenInvalid)
            .having((error) => error.status, 'status', 422)
            .having((error) => error.message, 'message', 'Masuk dengan Google gagal. Coba lagi.'),
      ),
    );
    expect(attempt.unauthenticated, 0);
  }, skip: skipReason);

  test('email yang sudah terdaftar ditolak 422 di kolom email', () async {
    final attempt = Device(baseUrl!);

    await expectLater(
      AuthRepository(attempt.api)
          .register(name: 'Lagi', email: a.user.email, password: 'rahasia-banget', deviceName: 'Tes'),
      throwsA(
        isA<ApiError>()
            .having((error) => error.code, 'code', ApiErrorCode.validationFailed)
            .having((error) => error.errors.keys, 'errors', contains('email')),
      ),
    );
  }, skip: skipReason);

  test('tugas pribadi: PUT dari antrean dibalas 201 dan diterapkan; kiriman ulang dibalas 200', () async {
    final list = (await a.lists()).single;
    final task = await a.account.tasks.create(
      list: list,
      title: 'Kirim laporan bulanan',
      dueDate: '2026-10-09',
      dueTime: '15:00',
    );

    // Sebelum terkirim: ada di cache, belum dibalas server.
    expect(await a.account.store.serverUpdatedAt(EntityType.task, task.id), isNull);

    expect(await a.account.outbox.flush(), FlushState.idle);

    final stored = Task.fromJson((await a.account.store.read(EntityType.task, task.id))!);
    expect(stored.spaceId, list.spaceId);
    expect(stored.assigneeIds, [a.user.id], reason: 'tanpa assignee_ids berarti pembuat');
    expect(stored.dueTime, '15:00');
    // 9 Okt 15.00 WIB = 08.00 UTC.
    expect(stored.remindAt, DateTime.utc(2026, 10, 9, 8));
    expect(await a.account.store.serverUpdatedAt(EntityType.task, task.id), isNotNull);

    // PUT yang diulang tidak mengubah apa pun dan membalas data tersimpan (200).
    final again = await a.api.send(
      'PUT',
      '/tasks/${task.id}',
      body: {'task_list_id': list.id, 'title': 'Judul lain yang diabaikan', 'position': 1},
    );
    expect(again.status, 200);
    expect(again.data['title'], 'Kirim laporan bulanan');
  }, skip: skipReason);

  test('undangan: kode 6 karakter; kode sendiri dan kode salah ditolak invitation_invalid', () async {
    final invitation = await a.account.spaces.invitation();
    expect(invitation.code, matches(RegExp(r'^[23456789ABCDEFGHJKLMNPQRSTUVWXYZ]{6}$')));
    expect(invitation.expiresAt.isAfter(DateTime.now().add(const Duration(hours: 47))), isTrue);

    // Dipanggil lagi: kode aktif yang sama.
    expect((await a.account.spaces.invitation()).code, invitation.code);
    expect((await a.account.profile.refresh()).invitation?.code, invitation.code);

    for (final code in [invitation.code, 'ZZZZZZ']) {
      await expectLater(
        a.account.spaces.accept(code),
        throwsA(
          isA<ApiError>()
              .having((error) => error.code, 'code', ApiErrorCode.invitationInvalid)
              .having((error) => error.message, 'message', 'Kode tidak berlaku, minta kode baru.'),
        ),
      );
    }
  }, skip: skipReason);

  test('gabung: Ruang Bersama berisi dua anggota, daftar "Tugas", dan warna diri dibedakan', () async {
    await b.syncNow();
    final code = (await a.account.spaces.invitation()).code;

    // Server menyeragamkan input: huruf kecil, spasi, dan tanda hubung diterima.
    final typed = '${code.substring(0, 3).toLowerCase()} - ${code.substring(3).toLowerCase()}';
    final space = await b.account.spaces.accept(typed);
    expect(space.isShared, isTrue);
    expect(space.ownerId, a.user.id, reason: 'pemilik = pengundang');
    expect(space.members.map((member) => member.id), unorderedEquals([a.user.id, b.user.id]));

    // Sync biasa (bukan penuh) cukup untuk membawa isi ruang baru ke kedua HP.
    await a.syncNow();
    await b.syncNow();

    expect((await a.sharedSpace()).id, space.id);
    expect((await a.sharedList()).name, 'Tugas');
    expect((await b.sharedList()).id, (await a.sharedList()).id);

    // Keduanya mawar; yang bergabung diganti ke warna pertama yang belum dipakai.
    final members = {for (final member in (await a.sharedSpace()).members) member.id: member};
    expect(members[a.user.id]!.color, 'mawar');
    expect(members[b.user.id]!.color, 'ungu');
    expect((await b.account.profile.refresh()).color, 'ungu');

    // Setelah berpasangan, kode undangan tidak tersedia lagi.
    await expectLater(
      a.account.spaces.invitation(),
      throwsA(isA<ApiError>().having((error) => error.code, 'code', ApiErrorCode.sharedSpaceExists)),
    );
    // Memakai kode yang sama lagi membalas ruang yang sama.
    expect((await b.account.spaces.accept(code)).id, space.id);
  }, skip: skipReason);

  test('isi Ruang Pribadi tidak pernah sampai ke pasangan', () async {
    final personalTitles = (await a.tasks()).map((task) => task.title);
    expect(personalTitles, contains('Kirim laporan bulanan'));

    expect((await b.tasks()).map((task) => task.title), isNot(contains('Kirim laporan bulanan')));
    expect((await b.spaces()).where((space) => space.isPersonal).single.ownerId, b.user.id);
  }, skip: skipReason);

  test('titip tugas ke pasangan, lalu pasangan menyelesaikannya', () async {
    final list = await a.sharedList();
    final task = await a.account.tasks.create(
      list: list,
      title: 'Beli galon',
      dueDate: '2026-10-09',
      assigneeIds: [b.user.id],
      important: true,
    );
    await a.syncNow();
    await b.syncNow();

    final received = (await b.tasks()).firstWhere((item) => item.id == task.id);
    expect(received.assigneeIds, [b.user.id]);
    expect(received.priority, 3);
    // Tanggal tanpa jam diingatkan pukul 08.00 WIB = 01.00 UTC.
    expect(received.remindAt, DateTime.utc(2026, 10, 9, 1));

    final opId = await b.account.tasks.complete(task.id);
    expect(opId, isNotNull);
    // Selama jeda Urungkan, belum ada yang sampai ke server.
    expect(await b.account.outbox.flush(), FlushState.waitingUndo);
    await a.syncNow();
    expect((await a.tasks()).firstWhere((item) => item.id == task.id).completedAt, isNull);

    await b.syncNow();
    await a.syncNow();

    final done = (await a.tasks()).firstWhere((item) => item.id == task.id);
    expect(done.completedAt, isNotNull);
    expect(done.completedBy, b.user.id, reason: 'server mengisi completed_by');

    // Batal selesai.
    await a.account.tasks.uncomplete(task.id);
    await a.syncNow();
    await b.syncNow();
    final reopened = (await b.tasks()).firstWhere((item) => item.id == task.id);
    expect(reopened.completedAt, isNull);
    expect(reopened.completedBy, isNull);
  }, skip: skipReason);

  test('kolom berbeda tidak saling menimpa; kolom yang sama: yang terakhir sampai menang', () async {
    final task = (await a.tasks()).firstWhere((item) => item.title == 'Beli galon');

    await a.account.tasks.rename(task.id, 'Beli galon 2 buah');
    await b.account.tasks.setNotes(task.id, 'Yang isi ulang saja');
    await a.syncNow();
    await b.syncNow();
    await a.syncNow();

    for (final device in [a, b]) {
      final merged = (await device.tasks()).firstWhere((item) => item.id == task.id);
      expect(merged.title, 'Beli galon 2 buah');
      expect(merged.notes, 'Yang isi ulang saja');
    }

    await a.account.tasks.rename(task.id, 'Versi A');
    await b.account.tasks.rename(task.id, 'Versi B');
    await a.account.outbox.flush();
    await b.syncNow();
    await a.syncNow();

    expect((await a.tasks()).firstWhere((item) => item.id == task.id).title, 'Versi B');
  }, skip: skipReason);

  test('tenggat: mengosongkan tanggal ikut mengosongkan jam dan pengingat', () async {
    final task = (await a.tasks()).firstWhere((item) => item.title == 'Versi B');

    await a.account.tasks.setDue(task.id, date: '2026-10-12', time: '19:30');
    await a.syncNow();
    var stored = (await a.tasks()).firstWhere((item) => item.id == task.id);
    expect(stored.dueTime, '19:30');
    expect(stored.remindAt, DateTime.utc(2026, 10, 12, 12, 30));

    await a.account.tasks.setDue(task.id, date: null, time: null);
    await a.syncNow();
    stored = (await a.tasks()).firstWhere((item) => item.id == task.id);
    expect(stored.dueDate, isNull);
    expect(stored.dueTime, isNull);
    expect(stored.remindAt, isNull);
  }, skip: skipReason);

  test('daftar aktif terakhir: 409 last_list, dan daftarnya pulih di HP', () async {
    final list = await a.sharedList();

    // Lewati pengecekan di HP, supaya jawaban server yang diuji.
    final before = await a.account.store.patch(EntityType.list, list.id, {
      'deleted_at': DateTime.now().toUtc().toIso8601String(),
    });
    await a.account.outbox.enqueueDelete(EntityType.list, list.id, before: before!);
    expect((await a.lists()).where((item) => item.id == list.id), isEmpty);

    final events = <OutboxEvent>[];
    final subscription = a.account.outbox.events.listen(events.add);
    expect(await a.account.outbox.flush(), FlushState.idle);
    await pumpEventQueue();
    await subscription.cancel();

    expect((events.single as OutboxRejected).message, 'Setiap ruang harus punya minimal satu daftar aktif.');
    expect((await a.lists()).where((item) => item.id == list.id), hasLength(1));
    expect((await a.account.db.select(a.account.db.outboxOps).get()), isEmpty);
  }, skip: skipReason);

  test('daftar dihapus pasangan: tugas yang masih di antrean dipindah ke daftar aktif pertama', () async {
    final space = await a.sharedSpace();
    final doomed = await a.account.lists.create(spaceId: space.id, name: 'Belanja', emoji: '🛒', color: 'toska');
    await a.syncNow();
    await b.syncNow();
    expect((await b.lists()).firstWhere((list) => list.id == doomed.id).emoji, '🛒');

    // B menambah tugas ke "Belanja" saat offline; sementara itu A menghapus daftarnya.
    final orphan = await b.account.tasks.create(list: doomed, title: 'Telur 1 kg');
    await a.account.lists.delete(doomed.id);
    await a.syncNow();

    final events = <OutboxEvent>[];
    final subscription = b.account.outbox.events.listen(events.add);
    expect(await b.account.outbox.flush(), FlushState.idle);
    await pumpEventQueue();
    await subscription.cancel();

    final survivor = await b.sharedList();
    final moved = Task.fromJson((await b.account.store.read(EntityType.task, orphan.id))!);
    expect(moved.taskListId, survivor.id);
    expect(moved.deletedAt, isNull);
    expect(events.whereType<OutboxTaskRelocated>().single.listName, survivor.name);

    await b.syncNow();
    await a.syncNow();
    expect((await a.tasks()).firstWhere((task) => task.id == orphan.id).taskListId, survivor.id);
    // Daftar yang dihapus hilang dari kedua HP.
    expect((await a.lists()).where((list) => list.id == doomed.id), isEmpty);
    expect((await b.lists()).where((list) => list.id == doomed.id), isEmpty);
  }, skip: skipReason);

  test(
    'tugas berulang: tugas berikutnya dari balasan centang, Urungkan menghapusnya, dan aturannya dicek server',
    () async {
      final list = await a.sharedList();
      // Tenggatnya di masa depan, jadi tugas berikutnya tepat seminggu sesudahnya.
      final task = await a.account.tasks.create(
        list: list,
        title: 'Buang sampah',
        dueDate: '2027-01-04',
        repeat: const TaskRepeat(RepeatFrequency.weekly),
      );
      await a.syncNow();

      await a.account.tasks.complete(task.id);
      await a.syncNow();
      final done = Task.fromJson((await a.account.store.read(EntityType.task, task.id))!);
      final nextId = done.nextTaskId!;
      final next = Task.fromJson((await a.account.store.read(EntityType.task, nextId))!);
      expect(
        (next.title, next.dueDate, next.isCompleted, next.createdBy),
        ('Buang sampah', '2027-01-11', false, a.user.id),
      );
      expect(next.repeat, const TaskRepeat(RepeatFrequency.weekly));

      await b.syncNow();
      expect(Task.fromJson((await b.account.store.read(EntityType.task, nextId))!).dueDate, '2027-01-11');

      // Urungkan setelah terkirim: tugas berikutnya yang belum disentuh ikut dihapus server.
      await a.account.tasks.uncomplete(task.id);
      await a.syncNow();
      expect(Task.fromJson((await a.account.store.read(EntityType.task, task.id))!).nextTaskId, isNull);
      expect((await a.account.store.tasks()).where((row) => row.id == nextId && row.deletedAt == null), isEmpty);
      await b.syncNow();
      expect((await b.account.store.read(EntityType.task, nextId))!['deleted_at'], isNotNull);

      // Centang ulang membuat tugas berikutnya yang baru.
      await a.account.tasks.complete(task.id);
      await a.syncNow();
      final againId = Task.fromJson((await a.account.store.read(EntityType.task, task.id))!).nextTaskId!;
      expect(againId, isNot(nextId));

      // Tanpa tanggal tidak bisa berulang; menghapus tenggat ikut mengosongkan aturan ulangnya.
      await expectLater(
        a.api.send('PATCH', '/tasks/$againId', body: {'due_date': null, 'repeat_frequency': 'daily'}),
        throwsA(isA<ApiError>().having((error) => error.code, 'code', ApiErrorCode.validationFailed)),
      );
      await a.account.tasks.setDue(againId, date: null, time: null);
      await a.syncNow();
      final cleared = Task.fromJson((await a.account.store.read(EntityType.task, againId))!);
      expect((cleared.dueDate, cleared.repeatFrequency, cleared.repeatInterval), (null, null, null));
    },
    skip: skipReason,
  );

  test('arsip: tugas ke daftar arsip ditolak parent_archived dan dipindah', () async {
    final space = await a.sharedSpace();
    final archive = await a.account.lists.create(spaceId: space.id, name: 'Lama');
    await a.syncNow();
    await b.syncNow();

    final task = await b.account.tasks.create(list: archive, title: 'Servis AC');
    await a.account.lists.archive(archive.id);
    await a.syncNow();

    expect(await b.account.outbox.flush(), FlushState.idle);
    expect(
      Task.fromJson((await b.account.store.read(EntityType.task, task.id))!).taskListId,
      (await b.sharedList()).id,
    );

    await b.syncNow();
    expect((await b.lists()).firstWhere((list) => list.id == archive.id).archivedAt, isNotNull);
  }, skip: skipReason);

  test('tugas dihapus pasangan: perubahan yang masih di antrean dibuang (410) dan tugasnya hilang', () async {
    final list = await a.sharedList();
    final task = await a.account.tasks.create(list: list, title: 'Bayar listrik');
    await a.syncNow();
    await b.syncNow();

    await a.account.tasks.delete(task.id);
    await a.syncNow();

    await b.account.tasks.rename(task.id, 'Bayar listrik dan air');
    expect(await b.account.outbox.flush(), FlushState.idle);

    expect(await b.account.store.read(EntityType.task, task.id), isNull);
    expect((await b.account.db.select(b.account.db.outboxOps).get()), isEmpty);
  }, skip: skipReason);

  test(
    'perjalanan: checklist ikut dibuat dan tidak bisa dihapus sendiri; tautan dana lepas saat targetnya dihapus',
    () async {
      final space = await a.sharedSpace();
      final goal = await a.account.savings.createGoal(
        spaceId: space.id,
        name: 'Dana Bali',
        targetAmount: 5000000,
        currency: 'IDR',
      );
      final trip = await a.account.trips.create(
        spaceId: space.id,
        title: 'Liburan ke Bali',
        destination: 'Bali',
        startDate: '2027-06-20',
        endDate: '2027-06-25',
        savingsGoalId: goal.id,
      );
      final checklist = (await a.account.store.checklistsOf(trip.id)).single;
      await a.account.tasks.create(list: checklist, title: 'Beli sunscreen');
      await a.syncNow();
      await b.syncNow();

      // B menerima perjalanan, checklist, dan itemnya.
      final received = (await b.account.store.checklistsOf(trip.id)).single;
      expect(received.id, checklist.id);
      expect(received.name, 'Persiapan Liburan ke Bali');
      expect((await b.tasks()).singleWhere((task) => task.taskListId == checklist.id).title, 'Beli sunscreen');
      expect(Trip.fromJson((await b.account.store.read(EntityType.trip, trip.id))!).savingsGoalId, goal.id);

      // Menghapus checklist sendiri (melewati pengecekan di HP) ditolak 409 trip_checklist, dan checklistnya pulih.
      final before = await a.account.store.patch(EntityType.list, checklist.id, {
        'deleted_at': DateTime.now().toUtc().toIso8601String(),
      });
      await a.account.outbox.enqueueDelete(EntityType.list, checklist.id, before: before!);
      final events = <OutboxEvent>[];
      final subscription = a.account.outbox.events.listen(events.add);
      expect(await a.account.outbox.flush(), FlushState.idle);
      await pumpEventQueue();
      await subscription.cancel();
      expect(
        (events.single as OutboxRejected).message,
        'Checklist ini ikut perjalanannya. Hapus perjalanannya kalau ingin menghapus checklist.',
      );
      expect((await a.account.store.checklistsOf(trip.id)).single.id, checklist.id);

      // Target dihapus: server mengosongkan tautan perjalanannya, dan itu sampai lewat sync.
      await a.account.savings.deleteGoal(goal.id);
      await a.syncNow();
      expect(Trip.fromJson((await a.account.store.read(EntityType.trip, trip.id))!).savingsGoalId, isNull);

      // A menghapus perjalanan saat B masih mencatat item offline: itemnya dipindah ke daftar biasa.
      final late = await b.account.tasks.create(list: received, title: 'Tukar uang');
      await a.account.trips.delete(trip.id);
      await a.syncNow();
      expect(await b.account.outbox.flush(), FlushState.idle);
      final moved = Task.fromJson((await b.account.store.read(EntityType.task, late.id))!);
      expect(moved.taskListId, (await b.sharedList()).id);

      await b.syncNow();
      expect(await b.account.store.checklistsOf(trip.id), isEmpty);
      expect((await b.account.store.read(EntityType.trip, trip.id))!['deleted_at'], isNotNull);
    },
    skip: skipReason,
  );

  test(
    'pengingat setor: jadwal disimpan server dan sampai ke HP pasangan; frekuensi kosong ikut mengosongkan harinya',
    () async {
      final space = await a.sharedSpace();
      final goal = await a.account.savings.createGoal(
        spaceId: space.id,
        name: 'Dana Darurat',
        targetAmount: 3000000,
        currency: 'IDR',
      );
      await a.account.savings.setReminder(
        goal.id,
        const SavingsReminder(frequency: ReminderFrequency.monthly, day: 31),
      );
      await a.syncNow();
      await b.syncNow();
      expect(
        SavingsGoal.fromJson((await b.account.store.read(EntityType.goal, goal.id))!).reminder,
        const SavingsReminder(frequency: ReminderFrequency.monthly, day: 31),
      );

      await b.account.savings.setReminder(goal.id, null);
      await b.syncNow();
      await a.syncNow();
      final cleared = SavingsGoal.fromJson((await a.account.store.read(EntityType.goal, goal.id))!);
      expect((cleared.reminderFrequency, cleared.reminderDay), (null, null));

      await a.account.savings.deleteGoal(goal.id);
      await a.syncNow();
    },
    skip: skipReason,
  );

  test(
    'kenangan: dari perjalanan sampai ke pasangan; hapus perjalanan melepas tautan; foto ke kenangan terhapus ditolak',
    () async {
      final space = await a.sharedSpace();
      final trip = await a.account.trips.create(
        spaceId: space.id,
        title: 'Pangandaran',
        destination: 'Pangandaran',
        startDate: '2026-08-01',
        endDate: '2026-08-03',
      );
      final memory = await a.account.memories.create(
        spaceId: space.id,
        title: 'Pangandaran',
        placeName: 'Pangandaran',
        visitedOn: '2026-08-01',
        story: 'Ombaknya besar.',
        tripId: trip.id,
      );
      await a.syncNow();
      await b.syncNow();

      final received = Memory.fromJson((await b.account.store.read(EntityType.memory, memory.id))!);
      expect((received.title, received.tripId, received.createdBy), ('Pangandaran', trip.id, a.user.id));

      // Pasangan boleh mengubah kenangan siapa pun.
      await b.account.memories.edit(
        memory.id,
        title: 'Pangandaran',
        placeName: 'Pantai Batu Karas',
        visitedOn: '2026-08-01',
        story: 'Ombaknya besar, airnya hangat.',
      );
      await b.syncNow();
      await a.syncNow();
      final edited = Memory.fromJson((await a.account.store.read(EntityType.memory, memory.id))!);
      expect((edited.placeName, edited.story), ('Pantai Batu Karas', 'Ombaknya besar, airnya hangat.'));

      // Kenangan tanpa foto: URL baru berupa daftar kosong.
      expect(await a.account.memories.refreshPhotos(memory.id), isEmpty);

      // Hapus perjalanan: kenangannya tetap ada, tautannya dilepas lewat sync.
      await a.account.trips.delete(trip.id);
      await a.syncNow();
      await b.syncNow();
      final unlinked = Memory.fromJson((await b.account.store.read(EntityType.memory, memory.id))!);
      expect((unlinked.tripId, unlinked.deletedAt), (null, null));

      // B menghapus kenangan saat A menambah foto offline: unggahannya ditolak parent_deleted dan dibuang.
      await b.account.memories.delete(memory.id);
      await b.syncNow();
      final added = await a.account.memories.addPhotos(edited, [
        PreparedPhoto(jpeg: tinyJpeg, width: 2, height: 2, takenAt: '2026-08-01T10:12:45+07:00'),
      ]);
      expect(added, 1);
      final photo = (await a.account.store.memoryPhotos(memory.id)).single;

      final events = <OutboxEvent>[];
      final subscription = a.account.outbox.events.listen(events.add);
      expect(await a.account.outbox.flush(), FlushState.idle);
      await pumpEventQueue();
      await subscription.cancel();
      expect((events.single as OutboxRejected).message, 'Kenangan ini sudah dihapus.');
      expect(await a.account.store.read(EntityType.memoryPhoto, photo.id), isNull);
      expect(await a.account.photoFiles.pending(photo.id), isNull);

      await a.syncNow();
      expect((await a.account.store.read(EntityType.memory, memory.id))!['deleted_at'], isNotNull);
      expect(await a.account.memories.refreshPhotos(memory.id), isEmpty, reason: '410 untuk kenangan terhapus');
    },
    skip: skipReason,
  );

  test('tabungan: setoran dari dua HP, target tercapai diisi server, hapus target berantai', () async {
    final space = await a.sharedSpace();
    final goal = await a.account.savings.createGoal(
      spaceId: space.id,
      name: 'Dana Liburan',
      emoji: '✈️',
      targetAmount: 1000000,
      currency: 'IDR',
      targetDate: '2027-06-30',
    );
    await a.account.savings.createEntry(goal: goal, amount: 400000, entryDate: '2026-10-08', note: 'Gajian');
    await a.syncNow();
    await b.syncNow();

    final received = SavingsGoal.fromJson((await b.account.store.read(EntityType.goal, goal.id))!);
    expect(received.emoji, '✈️');
    expect(received.achievedAt, isNull);

    final fromPartner = await b.account.savings.createEntry(goal: received, amount: 600000, entryDate: '2026-10-09');
    await b.syncNow();
    await a.syncNow();

    // user_id diisi server dengan akun yang mencatat.
    final entry = (await a.account.store.read(EntityType.entry, fromPartner.id))!;
    expect(entry['user_id'], b.user.id);
    expect(entry['type'], 'deposit');
    // Total 1.000.000 mencapai target.
    expect(SavingsGoal.fromJson((await a.account.store.read(EntityType.goal, goal.id))!).achievedAt, isNotNull);

    // Total turun lagi di bawah target: achieved_at kembali kosong.
    await a.account.savings.editEntry(fromPartner.id, amount: 100000, entryDate: '2026-10-09', note: null);
    await a.syncNow();
    expect(SavingsGoal.fromJson((await a.account.store.read(EntityType.goal, goal.id))!).achievedAt, isNull);

    // Setoran ke target yang sudah dihapus: 409 parent_deleted, dibuang dan diberi tahu.
    await a.account.savings.deleteGoal(goal.id);
    await a.syncNow();
    final tooLate = await b.account.savings.createEntry(goal: received, amount: 50000, entryDate: '2026-10-10');
    final events = <OutboxEvent>[];
    final subscription = b.account.outbox.events.listen(events.add);
    expect(await b.account.outbox.flush(), FlushState.idle);
    await pumpEventQueue();
    await subscription.cancel();

    expect((events.single as OutboxRejected).message, 'Target ini sudah dihapus.');
    expect(await b.account.store.read(EntityType.entry, tooLate.id), isNull);

    // Penghapusan target ikut menghapus setorannya di HP pasangan.
    await b.syncNow();
    final goalRow = await b.account.store.read(EntityType.goal, goal.id);
    expect(goalRow!['deleted_at'], isNotNull);
    expect((await b.account.store.read(EntityType.entry, fromPartner.id))!['deleted_at'], isNotNull);
  }, skip: skipReason);

  test('PATCH /me lewat antrean: nama, tanggal lahir, preferensi; pasangan melihat nama baru lewat sync', () async {
    await a.account.profile.update(name: 'Iqbal', birthDate: '--03-02', defaultCurrency: 'USD');
    await a.account.profile.updateNotificationPrefs(
      const NotificationPrefs(taskReminders: true, partnerActivity: false, savingsActivity: true),
    );
    await a.syncNow();

    final me = await a.account.profile.refresh();
    expect(me.name, 'Iqbal');
    expect(me.birthDate, '--03-02');
    expect(me.defaultCurrency, 'USD');
    expect(me.notificationPrefs.partnerActivity, isFalse);
    expect(me.notificationPrefs.taskReminders, isTrue);

    await b.syncNow();
    final seen = (await b.sharedSpace()).members.firstWhere((member) => member.id == a.user.id);
    expect(seen.name, 'Iqbal');
  }, skip: skipReason);

  test('GET /spaces membalas semua ruang beserta anggotanya', () async {
    await a.account.spaces.refresh();
    final spaces = await a.spaces();
    expect(spaces, hasLength(2));
    expect(spaces.first.isShared, isTrue, reason: 'Ruang Bersama ditaruh lebih dulu');
    expect(spaces.first.members, hasLength(2));
  }, skip: skipReason);

  test('perangkat: token FCM didaftarkan dan dihapus', () async {
    const fcm = 'token-fcm-e2e-palsu';
    expect((await a.api.send('POST', '/devices', body: {'token': fcm, 'platform': 'android'})).status, 201);
    expect((await a.api.send('POST', '/devices', body: {'token': fcm, 'platform': 'android'})).status, 200);
    expect((await a.api.send('DELETE', '/devices/$fcm')).status, 204);
  }, skip: skipReason);

  test('endpoint tak dikenal dibalas route_not_found, bukan not_found', () async {
    await expectLater(
      a.api.send('GET', '/tidak-ada'),
      throwsA(isA<ApiError>().having((error) => error.code, 'code', ApiErrorCode.routeNotFound)),
    );
  }, skip: skipReason);

  test('masuk di HP lain: sync penuh membawa semua data; keluar membuat token tidak berlaku (401)', () async {
    final other = Device(baseUrl!);
    await other.signIn(
      await AuthRepository(other.api).login(email: a.user.email, password: 'rahasia-banget', deviceName: 'HP kedua'),
    );
    await other.syncNow();

    expect(await other.spaces(), hasLength(2));
    expect((await other.tasks()).map((task) => task.title), containsAll(['Kirim laporan bulanan', 'Versi B']));
    // Sync penuh tidak membawa yang sudah terhapus.
    expect((await other.tasks()).map((task) => task.title), isNot(contains('Bayar listrik')));

    await AuthRepository(other.api).logout(fcmToken: 'token-fcm-e2e-palsu');
    expect(other.unauthenticated, 0);

    // Antrean berhenti dan isinya tetap tersimpan; sesi dianggap berakhir.
    final list = (await other.lists()).first;
    await other.account.tasks.create(list: list, title: 'Tidak terkirim');
    expect(await other.account.outbox.flush(), FlushState.stopped);
    expect(other.unauthenticated, 1);
    expect(await other.account.outbox.pendingCount(), 1);

    await other.close();
  }, skip: skipReason);

  test('keluar dari Ruang Bersama: ditutup untuk berdua, lalu pulih utuh saat bergabung lagi', () async {
    await a.syncNow();
    await b.syncNow();
    final shared = await a.sharedSpace();
    Future<Set<String>> sharedTitles(Device device) async => {
      for (final task in await device.tasks())
        if (task.spaceId == shared.id) task.title,
    };
    final before = await sharedTitles(a);
    expect(before, isNotEmpty);
    expect(await sharedTitles(b), before);

    // Perubahan B yang belum terkirim saat ruang ditutup.
    final pending = (await b.tasks()).firstWhere((task) => task.spaceId == shared.id);
    await b.account.tasks.rename(pending.id, 'Tidak sempat terkirim');

    await a.account.spaces.leave(shared.id);
    expect((await a.spaces()).map((space) => space.id), isNot(contains(shared.id)));
    expect(await sharedTitles(a), isEmpty);
    expect(
      (await a.tasks()).map((task) => task.title),
      contains('Kirim laporan bulanan'),
      reason: 'Ruang Pribadi tetap',
    );
    // Diulang tetap 204; GET /spaces tidak lagi menampilkannya.
    await a.account.spaces.leave(shared.id);
    final listed = (await a.api.send('GET', '/spaces')).dataList;
    expect(listed.map((space) => space['id']), isNot(contains(shared.id)));

    // B: perubahannya dibalas 404 lalu dibuang, dan sync membawa ruang yang tertutup tanpa isinya.
    await b.syncNow();
    expect(await b.account.outbox.pendingCount(), 0);
    expect((await b.spaces()).where((space) => space.isShared), isEmpty);
    expect(await sharedTitles(b), isEmpty);

    // Bergabung lagi lewat kode B: ruang lama pulih dengan id dan created_at aslinya.
    final code = (await b.account.spaces.invitation()).code;
    final restored = await a.account.spaces.accept(code);
    expect((restored.id, restored.createdAt), (shared.id, shared.createdAt));

    // Isinya kembali lewat sync biasa, karena server memperbarui updated_at-nya.
    await a.syncNow();
    await b.syncNow();
    expect(await sharedTitles(a), before);
    expect(await sharedTitles(b), before);
    expect((await b.sharedSpace()).id, shared.id);
  }, skip: skipReason);

  test('ekspor data: satu berkas JSON berbentuk sync penuh, termasuk isi Ruang Bersama dari pasangan', () async {
    final export = await a.account.exports.fetch();
    expect(export.fileName, matches(RegExp(r'^denly-days-\d{4}-\d{2}-\d{2}\.json$')));

    final file = jsonDecode(utf8.decode(export.bytes)) as Map<String, dynamic>;
    expect((file['app'], file['format_version']), ('Denly Days', 1));
    expect((file['user'] as Map<String, dynamic>)['id'], a.user.id);
    expect(file.keys, containsAll(['exported_at', 'devices', 'spaces', 'task_lists', 'tasks', 'memory_photos']));
    for (final device in file['devices'] as List<dynamic>) {
      expect((device as Map<String, dynamic>).keys.toSet(), {'platform', 'created_at', 'updated_at'});
    }
    expect(utf8.decode(export.bytes), isNot(contains('rahasia-banget')));

    final shared = await a.sharedSpace();
    expect([
      for (final space in file['spaces'] as List<dynamic>) (space as Map<String, dynamic>)['id'],
    ], contains(shared.id));
    final titles = {for (final task in file['tasks'] as List<dynamic>) (task as Map<String, dynamic>)['title']};
    expect(titles, contains('Kirim laporan bulanan'), reason: 'Ruang Pribadi');
    expect(
      titles,
      containsAll({
        for (final task in await b.tasks())
          if (task.spaceId == shared.id) task.title,
      }),
    );
    // Ruang Pribadi pasangan tidak ikut: hanya Ruang Pribadi milikku.
    expect(
      [
        for (final space in (file['spaces'] as List<dynamic>).cast<Map<String, dynamic>>())
          if (space['type'] == 'personal') space['owner_id'],
      ],
      [a.user.id],
    );
  }, skip: skipReason);

  test(
    'hapus akun: konfirmasi salah ditolak, lalu semua data hilang dan Ruang Bersama tertutup untuk pasangan',
    () async {
      final shared = await a.sharedSpace();
      final auth = AuthRepository(b.api);

      Future<void> rejected(Future<void> attempt, ApiErrorCode code) => expectLater(
        attempt,
        throwsA(isA<ApiError>().having((error) => error.code, 'code', code).having((e) => e.status, 'status', 422)),
      );
      await rejected(auth.deleteAccount(password: 'salah-total'), ApiErrorCode.invalidCredentials);
      await rejected(auth.deleteAccount(), ApiErrorCode.validationFailed);
      // Akun ini tidak tersambung ke Google, dan tokennya pun bukan dari Google.
      await rejected(auth.deleteAccount(idToken: 'bukan.token.google'), ApiErrorCode.googleTokenInvalid);
      expect(b.unauthenticated, 0);

      await auth.deleteAccount(password: 'rahasia-banget');

      // Balasan 204 yang hilang lalu dikirim ulang dibalas 401.
      await expectLater(
        auth.deleteAccount(password: 'rahasia-banget'),
        throwsA(isA<ApiError>().having((error) => error.code, 'code', ApiErrorCode.unauthenticated)),
      );

      // A: Ruang Bersama tiba tertutup, isinya hilang, Ruang Pribadi tetap.
      await a.syncNow();
      expect((await a.spaces()).map((space) => space.id), isNot(contains(shared.id)));
      expect((await a.tasks()).where((task) => task.spaceId == shared.id), isEmpty);
      expect((await a.tasks()).map((task) => task.title), contains('Kirim laporan bulanan'));

      // Email yang sama tidak bisa dipakai masuk lagi.
      await expectLater(
        AuthRepository(Device(baseUrl!).api).login(email: b.user.email, password: 'rahasia-banget', deviceName: 'Tes'),
        throwsA(isA<ApiError>().having((error) => error.code, 'code', ApiErrorCode.invalidCredentials)),
      );
    },
    skip: skipReason,
  );
}
