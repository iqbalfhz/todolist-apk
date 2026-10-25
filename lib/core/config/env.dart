/// Konfigurasi dari `--dart-define-from-file=env/<nama>.json`.
abstract final class Env {
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Kosong berarti app dijalankan tanpa `--dart-define-from-file`.
  static bool get isConfigured => apiBaseUrl.isNotEmpty;
}

/// Alasan [url] tidak boleh dipakai sebagai `API_BASE_URL`, atau `null` kalau boleh.
///
/// Build rilis hanya boleh memakai HTTPS: token dan semua data lewat alamat ini. HTTP hanya
/// untuk API lokal di build debug.
String? apiBaseUrlProblem(String url, {required bool release}) {
  if (url.isEmpty) {
    return 'API_BASE_URL belum diisi.\n\nJalankan dengan:\nflutter run --dart-define-from-file=env/dev.json';
  }
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasAuthority || (uri.scheme != 'https' && uri.scheme != 'http')) {
    return 'API_BASE_URL tidak valid: $url';
  }
  if (release && uri.scheme != 'https') {
    return 'Build rilis hanya boleh memakai API lewat HTTPS.\n\nAPI_BASE_URL sekarang: $url';
  }
  return null;
}
