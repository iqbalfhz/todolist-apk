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
  static const String trips = '/liburan';

  /// Cari di semua modul (v1.x). Di luar tab bawah.
  static const String search = '/cari';

  static const String settings = '/pengaturan';
  static const String profile = '/pengaturan/profil';
  static const String specialDates = '/pengaturan/tanggal-penting';

  /// Hapus akun (v1.0). Halaman publik `/hapus-akun` menyebut langkah "Pengaturan > Hapus akun".
  static const String deleteAccount = '/pengaturan/hapus-akun';

  /// Parameter kueri penanda layar asal, supaya tombol kembali pulang ke Beranda.
  static const String fromParam = 'dari';
  static const String fromHome = 'beranda';

  /// Parameter kueri: gulir langsung ke bagian Komentar (v1.x), dari notifikasi.
  static const String commentsParam = 'komentar';

  /// Parameter kueri: setoran yang langsung dibuka di Detail tabungan (v1.x), dari notifikasi.
  static const String entryParam = 'setoran';

  static String task(String id, {bool fromHome = false, bool comments = false}) =>
      _with('/tugas/$id', {if (fromHome) fromParam: Routes.fromHome, if (comments) commentsParam: '1'});

  static String goal(String id, {bool fromHome = false, String? entryId}) =>
      _with('/tabungan/$id', {if (fromHome) fromParam: Routes.fromHome, entryParam: ?entryId});

  /// Detail perjalanan (v0.2).
  static String trip(String id) => '/liburan/$id';

  /// Checklist persiapan perjalanan [tripId].
  static String tripChecklist(String tripId) => '/liburan/$tripId/persiapan';

  /// Item checklist, dibuka dari checklist (kembali ke sana) atau dari Detail perjalanan.
  static String tripTask(String tripId, String taskId, {bool fromChecklist = false}) =>
      fromChecklist ? '${tripChecklist(tripId)}/$taskId' : '/liburan/$tripId/tugas/$taskId';

  /// Target tabungan yang ditautkan ke perjalanan [tripId]; kembali ke perjalanannya.
  static String tripGoal(String tripId, String goalId) => '/liburan/$tripId/tabungan/$goalId';

  /// Linimasa Kenangan (v0.3).
  static const String memories = '/kenangan';

  /// Parameter kueri "Simpan jadi kenangan": perjalanan yang isinya dipakai.
  static const String tripParam = 'perjalanan';

  /// Kenangan baru, kosong atau diisi dari perjalanan [tripId].
  static String newMemory({String? tripId}) => tripId == null ? '/kenangan/baru' : '/kenangan/baru?$tripParam=$tripId';

  static String memory(String id, {bool comments = false}) =>
      _with('/kenangan/$id', {if (comments) commentsParam: '1'});

  /// Peta kenangan (v1.x), opsional langsung memilih kenangan [focusId].
  static String memoriesMap({String? focusId}) =>
      focusId == null ? '/kenangan/peta' : '/kenangan/peta?$focusParam=$focusId';

  /// Parameter kueri Peta kenangan: kenangan yang langsung dipilih.
  static const String focusParam = 'fokus';

  static String editMemory(String id) => '/kenangan/$id/ubah';

  /// Galeri foto kenangan [memoryId], dibuka di foto [photoId]. Di luar tab bawah.
  static String memoryPhoto(String memoryId, String photoId) => '/kenangan/$memoryId/foto/$photoId';

  static String _with(String path, Map<String, String> query) =>
      query.isEmpty ? path : Uri(path: path, queryParameters: query).toString();
}
