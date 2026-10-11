import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Kunci nilai kecil yang disimpan di HP, di luar database akun.
abstract final class StorageKeys {
  static const String token = 'auth.token';
  static const String userId = 'auth.user_id';
  static const String themeName = 'theme.name';
  static const String themeMode = 'theme.mode';

  /// Layar Izin notifikasi sudah dilewati di HP ini.
  static const String notificationsOnboarded = 'onboarding.notifications';

  /// Layar Ajak pasangan sudah dilewati oleh akun ini.
  static String pairingOnboarded(String userId) => 'onboarding.pairing.$userId';
}

/// Penyimpanan kunci-nilai di HP.
///
/// Token wajib disimpan lewat sini (flutter_secure_storage), bukan SharedPreferences.
/// Pilihan tema ikut disimpan di sini supaya app tidak perlu paket penyimpanan kedua.
abstract interface class KeyValueStore {
  Future<String?> read(String key);

  /// Simpan [value]; `null` menghapus kuncinya.
  Future<void> write(String key, String? value);
}

class SecureKeyValueStore implements KeyValueStore {
  const SecureKeyValueStore();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String? value) =>
      value == null ? _storage.delete(key: key) : _storage.write(key: key, value: value);
}
