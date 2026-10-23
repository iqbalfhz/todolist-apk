import 'package:freezed_annotation/freezed_annotation.dart';

part 'savings_goal.freezed.dart';
part 'savings_goal.g.dart';

/// Sumber target tabungan di kontrak. Nominal dalam satuan terkecil mata uangnya.
@freezed
abstract class SavingsGoal with _$SavingsGoal {
  const SavingsGoal._();

  const factory SavingsGoal({
    required String id,
    required String spaceId,
    required String name,
    String? emoji,
    required int targetAmount,
    required String currency,

    /// `YYYY-MM-DD`; dipakai untuk menghitung setoran per minggu yang dibutuhkan.
    String? targetDate,

    /// Pengingat setor rutin (v0.2): `weekly`, `monthly`, atau `null` (tanpa pengingat).
    String? reminderFrequency,

    /// 1–7 untuk mingguan (1 = Senin), 1–31 untuk bulanan.
    int? reminderDay,
    DateTime? achievedAt,
    DateTime? archivedAt,
    String? createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SavingsGoal;

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => _$SavingsGoalFromJson(json);

  bool get isArchived => archivedAt != null;

  /// Jadwal pengingat setor, atau `null` kalau tidak diingatkan.
  SavingsReminder? get reminder => SavingsReminder.tryFrom(reminderFrequency, reminderDay);
}

/// Seberapa sering pengingat setor dikirim. Namanya sama dengan nilai `reminder_frequency` di kontrak.
enum ReminderFrequency {
  weekly,
  monthly;

  /// Hari terakhir yang boleh dipilih: Minggu (7) untuk mingguan, tanggal 31 untuk bulanan.
  int get lastDay => this == weekly ? 7 : 31;
}

/// Jadwal pengingat setor sebuah target: pukul 08.00 di zona waktu ruangnya, tiap minggu
/// pada hari [day] (1 = Senin, 7 = Minggu), atau tiap bulan pada tanggal [day]. Tanggal yang
/// tidak ada di bulan yang lebih pendek jatuh ke hari terakhir bulan itu.
class SavingsReminder {
  const SavingsReminder({required this.frequency, required this.day});

  final ReminderFrequency frequency;
  final int day;

  /// Jadwal yang tidak dikenal atau di luar batas dianggap tidak ada.
  static SavingsReminder? tryFrom(String? frequency, int? day) {
    final parsed = ReminderFrequency.values.where((value) => value.name == frequency).firstOrNull;
    if (parsed == null || day == null || day < 1 || day > parsed.lastDay) return null;
    return SavingsReminder(frequency: parsed, day: day);
  }

  @override
  bool operator ==(Object other) => other is SavingsReminder && other.frequency == frequency && other.day == day;

  @override
  int get hashCode => Object.hash(frequency, day);
}
