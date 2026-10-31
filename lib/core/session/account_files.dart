import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import '../media/photo_files.dart';
import '../utils/ulid.dart';

/// Berkas milik satu akun di HP: database lokal (termasuk antrean) dan foto kenangan yang
/// menunggu diunggah. Ditimpa di tes.
abstract interface class AccountFiles {
  /// Hapus semua berkas akun [userId] (hapus akun, v1.0). Database-nya harus sudah ditutup.
  Future<void> delete(String userId);
}

/// [AccountFiles] di penyimpanan app.
class DeviceAccountFiles implements AccountFiles {
  const DeviceAccountFiles();

  /// Berkas pendamping SQLite yang bisa tertinggal di samping database.
  static const List<String> _sqliteSuffixes = ['', '-wal', '-shm', '-journal'];

  @override
  Future<void> delete(String userId) async {
    // ID akun hanya dipakai sebagai nama berkas kalau berbentuk ULID.
    if (!ulidPattern.hasMatch(userId)) return;

    final documents = await getApplicationDocumentsDirectory();
    for (final suffix in _sqliteSuffixes) {
      final file = File('${documents.path}/${AppDatabase.fileNameFor(userId)}.sqlite$suffix');
      if (await file.exists()) await file.delete();
    }

    final photos = await PhotoFiles.folderFor(userId);
    if (await photos.exists()) await photos.delete(recursive: true);
  }
}
