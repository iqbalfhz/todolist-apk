import 'package:freezed_annotation/freezed_annotation.dart';

part 'memory.freezed.dart';
part 'memory.g.dart';

/// Sumber kenangan di kontrak (v0.3): tempat yang pernah didatangi, dengan tanggal,
/// cerita, dan paling banyak 50 foto. Bisa berasal dari perjalanan yang sudah selesai.
@freezed
abstract class Memory with _$Memory {
  const factory Memory({
    required String id,
    required String spaceId,

    /// Perjalanan asalnya; dikosongkan server kalau perjalanannya dihapus.
    String? tripId,
    required String title,
    String? placeName,

    /// `YYYY-MM-DD`; tanggal kenangan di linimasa.
    required String visitedOn,
    String? story,
    String? createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _Memory;

  factory Memory.fromJson(Map<String, dynamic> json) => _$MemoryFromJson(json);
}
