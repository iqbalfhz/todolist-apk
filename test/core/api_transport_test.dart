import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/api/api_transport.dart';

/// Klien HTTP yang asli terhadap server lokal sementara: header, pembacaan balasan,
/// dan terutama pemilahan error dari tabel Error di kontrak. Data lokal hanya boleh
/// dibuang kalau balasannya JSON dengan `code` yang dikenal; sisanya selalu "coba lagi".
void main() {
  late HttpServer server;
  late Future<void> Function(HttpRequest request) handler;
  final seen = <HttpRequest>[];
  String? token;

  DioApiTransport transport() => DioApiTransport(baseUrl: 'http://127.0.0.1:${server.port}/api/v1', token: () => token);

  Future<void> json(HttpRequest request, int status, Object body, {Map<String, String> headers = const {}}) async {
    request.response.statusCode = status;
    request.response.headers.contentType = ContentType.json;
    headers.forEach(request.response.headers.set);
    request.response.write(jsonEncode(body));
    await request.response.close();
  }

  Future<void> html(HttpRequest request, int status) async {
    request.response.statusCode = status;
    request.response.headers.contentType = ContentType.html;
    request.response.write('<html><body>Bad Gateway</body></html>');
    await request.response.close();
  }

  setUp(() async {
    seen.clear();
    token = '1|token-hp-ini';
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) {
      seen.add(request);
      handler(request);
    });
  });

  tearDown(() => server.close(force: true));

  group('request', () {
    test('header: Accept JSON, token Bearer, dan body JSON di bawah /api/v1', () async {
      Map<String, dynamic>? received;
      handler = (request) async {
        received = jsonDecode(await utf8.decoder.bind(request).join()) as Map<String, dynamic>;
        await json(request, 201, {
          'data': {'id': 'abc'},
        });
      };

      final response = await transport().send('PUT', '/tasks/abc', body: {'title': 'Beli galon', 'notes': null});

      final request = seen.single;
      expect(request.method, 'PUT');
      expect(request.uri.path, '/api/v1/tasks/abc');
      expect(request.headers.value('accept'), 'application/json');
      expect(request.headers.value('authorization'), 'Bearer 1|token-hp-ini');
      expect(request.headers.contentType?.mimeType, 'application/json');
      // Kolom kosong tetap dikirim sebagai null, supaya PATCH bisa mengosongkan kolom.
      expect(received, {'title': 'Beli galon', 'notes': null});
      expect(response.status, 201);
      expect(response.data, {'id': 'abc'});
    });

    test('belum masuk: tanpa header Authorization', () async {
      token = null;
      handler = (request) => json(request, 200, {
        'data': {'token': '1|baru'},
      });

      await transport().send('POST', '/auth/login', body: {'email': 'nama@email.com'});

      expect(seen.single.headers.value('authorization'), isNull);
    });

    test('kueri dikirim apa adanya: since untuk halaman pertama sync', () async {
      handler = (request) => json(request, 200, {'data': <String, dynamic>{}, 'meta': <String, dynamic>{}});

      await transport().send('GET', '/sync', query: {'since': '2026-10-08T11:10:05.123456Z'});

      expect(seen.single.uri.queryParameters, {'since': '2026-10-08T11:10:05.123456Z'});
    });

    test('foto profil: multipart dengan kolom photo berisi JPEG', () async {
      late String contentType;
      late List<int> body;
      handler = (request) async {
        contentType = request.headers.value('content-type')!;
        body = await request.fold<List<int>>([], (all, chunk) => all..addAll(chunk));
        await json(request, 200, {
          'data': {'avatar_version': 1},
        });
      };
      final jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3, 0xFF, 0xD9]);

      final response = await transport().send(
        'POST',
        '/me/avatar',
        upload: ApiUpload(field: 'photo', bytes: jpeg, filename: 'avatar.jpg', mimeType: 'image/jpeg'),
      );

      expect(contentType, startsWith('multipart/form-data; boundary='));
      final text = latin1.decode(body);
      expect(text, contains('name="photo"; filename="avatar.jpg"'));
      expect(text.toLowerCase(), contains('content-type: image/jpeg'));
      expect(text, contains(latin1.decode(jpeg)));
      expect(seen.single.headers.value('authorization'), 'Bearer 1|token-hp-ini');
      expect(response.data['avatar_version'], 1);
    });

    test('pengalihan tidak diikuti, jadi token tidak pernah terkirim ke alamat lain', () async {
      final elsewhere = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final reached = <HttpRequest>[];
      elsewhere.listen((request) async {
        reached.add(request);
        await json(request, 200, {'data': <String, dynamic>{}});
      });
      addTearDown(() => elsewhere.close(force: true));

      handler = (request) async {
        request.response.statusCode = 302;
        request.response.headers.set('location', 'http://127.0.0.1:${elsewhere.port}/curi');
        await request.response.close();
      };

      await expectLater(transport().send('GET', '/me'), throwsA(isA<NetworkFailure>()));
      expect(reached, isEmpty);
      expect(seen.single.headers.value('authorization'), 'Bearer 1|token-hp-ini');
    });

    test('foto kenangan: kolom formulir ikut multipart, yang kosong tidak dikirim', () async {
      late List<int> body;
      handler = (request) async {
        body = await request.fold<List<int>>([], (all, chunk) => all..addAll(chunk));
        await json(request, 201, {
          'data': {'id': 'foto-1'},
        });
      };
      final jpeg = Uint8List.fromList([0xFF, 0xD8, 9, 0xFF, 0xD9]);

      final response = await transport().send(
        'POST',
        '/memory-photos/foto-1',
        body: {'memory_id': 'kenangan-1', 'position': 1024.0, 'taken_at': null},
        upload: ApiUpload(field: 'photo', bytes: jpeg, filename: 'foto-1.jpg', mimeType: 'image/jpeg'),
      );

      final text = latin1.decode(body);
      expect(seen.single.uri.path, '/api/v1/memory-photos/foto-1');
      expect(text, contains('name="memory_id"\r\n\r\nkenangan-1\r\n'));
      expect(text, contains('name="position"\r\n\r\n1024.0\r\n'));
      expect(text, isNot(contains('name="taken_at"')));
      expect(text, contains('name="photo"; filename="foto-1.jpg"'));
      expect(response.status, 201);
    });
  });

  group('balasan berhasil', () {
    test('204 tanpa body diterima (DELETE dan keluar)', () async {
      handler = (request) async {
        request.response.statusCode = 204;
        await request.response.close();
      };

      final response = await transport().send('DELETE', '/tasks/abc');

      expect(response.status, 204);
      expect(response.body, isNull);
    });

    test('200 yang bukan JSON dianggap gangguan, misalnya halaman login Wi-Fi publik', () async {
      handler = (request) => html(request, 200);

      await expectLater(
        transport().send('PATCH', '/tasks/abc', body: {'title': 'x'}),
        throwsA(isA<NetworkFailure>().having((failure) => failure.status, 'status', 200)),
      );
    });
  });

  group('error dengan code yang dikenal menjadi ApiError', () {
    test('422 validation_failed membawa pesan, errors per kolom, dan current', () async {
      handler = (request) => json(request, 422, {
        'message': 'Judul wajib diisi.',
        'code': 'validation_failed',
        'errors': {
          'title': ['Judul wajib diisi.'],
        },
        'current': null,
      });

      await expectLater(
        transport().send('PUT', '/tasks/abc', body: {'title': ''}),
        throwsA(
          isA<ApiError>()
              .having((error) => error.status, 'status', 422)
              .having((error) => error.code, 'code', ApiErrorCode.validationFailed)
              .having((error) => error.message, 'message', 'Judul wajib diisi.')
              .having((error) => error.messageFor('title'), 'pesan kolom', 'Judul wajib diisi.')
              // `current: null` berbeda dari tanpa `current`: data itu belum ada di server.
              .having((error) => error.hasCurrent, 'hasCurrent', isTrue)
              .having((error) => error.current, 'current', isNull),
        ),
      );
    });

    test('409 last_list membawa current yang terisi', () async {
      handler = (request) => json(request, 409, {
        'message': 'Setiap ruang harus punya minimal satu daftar aktif.',
        'code': 'last_list',
        'current': {'id': 'abc', 'name': 'Tugas'},
      });

      await expectLater(
        transport().send('DELETE', '/lists/abc'),
        throwsA(
          isA<ApiError>().having((error) => error.code, 'code', ApiErrorCode.lastList).having(
            (error) => error.current,
            'current',
            {'id': 'abc', 'name': 'Tugas'},
          ),
        ),
      );
    });

    test('balasan tanpa kunci current: hasCurrent salah', () async {
      handler = (request) =>
          json(request, 409, {'message': 'Kamu sudah punya Ruang Bersama.', 'code': 'shared_space_exists'});

      await expectLater(
        transport().send('POST', '/invitations'),
        throwsA(isA<ApiError>().having((error) => error.hasCurrent, 'hasCurrent', isFalse)),
      );
    });

    test('401 unauthenticated', () async {
      handler = (request) => json(request, 401, {'message': 'Sesi kamu sudah berakhir.', 'code': 'unauthenticated'});

      await expectLater(
        transport().send('PATCH', '/me', body: {'name': 'Iqbal'}),
        throwsA(isA<ApiError>().having((error) => error.code, 'code', ApiErrorCode.unauthenticated)),
      );
    });

    test('429 membawa jeda dari header Retry-After', () async {
      handler = (request) => json(
        request,
        429,
        {'message': 'Terlalu sering.', 'code': 'too_many_requests'},
        headers: {'retry-after': '7'},
      );

      await expectLater(
        transport().send('PATCH', '/tasks/abc', body: {'title': 'x'}),
        throwsA(
          isA<ApiError>()
              .having((error) => error.code, 'code', ApiErrorCode.tooManyRequests)
              .having((error) => error.retryAfter, 'retryAfter', const Duration(seconds: 7)),
        ),
      );
    });

    test('404: not_found dan route_not_found dibedakan', () async {
      handler = (request) => json(request, 404, {
        'message': 'Tidak ditemukan.',
        'code': request.uri.path.endsWith('/tasks/abc') ? 'not_found' : 'route_not_found',
      });

      await expectLater(
        transport().send('PATCH', '/tasks/abc', body: {'title': 'x'}),
        throwsA(isA<ApiError>().having((error) => error.code, 'code', ApiErrorCode.notFound)),
      );
      await expectLater(
        transport().send('PATCH', '/versi-baru/abc', body: {'title': 'x'}),
        throwsA(isA<ApiError>().having((error) => error.code, 'code', ApiErrorCode.routeNotFound)),
      );
    });
  });

  group('selain itu selalu "coba lagi" (NetworkFailure), tidak pernah alasan membuang data', () {
    test('404 tanpa JSON, misalnya dari proxy saat server sedang deploy', () async {
      handler = (request) => html(request, 404);

      await expectLater(
        transport().send('PATCH', '/tasks/abc', body: {'title': 'x'}),
        throwsA(isA<NetworkFailure>().having((failure) => failure.status, 'status', 404)),
      );
    });

    test('502 dari proxy', () async {
      handler = (request) => html(request, 502);

      await expectLater(
        transport().send('PUT', '/tasks/abc', body: {'title': 'x'}),
        throwsA(isA<NetworkFailure>().having((failure) => failure.status, 'status', 502)),
      );
    });

    test('500 server_error walau berbentuk JSON', () async {
      handler = (request) => json(request, 500, {'message': 'Ada yang tidak beres.', 'code': 'server_error'});

      await expectLater(
        transport().send('DELETE', '/tasks/abc'),
        throwsA(isA<NetworkFailure>().having((failure) => failure.status, 'status', 500)),
      );
    });

    test('JSON dengan code yang tidak dikenal versi app ini', () async {
      handler = (request) => json(request, 409, {'message': 'Aturan baru.', 'code': 'aturan_versi_depan'});

      await expectLater(
        transport().send('DELETE', '/tasks/abc'),
        throwsA(isA<NetworkFailure>().having((failure) => failure.status, 'status', 409)),
      );
    });

    test('JSON error tanpa code sama sekali', () async {
      handler = (request) => json(request, 404, {'message': 'Not Found'});

      await expectLater(transport().send('DELETE', '/tasks/abc'), throwsA(isA<NetworkFailure>()));
    });

    test('server tidak terjangkau: tanpa status, dan operasi tulis tidak diulang sendiri', () async {
      final unreachable = DioApiTransport(baseUrl: 'http://127.0.0.1:${server.port}/api/v1', token: () => token);
      await server.close(force: true);

      await expectLater(
        unreachable.send('PUT', '/tasks/abc', body: {'title': 'x'}),
        throwsA(isA<NetworkFailure>().having((failure) => failure.noConnection, 'noConnection', isTrue)),
      );
      expect(seen, isEmpty);
    });
  });

  test('GET yang putus di tengah jalan diulang; operasi tulis tidak', () async {
    var attempts = 0;
    handler = (request) async {
      attempts++;
      if (attempts == 1) {
        // Putuskan sambungan sebelum membalas.
        final socket = await request.response.detachSocket(writeHeaders: false);
        socket.destroy();
        return;
      }
      await json(request, 200, {
        'data': {'id': 'abc'},
      });
    };

    final response = await transport().send('GET', '/me');
    expect(response.data, {'id': 'abc'});
    expect(attempts, 2);

    attempts = 0;
    await expectLater(transport().send('PATCH', '/me', body: {'name': 'Iqbal'}), throwsA(isA<NetworkFailure>()));
    expect(attempts, 1, reason: 'antrean punya jeda coba ulangnya sendiri');
  });
}
