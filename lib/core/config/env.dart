/// Konfigurasi dari `--dart-define-from-file=env/<nama>.json`.
abstract final class Env {
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Kosong berarti app dijalankan tanpa `--dart-define-from-file`.
  static bool get isConfigured => apiBaseUrl.isNotEmpty;
}
