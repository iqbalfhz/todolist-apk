import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/notifications/push_service.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/features/auth/domain/user.dart';
import 'package:todolist/features/memories/presentation/memory_detail_screen.dart';

import 'helpers/app_harness.dart';
import 'helpers/fake_push.dart';
import 'helpers/fixtures.dart';

/// Kenangan hari ini (v1.x): push `memory_flashback` dan sakelarnya.
void main() {
  setUpAll(prepareAppTests);

  const flashback = PushMessage(
    title: 'Hari ini setahun lalu',
    body: 'Liburan ke Bali dan 2 kenangan lain',
    data: {'type': 'memory_flashback', 'space_id': sharedSpaceId, 'memory_id': memoryId},
  );

  test('memory_flashback: channel pengingat, tag kenangannya, dan tentang kenangan', () {
    expect(flashback.channel, PushChannels.reminders);
    expect(flashback.tag, 'memory-$memoryId');
    expect(flashback.isAboutMemory, isTrue);
    expect(flashback.isSilent, isFalse);
  });

  test('akun lama tanpa kunci memory_flashbacks: bawaannya menyala', () {
    expect(NotificationPrefs.fromJson({'task_reminders': false}).memoryFlashbacks, isTrue);
    expect(const NotificationPrefs(memoryFlashbacks: false).toJson()['memory_flashbacks'], isFalse);
  });

  testWidgets('ketuk: Detail kenangan, atau tab Kenangan kalau kenangannya belum ada', (tester) async {
    final h = Harness();
    await h.seed();
    final push = FakePushService();
    final container = await pumpApp(tester, h, push: push);

    push.tap(flashback);
    await settle(tester);
    expect(container.read(routerProvider).state.uri.path, Routes.memories);
    expect(find.text('Kenangan itu belum tersedia di HP ini.'), findsOneWidget);

    await h.account.store.write(EntityType.memory, memoryJson(), serverUpdatedAt: t0);
    push.tap(flashback);
    await settle(tester);
    expect(container.read(routerProvider).state.uri.path, Routes.memory(memoryId));
    expect(find.byType(MemoryDetailScreen), findsOneWidget);

    await disposeApp(tester, h);
  });

  testWidgets('Pengaturan: sakelar Kenangan hari ini mengirim notification_prefs utuh', (tester) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h);

    await tester.tap(find.bySemanticsLabel('Buka Pengaturan'));
    await settle(tester);
    // Sakelar terakhir; gulir sampai baris di bawahnya supaya tidak tertutup tab bawah.
    await tester.scrollUntilVisible(find.text('Mata uang'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Kenangan di tanggal yang sama tahun-tahun sebelumnya, pukul 08.00'), findsOneWidget);
    await tester.tap(find.text('Kenangan hari ini'));
    await settle(tester);

    final payload = jsonDecode((await h.ops()).single.payload!) as Map<String, dynamic>;
    expect((payload['notification_prefs'] as Map<String, dynamic>)['memory_flashbacks'], isFalse);
    expect((payload['notification_prefs'] as Map<String, dynamic>)['savings_reminders'], isTrue);

    await disposeApp(tester, h);
  });
}
