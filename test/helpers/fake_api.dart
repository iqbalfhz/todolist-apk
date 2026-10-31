import 'dart:async';
import 'dart:convert';

import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/api/api_transport.dart';

/// Satu request yang diterima [FakeApi].
class SentRequest {
  SentRequest(this.method, this.path, this.body, this.query, [this.upload]);

  final String method;
  final String path;
  final Map<String, dynamic>? body;
  final Map<String, dynamic>? query;

  /// Berkas `multipart/form-data`, untuk `POST /memory-photos/{id}`.
  final ApiUpload? upload;

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

  /// Isi `GET /me/export` (v1.0), dan teks mentahnya kalau berbeda dari JSON yang ditulis ulang.
  Map<String, dynamic>? exportFile;
  String? exportRaw;

  /// Ruang Bersama yang dibalas `POST /invitations/accept`.
  Map<String, dynamic>? acceptedSpace;

  /// Hasil `GET /places` (v1.x).
  List<Map<String, dynamic>> places = [];

  /// Selama menyala, semua request gagal seperti HP tanpa koneksi.
  bool offline = false;

  final List<Responder> _scripted = [];

  /// Dipanggil tepat sebelum setiap request dijawab.
  void Function(SentRequest request)? onRequest;

  int _tick = 0;
  int _nextTasks = 0;

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
    final request = SentRequest(method, path, body, query, upload);
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

    // Ekspor data (v1.0): berkas JSON tanpa pembungkus `data`, dengan nama dari header.
    if (segments.first == 'me' && segments.length > 1 && segments[1] == 'export') {
      final file = exportFile ?? {'app': 'Denly Days', 'format_version': 1, 'user': me};
      return ApiResponse(
        status: 200,
        body: file,
        raw: exportRaw ?? jsonEncode(file),
        headers: {'content-disposition': 'attachment; filename="denly-days-2026-10-08.json"'},
      );
    }

    if (segments.first == 'me') {
      // Hapus akun (v1.0).
      if (request.method == 'DELETE') return const ApiResponse(status: 204);
      if (request.method == 'PATCH') me = {...?me, ...?request.body, 'updated_at': stamp()};
      return ApiResponse(status: 200, body: {'data': me});
    }

    if (segments.first == 'spaces') {
      // Keluar dari Ruang Bersama (v1.0): ruangnya ditutup, dan diulang pun tetap 204.
      if (request.method == 'DELETE') {
        spaces = [
          for (final space in spaces)
            if (space['id'] != segments[1]) space,
        ];
        return const ApiResponse(status: 204);
      }
      return ApiResponse(status: 200, body: {'data': spaces});
    }

    if (request.method == 'GET' && segments.first == 'places') {
      return ApiResponse(status: 200, body: {'data': places});
    }

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

    if (resource == 'memories' && request.method == 'GET') return _memoryPhotos(id, existing);
    if (resource == 'memory-photos' && request.method == 'POST') return _uploadPhoto(request, id, existing);

    switch (request.method) {
      case 'PUT':
        if (existing != null) {
          if (resource == 'tasks') return _taskReply(table, id, existing, Map.of(existing), status: 200);
          return ApiResponse(status: 200, body: {'data': existing});
        }
        final time = stamp();
        final created = {
          ..._defaults(resource),
          ...?request.body,
          'id': id,
          'created_at': time,
          'updated_at': time,
          'deleted_at': null,
        };
        if (resource == 'tasks') return _taskReply(table, id, null, created, status: 201);
        // Seperti server: penulis komentar dan pemilik reaksi adalah akun yang mengirim.
        if (resource == 'comments' || resource == 'reactions') created['user_id'] = me?['id'] ?? created['user_id'];
        table[id] = created;
        return ApiResponse(status: 201, body: {'data': created});

      case 'PATCH':
        if (existing == null) throw apiError(404, ApiErrorCode.notFound, current: null);
        final updated = {...existing, ...?request.body, 'updated_at': stamp()};
        if (request.body?.containsKey('completed_at') ?? false) {
          updated['completed_by'] = request.body!['completed_at'] == null ? null : 'server-user';
        }
        if (resource == 'tasks') {
          // Seperti server: tanpa tanggal, aturan ulang ikut kosong.
          if (updated['due_date'] == null) {
            updated['repeat_frequency'] = null;
            updated['repeat_interval'] = null;
          }
          return _taskReply(table, id, existing, updated);
        }
        table[id] = updated;
        return ApiResponse(status: 200, body: {'data': updated});

      case 'DELETE':
        if (existing != null) table[id] = {...existing, 'deleted_at': stamp(), 'updated_at': stamp()};
        // Server ikut menghapus foto kenangan yang dihapus.
        if (resource == 'memories') {
          final photos = rows['memory-photos'] ?? {};
          for (final photo in photos.values.toList()) {
            if (photo['memory_id'] == id && photo['deleted_at'] == null) {
              photos[photo['id'] as String] = {
                ...photo,
                'url': null,
                'thumb_url': null,
                'deleted_at': stamp(),
                'updated_at': stamp(),
              };
            }
          }
        }
        return const ApiResponse(status: 204);
    }

