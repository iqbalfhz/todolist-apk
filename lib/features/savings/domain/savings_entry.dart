import 'package:freezed_annotation/freezed_annotation.dart';

part 'savings_entry.freezed.dart';
part 'savings_entry.g.dart';

/// Sumber setoran di kontrak. `type` di v0.1 selalu `deposit`.
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
