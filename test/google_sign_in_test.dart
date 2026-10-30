import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/platform/device_platform.dart';
import 'package:todolist/core/session/session.dart';
import 'package:todolist/core/storage/key_value_store.dart';
import 'package:todolist/core/theme/app_palette.dart';
import 'package:todolist/features/auth/data/auth_repository.dart';
import 'package:todolist/features/auth/data/google_accounts.dart';
import 'package:todolist/features/auth/presentation/google_sign_in_button.dart';

import 'helpers/app_harness.dart';
import 'helpers/fake_api.dart';
import 'helpers/fake_google.dart';
import 'helpers/fixtures.dart';

/// Masuk dengan Google (v1.x).
void main() {
  setUpAll(prepareAppTests);

  const sari = GoogleIdentity(idToken: 'eyJhbGciOiJSUzI1NiJ9.palsu.tanda', email: 'sari@gmail.com');
  const redmi = DeviceInfo(manufacturer: 'Xiaomi', brand: 'Redmi', model: 'Redmi Note 14 Pro+ 5G', sdkInt: 35);

  Finder googleButton(String label) => find.widgetWithText(GoogleSignInButton, label);

  Map<String, dynamic> signedIn({String name = 'Iqbal'}) => {
    'data': {'token': '1|token-palsu', 'user': userJson(name: name)},
  };

  /// Isi cache seperti sync pertama akun yang baru dibuat: Ruang Pribadi dengan daftar "Tugas".
  void newAccountSync(FakeApi api) => api
    ..spaces = [personalSpaceJson()]
    ..syncPages.add(
      api.syncPage(
        spaces: [personalSpaceJson()],
        taskLists: [listJson(spaceId: personalSpaceId, name: 'Tugas')],
      ),
    );

  bool googleEnabled(WidgetTester tester) =>
      tester.widget<GoogleSignInButton>(find.byType(GoogleSignInButton)).onPressed != null;

  group('lapisan data', () {
    test('POST /auth/google: 201 berarti akun baru, 200 akun yang sudah ada', () async {
      final h = Harness();
      addTearDown(h.dispose);
      h.api
        ..enqueue((_) => ApiResponse(status: 201, body: signedIn(name: 'Sari')))
        ..enqueue((_) => ApiResponse(status: 200, body: signedIn()));
      final auth = AuthRepository(h.api);

      final created = await auth.signInWithGoogle(
        idToken: 'id-token',
        deviceName: redmi.name,
        timezone: 'Asia/Makassar',
      );
      expect(created.created, isTrue);
      expect((created.result.token, created.result.user.name), ('1|token-palsu', 'Sari'));
      final request = h.api.requests.single;
      expect('${request.method} ${request.path}', 'POST /auth/google');
      expect(request.body, {'id_token': 'id-token', 'device_name': redmi.name, 'timezone': 'Asia/Makassar'});

      final existing = await auth.signInWithGoogle(idToken: 'id-token', deviceName: redmi.name);
      expect(existing.created, isFalse);
      expect(h.api.requests.last.body, containsPair('timezone', null));
    });
  });

  group('layar Masuk', () {
    testWidgets('akun yang sudah ada: pilih akun Google, tukar tokennya, lalu Beranda', (tester) async {
      final h = Harness();
      // Akun ini sudah pernah melewati Ajak pasangan di HP ini.
      final storage = MemoryKeyValueStore({StorageKeys.pairingOnboarded(meId): '1'});
      final google = FakeGoogleAccounts([sari]);
      h.api.me = userJson();
      newAccountSync(h.api);
      final container = await pumpApp(tester, h, signedIn: false, storage: storage, device: redmi, google: google);

      expect(find.text('atau'), findsOneWidget);
      await tester.tap(googleButton('Masuk dengan Google'));
      await settle(tester);

      expect(google.picks, 1);
      final request = h.api.requests.first;
      expect('${request.method} ${request.path}', 'POST /auth/google');
      expect(request.body, containsPair('id_token', sari.idToken));
      expect(request.body, containsPair('device_name', redmi.name));
      expect(request.body, contains('timezone'));
      expect(storage.values[StorageKeys.token], '1|token-palsu');
      expect(container.read(sessionProvider).isSignedIn, isTrue);
      expect(find.text('Tugas hari ini'), findsOneWidget);
      expect(find.textContaining('Akun baru dibuat'), findsNothing);

      await disposeApp(tester, h);
    });

    testWidgets('akun baru (201): emailnya disebut, lalu alur pertama kali', (tester) async {
      final h = Harness();
      h.api.me = userJson(name: 'Sari');
      newAccountSync(h.api);
      h.api.enqueue(
        (request) => request.path == '/auth/google'
            ? ApiResponse(status: 201, body: signedIn(name: 'Sari'))
            : h.api.handle(request),
      );
      await pumpApp(tester, h, signedIn: false, pairingDone: false, google: FakeGoogleAccounts([sari]));

      await tester.tap(googleButton('Masuk dengan Google'));
      await settle(tester);

      expect(find.text('Akun baru dibuat untuk sari@gmail.com.'), findsOneWidget);
      expect(find.text('Pakai berdua, lebih ringan'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('selama ditukar di server: akun Google yang dipakai disebut, lalu pesan error dari server', (
      tester,
    ) async {
      final h = Harness();
      final reply = Completer<ApiResponse>();
      h.api.enqueue((_) => reply.future);
      await pumpApp(tester, h, signedIn: false, google: FakeGoogleAccounts([sari]));

      await tester.tap(googleButton('Masuk dengan Google'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Memakai akun Google sari@gmail.com…'), findsOneWidget);
      expect(googleEnabled(tester), isFalse);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Masuk')).onPressed, isNull);

      reply.completeError(
        apiError(422, ApiErrorCode.googleTokenInvalid, message: 'Email akun Google ini belum terverifikasi.'),
      );
      await settle(tester);
      expect(find.text('Email akun Google ini belum terverifikasi.'), findsOneWidget);
      expect(find.textContaining('Memakai akun Google'), findsNothing);
      expect(find.text('Senang melihatmu lagi.'), findsOneWidget);
      expect(googleEnabled(tester), isTrue);

      // Masuk dengan email menghapus pesan Google yang lama.
      await tester.enterText(find.byType(TextField).at(0), 'bukan-email');
      await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
      await settle(tester);
      expect(find.text('Email akun Google ini belum terverifikasi.'), findsNothing);

      await disposeApp(tester, h);
    });

    testWidgets('pilihan akun ditutup: tidak ada yang dikirim dan tanpa pesan', (tester) async {
      final h = Harness();
      final google = FakeGoogleAccounts([null]);
      await pumpApp(tester, h, signedIn: false, google: google);

      await tester.tap(googleButton('Masuk dengan Google'));
      await settle(tester);

      expect(google.picks, 1);
      expect(h.api.requests, isEmpty);
      expect(find.text('Masuk dengan Google gagal. Coba lagi.'), findsNothing);
      expect(googleEnabled(tester), isTrue);

      await disposeApp(tester, h);
    });

    testWidgets('gagal di HP, server bermasalah, atau tanpa koneksi: pesannya di bawah tombol Google', (tester) async {
      final h = Harness();
      final google = FakeGoogleAccounts([
        const GoogleAccountsFailure('providerConfigurationError: [28444] Developer console is not set up correctly.'),
        sari,
        sari,
      ]);
      await pumpApp(tester, h, signedIn: false, google: google);

      await tester.tap(googleButton('Masuk dengan Google'));
      await settle(tester);
      expect(find.text('Masuk dengan Google gagal. Coba lagi.'), findsOneWidget);
      expect(h.api.requests, isEmpty);

      // Kunci Google tidak bisa diambil server (503), atau GOOGLE_CLIENT_ID belum diisi (500).
      h.api.failNext(const NetworkFailure(status: 503));
      await tester.tap(googleButton('Masuk dengan Google'));
      await settle(tester);
      expect(find.text('Masuk dengan Google gagal. Coba lagi.'), findsNothing);
      expect(find.text('Ada yang tidak beres. Coba lagi sebentar lagi.'), findsOneWidget);

      h.api.failNext(const NetworkFailure());
      await tester.tap(googleButton('Masuk dengan Google'));
      await settle(tester);
      expect(find.text('Butuh koneksi internet. Coba lagi saat online.'), findsOneWidget);
      expect(find.text('Senang melihatmu lagi.'), findsOneWidget);

      await disposeApp(tester, h);
    });
  });

  group('layar Daftar dan tema', () {
    testWidgets('layar Daftar: Daftar dengan Google memakai endpoint yang sama', (tester) async {
      final h = Harness();
      h.api.me = userJson(name: 'Sari');
      newAccountSync(h.api);
      await pumpApp(tester, h, signedIn: false, google: FakeGoogleAccounts([sari]));

      await tester.tap(find.widgetWithText(TextButton, 'Daftar'));
      await settle(tester);
      expect(googleButton('Masuk dengan Google'), findsNothing);
      await tester.tap(googleButton('Daftar dengan Google'));
      await settle(tester);

      expect(h.api.requests.first.path, '/auth/google');
      // Akun ini belum pernah melewati Ajak pasangan di HP ini.
      expect(find.text('Pakai berdua, lebih ringan'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('warna tombol dari panduan Google, bukan warna tema', (tester) async {
      Color fill() => tester
          .widget<OutlinedButton>(
            find.descendant(of: find.byType(GoogleSignInButton), matching: find.byType(OutlinedButton)),
          )
          .style!
          .backgroundColor!
          .resolve({})!;

      final light = Harness();
      await pumpApp(tester, light, signedIn: false, themeMode: 'light');
      expect(fill(), GoogleButtonColors.light.fill);
      await disposeApp(tester, light);

      final dark = Harness();
      await pumpApp(tester, dark, signedIn: false, themeMode: 'dark');
      expect(fill(), const Color(0xFF131314));
      expect(find.image(const AssetImage(googleLogoAsset)), findsOneWidget);
      await disposeApp(tester, dark);
    });
  });
}
