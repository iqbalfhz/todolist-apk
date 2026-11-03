import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/core/session/session.dart';
import 'package:todolist/core/storage/key_value_store.dart';
import 'package:todolist/features/auth/data/auth_repository.dart';

import 'helpers/app_harness.dart';
import 'helpers/fixtures.dart';

/// Lupa kata sandi dan verifikasi email (v1.0).
void main() {
  setUpAll(prepareAppTests);

  const sent = 'Kalau email itu terdaftar, kode sudah dikirim. Cek juga folder spam.';
  const wrongCode = 'Kode salah atau sudah tidak berlaku. Minta kode baru kalau perlu.';
  const codeFormat = 'Kodenya 6 angka, sesuai email yang kami kirim.';

  List<String> calls(Harness h) => [for (final request in h.api.requests) '${request.method} ${request.path}'];

  Finder button(String label) => find.widgetWithText(FilledButton, label);

  /// Profil di HP dan di server yang emailnya belum diverifikasi.
  Future<void> unverified(Harness h) async {
    await h.account.store.write(EntityType.me, userJson(emailVerifiedAt: null));
    h.api.me = userJson(emailVerifiedAt: null);
  }

  group('lapisan data', () {
    test('lupa kata sandi: minta kode, lalu atur ulang dengan kode 6 angka; balasannya seperti masuk', () async {
      final h = Harness();
      addTearDown(h.dispose);
      h.api.me = userJson();
      final auth = AuthRepository(h.api);

      await auth.forgotPassword(' nama@email.com ');
      final result = await auth.resetPassword(
        email: 'nama@email.com',
        code: ' 482913 ',
        password: 'sandi-baru-123',
        deviceName: 'Redmi Note 14',
      );

      expect(calls(h), ['POST /auth/forgot-password', 'POST /auth/reset-password']);
      expect(h.api.requests.first.body, {'email': 'nama@email.com'});
      expect(h.api.requests.last.body, {
        'email': 'nama@email.com',
        'code': '482913',
        'password': 'sandi-baru-123',
        'device_name': 'Redmi Note 14',
      });
      expect((result.token, result.user.id), ('1|token-palsu', meId));

      await expectLater(
        auth.resetPassword(email: 'nama@email.com', code: '111111', password: 'sandi-baru-123', deviceName: 'x'),
        throwsA(isA<ApiError>().having((error) => error.errors['code'], 'errors.code', [wrongCode])),
      );
    });

    test('verifikasi email: 202 berarti kode terkirim, kode benar mengisi email_verified_at', () async {
      final h = Harness();
      addTearDown(h.dispose);
      await h.seed();
      await unverified(h);
      final profile = h.account.profile;

      expect(await profile.requestEmailVerification(), isTrue);
      await expectLater(profile.confirmEmailVerification('111111'), throwsA(isA<ApiError>()));
      expect((await profile.current())!.emailVerifiedAt, isNull);

      final user = await profile.confirmEmailVerification(' 135790 ');
      expect(calls(h), [
        'POST /me/email-verification',
        'POST /me/email-verification/confirm',
        'POST /me/email-verification/confirm',
      ]);
      expect(h.api.requests.last.body, {'code': '135790'});
      expect(user.emailVerifiedAt, isNotNull);
      expect((await profile.current())!.emailVerifiedAt, user.emailVerifiedAt);
    });

    test('verifikasi email: 204 berarti sudah terverifikasi, lalu profil diambil ulang', () async {
      final h = Harness();
      addTearDown(h.dispose);
      await h.seed();
      // Di HP masih belum, padahal di server sudah (misalnya lewat atur ulang kata sandi di HP lain).
      await h.account.store.write(EntityType.me, userJson(emailVerifiedAt: null));

      expect(await h.account.profile.requestEmailVerification(), isFalse);
      expect(calls(h), ['POST /me/email-verification', 'GET /me']);
      expect((await h.account.profile.current())!.emailVerifiedAt, isNotNull);
    });
  });

  group('layar Lupa kata sandi', () {
    testWidgets('dari Masuk: email ikut, kode diminta, lalu kata sandi baru langsung masuk ke Beranda', (tester) async {
      final h = Harness();
      final storage = MemoryKeyValueStore({StorageKeys.pairingOnboarded(meId): '1'});
      h.api
        ..me = userJson()
        ..spaces = [personalSpaceJson()]
        ..syncPages.add(
          h.api.syncPage(
            spaces: [personalSpaceJson()],
            taskLists: [listJson(spaceId: personalSpaceId, name: 'Tugas')],
          ),
        );
      final container = await pumpApp(tester, h, signedIn: false, storage: storage);

      await tester.enterText(find.byType(TextField).first, ' nama@email.com');
      await tester.tap(find.text('Lupa kata sandi?'));
      await settle(tester);

      expect(find.text('Lupa kata sandi'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'nama@email.com');

      await tester.tap(button('Kirim kode'));
      await settle(tester);
      expect(find.text(sent), findsOneWidget);
      expect(calls(h), ['POST /auth/forgot-password']);
      expect(h.api.requests.single.body, {'email': 'nama@email.com'});

      // Diperiksa di HP dulu: kode 6 angka dan kata sandi minimal 8 karakter.
      final code = find.byType(TextField).at(1);
      final password = find.byType(TextField).at(2);
      await tester.tap(button('Simpan kata sandi baru'));
      await settle(tester);
      expect(find.text(codeFormat), findsOneWidget);
      expect(find.text('Kata sandi belum diisi.'), findsOneWidget);

      // Isian kode hanya menerima angka, paling banyak 6.
      await tester.enterText(code, '48-29a13999');
      expect(tester.widget<TextField>(code).controller!.text, '482913');
      await tester.enterText(code, '4829');
      await tester.enterText(password, 'pendek');
      await tester.tap(button('Simpan kata sandi baru'));
      await settle(tester);
      expect(find.text(codeFormat), findsOneWidget);
      expect(find.text('Kata sandi minimal 8 karakter.'), findsOneWidget);
      expect(calls(h), hasLength(1));

      // Kode salah: pesan server di bawah isian kode, tetap belum masuk.
      await tester.enterText(code, '111111');
      await tester.enterText(password, 'sandi-baru-123');
      await tester.tap(button('Simpan kata sandi baru'));
      await settle(tester);
      expect(find.text(wrongCode), findsOneWidget);
      expect(container.read(sessionProvider).isSignedIn, isFalse);

      await tester.enterText(code, '482913');
      await tester.tap(button('Simpan kata sandi baru'));
      await settle(tester);

      final reset = h.api.requests.lastWhere((request) => request.path == '/auth/reset-password');
      expect(reset.body, containsPair('code', '482913'));
      expect(reset.body, containsPair('password', 'sandi-baru-123'));
      expect(reset.body, contains('device_name'));
      expect(storage.values[StorageKeys.token], '1|token-palsu');
      expect(container.read(sessionProvider).isSignedIn, isTrue);
      expect(find.text('Kata sandi baru tersimpan, dan kamu sudah masuk.'), findsOneWidget);
      expect(find.text('Tugas hari ini'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('email diperiksa di HP; tanpa koneksi dan terlalu sering diberi tahu; Kembali ke Masuk', (
      tester,
    ) async {
      final h = Harness();
      await pumpApp(tester, h, signedIn: false);

      await tester.tap(find.text('Lupa kata sandi?'));
      await settle(tester);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);

      await tester.tap(button('Kirim kode'));
      await settle(tester);
      expect(find.text('Tulis email yang benar, misalnya nama@email.com.'), findsOneWidget);
      expect(h.api.requests, isEmpty);

      await tester.enterText(find.byType(TextField), 'nama@email.com');
      h.api.failNext(const NetworkFailure());
      await tester.tap(button('Kirim kode'));
      await settle(tester);
      expect(find.text('Butuh koneksi internet. Coba lagi saat online.'), findsOneWidget);
      expect(find.text(sent), findsNothing);

      // Batasnya per 15 menit atau per jam, jadi menitnya disebut dari Retry-After.
      h.api.failNext(
        const ApiError(
          status: 429,
          code: ApiErrorCode.tooManyRequests,
          message: 'Terlalu sering. Coba lagi sebentar lagi.',
          retryAfter: Duration(seconds: 610),
        ),
      );
      await tester.tap(button('Kirim kode'));
      await settle(tester);
      expect(find.text('Kode sudah beberapa kali diminta. Coba lagi sekitar 11 menit lagi.'), findsOneWidget);
      expect(find.text('Butuh koneksi internet. Coba lagi saat online.'), findsNothing);

      await tester.tap(find.byTooltip('Kembali'));
      await settle(tester);
      expect(find.text('Senang melihatmu lagi.'), findsOneWidget);

      // Tombol kembali Android juga ke layar Masuk, bukan menutup app.
      await tester.tap(find.text('Lupa kata sandi?'));
      await settle(tester);
      expect(await tester.binding.handlePopRoute(), isTrue);
      await settle(tester);
      expect(find.text('Senang melihatmu lagi.'), findsOneWidget);
      expect(find.text('Lupa kata sandi'), findsNothing);

      await disposeApp(tester, h);
    });

    testWidgets('Kirim ulang kode meminta kode baru untuk email yang sama', (tester) async {
      final h = Harness();
      final container = await pumpApp(tester, h, signedIn: false);
      container.read(routerProvider).go(Routes.forgotPasswordFor('nama@email.com'));
      await settle(tester);

      await tester.tap(button('Kirim kode'));
      await settle(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Kirim ulang kode'));
      await settle(tester);

      expect(calls(h), ['POST /auth/forgot-password', 'POST /auth/forgot-password']);
      expect(find.text(sent), findsOneWidget);

      await disposeApp(tester, h);
    });
  });

  group('verifikasi email di Pengaturan', () {
    Future<void> openSettings(WidgetTester tester, Harness h) async {
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.settings);
      await settle(tester);
    }

    testWidgets('sudah terverifikasi: tidak ada ajakan', (tester) async {
      final h = Harness();
      await h.seed();
      await openSettings(tester, h);

      expect(find.text('Verifikasi email'), findsNothing);
      expect(find.text('Profil'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('belum: ajakan di atas, kirim kode, kode salah, lalu kode benar menghilangkan ajakan', (tester) async {
      final h = Harness();
      await h.seed();
      await unverified(h);
      await openSettings(tester, h);

      expect(find.text('Verifikasi email'), findsOneWidget);
      expect(find.text('nama@email.com belum diverifikasi.'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Verifikasi'));
      await settle(tester);
      expect(find.text('Kami kirim kode 6 angka ke nama@email.com.'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      await tester.tap(button('Kirim kode'));
      await settle(tester);
      expect(find.text('Kode sudah dikirim ke nama@email.com. Cek juga folder spam.'), findsOneWidget);
      expect(calls(h), contains('POST /me/email-verification'));

      await tester.tap(button('Verifikasi'));
      await settle(tester);
      expect(find.text(codeFormat), findsOneWidget);
      expect(calls(h), isNot(contains('POST /me/email-verification/confirm')));

      await tester.enterText(find.byType(TextField), '111111');
      await tester.tap(button('Verifikasi'));
      await settle(tester);
      expect(find.text(wrongCode), findsOneWidget);
      expect(find.text('nama@email.com belum diverifikasi.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '135790');
      await tester.tap(button('Verifikasi'));
      await settle(tester);

      expect(h.api.requests.last.body, {'code': '135790'});
      expect(find.text('Email sudah terverifikasi.'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Verifikasi email'), findsNothing);
      expect((await h.account.profile.current())!.emailVerifiedAt, isNotNull);

      await disposeApp(tester, h);
    });

    testWidgets('ternyata sudah terverifikasi (204): lembar ditutup dan ajakan hilang', (tester) async {
      final h = Harness();
      await h.seed();
      await unverified(h);
      await openSettings(tester, h);

      await tester.tap(find.widgetWithText(TextButton, 'Verifikasi'));
      await settle(tester);
      // Sementara itu emailnya terverifikasi lewat HP lain.
      h.api.me = userJson();
      await tester.tap(button('Kirim kode'));
      await settle(tester);

      expect(find.text('Email ini ternyata sudah terverifikasi.'), findsOneWidget);
      expect(find.text('Verifikasi email'), findsNothing);

      await disposeApp(tester, h);
    });

    testWidgets('terlalu sering minta kode: menitnya disebut, lembar tetap terbuka', (tester) async {
      final h = Harness();
      await h.seed();
      await unverified(h);
      await openSettings(tester, h);

      await tester.tap(find.widgetWithText(TextButton, 'Verifikasi'));
      await settle(tester);
      h.api.failNext(
        const ApiError(
          status: 429,
          code: ApiErrorCode.tooManyRequests,
          message: 'Terlalu sering. Coba lagi sebentar lagi.',
          retryAfter: Duration(minutes: 14, seconds: 5),
        ),
      );
      await tester.tap(button('Kirim kode'));
      await settle(tester);

      expect(find.text('Kode sudah beberapa kali diminta. Coba lagi sekitar 15 menit lagi.'), findsOneWidget);
      expect(button('Kirim kode'), findsOneWidget);

      await disposeApp(tester, h);
    });
  });
}
