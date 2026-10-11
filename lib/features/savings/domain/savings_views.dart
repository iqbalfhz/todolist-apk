import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/utils/dates.dart';
import '../../spaces/domain/household.dart';
import '../../spaces/domain/space.dart';
import 'savings_entry.dart';
import 'savings_goal.dart';

/// Target beserta setoran dan progresnya. Progres dihitung di HP dari daftar setoran.
class GoalProgress {
  const GoalProgress({required this.goal, required this.space, required this.entries, required this.today});

  final SavingsGoal goal;
  final Space space;

  /// Setoran target ini, yang terbaru lebih dulu.
  final List<SavingsEntry> entries;

  /// Tanggal hari ini (`YYYY-MM-DD`) di zona waktu ruang target ini.
  final String today;

  int get saved => entries.fold(0, (total, entry) => total + entry.amount);

  int get remaining => math.max(0, goal.targetAmount - saved);

  bool get isAchieved => saved >= goal.targetAmount;

  /// Bagian yang terkumpul, 0 sampai 1.
  double get fraction => goal.targetAmount <= 0 ? 0 : math.min(1, saved / goal.targetAmount);

  /// Persen dibulatkan ke bawah, supaya 100% hanya tampil saat benar-benar tercapai.
  int get percent => (fraction * 100).floor();

  /// Setoran per minggu yang dibutuhkan sampai tanggal target (FR-14).
  ///
  /// `null` kalau target tidak punya tanggal, sudah tercapai, atau tanggalnya sudah lewat.
  int? get weeklyNeed {
    final targetDate = goal.targetDate;
    if (targetDate == null || isAchieved) return null;

    final daysLeft = daysBetween(today, targetDate);
    if (daysLeft <= 0) return null;

    final weeksLeft = math.max(1, daysLeft ~/ 7);
    return (remaining / weeksLeft).ceil();
  }

  /// Jumlah setoran per bulan untuk [count] bulan terakhir sampai bulan ini.
  List<MonthTotal> monthlyTotals({int count = 5}) {
    final current = parseYmd(today);
    final months = [
      for (var offset = count - 1; offset >= 0; offset--) DateTime.utc(current.year, current.month - offset),
    ];

    return [
      for (final month in months)
        MonthTotal(
          year: month.year,
          month: month.month,
          amount: entries
              .where((entry) => entry.entryDate.startsWith(toYmd(month.year, month.month, 1).substring(0, 7)))
              .fold(0, (total, entry) => total + entry.amount),
          isCurrent: month.year == current.year && month.month == current.month,
        ),
    ];
  }
}

class MonthTotal {
  const MonthTotal({required this.year, required this.month, required this.amount, required this.isCurrent});

  final int year;
  final int month;
  final int amount;
  final bool isCurrent;
}

List<GoalProgress> buildGoalProgress({
  required List<SavingsGoal> goals,
  required List<SavingsEntry> entries,
  required Household household,
  required String Function(String timezone) today,
}) {
  final byGoal = <String, List<SavingsEntry>>{};
  for (final entry in entries) {
    if (entry.deletedAt == null) byGoal.putIfAbsent(entry.savingsGoalId, () => []).add(entry);
  }

  return [
    for (final goal in goals)
      if (goal.deletedAt == null && household.spaceOf(goal.spaceId) != null)
        GoalProgress(
          goal: goal,
          space: household.spaceOf(goal.spaceId)!,
          entries: byGoal[goal.id] ?? const [],
          today: today(household.timezoneOf(goal.spaceId)),
        ),
  ];
}

/// Target "utama" untuk kartu Tabungan di Beranda: target aktif yang paling lama
/// dibuat dan belum tercapai; kalau semuanya sudah tercapai, yang paling lama dibuat.
GoalProgress? primaryGoal(List<GoalProgress> goals) {
  final active = goals.where((progress) => !progress.goal.isArchived).toList();
  return active.where((progress) => !progress.isAchieved).firstOrNull ?? active.firstOrNull;
}

/// Semua target beserta progresnya; `null` selama cache belum terbaca.
final goalProgressProvider = Provider<List<GoalProgress>?>((ref) {
  final goals = ref.watch(goalsProvider).value;
  final entries = ref.watch(entriesProvider).value;
  final household = ref.watch(householdProvider);
  if (goals == null || entries == null || household == null) return null;

  ref.watch(nowProvider);
  final clock = ref.watch(spaceClockProvider);

  return buildGoalProgress(goals: goals, entries: entries, household: household, today: clock.today);
});
