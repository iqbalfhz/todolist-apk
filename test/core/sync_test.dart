import 'package:flutter_test/flutter_test.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/database/local_store.dart';
import 'package:todolist/core/queue/outbox.dart';

import '../helpers/fake_api.dart';
import '../helpers/fixtures.dart';

void main() {
  late Harness h;

  setUp(() => h = Harness());
  tearDown(() => h.dispose());

  List<Map<String, dynamic>?> syncQueries() => [for (final request in h.api.sent('GET')) request.query];

  group('request', () {
    test('database kosong: sync penuh tanpa since, lalu server_time disimpan', () async {
      h.api.syncPages.add(
        h.api.syncPage(
          spaces: [sharedSpaceJson(), personalSpaceJson()],
          taskLists: [listJson()],
          tasks: [taskJson()],
          savingsGoals: [goalJson()],
          savingsEntries: [entryJson()],
          serverTime: '2026-10-08T11:10:05.123456Z',
        ),
      );

      expect(await h.account.sync.sync(), isTrue);

      expect(syncQueries(), [null]);
      expect(await h.account.store.meta(MetaKeys.syncSince), '2026-10-08T11:10:05.123456Z');
      expect(await h.account.store.spaces(), hasLength(2));
      expect((await h.local(EntityType.task, taskId))!['title'], 'Beli galon');
      expect((await h.local(EntityType.goal, goalId))!['target_amount'], 10000000);
      expect((await h.local(EntityType.entry, entryId))!['amount'], 200000);
    });

    test('sudah punya kursor: sync berikutnya memakai since yang tersimpan apa adanya', () async {
      h.api.syncPages.add(h.api.syncPage(serverTime: '2026-10-08T11:10:05.123456Z'));
      await h.account.sync.sync();
      h.api.syncPages.add(h.api.syncPage(serverTime: '2026-10-08T12:00:00.000001Z'));
      await h.account.sync.sync();

      expect(syncQueries(), [
        null,
        {'since': '2026-10-08T11:10:05.123456Z'},
      ]);
      expect(await h.account.store.meta(MetaKeys.syncSince), '2026-10-08T12:00:00.000001Z');
    });

    test(
      'halaman berikutnya memakai cursor sampai has_more false; server_time diambil dari halaman terakhir',
      () async {
        h.api.syncPages
          ..add(h.api.syncPage(taskLists: [listJson()], serverTime: 'T-server', nextCursor: 'kursor-1'))
          ..add(h.api.syncPage(tasks: [taskJson()], serverTime: 'T-server', nextCursor: 'kursor-2'))
          ..add(
            h.api.syncPage(
              tasks: [taskJson(id: '01m4dh1yn0t6cdn39q4f091896', title: 'Telur 1 kg')],
              serverTime: 'T-server',
            ),
          );

        expect(await h.account.sync.sync(), isTrue);

        expect(syncQueries(), [
          null,
          {'cursor': 'kursor-1'},
          {'cursor': 'kursor-2'},
        ]);
        expect(await h.account.store.meta(MetaKeys.syncSince), 'T-server');
        expect(await h.account.store.tasks(), hasLength(2));
      },
    );

    test('cursor ditolak 422: sync diulang dari since yang tersimpan', () async {
      await h.account.store.setMeta(MetaKeys.syncSince, 'T-lama');
      h.api.syncPages.add(h.api.syncPage(serverTime: 'T-1', nextCursor: 'rusak'));
      h.api
        ..enqueue(h.api.handle)
        ..enqueue((_) => throw apiError(422, ApiErrorCode.validationFailed))
        ..enqueue((_) => ApiResponse(status: 200, body: h.api.syncPage(serverTime: 'T-2')));

      expect(await h.account.sync.sync(), isTrue);

      expect(syncQueries(), [
        {'since': 'T-lama'},
        {'cursor': 'rusak'},
        {'since': 'T-lama'},
      ]);
      expect(await h.account.store.meta(MetaKeys.syncSince), 'T-2');
    });

    test('tanpa koneksi: sync gagal, kursor tidak berubah, dan dijadwalkan ulang', () async {
      await h.account.store.setMeta(MetaKeys.syncSince, 'T-lama');
      h.api.failNext(const NetworkFailure());

      expect(await h.account.sync.sync(), isFalse);

      expect(await h.account.store.meta(MetaKeys.syncSince), 'T-lama');
      expect(h.timers.pending!.delay, const Duration(seconds: 2));
    });

    test('hanya satu sync berjalan pada satu waktu; permintaan kedua dijalankan sesudahnya', () async {
      final first = h.account.sync.sync();
      final second = h.account.sync.sync();

      expect(identical(first, second), isTrue);
      await first;

      // Satu putaran untuk permintaan pertama, satu lagi untuk yang datang di tengah jalan.
      expect(h.api.sent('GET'), hasLength(2));
    });
  });

  group('antrean dan sync', () {
    test('operasi yang bisa dikirim dikirim dulu, baru data ditarik', () async {
      await h.seed(withTask: true);
      await h.account.tasks.rename(taskId, 'Beli galon besar');

      await h.account.sync.sync();

      expect(h.api.log, ['PATCH /tasks/$taskId', 'GET /sync']);
    });

    test('data tetap ditarik walau masih ada operasi yang menunggu Urungkan', () async {
      await h.seed(withTask: true);
      await h.account.tasks.complete(taskId);

      expect(await h.account.sync.sync(), isTrue);

      expect(h.api.log, ['GET /sync']);
      expect(await h.ops(), hasLength(1));
    });

    test('data tetap ditarik walau antrean sedang menunggu coba ulang', () async {
      await h.seed(withTask: true);
      await h.account.tasks.rename(taskId, 'Satu');
      h.api.failNext(const NetworkFailure());
      expect(await h.account.outbox.flush(), FlushState.waitingRetry);

      expect(await h.account.sync.sync(), isTrue);

      expect(h.api.log, ['PATCH /tasks/$taskId', 'GET /sync']);
      expect(await h.ops(), hasLength(1));
    });
  });

  group('menerapkan baris', () {
    test('tanpa pengecekan foreign key: tugas boleh tiba sebelum daftarnya', () async {
      h.api.syncPages
        ..add(h.api.syncPage(tasks: [taskJson()], nextCursor: 'kursor-1'))
        ..add(h.api.syncPage(taskLists: [listJson()]));

      expect(await h.account.sync.sync(), isTrue);

      expect(await h.local(EntityType.task, taskId), isNotNull);
      expect(await h.local(EntityType.list, listId), isNotNull);
    });

    test('kolom dengan operasi tertunda tidak ditimpa; kolom lain tetap diperbarui', () async {
      await h.seed(withTask: true);
      await h.account.tasks.rename(taskId, 'Judul lokal');
      h.api.failNext(const NetworkFailure());

      h.api.syncPages.add(
        h.api.syncPage(
          tasks: [taskJson(title: 'Judul pasangan', notes: 'Catatan pasangan', priority: 3, updatedAt: t1)],
        ),
      );
      await h.account.sync.sync();

      final task = (await h.local(EntityType.task, taskId))!;
      expect(task['title'], 'Judul lokal');
      expect(task['notes'], 'Catatan pasangan');
      expect(task['priority'], 3);
    });

    test('completed_by ikut dilindungi selama completed_at masih di antrean', () async {
      await h.seed(withTask: true);
      await h.account.tasks.complete(taskId);

      h.api.syncPages.add(
        h.api.syncPage(
          tasks: [taskJson(title: 'Judul pasangan', updatedAt: t1)],
        ),
      );
      await h.account.sync.sync();

      final task = (await h.local(EntityType.task, taskId))!;
      expect(task['completed_at'], isNotNull);
      expect(task['completed_by'], meId);
      expect(task['title'], 'Judul pasangan');
    });

    test('baris yang DELETE-nya masih di antrean tidak muncul lagi', () async {
      await h.seed(withTask: true);
      await h.account.tasks.delete(taskId);

      h.api.syncPages.add(
        h.api.syncPage(
          tasks: [taskJson(title: 'Diubah pasangan', updatedAt: t1)],
        ),
      );
      await h.account.sync.sync();

      final task = (await h.local(EntityType.task, taskId))!;
      expect(task['deleted_at'], isNotNull);
      expect(await h.account.store.tasks(), isEmpty);
    });

    test('baris yang lebih tua dari salinan lokal diabaikan; yang sama umurnya diterapkan', () async {
      await h.account.store.write(
        EntityType.task,
        taskJson(title: 'Baru', updatedAt: t2),
        serverUpdatedAt: t2,
      );

      h.api.syncPages.add(
        h.api.syncPage(
          tasks: [taskJson(title: 'Lama', updatedAt: t1)],
        ),
      );
      await h.account.sync.sync();
      expect((await h.local(EntityType.task, taskId))!['title'], 'Baru');

      h.api.syncPages.add(
        h.api.syncPage(
          tasks: [taskJson(title: 'Sama umur', updatedAt: t2)],
        ),
      );
      await h.account.sync.sync();
      expect((await h.local(EntityType.task, taskId))!['title'], 'Sama umur');
    });

    test('mikrodetik ikut dibandingkan saat menentukan baris yang lebih tua', () async {
      await h.account.store.write(
        EntityType.task,
        taskJson(title: 'Baru', updatedAt: '2026-10-08T10:15:30.000002Z'),
        serverUpdatedAt: '2026-10-08T10:15:30.000002Z',
      );

      h.api.syncPages.add(
        h.api.syncPage(
          tasks: [taskJson(title: 'Lama', updatedAt: '2026-10-08T10:15:30.000001Z')],
        ),
      );
      await h.account.sync.sync();

      expect((await h.local(EntityType.task, taskId))!['title'], 'Baru');
    });

    test('baris terhapus dari server menghilang dari tampilan', () async {
      await h.seed(withTask: true);

      h.api.syncPages.add(
        h.api.syncPage(
          tasks: [taskJson(deletedAt: t1, updatedAt: t1)],
        ),
      );
      await h.account.sync.sync();

      expect(await h.account.store.tasks(), isEmpty);
    });

    test('induk tiba terhapus: anaknya ikut terhapus, kecuali yang masih punya operasi di antrean', () async {
      await h.seed(withTask: true);
      const pendingTaskId = '01m4dh1yn0t6cdn39q4f091897';
      await h.account.store.write(
        EntityType.task,
        taskJson(id: pendingTaskId, title: 'Telur 1 kg'),
        serverUpdatedAt: t0,
      );
      await h.account.tasks.rename(pendingTaskId, 'Telur 2 kg');
      h.api.failNext(const NetworkFailure());

      h.api.syncPages.add(
        h.api.syncPage(
          taskLists: [listJson(deletedAt: t1, updatedAt: t1)],
        ),
      );
      await h.account.sync.sync();

      expect((await h.local(EntityType.list, listId))!['deleted_at'], isNotNull);
      expect((await h.local(EntityType.task, taskId))!['deleted_at'], isNotNull);
      expect((await h.local(EntityType.task, pendingTaskId))!['deleted_at'], isNull);
    });

    test('target tiba terhapus: setorannya ikut terhapus', () async {
      await h.seed(withGoal: true);
      await h.account.store.write(EntityType.entry, entryJson(), serverUpdatedAt: t0);

      h.api.syncPages.add(
        h.api.syncPage(
          savingsGoals: [goalJson(deletedAt: t1, updatedAt: t1)],
        ),
      );
      await h.account.sync.sync();

      expect((await h.local(EntityType.entry, entryId))!['deleted_at'], isNotNull);
    });

    test('sync penuh hanya menambah dan memperbarui', () async {
      await h.account.store.write(EntityType.task, taskJson(), serverUpdatedAt: t0);

      // Sync penuh tidak menyebut tugas itu, dan tugasnya tetap ada.
      h.api.syncPages.add(h.api.syncPage(taskLists: [listJson()]));
      await h.account.sync.sync();

      expect(syncQueries(), [null]);
      expect(await h.local(EntityType.task, taskId), isNotNull);
    });
  });
}
