import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/api/api_transport.dart';
import 'package:todolist/core/config/env.dart';
import 'package:todolist/core/media/photo_cache.dart';
import 'package:todolist/core/media/photo_files.dart';
import 'package:todolist/core/media/photo_picker.dart';
import 'package:todolist/core/platform/device_platform.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/core/session/session.dart';
import 'package:todolist/core/session/token_revocations.dart';
import 'package:todolist/core/storage/key_value_store.dart';

import 'helpers/app_harness.dart';
import 'helpers/fake_api.dart';
import 'helpers/fake_photos.dart';
import 'helpers/fixtures.dart';

/// Klien API palsu untuk pencabutan token: mencatat token tiap request dan bisa gagal.
class _RevocationApi implements ApiTransport {
  _RevocationApi(this.token, this.log, this.answer);

  final String token;
  final List<String> log;
  final Object? Function(String token) answer;

  @override
  Future<ApiResponse> send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    ApiUpload? upload,
  }) async {
    log.add('$method $path $token ${jsonEncode(body)}');
    final error = answer(token);
    if (error != null) throw error;
    return const ApiResponse(status: 204);
  }
}

/// Penyimpanan yang tidak bisa dibaca, seperti kunci perangkat yang hilang.
class _BrokenStore implements KeyValueStore {
  @override
  Future<String?> read(String key) async => throw PlatformException(code: 'kunci-hilang');

  @override
  Future<void> write(String key, String? value) async {}
}

