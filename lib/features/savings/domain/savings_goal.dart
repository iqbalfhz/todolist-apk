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
    DateTime? achievedAt,
    DateTime? archivedAt,
    String? createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SavingsGoal;

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => _$SavingsGoalFromJson(json);

  bool get isArchived => archivedAt != null;
}
