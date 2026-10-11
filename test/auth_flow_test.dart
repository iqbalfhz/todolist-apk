import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/queue/outbox.dart';
import 'package:todolist/core/session/session.dart';
import 'package:todolist/core/storage/key_value_store.dart';

import 'helpers/app_harness.dart';
import 'helpers/fake_api.dart';
import 'helpers/fixtures.dart';

void main() {
  setUpAll(prepareAppTests);

  Future<void> fillLogin(
    WidgetTester tester, {
    String email = 'nama@email.com',
    String password = 'rahasia-banget',
  }) async {
    await tester.enterText(find.byType(TextField).at(0), email);
    await tester.enterText(find.byType(TextField).at(1), password);
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await settle(tester);
  }

  testWidgets('belum masuk: app membuka layar Masuk, dan bisa pindah ke Daftar', (tester) async {
    final h = Harness();
    await pumpApp(tester, h, signedIn: false);

    expect(find.text('Senang melihatmu lagi.'), findsOneWidget);
    expect(find.text('Nama panggilan'), findsNothing);

    await tester.tap(find.widgetWithText(TextButton, 'Daftar'));
    await settle(tester);

    expect(find.text('Buat akun untuk mulai mencatat berdua.'), findsOneWidget);
    expect(find.text('Nama panggilan'), findsOneWidget);

    await disposeApp(tester, h);
  });

  testWidgets('isian diperiksa di HP sebelum dikirim', (tester) async {
    final h = Harness();
    await pumpApp(tester, h, signedIn: false);

    await fillLogin(tester, email: 'bukan-email', password: '');

    expect(find.text('Tulis email yang benar, misalnya nama@email.com.'), findsOneWidget);
    expect(find.text('Kata sandi belum diisi.'), findsOneWidget);
    expect(h.api.requests, isEmpty);

    await disposeApp(tester, h);
  });

  testWidgets('salah kata sandi: pesan dari server ditampilkan dan tetap di layar Masuk', (tester) async {
    final h = Harness();
    await pumpApp(tester, h, signedIn: false);

    h.api.failNext(apiError(422, ApiErrorCode.invalidCredentials, message: 'Email atau kata sandi salah.'));
    await fillLogin(tester);

    expect(find.text('Email atau kata sandi salah.'), findsOneWidget);
    expect(find.text('Senang melihatmu lagi.'), findsOneWidget);

    await disposeApp(tester, h);
  });

  testWidgets('tanpa koneksi: masuk butuh koneksi', (tester) async {
    final h = Harness();
    await pumpApp(tester, h, signedIn: false);

    h.api.failNext(const NetworkFailure());
    await fillLogin(tester);

    expect(find.text('Butuh koneksi internet. Coba lagi saat online.'), findsOneWidget);

    await disposeApp(tester, h);
  });

  testWidgets('alur pertama kali: Masuk, Izin notifikasi, Ajak pasangan, lalu Beranda', (tester) async {
    final h = Harness();
    final storage = MemoryKeyValueStore();
    h.api
      ..me = userJson()
      ..spaces = [personalSpaceJson()]
      ..syncPages.add(
        h.api.syncPage(
          spaces: [personalSpaceJson()],
          taskLists: [listJson(spaceId: personalSpaceId, name: 'Tugas')],
        ),
      );
    final container = await pumpApp(
      tester,
      h,
      signedIn: false,
      notificationsDone: false,
      pairingDone: false,
      storage: storage,
    );

    await fillLogin(tester);

    // Token disimpan di penyimpanan aman, dan profil dari balasan masuk tersimpan di cache.
    expect(storage.values[StorageKeys.token], '1|token-palsu');
    expect(storage.values[StorageKeys.userId], meId);
    expect((await h.local(EntityType.me, meId))!['name'], 'Iqbal');
    expect(h.api.requests.first.body, containsPair('email', 'nama@email.com'));
    expect(h.api.requests.first.body, contains('device_name'));
    // Database lokal akun ini masih kosong, jadi sync pertamanya penuh (tanpa since).
    expect(h.api.requests.firstWhere((request) => request.path == '/sync').query, isNull);

    // Langkah 1: Izin notifikasi, bisa dilewati.
    expect(find.text('Biar tidak ada yang terlewat'), findsOneWidget);
    await tester.tap(find.text('Lanjut'));
    await settle(tester);
    expect(storage.values[StorageKeys.notificationsOnboarded], isNotNull);

    // Langkah 2: Ajak pasangan, dengan kode undangan sendiri.
    expect(find.text('Pakai berdua, lebih ringan'), findsOneWidget);
    expect(find.text('Kode undanganmu'), findsOneWidget);
    await tester.ensureVisible(find.text('Nanti saja'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nanti saja'));
    await settle(tester);
    expect(storage.values[StorageKeys.pairingOnboarded(meId)], isNotNull);

    // Beranda.
    expect(find.text('Tugas hari ini'), findsOneWidget);
    expect(container.read(sessionProvider).isSignedIn, isTrue);

    await disposeApp(tester, h);
  });

  testWidgets('token tidak berlaku lagi (401): antrean berhenti dan layar Masuk dibuka', (tester) async {
    final h = Harness();
    await h.seed(withTask: true);
    final container = await pumpApp(tester, h);
    expect(find.text('Tugas hari ini'), findsOneWidget);

    await h.account.tasks.rename(taskId, 'Belum terkirim');
    h.api.failNext(
      apiError(401, ApiErrorCode.unauthenticated, message: 'Sesi kamu sudah berakhir. Silakan masuk lagi.'),
    );
    await h.account.outbox.flush();
    // Antrean berhenti, dan isinya tetap tersimpan untuk akun ini.
    expect(await h.ops(), hasLength(1));
    expect(await h.account.outbox.flush(), FlushState.stopped);

    // Sesi berakhir dengan sendirinya begitu server membalas 401.
    await settle(tester);
    expect(container.read(sessionProvider).expired, isTrue);

    expect(find.text('Senang melihatmu lagi.'), findsOneWidget);
    expect(find.text('Sesi kamu sudah berakhir. Silakan masuk lagi.'), findsWidgets);

    await disposeApp(tester, h);
  });

  testWidgets('keluar: peringatan kalau masih ada perubahan yang belum terkirim', (tester) async {
    final semantics = tester.ensureSemantics();
    final h = Harness();
    final storage = MemoryKeyValueStore({StorageKeys.token: '1|token-palsu', StorageKeys.userId: meId});
    await h.seed(withTask: true);
    await h.account.tasks.rename(taskId, 'Belum terkirim');
    h.api.offline = true;
    final container = await pumpApp(tester, h, storage: storage);

    expect(find.text('Sedang offline. Perubahanmu aman dan dikirim saat online.'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Buka Pengaturan'));
    await settle(tester);
    await tester.ensureVisible(find.text('Keluar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keluar'));
    await settle(tester);

    expect(find.text('Keluar dari akun ini?'), findsOneWidget);
    expect(find.textContaining('Masih ada 1 perubahan yang belum terkirim.'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Keluar'));
    await settle(tester);

    expect(h.api.log, contains('POST /auth/logout'));
    expect(container.read(sessionProvider).isSignedIn, isFalse);
    expect(storage.values.containsKey(StorageKeys.token), isFalse);
    expect(find.text('Senang melihatmu lagi.'), findsOneWidget);

    semantics.dispose();
    await disposeApp(tester, h);
  });
}
