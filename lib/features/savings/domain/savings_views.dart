import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/utils/dates.dart';
import '../../spaces/domain/household.dart';
import '../../spaces/domain/space.dart';
import 'savings_entry.dart';
import 'savings_goal.dart';

/// Target beserta setoran dan progresnya. Progres dihitung di HP dari daftar setoran: jumlah
/// setoran dikurangi jumlah penarikan (v1.x).
class GoalProgress {
  const GoalProgress({required this.goal, required this.space, required this.entries, required this.today});

  final SavingsGoal goal;
  final Space space;

  /// Setoran dan penarikan target ini, yang terbaru lebih dulu.
  final List<SavingsEntry> entries;

  /// Tanggal hari ini (`YYYY-MM-DD`) di zona waktu ruang target ini.
  final String today;

  /// Total bersih. Bisa negatif kalau dua HP mencatat penarikan bersamaan saat offline.
  int get saved => entries.fold(0, (total, entry) => total + entry.signedAmount);

  /// Yang masih bisa diambil: total bersih, paling kecil 0.
  int get available => math.max(0, saved);

  int get remaining => math.max(0, goal.targetAmount - saved);

  bool get isAchieved => saved >= goal.targetAmount;

  /// Bagian yang terkumpul, 0 sampai 1.
  double get fraction => goal.targetAmount <= 0 ? 0 : (saved / goal.targetAmount).clamp(0, 1).toDouble();

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

  /// Kontribusi tiap orang di target bersama, dengan bagiannya dari total terkumpul (persen
  /// yang jumlahnya selalu 100). Urutannya Aku, Pasangan, lalu setoran dari akun yang sudah
  /// bukan anggota (kalau ada). Setoran tanpa `user_id` dihitung milik [meId], sama seperti
  /// di riwayat.
  ///
  /// Nominalnya bersih: setoran orang itu dikurangi penarikannya, jadi bisa negatif kalau ia
  /// mengambil lebih dari yang ia setor. Bagian persen hanya dibagi di antara yang positif.
  List<Contribution> contributions({required String meId, required String? partnerId}) {
    final totals = <Contributor, int>{};
    for (final entry in entries) {
      final userId = entry.userId;
      final who = userId == null || userId == meId
          ? Contributor.me
          : userId == partnerId
          ? Contributor.partner
          : Contributor.former;
      totals[who] = (totals[who] ?? 0) + entry.signedAmount;
    }

    final who = [
      Contributor.me,
      if (partnerId != null) Contributor.partner,
      if (totals.containsKey(Contributor.former)) Contributor.former,
    ];
    final amounts = [for (final item in who) totals[item] ?? 0];
    final percents = sharePercents([for (final amount in amounts) math.max(0, amount)]);
    return [for (var i = 0; i < who.length; i++) Contribution(who: who[i], amount: amounts[i], percent: percents[i])];
  }

  /// Jumlah setoran per bulan untuk [count] bulan terakhir sampai bulan ini. Penarikan tidak
  /// ikut: grafiknya "Setoran per bulan", dan penarikan tampil di riwayat.
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
              .where((entry) => !entry.isWithdrawal)
              .where((entry) => entry.entryDate.startsWith(toYmd(month.year, month.month, 1).substring(0, 7)))
              .fold(0, (total, entry) => total + entry.amount),
          isCurrent: month.year == current.year && month.month == current.month,
        ),
    ];
  }
}

/// Pemilik setoran di target bersama, dari sudut pandang pengguna.
enum Contributor { me, partner, former }

/// Kontribusi satu orang: total bersih setorannya dan bagiannya dari total terkumpul.
class Contribution {
  const Contribution({required this.who, required this.amount, required this.percent});

  final Contributor who;
  final int amount;

  /// Bagian dari total terkumpul, 0–100. Semua bagian satu target berjumlah 100, kecuali
  /// totalnya 0 atau kurang.
  final int percent;
}

/// Bagian tiap nominal dari jumlahnya dalam persen bulat yang totalnya tepat 100 (metode sisa
/// terbesar), supaya "62% + 37%" tidak pernah tampil. Semua nol menghasilkan semua nol.
List<int> sharePercents(List<int> amounts) {
  final total = amounts.fold(0, (sum, amount) => sum + amount);
  if (total <= 0) return [for (final _ in amounts) 0];

  final exact = [for (final amount in amounts) amount * 100 / total];
  final percents = [for (final value in exact) value.floor()];
  var left = 100 - percents.fold(0, (sum, value) => sum + value);

  // Sisa dibagikan ke pecahan terbesar; yang sama besar, yang lebih dulu.
  final order = [for (var i = 0; i < amounts.length; i++) i]
    ..sort((a, b) {
      final byFraction = (exact[b] - percents[b]).compareTo(exact[a] - percents[a]);
      return byFraction != 0 ? byFraction : a.compareTo(b);
    });
  for (final index in order) {
    if (left == 0) break;
    percents[index]++;
    left--;
  }
  return percents;
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
