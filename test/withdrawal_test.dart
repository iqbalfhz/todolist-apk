import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/notifications/push_service.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/core/utils/money.dart';
import 'package:todolist/features/savings/domain/savings_entry.dart';
import 'package:todolist/features/savings/domain/savings_goal.dart';
import 'package:todolist/features/savings/domain/savings_views.dart';
import 'package:todolist/features/spaces/domain/space.dart';

import 'helpers/app_harness.dart';
import 'helpers/fixtures.dart';

String _entryId(int n) => '01m4dk06v0p3ew0dm0dk94s3${n.toString().padLeft(2, '0')}';

typedef _Entry = ({String? userId, int amount, bool withdrawal, String date});

GoalProgress _progress(List<_Entry> entries, {int target = 10000000}) => GoalProgress(
  goal: SavingsGoal.fromJson(goalJson(targetAmount: target)),
  space: Space.fromJson(sharedSpaceJson()),
  today: '2026-10-08',
  entries: [
    for (final (index, entry) in entries.indexed)
      SavingsEntry.fromJson({
        ...entryJson(id: _entryId(index), amount: entry.amount, entryDate: entry.date),
        'user_id': entry.userId,
        'type': entry.withdrawal ? 'withdrawal' : 'deposit',
      }),
  ],
);

/// Penarikan tabungan (v1.x).
void main() {
  setUpAll(prepareAppTests);

  group('total bersih', () {
    test('setoran dikurangi penarikan; persen dan sisa dari total bersih', () {
      final progress = _progress([
        (userId: meId, amount: 3000000, withdrawal: false, date: '2026-09-01'),
        (userId: partnerId, amount: 2000000, withdrawal: false, date: '2026-10-01'),
        (userId: meId, amount: 1500000, withdrawal: true, date: '2026-10-05'),
      ]);

      expect(progress.saved, 3500000);
      expect(progress.available, 3500000);
      expect(progress.percent, 35);
      expect(progress.remaining, 6500000);
      // Grafik "Setoran per bulan" hanya menghitung setoran.
      expect([for (final month in progress.monthlyTotals()) month.amount], [0, 0, 0, 3000000, 2000000]);
    });

    test('total negatif (dua HP menarik saat offline): persen 0, tidak ada yang bisa diambil', () {
      final progress = _progress([
        (userId: meId, amount: 1000000, withdrawal: false, date: '2026-10-01'),
        (userId: meId, amount: 800000, withdrawal: true, date: '2026-10-02'),
        (userId: partnerId, amount: 800000, withdrawal: true, date: '2026-10-02'),
      ]);

      expect(progress.saved, -600000);
      expect(progress.available, 0);
      expect(progress.fraction, 0);
      expect(progress.percent, 0);
      expect(progress.isAchieved, isFalse);
    });

    test('kontribusi bersih per orang; persen hanya dibagi di antara yang positif', () {
      final progress = _progress([
        (userId: meId, amount: 1000000, withdrawal: false, date: '2026-10-01'),
        (userId: partnerId, amount: 3000000, withdrawal: false, date: '2026-10-01'),
        (userId: meId, amount: 2000000, withdrawal: true, date: '2026-10-03'),
      ]);

      expect(
        [
          for (final item in progress.contributions(meId: meId, partnerId: partnerId))
            (item.who, item.amount, item.percent),
        ],
        [(Contributor.me, -1000000, 0), (Contributor.partner, 3000000, 100)],
      );
    });

    test('nominal negatif memakai tanda minus', () {
      expect(formatMoney(-200000, 'IDR'), '−Rp200.000');
      expect(formatMoney(-200000, 'IDR', withSign: true), '−Rp200.000');
      expect(formatMoney(200000, 'IDR', withSign: true), '+Rp200.000');
      expect(formatMoney(-12550, 'USD'), '−US\$125,50');
    });

    test('push savings_withdrawal membuka Detail target dan tidak tampil di layar kunci', () {
      const push = PushMessage(
        title: 'Dana Liburan',
        body: 'Sari mengambil Rp500.000',
        data: {'type': 'savings_withdrawal', 'space_id': sharedSpaceId, 'savings_goal_id': goalId},
      );
      expect(push.isAboutSavings, isTrue);
      expect(push.channel, PushChannels.activity);
      expect(push.tag, 'goal-$goalId');
    });
  });

  group('Detail tabungan', () {
    Future<void> seedDeposit(Harness h, int amount) => h.account.store.write(
      EntityType.entry,
      entryJson(id: _entryId(0), amount: amount),
      serverUpdatedAt: t0,
    );

    testWidgets('ambil: tidak boleh melebihi yang terkumpul, lalu tercatat sebagai penarikan', (tester) async {
      final h = Harness();
      await h.seed(withGoal: true);
      await seedDeposit(h, 4500000);
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.goal(goalId));
      await settle(tester);

      await tester.tap(find.text('Ambil'));
      await settle(tester);
      expect(find.text('Ambil tabungan'), findsOneWidget);
      expect(find.text('Berapa yang diambil?'), findsOneWidget);
      expect(find.text('Terkumpul Rp4.500.000, jadi paling banyak segitu yang bisa diambil.'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '5000000');
      await tester.tap(find.text('Simpan'));
      await settle(tester);
      expect(find.text('Paling banyak Rp4.500.000, sebesar yang terkumpul.'), findsOneWidget);
      expect(await h.ops(), isEmpty);

      await tester.enterText(find.byType(TextField).first, '1500000');
      await tester.enterText(find.byType(TextField).last, 'Tiket kereta');
      await tester.tap(find.text('Simpan'));
      await settle(tester);

      expect(find.text('Ambil tabungan'), findsNothing);
      expect(find.text('30%'), findsOneWidget);
      final op = (await h.ops()).single;
      expect('${op.entityType}:${op.method}', 'entry:PUT');
      expect(jsonDecode(op.payload!), {
        'savings_goal_id': goalId,
        'amount': 1500000,
        'entry_date': '2026-10-08',
        'note': 'Tiket kereta',
        'type': 'withdrawal',
      });

      await tester.scrollUntilVisible(
        find.text('Aku mengambil · Tiket kereta'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('−Rp1.500.000'), findsOneWidget);

      // Mengubah penarikan: batasnya ditambah nominal penarikan itu sendiri.
      await tester.tap(find.text('Aku mengambil · Tiket kereta'));
      await settle(tester);
      expect(find.text('Ubah penarikan'), findsOneWidget);
      expect(find.text('Terkumpul Rp4.500.000, jadi paling banyak segitu yang bisa diambil.'), findsOneWidget);
      expect(find.text('Hapus penarikan'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('tanpa yang terkumpul, tombol Ambil tidak tampil', (tester) async {
      final h = Harness();
      await h.seed(withGoal: true);
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.goal(goalId));
      await settle(tester);

      expect(find.text('Setor'), findsOneWidget);
      expect(find.text('Ambil'), findsNothing);

      await disposeApp(tester, h);
    });
  });
}
