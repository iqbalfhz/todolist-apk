import 'dart:async';

import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/api/api_transport.dart';

/// Satu request yang diterima [FakeApi].
class SentRequest {
  SentRequest(this.method, this.path, this.body, this.query);

  final String method;
  final String path;
  final Map<String, dynamic>? body;
  final Map<String, dynamic>? query;

  @override
  String toString() => '$method $path';
}

typedef Responder = FutureOr<ApiResponse> Function(SentRequest request);

/// API palsu yang berperilaku seperti kontrak untuk endpoint antrean:
/// `PUT` membuat (201) atau membalas data tersimpan (200), `PATCH` mengubah (200),
/// `DELETE` menandai terhapus (204). Balasan berikutnya bisa ditimpa lewat [enqueue].
class FakeApi implements ApiTransport {
  FakeApi({DateTime Function()? now}) : _now = now ?? (() => DateTime.utc(2026, 10, 8, 10));

  final DateTime Function() _now;

  /// Semua request, urut waktu tiba.
  final List<SentRequest> requests = [];

  /// Data "di server", per sumber lalu per ID.
  final Map<String, Map<String, Map<String, dynamic>>> rows = {};

  /// Halaman-halaman `GET /sync`, dibalas berurutan.
  final List<Map<String, dynamic>> syncPages = [];

  /// Profil yang dibalas `GET /me` dan `PATCH /me`.
  Map<String, dynamic>? me;

  /// Ruang yang dibalas `GET /spaces`.
  List<Map<String, dynamic>> spaces = [];

  /// Kode yang dibalas `POST /invitations`.
  String invitationCode = 'K7M2QX';

  /// Ruang Bersama yang dibalas `POST /invitations/accept`.
  Map<String, dynamic>? acceptedSpace;

  /// Selama menyala, semua request gagal seperti HP tanpa koneksi.
  bool offline = false;

  final List<Responder> _scripted = [];

  /// Dipanggil tepat sebelum setiap request dijawab.
  void Function(SentRequest request)? onRequest;

  int _tick = 0;

  /// Timpa balasan request berikutnya (bisa dipanggil beberapa kali, dijawab berurutan).
  void enqueue(Responder responder) => _scripted.add(responder);

  void failNext(Object error, {int times = 1}) {
    for (var i = 0; i < times; i++) {
      enqueue((_) => throw error);
    }
  }

  List<String> get log => [for (final request in requests) request.toString()];

  List<SentRequest> sent(String method) => requests.where((request) => request.method == method).toList();

  /// Waktu server dengan mikrodetik, naik setiap dipanggil supaya `updated_at` selalu berbeda.
  String stamp() {
    final time = _now().add(Duration(microseconds: ++_tick));
    return time.toUtc().toIso8601String();
  }

  Map<String, dynamic>? row(String resource, String id) => rows[resource]?[id];

  /// Simpan baris "di server" tanpa melewati request.
  Map<String, dynamic> seed(String resource, Map<String, dynamic> row) {
    final time = stamp();
    final stored = {'created_at': time, 'updated_at': time, 'deleted_at': null, ...row};
    rows.putIfAbsent(resource, () => {})[row['id'] as String] = stored;
    return stored;
  }

