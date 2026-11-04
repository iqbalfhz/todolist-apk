import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

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

  /// Nama ZIP ekspor (v1.x), misalnya `denly-days-2026-11-03.zip`.
  String get zipName => '$folder.zip';

  /// Perkiraan ukuran ZIP-nya: data ditambah sekitar 1 MB per foto.
  int get zipSizeEstimate => bytes.length + photos.length * photoSizeEstimate;
}

/// Kira-kira ukuran satu foto versi penuh (kontrak, bagian Ekspor ZIP berisi foto).
const int photoSizeEstimate = 1024 * 1024;

/// Ruang yang tetap disisakan di HP selain perkiraan ukuran ZIP.
const int zipSpaceMargin = 50 * 1024 * 1024;

/// Satu foto yang ikut diekspor lewat tautan.
class ExportPhoto {
  const ExportPhoto({required this.cacheId, required this.fileName, required this.url, this.isAvatar = false});

  /// Kunci di cache foto: ID foto kenangan, atau `profil-{id akun}` untuk foto profil.
  final String cacheId;
  final String fileName;
  final String url;

  /// Foto profil selalu diunduh ulang, karena bisa sudah diganti sejak tersimpan di cache.
  final bool isAvatar;

  /// Letaknya di dalam ZIP ekspor (v1.x).
  String get zipEntry => isAvatar ? 'foto-profil.jpg' : 'foto-kenangan/$fileName';
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

/// ZIP ekspor yang sudah tersimpan di folder unduhan (v1.x).
class SavedZip {
  const SavedZip({required this.name, required this.location, this.uri, this.path});

  /// Nama berkas sesungguhnya; Android menambah nomor kalau namanya sudah dipakai.
  final String name;

  /// Folder untuk ditunjukkan ke pengguna.
  final String location;

  /// Alamat MediaStore (Android 10+) atau letak berkasnya (sebelumnya), untuk dibagikan.
  final String? uri;
  final String? path;
}

/// Tempat menulis ZIP ekspor (v1.x). Ditimpa di tes.
abstract interface class ExportZipWriter {
  /// Ruang kosong di HP dalam byte, atau `null` kalau tidak terbaca.
  Future<int?> freeSpace();

  /// Buka ZIP baru bernama [name] di `Download/Denly Days`.
  Future<ExportZipSession> start(String name);

  /// Buka lembar bagikan untuk [zip].
  Future<void> share(SavedZip zip);
}

/// ZIP yang sedang ditulis. Berkasnya baru terlihat di folder unduhan setelah [finish].
abstract interface class ExportZipSession {
  Future<void> add(String entry, Uint8List bytes, {required bool compress});

  Future<SavedZip> finish();

  /// Hapus ZIP yang belum selesai. Tidak pernah gagal.
  Future<void> cancel();
}

/// [ExportZipWriter] ke folder unduhan HP lewat `ExportZip.kt`.
class DeviceExportZipWriter implements ExportZipWriter {
  const DeviceExportZipWriter(this.platform);

  final DevicePlatform platform;

  @override
  Future<int?> freeSpace() => platform.freeSpace();

  @override
  Future<ExportZipSession> start(String name) async => _DeviceZipSession(await DeviceZip.start(name));

  @override
  Future<void> share(SavedZip zip) async {
    final uri = zip.uri;
    if (uri != null && await platform.shareFile(uri, 'application/zip')) return;
    // Sebelum Android 10, ZIP-nya berkas biasa di folder unduhan milik app.
    final path = zip.path;
    if (path != null) {
      await SharePlus.instance.share(ShareParams(files: [XFile(path, mimeType: 'application/zip')]));
    }
  }
}

class _DeviceZipSession implements ExportZipSession {
  _DeviceZipSession(this.zip);

  final DeviceZip zip;

  @override
  Future<void> add(String entry, Uint8List bytes, {required bool compress}) =>
      zip.add(entry, bytes, compress: compress);

  @override
  Future<SavedZip> finish() async {
    final saved = await zip.finish();
    return SavedZip(name: saved['name']!, location: saved['location']!, uri: saved['uri'], path: saved['path']);
  }

  @override
  Future<void> cancel() => zip.cancel();
}

/// Satu ZIP ekspor (v1.x): `data.json` apa adanya, lalu foto versi penuh satu per satu. ZIP-nya
/// baru muncul di folder unduhan lewat [finish], yang hanya dipanggil kalau semua foto masuk,
/// jadi tidak pernah ada ZIP yang diam-diam tidak lengkap.
class ExportZipJob {
  ExportZipJob({
    required this.export,
    required this.session,
    required this.fetcher,
    this.retryDelays = const [Duration(seconds: 2), Duration(seconds: 4)],
  }) : remaining = export.photos;

  final DataExport export;
  final ExportZipSession session;
  final ExportPhotoFetcher fetcher;

  /// Jeda sebelum foto yang gagal diunduh dicoba lagi.
  final List<Duration> retryDelays;

  /// Foto yang belum masuk ZIP.
  List<ExportPhoto> remaining;

  bool _cancelled = false;

  Future<void> addData() => session.add('data.json', export.bytes, compress: true);

  /// Unduh lalu masukkan [remaining] ke ZIP, masing-masing dicoba lagi sesuai [retryDelays].
  /// Mengembalikan yang tetap gagal, yang juga menjadi [remaining] berikutnya. Gagal menulis ke
  /// HP dilempar apa adanya.
  Future<List<ExportPhoto>> addPhotos({void Function(int done)? onProgress}) async {
    final failed = <ExportPhoto>[];
    var done = 0;
    for (final photo in remaining) {
      final bytes = await _fetch(photo);
      if (_cancelled) return remaining;
      if (bytes == null) {
        failed.add(photo);
      } else {
        await session.add(photo.zipEntry, bytes, compress: false);
      }
      onProgress?.call(++done);
    }
    remaining = failed;
    return failed;
  }

  Future<Uint8List?> _fetch(ExportPhoto photo) async {
    for (var attempt = 0; ; attempt++) {
      try {
        return await fetcher.fetch(photo);
      } on Object catch (error) {
        debugPrint('Foto ${photo.fileName} gagal diunduh untuk ZIP: $error');
        if (_cancelled || attempt >= retryDelays.length) return null;
        await Future<void>.delayed(retryDelays[attempt]);
      }
    }
  }

  Future<SavedZip> finish() => session.finish();

  /// Hentikan dan hapus ZIP yang belum selesai, misalnya saat layar ditutup.
  Future<void> cancel() {
    _cancelled = true;
    return session.cancel();
  }
}

/// Error saat menyimpan ke HP, misalnya penyimpanan penuh.
bool isSaveFailure(Object error) => error is PlatformException || error is FileSystemException;
