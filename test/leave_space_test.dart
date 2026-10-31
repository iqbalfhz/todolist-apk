import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/database/local_store.dart';
import 'package:todolist/core/notifications/push_service.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/core/sync/sync_engine.dart';

import 'helpers/app_harness.dart';
import 'helpers/fake_api.dart';
import 'helpers/fake_push.dart';
import 'helpers/fixtures.dart';

/// Keluar dari Ruang Bersama (v1.0).
void main() {
  setUpAll(prepareAppTests);

  const privateList = '01m4dh0429zqexwxs1n4yw5jn9';
  const privateTask = '01m4dh1yn9t6cdn39q4f091899';

  /// Ruang Bersama berisi daftar, tugas, target, setoran, tanggal penting, kenangan beserta
  /// fotonya, dan komentar; Ruang Pribadi berisi satu daftar dan satu tugas.
  Future<void> seedSpaces(Harness h) async {
    await h.seed(withTask: true, withGoal: true);
    final store = h.account.store;
    for (final (type, json) in [
      (EntityType.entry, entryJson()),
      (EntityType.specialDate, specialDateJson()),
      (EntityType.memory, memoryJson()),
      (EntityType.memoryPhoto, memoryPhotoJson()),
      (EntityType.comment, commentJson()),
      (EntityType.list, listJson(id: privateList, spaceId: personalSpaceId, name: 'Pribadi')),
      (EntityType.task, taskJson(id: privateTask, taskListId: privateList, spaceId: personalSpaceId, title: 'Rahasia')),
    ]) {
      await store.write(type, json, serverUpdatedAt: t0);
    }
    h.api.rows.putIfAbsent('tasks', () => {})[privateTask] = taskJson(
      id: privateTask,
      taskListId: privateList,
      spaceId: personalSpaceId,
    );
    h.api.spaces = [personalSpaceJson(), sharedSpaceJson()];
  }

  /// Isi Ruang Bersama yang diperiksa, per jenis.
  const sharedContent = [
    (EntityType.list, listId),
    (EntityType.task, taskId),
    (EntityType.goal, goalId),
    (EntityType.entry, entryId),
    (EntityType.specialDate, specialDateId),
    (EntityType.memory, memoryId),
    (EntityType.memoryPhoto, photoId),
    (EntityType.comment, commentId),
  ];

  /// Sync berikutnya melanjutkan kursor (bukan sync penuh). [holdQueue] menahan antrean sekali,
  /// supaya sync hanya menarik data.
  Future<void> pullOnly(Harness h, {bool holdQueue = false}) async {
    await h.account.store.setMeta(MetaKeys.syncSince, 'T-0');
    await h.account.store.setMeta(MetaKeys.syncCollections, '${SyncEngine.collectionsVersion}');
    if (holdQueue) h.api.enqueue((_) => throw const NetworkFailure());
  }

  DateTime? deletedAt(Map<String, dynamic>? row) {
    final value = row?['deleted_at'] as String?;
    return value == null ? null : DateTime.parse(value);
  }

  Map<String, dynamic> closedSpace() => {...sharedSpaceJson(updatedAt: t1), 'deleted_at': t1};

  group('keluar', () {
    test('antrean dikirim dulu, lalu DELETE; ruang dan isinya hilang dari HP, sisa antreannya dibuang', () async {
      final h = Harness();
      addTearDown(h.dispose);
      await seedSpaces(h);

      // Perubahan terakhir di Ruang Bersama, lalu dua centang yang masih menunggu Urungkan.
      await h.account.tasks.rename(taskId, 'Beli galon dua');
      await h.account.tasks.complete(taskId);
      await h.account.tasks.complete(privateTask);

      await h.account.spaces.leave(sharedSpaceId);

      expect(
        [for (final request in h.api.requests) '${request.method} ${request.path}'],
        ['PATCH /tasks/$taskId', 'DELETE /spaces/$sharedSpaceId'],
      );
      expect(await h.local(EntityType.space, sharedSpaceId), isNull);
      for (final (type, id) in sharedContent) {
        expect(await h.local(type, id), isNull, reason: '$type ikut terhapus');
      }
      // Ruang Pribadi tidak berubah, termasuk antreannya.
      expect(await h.local(EntityType.space, personalSpaceId), isNotNull);
      expect((await h.local(EntityType.task, privateTask))!['completed_at'], isNotNull);
      expect([for (final op in await h.ops()) op.entityId], [privateTask]);
    });

    test('tanpa koneksi atau ditolak server: tidak ada yang berubah di HP', () async {
      final h = Harness();
      addTearDown(h.dispose);
      await seedSpaces(h);

      h.api.offline = true;
      await expectLater(h.account.spaces.leave(sharedSpaceId), throwsA(isA<NetworkFailure>()));
      h.api.offline = false;

      h.api.failNext(apiError(404, ApiErrorCode.notFound, message: 'Data tidak ditemukan.'));
      await expectLater(
        h.account.spaces.leave(sharedSpaceId),
        throwsA(isA<ApiError>().having((error) => error.code, 'code', ApiErrorCode.notFound)),
      );

      expect(await h.local(EntityType.space, sharedSpaceId), isNotNull);
      for (final (type, id) in sharedContent) {
        expect(await h.local(type, id), isNotNull);
      }
    });
  });

  group('sync', () {
    test(
      'Ruang Bersama tiba tertutup: isinya ikut terhapus, kecuali yang masih di antrean sampai dibalas 404',
      () async {
        final h = Harness();
        addTearDown(h.dispose);
        await seedSpaces(h);
        h.api.offline = true;
        await h.account.tasks.rename(taskId, 'Belum terkirim');
        h.api.offline = false;

        await pullOnly(h, holdQueue: true);
        h.api.syncPages.add(h.api.syncPage(spaces: [closedSpace()]));
        await h.account.sync.sync();

        expect([for (final space in await h.account.store.spaces()) space.id], [personalSpaceId]);
        for (final (type, id) in sharedContent.where((item) => item.$1 != EntityType.task)) {
          expect(deletedAt(await h.local(type, id)), DateTime.parse(t1), reason: '$type ikut terhapus');
        }
        // Tugas yang masih punya operasi dibiarkan dulu; Ruang Pribadi tidak tersentuh.
        expect((await h.local(EntityType.task, taskId))!['deleted_at'], isNull);
        expect((await h.local(EntityType.list, privateList))!['deleted_at'], isNull);
        expect((await h.local(EntityType.task, privateTask))!['deleted_at'], isNull);

        // Server membalas 404 untuk isi ruang yang ditutup; operasinya dibuang beserta tugasnya.
        h.api.rows['tasks']!.remove(taskId);
        await h.account.outbox.flush(retryNow: true);
        expect(await h.ops(), isEmpty);
        expect(await h.local(EntityType.task, taskId), isNull);
      },
    );

    test('bergabung lagi dalam 30 hari: ruang lama dan isinya kembali lewat kode dan sync biasa', () async {
      final h = Harness();
      addTearDown(h.dispose);
      await seedSpaces(h);
      await h.account.spaces.leave(sharedSpaceId);

      // Server memulihkan ruang lama dengan id dan created_at aslinya, lalu memperbarui isinya.
      h.api.acceptedSpace = sharedSpaceJson(updatedAt: t2);
      final restored = await h.account.spaces.accept('K7M2QX');
      expect((restored.id, restored.createdAt.toUtc()), (sharedSpaceId, DateTime.parse(t0)));

      await pullOnly(h);
      h.api.syncPages.add(
        h.api.syncPage(
          taskLists: [listJson(updatedAt: t2)],
          tasks: [taskJson(updatedAt: t2)],
          savingsGoals: [goalJson(updatedAt: t2)],
        ),
      );
      await h.account.sync.sync();

      expect([for (final space in await h.account.store.spaces()) space.id], contains(sharedSpaceId));
      for (final (type, id) in [(EntityType.list, listId), (EntityType.task, taskId), (EntityType.goal, goalId)]) {
        expect((await h.local(type, id))!['deleted_at'], isNull, reason: '$type kembali');
      }
    });
  });

  group('layar Ajak pasangan', () {
    Future<void> openPairing(WidgetTester tester, Harness h) async {
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.pairing);
      await settle(tester);
    }

    Future<void> tapLeave(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Keluar dari Ruang Bersama'));
      await tester.tap(find.text('Keluar dari Ruang Bersama'));
      await settle(tester);
    }

    testWidgets('konfirmasi menyebut akibatnya; setelah keluar, kode undangan tampil lagi', (tester) async {
      final h = Harness();
      await seedSpaces(h);
      await openPairing(tester, h);
      expect(find.text('Ruang Bersama'), findsWidgets);

      await tapLeave(tester);
      expect(find.text('Keluar dari Ruang Bersama?'), findsOneWidget);
      expect(
        find.text(
          'Ruang Bersama ditutup untukmu dan Sari. Isinya disimpan 30 hari dan kembali utuh kalau kalian '
          'bergabung lagi dengan kode undangan. Setelah itu, isinya dihapus permanen beserta fotonya.\n\n'
          'Ruang Pribadi milikmu tidak berubah. Kalau perlu, simpan salinannya dulu lewat Ekspor data.',
        ),
        findsOneWidget,
      );

      // Batal: tidak ada yang dikirim.
      await tester.tap(find.text('Batal'));
      await settle(tester);
      expect(h.api.requests.where((request) => request.method == 'DELETE'), isEmpty);

      await tapLeave(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Keluar'));
      await settle(tester);

      expect(h.api.requests.where((request) => request.method == 'DELETE').single.path, '/spaces/$sharedSpaceId');
      expect(
        find.text('Kamu sudah keluar dari Ruang Bersama. Isinya disimpan 30 hari kalau kalian ingin bergabung lagi.'),
        findsOneWidget,
      );
      expect(find.text('Pakai berdua, lebih ringan'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('K 7 M 2 Q X')), findsOneWidget);
      expect(await h.local(EntityType.task, taskId), isNull);

      await disposeApp(tester, h);
    });

    testWidgets('selama keluar tombolnya nonaktif; tanpa koneksi tetap berpasangan', (tester) async {
      final h = Harness();
      await seedSpaces(h);
      final reply = Completer<ApiResponse>();
      await openPairing(tester, h);

      h.api.enqueue((request) => request.method == 'DELETE' ? reply.future : h.api.handle(request));
      await tapLeave(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Keluar'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Mengirim perubahan terakhir, lalu menutup Ruang Bersama…'), findsOneWidget);
      expect(
        tester
            .widget<ButtonStyleButton>(
              find.ancestor(of: find.text('Keluar dari Ruang Bersama'), matching: find.bySubtype<ButtonStyleButton>()),
            )
            .onPressed,
        isNull,
      );

      reply.completeError(const NetworkFailure());
      await settle(tester);
      expect(find.text('Butuh koneksi internet. Coba lagi saat online.'), findsOneWidget);
      expect(find.text('Keluar dari Ruang Bersama'), findsOneWidget);
      expect(await h.local(EntityType.space, sharedSpaceId), isNotNull);

      await disposeApp(tester, h);
    });

    testWidgets('alur pertama kali: tanpa tombol keluar', (tester) async {
      final h = Harness();
      await seedSpaces(h);
      await pumpApp(tester, h, pairingDone: false);

      expect(find.text('Lanjut'), findsOneWidget);
      expect(find.text('Keluar dari Ruang Bersama'), findsNothing);

      await disposeApp(tester, h);
    });
  });

  group('notifikasi', () {
    testWidgets('partner_left: channel aktivitas, lalu ketuk menjalankan sync dan membuka Beranda', (tester) async {
      const message = PushMessage(
        title: 'Ruang Bersama',
        body: 'Sari keluar dari Ruang Bersama. Isinya disimpan 30 hari kalau kalian ingin bergabung lagi.',
        data: {'type': 'partner_left', 'space_id': sharedSpaceId},
      );
      expect(message.channel, PushChannels.activity);
      expect(message.tag, 'space-$sharedSpaceId');
      expect(message.isSilent, isFalse);

      final h = Harness();
      await seedSpaces(h);
      final push = FakePushService();
      final container = await pumpApp(tester, h, push: push);
      container.read(routerProvider).go(Routes.goal(goalId));
      await settle(tester);

      h.api.syncPages.add(h.api.syncPage(spaces: [closedSpace()]));
      push.tap(message);
      await settle(tester);

      expect(container.read(routerProvider).state.uri.path, Routes.home);
      expect(deletedAt(await h.local(EntityType.goal, goalId)), DateTime.parse(t1));
      expect([for (final space in await h.account.store.spaces()) space.id], [personalSpaceId]);

      await disposeApp(tester, h);
    });
  });
}
