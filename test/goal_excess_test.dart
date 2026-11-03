import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';

import 'helpers/app_harness.dart';
import 'helpers/fixtures.dart';

/// Setoran yang melewati target: "Sisa Rp0" lalu kelebihannya di Detail tabungan.
void main() {
  setUpAll(prepareAppTests);

  testWidgets('target Rp1.000.000, terkumpul Rp950.000, lalu setor Rp60.000: lebih Rp10.000', (tester) async {
    final h = Harness();
    await h.seed(withGoal: true);
    await h.account.store.write(
      EntityType.goal,
      goalJson(targetAmount: 1000000, targetDate: null),
      serverUpdatedAt: t0,
    );
    await h.account.store.write(EntityType.entry, entryJson(amount: 950000), serverUpdatedAt: t0);
    final container = await pumpApp(tester, h);
    container.read(routerProvider).go(Routes.goal(goalId));
    await settle(tester);

    expect(find.text('Sisa Rp50.000'), findsOneWidget);
    expect(find.textContaining('Lebih'), findsNothing);

    await tester.tap(find.text('Setor'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, '60000');
    await tester.tap(find.text('Simpan'));
    await settle(tester);

    expect(find.text('Rp1.010.000'), findsWidgets);
    expect(find.text('Sisa Rp0'), findsOneWidget);
    expect(find.text('Lebih Rp10.000 dari target'), findsOneWidget);
    expect(find.text('Dana Liburan tercapai. Selamat, kalian berhasil!'), findsOneWidget);

    await disposeApp(tester, h);
  });

  testWidgets('pas mencapai target: tanpa keterangan lebih', (tester) async {
    final h = Harness();
    await h.seed(withGoal: true);
    await h.account.store.write(
      EntityType.goal,
      goalJson(targetAmount: 1000000, targetDate: null),
      serverUpdatedAt: t0,
    );
    await h.account.store.write(EntityType.entry, entryJson(amount: 1000000), serverUpdatedAt: t0);
    final container = await pumpApp(tester, h);
    container.read(routerProvider).go(Routes.goal(goalId));
    await settle(tester);

    expect(find.text('Sisa Rp0'), findsOneWidget);
    expect(find.textContaining('Lebih'), findsNothing);

    await disposeApp(tester, h);
  });
}
