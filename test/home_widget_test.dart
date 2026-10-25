import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/core/time/space_clock.dart';
import 'package:todolist/features/auth/presentation/auth_actions.dart';
import 'package:todolist/features/home/domain/home_widget_snapshot.dart';
import 'package:todolist/features/savings/domain/savings_views.dart';
import 'package:todolist/features/spaces/domain/household.dart';
import 'package:todolist/features/tasks/domain/task.dart';
import 'package:todolist/features/tasks/domain/task_list.dart';
import 'package:todolist/features/auth/domain/user.dart';
import 'package:todolist/features/savings/domain/savings_entry.dart';
import 'package:todolist/features/savings/domain/savings_goal.dart';
import 'package:todolist/features/spaces/domain/space.dart';
import 'package:todolist/features/tasks/domain/task_views.dart';

import 'helpers/app_harness.dart';
import 'helpers/fixtures.dart';

String _taskId(int n) => '01m4dh1yn0t6cdn39q4f0918${n.toString().padLeft(2, '0')}';

/// Widget "Tugas hari ini" di layar utama (v1.x).
void main() {
  setUpAll(prepareAppTests);

  group('ringkasan widget', () {
    final household = Household(
      me: User.fromJson(userJson()),
      spaces: [Space.fromJson(sharedSpaceJson()), Space.fromJson(personalSpaceJson())],
    );

    List<TaskItem> items(List<Map<String, dynamic>> tasks) => buildTaskItems(
      tasks: [for (final task in tasks) Task.fromJson(task)],
      lists: [TaskList.fromJson(listJson())],
      household: household,
      clock: SpaceClock(now: TestClock().call),
    );

    test('tugas belum selesai sampai 7 hari ke depan, yang terlewat dulu; tanpa nominal tabungan', () {
      final snapshot = homeWidgetSnapshot(
        tasks: items([
          taskJson(id: _taskId(1), title: 'Hari ini sore', dueDate: '2026-10-08', dueTime: '17:00'),
          taskJson(id: _taskId(2), title: 'Terlewat', dueDate: '2026-10-06'),
          taskJson(id: _taskId(3), title: 'Hari ini', dueDate: '2026-10-08'),
          taskJson(id: _taskId(4), title: 'Minggu depan', dueDate: '2026-10-15'),
          taskJson(id: _taskId(5), title: 'Terlalu jauh', dueDate: '2026-10-16'),
          taskJson(id: _taskId(6), title: 'Tanpa tenggat'),
          taskJson(id: _taskId(7), title: 'Sudah selesai', dueDate: '2026-10-08', completedAt: t0),
        ]),
        goal: GoalProgress(
          goal: SavingsGoal.fromJson({...goalJson(), 'emoji': '✈️'}),
          space: Space.fromJson(sharedSpaceJson()),
          entries: [SavingsEntry.fromJson(entryJson(amount: 4500000))],
          today: '2026-10-08',
        ),
        timezone: 'Asia/Jakarta',
        today: '2026-10-08',
      );

      expect(snapshot['signed_in'], isTrue);
      expect(snapshot['timezone'], 'Asia/Jakarta');
      expect(snapshot['tasks'], [
        {'title': 'Terlewat', 'due': '2026-10-06', 'time': null},
        {'title': 'Hari ini sore', 'due': '2026-10-08', 'time': '17:00'},
        {'title': 'Hari ini', 'due': '2026-10-08', 'time': null},
        {'title': 'Minggu depan', 'due': '2026-10-15', 'time': null},
      ]);
      expect(snapshot['goal'], {'label': '✈️ Dana Liburan', 'percent': 45});
      expect(jsonEncode(snapshot), isNot(contains('4500000')));
    });
  });

  group('kanal ke Android', () {
    const channel = MethodChannel('todolist/device');

    testWidgets('widget diperbarui saat tugas berubah dan dikosongkan saat keluar', (tester) async {
      final sent = <Map<String, dynamic>>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'updateWidget') {
          sent.add(jsonDecode((call.arguments as Map)['json'] as String) as Map<String, dynamic>);
        }
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));

      final h = Harness();
      await h.seed(withTask: true);
      await h.account.store.write(EntityType.task, taskJson(dueDate: '2026-10-08'), serverUpdatedAt: t0);
      final container = await pumpApp(tester, h);

      expect(sent.last['signed_in'], isTrue);
      expect([for (final task in sent.last['tasks'] as List) task['title']], ['Beli galon']);
      final calls = sent.length;

      // Waktu berjalan tanpa perubahan: tidak dikirim ulang.
      await tester.pump(const Duration(seconds: 31));
      await settle(tester);
      expect(sent.length, calls);

      // Tugas diselesaikan: hilang dari widget.
      await tester.tap(find.bySemanticsLabel(RegExp('Tandai selesai: Beli galon')));
      await settle(tester);
      expect(sent.last['tasks'], isEmpty);

      await tester.runAsync(() => signOut(container));
      await settle(tester);
      expect(sent.last, {'signed_in': false});

      await disposeApp(tester, h);
    });

    testWidgets('Pengaturan: sematkan widget, atau jelaskan caranya kalau launcher tidak bisa', (tester) async {
      var supported = true;
      final calls = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        return call.method == 'pinWidget' ? supported : null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));

      final h = Harness();
      await h.seed();
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.settings);
      await settle(tester);

      await tester.scrollUntilVisible(
        find.text('Widget di layar utama'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Widget di layar utama'));
      await settle(tester);
      expect(calls, contains('pinWidget'));
      expect(find.textContaining('Tekan lama layar utama HP'), findsNothing);

      supported = false;
      await tester.tap(find.text('Widget di layar utama'));
      await settle(tester);
      expect(find.text('Tekan lama layar utama HP, pilih Widget, lalu cari Denly Days.'), findsOneWidget);

      await disposeApp(tester, h);
    });
  });
}
