import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import '../../../core/database/local_store.dart';
import '../../../core/media/media_caches.dart';
import '../../../core/notifications/push_service.dart';
import '../../../core/providers.dart';
import '../../../core/session/session.dart';
import '../../../core/session/token_revocations.dart';
import '../domain/user.dart';

/// Zona waktu IANA dari HP, dikirim saat daftar. `null` kalau tidak terbaca;
/// server lalu memakai `Asia/Jakarta`.
Future<String?> deviceTimezone() async {
  try {
    return (await FlutterTimezone.getLocalTimezone()).identifier;
  } on Object {
    return null;
  }
}

/// Simpan token, buka database akun itu, simpan profilnya, lalu mulai sync.
///
/// Setelah daftar, sync ini penuh (database lokal masih kosong). Saat masuk lagi di
/// HP yang sama, sync melanjutkan kursor yang tersimpan, jadi data yang dihapus
/// pasangan selama itu ikut terhapus di HP.
///
/// Menerima [ProviderContainer], bukan `WidgetRef`: begitu sesi berubah, router
/// mengganti layar pemanggilnya, dan `ref` milik layar itu tidak bisa dipakai lagi.
Future<void> completeSignIn(ProviderContainer container, AuthResult result) async {
  await container.read(sessionProvider.notifier).signIn(userId: result.user.id, token: result.token);

  final account = container.read(accountProvider);
  if (account == null) return;

  await account.profile.save(result.user);
  // Tidak ditunggu: layar berikutnya menampilkan skeleton sampai data tiba.
  account.sync.sync().ignore();
}

/// Keluar: cabut token di server, hapus token FCM di HP apa pun hasilnya, kosongkan cache
/// gambar, lalu hapus token dari HP. Database lokal akun (termasuk antrean yang belum
/// terkirim) tetap tersimpan.
///
/// Tanpa koneksi, tokennya disimpan untuk dicabut begitu server terjangkau lagi, supaya
/// tidak ada token yang tetap berlaku di server setelah keluar.
Future<void> signOut(ProviderContainer container) async {
  final account = container.read(accountProvider);
  final push = container.read(pushServiceProvider);
  final token = container.read(sessionProvider).token;

  final fcmToken = await account?.store.meta(MetaKeys.deviceToken) ?? await push.token();

  final revoked = await container.read(authRepositoryProvider).logout(fcmToken: fcmToken);
  if (!revoked && token != null) {
    await TokenRevocations(container.read(keyValueStoreProvider)).add(token, fcmToken: fcmToken);
  }
  await push.deleteToken();
  await account?.store.setMeta(MetaKeys.deviceToken, null);
  try {
    await container.read(mediaCachesProvider).clear();
  } on Object {
    // Cache yang gagal dikosongkan tidak boleh menahan keluar.
  }
  await container.read(sessionProvider.notifier).signOut();
}
