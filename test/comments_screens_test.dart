import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/notifications/push_service.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/features/comments/presentation/comments_section.dart';
import 'package:todolist/features/savings/presentation/entry_detail_sheet.dart';
import 'package:todolist/features/savings/presentation/goal_detail_screen.dart';
import 'package:todolist/features/tasks/presentation/task_detail_screen.dart';

import 'helpers/app_harness.dart';
import 'helpers/fake_push.dart';
import 'helpers/fixtures.dart';

/// Reaksi dan komentar (v1.x): layar.
void main() {
  setUpAll(prepareAppTests);

  Map<String, dynamic> payloadOf(dynamic op) => jsonDecode(op.payload as String) as Map<String, dynamic>;

  Finder composer() => find.widgetWithText(TextField, 'Tulis komentar…');

  group('Detail tugas', () {
    testWidgets('tulis komentar, beri dan cabut reaksi, ubah lalu hapus dengan Urungkan', (tester) async {
      final h = Harness();
      await h.seed(withTask: true);
      await h.account.store.write(EntityType.comment, commentJson(), serverUpdatedAt: t0);
      final container = await pumpApp(tester, h);

      // Dibuka seperti dari notifikasi: langsung bergulir ke Komentar.
      container.read(routerProvider).go(Routes.task(taskId, comments: true));
      await settle(tester);
      expect(find.byType(CommentsSection), findsOneWidget);
      expect(find.text('Jangan lupa yang isi ulang, ya.'), findsOneWidget);
      // Komentar pasangan tidak bisa diubah dari HP ini.
      expect(find.byTooltip('Opsi komentar'), findsNothing);

      await tester.enterText(composer(), '  Siap, nanti sore  ');
      // Kolom yang diisi digulir ke tampilan dulu; selama itu daftar mengabaikan ketukan.
      await settle(tester);
      await tester.tap(find.byTooltip('Kirim komentar'));
      await settle(tester);
      expect(find.text('Siap, nanti sore'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Siap, nanti sore'), findsNothing, reason: 'kolomnya dikosongkan');
      final put = (await h.ops()).singleWhere((op) => op.entityType == 'comment');
      expect(payloadOf(put), {'subject_type': 'task', 'subject_id': taskId, 'body': 'Siap, nanti sore'});

      // Reaksi.
      await tester.tap(find.byTooltip('Beri reaksi'));
      await settle(tester);
      await tester.tap(find.bySemanticsLabel('Reaksi 😂'));
      await settle(tester);
      expect(find.bySemanticsLabel('Reaksi 😂 dari Aku'), findsOneWidget);
      expect(find.bySemanticsLabel('Reaksi 😂'), findsNothing, reason: 'pilihan reaksi tertutup lagi');
      await tester.tap(find.bySemanticsLabel('Reaksi 😂 dari Aku'));
      await settle(tester);
      expect(find.bySemanticsLabel(RegExp('Reaksi 😂 dari')), findsNothing);
      expect((await h.ops()).where((op) => op.entityType == 'reaction'), isEmpty, reason: 'belum terkirim, jadi batal');

      // Ubah komentarku, semenit kemudian.
      h.clock.advance(const Duration(minutes: 1));
      await tester.tap(find.byTooltip('Opsi komentar'));
      await settle(tester);
      await tester.tap(find.text('Ubah').last);
      await settle(tester);
      expect(find.text('Ubah komentar'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, 'Siap, nanti sore'), 'Siap, sekarang juga');
      await tester.tap(find.text('Simpan'));
      await settle(tester);
      expect(find.text('Siap, sekarang juga'), findsOneWidget);
      expect(find.textContaining('diedit', findRichText: true), findsOneWidget);

      // Hapus, lalu Urungkan.
      await tester.tap(find.byTooltip('Opsi komentar'));
      await settle(tester);
      await tester.tap(find.text('Hapus').last);
      await settle(tester);
      expect(find.text('Siap, sekarang juga'), findsNothing);
      expect(find.text('Komentar dihapus.'), findsOneWidget);
      await tester.tap(find.text('Urungkan'));
      await settle(tester);
      expect(find.text('Siap, sekarang juga'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('tugas di Ruang Pribadi: tanpa komentar dan reaksi', (tester) async {
      final h = Harness();
      await h.seed();
      const privateList = '01m4dh0429zqexwxs1n4yw5jn9';
      await h.account.store.write(
        EntityType.list,
        listJson(id: privateList, spaceId: personalSpaceId, name: 'Pribadi'),
        serverUpdatedAt: t0,
      );
      await h.account.store.write(
        EntityType.task,
        taskJson(taskListId: privateList, spaceId: personalSpaceId, title: 'Rahasia'),
        serverUpdatedAt: t0,
      );
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.task(taskId, comments: true));
      await settle(tester);

      expect(find.byType(TaskDetailScreen), findsOneWidget);
      expect(find.byType(CommentsSection), findsNothing);

      await disposeApp(tester, h);
    });
  });

  group('kenangan dan setoran', () {
    testWidgets('kenangan: reaksi pasangan, lalu ikut memberi emoji yang sama', (tester) async {
      final h = Harness();
      await h.seed();
      await h.account.store.write(EntityType.memory, memoryJson(), serverUpdatedAt: t0);
      await h.account.store.write(
        EntityType.reaction,
        reactionJson(subjectType: 'memory', subjectId: memoryId),
        serverUpdatedAt: t0,
      );
      final container = await pumpApp(tester, h);

      container.read(routerProvider).go(Routes.memories);
      await settle(tester);
      expect(
        find.bySemanticsLabel(RegExp('1 reaksi, 0 komentar')),
        findsOneWidget,
        reason: 'penanda di kartu linimasa',
      );

      container.read(routerProvider).go(Routes.memory(memoryId, comments: true));
      await settle(tester);
      expect(find.bySemanticsLabel('Reaksi ❤️ dari Pasangan'), findsOneWidget);
      h.clock.advance(const Duration(minutes: 1));
      await tester.tap(find.bySemanticsLabel('Reaksi ❤️ dari Pasangan'));
      await settle(tester);
      expect(find.bySemanticsLabel('Reaksi ❤️ dari Pasangan dan Aku'), findsOneWidget);
      final op = (await h.ops()).single;
      expect('${op.method} ${op.entityType}', 'PUT reaction');
      expect(payloadOf(op), {'subject_type': 'memory', 'subject_id': memoryId, 'emoji': '❤️'});

      await disposeApp(tester, h);
    });

    testWidgets('setoran di target bersama: riwayat bertanda, ketuk membuka detail dengan komentarnya', (tester) async {
      final h = Harness();
      await h.seed(withGoal: true);
      await h.account.store.write(EntityType.entry, entryJson(), serverUpdatedAt: t0);
      await h.account.store.write(
        EntityType.comment,
        commentJson(subjectType: 'savings_entry', subjectId: entryId, body: 'Mantap, gajian!'),
        serverUpdatedAt: t0,
      );
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.goal(goalId));
      await settle(tester);

      await tester.scrollUntilVisible(
        find.bySemanticsLabel(RegExp('0 reaksi, 1 komentar')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Aku · Gajian'));
      await settle(tester);
      expect(find.byType(EntryDetailSheet), findsOneWidget);
      expect(find.text('Setoran'), findsOneWidget);
      expect(find.text('Mantap, gajian!'), findsOneWidget);

      await tester.tap(find.text('Ubah setoran'));
      await settle(tester);
      expect(find.byType(EntryDetailSheet), findsNothing);
      expect(find.text('Hapus setoran'), findsOneWidget);

      await disposeApp(tester, h);
    });
  });

  group('notifikasi', () {
    PushMessage commentPush(String subjectType, String subjectId, {String? goal}) => PushMessage(
      title: 'Judul',
      body: 'Sari: Halo',
      data: {
        'type': 'comment_created',
        'space_id': sharedSpaceId,
        'subject_type': subjectType,
        'subject_id': subjectId,
        'savings_goal_id': ?goal,
      },
    );

    testWidgets('ketuk: tugas dibuka di komentarnya, setoran dibuka detailnya, yang hilang ke induknya', (
      tester,
    ) async {
      final h = Harness();
      await h.seed(withTask: true, withGoal: true);
      await h.account.store.write(EntityType.entry, entryJson(), serverUpdatedAt: t0);
      final push = FakePushService();
      final container = await pumpApp(tester, h, push: push);

      push.tap(commentPush('task', taskId));
      await settle(tester);
      expect(container.read(routerProvider).state.uri.toString(), Routes.task(taskId, comments: true));
      expect(find.byType(CommentsSection), findsOneWidget);

      push.tap(commentPush('savings_entry', entryId, goal: goalId));
      await settle(tester);
      expect(find.byType(GoalDetailScreen), findsOneWidget);
      expect(find.byType(EntryDetailSheet), findsOneWidget);
      Navigator.of(tester.element(find.byType(EntryDetailSheet))).pop();
      await settle(tester);

      push.tap(commentPush('memory', memoryId));
      await settle(tester);
      expect(container.read(routerProvider).state.uri.path, Routes.memories);
      expect(find.text('Kenangan itu belum tersedia di HP ini.'), findsOneWidget);

      await disposeApp(tester, h);
    });
  });
}
