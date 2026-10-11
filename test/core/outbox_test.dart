import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/queue/outbox.dart';
import 'package:todolist/features/tasks/domain/task_list.dart';

import '../helpers/fake_api.dart';
import '../helpers/fixtures.dart';

void main() {
  late Harness h;

  setUp(() => h = Harness());
  tearDown(() => h.dispose());

  TaskList sharedList() => TaskList.fromJson(listJson());

  Map<String, dynamic> payloadOf(dynamic op) => jsonDecode(op.payload as String) as Map<String, dynamic>;

  group('urutan kirim', () {
    test('operasi dikirim berurutan sesuai urutan masuk', () async {
      await h.seed();
      final list = await h.account.lists.create(spaceId: sharedSpaceId, name: 'Rumah');
      final task = await h.account.tasks.create(list: list, title: 'Bayar listrik');
      await h.account.tasks.delete(task.id);
      h.clock.advance(Outbox.undoWindow);

      expect(await h.account.outbox.flush(), FlushState.idle);

      expect(h.api.log, ['PUT /lists/${list.id}', 'PUT /tasks/${task.id}', 'DELETE /tasks/${task.id}']);
      expect(await h.ops(), isEmpty);
    });

    test('operasi ditandai "pernah dikirim" sebelum dikirim', () async {
      await h.seed();
      final task = await h.account.tasks.create(list: sharedList(), title: 'Beli galon');

      bool? attemptedWhileSending;
      h.api.enqueue((request) async {
        attemptedWhileSending = (await h.ops()).single.attempted;
        return h.api.handle(request);
      });

      expect((await h.ops()).single.attempted, isFalse);
      await h.account.outbox.flush();

      expect(attemptedWhileSending, isTrue);
      expect(h.api.row('tasks', task.id), isNotNull);
    });

    test('satu flush pada satu waktu: panggilan kedua menumpang yang sedang berjalan', () async {
      await h.seed();
      await h.account.tasks.create(list: sharedList(), title: 'Beli galon');

      final first = h.account.outbox.flush();
      final second = h.account.outbox.flush();
      await Future.wait([first, second]);

      expect(h.api.sent('PUT'), hasLength(1));
    });
  });

  group('aturan gabung', () {
    test('perubahan digabung ke PATCH paling akhir yang belum dikirim, dan nilai awal dipertahankan', () async {
      await h.seed(withTask: true);

      await h.account.tasks.rename(taskId, 'Beli galon 2');
      await h.account.tasks.rename(taskId, 'Beli galon 3');
      await h.account.tasks.setImportant(taskId, true);

      final op = (await h.ops()).single;
      expect(op.method, 'PATCH');
      expect(payloadOf(op), {'title': 'Beli galon 3', 'priority': 3});
      expect(jsonDecode(op.before!), {'title': 'Beli galon', 'priority': 0});
    });

    test('perubahan digabung ke PUT yang belum dikirim', () async {
      await h.seed();
      final task = await h.account.tasks.create(list: sharedList(), title: 'Beli galon');
      await h.account.tasks.setDue(task.id, date: '2026-10-09', time: '17:00');

      final op = (await h.ops()).single;
      expect(op.method, 'PUT');
      expect(payloadOf(op), containsPair('due_date', '2026-10-09'));
      expect(payloadOf(op), containsPair('due_time', '17:00'));

      await h.account.outbox.flush();
      expect(h.api.log, ['PUT /tasks/${task.id}']);
      expect(h.api.row('tasks', task.id), containsPair('due_time', '17:00'));
    });

    test('tidak digabung kalau operasi paling akhir milik data lain', () async {
      await h.seed(withTask: true);
      await h.account.tasks.rename(taskId, 'Satu');
      await h.account.lists.edit(listId, name: 'Belanja mingguan', emoji: null, color: 'toska');
      await h.account.tasks.rename(taskId, 'Dua');

      final ops = await h.ops();
      expect([for (final op in ops) '${op.entityType}:${op.method}'], ['task:PATCH', 'list:PATCH', 'task:PATCH']);
      expect(payloadOf(ops.first), {'title': 'Satu'});
      expect(payloadOf(ops.last), {'title': 'Dua'});
      expect(jsonDecode(ops.last.before!), {'title': 'Satu'});
    });

    test('tidak digabung ke operasi yang pernah dikirim', () async {
      await h.seed(withTask: true);
      await h.account.tasks.rename(taskId, 'Satu');

      h.api.failNext(const NetworkFailure());
      expect(await h.account.outbox.flush(), FlushState.waitingRetry);
      expect((await h.ops()).single.attempted, isTrue);

      await h.account.tasks.rename(taskId, 'Dua');

      final ops = await h.ops();
      expect(ops, hasLength(2));
      expect(payloadOf(ops.first), {'title': 'Satu'});
      expect(payloadOf(ops.last), {'title': 'Dua'});
    });

    test('tidak digabung ke operasi yang sedang menunggu Urungkan', () async {
      await h.seed(withTask: true);
      await h.account.tasks.complete(taskId);
      await h.account.tasks.rename(taskId, 'Beli galon besar');

      final ops = await h.ops();
      expect(ops, hasLength(2));
      expect(payloadOf(ops.first).keys, ['completed_at']);
      expect(payloadOf(ops.last), {'title': 'Beli galon besar'});
    });

    test('selesai selalu menjadi operasi tersendiri, tidak digabung ke perubahan sebelumnya', () async {
      await h.seed(withTask: true);
      await h.account.tasks.rename(taskId, 'Beli galon besar');
      await h.account.tasks.complete(taskId);

      expect(await h.ops(), hasLength(2));
    });

    test('hanya kolom yang berubah yang dikirim', () async {
      await h.seed(withGoal: true);
      await h.account.savings.editGoal(
        goalId,
        name: 'Dana Liburan',
        emoji: null,
        targetAmount: 12000000,
        targetDate: '2027-02-28',
      );

      expect(payloadOf((await h.ops()).single), {'target_amount': 12000000});
    });

    test('tidak ada operasi kalau nilainya tidak berubah', () async {
      await h.seed(withTask: true);
      await h.account.tasks.rename(taskId, 'Beli galon');
      await h.account.tasks.setImportant(taskId, false);

      expect(await h.ops(), isEmpty);
    });

    test('tanggal dan jam tenggat selalu dikirim bersama', () async {
      await h.seed(withTask: true);
      await h.account.tasks.setDue(taskId, date: '2026-10-09', time: null);
      await h.account.outbox.flush();
      await h.account.tasks.setDue(taskId, date: '2026-10-09', time: '17:00');

      expect(payloadOf((await h.ops()).single), {'due_date': '2026-10-09', 'due_time': '17:00'});
    });
  });

  group('jeda Urungkan', () {
    test('selesai tidak dikirim selama 5 detik, lalu dikirim', () async {
      await h.seed(withTask: true);
      await h.account.tasks.complete(taskId);

      expect((await h.local(EntityType.task, taskId))!['completed_at'], isNotNull);
      expect((await h.local(EntityType.task, taskId))!['completed_by'], meId);

      expect(await h.account.outbox.flush(), FlushState.waitingUndo);
      expect(h.api.requests, isEmpty);
      expect(h.timers.pending!.delay, Outbox.undoWindow);

      h.clock.advance(const Duration(seconds: 4));
      expect(await h.account.outbox.flush(), FlushState.waitingUndo);
      expect(h.api.requests, isEmpty);

      h.clock.advance(const Duration(seconds: 1));
      expect(await h.account.outbox.flush(), FlushState.idle);
      expect(h.api.log, ['PATCH /tasks/$taskId']);
      expect(h.api.requests.single.body!.keys, ['completed_at']);
    });

    test('Urungkan menghapus operasi itu saja dan memulihkan tugas', () async {
      await h.seed(withTask: true);
      await h.account.tasks.rename(taskId, 'Beli galon besar');
      final opId = await h.account.tasks.complete(taskId);

      expect(await h.account.tasks.undo(opId!), isTrue);

      final task = (await h.local(EntityType.task, taskId))!;
      expect(task['completed_at'], isNull);
      expect(task['completed_by'], isNull);
      expect(task['title'], 'Beli galon besar');

      h.clock.advance(Outbox.undoWindow);
      await h.account.outbox.flush();
      expect(h.api.log, ['PATCH /tasks/$taskId']);
      expect(h.api.requests.single.body, {'title': 'Beli galon besar'});
    });

    test('Urungkan setelah operasi dikirim tidak berpengaruh', () async {
      await h.seed(withTask: true);
      final opId = await h.account.tasks.complete(taskId);
      h.clock.advance(Outbox.undoWindow);
      await h.account.outbox.flush();

      expect(await h.account.tasks.undo(opId!), isFalse);
      expect((await h.local(EntityType.task, taskId))!['completed_at'], isNotNull);
    });

    test('hapus tugas menunggu 5 detik dan bisa diurungkan', () async {
      await h.seed(withTask: true);
      final opId = await h.account.tasks.delete(taskId);

      expect((await h.local(EntityType.task, taskId))!['deleted_at'], isNotNull);
      expect(await h.account.outbox.flush(), FlushState.waitingUndo);
      expect(h.api.requests, isEmpty);

      expect(await h.account.tasks.undo(opId!), isTrue);
      expect((await h.local(EntityType.task, taskId))!['deleted_at'], isNull);
      expect(await h.ops(), isEmpty);
    });

    test('batal selesai dalam 5 detik sama dengan Urungkan: tidak ada yang dikirim', () async {
      await h.seed(withTask: true);
      await h.account.tasks.complete(taskId);
      await h.account.tasks.uncomplete(taskId);

      expect(await h.ops(), isEmpty);
      expect((await h.local(EntityType.task, taskId))!['completed_at'], isNull);

      h.clock.advance(Outbox.undoWindow);
      expect(await h.account.outbox.flush(), FlushState.idle);
      expect(h.api.requests, isEmpty);
    });

    test('operasi di belakang yang menunggu Urungkan ikut menunggu, supaya urutan terjaga', () async {
      await h.seed(withTask: true);
      await h.account.tasks.complete(taskId);
      await h.account.lists.edit(listId, name: 'Belanja mingguan', emoji: null, color: 'toska');

      expect(await h.account.outbox.flush(), FlushState.waitingUndo);
      expect(h.api.requests, isEmpty);

      h.clock.advance(Outbox.undoWindow);
      await h.account.outbox.flush();
      expect(h.api.log, ['PATCH /tasks/$taskId', 'PATCH /lists/$listId']);
    });
  });

  group('balasan berhasil', () {
    test('PUT dibalas 201: baris server diterapkan dan operasi selesai', () async {
      await h.seed();
      final task = await h.account.tasks.create(list: sharedList(), title: 'Beli galon');
      await h.account.outbox.flush();

      final local = (await h.local(EntityType.task, task.id))!;
      expect(local['updated_at'], h.api.row('tasks', task.id)!['updated_at']);
      expect(await h.account.store.serverUpdatedAt(EntityType.task, task.id), isNotNull);
      expect(await h.ops(), isEmpty);
    });

    test('PUT dibalas 200 (sudah ada): balasan diterapkan seperti baris sync, tanpa operasi tambahan', () async {
      await h.seed();
      final task = await h.account.tasks.create(list: sharedList(), title: 'Beli galon');
      // Kiriman sebelumnya sudah sampai, tapi balasannya hilang.
      h.api.seed('tasks', taskJson(id: task.id, title: 'Beli galon', updatedAt: t1));

      await h.account.outbox.flush();

      expect(h.api.log, ['PUT /tasks/${task.id}']);
      expect(await h.ops(), isEmpty);
      expect((await h.local(EntityType.task, task.id))!['title'], 'Beli galon');
    });

    test('balasan tidak menimpa kolom yang masih punya operasi di antrean', () async {
      await h.seed(withTask: true);
      await h.account.tasks.rename(taskId, 'Satu');
      h.api.failNext(const NetworkFailure());
      await h.account.outbox.flush();
      await h.account.tasks.rename(taskId, 'Dua');

      // Kirim operasi pertama saja: balasannya berjudul "Satu", tapi "Dua" masih di antrean.
      h.clock.advance(const Duration(seconds: 2));
      h.api.enqueue((request) async {
        final response = h.api.handle(request);
        h.api.failNext(const NetworkFailure());
        return response;
      });
      await h.account.outbox.flush();

      expect((await h.local(EntityType.task, taskId))!['title'], 'Dua');
      expect(await h.ops(), hasLength(1));
    });

    test('PATCH /me berhasil: profil lokal diperbarui', () async {
      await h.seed();
      await h.account.profile.update(name: 'Iqbal F', color: 'biru');
      expect((await h.local(EntityType.me, meId))!['name'], 'Iqbal F');

      await h.account.outbox.flush();

      expect(h.api.log, ['PATCH /me']);
      expect(h.api.requests.single.body, {'name': 'Iqbal F', 'color': 'biru'});
      expect(await h.ops(), isEmpty);
    });
  });

  group('penanganan error', () {
    test('401 unauthenticated: antrean berhenti dan isinya tetap tersimpan', () async {
      await h.seed(withTask: true);
      await h.account.tasks.rename(taskId, 'Satu');
      h.api.failNext(apiError(401, ApiErrorCode.unauthenticated));

      expect(await h.account.outbox.flush(), FlushState.stopped);
      expect(await h.ops(), hasLength(1));

      // Tidak dicoba lagi walau diminta.
      expect(await h.account.outbox.flush(), FlushState.stopped);
      expect(h.api.requests, hasLength(1));
    });

    test('403 forbidden: buang dari antrean, pakai current, tampilkan pesan', () async {
      await h.seed(withTask: true);
      final events = <OutboxEvent>[];
      h.account.outbox.events.listen(events.add);

      await h.account.tasks.rename(taskId, 'Tidak boleh');
      h.api.failNext(
        apiError(403, ApiErrorCode.forbidden, message: 'Kamu tidak boleh melakukan ini.', current: taskJson()),
      );

      expect(await h.account.outbox.flush(), FlushState.idle);
      await pumpEventQueue();

      expect(await h.ops(), isEmpty);
      expect((await h.local(EntityType.task, taskId))!['title'], 'Beli galon');
      expect((events.single as OutboxRejected).message, 'Kamu tidak boleh melakukan ini.');
    });

    test('404 not_found: buang dari antrean dan hapus data itu dari cache', () async {
      await h.seed(withTask: true);
      await h.account.tasks.rename(taskId, 'Hilang');
      h.api.failNext(apiError(404, ApiErrorCode.notFound, current: null));

      expect(await h.account.outbox.flush(), FlushState.idle);

      expect(await h.ops(), isEmpty);
      expect(await h.local(EntityType.task, taskId), isNull);
    });

    test('404 route_not_found: antrean disimpan, dicoba lagi nanti, dan app perlu diperbarui', () async {
      await h.seed(withTask: true);
      final events = <OutboxEvent>[];
      h.account.outbox.events.listen(events.add);

      await h.account.tasks.rename(taskId, 'Satu');
      h.api.failNext(apiError(404, ApiErrorCode.routeNotFound));

      expect(await h.account.outbox.flush(), FlushState.waitingRetry);
      await pumpEventQueue();

      expect(await h.ops(), hasLength(1));
      expect((await h.local(EntityType.task, taskId))!['title'], 'Satu');
      expect(events.single, isA<OutboxNeedsAppUpdate>());
    });

    test('409 parent_deleted untuk tugas: pindah ke daftar aktif pertama, lalu kirim ulang', () async {
      await h.seed();
      await h.account.store.write(
        EntityType.list,
        listJson(id: otherListId, name: 'Rumah', position: 512),
        serverUpdatedAt: t0,
      );
      h.api.rows['lists']![otherListId] = listJson(id: otherListId, name: 'Rumah', position: 512);
      final events = <OutboxEvent>[];
      h.account.outbox.events.listen(events.add);

      final task = await h.account.tasks.create(list: sharedList(), title: 'Beli galon');
      h.api.failNext(apiError(409, ApiErrorCode.parentDeleted, message: 'Daftar ini sudah dihapus.', current: null));

      expect(await h.account.outbox.flush(), FlushState.idle);
      await pumpEventQueue();

      expect(h.api.log, ['PUT /tasks/${task.id}', 'PUT /tasks/${task.id}']);
      expect(h.api.requests.last.body!['task_list_id'], otherListId);
      expect((await h.local(EntityType.task, task.id))!['task_list_id'], otherListId);
      expect(events.whereType<OutboxTaskRelocated>().single.listName, 'Rumah');
      expect(events.whereType<OutboxNeedsSync>(), isNotEmpty);
    });

    test('409 parent_archived saat pindah daftar: pindah ke daftar aktif lain, lalu kirim ulang', () async {
      await h.seed(withTask: true);
      const archivedId = '01m4dh0422zqexwxs1n4yw5jn4';
      await h.account.store.write(
        EntityType.list,
        listJson(id: archivedId, name: 'Lama', position: 4096),
        serverUpdatedAt: t0,
      );

      await h.account.tasks.moveToList(taskId, TaskList.fromJson(listJson(id: archivedId)));
      h.api.failNext(apiError(409, ApiErrorCode.parentArchived, current: taskJson()));

      expect(await h.account.outbox.flush(), FlushState.idle);

      expect(h.api.requests.last.body, {'task_list_id': listId});
      expect((await h.local(EntityType.task, taskId))!['task_list_id'], listId);
    });

    test('409 parent_deleted untuk tugas tanpa daftar aktif lain: tunggu, minta sync', () async {
      await h.seed();
      final events = <OutboxEvent>[];
      h.account.outbox.events.listen(events.add);

      await h.account.tasks.create(list: sharedList(), title: 'Beli galon');
      h.api.failNext(apiError(409, ApiErrorCode.parentDeleted, current: null));

      expect(await h.account.outbox.flush(), FlushState.waitingRetry);
      await pumpEventQueue();

      expect(await h.ops(), hasLength(1));
      expect(events.whereType<OutboxNeedsSync>(), isNotEmpty);
    });

    test('409 parent_deleted untuk setoran: buang dan beri tahu', () async {
      await h.seed(withGoal: true);
      final events = <OutboxEvent>[];
      h.account.outbox.events.listen(events.add);

      final goal = (await h.account.savings.watchGoals().first).single;
      final entry = await h.account.savings.createEntry(goal: goal, amount: 200000, entryDate: '2026-10-08');
      h.api.failNext(apiError(409, ApiErrorCode.parentDeleted, message: 'Target ini sudah dihapus.', current: null));

      expect(await h.account.outbox.flush(), FlushState.idle);
      await pumpEventQueue();

      expect(await h.ops(), isEmpty);
      expect(await h.local(EntityType.entry, entry.id), isNull);
      expect((events.single as OutboxRejected).message, 'Target ini sudah dihapus.');
    });

    test('409 last_list: DELETE daftar ditolak, daftar dan tugasnya pulih', () async {
      await h.seed(withTask: true);
      // Daftar kedua hanya ada di HP ini, jadi penghapusan lolos pengecekan lokal.
      await h.account.store.write(
        EntityType.list,
        listJson(id: otherListId, name: 'Rumah', position: 2048),
        serverUpdatedAt: t0,
      );

      await h.account.lists.delete(listId);
      expect((await h.local(EntityType.list, listId))!['deleted_at'], isNotNull);

      h.api.failNext(apiError(409, ApiErrorCode.lastList, current: listJson()));
      expect(await h.account.outbox.flush(), FlushState.idle);

      expect((await h.local(EntityType.list, listId))!['deleted_at'], isNull);
      expect((await h.local(EntityType.task, taskId))!['deleted_at'], isNull);
      expect(await h.ops(), isEmpty);
    });

    test('409 id_conflict: buang dari antrean; current null berarti hapus versi lokal', () async {
      await h.seed();
      final task = await h.account.tasks.create(list: sharedList(), title: 'Beli galon');
      h.api.failNext(apiError(409, ApiErrorCode.idConflict, current: null));

      expect(await h.account.outbox.flush(), FlushState.idle);

      expect(await h.ops(), isEmpty);
      expect(await h.local(EntityType.task, task.id), isNull);
    });

    test('410 resource_deleted: buang dari antrean dan hapus data itu dari cache', () async {
      await h.seed(withTask: true);
      await h.account.tasks.rename(taskId, 'Sudah dihapus pasangan');
      h.api.failNext(apiError(410, ApiErrorCode.resourceDeleted, current: taskJson(deletedAt: t1)));

      expect(await h.account.outbox.flush(), FlushState.idle);

      expect(await h.ops(), isEmpty);
      expect(await h.local(EntityType.task, taskId), isNull);
    });

    test('422 validation_failed: buang dari antrean dan pakai current', () async {
      await h.seed(withTask: true);
      await h.account.tasks.rename(taskId, 'Ditolak');
      h.api.failNext(
        apiError(
          422,
          ApiErrorCode.validationFailed,
          current: taskJson(title: 'Versi server', updatedAt: t1),
        ),
      );

      expect(await h.account.outbox.flush(), FlushState.idle);

      expect(await h.ops(), isEmpty);
      expect((await h.local(EntityType.task, taskId))!['title'], 'Versi server');
    });

    test('429 too_many_requests: tunggu sesuai Retry-After, lalu coba lagi', () async {
      await h.seed(withTask: true);
      await h.account.tasks.rename(taskId, 'Satu');
      h.api.failNext(apiError(429, ApiErrorCode.tooManyRequests, retryAfter: const Duration(seconds: 40)));

      expect(await h.account.outbox.flush(), FlushState.waitingRetry);
      expect(h.timers.pending!.delay, const Duration(seconds: 40));

      h.clock.advance(const Duration(seconds: 39));
      expect(await h.account.outbox.flush(), FlushState.waitingRetry);
      expect(h.api.requests, hasLength(1));

      h.clock.advance(const Duration(seconds: 1));
      expect(await h.account.outbox.flush(), FlushState.idle);
      expect(h.api.requests, hasLength(2));
    });

    test('tanpa koneksi, 5xx, atau bukan JSON: coba lagi dengan jeda 2, 4, 8 detik, maksimal 5 menit', () async {
      await h.seed(withTask: true);
      await h.account.tasks.rename(taskId, 'Satu');

      final delays = <int>[];
      for (var attempt = 0; attempt < 10; attempt++) {
        h.api.failNext(attempt.isEven ? const NetworkFailure() : const NetworkFailure(status: 502));
        expect(await h.account.outbox.flush(retryNow: true), FlushState.waitingRetry);
        delays.add(h.timers.pending!.delay.inSeconds);
      }

      expect(delays, [2, 4, 8, 16, 32, 64, 128, 256, 300, 300]);
      expect(await h.ops(), hasLength(1));
      expect((await h.local(EntityType.task, taskId))!['title'], 'Satu');
    });

    test('jeda coba ulang dihormati, dan kembali normal setelah berhasil', () async {
      await h.seed(withTask: true);
      await h.account.tasks.rename(taskId, 'Satu');
      h.api.failNext(const NetworkFailure());
      await h.account.outbox.flush();

      // Belum waktunya: tidak ada request baru.
      h.clock.advance(const Duration(seconds: 1));
      expect(await h.account.outbox.flush(), FlushState.waitingRetry);
      expect(h.api.requests, hasLength(1));

      h.clock.advance(const Duration(seconds: 1));
      expect(await h.account.outbox.flush(), FlushState.idle);

      await h.account.tasks.rename(taskId, 'Dua');
      h.api.failNext(const NetworkFailure());
      await h.account.outbox.flush();
      expect(h.timers.pending!.delay, const Duration(seconds: 2));
    });
  });
}
