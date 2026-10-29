import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/database/app_database.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/database/local_store.dart';
import 'package:todolist/core/database/mappers.dart';
import 'package:todolist/core/sync/sync_engine.dart';
import 'package:todolist/features/memories/domain/memory.dart';

import 'helpers/fake_api.dart';
import 'helpers/fixtures.dart';

/// Pin lokasi kenangan dan cari tempat (v1.x): lapisan data.
void main() {
  Map<String, dynamic> pinned(Map<String, dynamic> memory, num latitude, num longitude) => {
    ...memory,
    'latitude': latitude,
    'longitude': longitude,
  };

  Future<Memory?> local(Harness h) async {
    final row = await h.local(EntityType.memory, memoryId);
    return row == null ? null : Memory.fromJson(row);
  }

  Map<String, dynamic> payload(OutboxRow op) => jsonDecode(op.payload!) as Map<String, dynamic>;

  group('titik', () {
    test('dibulatkan ke 6 desimal seperti server; di luar jangkauan ditolak', () {
      expect(GeoPoint.tryCreate(-8.5068534, 115.2624779), const GeoPoint(-8.506853, 115.262478));
      expect(GeoPoint.tryCreate(90, -180), const GeoPoint(90, -180));
      expect(GeoPoint.tryCreate(90.000001, 0), isNull);
      expect(GeoPoint.tryCreate(0, 180.5), isNull);
      expect(GeoPoint.tryCreate(double.nan, 0), isNull);
    });

    test('angka bulat dari server dibaca sebagai num', () {
      final memory = Memory.fromJson(pinned(memoryJson(), -8, 115));
      expect(memory.pin, const GeoPoint(-8, 115));
      expect(Memory.fromJson(memoryJson()).pin, isNull);
    });
  });

  group('antrean', () {
    test('kenangan baru dengan pin: PUT membawa lintang dan bujur yang sudah dibulatkan', () async {
      final h = Harness();
      addTearDown(h.dispose);
      await h.seed();

      final memory = await h.account.memories.create(
        spaceId: sharedSpaceId,
        title: 'Liburan ke Bali',
        visitedOn: '2026-06-20',
        pin: const GeoPoint(-8.5068534, 115.2624779),
      );

      final op = (await h.ops()).single;
      expect(payload(op), containsPair('latitude', -8.506853));
      expect(payload(op), containsPair('longitude', 115.262478));
      expect((await h.local(EntityType.memory, memory.id))!['latitude'], -8.506853);
    });

    test('tanpa pin: PUT tidak membawa kolom lokasi', () async {
      final h = Harness();
      addTearDown(h.dispose);
      await h.seed();

      await h.account.memories.create(spaceId: sharedSpaceId, title: 'Makan malam', visitedOn: '2026-06-20');
      expect(payload((await h.ops()).single).keys, isNot(contains('latitude')));
    });

    test('pasang dan lepas pin: lintang dan bujur selalu dikirim berdua', () async {
      final h = Harness();
      addTearDown(h.dispose);
      await h.seed();
      await h.account.store.write(EntityType.memory, memoryJson(), serverUpdatedAt: t0);
      h.api.seed('memories', memoryJson());

      await h.account.memories.setPin(memoryId, const GeoPoint(-6.914744, 107.609810));
      expect(payload((await h.ops()).single), {'latitude': -6.914744, 'longitude': 107.60981});
      expect((await local(h))!.pin, const GeoPoint(-6.914744, 107.60981));

      await h.account.outbox.flush();
      await h.account.memories.setPin(memoryId, null);
      final ops = await h.ops();
      expect(payload(ops.last), {'latitude': null, 'longitude': null});
      expect((await local(h))!.pin, isNull);
    });

    test('pin yang belum terkirim tidak ditimpa sync, termasuk pasangannya', () async {
      final h = Harness();
      addTearDown(h.dispose);
      await h.seed();
      await h.account.store.write(EntityType.memory, memoryJson(), serverUpdatedAt: t0);
      await h.account.memories.setPin(memoryId, const GeoPoint(-6.9, 107.6));

      h.api.offline = true;
      await h.account.store.setMeta(MetaKeys.syncSince, 'T-0');
      await h.account.store.setMeta(MetaKeys.syncCollections, '${SyncEngine.collectionsVersion}');
      h.api.offline = false;
      // Antrean ditahan, jadi sync hanya menarik data.
      h.api.enqueue((_) => throw const NetworkFailure());
      h.api.syncPages.add(
        h.api.syncPage(
          memories: [pinned(memoryJson(updatedAt: '2026-10-08T12:00:00.000000Z', story: 'Cerita baru'), -8.5, 115.2)],
        ),
      );
      await h.account.sync.sync();

      final memory = (await local(h))!;
      expect(memory.pin, const GeoPoint(-6.9, 107.6));
      expect(memory.story, 'Cerita baru');
    });
  });

  group('sync', () {
    test('sync penuh sekali setelah app mengenal pin lokasi', () async {
      final h = Harness();
      addTearDown(h.dispose);
      await h.account.store.setMeta(MetaKeys.syncSince, 'T-lama');
      await h.account.store.setMeta(MetaKeys.syncCollections, '5');
      h.api.syncPages.add(h.api.syncPage(serverTime: 'T-1', memories: [pinned(memoryJson(), -8.506853, 115.262477)]));

      expect(SyncEngine.collectionsVersion, greaterThanOrEqualTo(6));
      await h.account.sync.sync();

      expect(
        [
          for (final request in h.api.requests)
            if (request.path == '/sync') request.query,
        ],
        [null],
      );
      expect((await local(h))!.pin, const GeoPoint(-8.506853, 115.262477));
      expect(await h.account.store.meta(MetaKeys.syncCollections), '${SyncEngine.collectionsVersion}');
    });

    test('database versi 5 dinaikkan ke versi 6: kolom pin di kenangan, isi lama tetap ada', () async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      final dir = await Directory.systemTemp.createTemp('denly_migrasi6');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/akun.sqlite');

      final old = AppDatabase(NativeDatabase(file));
      await old.into(old.memories).insert(memoryCompanion(Memory.fromJson(memoryJson())));
      for (final statement in [
        'ALTER TABLE memories DROP COLUMN latitude',
        'ALTER TABLE memories DROP COLUMN longitude',
        'PRAGMA user_version = 5',
      ]) {
        await old.customStatement(statement);
      }
      await old.close();

      final upgraded = AppDatabase(NativeDatabase(file));
      addTearDown(upgraded.close);

      final before = (await upgraded.select(upgraded.memories).getSingle()).toModel();
      expect((before.title, before.pin), ('Liburan ke Bali', null));

      await upgraded
          .update(upgraded.memories)
          .write(const MemoriesCompanion(latitude: Value(-8.5), longitude: Value(115.2)));
      expect((await upgraded.select(upgraded.memories).getSingle()).toModel().pin, const GeoPoint(-8.5, 115.2));
    });
  });

  group('cari tempat', () {
    test('GET /places dengan kata kunci yang dirapikan; hasilnya nama, alamat, dan titik', () async {
      final h = Harness();
      addTearDown(h.dispose);
      h.api.places = [
        {'name': 'Ubud', 'address': 'Ubud, Gianyar, Bali, Indonesia', 'latitude': -8.506853, 'longitude': 115},
      ];

      final places = await h.account.memories.searchPlaces('  ubud ');
      expect(h.api.requests.single.query, {'q': 'ubud'});
      expect(
        [for (final place in places) (place.name, place.address, place.point)],
        [('Ubud', 'Ubud, Gianyar, Bali, Indonesia', const GeoPoint(-8.506853, 115))],
      );
    });

    test('pencarian yang dimatikan server tetap sampai sebagai ApiError', () async {
      final h = Harness();
      addTearDown(h.dispose);
      h.api.failNext(apiError(503, ApiErrorCode.placesUnavailable, message: 'Pencarian tempat sedang tidak tersedia.'));

      await expectLater(
        h.account.memories.searchPlaces('ubud'),
        throwsA(isA<ApiError>().having((error) => error.code, 'code', ApiErrorCode.placesUnavailable)),
      );
    });
  });
}
