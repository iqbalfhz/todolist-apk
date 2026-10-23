import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip.freezed.dart';
part 'trip.g.dart';

/// Sumber perjalanan di kontrak (v0.2): rencana liburan dengan tujuan, tanggal,
/// catatan, dan tautan ke target tabungan. Checklist persiapannya adalah daftar
/// tugas yang `trip_id`-nya berisi ID perjalanan ini.
@freezed
abstract class Trip with _$Trip {
  const Trip._();

  const factory Trip({
    required String id,
    required String spaceId,
    required String title,
    String? destination,

    /// `YYYY-MM-DD`; kosong berarti tanggalnya belum pasti.
    String? startDate,

    /// `YYYY-MM-DD`, tidak lebih awal dari [startDate]; kosong berarti perjalanannya sehari.
    String? endDate,
    String? notes,

    /// Target tabungan di ruang yang sama; dikosongkan server kalau targetnya dihapus.
    String? savingsGoalId,
    String? createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _Trip;

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);

  /// Hari terakhir perjalanan: [endDate], atau [startDate] kalau perjalanannya sehari.
  String? get lastDate => endDate ?? startDate;
}
