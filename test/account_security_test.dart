import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/features/auth/data/google_accounts.dart';
import 'package:todolist/features/auth/presentation/google_sign_in_button.dart';

import 'helpers/app_harness.dart';
import 'helpers/fake_api.dart';
import 'helpers/fake_google.dart';
import 'helpers/fake_push.dart';
import 'helpers/fixtures.dart';

/// Ganti email dan kata sandi dari Pengaturan (v1.x), dan akun admin yang tidak bisa dihapus.
void main() {
  setUpAll(prepareAppTests);

  const google = GoogleIdentity(idToken: 'eyJhbGciOiJSUzI1NiJ9.palsu.tanda', email: 'iqbal@gmail.com');
  const otherGoogle = GoogleIdentity(idToken: 'token.akun.lain', email: 'lain@gmail.com');
  const wrongCode = 'Kode salah atau sudah tidak berlaku. Minta kode baru kalau perlu.';

  List<String> calls(Harness h) => [for (final request in h.api.requests) '${request.method} ${request.path}'];

  List<String> accountCalls(Harness h) => [
    for (final call in calls(h))
      if (call.contains('/me/password') || call.contains('/me/email-change')) call,
  ];

  Finder button(String label) => find.widgetWithText(FilledButton, label);

  /// Profil di HP dan di server untuk akun dari Google yang belum punya kata sandi.
  Future<void> googleOnly(Harness h) async {
    await h.account.store.write(EntityType.me, userJson(hasPassword: false));
    h.api.me = userJson(hasPassword: false);
  }

  /// Buka baris [label] di Pengaturan. Digulir sampai tombol Keluar di paling bawah dulu, supaya
  /// barisnya utuh di layar.
  Future<void> openFromSettings(WidgetTester tester, String label) async {
    await tester.scrollUntilVisible(
      find.widgetWithText(OutlinedButton, 'Keluar'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(label));
    await settle(tester);
  }

  Future<void> tapButton(WidgetTester tester, String label) async {
    await tester.ensureVisible(button(label));
    await tester.tap(button(label));
    await settle(tester);
  }

  group('lapisan data', () {
    test('ganti kata sandi: PUT /me/password dengan token FCM HP ini; akun Google ditandai punya kata sandi', () async {
      final h = Harness();
      addTearDown(h.dispose);
      await googleOnly(h);
      final profile = h.account.profile;

      await profile.changePassword(password: 'sandi-baru-123', idToken: google.idToken, fcmToken: 'fcm-hp-ini');

      expect(calls(h), ['PUT /me/password']);
      expect(h.api.requests.single.body, {
        'id_token': google.idToken,
        'password': 'sandi-baru-123',
        'fcm_token': 'fcm-hp-ini',
      });
      expect((await profile.current())!.hasPassword, isTrue);

      await profile.changePassword(currentPassword: 'sandi-baru-123', password: 'sandi-lagi-456');
      expect(h.api.requests.last.body, {'current_password': 'sandi-baru-123', 'password': 'sandi-lagi-456'});
    });

    test('ganti email: kode ke email baru, lalu profil berganti email dan sudah terverifikasi', () async {
      final h = Harness();
      addTearDown(h.dispose);
      await h.account.store.write(EntityType.me, userJson(emailVerifiedAt: null));
      h.api.me = userJson(emailVerifiedAt: null);
      final profile = h.account.profile;

      await profile.requestEmailChange(email: ' baru@email.com ', password: 'sandi-lama-123');
      await expectLater(
        profile.confirmEmailChange('111111'),
        throwsA(isA<ApiError>().having((error) => error.errors['code'], 'errors.code', [wrongCode])),
      );
      final user = await profile.confirmEmailChange(' 135790 ');

      expect(calls(h), ['POST /me/email-change', 'POST /me/email-change/confirm', 'POST /me/email-change/confirm']);
      expect(h.api.requests.first.body, {'email': 'baru@email.com', 'password': 'sandi-lama-123'});
      expect(h.api.requests.last.body, {'code': '135790'});
      expect(user.email, 'baru@email.com');
      final stored = (await profile.current())!;
      expect(stored.email, 'baru@email.com');
      expect(stored.emailVerifiedAt, isNotNull);
    });

    test('profil lama tanpa has_password dianggap punya kata sandi', () async {
      final h = Harness();
      addTearDown(h.dispose);
      await h.account.store.write(EntityType.me, userJson()..remove('has_password'));

      expect((await h.account.profile.current())!.hasPassword, isTrue);
    });
  });

  group('Pengaturan', () {
    testWidgets('bagian Akun dan data: email sekarang, dan "Buat kata sandi" untuk akun tanpa kata sandi', (
      tester,
    ) async {
      final h = Harness();
      await h.seed();
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.settings);
      await settle(tester);
      await tester.scrollUntilVisible(find.text('Ganti kata sandi'), 300, scrollable: find.byType(Scrollable).first);

      expect(find.text('Akun dan data'), findsOneWidget);
      expect(find.text('Ganti email'), findsOneWidget);
      expect(find.text('nama@email.com'), findsOneWidget);
      expect(find.text('Akunmu otomatis keluar dari HP lain'), findsOneWidget);

      await h.account.store.write(EntityType.me, userJson(hasPassword: false));
      await settle(tester);
      expect(find.text('Ganti kata sandi'), findsNothing);
      expect(find.text('Buat kata sandi'), findsOneWidget);
      expect(find.text('Supaya bisa masuk dengan email juga, tanpa Google'), findsOneWidget);

      await disposeApp(tester, h);
    });
  });

  group('Ganti kata sandi', () {
    testWidgets('isian diperiksa di HP, kata sandi salah dari server, lalu berhasil dengan token FCM HP ini', (
      tester,
    ) async {
      final h = Harness();
      await h.seed();
      final push = FakePushService(fcmToken: 'fcm-hp-ini');
      final container = await pumpApp(tester, h, push: push);
      container.read(routerProvider).go(Routes.settings);
      await settle(tester);
      await openFromSettings(tester, 'Ganti kata sandi');

      expect(find.text('Setelah diganti, akunmu keluar dari HP lain. HP ini tetap masuk.'), findsOneWidget);
      final fields = find.byType(TextField);

      await tapButton(tester, 'Simpan kata sandi baru');
      expect(find.text('Kata sandi belum diisi.'), findsNWidgets(2));

      await tester.enterText(fields.at(0), 'salah-sandi');
      await tester.enterText(fields.at(1), 'pendek');
      await tapButton(tester, 'Simpan kata sandi baru');
      expect(find.text('Kata sandi minimal 8 karakter.'), findsOneWidget);
      expect(accountCalls(h), isEmpty);

      await tester.enterText(fields.at(1), 'sandi-baru-123');
      await tapButton(tester, 'Simpan kata sandi baru');
      expect(find.text('Kata sandi saat ini salah.'), findsOneWidget);

      await tester.enterText(fields.at(0), 'sandi-lama-123');
      await tapButton(tester, 'Simpan kata sandi baru');

      expect(h.api.requests.last.body, {
        'current_password': 'sandi-lama-123',
        'password': 'sandi-baru-123',
        'fcm_token': 'fcm-hp-ini',
      });
      expect(find.text('Kata sandi baru tersimpan. Akunmu sudah keluar dari HP lain.'), findsOneWidget);
      // Kembali ke Pengaturan.
      expect(find.text('Akunmu otomatis keluar dari HP lain'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('terlalu sering (429): menit dari Retry-After', (tester) async {
      final h = Harness();
      await h.seed();
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.changePassword);
      await settle(tester);

      h.api.failNext(
        apiError(
          429,
          ApiErrorCode.tooManyRequests,
          message: 'Terlalu banyak percobaan.',
          retryAfter: const Duration(minutes: 14, seconds: 10),
        ),
      );
      await tester.enterText(find.byType(TextField).at(0), 'sandi-lama-123');
      await tester.enterText(find.byType(TextField).at(1), 'sandi-baru-123');
      await tapButton(tester, 'Simpan kata sandi baru');

      expect(find.text('Kata sandi sudah beberapa kali diganti. Coba lagi sekitar 15 menit lagi.'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('akun dari Google: "Buat kata sandi" dikonfirmasi dengan akun Google yang tersambung', (tester) async {
      final h = Harness();
      await h.seed();
      await googleOnly(h);
      final accounts = FakeGoogleAccounts([null, otherGoogle, google]);
      final container = await pumpApp(tester, h, google: accounts);
      container.read(routerProvider).go(Routes.changePassword);
      await settle(tester);

      expect(find.text('Buat kata sandi'), findsOneWidget);
      expect(
        find.text(
          'Akunmu dibuat lewat Google. Buat kata sandi supaya bisa masuk dengan nama@email.com dan kata sandi '
          'juga. Setelah itu, akunmu keluar dari HP lain, dan HP ini tetap masuk.',
        ),
        findsOneWidget,
      );
      expect(find.text('Kata sandi saat ini'), findsNothing);

      Future<void> continueWithGoogle() async {
        await tester.ensureVisible(find.byType(GoogleSignInButton));
        await tester.tap(find.byType(GoogleSignInButton));
        await settle(tester);
      }

      // Kata sandi baru diperiksa dulu, sebelum pilihan akun dibuka.
      await continueWithGoogle();
      expect(find.text('Kata sandi belum diisi.'), findsOneWidget);
      expect(accounts.picks, 0);

      await tester.enterText(find.byType(TextField), 'sandi-baru-123');
      // Pilihan akun ditutup: tidak terjadi apa-apa.
      await continueWithGoogle();
      expect(accountCalls(h), isEmpty);

      await continueWithGoogle();
      expect(find.text('Pilih akun Google yang tersambung ke akun ini.'), findsNWidgets(2));

      await continueWithGoogle();
      expect(h.api.requests.last.body, {'id_token': google.idToken, 'password': 'sandi-baru-123'});
      expect(
        find.text('Kata sandi tersimpan. Sekarang kamu juga bisa masuk dengan email dan kata sandi.'),
        findsOneWidget,
      );
      expect((await h.account.profile.current())!.hasPassword, isTrue);

      await disposeApp(tester, h);
    });
  });

  group('Ganti email', () {
    testWidgets('email baru dan kata sandi, lalu kode dari email baru', (tester) async {
      final h = Harness();
      await h.seed();
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.settings);
      await settle(tester);
      await openFromSettings(tester, 'Ganti email');

      expect(
        find.text(
          'Email akunmu sekarang nama@email.com. Kami kirim kode 6 angka ke email baru untuk memastikan alamatnya '
          'benar.',
        ),
        findsOneWidget,
      );
      final email = find.byType(TextField).at(0);
      final password = find.byType(TextField).at(1);

      // Diperiksa di HP: format email, email yang sama, dan kata sandi kosong.
      await tester.enterText(email, 'baru@email');
      await tapButton(tester, 'Kirim kode');
      expect(find.text('Tulis email yang benar, misalnya nama@email.com.'), findsOneWidget);
      expect(find.text('Kata sandi belum diisi.'), findsOneWidget);

      await tester.enterText(email, 'Nama@Email.com');
      await tester.enterText(password, 'sandi-lama-123');
      await tapButton(tester, 'Kirim kode');
      expect(find.text('Email baru sama dengan email sekarang.'), findsOneWidget);
      expect(accountCalls(h), isEmpty);

      // Dari server: email yang sudah dipakai, lalu kata sandi salah.
      await tester.enterText(email, 'dipakai@email.com');
      await tapButton(tester, 'Kirim kode');
      expect(find.text('Email ini sudah dipakai akun lain.'), findsOneWidget);

      await tester.enterText(email, 'baru@email.com');
      await tester.enterText(password, 'salah-sandi');
      await tapButton(tester, 'Kirim kode');
      expect(find.text('Kata sandi salah.'), findsOneWidget);

      await tester.enterText(password, 'sandi-lama-123');
      await tapButton(tester, 'Kirim kode');
      expect(find.text('Kode sudah dikirim ke baru@email.com. Cek juga folder spam.'), findsOneWidget);
      expect(find.text('Kata sandi'), findsNothing);
      expect(h.api.requests.last.body, {'email': 'baru@email.com', 'password': 'sandi-lama-123'});

      // Kirim ulang memakai kata sandi yang sama.
      await tester.tap(find.text('Kirim ulang kode'));
      await settle(tester);
      expect(accountCalls(h).where((call) => call == 'POST /me/email-change'), hasLength(4));
      expect(h.api.requests.last.body, {'email': 'baru@email.com', 'password': 'sandi-lama-123'});

      final code = find.byType(TextField).at(1);
      await tester.enterText(code, '12');
      await tapButton(tester, 'Ganti email');
      expect(find.text('Kodenya 6 angka, sesuai email yang kami kirim.'), findsOneWidget);

      await tester.enterText(code, '111111');
      await tapButton(tester, 'Ganti email');
      expect(find.text(wrongCode), findsOneWidget);

      await tester.enterText(code, '135790');
      await tapButton(tester, 'Ganti email');

      expect(find.text('Email akunmu sekarang baru@email.com.'), findsOneWidget);
      expect((await h.account.profile.current())!.email, 'baru@email.com');
      await tester.scrollUntilVisible(find.text('Ganti email'), 300, scrollable: find.byType(Scrollable).first);
      expect(find.text('baru@email.com'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('akun dari Google: konfirmasi lewat Google; token yang ditolak saat kirim ulang mengulang dari awal', (
      tester,
    ) async {
      final h = Harness();
      await h.seed();
      await googleOnly(h);
      final accounts = FakeGoogleAccounts([google]);
      final container = await pumpApp(tester, h, google: accounts);
      container.read(routerProvider).go(Routes.changeEmail);
      await settle(tester);

      expect(find.text('Masuk dengan Google tetap memakai akun Google yang sama.'), findsOneWidget);
      expect(find.text('Kata sandi'), findsNothing);

      await tester.enterText(find.byType(TextField), 'baru@email.com');
      await tester.ensureVisible(find.byType(GoogleSignInButton));
      await tester.tap(find.byType(GoogleSignInButton));
      await settle(tester);

      expect(h.api.requests.last.body, {'email': 'baru@email.com', 'id_token': google.idToken});
      expect(find.text('Kode sudah dikirim ke baru@email.com. Cek juga folder spam.'), findsOneWidget);

      // Token Google sudah kedaluwarsa saat kirim ulang: kembali ke konfirmasi dengan pesannya.
      h.api.googleIdToken = 'token.baru';
      await tester.tap(find.text('Kirim ulang kode'));
      await settle(tester);
      expect(find.byType(GoogleSignInButton), findsOneWidget);
      expect(find.text('Pilih akun Google yang tersambung ke akun ini.'), findsNWidgets(2));

      await disposeApp(tester, h);
    });

    testWidgets('terlalu sering meminta kode (429) dan akun admin', (tester) async {
      final h = Harness();
      await h.seed();
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.changeEmail);
      await settle(tester);

      await tester.enterText(find.byType(TextField).at(0), 'baru@email.com');
      await tester.enterText(find.byType(TextField).at(1), 'sandi-lama-123');
      h.api.failNext(
        apiError(
          429,
          ApiErrorCode.tooManyRequests,
          message: 'Terlalu banyak permintaan.',
          retryAfter: const Duration(minutes: 9),
        ),
      );
      await tapButton(tester, 'Kirim kode');
      expect(find.text('Kode sudah beberapa kali diminta. Coba lagi sekitar 9 menit lagi.'), findsOneWidget);

      h.api.admin = true;
      await tapButton(tester, 'Kirim kode');
      expect(find.text('Email akun admin hanya bisa diganti lewat server.'), findsOneWidget);

      await disposeApp(tester, h);
    });
  });

  testWidgets('Hapus akun: akun admin ditolak dengan pesan dari server', (tester) async {
    final h = Harness();
    await h.seed();
    h.api.admin = true;
    final files = FakeAccountFiles();
    final container = await pumpApp(tester, h, accountFiles: files);
    container.read(routerProvider).go(Routes.deleteAccount);
    await settle(tester);

    await tester.enterText(find.byType(TextField), 'sandi-lama-123');
    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Hapus akun'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Hapus akun'));
    await settle(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Hapus akun'));
    await settle(tester);

    expect(find.text('Akun admin hanya bisa dihapus lewat server.'), findsOneWidget);
    expect(files.deleted, isEmpty);

    await disposeApp(tester, h);
  });
}
