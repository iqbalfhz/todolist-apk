import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import '../../../core/api/api_transport.dart';
import '../../../core/media/photo_cache.dart';
import '../../../core/platform/device_platform.dart';
import '../../../core/utils/ulid.dart';

/// Hasil ekspor data (v1.0): berkas JSON persis seperti balasan server, dan foto yang bisa
/// diunduh sesudahnya lewat tautan di dalamnya.
class DataExport {
  const DataExport({required this.fileName, required this.bytes, required this.photos});

  /// Dari `Content-Disposition`, misalnya `denly-days-2026-10-31.json`.
  final String fileName;
  final Uint8List bytes;

  /// Foto profil dan foto kenangan, dengan tautan yang berlaku 7 hari.
  final List<ExportPhoto> photos;

  /// Folder hasil ekspor di HP: nama berkasnya tanpa `.json`.
  String get folder => fileName.substring(0, fileName.length - '.json'.length);
}

/// Satu foto yang ikut diekspor lewat tautan.
class ExportPhoto {
  const ExportPhoto({required this.cacheId, required this.fileName, required this.url, this.isAvatar = false});

  /// Kunci di cache foto: ID foto kenangan, atau `profil-{id akun}` untuk foto profil.
  final String cacheId;
  final String fileName;
  final String url;

  /// Foto profil selalu diunduh ulang, karena bisa sudah diganti sejak tersimpan di cache.
  final bool isAvatar;
}

final RegExp _safeFileName = RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]*\.json$');

/// Nama berkas dari header `Content-Disposition`. Nama yang tidak aman sebagai nama berkas
/// diganti `denly-days-{tanggal}.json` menurut tanggal di HP.
String exportFileName(String? contentDisposition, DateTime now) {
  final match = RegExp(r'filename="?([^";]+)"?').firstMatch(contentDisposition ?? '');
  final name = match?.group(1)?.trim();
  if (name != null && _safeFileName.hasMatch(name) && !name.contains('..')) return name;

  String two(int value) => value.toString().padLeft(2, '0');
  return 'denly-days-${now.year}-${two(now.month)}-${two(now.day)}.json';
}

/// Foto yang bisa diunduh dari isi ekspor: foto profil (`user.avatar_url`) dan setiap
/// `memory_photos` yang punya `url`. Nama berkasnya ID foto, supaya bisa dicocokkan ke JSON.
List<ExportPhoto> exportPhotos(Map<String, dynamic> json) {
  final photos = <ExportPhoto>[];

  final user = json['user'];
  if (user is Map<String, dynamic> && user['avatar_url'] is String) {
    photos.add(
      ExportPhoto(
        cacheId: 'profil-${user['id']}',
        fileName: 'foto-profil.jpg',
        url: user['avatar_url'] as String,
        isAvatar: true,
      ),
    );
  }

  for (final photo in json['memory_photos'] as List<dynamic>? ?? const []) {
    if (photo is! Map<String, dynamic>) continue;
    final id = photo['id'];
    final url = photo['url'];
    // ID dari server hanya dipakai sebagai nama berkas kalau berbentuk ULID.
    if (id is! String || !ulidPattern.hasMatch(id) || url is! String) continue;
    photos.add(ExportPhoto(cacheId: id, fileName: '$id.jpg', url: url));
  }

  return photos;
}

/// Ekspor data (v1.0): `GET /me/export`, langsung dan butuh koneksi.
class ExportRepository {
  ExportRepository(this.api);

  final ApiTransport api;

  /// Ambil berkas ekspor. Lebih dari 5 kali per jam dibalas 429 `too_many_requests`, dengan
  /// `retryAfter` dari header `Retry-After`.
  Future<DataExport> fetch({DateTime? now}) async {
    final response = await api.send('GET', '/me/export');
    final body = response.body ?? const <String, dynamic>{};
    return DataExport(
      fileName: exportFileName(response.headers['content-disposition'], now ?? DateTime.now()),
      // Disimpan apa adanya; tanpa teks mentah (API palsu di tes), JSON-nya ditulis ulang.
      bytes: utf8.encode(response.raw ?? jsonEncode(body)),
      photos: exportPhotos(body),
    );
  }
}

/// Tempat menyimpan hasil ekspor di HP. Ditimpa di tes.
abstract interface class ExportSaver {
  /// Simpan [bytes] sebagai [name] di folder ekspor [folder]. Mengembalikan letak foldernya,
  /// untuk ditunjukkan ke pengguna.
  Future<String> save({
    required String folder,
    required String name,
    required String mimeType,
    required Uint8List bytes,
  });
}

/// [ExportSaver] ke `Download/Denly Days/{folder}` lewat MediaStore (`MainActivity.kt`).
class DeviceExportSaver implements ExportSaver {
  const DeviceExportSaver(this.platform);

  final DevicePlatform platform;

  @override
  Future<String> save({
    required String folder,
    required String name,
    required String mimeType,
    required Uint8List bytes,
  }) => platform.saveDownload(folder: folder, name: name, mimeType: mimeType, bytes: bytes);
}

/// Mengambil isi foto yang diekspor. Ditimpa di tes.
abstract interface class ExportPhotoFetcher {
  Future<Uint8List> fetch(ExportPhoto photo);
}

/// Foto kenangan diambil dari cache kalau sudah pernah dibuka di HP ini; sisanya diunduh
/// lewat tautan di berkas ekspor dan ikut tersimpan di cache.
class CachedExportPhotoFetcher implements ExportPhotoFetcher {
  const CachedExportPhotoFetcher(this.cache);

  final PhotoCache cache;

  @override
  Future<Uint8List> fetch(ExportPhoto photo) async {
    final File file =
        (photo.isAvatar ? null : await cache.cached(photo.cacheId, thumb: false)) ??
        await cache.download(photo.cacheId, photo.url, thumb: false);
    return file.readAsBytes();
  }
}

/// Error saat menyimpan ke HP, misalnya penyimpanan penuh.
bool isSaveFailure(Object error) => error is PlatformException || error is FileSystemException;
