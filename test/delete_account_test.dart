import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/core/session/session.dart';
import 'package:todolist/core/storage/key_value_store.dart';
import 'package:todolist/features/auth/data/auth_repository.dart';
import 'package:todolist/features/auth/data/google_accounts.dart';
import 'package:todolist/features/auth/presentation/google_sign_in_button.dart';

import 'helpers/app_harness.dart';
import 'helpers/fake_api.dart';
import 'helpers/fake_google.dart';
import 'helpers/fake_push.dart';
import 'helpers/fixtures.dart';

/// Hapus akun (v1.0).
void main() {
  setUpAll(prepareAppTests);

  const sari = GoogleIdentity(idToken: 'eyJhbGciOiJSUzI1NiJ9.palsu.tanda', email: 'iqbal@gmail.com');
  const done = 'Akunmu sudah dihapus beserta semua datanya.';

  List<String> deletes(Harness h) => [
    for (final request in h.api.requests)
      if (request.method == 'DELETE') request.path,
  ];

  test('DELETE /me dengan kata sandi atau ID token Google', () async {
    final h = Harness();
    addTearDown(h.dispose);
    final auth = AuthRepository(h.api);

    await auth.deleteAccount(password: 'rahasia-banget');
    await auth.deleteAccount(idToken: 'id-token');

    expect([for (final request in h.api.requests) '${request.method} ${request.path}'], ['DELETE /me', 'DELETE /me']);
    expect(h.api.requests.first.body, {'password': 'rahasia-banget'});
    expect(h.api.requests.last.body, {'id_token': 'id-token'});
  });

  group('layar Hapus akun', () {
    testWidgets('dari Pengaturan: akibatnya disebut, kata sandi diperiksa, lalu semua data di HP dihapus', (
      tester,
    ) async {
      final h = Harness();
      await h.seed(withTask: true);
      final storage = MemoryKeyValueStore({StorageKeys.pairingOnboarded(meId): '1'});
      final push = FakePushService();
      final files = FakeAccountFiles();
      final container = await pumpApp(tester, h, storage: storage, push: push, accountFiles: files);

      container.read(routerProvider).go(Routes.settings);
      await settle(tester);
      await tester.scrollUntilVisible(
        find.text('Hapus permanen akun dan semua datamu'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Hapus permanen akun dan semua datamu'));
      await settle(tester);

      expect(find.text('Semua datamu dihapus permanen dan tidak bisa dibatalkan.'), findsOneWidget);
      expect(find.text('Ruang Bersama ditutup, dan isinya beserta foto ikut terhapus untuk Sari.'), findsOneWidget);

      // Kata sandi kosong diperiksa di HP; yang salah dari server.
      Future<void> submit() async {
        await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Hapus akun'));
        await tester.tap(find.widgetWithText(OutlinedButton, 'Hapus akun'));
        await settle(tester);
      }

      await submit();
      expect(find.text('Kata sandi belum diisi.'), findsOneWidget);
      expect(deletes(h), isEmpty);

      await tester.enterText(find.byType(TextField), 'salah-sandi');
      await submit();
      expect(find.text('Hapus akun sekarang?'), findsOneWidget);
      h.api.failNext(apiError(422, ApiErrorCode.invalidCredentials, message: 'Kata sandi salah.'));
      await tester.tap(find.widgetWithText(TextButton, 'Hapus akun'));
      await settle(tester);
      expect(find.text('Kata sandi salah.'), findsOneWidget);
      expect(files.deleted, isEmpty);

      // Batal di konfirmasi: tidak ada yang dikirim.
      await tester.enterText(find.byType(TextField), 'rahasia-banget');
      await submit();
      await tester.tap(find.text('Batal'));
      await settle(tester);
      expect(deletes(h), ['/me']);

      await submit();
      await tester.tap(find.widgetWithText(TextButton, 'Hapus akun'));
      await settle(tester);

      expect(h.api.requests.last.body, {'password': 'rahasia-banget'});
      expect(find.text('Senang melihatmu lagi.'), findsOneWidget);
      expect(find.text(done), findsOneWidget);
      expect(find.text('Sesi kamu sudah berakhir. Silakan masuk lagi.'), findsNothing);
      expect(container.read(sessionProvider).isSignedIn, isFalse);
      expect(storage.values[StorageKeys.token], isNull);
      expect(storage.values[StorageKeys.pairingOnboarded(meId)], isNull);
      expect(push.tokenDeleted, isTrue);
      expect(files.deleted, [meId]);

      await disposeApp(tester, h);
    });

    testWidgets('dengan akun Google: emailnya disebut di konfirmasi; akun Google lain ditolak', (tester) async {
      final h = Harness();
      await h.seed();
      final files = FakeAccountFiles();
      final google = FakeGoogleAccounts([sari, sari]);
      final container = await pumpApp(tester, h, google: google, accountFiles: files);
      container.read(routerProvider).go(Routes.deleteAccount);
      await settle(tester);

      Future<void> viaGoogle() async {
        await tester.ensureVisible(find.byType(GoogleSignInButton));
        await tester.tap(find.byType(GoogleSignInButton));
        await settle(tester);
        expect(
          find.text(
            'Akun yang tersambung ke iqbal@gmail.com beserta semua datanya dihapus permanen. Ini tidak bisa dibatalkan.',
          ),
          findsOneWidget,
        );
        await tester.tap(find.widgetWithText(TextButton, 'Hapus akun'));
        await settle(tester);
      }

      h.api.failNext(
        apiError(422, ApiErrorCode.googleTokenInvalid, message: 'Pilih akun Google yang tersambung ke akun ini.'),
      );
      await viaGoogle();
      expect(find.text('Pilih akun Google yang tersambung ke akun ini.'), findsOneWidget);
      expect(container.read(sessionProvider).isSignedIn, isTrue);

      await viaGoogle();
      expect(h.api.requests.last.body, {'id_token': sari.idToken});
      expect(find.text(done), findsOneWidget);
      expect(files.deleted, [meId]);

      await disposeApp(tester, h);
    });

    testWidgets('balasan 204 hilang: kiriman ulang yang dibalas 401 berarti akunnya sudah terhapus', (tester) async {
      final h = Harness();
      await h.seed();
      final files = FakeAccountFiles();
      final container = await pumpApp(tester, h, accountFiles: files);
      container.read(routerProvider).go(Routes.deleteAccount);
      await settle(tester);

      Future<void> delete() async {
        await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Hapus akun'));
        await tester.tap(find.widgetWithText(OutlinedButton, 'Hapus akun'));
        await settle(tester);
        await tester.tap(find.widgetWithText(TextButton, 'Hapus akun'));
        await settle(tester);
      }

      await tester.enterText(find.byType(TextField), 'rahasia-banget');
      h.api.failNext(const NetworkFailure());
      await delete();
      expect(find.text('Butuh koneksi internet. Coba lagi saat online.'), findsOneWidget);
      expect(files.deleted, isEmpty);

      h.api.failNext(apiError(401, ApiErrorCode.unauthenticated, message: 'Sesi berakhir.'));
      await delete();
      expect(find.text(done), findsOneWidget);
      expect(find.text('Sesi kamu sudah berakhir. Silakan masuk lagi.'), findsNothing);
      expect(files.deleted, [meId]);

      await disposeApp(tester, h);
    });

    testWidgets('401 tanpa permintaan hapus sebelumnya: sesi berakhir biasa, data di HP tetap', (tester) async {
      final h = Harness();
      await h.seed();
      final files = FakeAccountFiles();
      final container = await pumpApp(tester, h, accountFiles: files);
      container.read(routerProvider).go(Routes.deleteAccount);
      await settle(tester);

      await tester.enterText(find.byType(TextField), 'rahasia-banget');
      h.api.failNext(apiError(401, ApiErrorCode.unauthenticated, message: 'Sesi berakhir.'));
      await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Hapus akun'));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Hapus akun'));
      await settle(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Hapus akun'));
      await settle(tester);

      expect(find.text('Sesi kamu sudah berakhir. Silakan masuk lagi.'), findsWidgets);
      expect(find.text(done), findsNothing);
      expect(files.deleted, isEmpty);

      await disposeApp(tester, h);
    });
  });
}
