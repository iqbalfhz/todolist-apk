import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/session/account.dart';
import '../domain/memory.dart';

/// Hasil menambahkan foto ke kenangan.
class PhotoImportResult {
  const PhotoImportResult({this.added = 0, this.unreadable = 0, this.overLimit = 0});

  final int added;

  /// Berkas yang tidak bisa dibaca sebagai gambar.
  final int unreadable;

  /// Foto yang tidak masuk karena kenangannya sudah berisi 50 foto.
  final int overLimit;
}

/// Foto yang sedang disiapkan (dikecilkan dan dikompres) per kenangan, sebelum masuk antrean.
///
/// Foto disiapkan satu per satu di latar belakang, jadi layar tidak menunggu. Setiap foto yang
/// selesai langsung masuk ke kenangannya dan antrean unggah; jumlah yang tersisa ditampilkan
/// sebagai kotak skeleton di Detail kenangan.
class PhotoImports extends Notifier<Map<String, int>> {
  Account? _account;

  @override
  Map<String, int> build() {
    _account = ref.watch(accountProvider);
    return const {};
  }

  /// Jumlah foto yang masih disiapkan untuk [memoryId].
  int remaining(String memoryId) => state[memoryId] ?? 0;

  /// Siapkan [paths] lalu tambahkan ke [memory], berurutan sesuai pilihan.
  Future<PhotoImportResult> start(Memory memory, List<String> paths) async {
    final account = _account;
    if (account == null || paths.isEmpty) return const PhotoImportResult();
    final picker = ref.read(photoPickerProvider);

    var added = 0;
    var unreadable = 0;
    var overLimit = 0;
    _change(account, memory.id, paths.length);

    for (final path in paths) {
      try {
        final photo = await picker.prepare(path);
        if (photo == null) {
          unreadable++;
        } else if (await account.memories.addPhotos(memory, [photo]) == 0) {
          overLimit++;
        } else {
          added++;
        }
      } on Object {
        // Berkas rusak, atau akunnya keluar di tengah jalan.
        unreadable++;
      } finally {
        _change(account, memory.id, -1);
      }
    }
    return PhotoImportResult(added: added, unreadable: unreadable, overLimit: overLimit);
  }

  void _change(Account account, String memoryId, int delta) {
    // Akun sudah berganti: hitungan baru mulai dari kosong.
    if (!ref.mounted || !identical(account, _account)) return;
    final next = math.max(0, remaining(memoryId) + delta);
    state = {
      for (final entry in state.entries)
        if (entry.key != memoryId) entry.key: entry.value,
      if (next > 0) memoryId: next,
    };
  }
}

final photoImportsProvider = NotifierProvider<PhotoImports, Map<String, int>>(PhotoImports.new);
