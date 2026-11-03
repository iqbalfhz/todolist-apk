import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/features/savings/data/exchange_rate_repository.dart';
import 'package:todolist/features/savings/domain/exchange_rates.dart';

import 'helpers/app_harness.dart';
import 'helpers/fake_api.dart';
import 'helpers/fixtures.dart';

const String usdGoalId = '01m4dfr0yg0n6e2k5f3m8t1q2j';
const String usdEntryId = '01m4dfr2e3b7w9x1y5z8a0c4d6';

/// Perkiraan kurs (v1.x).
void main() {
  setUpAll(prepareAppTests);

  final rates = ExchangeRates.fromJson(exchangeRatesJson());

  group('hitungan', () {
    test('contoh di kontrak: US\$100,00 menjadi Rp1.813.610', () {
      expect(rates.convert(10000, from: 'USD', to: 'IDR'), 1813610);
      expect(rates.convert(50000, from: 'USD', to: 'IDR'), 9068050);
      expect(rates.convert(1813610, from: 'IDR', to: 'USD'), 10000);
    });

    test('desimal mengikuti tabel Uang di kedua sisi', () {
      expect(rates.convert(5000, from: 'JPY', to: 'IDR'), 574293);
      expect(rates.convert(1000, from: 'EUR', to: 'USD'), 1122);
      expect(rates.convert(12345, from: 'SGD', to: 'MYR'), 39292);
    });

    test('dibulatkan setengah ke atas; nominal negatif tetap negatif', () {
      final half = ExchangeRates.fromJson(exchangeRatesJson(idr: '20341.5'));
      expect(half.convert(100, from: 'EUR', to: 'IDR'), 20342);
      expect(rates.convert(-10000, from: 'USD', to: 'IDR'), -1813610);
    });

    test('nominal paling besar tetap persis, tanpa pembulatan float', () {
      expect(rates.convert(1000000000000000, from: 'IDR', to: 'USD'), 5513864547513);
      expect(rates.convert(1000000000000000, from: 'USD', to: 'JPY'), 1578994293865906);
    });

    test('kurs yang tidak ada, nol, atau tidak terbaca membuat perkiraan kosong', () {
      final broken = ExchangeRates.fromJson({
        ...exchangeRatesJson(),
        'rates': {'EUR': '1', 'IDR': '20341.45', 'USD': '0', 'SGD': 'abc'},
      });
      expect(broken.convert(10000, from: 'USD', to: 'IDR'), isNull);
      expect(broken.convert(10000, from: 'SGD', to: 'IDR'), isNull);
      expect(broken.convert(10000, from: 'MYR', to: 'IDR'), isNull);
      expect(broken.convert(10000, from: 'EUR', to: 'IDR'), 2034145);
    });
  });

  group('repository', () {
    List<String> calls(Harness h) => [
      for (final request in h.api.requests)
        if (request.path == '/exchange-rates') request.method,
    ];

    test('disimpan di HP, lalu paling sering sekali per 6 jam', () async {
      final h = Harness();
      addTearDown(h.dispose);
      final repository = h.account.exchangeRates;

      expect(await repository.current(), isNull);
      expect(await repository.refresh(), isTrue);
      expect(await repository.current(), rates);
      expect(await repository.watch().first, rates);

      h.clock.advance(ExchangeRateRepository.refreshEvery - const Duration(minutes: 1));
      expect(await repository.refresh(), isFalse);
      expect(calls(h), ['GET']);

      h.api.exchangeRates = exchangeRatesJson(date: '2026-10-08', idr: '20400.10');
      h.clock.advance(const Duration(minutes: 1));
      expect(await repository.refresh(), isTrue);
      expect(calls(h), ['GET', 'GET']);
      expect((await repository.current())!.date, '2026-10-08');
    });

    test('503 exchange_rates_unavailable: kurs tersimpan tetap dipakai, dicoba lagi 15 menit kemudian', () async {
      final h = Harness();
      addTearDown(h.dispose);
      final repository = h.account.exchangeRates;

      // Belum pernah ada kurs di server: tidak ada perkiraan, dan tidak dicoba terus-menerus.
      h.api.exchangeRates = null;
      expect(await repository.refresh(), isFalse);
      expect(await repository.current(), isNull);
      expect(await repository.refresh(), isFalse);
      expect(calls(h), ['GET']);

      h.clock.advance(ExchangeRateRepository.retryAfterFailure);
      h.api.exchangeRates = exchangeRatesJson();
      expect(await repository.refresh(), isTrue);

      // Sesudahnya server tidak terjangkau: kurs lama tetap ada.
      h.clock.advance(ExchangeRateRepository.refreshEvery);
      h.api.failNext(const NetworkFailure());
      expect(await repository.refresh(), isFalse);
      expect(await repository.current(), rates);
      expect(calls(h), ['GET', 'GET', 'GET']);
    });

    test('error lain diteruskan dan tidak menghapus kurs tersimpan', () async {
      final h = Harness();
      addTearDown(h.dispose);
      final repository = h.account.exchangeRates;
      await repository.refresh();

      h.clock.advance(ExchangeRateRepository.refreshEvery);
      h.api.failNext(apiError(401, ApiErrorCode.unauthenticated));
      await expectLater(repository.refresh(), throwsA(isA<ApiError>()));
      expect(await repository.current(), rates);
    });
  });

  group('layar', () {
    /// Target dolar milikku di Ruang Bersama: US$100,00 dari US$500,00.
    Future<void> seedDollarGoal(Harness h) async {
      await h.seed(withGoal: true);
      final goal = goalJson(id: usdGoalId, name: 'Tiket Jepang', currency: 'USD', targetAmount: 50000);
      final entry = entryJson(id: usdEntryId, savingsGoalId: usdGoalId, amount: 10000, note: null);
      await h.account.store.write(EntityType.goal, goal, serverUpdatedAt: t0);
      await h.account.store.write(EntityType.entry, entry, serverUpdatedAt: t0);
      h.api.rows.putIfAbsent('savings-goals', () => {})[usdGoalId] = goal;
      h.api.rows.putIfAbsent('savings-entries', () => {})[usdEntryId] = entry;
    }

    const estimate = '≈ Rp1.813.610 dari Rp9.068.050 · kurs ECB 7 Okt';
    const spoken = 'Kira-kira Rp1.813.610 dari Rp9.068.050, kurs ECB 7 Okt';

    testWidgets('tab Tabungan dan Detail: perkiraan di bawah nominal dolar, tidak di target rupiah', (tester) async {
      final semantics = tester.ensureSemantics();
      final h = Harness();
      await seedDollarGoal(h);
      final container = await pumpApp(tester, h);

      // Ada target dolar, jadi kurs diambil sekali saat app dibuka.
      expect(h.api.requests.where((request) => request.path == '/exchange-rates'), hasLength(1));

      container.read(routerProvider).go(Routes.savings);
      await settle(tester);
      expect(find.text('US\$100,00 dari US\$500,00'), findsOneWidget);
      expect(find.text(estimate), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(RegExp.escape(spoken))), findsOneWidget);
      // Target rupiah tidak punya perkiraan.
      expect(find.textContaining('≈'), findsOneWidget);

      container.read(routerProvider).go(Routes.goal(usdGoalId));
      await settle(tester);
      expect(find.text(estimate), findsOneWidget);

      container.read(routerProvider).go(Routes.goal(goalId));
      await settle(tester);
      expect(find.textContaining('kurs ECB'), findsNothing);

      await disposeApp(tester, h);
      semantics.dispose();
    });

    testWidgets('setor dan ambil: perkiraan nominal yang sedang diketik', (tester) async {
      final semantics = tester.ensureSemantics();
      final h = Harness();
      await seedDollarGoal(h);
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.goal(usdGoalId));
      await settle(tester);

      // Perkiraan nominal, bukan perkiraan target di Detail yang ada di belakang lembar.
      final typedEstimate = find.textContaining(RegExp(r'^≈ Rp[\d.]+ · kurs ECB'));
      await tester.tap(find.text('Setor'));
      await settle(tester);
      expect(typedEstimate, findsNothing);
      await tester.enterText(find.byType(TextField).first, '25');
      await tester.pump();
      expect(find.text('≈ Rp453.403 · kurs ECB 7 Okt'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(RegExp.escape('Kira-kira Rp453.403, kurs ECB 7 Okt'))), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '1');
      await tester.pump();
      expect(find.text('≈ Rp18.136 · kurs ECB 7 Okt'), findsOneWidget);
      await tester.tap(find.byTooltip('Tutup'));
      await settle(tester);

      await tester.tap(find.text('Ambil'));
      await settle(tester);
      await tester.enterText(find.byType(TextField).first, '100');
      await tester.pump();
      expect(find.text('≈ Rp1.813.610 · kurs ECB 7 Okt'), findsOneWidget);
      expect(find.text('Terkumpul US\$100,00, jadi paling banyak segitu yang bisa diambil.'), findsOneWidget);

      await disposeApp(tester, h);
      semantics.dispose();
    });

    testWidgets('kurs belum pernah ada (503): tanpa perkiraan, dan app tetap jalan', (tester) async {
      final h = Harness();
      await seedDollarGoal(h);
      h.api.exchangeRates = null;
      final container = await pumpApp(tester, h);

      container.read(routerProvider).go(Routes.savings);
      await settle(tester);
      expect(find.text('US\$100,00 dari US\$500,00'), findsOneWidget);
      expect(find.textContaining('kurs ECB'), findsNothing);

      await disposeApp(tester, h);
    });

    testWidgets('semua target dalam mata uang bawaan: kurs tidak diambil', (tester) async {
      final h = Harness();
      await h.seed(withGoal: true);
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.savings);
      await settle(tester);

      expect(h.api.requests.where((request) => request.path == '/exchange-rates'), isEmpty);
      expect(find.textContaining('kurs ECB'), findsNothing);

      await disposeApp(tester, h);
    });
  });
}
