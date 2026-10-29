import 'dart:math' as math;

import '../../../core/api/api_error.dart';
import '../../../core/api/api_transport.dart';
import '../../../core/database/entity_type.dart';
import '../../../core/database/local_writer.dart';
import '../../../core/media/photo_files.dart';
import '../../../core/media/photo_picker.dart';
import '../../../core/sync/row_applier.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/ulid.dart';
import '../../../core/utils/validators.dart';
import '../domain/memory.dart';
import '../domain/memory_photo.dart';

/// Kenangan dan fotonya (v0.3): dibaca dari cache lokal, ditulis lewat antrean.
///
/// Foto diunggah satu per satu lewat `POST /memory-photos/{id}`, setelah `PUT` kenangannya.
/// Berkasnya yang sudah dikompres disimpan di [files] sampai server membalas. Kedua anggota
/// Ruang Bersama boleh mengubah dan menghapus kenangan dan foto siapa pun.
class MemoryRepository {
  MemoryRepository({
    required this.writer,
    required this.api,
    required this.applier,
    required this.files,
    required this.userId,
  });

  final LocalWriter writer;
  final ApiTransport api;
  final RowApplier applier;
  final PhotoFiles files;
  final String userId;

  Stream<List<Memory>> watchAll() => writer.store.watchMemories();

  Stream<List<MemoryPhoto>> watchPhotos() => writer.store.watchMemoryPhotos();

  /// Buat kenangan. [visitedOn] berformat `YYYY-MM-DD`; [tripId] diisi lewat "Simpan jadi kenangan".
  /// [pin] (v1.x) hanya dikirim kalau diisi; tanpa itu server menyimpannya tanpa pin.
  Future<Memory> create({
    required String spaceId,
    required String title,
    String? placeName,
    required String visitedOn,
    String? story,
    String? tripId,
    GeoPoint? pin,
  }) async {
    final fields = _validated(title: title, placeName: placeName, visitedOn: visitedOn, story: story);
    final nowIso = writer.nowIso();

    final payload = <String, dynamic>{
      'space_id': spaceId,
      ...fields,
      'trip_id': tripId,
      if (pin != null) ..._pinFields(pin),
    };
    final row = <String, dynamic>{
      ...payload,
      'id': newUlid(now: writer.now()),
      'created_by': userId,
      'created_at': nowIso,
      'updated_at': nowIso,
      'deleted_at': null,
    };

    await writer.create(EntityType.memory, row, payload);
    return Memory.fromJson(row);
  }

  /// Hanya kolom yang berubah yang dikirim.
  Future<void> edit(
    String id, {
    required String title,
    required String? placeName,
    required String visitedOn,
    required String? story,
  }) => writer.update(
    EntityType.memory,
    id,
    _validated(title: title, placeName: placeName, visitedOn: visitedOn, story: story),
  );

  /// Pasang, pindahkan, atau lepas ([pin] `null`) pin lokasi (v1.x). Lintang dan bujur selalu
  /// dikirim berdua, karena server menolak salah satunya saja.
  Future<void> setPin(String id, GeoPoint? pin) => writer.update(
    EntityType.memory,
    id,
    pin == null ? {'latitude': null, 'longitude': null} : _pinFields(pin),
    sendTogether: true,
  );

  /// Cari tempat lewat `GET /places` (v1.x), langsung ke server dan butuh koneksi. Dipanggil
  /// hanya saat tombol cari ditekan, karena kebijakan Nominatim melarang pencarian sambil
  /// mengetik. [query] harus 3–100 karakter.
  Future<List<Place>> searchPlaces(String query) async {
    final response = await api.send('GET', '/places', query: {'q': query.trim()});
    return [for (final row in response.dataList) Place.fromJson(row)];
  }

  /// Hapus kenangan; server ikut menghapus fotonya, dan penghapusan itu sampai lewat sync.
  ///
  /// Kenangan tanpa foto dihapus dengan jeda Urungkan ([undoable]); yang berfoto dihapus
  /// setelah konfirmasi, dan fotonya yang belum terunggah tidak dikirim lagi. Mengembalikan
  /// ID operasi untuk [undo].
  Future<int?> delete(String id, {bool undoable = false}) async {
    if (!undoable) {
      final photos = await writer.store.memoryPhotos(id);
      await writer.outbox.cancelUploads(EntityType.memoryPhoto, [
        for (final photo in photos)
          if (!photo.isUploaded) photo.id,
      ]);
    }
    return writer.delete(EntityType.memory, id, undoable: undoable);
  }

