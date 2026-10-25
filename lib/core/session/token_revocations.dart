import 'dart:convert';

import '../api/api_error.dart';
import '../api/api_transport.dart';
import '../storage/key_value_store.dart';

/// Token yang belum dicabut di server, beserta token FCM HP itu saat keluar.
typedef PendingRevocation = ({String token, String? fcmToken});

/// Token yang belum sempat dicabut di server karena keluar saat offline.
///
/// Keluar tetap berjalan di HP walau server tidak terjangkau, tapi tokennya masih berlaku di
/// server sampai dicabut. Token itu disimpan di penyimpanan aman, lalu dicabut lewat
/// `POST /auth/logout` begitu app dibuka atau kembali aktif dan server terjangkau.
class TokenRevocations {
  TokenRevocations(this.storage);

  final KeyValueStore storage;

  Future<List<PendingRevocation>> pending() async {
    final raw = await storage.read(StorageKeys.pendingRevocations);
    if (raw == null) return const [];
    try {
      return [
        for (final item in (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>())
          (token: item['token'] as String, fcmToken: item['fcm_token'] as String?),
      ];
    } on Object {
      // Isi rusak tidak bisa dipakai lagi; dibuang supaya tidak mengganjal selamanya.
      await storage.write(StorageKeys.pendingRevocations, null);
      return const [];
    }
  }

  /// Simpan [token] untuk dicabut nanti.
  Future<void> add(String token, {String? fcmToken}) async {
    final items = [
      for (final item in await pending())
        if (item.token != token) item,
      (token: token, fcmToken: fcmToken),
    ];
    await _save(items);
  }

  /// Cabut semua yang tertunda, masing-masing dengan tokennya sendiri. Yang gagal karena
  /// jaringan disimpan untuk dicoba lagi. Balasan error dari server (misalnya 401, token
  /// sudah tidak berlaku) berarti tidak ada lagi yang perlu dicabut.
  Future<void> revokeAll(ApiTransport Function(String token) transportFor) async {
    final items = await pending();
    if (items.isEmpty) return;

    final done = <String>{};
    for (final item in items) {
      try {
        await transportFor(item.token).send('POST', '/auth/logout', body: {'fcm_token': item.fcmToken});
        done.add(item.token);
      } on ApiError {
        done.add(item.token);
      } on NetworkFailure {
        // Dicoba lagi nanti.
      }
    }

    // Dibaca ulang: token lain mungkin ditambahkan selama pencabutan berjalan.
    await _save([
      for (final item in await pending())
        if (!done.contains(item.token)) item,
    ]);
  }

  Future<void> _save(List<PendingRevocation> items) => storage.write(
    StorageKeys.pendingRevocations,
    items.isEmpty
        ? null
        : jsonEncode([
            for (final item in items) {'token': item.token, 'fcm_token': item.fcmToken},
          ]),
  );
}
