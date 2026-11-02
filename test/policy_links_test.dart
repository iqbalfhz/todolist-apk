import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/config/env.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';

import 'helpers/app_harness.dart';
import 'helpers/fixtures.dart';

/// Tautan Syarat layanan dan Kebijakan privasi (v1.0).
void main() {
  setUpAll(prepareAppTests);

  /// Alamat yang diminta dibuka lewat kanal `todolist/device`, dan apakah HP bisa membukanya.
  List<String> mockBrowser(WidgetTester tester, {bool canOpen = true}) {
    final opened = <String>[];
    const channel = MethodChannel('todolist/device');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method != 'openUrl') return null;
      opened.add((call.arguments as Map<Object?, Object?>)['url']! as String);
      return canOpen;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));
    return opened;
  }

  test('alamatnya halaman publik di server produksi, lewat HTTPS', () {
    expect(Env.termsUrl, 'https://denlydays.iqbalfhz.my.id/syarat');
    expect(Env.privacyUrl, 'https://denlydays.iqbalfhz.my.id/privasi');
  });

  testWidgets('Masuk dan Daftar: kalimat persetujuan dengan kedua tautan', (tester) async {
    final h = Harness();
    final opened = mockBrowser(tester);
    await pumpApp(tester, h, signedIn: false);

    expect(find.text('Dengan mendaftar atau masuk dengan Google, kamu menyetujui'), findsOneWidget);
    await tester.ensureVisible(find.widgetWithText(TextButton, 'Kebijakan privasi'));
    await tester.tap(find.widgetWithText(TextButton, 'Kebijakan privasi'));
    await settle(tester);
    expect(opened, [Env.privacyUrl]);

    await tester.ensureVisible(find.widgetWithText(TextButton, 'Daftar'));
    await tester.tap(find.widgetWithText(TextButton, 'Daftar'));
    await settle(tester);
    await tester.ensureVisible(find.widgetWithText(TextButton, 'Syarat layanan'));
    await tester.tap(find.widgetWithText(TextButton, 'Syarat layanan'));
    await settle(tester);
    expect(opened, [Env.privacyUrl, Env.termsUrl]);

    await disposeApp(tester, h);
  });

  testWidgets('Pengaturan: kedua halaman, dan alamatnya disebut kalau tidak ada browser', (tester) async {
    final h = Harness();
    await h.seed();
    final opened = mockBrowser(tester, canOpen: false);
    final container = await pumpApp(tester, h);
    container.read(routerProvider).go(Routes.settings);
    await settle(tester);

    await tester.scrollUntilVisible(
      find.widgetWithText(OutlinedButton, 'Keluar'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Syarat layanan'));
    await settle(tester);
    expect(opened, [Env.termsUrl]);
    expect(find.text('Tautan tidak bisa dibuka. Buka ${Env.termsUrl} di browser.'), findsOneWidget);

    await tester.tap(find.text('Kebijakan privasi'));
    await settle(tester);
    expect(opened.last, Env.privacyUrl);

    await disposeApp(tester, h);
  });
}
