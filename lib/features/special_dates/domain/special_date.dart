import 'package:freezed_annotation/freezed_annotation.dart';

part 'special_date.freezed.dart';
part 'special_date.g.dart';

/// Jenis tanggal penting. Namanya sama dengan nilai `type` di kontrak.
enum SpecialDateType {
  birthday,
  anniversary,

  /// "Lainnya".
  other;

  /// Jenis yang belum dikenal versi app ini dianggap "Lainnya".
  static SpecialDateType parse(String value) =>
      values.firstWhere((type) => type.name == value, orElse: () => SpecialDateType.other);
}

/// Sumber tanggal penting di kontrak (v0.2): acara tahunan seperti hari jadi
/// atau ulang tahun orang lain. Ulang tahun anggota ruang tidak dicatat di sini,
/// tetapi diambil dari `birth_date` di profil.
@freezed
abstract class SpecialDate with _$SpecialDate {
  const SpecialDate._();

  const factory SpecialDate({
    required String id,
    required String spaceId,

    /// `birthday`, `anniversary`, atau `other`.
    required String type,
    required String title,

    /// `YYYY-MM-DD`, atau `--MM-DD` kalau tahunnya tidak diketahui.
    required String date,
    String? createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SpecialDate;

  factory SpecialDate.fromJson(Map<String, dynamic> json) => _$SpecialDateFromJson(json);

  SpecialDateType get kind => SpecialDateType.parse(type);
}
