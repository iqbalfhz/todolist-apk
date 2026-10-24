import 'dart:async';
import 'dart:io';

import '../../../core/media/photo_cache.dart';
import '../../../core/media/photo_files.dart';
import '../domain/memory_photo.dart';

/// Gambar foto kenangan untuk layar (v0.3).
///
/// Urutan sumbernya: cache gambar, berkas yang belum selesai diunggah dari HP ini, lalu
/// unduhan. URL yang sudah berumur 7 hari, atau yang ditolak R2 dengan 403, diganti dulu
/// lewat [refreshUrls] (`GET /memories/{id}/photos`), langsung ke server.
class MemoryPhotoImages {
  MemoryPhotoImages({required this.cache, required this.files, required this.refreshUrls, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final PhotoCache cache;
  final PhotoFiles files;

  /// Foto kenangan itu dengan URL baru; juga memperbarui cache lokal.
  final Future<List<MemoryPhoto>> Function(String memoryId) refreshUrls;
  final DateTime Function() _now;

  final Map<String, Future<File?>> _loading = {};
  final Map<String, Future<List<MemoryPhoto>>> _refreshing = {};

  /// Thumbnail untuk linimasa dan kisi foto. Versi penuh yang sudah ada di HP juga dipakai,
  /// supaya foto yang baru diunggah tidak perlu diunduh lagi.
  Future<File?> thumb(MemoryPhoto photo) => _once('${photo.id}-thumb', () async {
    return await cache.cached(photo.id, thumb: true) ??
        await files.pending(photo.id) ??
        await cache.cached(photo.id, thumb: false) ??
        await _download(photo, thumb: true);
  });

  /// Versi penuh untuk galeri; diunduh saat foto dibuka.
  Future<File?> full(MemoryPhoto photo) => _once(photo.id, () async {
    return await cache.cached(photo.id, thumb: false) ??
        await files.pending(photo.id) ??
        await _download(photo, thumb: false);
  });

  /// Unduh thumbnail yang belum ada di HP, dipanggil tepat setelah sync supaya linimasa dan
  /// galeri tetap tampil saat offline. Berhenti setelah tiga kegagalan berturut-turut,
  /// yang biasanya berarti koneksinya putus.
  Future<void> prefetchThumbs(Iterable<MemoryPhoto> photos) async {
    var failures = 0;
    for (final photo in photos) {
      if (photo.thumbUrl == null || await cache.cached(photo.id, thumb: true) != null) continue;
      try {
        await thumb(photo);
        failures = 0;
      } on Object {
        if (++failures >= 3) return;
      }
    }
  }

  Future<File?> _download(MemoryPhoto photo, {required bool thumb}) async {
    // Belum terunggah dari HP pasangan: belum ada yang bisa diunduh.
    var url = thumb ? photo.thumbUrl : photo.url;
    if (url == null) return null;

    if (isSignedUrlExpired(url, _now())) {
      url = await _freshUrl(photo, thumb: thumb);
      if (url == null) return null;
    }

    try {
      return await cache.download(photo.id, url, thumb: thumb);
    } on PhotoUrlExpired {
      final fresh = await _freshUrl(photo, thumb: thumb);
      if (fresh == null) return null;
      return cache.download(photo.id, fresh, thumb: thumb);
    }
  }

  Future<String?> _freshUrl(MemoryPhoto photo, {required bool thumb}) async {
    final photos = await _refreshing.putIfAbsent(
      photo.memoryId,
      // Pembersihnya tidak boleh mengembalikan future yang dihapus: whenComplete akan menunggunya,
      // padahal itu future ini sendiri.
      () => refreshUrls(photo.memoryId).whenComplete(() {
        _refreshing.remove(photo.memoryId);
      }),
    );
    final fresh = photos.where((item) => item.id == photo.id).firstOrNull;
    return thumb ? fresh?.thumbUrl : fresh?.url;
  }

  /// Satu permintaan per gambar pada satu waktu, walau beberapa widget memintanya bersamaan.
  Future<File?> _once(String key, Future<File?> Function() load) => _loading.putIfAbsent(
    key,
    () => load().whenComplete(() {
      _loading.remove(key);
    }),
  );
}
