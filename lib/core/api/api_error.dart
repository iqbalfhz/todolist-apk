/// `code` error dari tabel Error di `docs/kontrak-api.md`.
enum ApiErrorCode {
  unauthenticated('unauthenticated'),
  forbidden('forbidden'),
  notFound('not_found'),
  routeNotFound('route_not_found'),
  parentDeleted('parent_deleted'),
  parentArchived('parent_archived'),
  lastList('last_list'),
  idConflict('id_conflict'),

  /// Checklist perjalanan dihapus atau diarsipkan sendiri (v0.2).
  tripChecklist('trip_checklist'),
  sharedSpaceExists('shared_space_exists'),
  resourceDeleted('resource_deleted'),
  validationFailed('validation_failed'),
  invalidCredentials('invalid_credentials'),

  /// ID token Google ditolak server (v1.x): salah, kedaluwarsa, untuk app lain, atau emailnya
  /// belum terverifikasi. Pesannya ditampilkan, dan pengguna bisa mencoba lagi.
  googleTokenInvalid('google_token_invalid'),
  invitationInvalid('invitation_invalid'),
  tooManyRequests('too_many_requests'),

  /// Pencarian tempat sedang tidak tersedia (503, v1.x). Satu-satunya 5xx yang dianggap jawaban
  /// API: pesannya ditampilkan, dan pin tetap bisa dipasang langsung di peta.
  placesUnavailable('places_unavailable'),
  serverError('server_error');

  const ApiErrorCode(this.value);

  final String value;

  static ApiErrorCode? tryParse(Object? value) {
    for (final code in values) {
      if (code.value == value) return code;
    }
    return null;
  }
}

/// Balasan error berupa JSON dengan `code` yang dikenal.
///
/// Hanya error jenis ini yang boleh membuat app membuang isi antrean atau menghapus data lokal.
class ApiError implements Exception {
  const ApiError({
    required this.status,
    required this.code,
    required this.message,
    this.errors = const {},
    this.hasCurrent = false,
    this.current,
    this.retryAfter,
  });

  final int status;
  final ApiErrorCode code;

  /// Pesan berbahasa Indonesia dari server, bisa langsung ditampilkan.
  final String message;

  /// Error validasi per kolom.
  final Map<String, List<String>> errors;

  /// Apakah balasan menyertakan kunci `current`. Kalau ya dan nilainya `null`,
  /// data itu tidak ada di server.
  final bool hasCurrent;

  /// Data di URL request seperti tersimpan di server sekarang.
  final Map<String, dynamic>? current;

  /// Dari header `Retry-After` pada 429.
  final Duration? retryAfter;

  /// Pesan untuk satu kolom, atau pesan umum kalau kolom itu tidak punya error.
  String messageFor(String field) => errors[field]?.firstOrNull ?? message;

  @override
  String toString() => 'ApiError($status ${code.value}): $message';
}

/// Jaringan, proxy, atau server bermasalah: tanpa koneksi, timeout, 5xx,
/// balasan bukan JSON, atau JSON tanpa `code` yang dikenal.
///
/// Selalu boleh dicoba lagi; tidak pernah menjadi alasan membuang data.
class NetworkFailure implements Exception {
  const NetworkFailure({this.status, this.detail});

  /// Status HTTP kalau server sempat membalas; `null` kalau tidak ada koneksi.
  final int? status;
  final String? detail;

  bool get noConnection => status == null;

  @override
  String toString() => 'NetworkFailure(${status ?? 'tanpa koneksi'}): ${detail ?? ''}';
}

/// Balasan berhasil (2xx).
class ApiResponse {
  const ApiResponse({required this.status, this.body, this.raw, this.headers = const {}});

  final int status;

  /// JSON balasan; `null` untuk 204.
  final Map<String, dynamic>? body;

  /// Isi balasan apa adanya, untuk balasan berupa berkas (ekspor data, v1.0).
  final String? raw;

  /// Header balasan, dengan nama huruf kecil.
  final Map<String, String> headers;

  /// Isi kunci `data` saat berupa satu objek.
  Map<String, dynamic> get data => body!['data'] as Map<String, dynamic>;

  /// Isi kunci `data` saat berupa larik.
  List<Map<String, dynamic>> get dataList => (body!['data'] as List<dynamic>).cast<Map<String, dynamic>>();

  Map<String, dynamic> get meta => body!['meta'] as Map<String, dynamic>;
}