  /// Tambahkan foto yang sudah disiapkan ke [memory], di belakang foto yang ada. Yang melewati
  /// batas [Limits.memoryPhotos] tidak ditambahkan. Mengembalikan jumlah foto yang masuk.
  Future<int> addPhotos(Memory memory, List<PreparedPhoto> photos) async {
    final existing = await writer.store.memoryPhotos(memory.id);
    final accepted = photos.take(math.max(0, Limits.memoryPhotos - existing.length)).toList();
    var position = await writer.nextPosition(EntityType.memoryPhoto, parentId: memory.id);

    for (final photo in accepted) {
      final id = newUlid(now: writer.now());
      final nowIso = writer.nowIso();
      await files.save(id, photo.jpeg);

      final payload = <String, dynamic>{'memory_id': memory.id, 'position': position, 'taken_at': photo.takenAt};
      final row = <String, dynamic>{
        ...payload,
        'id': id,
        'space_id': memory.spaceId,
        'uploaded_by': userId,
        'width': photo.width,
        'height': photo.height,
        'url': null,
        'thumb_url': null,
        'created_at': nowIso,
        'updated_at': nowIso,
        'deleted_at': null,
      };

      await writer.upload(EntityType.memoryPhoto, row, payload);
      position += positionStep;
    }
    return accepted.length;
  }

  /// "Jadikan sampul": pindahkan foto ke depan, sebelum foto pertama kenangannya.
  Future<void> makeCover(MemoryPhoto photo) async {
    final photos = await writer.store.memoryPhotos(photo.memoryId);
    final first = photos.firstOrNull;
    if (first == null || first.id == photo.id) return;
    await writer.update(EntityType.memoryPhoto, photo.id, {'position': first.position - positionStep});
  }

  /// Hapus foto. Operasinya menunggu 5 detik selama tombol Urungkan tampil.
  /// Mengembalikan ID operasi untuk [undo].
  Future<int?> deletePhoto(String photoId) => writer.delete(EntityType.memoryPhoto, photoId, undoable: true);

  /// Urungkan hapus foto atau kenangan. `false` kalau operasinya sudah terlanjur dikirim.
  Future<bool> undo(int opId) => writer.outbox.undo(opId);

  /// Ambil URL baru (berlaku 7 hari) untuk semua foto [memoryId], langsung ke server.
  /// Kenangan yang sudah dihapus atau tidak dikenal server tidak punya foto.
  Future<List<MemoryPhoto>> refreshPhotos(String memoryId) async {
    try {
      final response = await api.send('GET', '/memories/$memoryId/photos');
      final rows = response.dataList;
      for (final row in rows) {
        await applier.apply(EntityType.memoryPhoto, row);
      }
      return [for (final row in rows) MemoryPhoto.fromJson(row)];
    } on ApiError catch (error) {
      if (error.code == ApiErrorCode.resourceDeleted || error.code == ApiErrorCode.notFound) return const [];
      rethrow;
    }
  }

  // ---------------------------------------------------------------- validasi

  static Map<String, dynamic> _pinFields(GeoPoint pin) {
    final valid = GeoPoint.tryCreate(pin.latitude, pin.longitude);
    if (valid == null) throw ArgumentError.value(pin, 'pin', 'Lintang -90..90 dan bujur -180..180.');
    return {'latitude': valid.latitude, 'longitude': valid.longitude};
  }

  /// Kolom isi kenangan yang sudah dirapikan, dengan aturan yang sama seperti server.
  static Map<String, dynamic> _validated({
    required String title,
    required String? placeName,
    required String visitedOn,
    required String? story,
  }) {
    final cleanTitle = title.trim();
    if (!isValidRequiredText(cleanTitle, Limits.memoryTitle)) {
      throw ArgumentError.value(title, 'title', 'Judul wajib diisi, paling banyak ${Limits.memoryTitle} karakter.');
    }

    final cleanPlace = nullIfBlank(placeName);
    if (cleanPlace != null && textLength(cleanPlace) > Limits.memoryPlace) {
      throw ArgumentError.value(placeName, 'placeName', 'Nama tempat paling banyak ${Limits.memoryPlace} karakter.');
    }

    if (!isValidYmd(visitedOn)) {
      throw ArgumentError.value(visitedOn, 'visitedOn', 'Tanggal harus YYYY-MM-DD.');
    }

    final cleanStory = nullIfBlank(story);
    if (cleanStory != null && textLength(cleanStory) > Limits.memoryStory) {
      throw ArgumentError.value(story, 'story', 'Cerita paling banyak ${Limits.memoryStory} karakter.');
    }

    return {'title': cleanTitle, 'place_name': cleanPlace, 'visited_on': visitedOn, 'story': cleanStory};
  }
}