void main() {
  setUpAll(prepareAppTests);

  group('alamat API', () {
    test('build rilis hanya menerima HTTPS; HTTP hanya untuk API lokal di build debug', () {
      expect(apiBaseUrlProblem('https://denlydays.iqbalfhz.my.id/api/v1', release: true), isNull);
      expect(apiBaseUrlProblem('http://127.0.0.1:8000/api/v1', release: false), isNull);
      expect(apiBaseUrlProblem('http://denlydays.iqbalfhz.my.id/api/v1', release: true), contains('HTTPS'));
      expect(apiBaseUrlProblem('', release: true), contains('belum diisi'));
      expect(apiBaseUrlProblem('ftp://contoh.test', release: false), contains('tidak valid'));
      expect(apiBaseUrlProblem('bukan alamat', release: false), contains('tidak valid'));
    });
  });

  group('ID sebagai nama berkas', () {
    late Directory dir;
    late PhotoFiles files;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('denly_keamanan');
      files = PhotoFiles(directory: () async => Directory('${dir.path}/foto'), cache: const NoPhotoCache());
    });
    tearDown(() => dir.delete(recursive: true));

    test('ID foto yang bukan ULID tidak pernah dijadikan nama berkas', () async {
      final outside = File('${dir.path}/rahasia.jpg')..writeAsBytesSync([1, 2, 3]);

      expect(await files.pending('../rahasia'), isNull);
      await expectLater(files.save('../rahasia', Uint8List.fromList([9])), throwsArgumentError);
      expect(outside.readAsBytesSync(), [1, 2, 3], reason: 'berkas di luar folder foto tidak tersentuh');

      // ULID biasa tetap bisa disimpan dan dibaca.
      await files.save(photoId, Uint8List.fromList([7]));
      expect((await files.pending(photoId))!.readAsBytesSync(), [7]);
    });

    test('folder foto dan database akun hanya untuk ID akun berbentuk ULID', () {
      expect(() => PhotoFiles.forAccount('../akun', const NoPhotoCache()), throwsArgumentError);
    });

    test('salinan sementara foto hanya dihapus kalau ada di folder cache app', () async {
      final cache = await Directory('${dir.path}/cache').create();
      final inside = File('${cache.path}/image_picker_1.jpg')..writeAsBytesSync([1]);
      final outside = File('${dir.path}/galeri.jpg')..writeAsBytesSync([1]);

      await discardTemporaryFile(outside.path, temporaryDirectory: () async => cache);
      await discardTemporaryFile('${cache.path}/../galeri.jpg', temporaryDirectory: () async => cache);
      expect(outside.existsSync(), isTrue);

      await discardTemporaryFile(inside.path, temporaryDirectory: () async => cache);
      expect(inside.existsSync(), isFalse);

      expect(isWithinDirectory('${cache.path}/a.jpg', cache.path), isTrue);
      expect(isWithinDirectory('${cache.path}/../a.jpg', cache.path), isFalse);
      expect(isWithinDirectory(cache.path, cache.path), isFalse);
    });
  });

  group('sesi', () {
    testWidgets('ID akun tersimpan yang bukan ULID, atau penyimpanan yang rusak, berarti belum masuk', (tester) async {
      const channel = MethodChannel('todolist/device');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (_) async => {'manufacturer': 'Google', 'brand': 'google', 'model': 'Pixel 8', 'sdkInt': 34},
      );
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));

      final valid = await Bootstrap.load(
        MemoryKeyValueStore({StorageKeys.token: '1|token', StorageKeys.userId: meId}),
        const DevicePlatform(),
      );
      expect(valid.userId, meId);

      final tampered = await Bootstrap.load(
        MemoryKeyValueStore({StorageKeys.token: '1|token', StorageKeys.userId: '../../databases/x'}),
        const DevicePlatform(),
      );
      expect((tampered.userId, tampered.token), (null, null));

      final broken = await Bootstrap.load(_BrokenStore(), const DevicePlatform());
      expect((broken.userId, broken.token), (null, null));
    });
  });

  group('token yang belum tercabut', () {
    late MemoryKeyValueStore storage;
    late TokenRevocations revocations;
    final log = <String>[];

    setUp(() {
      storage = MemoryKeyValueStore();
      revocations = TokenRevocations(storage);
      log.clear();
    });

    test('dicabut dengan tokennya sendiri; yang gagal karena jaringan dicoba lagi nanti', () async {
      await revocations.add('1|lama', fcmToken: 'fcm-lama');
      await revocations.add('2|offline');
      await revocations.add('1|lama', fcmToken: 'fcm-lama');
      expect([for (final item in await revocations.pending()) item.token], ['2|offline', '1|lama']);

      await revocations.revokeAll(
        (token) => _RevocationApi(token, log, (token) => token == '2|offline' ? const NetworkFailure() : null),
      );

      expect(log, [
        'POST /auth/logout 2|offline {"fcm_token":null}',
        'POST /auth/logout 1|lama {"fcm_token":"fcm-lama"}',
      ]);
      expect([for (final item in await revocations.pending()) item.token], ['2|offline']);

      // Token yang sudah tidak berlaku (401) tidak perlu dicabut lagi.
      await revocations.revokeAll(
        (token) => _RevocationApi(token, log, (_) => apiError(401, ApiErrorCode.unauthenticated)),
      );
      expect(await revocations.pending(), isEmpty);
      expect(storage.values.containsKey(StorageKeys.pendingRevocations), isFalse);
    });

    test('isi yang rusak dibuang, bukan membuat app gagal', () async {
      storage.values[StorageKeys.pendingRevocations] = '{bukan json';
      expect(await revocations.pending(), isEmpty);
      expect(storage.values.containsKey(StorageKeys.pendingRevocations), isFalse);
    });
  });

  testWidgets('keluar saat offline: token disimpan, dicabut saat app aktif lagi, dan cache foto dikosongkan', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final h = Harness();
    final storage = MemoryKeyValueStore({StorageKeys.token: '1|token-palsu', StorageKeys.userId: meId});
    await h.seed();
    h.api.offline = true;
    final container = await pumpApp(tester, h, storage: storage);

    await tester.tap(find.bySemanticsLabel('Buka Pengaturan'));
    await settle(tester);
    await tester.scrollUntilVisible(find.text('Keluar'), 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keluar'));
    await settle(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Keluar'));
    await settle(tester);

    expect(container.read(sessionProvider).isSignedIn, isFalse);
    expect(storage.values.containsKey(StorageKeys.token), isFalse);
    expect(h.mediaCaches.clears, 1);
    expect([for (final item in await TokenRevocations(storage).pending()) item.token], ['1|token-palsu']);

    // Kembali online lalu app aktif lagi: token lama dicabut dengan dirinya sendiri.
    h.api.offline = false;
    // Urutan yang sama seperti Android: ke latar belakang lalu kembali.
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await settle(tester);

    expect(h.revocationTokens, ['1|token-palsu']);
    expect(h.api.log.where((line) => line == 'POST /auth/logout'), hasLength(2));
    expect(await TokenRevocations(storage).pending(), isEmpty);

    semantics.dispose();
    await disposeApp(tester, h);
  });

  testWidgets('foto yang dipilih tapi tidak jadi disimpan dibuang dari cache', (tester) async {
    final h = Harness();
    await h.seed();
    final picker = FakePhotoPicker()..picks.add(['galeri/a.jpg', 'galeri/b.jpg', 'galeri/c.jpg']);
    final container = await pumpApp(tester, h, photoPicker: picker);

    container.read(routerProvider).go(Routes.newMemory());
    await settle(tester);
    await tester.scrollUntilVisible(find.text('Pilih foto'), 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pilih foto'));
    await settle(tester);

    await tester.tap(find.byTooltip('Batal pilih foto 2'));
    await settle(tester);
    expect(picker.discarded, ['galeri/b.jpg']);

    // Keluar dari formulir tanpa menyimpan.
    container.read(routerProvider).go(Routes.memories);
    await settle(tester);
    expect(picker.discarded, ['galeri/b.jpg', 'galeri/a.jpg', 'galeri/c.jpg']);
    expect(picker.prepared, isEmpty);

    await disposeApp(tester, h);
  });
}
