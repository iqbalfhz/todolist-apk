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

    /// Pin lokasi (v1.x), selalu berpasangan dengan [longitude]; dibulatkan ke 6 desimal.
    double? latitude,
    double? longitude,

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

/// Titik di peta: lintang dan bujur dalam derajat.
class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  /// Titik yang bisa disimpan server: lintang -90..90 dan bujur -180..180, dibulatkan ke
  /// 6 desimal (sekitar 11 cm) seperti di server, supaya salinan lokal sama dengan server.
  /// `null` kalau di luar jangkauan atau bukan angka.
  static GeoPoint? tryCreate(num latitude, num longitude) {
    final lat = latitude.toDouble();
    final lng = longitude.toDouble();
    if (!lat.isFinite || !lng.isFinite || lat.abs() > 90 || lng.abs() > 180) return null;
    return GeoPoint(round6(lat), round6(lng));
  }

  static double round6(double value) => (value * 1000000).round() / 1000000;

  @override
  bool operator ==(Object other) => other is GeoPoint && other.latitude == latitude && other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'GeoPoint($latitude, $longitude)';
}

extension MemoryPin on Memory {
  /// Pin lokasi, atau `null` kalau kenangan ini belum diberi pin.
  GeoPoint? get pin {
    final lat = latitude;
    final lng = longitude;
    return lat == null || lng == null ? null : GeoPoint(lat, lng);
  }
}

/// Hasil `GET /places` (v1.x): tempat dari OpenStreetMap lewat server.
class Place {
  const Place({required this.name, required this.address, required this.point});

  factory Place.fromJson(Map<String, dynamic> json) => Place(
    name: json['name'] as String? ?? '',
    address: json['address'] as String? ?? '',
    point: GeoPoint((json['latitude'] as num).toDouble(), (json['longitude'] as num).toDouble()),
  );

  final String name;
  final String address;
  final GeoPoint point;
}
