import 'package:flutter_test/flutter_test.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/database/local_store.dart';
import 'package:todolist/core/sync/sync_engine.dart';

import 'helpers/fake_api.dart';
import 'helpers/fixtures.dart';

/// Penghapusan permanen catatan lama (v1.0): `GET /sync` dibalas 410 `sync_expired`.
void main() {
  const otherTask = '01m4dh1yn1t6cdn39q4f091896';
  const goneMemory = '01m4dr8c59jk2mt7xw3pq9vb6f';

  test('cache dikosongkan kecuali yang masih di antrean, since dilupakan, lalu sync penuh', () async {
    final h = Harness();
    addTearDown(h.dispose);
    await h.seed(withTask: true, withGoal: true);
    final store = h.account.store;
    await store.write(
      EntityType.task,
      taskJson(id: otherTask, title: 'Sudah dihapus pasangan'),
      serverUpdatedAt: t0,
    );
    await store.write(EntityType.memory, memoryJson(id: goneMemory), serverUpdatedAt: t0);
    await store.setMeta(MetaKeys.syncSince, '2026-09-01T00:00:00.000000Z');
    await store.setMeta(MetaKeys.syncCollections, '${SyncEngine.collectionsVersion}');

    // Perubahan yang belum terkirim: tugasnya tetap di HP sampai server membalasnya.
    h.api.offline = true;
    await h.account.tasks.rename(taskId, 'Belum terkirim');
    h.api.offline = false;
    h.api.enqueue((_) => throw const NetworkFailure());

    h.api.enqueue((_) => throw apiError(410, ApiErrorCode.syncExpired, message: 'Sync terlalu lama.'));
    h.api.syncPages.add(
      h.api.syncPage(
        spaces: [sharedSpaceJson(), personalSpaceJson()],
        taskLists: [listJson()],
        savingsGoals: [goalJson()],
        serverTime: '2026-11-02T08:00:00.000000Z',
      ),
    );

    expect(await h.account.sync.sync(), isTrue);

    expect(
      [
        for (final request in h.api.requests)
          if (request.path == '/sync') request.query,
      ],
      [
        {'since': '2026-09-01T00:00:00.000000Z'},
        null,
      ],
    );
    expect(await store.meta(MetaKeys.syncSince), '2026-11-02T08:00:00.000000Z');

    // Yang tidak dikirim lagi oleh sync penuh hilang dari HP.
    expect(await h.local(EntityType.task, otherTask), isNull);
    expect(await h.local(EntityType.memory, goneMemory), isNull);
    // Yang dikirim lagi tetap ada; yang masih di antrean tetap dengan perubahannya.
    expect(await h.local(EntityType.goal, goalId), isNotNull);
    expect([for (final space in await store.spaces()) space.id], unorderedEquals([sharedSpaceId, personalSpaceId]));
    expect((await h.local(EntityType.task, taskId))!['title'], 'Belum terkirim');
    expect((await h.ops()).single.entityId, taskId);
    // Profil sendiri tidak ikut dikosongkan.
    expect(await h.local(EntityType.me, ''), isNotNull);
  });

  test('410 kedua kalinya tidak membuat putaran tanpa akhir', () async {
    final h = Harness();
    addTearDown(h.dispose);
    await h.seed();
    await h.account.store.setMeta(MetaKeys.syncSince, '2026-09-01T00:00:00.000000Z');
    await h.account.store.setMeta(MetaKeys.syncCollections, '${SyncEngine.collectionsVersion}');
    for (var i = 0; i < 2; i++) {
      h.api.enqueue((_) => throw apiError(410, ApiErrorCode.syncExpired, message: 'Sync terlalu lama.'));
    }

    expect(await h.account.sync.sync(), isFalse);
    expect(h.api.requests.where((request) => request.path == '/sync'), hasLength(2));
    expect(await h.account.store.meta(MetaKeys.syncSince), isNull, reason: 'sync berikutnya tetap penuh');
  });
}
