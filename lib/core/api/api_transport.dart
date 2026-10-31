import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'api_error.dart';

/// Berkas untuk request `multipart/form-data` (foto profil dan foto kenangan).
class ApiUpload {
  const ApiUpload({required this.field, required this.bytes, required this.filename, required this.mimeType});

  final String field;
  final Uint8List bytes;
  final String filename;
  final String mimeType;
}

/// Pengirim request ke API. Antrean dan sync bergantung pada antarmuka ini,
/// supaya bisa diuji dengan API palsu.
///
/// Melempar [ApiError] untuk balasan error JSON dengan `code` yang dikenal,
/// dan [NetworkFailure] untuk semua masalah jaringan atau server lainnya.
abstract interface class ApiTransport {
  Future<ApiResponse> send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    ApiUpload? upload,
  });
}

/// Mengamati hasil setiap request, apa pun pengirimnya, untuk dua hal yang berlaku
/// di seluruh app: banner offline dan sesi yang berakhir.
class ObservedTransport implements ApiTransport {
  const ObservedTransport(this.inner, {this.onReachability, this.onUnauthenticated});

  final ApiTransport inner;

  /// Dipanggil setiap request selesai: `true` kalau server menjawab dengan benar.
  final void Function(bool reachable)? onReachability;

  /// Dipanggil saat server membalas 401: token HP ini tidak berlaku lagi.
  final void Function()? onUnauthenticated;

  @override
  Future<ApiResponse> send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    ApiUpload? upload,
  }) async {
    try {
      final response = await inner.send(method, path, body: body, query: query, upload: upload);
      onReachability?.call(true);
      return response;
    } on NetworkFailure {
      onReachability?.call(false);
      rethrow;
    } on ApiError catch (error) {
      // Server menjawab, hanya saja menolak.
      onReachability?.call(true);
      if (error.code == ApiErrorCode.unauthenticated) onUnauthenticated?.call();
      rethrow;
    }
  }
}

/// [ApiTransport] di atas dio.
class DioApiTransport implements ApiTransport {
  DioApiTransport({required String baseUrl, required String? Function() token, Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'
      ..connectTimeout = const Duration(seconds: 10)
      ..sendTimeout = _sendTimeout
      ..receiveTimeout = const Duration(seconds: 20)
      // Balasan dibaca sebagai teks lalu di-decode sendiri, supaya halaman HTML
      // dari proxy tidak pernah dianggap balasan API.
      ..responseType = ResponseType.plain
      ..headers[Headers.acceptHeader] = Headers.jsonContentType
      // API tidak pernah mengalihkan. Pengalihan dianggap gangguan (dicoba lagi), bukan diikuti,
      // supaya token tidak pernah ikut terkirim ke alamat lain.
      ..followRedirects = false
      ..maxRedirects = 0
      ..validateStatus = _anyStatus;

    _dio.interceptors
      ..add(_TokenInterceptor(token))
      ..add(_RetryInterceptor(_dio));
  }

  final Dio _dio;

  static const Duration _sendTimeout = Duration(seconds: 20);

  /// Foto kenangan sampai sekitar 1,5 MB; di jaringan lambat butuh lebih lama.
  static const Duration _uploadTimeout = Duration(seconds: 90);

  @override
  Future<ApiResponse> send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    ApiUpload? upload,
  }) async {
    final Response<String> response;

    try {
      response = await _dio.request<String>(
        path.startsWith('/') ? path.substring(1) : path,
        data: upload == null ? body : _formData(upload, body),
        queryParameters: query,
        options: Options(
          method: method,
          contentType: upload == null ? Headers.jsonContentType : Headers.multipartFormDataContentType,
          sendTimeout: upload == null ? _sendTimeout : _uploadTimeout,
        ),
      );
    } on DioException catch (error) {
      throw NetworkFailure(detail: error.message ?? error.type.name);
    }

    final status = response.statusCode ?? 0;
    final json = _decode(response.data);

    if (status >= 200 && status < 300) {
      // 204 tidak punya body. 2xx lain wajib JSON; halaman login Wi-Fi publik pun membalas 200.
      if (status != 204 && json == null) {
        throw NetworkFailure(status: status, detail: 'Balasan bukan JSON');
      }
      return ApiResponse(
        status: status,
        body: json,
        raw: response.data,
        headers: {
          for (final MapEntry(:key, :value) in response.headers.map.entries) key.toLowerCase(): value.join(', '),
        },
      );
    }

    final code = ApiErrorCode.tryParse(json?['code']);

    // 404 atau 502 tanpa JSON (misalnya dari proxy saat deploy) dan semua 5xx
    // diperlakukan sebagai gangguan sementara, bukan jawaban API, kecuali 503
    // `places_unavailable` dari pencarian tempat (v1.x).
    final placesUnavailable = status == 503 && code == ApiErrorCode.placesUnavailable;
    if (json == null || code == null || (status >= 500 && !placesUnavailable) || code == ApiErrorCode.serverError) {
      throw NetworkFailure(status: status, detail: json?['message'] as String?);
    }

    throw ApiError(
      status: status,
      code: code,
      message: json['message'] as String? ?? '',
      errors: _fieldErrors(json['errors']),
      hasCurrent: json.containsKey('current'),
      current: json['current'] as Map<String, dynamic>?,
      retryAfter: _retryAfter(response.headers.value('retry-after')),
    );
  }

  /// Berkas dan kolom formulirnya. Kolom yang kosong tidak dikirim, dan angka dikirim sebagai teks.
  FormData _formData(ApiUpload upload, Map<String, dynamic>? fields) => FormData.fromMap({
    for (final entry in (fields ?? const <String, dynamic>{}).entries)
      if (entry.value != null) entry.key: entry.value.toString(),
    upload.field: MultipartFile.fromBytes(
      upload.bytes,
      filename: upload.filename,
      contentType: DioMediaType.parse(upload.mimeType),
    ),
  });

  /// Status error dibaca sendiri di [send], jadi dio tidak perlu melemparnya.
  static bool _anyStatus(int? status) => true;

  static Map<String, dynamic>? _decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  static Map<String, List<String>> _fieldErrors(Object? raw) {
    if (raw is! Map) return const {};
    return {
      for (final entry in raw.entries)
        entry.key.toString(): [
          if (entry.value is List)
            for (final message in entry.value as List<dynamic>) message.toString(),
        ],
    };
  }

  static Duration? _retryAfter(String? header) {
    final seconds = int.tryParse(header ?? '');
    return seconds == null ? null : Duration(seconds: seconds);
  }
}

/// Menambahkan `Authorization: Bearer <token>` kalau HP ini sedang masuk.
class _TokenInterceptor extends Interceptor {
  _TokenInterceptor(this._token);

  final String? Function() _token;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _token();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}

/// Mengulang `GET` yang gagal karena koneksi, paling banyak dua kali.
///
/// Operasi tulis tidak diulang di sini: antrean punya jeda coba ulangnya sendiri.
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);

  final Dio _dio;

  static const List<Duration> _delays = [Duration(seconds: 1), Duration(seconds: 2)];
  static const String _attemptKey = 'retry_attempt';

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final attempt = options.extra[_attemptKey] as int? ?? 0;
    final retryable =
        options.method == 'GET' &&
        attempt < _delays.length &&
        (err.type == DioExceptionType.connectionError ||
            err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout);

    if (!retryable) return handler.next(err);

    await Future<void>.delayed(_delays[attempt]);
    options.extra[_attemptKey] = attempt + 1;

    try {
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (error) {
      handler.next(error);
    }
  }
}
