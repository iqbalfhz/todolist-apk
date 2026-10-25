import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// URL foto ditolak R2 dengan 403: tanda tangannya sudah kedaluwarsa.
class PhotoUrlExpired implements Exception {
  const PhotoUrlExpired();
}

/// Cache gambar foto kenangan (v0.3).
///
/// Kuncinya `photo-{id}` untuk versi penuh dan `photo-{id}-thumb` untuk thumbnail, bukan
/// URL-nya: URL bertanda tangan berganti setiap 7 hari, sedangkan gambarnya tidak pernah berubah.
abstract interface class PhotoCache {
  /// Gambar yang sudah ada di cache, atau `null`.
  Future<File?> cached(String photoId, {required bool thumb});

  /// Unduh lalu simpan. Melempar [PhotoUrlExpired] kalau R2 membalas 403.
  Future<File> download(String photoId, String url, {required bool thumb});

  /// Simpan gambar yang sudah ada di HP, misalnya foto yang baru diunggah dari HP ini.
  Future<void> put(String photoId, Uint8List bytes, {required bool thumb, required String url});

  /// Hapus semua gambar, misalnya saat keluar.
  Future<void> clear();
}

/// Kunci cache sebuah foto, sesuai kontrak.
String photoCacheKey(String photoId, {required bool thumb}) => thumb ? 'photo-$photoId-thumb' : 'photo-$photoId';

/// [PhotoCache] di atas flutter_cache_manager (bawaan cached_network_image).
class DevicePhotoCache implements PhotoCache {
  DevicePhotoCache._();

  static final DevicePhotoCache instance = DevicePhotoCache._();

  /// Thumbnail disimpan lama, supaya linimasa dan galeri tetap tampil saat offline.
  final CacheManager _thumbs = CacheManager(
    Config('denly_foto_kecil', stalePeriod: const Duration(days: 3650), maxNrOfCacheObjects: 20000),
  );

  /// Versi penuh hanya untuk foto yang pernah dibuka; yang lama tidak dibuka dibuang lebih dulu.
  final CacheManager _full = CacheManager(
    Config('denly_foto', stalePeriod: const Duration(days: 180), maxNrOfCacheObjects: 600),
  );

  CacheManager _of({required bool thumb}) => thumb ? _thumbs : _full;

  @override
  Future<File?> cached(String photoId, {required bool thumb}) async {
    final info = await _of(thumb: thumb).getFileFromCache(photoCacheKey(photoId, thumb: thumb));
    return info?.file;
  }

  @override
  Future<File> download(String photoId, String url, {required bool thumb}) async {
    try {
      final info = await _of(thumb: thumb).downloadFile(url, key: photoCacheKey(photoId, thumb: thumb));
      return info.file;
    } on HttpExceptionWithStatus catch (error) {
      if (error.statusCode == HttpStatus.forbidden) throw const PhotoUrlExpired();
      rethrow;
    }
  }

  @override
  Future<void> put(String photoId, Uint8List bytes, {required bool thumb, required String url}) async {
    await _of(thumb: thumb).putFile(
      url,
      bytes,
      key: photoCacheKey(photoId, thumb: thumb),
      maxAge: const Duration(days: 3650),
      fileExtension: 'jpg',
    );
  }

  @override
  Future<void> clear() async {
    await _thumbs.emptyCache();
    await _full.emptyCache();
  }
}

/// Tanpa cache: dipakai di tes dan HP uji yang tidak menampilkan foto.
class NoPhotoCache implements PhotoCache {
  const NoPhotoCache();

  @override
  Future<File?> cached(String photoId, {required bool thumb}) async => null;

  @override
  Future<File> download(String photoId, String url, {required bool thumb}) =>
      throw const SocketException('Tanpa cache foto');

  @override
  Future<void> put(String photoId, Uint8List bytes, {required bool thumb, required String url}) async {}

  @override
  Future<void> clear() async {}
}

/// Kapan URL bertanda tangan R2 (AWS SigV4) kedaluwarsa, dibaca dari `X-Amz-Date` dan
/// `X-Amz-Expires`. `null` kalau URL-nya tidak membawa keduanya.
DateTime? signedUrlExpiry(String url) {
  final query = Uri.tryParse(url)?.queryParameters;
  final signedAt = query?['X-Amz-Date'];
  final seconds = int.tryParse(query?['X-Amz-Expires'] ?? '');
  if (signedAt == null || seconds == null) return null;

  final match = RegExp(r'^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})Z$').firstMatch(signedAt);
  if (match == null) return null;
  final parts = [for (var i = 1; i <= 6; i++) int.parse(match.group(i)!)];
  return DateTime.utc(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5]).add(Duration(seconds: seconds));
}

/// URL yang sudah atau hampir kedaluwarsa. Diberi jeda satu jam, supaya unduhan yang
/// dimulai sekarang tidak gagal di tengah jalan.
bool isSignedUrlExpired(String url, DateTime now) {
  final expiry = signedUrlExpiry(url);
  return expiry != null && !now.isBefore(expiry.subtract(const Duration(hours: 1)));
}
