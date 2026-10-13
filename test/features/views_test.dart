import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:todolist/core/l10n/l10n.dart';
import 'package:todolist/core/time/space_clock.dart';
import 'package:todolist/features/auth/domain/user.dart';
import 'package:todolist/features/savings/domain/savings_entry.dart';
import 'package:todolist/features/savings/domain/savings_goal.dart';
import 'package:todolist/features/savings/domain/savings_views.dart';
import 'package:todolist/features/spaces/domain/household.dart';
import 'package:todolist/features/spaces/domain/space.dart';
import 'package:todolist/features/tasks/domain/task.dart';
import 'package:todolist/features/tasks/domain/task_list.dart';
import 'package:todolist/features/tasks/domain/task_views.dart';
import 'package:todolist/features/tasks/presentation/task_text.dart';

import '../helpers/fixtures.dart';

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  // Kamis, 8 Oktober 2026 pukul 17.00 WIB.
  final clock = SpaceClock(now: () => DateTime.utc(2026, 10, 8, 10));
  final l10n = lookupAppLocalizations(const Locale('id'));

  final household = Household(
    me: User.fromJson(userJson()),
    spaces: [Space.fromJson(sharedSpaceJson()), Space.fromJson(personalSpaceJson())],
  );
  final solo = Household(me: User.fromJson(userJson()), spaces: [Space.fromJson(personalSpaceJson())]);

  const personalListId = '01m4dh0423zqexwxs1n4yw5jn5';
  final lists = [
    TaskList.fromJson(listJson()),
    TaskList.fromJson(listJson(id: otherListId, name: 'Rumah', position: 2048)),
    TaskList.fromJson(listJson(id: personalListId, spaceId: personalSpaceId, name: 'Kerja', position: 512)),
  ];

  List<TaskItem> build(List<Map<String, dynamic>> tasks, {List<TaskList>? withLists}) => buildTaskItems(
    tasks: [for (final task in tasks) Task.fromJson(task)],
    lists: withLists ?? lists,
    household: household,
    clock: clock,
  );

  TaskItem one(Map<String, dynamic> task) => build([task]).single;

  group('tugas hari ini dan terlewat', () {
    test('tenggat hari ini tanpa jam: untuk hari ini, belum terlewat', () {
      final item = one(taskJson(dueDate: '2026-10-08'));
      expect(item.isForToday, isTrue);
      expect(item.isOverdue, isFalse);
      expect(dueText(l10n, item), 'Hari ini');
    });

    test('tenggat hari ini dengan jam yang belum lewat', () {
      final item = one(taskJson(dueDate: '2026-10-08', dueTime: '19:00'));
      expect(item.isOverdue, isFalse);
      expect(dueText(l10n, item), 'Hari ini, 19.00');
    });

    test('tenggat hari ini dengan jam yang sudah lewat: terlewat', () {
      final item = one(taskJson(dueDate: '2026-10-08', dueTime: '09:00'));
      expect(item.isForToday, isTrue);
      expect(item.isOverdue, isTrue);
      expect(dueText(l10n, item), 'Terlewat · hari ini, 09.00');
    });

    test('tenggat kemarin: terlewat dan tetap masuk tugas hari ini', () {
      final item = one(taskJson(dueDate: '2026-10-07'));
      expect(item.isForToday, isTrue);
      expect(item.isOverdue, isTrue);
      expect(dueText(l10n, item), 'Terlewat · kemarin');
    });

    test('tenggat lebih lama: terlewat dengan tanggalnya', () {
      expect(dueText(l10n, one(taskJson(dueDate: '2026-10-05'))), 'Terlewat · Sen, 5 Okt');
    });

    test('tenggat besok dan seterusnya: bukan tugas hari ini', () {
      final tomorrow = one(taskJson(dueDate: '2026-10-09', dueTime: '17:00'));
      expect(tomorrow.isForToday, isFalse);
      expect(dueText(l10n, tomorrow), 'Besok, 17.00');
      expect(dueText(l10n, one(taskJson(dueDate: '2026-10-10'))), 'Sab, 10 Okt');
      expect(dueText(l10n, one(taskJson(dueDate: '2027-01-02'))), 'Sab, 2 Jan 2027');
    });

    test('tanpa tenggat: bukan tugas hari ini', () {
      final item = one(taskJson());
      expect(item.isForToday, isFalse);
      expect(dueText(l10n, item), 'Tanpa tenggat');
    });

    test('selesai hari ini tetap tampil; selesai kemarin tidak', () {
      final today = one(
        taskJson(dueDate: '2026-10-08', completedAt: '2026-10-08T05:40:00.000000Z', completedBy: partnerId),
      );
      expect(today.isForToday, isTrue);
      expect(today.isOverdue, isFalse);
      // Sama seperti di mockup: pasangan disebut dengan labelnya, bukan namanya.
      expect(completedText(l10n, today, household, clock), 'Diselesaikan Pasangan, 12.40');

      final yesterday = one(
        taskJson(dueDate: '2026-10-07', completedAt: '2026-10-07T05:40:00.000000Z', completedBy: meId),
      );
      expect(yesterday.isForToday, isFalse);
      expect(completedText(l10n, yesterday, household, clock), 'Diselesaikan Aku, kemarin');
    });

    test('"hari ini" mengikuti zona waktu ruang: pukul 23.30 UTC sudah tanggal 9 di Jakarta', () {
      final late = SpaceClock(now: () => DateTime.utc(2026, 10, 8, 23, 30));
      final item = buildTaskItems(
        tasks: [Task.fromJson(taskJson(dueDate: '2026-10-08'))],
        lists: lists,
        household: household,
        clock: late,
      ).single;

      expect(item.today, '2026-10-09');
      expect(item.isOverdue, isTrue);
    });

    test('urutan: terlewat paling lama dulu, lalu menurut jam, selesai di paling bawah', () {
      final items = build([
        taskJson(id: 'a', title: 'Tanpa jam', dueDate: '2026-10-08'),
        taskJson(id: 'b', title: 'Sore', dueDate: '2026-10-08', dueTime: '17:30'),
        taskJson(id: 'c', title: 'Selesai', dueDate: '2026-10-08', completedAt: '2026-10-08T03:00:00.000000Z'),
        taskJson(id: 'd', title: 'Kemarin', dueDate: '2026-10-07'),
        taskJson(id: 'e', title: 'Pagi', dueDate: '2026-10-08', dueTime: '08:00'),
      ])..sort(compareForToday);

      expect([for (final item in items) item.task.title], ['Kemarin', 'Pagi', 'Sore', 'Tanpa jam', 'Selesai']);
    });
  });

  group('daftar dan penanggung jawab', () {
    test('tugas di daftar yang diarsipkan atau dihapus tidak tampil di tampilan mana pun', () {
      final items = build(
        [
          taskJson(id: 'a', taskListId: listId),
          taskJson(id: 'b', taskListId: otherListId),
          taskJson(id: 'c', taskListId: personalListId, spaceId: personalSpaceId),
          taskJson(id: 'd', taskListId: 'daftar-tidak-ada'),
        ],
        withLists: [
          TaskList.fromJson(listJson()),
          TaskList.fromJson(listJson(id: otherListId, archivedAt: t1)),
          TaskList.fromJson(listJson(id: personalListId, spaceId: personalSpaceId, deletedAt: t1)),
        ],
      );

      expect([for (final item in items) item.task.id], ['a']);
    });

    test('urutan daftar: Ruang Bersama dulu, lalu menurut position', () {
      expect([for (final list in orderLists(lists, household)) list.name], ['Belanja', 'Rumah', 'Kerja']);
    });

    test('daftar aktif pertama di sebuah ruang punya position terkecil', () {
      expect(firstActiveList(lists, sharedSpaceId)!.name, 'Belanja');
      expect(firstActiveList(lists, personalSpaceId)!.name, 'Kerja');
      expect(firstActiveList([TaskList.fromJson(listJson(archivedAt: t1))], sharedSpaceId), isNull);
    });

    test('Aku, Pasangan, dan Kita', () {
      final mine = one(taskJson(assigneeIds: [meId]));
      final theirs = one(taskJson(assigneeIds: [partnerId]));
      final ours = one(taskJson(assigneeIds: [meId, partnerId]));

      expect(mine.assigneeFor(meId), Assignee.me);
      expect(theirs.assigneeFor(meId), Assignee.partner);
      expect(ours.assigneeFor(meId), Assignee.us);

      // Tugas "Kita" muncul di filter Aku maupun Pasangan.
      for (final filter in [PersonFilter.me, PersonFilter.partner]) {
        expect(ours.matches(filter, meId: meId, partnerId: partnerId), isTrue);
      }
      expect(mine.matches(PersonFilter.partner, meId: meId, partnerId: partnerId), isFalse);
      expect(theirs.matches(PersonFilter.me, meId: meId, partnerId: partnerId), isFalse);
      expect(theirs.matches(PersonFilter.all, meId: meId, partnerId: partnerId), isTrue);

      expect(assigneeIdsFor(Assignee.us, household), [meId, partnerId]);
      expect(assigneeIdsFor(Assignee.partner, household), [partnerId]);
      expect(assigneeIdsFor(Assignee.us, solo), [meId], reason: 'tanpa pasangan, hanya diri sendiri');
    });

    test('rumah tangga: pasangan dan warna', () {
      expect(household.isPaired, isTrue);
      expect(household.partner!.name, 'Sari');
      expect(household.colorOf(partnerId), 'ungu');
      expect(household.colorOf(meId), 'mawar');
      expect(household.timezoneOf(sharedSpaceId), 'Asia/Jakarta');
      expect(solo.isPaired, isFalse);
      expect(solo.partner, isNull);
    });
  });

  group('tabungan', () {
    GoalProgress progress({
      int target = 10000000,
      String? targetDate = '2027-02-28',
      List<Map<String, dynamic>> entries = const [],
      String today = '2026-10-08',
    }) => GoalProgress(
      goal: SavingsGoal.fromJson(goalJson(targetAmount: target, targetDate: targetDate)),
      space: household.shared!,
      entries: [for (final entry in entries) SavingsEntry.fromJson(entry)],
      today: today,
    );

    test('progres dihitung dari setoran, seperti di mockup', () {
      final result = progress(
        entries: [
          entryJson(id: 'a', amount: 6000000),
          entryJson(id: 'b', amount: 500000),
        ],
      );

      expect(result.saved, 6500000);
      expect(result.percent, 65);
      expect(result.remaining, 3500000);
      expect(result.isAchieved, isFalse);
      // 143 hari sampai 28 Feb 2027 = 20 minggu penuh.
      expect(result.weeklyNeed, 175000);
    });

    test('persen dibulatkan ke bawah: 100% hanya saat benar-benar tercapai', () {
      expect(progress(entries: [entryJson(amount: 9999999)]).percent, 99);

      final achieved = progress(entries: [entryJson(amount: 12000000)]);
      expect(achieved.percent, 100);
      expect(achieved.fraction, 1);
      expect(achieved.remaining, 0);
      expect(achieved.isAchieved, isTrue);
      expect(achieved.weeklyNeed, isNull);
    });

    test('setoran per minggu hanya kalau ada tanggal target yang belum lewat', () {
      expect(progress(targetDate: null).weeklyNeed, isNull);
      expect(progress(targetDate: '2026-10-01').weeklyNeed, isNull);
      expect(progress(targetDate: '2026-10-08').weeklyNeed, isNull);
      // Kurang dari seminggu: seluruh sisanya dalam satu minggu.
      expect(progress(target: 100000, targetDate: '2026-10-11').weeklyNeed, 100000);
      // Dibulatkan ke atas supaya target tetap tercapai.
      expect(progress(target: 100000, targetDate: '2026-10-29').weeklyNeed, 33334);
    });

    test('setoran per bulan: lima bulan terakhir sampai bulan berjalan', () {
      final months = progress(
        entries: [
          entryJson(id: 'a', amount: 200000, entryDate: '2026-10-08'),
          entryJson(id: 'b', amount: 300000, entryDate: '2026-10-01'),
          entryJson(id: 'c', amount: 1800000, entryDate: '2026-09-15'),
          entryJson(id: 'd', amount: 1000000, entryDate: '2026-06-30'),
          entryJson(id: 'e', amount: 999, entryDate: '2026-05-31'),
        ],
      ).monthlyTotals();

      expect([for (final month in months) month.month], [6, 7, 8, 9, 10]);
      expect([for (final month in months) month.amount], [1000000, 0, 0, 1800000, 500000]);
      expect(months.last.isCurrent, isTrue);
      expect(months.where((month) => month.isCurrent), hasLength(1));
    });

    test('setoran per bulan melewati pergantian tahun', () {
      final months = progress(
        today: '2027-02-10',
        entries: [entryJson(amount: 5, entryDate: '2026-12-31')],
      ).monthlyTotals();

      expect(
        [for (final month in months) (month.year, month.month)],
        [(2026, 10), (2026, 11), (2026, 12), (2027, 1), (2027, 2)],
      );
      expect(months[2].amount, 5);
    });

    test('target utama: yang paling lama dibuat dan belum tercapai, bukan yang diarsipkan', () {
      List<GoalProgress> goals(List<(String, int, bool)> specs) => [
        for (final (id, saved, archived) in specs)
          GoalProgress(
            goal: SavingsGoal.fromJson(goalJson(id: id, name: id, targetAmount: 100, archivedAt: archived ? t1 : null)),
            space: household.shared!,
            entries: [SavingsEntry.fromJson(entryJson(savingsGoalId: id, amount: saved == 0 ? 1 : saved))],
            today: '2026-10-08',
          ),
      ];

      expect(
        primaryGoal(goals([('arsip', 10, true), ('tercapai', 100, false), ('jalan', 10, false)]))!.goal.id,
        'jalan',
      );
      expect(primaryGoal(goals([('tercapai', 100, false), ('arsip', 10, true)]))!.goal.id, 'tercapai');
      expect(primaryGoal(goals([('arsip', 10, true)])), isNull);
      expect(primaryGoal(const []), isNull);
    });

    test('setoran terhapus dan target di ruang yang tidak dikenal tidak dihitung', () {
      final result = buildGoalProgress(
        goals: [
          SavingsGoal.fromJson(goalJson()),
          SavingsGoal.fromJson(goalJson(id: 'terhapus', deletedAt: t1)),
          SavingsGoal.fromJson(goalJson(id: 'asing', spaceId: 'ruang-lain')),
        ],
        entries: [
          SavingsEntry.fromJson(entryJson(id: 'a', amount: 100)),
          SavingsEntry.fromJson(entryJson(id: 'b', amount: 900, deletedAt: t1)),
        ],
        household: household,
        today: clock.today,
      );

      expect(result.single.goal.id, goalId);
      expect(result.single.saved, 100);
      expect(result.single.today, '2026-10-08');
    });
  });
}
