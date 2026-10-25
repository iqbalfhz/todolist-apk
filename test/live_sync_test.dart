import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/app_services.dart';
import 'package:todolist/core/notifications/push_service.dart';

import 'helpers/app_harness.dart';
import 'helpers/fake_api.dart';
import 'helpers/fake_push.dart';
import 'helpers/fixtures.dart';

/// Sinkron langsung (v1.x): perubahan dari pasangan muncul tanpa tarik untuk menyegarkan.
void main() {
  setUpAll(prepareAppTests);

  Iterable<SentRequest> syncs(Harness h) => h.api.requests.where((request) => request.path == '/sync');

  Future<void> moveTo(WidgetTester tester, List<AppLifecycleState> states) async {
    for (final state in states) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await settle(tester);
  }

  testWidgets('selama app tampil, data ditarik tiap 30 detik; di latar belakang berhenti', (tester) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h);
    final before = syncs(h).length;

    // Pasangan menambah tugas; HP ini tidak melakukan apa pun.
    h.api.syncPages.add(
      h.api.syncPage(
        tasks: [taskJson(title: 'Jemput paket', dueDate: '2026-10-08')],
      ),
    );
    await tester.pump(liveSyncInterval);
    await settle(tester);
    expect(syncs(h).length, before + 1);
    expect(find.text('Jemput paket'), findsOneWidget);

    await moveTo(tester, [AppLifecycleState.inactive, AppLifecycleState.hidden, AppLifecycleState.paused]);
    final paused = syncs(h).length;
    await tester.pump(liveSyncInterval * 4);
    await settle(tester);
    expect(syncs(h).length, paused, reason: 'tidak ada sync berkala saat app tidak tampil');

    // Kembali tampil: langsung sync, lalu berkala lagi.
    await moveTo(tester, [AppLifecycleState.hidden, AppLifecycleState.inactive, AppLifecycleState.resumed]);
    expect(syncs(h).length, paused + 1);
    await tester.pump(liveSyncInterval);
    await settle(tester);
    expect(syncs(h).length, paused + 2);

    await disposeApp(tester, h);
  });

  testWidgets('panel notifikasi ditarik (inactive): sync berkala tetap jalan', (tester) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h);

    await moveTo(tester, [AppLifecycleState.inactive]);
    addTearDown(() => tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed));
    final before = syncs(h).length;
    await tester.pump(liveSyncInterval);
    await settle(tester);
    expect(syncs(h).length, before + 1);

    await disposeApp(tester, h);
  });

  testWidgets('push sync dari server: data langsung ditarik tanpa notifikasi', (tester) async {
    final h = Harness();
    await h.seed();
    final push = FakePushService();
    await pumpApp(tester, h, push: push);
    final before = syncs(h).length;

    h.api.syncPages.add(
      h.api.syncPage(
        tasks: [taskJson(title: 'Jemput paket', dueDate: '2026-10-08')],
      ),
    );
    push.receive(const PushMessage(data: {'type': 'sync', 'space_id': sharedSpaceId}));
    await settle(tester);

    expect(syncs(h).length, before + 1);
    expect(find.text('Jemput paket'), findsOneWidget);
    expect(push.shown, isEmpty);

    // Pesan data tanpa judul dan isi tidak pernah jadi notifikasi kosong.
    push.receive(const PushMessage(data: {'type': 'jenis_baru', 'space_id': sharedSpaceId}));
    await settle(tester);
    expect(push.shown, isEmpty);
    expect(syncs(h).length, before + 2);

    await disposeApp(tester, h);
  });
}
