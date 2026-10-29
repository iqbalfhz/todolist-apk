import 'package:freezed_annotation/freezed_annotation.dart';

part 'savings_entry.freezed.dart';
part 'savings_entry.g.dart';

/// Sumber setoran di kontrak. `type` `deposit` untuk setoran, `withdrawal` untuk penarikan (v1.x);
/// `amount` selalu lebih dari 0, arahnya ditentukan `type`.
@freezed
abstract class SavingsEntry with _$SavingsEntry {
  const factory SavingsEntry({
    required String id,
    required String savingsGoalId,
    required String spaceId,

    /// Akun yang mencatat; diisi server.
    String? userId,
    @Default('deposit') String type,
    required int amount,

    /// `YYYY-MM-DD`, tanggal setor menurut HP.
    required String entryDate,
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SavingsEntry;

  factory SavingsEntry.fromJson(Map<String, dynamic> json) => _$SavingsEntryFromJson(json);
}

/// Nilai `type` di kontrak.
abstract final class EntryType {
  static const String deposit = 'deposit';
  static const String withdrawal = 'withdrawal';
}

extension SavingsEntryDirection on SavingsEntry {
  /// Penarikan (v1.x). Nilai `type` lain dianggap setoran, sama seperti server.
  bool get isWithdrawal => type == EntryType.withdrawal;

  /// Nominal bertanda: positif untuk setoran, negatif untuk penarikan.
  int get signedAmount => isWithdrawal ? -amount : amount;
}
