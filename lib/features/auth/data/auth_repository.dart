import '../../../core/api/api_error.dart';
import '../../../core/api/api_transport.dart';
import '../domain/user.dart';

/// Daftar, masuk, dan keluar. Ketiganya dipanggil langsung dan butuh koneksi.
class AuthRepository {
  AuthRepository(this.api);

  final ApiTransport api;

  /// Daftar sekaligus membuat akun, Ruang Pribadi berisi satu daftar "Tugas", dan token HP ini.
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String deviceName,
    String? timezone,
  }) async {
    final response = await api.send(
      'POST',
      '/auth/register',
      body: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'device_name': deviceName,
        'timezone': timezone,
      },
    );
    return AuthResult.fromJson(response.data);
  }

  /// Email atau kata sandi salah dibalas 422 `invalid_credentials`, bukan 401.
  Future<AuthResult> login({required String email, required String password, required String deviceName}) async {
    final response = await api.send(
      'POST',
      '/auth/login',
      body: {'email': email.trim(), 'password': password, 'device_name': deviceName},
    );
    return AuthResult.fromJson(response.data);
  }

  /// Cabut token HP ini dan hapus token FCM-nya di server.
  ///
  /// Keluar tetap dilanjutkan di HP walau server tidak terjangkau. Mengembalikan `false`
  /// kalau tokennya belum tercabut (tanpa koneksi), supaya pemanggil mencabutnya nanti.
  Future<bool> logout({String? fcmToken}) async {
    try {
      await api.send('POST', '/auth/logout', body: {'fcm_token': fcmToken});
      return true;
    } on ApiError {
      // Token sudah tidak berlaku; tidak ada lagi yang perlu dicabut.
      return true;
    } on NetworkFailure {
      return false;
    }
  }
}
