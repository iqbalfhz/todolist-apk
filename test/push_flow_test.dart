import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/notifications/push_service.dart';
import 'package:todolist/core/platform/device_platform.dart';
import 'package:todolist/core/storage/key_value_store.dart';
import 'package:todolist/features/auth/presentation/auth_actions.dart';

import 'helpers/app_harness.dart';
import 'helpers/fake_api.dart';
import 'helpers/fake_push.dart';
import 'helpers/fixtures.dart';

void main() {
  setUpAll(prepareAppTests);

  PushMessage taskPush(String type) => PushMessage(
    title: 'Sari menitipkan tugas',
    body: 'Jemput paket',
    data: {'type': type, 'space_id': sharedSpaceId, 'task_id': taskId},
  );

  const savingsPush = PushMessage(
    title: 'Setoran baru',
    body: 'Sari menyetor ke Dana Liburan',
    data: {'type': 'savings_deposit', 'space_id': sharedSpaceId, 'savings_goal_id': goalId},
  );

  Iterable<SentRequest> to(Harness h, String path) => h.api.requests.where((request) => request.path == path);

  group('push notification', () {
    testWidgets('token FCM HP ini didaftarkan ke server, juga saat FCM menggantinya', (tester) async {
      final h = Harness();
      await h.seed();
      final push = FakePushService(fcmToken: 'token-fcm-1');
      await pumpApp(tester, h, push: push);

      final first = to(h, '/devices').single;
      expect(first.method, 'POST');
      expect(first.body, {'token': 'token-fcm-1', 'platform': 'android'});

      push.refreshToken('token-fcm-2');
      await settle(tester);
      expect(to(h, '/devices').last.body, containsPair('token', 'token-fcm-2'));

      await disposeApp(tester, h);
    });

    testWidgets('push masuk saat app terbuka: data ditarik dan notifikasi lokal ditampilkan', (tester) async {
      final h = Harness();
      await h.seed();
      final push = FakePushService();
      await pumpApp(tester, h, push: push);
      final syncsBefore = to(h, '/sync').length;

      h.api.syncPages.add(
        h.api.syncPage(
          tasks: [taskJson(title: 'Jemput paket', dueDate: '2026-10-08')],
        ),
      );
      push.receive(taskPush('task_assigned'));
      await settle(tester);

      expect(to(h, '/sync').length, syncsBefore + 1);
      expect(find.text('Jemput paket'), findsOneWidget);
      expect(push.shown.single.channel, PushChannels.activity);

      // Pengingat tenggat memakai channel yang bersuara.
      push.receive(taskPush('task_reminder'));
      await settle(tester);
      expect(push.shown.last.channel, PushChannels.reminders);

      await disposeApp(tester, h);
    });

    testWidgets('notifikasi diketuk: sync dulu, lalu layar sesuai jenisnya dibuka', (tester) async {
      final h = Harness();
      await h.seed();
      final push = FakePushService();
      await pumpApp(tester, h, push: push);

      // Tugasnya baru ada di server; HP ini belum punya.
      h.api.syncPages.add(h.api.syncPage(tasks: [taskJson(title: 'Jemput paket')]));
      push.tap(taskPush('task_assigned'));
      await settle(tester);

      expect(find.text('Detail tugas'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Jemput paket'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('notifikasi diketuk tetapi datanya belum ada di HP: layar induk dengan pesan singkat', (tester) async {
      final h = Harness();
      await h.seed();
      final push = FakePushService();
      await pumpApp(tester, h, push: push);

      push.tap(taskPush('task_reminder'));
      await settle(tester);

      expect(find.text('Detail tugas'), findsNothing);
      expect(find.text('Semua tugas'), findsOneWidget);
      expect(find.text('Tugas itu belum tersedia di HP ini.'), findsOneWidget);

      push.tap(savingsPush);
      await settle(tester);

      // Tab Tabungan, bukan detail target.
      expect(find.text('Riwayat tabungan'), findsNothing);
      expect(find.text('Belum ada target tabungan. Buat satu, lalu catat setoran pertama kalian.'), findsOneWidget);
      expect(find.text('Target itu belum tersedia di HP ini.'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('notifikasi tabungan diketuk: lembar yang masih terbuka ditutup, lalu detail target dibuka', (
      tester,
    ) async {
      final h = Harness();
      await h.seed(withGoal: true);
      final push = FakePushService();
      await pumpApp(tester, h, push: push);

      await tester.tap(find.byType(FloatingActionButton));
      await settle(tester);
      expect(find.text('Tugas baru'), findsOneWidget);

      push.tap(savingsPush);
      await settle(tester);

      expect(find.text('Tugas baru'), findsNothing);
      expect(find.text('Riwayat tabungan'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('app dibuka dari notifikasi: langsung menuju layarnya', (tester) async {
      final h = Harness();
      await h.seed(withTask: true);
      final push = FakePushService(opened: taskPush('task_reminder'));
      await pumpApp(tester, h, push: push);

      expect(find.text('Detail tugas'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Beli galon'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('keluar: token FCM dicabut di server dan dihapus dari HP', (tester) async {
      final h = Harness();
      await h.seed();
      final push = FakePushService(fcmToken: 'token-fcm-1');
      final storage = MemoryKeyValueStore({StorageKeys.token: '1|token-palsu', StorageKeys.userId: meId});
      final container = await pumpApp(tester, h, push: push, storage: storage);

      await tester.runAsync(() => signOut(container));
      await settle(tester);

      expect(to(h, '/auth/logout').single.body, {'fcm_token': 'token-fcm-1'});
      expect(push.tokenDeleted, isTrue);
      expect(storage.values.containsKey(StorageKeys.token), isFalse);
      expect(find.text('Senang melihatmu lagi.'), findsOneWidget);

      await disposeApp(tester, h);
    });
  });

  group('izin notifikasi', () {
    const android14 = DeviceInfo(manufacturer: 'Google', brand: 'google', model: 'Pixel 8', sdkInt: 34);
    const xiaomi = DeviceInfo(manufacturer: 'Xiaomi', brand: 'Redmi', model: 'Redmi Note 13', sdkInt: 34);

    testWidgets('Android 13+: izin baru diminta setelah tombolnya diketuk', (tester) async {
      final h = Harness();
      await h.seed();
      final push = FakePushService();
      final storage = MemoryKeyValueStore();
      await pumpApp(tester, h, push: push, device: android14, notificationsDone: false, storage: storage);

      expect(find.text('Biar tidak ada yang terlewat'), findsOneWidget);
      expect(push.permissionRequests, 0);
      // HP ini tidak butuh panduan baterai.
      expect(find.text('Supaya pengingat tetap sampai'), findsNothing);

      await tester.tap(find.text('Izinkan notifikasi'));
      await settle(tester);

      expect(push.permissionRequests, 1);
      expect(find.text('Notifikasi sudah diizinkan.'), findsOneWidget);
      expect(find.text('Izinkan notifikasi'), findsNothing);

      await tester.tap(find.text('Lanjut'));
      await settle(tester);

      expect(storage.values[StorageKeys.notificationsOnboarded], isNotNull);
      expect(find.text('Tugas hari ini'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('izin ditolak: ada jalan ke pengaturan notifikasi, dan layar tetap bisa dilewati', (tester) async {
      final h = Harness();
      await h.seed();
      final push = FakePushService(grantOnRequest: false);
      await pumpApp(tester, h, push: push, device: android14, notificationsDone: false);

      await tester.tap(find.text('Izinkan notifikasi'));
      await settle(tester);

      expect(
        find.text('Notifikasi belum diizinkan. Kamu bisa menyalakannya nanti dari pengaturan HP.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Buka pengaturan notifikasi'));
      await settle(tester);
      expect(push.settingsOpened, 1);

      await tester.tap(find.text('Lewati'));
      await settle(tester);
      expect(find.text('Tugas hari ini'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('HP Xiaomi: panduan mematikan penghemat baterai ikut tampil', (tester) async {
      // Kode native (`MainActivity.kt`) diganti: pertama berhasil membuka pengaturan, lalu gagal.
      const channel = MethodChannel('todolist/device');
      final calls = <String>[];
      var opens = true;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        return opens;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));

      final h = Harness();
      await h.seed();
      await pumpApp(tester, h, push: FakePushService(granted: true), device: xiaomi, notificationsDone: false);

      expect(find.text('Notifikasi sudah diizinkan.'), findsOneWidget);
      expect(find.text('Supaya pengingat tetap sampai'), findsOneWidget);
      expect(find.textContaining('HP Xiaomi sering menghentikan app'), findsOneWidget);
      expect(find.textContaining('Nyalakan Mulai otomatis.'), findsOneWidget);

      const failed = 'Pengaturan baterai tidak bisa dibuka dari sini. Buka lewat Pengaturan HP.';
      await tester.ensureVisible(find.text('Buka pengaturan baterai'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buka pengaturan baterai'));
      await settle(tester);
      expect(calls, ['openBatterySettings']);
      expect(find.text(failed), findsNothing);

      // HP yang tidak punya layar pengaturannya: pesannya menunjukkan jalan lain.
      opens = false;
      await tester.tap(find.text('Buka pengaturan baterai'));
      await settle(tester);
      expect(find.text(failed), findsOneWidget);

      await disposeApp(tester, h);
    });
  });
}
