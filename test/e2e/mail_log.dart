import 'dart:convert';
import 'dart:io';

/// Kode 6 angka dari email yang ditulis API lokal ke log, supaya lupa kata sandi dan verifikasi
/// email (v1.0) bisa diuji sampai habis tanpa layanan email sungguhan.
///
/// Aktif kalau E2E_MAIL_LOG menunjuk ke log Laravel (`storage/logs/laravel.log`). API lokal
/// memakai `MAIL_MAILER=log`, dan emailnya dikirim lewat antrean, jadi jalankan juga pekerja
/// antrean untuk database tes yang sama, dari folder repo api:
///
///   DB_DATABASE=todolist_mobile_e2e php artisan queue:work --sleep=1 --tries=1
///
/// Pekerjaan lain di antrean (push dan hapus foto di R2) gagal di lokal karena kuncinya kosong;
/// itu hanya tercatat di log dan tidak memengaruhi balasan API. Jangan memakai
/// `QUEUE_CONNECTION=sync`: kegagalan itu lalu menjadi balasan 500.
class MailLog {
  MailLog(this.path);

  static MailLog? fromEnvironment() {
    final path = Platform.environment['E2E_MAIL_LOG'];
    return path == null || path.isEmpty ? null : MailLog(path);
  }

  /// Subjek email atur ulang kata sandi dan email verifikasi (kontrak, bagian Lupa kata sandi).
  static const String passwordReset = 'Kode atur ulang kata sandi Denly Days';
  static const String verification = 'Kode verifikasi email Denly Days';

  /// Subjek email kode ganti email (v1.x), dikirim ke email baru.
  static const String emailChange = 'Kode ganti email Denly Days';

  final String path;
  int _offset = 0;

  /// Tandai akhir log saat ini; [code] hanya membaca email yang ditulis sesudahnya.
  void mark() => _offset = File(path).lengthSync();

  /// Kode terakhir untuk [email] sejak [mark], dari email bersubjek [purpose]. Ditunggu sampai
  /// pekerja antrean selesai mengirimnya.
  Future<String> code(String email, String purpose, {Duration timeout = const Duration(seconds: 20)}) async {
    final deadline = DateTime.now().add(timeout);
    while (true) {
      final found = _find(email, purpose);
      if (found != null) return found;
      if (DateTime.now().isAfter(deadline)) {
        throw StateError(
          'Kode untuk $email tidak ada di $path. Pastikan API lokal memakai MAIL_MAILER=log dan '
          'pekerja antreannya jalan.',
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
  }

  String? _find(String email, String purpose) {
    final file = File(path).openSync();
    final String text;
    try {
      file.setPositionSync(_offset);
      text = utf8.decode(file.readSync(file.lengthSync() - _offset), allowMalformed: true);
    } finally {
      file.closeSync();
    }

    // Setiap catatan log diawali "[2026-11-02 08:00:00] local.DEBUG:", dan satu email satu catatan.
    // Alamatnya dicocokkan utuh, supaya "aku-1@contoh.test" tidak ikut "ui-aku-1@contoh.test".
    final address = RegExp('(?<![\\w.+-])${RegExp.escape(email)}');
    String? found;
    for (final entry in text.split(RegExp(r'^\[\d{4}-', multiLine: true))) {
      if (!address.hasMatch(entry) || !entry.contains('Subject: $purpose')) continue;
      // Sejak 3 November 2026 kodenya di baris tersendiri di versi teks biasa; sebelumnya di
      // akhir kalimat "... Denly Days: 482913.".
      final code =
          RegExp(r'^\s*(\d{6})\s*$', multiLine: true).firstMatch(entry)?.group(1) ??
          RegExp(r'Denly Days: (\d{6})\.').firstMatch(entry)?.group(1);
      found = code ?? found;
    }
    return found;
  }
}
