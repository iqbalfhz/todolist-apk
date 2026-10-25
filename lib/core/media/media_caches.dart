import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'photo_cache.dart';

/// Cache gambar di HP: foto kenangan dan foto profil.
///
/// Dikosongkan saat keluar, supaya foto akun itu tidak tertinggal di HP ketika akun lain
/// masuk. Akun yang sama mengunduhnya lagi setelah masuk.
abstract interface class MediaCaches {
  Future<void> clear();
}

/// [MediaCaches] di HP: cache foto kenangan, cache foto profil (cached_network_image), dan
/// gambar yang sudah dibaca ke memori.
class DeviceMediaCaches implements MediaCaches {
  const DeviceMediaCaches();

  @override
  Future<void> clear() async {
    await DevicePhotoCache.instance.clear();
    await DefaultCacheManager().emptyCache();
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  }
}

/// Ditimpa di tes dengan versi palsu.
final mediaCachesProvider = Provider<MediaCaches>((ref) => const DeviceMediaCaches());
