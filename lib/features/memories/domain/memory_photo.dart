import 'package:freezed_annotation/freezed_annotation.dart';

part 'memory_photo.freezed.dart';
part 'memory_photo.g.dart';

/// Sumber foto kenangan di kontrak (v0.3). Foto dengan [position] terkecil menjadi sampul.
@freezed
abstract class MemoryPhoto with _$MemoryPhoto {
  const MemoryPhoto._();

  const factory MemoryPhoto({
    required String id,
    required String memoryId,
    required String spaceId,
    String? uploadedBy,
    required double position,

    /// Ukuran versi penuh, paling besar 2560 px di sisi terpanjang.
    int? width,
    int? height,
    DateTime? takenAt,

    /// URL bertanda tangan yang berlaku 7 hari; kosong selama foto belum terunggah.
    String? url,
    String? thumbUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _MemoryPhoto;

  factory MemoryPhoto.fromJson(Map<String, dynamic> json) => _$MemoryPhotoFromJson(json);

  /// Sudah tersimpan di server, jadi punya URL.
  bool get isUploaded => url != null;

  /// Lebar dibagi tinggi, atau `null` kalau ukurannya belum diketahui.
  double? get aspectRatio {
    final w = width;
    final h = height;
    return w == null || h == null || w <= 0 || h <= 0 ? null : w / h;
  }
}
