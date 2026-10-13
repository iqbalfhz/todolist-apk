import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/platform/device_platform.dart';
import 'package:todolist/core/providers.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/core/widgets/widgets.dart';
import 'package:todolist/features/savings/presentation/goal_form_sheet.dart';
import 'package:todolist/features/savings/presentation/savings_screen.dart';
import 'package:todolist/features/tasks/presentation/list_form_sheet.dart';
import 'package:todolist/features/tasks/presentation/manage_lists_screen.dart';

import 'helpers/app_harness.dart';
import 'helpers/fake_push.dart';
import 'helpers/fixtures.dart';
import 'helpers/rich_fixtures.dart';

/// Tata letak tetap rapi saat huruf sistem diperbesar dan di layar kecil.
///
/// Setiap layar dirender dengan data yang ramai. Isi yang meluap dilaporkan Flutter
/// sebagai error, jadi tesnya gagal sendiri tanpa perlu membandingkan gambar.
void main() {
  setUpAll(prepareAppTests);

  /// Ukuran mockup, dan HP kecil yang masih umum dipakai.
  const mockup = Size(390, 844);
  const small = Size(360, 640);
  const keyboard = 280.0;

  Future<void> apply(WidgetTester tester, {required Size size, required double textScale}) async {
    tester.view.physicalSize = size;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await settle(tester);
  }

  Future<void> go(WidgetTester tester, ProviderContainer container, String path) async {
    container.read(routerProvider).go(path);
    await settle(tester);
  }

  /// Gulir sampai bawah, supaya bagian yang belum terlihat ikut ditata.
  Future<void> scrollThrough(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isEmpty) return;
      await tester.drag(scrollable.first, const Offset(0, -400), warnIfMissed: false);
      await settle(tester);
    }
  }

  Future<void> visit(WidgetTester tester, ProviderContainer container, String path) async {
    await go(tester, container, path);
    await scrollThrough(tester);
  }

  /// Lembar bawah diperiksa dengan keyboard terbuka, keadaan tersempitnya.
  Future<void> withSheet(WidgetTester tester, ProviderContainer container, Future<void> Function() open) async {
    await open();
    tester.view.viewInsets = const FakeViewPadding(bottom: keyboard);
    await settle(tester);
    expect(find.byType(AppSheet), findsOneWidget, reason: 'lembar bawahnya tidak terbuka');
    await scrollThrough(tester);

    container.read(routerProvider).routerDelegate.navigatorKey.currentState!.pop();
    tester.view.resetViewInsets();
    await settle(tester);
  }

  for (final (label, size, textScale) in [
    ('ukuran mockup', mockup, 1.0),
    ('huruf 1,3x', mockup, 1.3),
    ('huruf 2x', mockup, 2.0),
    ('layar kecil', small, 1.0),
    ('layar kecil, huruf 1,3x', small, 1.3),
  ]) {
    testWidgets('$label: semua layar setelah masuk', (tester) async {
      final h = Harness();
      await h.seedRich();
      final container = await pumpApp(tester, h);
      await apply(tester, size: size, textScale: textScale);

      await visit(tester, container, Routes.home);
      await withSheet(tester, container, () => tester.tap(find.byType(FloatingActionButton)));

      await visit(tester, container, Routes.tasks);
      await tester.tap(find.textContaining('Selesai ('));
      await settle(tester);
      await scrollThrough(tester);

      await visit(tester, container, Routes.task(importantTaskId));
      await visit(tester, container, Routes.task(longTaskId));

      await visit(tester, container, Routes.manageLists);
      await withSheet(tester, container, () async {
        final list = container.read(taskListsProvider).value!.firstWhere((list) => list.id == shoppingListId);
        showListFormSheet(tester.element(find.byType(ManageListsScreen)), list: list).ignore();
      });

      await visit(tester, container, Routes.savings);
      await tester.tap(find.textContaining('Diarsipkan ('));
      await settle(tester);
      await scrollThrough(tester);
      await withSheet(tester, container, () async {
        showGoalFormSheet(tester.element(find.byType(SavingsScreen))).ignore();
      });

      await visit(tester, container, Routes.goal(tripGoalId));
      // Kembali ke atas: tombol Setor harus benar-benar tampil sebelum diketuk.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 4000), warnIfMissed: false);
      await settle(tester);
      await tester.ensureVisible(find.text('Setor'));
      await settle(tester);
      await withSheet(tester, container, () => tester.tap(find.text('Setor')));
      await visit(tester, container, Routes.goal(achievedGoalId));

      await visit(tester, container, Routes.settings);
      await visit(tester, container, Routes.profile);
      await visit(tester, container, Routes.pairing);

      await disposeApp(tester, h);
    });
  }

  for (final (label, size, textScale) in [('huruf 2x', mockup, 2.0), ('layar kecil, huruf 1,3x', small, 1.3)]) {
    testWidgets('$label: Masuk dan Daftar dengan pesan error', (tester) async {
      final h = Harness();
      await pumpApp(tester, h, signedIn: false);
      await apply(tester, size: size, textScale: textScale);

      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Masuk'));
      await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
      await settle(tester);
      await scrollThrough(tester);

      await tester.ensureVisible(find.widgetWithText(TextButton, 'Daftar'));
      await tester.tap(find.widgetWithText(TextButton, 'Daftar'));
      await settle(tester);
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Daftar'));
      await tester.tap(find.widgetWithText(FilledButton, 'Daftar'));
      await settle(tester);
      await scrollThrough(tester);

      expect(find.text('Nama panggilan belum diisi.'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('$label: Izin notifikasi dengan panduan baterai, lalu Ajak pasangan', (tester) async {
      const xiaomi = DeviceInfo(manufacturer: 'Xiaomi', brand: 'Redmi', model: 'Redmi Note 13', sdkInt: 34);
      final h = Harness();
      await h.seedUnpaired();
      await pumpApp(
        tester,
        h,
        push: FakePushService(grantOnRequest: false),
        device: xiaomi,
        notificationsDone: false,
        pairingDone: false,
      );
      await apply(tester, size: size, textScale: textScale);

      // Izin ditolak: kartu petunjuk dan panduan baterai tampil bersamaan.
      await tester.tap(find.text('Izinkan notifikasi'));
      await settle(tester);
      await scrollThrough(tester);

      await tester.ensureVisible(find.text('Lewati'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lewati'));
      await settle(tester);

      expect(find.text('Kode undanganmu'), findsOneWidget);
      await scrollThrough(tester);

      await disposeApp(tester, h);
    });
  }
}
