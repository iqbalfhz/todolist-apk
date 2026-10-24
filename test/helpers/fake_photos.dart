import 'dart:io';
import 'dart:typed_data';

import 'package:todolist/core/api/api_transport.dart';
import 'package:todolist/core/database/app_database.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/media/photo_cache.dart';
import 'package:todolist/core/media/photo_files.dart';
import 'package:todolist/core/media/photo_picker.dart';

/// Isi JPEG palsu; cukup untuk antrean dan API palsu, yang tidak membaca gambarnya.
Uint8List fakeJpeg([int seed = 1]) => Uint8List.fromList([0xff, 0xd8, seed, 0xff, 0xd9]);

/// Cache foto di memori. [File] yang dikembalikan hanya penanda; isinya ada di [thumbs] dan [fulls].
class FakePhotoCache implements PhotoCache {
  final Map<String, Uint8List> thumbs = {};
  final Map<String, Uint8List> fulls = {};

  /// URL yang diunduh, urut waktu.
  final List<String> downloads = [];

  /// URL yang ditolak seperti R2 menolak tanda tangan kedaluwarsa (403).
  final Set<String> expired = {};

  /// Selama menyala, unduhan gagal seperti tanpa koneksi.
  bool offline = false;

  /// Folder berkas yang dikembalikan; isi foldernya hanya dibaca kalau tesnya merender gambar.
  String folder = 'cache';

  Map<String, Uint8List> _of(bool thumb) => thumb ? thumbs : fulls;

  File _file(String photoId, bool thumb) => File('$folder/${photoCacheKey(photoId, thumb: thumb)}.jpg');

  @override
  Future<File?> cached(String photoId, {required bool thumb}) async =>
      _of(thumb).containsKey(photoId) ? _file(photoId, thumb) : null;

  @override
  Future<File> download(String photoId, String url, {required bool thumb}) async {
    downloads.add(url);
    if (offline) throw const SocketException('Tanpa koneksi');
    if (expired.contains(url)) throw const PhotoUrlExpired();
    _of(thumb)[photoId] = fakeJpeg();
    return _file(photoId, thumb);
  }

  @override
  Future<void> put(String photoId, Uint8List bytes, {required bool thumb, required String url}) async {
    _of(thumb)[photoId] = bytes;
  }
}

/// Berkas foto yang menunggu diunggah, di memori.
class FakePhotoFiles implements PhotoFiles {
  FakePhotoFiles(this.cache);

  @override
  final PhotoCache cache;

  final Map<String, Uint8List> files = {};

  @override
  Future<Directory> Function() get directory =>
      () async => Directory('foto');

  @override
  Future<File> save(String photoId, Uint8List jpeg) async {
    files[photoId] = jpeg;
    return File('foto/$photoId.jpg');
  }

  @override
  Future<File?> pending(String photoId) async => files.containsKey(photoId) ? File('foto/$photoId.jpg') : null;

  @override
  Future<ApiUpload?> fileFor(OutboxRow op) async {
    final bytes = files[op.entityId];
    if (op.entityType != EntityType.memoryPhoto.name || bytes == null) return null;
    return ApiUpload(field: 'photo', bytes: bytes, filename: '${op.entityId}.jpg', mimeType: 'image/jpeg');
  }

  @override
  Future<void> uploaded(OutboxRow op, Map<String, dynamic> data) async {
    final bytes = files.remove(op.entityId);
    final url = data['url'] as String?;
    if (bytes != null && url != null) await cache.put(op.entityId, bytes, thumb: false, url: url);
  }

  @override
  Future<void> discard(EntityType type, String id) async {
    if (type == EntityType.memoryPhoto) files.remove(id);
  }
}

/// Galeri palsu: [picks] dibalas berurutan, satu daftar per pemilihan.
class FakePhotoPicker implements PhotoPicker {
  final List<List<String>> picks = [];

  /// Batas yang diminta setiap pemilihan.
  final List<int> limits = [];

  /// Berkas yang tidak bisa dibaca sebagai gambar.
  final Set<String> unreadable = {};

  /// Berkas yang disiapkan, urut waktu.
  final List<String> prepared = [];

  @override
  Future<List<String>> pickFromGallery({required int limit}) async {
    limits.add(limit);
    if (picks.isEmpty) return const [];
    return picks.removeAt(0).take(limit).toList();
  }

  @override
  Future<PreparedPhoto?> prepare(String path) async {
    prepared.add(path);
    if (unreadable.contains(path)) return null;
    return PreparedPhoto(
      jpeg: fakeJpeg(prepared.length),
      width: 2560,
      height: 1920,
      takenAt: '2027-06-20T10:12:45+07:00',
    );
  }
}
