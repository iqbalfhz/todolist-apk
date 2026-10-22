/// Alamat layar (go_router), sesuai usulan di `docs/layar.md`.
abstract final class Routes {
  static const String login = '/masuk';
  static const String register = '/daftar';
  static const String notifications = '/izin-notifikasi';
  static const String pairing = '/ajak-pasangan';

  static const String home = '/beranda';
  static const String tasks = '/tugas';
  static const String manageLists = '/tugas/daftar';
  static const String savings = '/tabungan';

  static const String settings = '/pengaturan';
  static const String profile = '/pengaturan/profil';
  static const String specialDates = '/pengaturan/tanggal-penting';

  /// Parameter kueri penanda layar asal, supaya tombol kembali pulang ke Beranda.
  static const String fromParam = 'dari';
  static const String fromHome = 'beranda';

  static String task(String id, {bool fromHome = false}) => '/tugas/$id${_origin(fromHome)}';

  static String goal(String id, {bool fromHome = false}) => '/tabungan/$id${_origin(fromHome)}';

  static String _origin(bool fromHome) => fromHome ? '?$fromParam=${Routes.fromHome}' : '';
}
