import 'package:flutter_test/flutter_test.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/features/savings/domain/savings_entry.dart';
import 'package:todolist/features/savings/domain/savings_goal.dart';
import 'package:todolist/features/savings/domain/savings_views.dart';
import 'package:todolist/features/spaces/domain/space.dart';

import 'helpers/app_harness.dart';
import 'helpers/fixtures.dart';

String _entryId(int n) => '01m4dk06v0p3ew0dm0dk94s2${n.toString().padLeft(2, '0')}';

GoalProgress _progress(List<({String? userId, int amount})> deposits) => GoalProgress(
  goal: SavingsGoal.fromJson(goalJson()),
  space: Space.fromJson(sharedSpaceJson()),
  today: '2026-10-08',
  entries: [
    for (final (index, deposit) in deposits.indexed)
      SavingsEntry.fromJson({...entryJson(id: _entryId(index), amount: deposit.amount), 'user_id': deposit.userId}),
  ],
);

void main() {
  setUpAll(prepareAppTests);

  group('bagian persen', () {
    test('jumlahnya selalu tepat 100, sisa pembulatan ke pecahan terbesar', () {
      expect(sharePercents([625, 375]), [63, 37]);
      expect(sharePercents([1, 1, 1]), [34, 33, 33]);
      expect(sharePercents([4000000, 2500000]), [62, 38]);
      expect(sharePercents([999, 1]), [100, 0]);
      expect(sharePercents([500, 0]), [100, 0]);
      expect(sharePercents([0, 0]), [0, 0]);
    });
  });

  group('kontribusi per orang', () {
    test('setoran dijumlah per orang; tanpa user_id dihitung milik sendiri', () {
      final progress = _progress([
        (userId: meId, amount: 3000000),
        (userId: partnerId, amount: 2500000),
        (userId: null, amount: 1000000),
      ]);

      final contributions = progress.contributions(meId: meId, partnerId: partnerId);
      expect(
        [for (final item in contributions) (item.who, item.amount, item.percent)],
        [(Contributor.me, 4000000, 62), (Contributor.partner, 2500000, 38)],
      );
      expect(contributions.fold(0, (sum, item) => sum + item.amount), progress.saved);
    });

    test('pasangan yang belum menyetor tetap tampil dengan Rp0; akun yang sudah bukan anggota dipisah', () {
      final onlyMe = _progress([(userId: meId, amount: 500000)]);
      expect(
        [for (final item in onlyMe.contributions(meId: meId, partnerId: partnerId)) (item.who, item.percent)],
        [(Contributor.me, 100), (Contributor.partner, 0)],
      );

      final former = _progress([
        (userId: meId, amount: 700000),
        (userId: '01m4dga4y03c5ratqsc31zc999', amount: 300000),
      ]);
      expect(
        [for (final item in former.contributions(meId: meId, partnerId: partnerId)) (item.who, item.percent)],
        [(Contributor.me, 70), (Contributor.partner, 0), (Contributor.former, 30)],
      );
    });
  });

  group('Detail tabungan', () {
    testWidgets('target bersama: kontribusi Aku dan Pasangan beserta totalnya', (tester) async {
      final h = Harness();
      await h.seed(withGoal: true);
      for (final (index, deposit) in [(userId: meId, amount: 3000000), (userId: partnerId, amount: 2000000)].indexed) {
        await h.account.store.write(
          EntityType.entry,
          entryJson(id: _entryId(index), userId: deposit.userId, amount: deposit.amount),
          serverUpdatedAt: t0,
        );
      }
      final container = await pumpApp(tester, h);

      container.read(routerProvider).go(Routes.goal(goalId));
      await settle(tester);

      expect(find.text('Kontribusi'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('Rp3.000.000'), findsOneWidget);
      expect(find.text('Rp2.000.000'), findsWidgets);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Rp5.000.000'), findsWidgets);

      await disposeApp(tester, h);
    });

    testWidgets('target pribadi atau yang belum punya setoran: tanpa kartu kontribusi', (tester) async {
      final h = Harness();
      await h.seed(withGoal: true);
      const personalGoalId = '01m4djq1w0ystkpbz7mqd22k3p';
      await h.account.store.write(
        EntityType.goal,
        goalJson(id: personalGoalId, spaceId: personalSpaceId, name: 'Dana Pribadi'),
        serverUpdatedAt: t0,
      );
      await h.account.store.write(EntityType.entry, {
        ...entryJson(savingsGoalId: personalGoalId),
        'space_id': personalSpaceId,
      }, serverUpdatedAt: t0);
      final container = await pumpApp(tester, h);

      container.read(routerProvider).go(Routes.goal(personalGoalId));
      await settle(tester);
      expect(find.text('Dana Pribadi'), findsWidgets);
      expect(find.text('Kontribusi'), findsNothing);

      container.read(routerProvider).go(Routes.goal(goalId));
      await settle(tester);
      expect(find.text('Kontribusi'), findsNothing, reason: 'belum ada setoran');

      await disposeApp(tester, h);
    });
  });
}
