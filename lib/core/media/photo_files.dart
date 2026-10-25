import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../api/api_transport.dart';
import '../database/app_database.dart';
import '../database/entity_type.dart';
import '../queue/upload_files.dart';
import '../utils/ulid.dart';
import 'photo_cache.dart';

/// Foto kenangan yang sudah dikompres dan menunggu diunggah, satu folder per akun.
///
/// Berkasnya disimpan di penyimpanan app, bukan cache sistem, supaya tidak dibersihkan
/// Android sebelum terunggah. Setelah server menyimpannya, berkas dipindah ke [cache]
/// sebagai versi penuh foto itu, jadi tidak perlu diunduh lagi di HP ini.
class PhotoFiles implements UploadFiles {
  PhotoFiles({required this.directory, required this.cache});

  /// Folder akun [userId] di penyimpanan app.
  factory PhotoFiles.forAccount(String userId, PhotoCache cache) {
    if (!ulidPattern.hasMatch(userId)) throw ArgumentError.value(userId, 'userId', 'Bukan ULID');
    return PhotoFiles(
      directory: () async => Directory('${(await getApplicationSupportDirectory()).path}/foto_kenangan/akun_$userId'),
      cache: cache,
    );
  }

  /// Folder tempat berkas disimpan; dibuat saat foto pertama disimpan.
  final Future<Directory> Function() directory;
  final PhotoCache cache;

  /// Berkas foto [photoId], atau `null` kalau ID-nya bukan ULID. ID foto dari server juga
  /// dipakai di sini; yang bentuknya lain tidak pernah dijadikan nama berkas, supaya tidak
  /// bisa menunjuk berkas di luar folder ini.
  Future<File?> _fileOf(String photoId) async {
    if (!ulidPattern.hasMatch(photoId)) return null;
    return File('${(await directory()).path}/$photoId.jpg');
  }

  /// Simpan foto [photoId] yang sudah dikompres sampai terunggah.
  Future<File> save(String photoId, Uint8List jpeg) async {
    final file = await _fileOf(photoId);
    if (file == null) throw ArgumentError.value(photoId, 'photoId', 'Bukan ULID');
    await file.parent.create(recursive: true);
    return file.writeAsBytes(jpeg, flush: true);
  }

  /// Berkas foto yang belum selesai diunggah dari HP ini, atau `null`.
  Future<File?> pending(String photoId) async {
    final file = await _fileOf(photoId);
    return file != null && await file.exists() ? file : null;
  }

  @override
  Future<ApiUpload?> fileFor(OutboxRow op) async {
    if (op.entityType != EntityType.memoryPhoto.name) return null;
    final file = await pending(op.entityId);
    if (file == null) return null;

    return ApiUpload(
      field: 'photo',
      bytes: await file.readAsBytes(),
      filename: '${op.entityId}.jpg',
      mimeType: 'image/jpeg',
    );
  }

  @override
  Future<void> uploaded(OutboxRow op, Map<String, dynamic> data) async {
    final file = await pending(op.entityId);
    if (file == null) return;

    final url = data['url'] as String?;
    if (url != null) await cache.put(op.entityId, await file.readAsBytes(), thumb: false, url: url);
    await file.delete();
  }

  @override
  Future<void> discard(EntityType type, String id) async {
    if (type != EntityType.memoryPhoto) return;
    final file = await pending(id);
    await file?.delete();
  }
}
