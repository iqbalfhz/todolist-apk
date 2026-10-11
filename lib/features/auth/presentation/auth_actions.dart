import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import '../../../core/database/local_store.dart';
import '../../../core/notifications/push_service.dart';
import '../../../core/providers.dart';
import '../../../core/session/session.dart';
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
Future<void> completeSignIn(WidgetRef ref, AuthResult result) async {
  await ref.read(sessionProvider.notifier).signIn(userId: result.user.id, token: result.token);

  final account = ref.read(accountProvider);
  if (account == null) return;

  await account.profile.save(result.user);
  // Tidak ditunggu: layar berikutnya menampilkan skeleton sampai data tiba.
  account.sync.sync().ignore();
}

/// Keluar: cabut token di server, hapus token FCM di HP apa pun hasilnya, lalu hapus token dari HP.
/// Database lokal akun (termasuk antrean yang belum terkirim) tetap tersimpan.
Future<void> signOut(WidgetRef ref) async {
  final account = ref.read(accountProvider);
  final push = ref.read(pushServiceProvider);
  final auth = ref.read(authRepositoryProvider);
  final session = ref.read(sessionProvider.notifier);

  final fcmToken = await account?.store.meta(MetaKeys.deviceToken) ?? await push.token();

  await auth.logout(fcmToken: fcmToken);
  await push.deleteToken();
  await account?.store.setMeta(MetaKeys.deviceToken, null);
  await session.signOut();
}