    throw StateError('FakeApi tidak mengenal $request');
  }

  /// Balasan tugas (v1.0): `{"data": ..., "next_task": ...}`. Tugas berulang yang baru selesai
  /// membuat tugas berikutnya sekali saja; Urungkan menghapusnya selama belum disentuh.
  ApiResponse _taskReply(
    Map<String, Map<String, dynamic>> table,
    String id,
    Map<String, dynamic>? before,
    Map<String, dynamic> after, {
    int status = 200,
  }) {
    final wasDone = before?['completed_at'] != null;
    final isDone = after['completed_at'] != null;
    var nextId = after['next_task_id'] as String?;

    if (!wasDone && isDone && after['repeat_frequency'] != null && nextId == null) {
      nextId = '${id.substring(0, 22)}n${(++_nextTasks).toString().padLeft(3, '0')}';
      final time = stamp();
      table[nextId] = {
        ...after,
        'id': nextId,
        'due_date': nextDueDate(after),
        'completed_at': null,
        'completed_by': null,
        'next_task_id': null,
        'created_at': time,
        'updated_at': time,
        'deleted_at': null,
      };
      after['next_task_id'] = nextId;
    } else if (wasDone && !isDone && nextId != null) {
      final next = table[nextId];
      // Belum disentuh: belum pernah diubah sejak dibuat.
      if (next != null && next['updated_at'] == next['created_at']) {
        table[nextId] = {...next, 'deleted_at': stamp(), 'updated_at': stamp()};
        after['next_task_id'] = null;
        nextId = null;
      }
    }

    table[id] = after;
    final next = nextId == null ? null : table[nextId];
    return ApiResponse(
      status: status,
      body: {'data': after, 'next_task': next == null || next['deleted_at'] != null ? null : next},
    );
  }

  /// Tenggat berikutnya versi sederhana: tenggat lama ditambah selangnya.
  static String nextDueDate(Map<String, dynamic> task) {
    final parts = (task['due_date'] as String).split('-').map(int.parse).toList();
    final every = (task['repeat_interval'] as int?) ?? 1;
    final (year, month, day) = (parts[0], parts[1], parts[2]);
    final next = switch (task['repeat_frequency']) {
      'daily' => DateTime.utc(year, month, day + every),
      'weekly' => DateTime.utc(year, month, day + 7 * every),
      'monthly' => DateTime.utc(year, month + every, day),
      _ => DateTime.utc(year + every, month, day),
    };
    String two(int value) => value.toString().padLeft(2, '0');
    return '${next.year}-${two(next.month)}-${two(next.day)}';
  }

  /// URL R2 bertanda tangan palsu untuk foto [id], berlaku 7 hari sejak sekarang.
  String photoUrl(String id, {bool thumb = false, DateTime? signedAt}) {
    final time = (signedAt ?? _now()).toUtc();
    String two(int value) => value.toString().padLeft(2, '0');
    final amzDate =
        '${time.year}${two(time.month)}${two(time.day)}T${two(time.hour)}${two(time.minute)}${two(time.second)}Z';
    return 'https://r2.contoh.test/memories/$id${thumb ? '-thumb' : ''}.jpg?X-Amz-Date=$amzDate&X-Amz-Expires=604800&X-Amz-Signature=palsu';
  }

  /// `GET /memories/{id}/photos`: foto yang belum dihapus, urut `position`, dengan URL baru.
  ApiResponse _memoryPhotos(String memoryId, Map<String, dynamic>? memory) {
    if (memory == null) throw apiError(404, ApiErrorCode.notFound);
    if (memory['deleted_at'] != null) throw apiError(410, ApiErrorCode.resourceDeleted, current: memory);

    final photos = rows['memory-photos'] ?? {};
    final own = [
      for (final photo in photos.values)
        if (photo['memory_id'] == memoryId && photo['deleted_at'] == null) photo,
    ]..sort((a, b) => (a['position'] as num).compareTo(b['position'] as num));

    final fresh = [
      for (final photo in own)
        {...photo, 'url': photoUrl(photo['id'] as String), 'thumb_url': photoUrl(photo['id'] as String, thumb: true)},
    ];
    for (final photo in fresh) {
      photos[photo['id'] as String] = photo;
    }
    return ApiResponse(status: 200, body: {'data': fresh});
  }

  /// `POST /memory-photos/{id}` (multipart), dengan aturan yang sama seperti `PUT`.
  ApiResponse _uploadPhoto(SentRequest request, String id, Map<String, dynamic>? existing) {
    if (existing != null) {
      if (existing['deleted_at'] != null) throw apiError(410, ApiErrorCode.resourceDeleted, current: existing);
      return ApiResponse(status: 200, body: {'data': existing});
    }
    if (request.upload == null) throw apiError(422, ApiErrorCode.validationFailed, message: 'Foto wajib diisi.');

    final body = request.body ?? const {};
    final memoryId = body['memory_id'] as String;
    final memory = rows['memories']?[memoryId];
    if (memory == null || memory['deleted_at'] != null) {
      throw apiError(409, ApiErrorCode.parentDeleted, message: 'Kenangan ini sudah dihapus.');
    }

    final photos = rows.putIfAbsent('memory-photos', () => {});
    final count = photos.values.where((photo) => photo['memory_id'] == memoryId && photo['deleted_at'] == null).length;
    if (count >= 50) {
      throw apiError(422, ApiErrorCode.validationFailed, message: 'Satu kenangan paling banyak 50 foto.');
    }

    final time = stamp();
    final created = <String, dynamic>{
      'id': id,
      'memory_id': memoryId,
      'space_id': memory['space_id'],
      'uploaded_by': 'server-user',
      'position': num.parse('${body['position']}'),
      'width': 2560,
      'height': 1920,
      'taken_at': body['taken_at'],
      'url': photoUrl(id),
      'thumb_url': photoUrl(id, thumb: true),
      'created_at': time,
      'updated_at': time,
      'deleted_at': null,
    };
    photos[id] = created;
    return ApiResponse(status: 201, body: {'data': created});
  }

  /// Kolom yang diisi server saat data dibuat.
  static Map<String, dynamic> _defaults(String resource) => switch (resource) {
    'lists' => {'emoji': null, 'color': 'mawar', 'archived_at': null, 'trip_id': null, 'created_by': 'server-user'},
    'tasks' => {
      'repeat_frequency': null,
      'repeat_interval': null,
      'next_task_id': null,
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
      'reminder_frequency': null,
      'reminder_day': null,
      'achieved_at': null,
      'archived_at': null,
      'created_by': 'server-user',
    },
    'savings-entries' => {'space_id': 'space-shared', 'user_id': 'server-user', 'type': 'deposit', 'note': null},
    'special-dates' => {'created_by': 'server-user'},
    'comments' || 'reactions' => {'space_id': 'space-shared', 'user_id': 'server-user'},
    'memories' => {'trip_id': null, 'place_name': null, 'story': null, 'created_by': 'server-user'},
    'trips' => {
      'destination': null,
      'start_date': null,
      'end_date': null,
      'notes': null,
      'savings_goal_id': null,
      'created_by': 'server-user',
    },
    _ => {},
  };

  /// Bentuk balasan `GET /sync`.
  Map<String, dynamic> syncPage({
    List<Map<String, dynamic>> spaces = const [],
    List<Map<String, dynamic>> taskLists = const [],
    List<Map<String, dynamic>> tasks = const [],
    List<Map<String, dynamic>> savingsGoals = const [],
    List<Map<String, dynamic>> savingsEntries = const [],
    List<Map<String, dynamic>> specialDates = const [],
    List<Map<String, dynamic>> trips = const [],
    List<Map<String, dynamic>> memories = const [],
    List<Map<String, dynamic>> memoryPhotos = const [],
    List<Map<String, dynamic>> comments = const [],
    List<Map<String, dynamic>> reactions = const [],
    String? serverTime,
    String? nextCursor,
  }) => {
    'data': {
      'spaces': spaces,
      'task_lists': taskLists,
      'tasks': tasks,
      'savings_goals': savingsGoals,
      'savings_entries': savingsEntries,
      'special_dates': specialDates,
      'trips': trips,
      'memories': memories,
      'memory_photos': memoryPhotos,
      'comments': comments,
      'reactions': reactions,
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