  @override
  Future<ApiResponse> send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    ApiUpload? upload,
  }) async {
    final request = SentRequest(method, path, body, query);
    requests.add(request);
    onRequest?.call(request);

    // Beri kesempatan kode lain berjalan, seperti request sungguhan. Cukup satu mikrotugas,
    // supaya tes widget tidak perlu memajukan jam palsu.
    await Future<void>.value();

    if (offline) throw const NetworkFailure();
    if (_scripted.isNotEmpty) return _scripted.removeAt(0)(request);
    return handle(request);
  }

  /// Jawaban bawaan untuk [request], tanpa mencatatnya lagi. Berguna di dalam [enqueue].
  ApiResponse handle(SentRequest request) {
    final segments = request.path.split('/').where((part) => part.isNotEmpty).toList();

    if (request.method == 'GET' && segments.first == 'sync') {
      if (syncPages.isEmpty) return ApiResponse(status: 200, body: syncPage());
      return ApiResponse(status: 200, body: syncPages.removeAt(0));
    }

    if (segments.first == 'me') {
      if (request.method == 'PATCH') me = {...?me, ...?request.body, 'updated_at': stamp()};
      return ApiResponse(status: 200, body: {'data': me});
    }

    if (segments.first == 'spaces') return ApiResponse(status: 200, body: {'data': spaces});

    if (segments.first == 'devices') {
      return ApiResponse(status: 201, body: {'data': request.body});
    }

    if (segments.first == 'invitations') {
      if (segments.length > 1) {
        final space = acceptedSpace;
        if (space == null) {
          throw apiError(422, ApiErrorCode.invitationInvalid, message: 'Kode tidak berlaku, minta kode baru.');
        }
        spaces = [...spaces, space];
        return ApiResponse(status: 201, body: {'data': space});
      }
      return ApiResponse(
        status: 200,
        body: {
          'data': {
            'code': invitationCode,
            'expires_at': _now().add(const Duration(hours: 48)).toUtc().toIso8601String(),
          },
        },
      );
    }

    if (segments.first == 'auth') {
      if (segments[1] == 'logout') return const ApiResponse(status: 204);
      return ApiResponse(
        status: 200,
        body: {
          'data': {'token': '1|token-palsu', 'user': me},
        },
      );
    }

    final resource = segments[0];
    final id = segments[1];
    final table = rows.putIfAbsent(resource, () => {});
    final existing = table[id];

    switch (request.method) {
      case 'PUT':
        if (existing != null) return ApiResponse(status: 200, body: {'data': existing});
        final time = stamp();
        final created = {
          ..._defaults(resource),
          ...?request.body,
          'id': id,
          'created_at': time,
          'updated_at': time,
          'deleted_at': null,
        };
        table[id] = created;
        return ApiResponse(status: 201, body: {'data': created});

      case 'PATCH':
        if (existing == null) throw apiError(404, ApiErrorCode.notFound, current: null);
        final updated = {...existing, ...?request.body, 'updated_at': stamp()};
        if (request.body?.containsKey('completed_at') ?? false) {
          updated['completed_by'] = request.body!['completed_at'] == null ? null : 'server-user';
        }
        table[id] = updated;
        return ApiResponse(status: 200, body: {'data': updated});

      case 'DELETE':
        if (existing != null) table[id] = {...existing, 'deleted_at': stamp(), 'updated_at': stamp()};
        return const ApiResponse(status: 204);
    }

    throw StateError('FakeApi tidak mengenal $request');
  }

  /// Kolom yang diisi server saat data dibuat.
  static Map<String, dynamic> _defaults(String resource) => switch (resource) {
    'lists' => {'emoji': null, 'color': 'mawar', 'archived_at': null, 'created_by': 'server-user'},
    'tasks' => {
      'space_id': 'space-shared',
      'notes': null,
      'due_date': null,
      'due_time': null,
      'priority': 0,
      'assignee_ids': ['server-user'],
      'remind_at': null,
      'completed_at': null,
      'completed_by': null,
      'created_by': 'server-user',
      'updated_by': 'server-user',
    },
    'savings-goals' => {
      'emoji': null,
      'target_date': null,
      'achieved_at': null,
      'archived_at': null,
      'created_by': 'server-user',
    },
    'savings-entries' => {'space_id': 'space-shared', 'user_id': 'server-user', 'type': 'deposit', 'note': null},
    _ => {},
  };

  /// Bentuk balasan `GET /sync`.
  Map<String, dynamic> syncPage({
    List<Map<String, dynamic>> spaces = const [],
    List<Map<String, dynamic>> taskLists = const [],
    List<Map<String, dynamic>> tasks = const [],
    List<Map<String, dynamic>> savingsGoals = const [],
    List<Map<String, dynamic>> savingsEntries = const [],
    String? serverTime,
    String? nextCursor,
  }) => {
    'data': {
      'spaces': spaces,
      'task_lists': taskLists,
      'tasks': tasks,
      'savings_goals': savingsGoals,
      'savings_entries': savingsEntries,
    },
    'meta': {'server_time': serverTime ?? stamp(), 'has_more': nextCursor != null, 'next_cursor': nextCursor},
  };
}

/// Error JSON dengan `code` yang dikenal. [current] hanya disertakan kalau diisi (boleh `null`).
ApiError apiError(
  int status,
  ApiErrorCode code, {
  String message = 'Pesan dari server.',
  Object? current = _absent,
  Duration? retryAfter,
}) => ApiError(
  status: status,
  code: code,
  message: message,
  hasCurrent: !identical(current, _absent),
  current: identical(current, _absent) ? null : current as Map<String, dynamic>?,
  retryAfter: retryAfter,
);

const Object _absent = Object();
