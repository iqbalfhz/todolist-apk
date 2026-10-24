import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/database/app_database.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/database/local_store.dart';
import 'package:todolist/core/database/mappers.dart';
import 'package:todolist/core/l10n/l10n.dart';
import 'package:todolist/core/media/photo_cache.dart';
import 'package:todolist/core/media/photo_picker.dart';
import 'package:todolist/core/notifications/push_service.dart';
import 'package:todolist/core/queue/outbox.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/core/sync/sync_engine.dart';
import 'package:todolist/features/auth/domain/user.dart';
import 'package:todolist/features/memories/domain/memory.dart';
import 'package:todolist/features/memories/domain/memory_photo.dart';
import 'package:todolist/features/memories/domain/memory_views.dart';
import 'package:todolist/features/memories/presentation/memory_photo_view.dart';
import 'package:todolist/features/spaces/domain/household.dart';
import 'package:todolist/features/spaces/domain/space.dart';
import 'package:todolist/features/tasks/domain/task_list.dart';
import 'package:todolist/features/trips/domain/trip.dart';

import 'helpers/app_harness.dart';
import 'helpers/fake_api.dart';
import 'helpers/fake_photos.dart';
import 'helpers/fake_push.dart';
import 'helpers/fixtures.dart';

extension MemoriesHarness on Harness {
  /// Kenangan "Liburan ke Bali" dari [tripId], dengan [photos] foto yang sudah terunggah.
  /// Datanya juga ada "di server".
  Future<void> seedMemory({int photos = 2, String? linkedTrip = tripId}) async {
    final memory = memoryJson(tripId: linkedTrip);
    await account.store.write(EntityType.memory, memory, serverUpdatedAt: t0);
    api.rows.putIfAbsent('memories', () => {})[memoryId] = memory;

    for (var i = 0; i < photos; i++) {
      final photo = memoryPhotoJson(id: [photoId, photo2Id][i], position: 1024.0 * (i + 1));
      await account.store.write(EntityType.memoryPhoto, photo, serverUpdatedAt: t0);
      api.rows.putIfAbsent('memory-photos', () => {})[photo['id'] as String] = photo;
    }
  }

  Future<List<MemoryPhoto>> photosOf(String memory) => account.store.memoryPhotos(memory);

  List<String> opNames(List<OutboxRow> ops) => [for (final op in ops) '${op.method} ${op.entityType}'];
}

/// Gulir halaman sampai [finder] terlihat; isi ListView yang jauh di bawah belum dibangun.
Future<void> reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
}

PreparedPhoto prepared([int seed = 1]) =>
    PreparedPhoto(jpeg: fakeJpeg(seed), width: 2560, height: 1920, takenAt: '2027-06-20T10:12:45+07:00');

void main() {
  setUpAll(prepareAppTests);

  final l10n = lookupAppLocalizations(const Locale('id'));

  Map<String, dynamic> payloadOf(OutboxRow op) => jsonDecode(op.payload!) as Map<String, dynamic>;

  // ------------------------------------------------------------------ foto sebelum diunggah

  group('foto sebelum diunggah', () {
    test('dikecilkan ke sisi terpanjang 2560 px; foto besar dibaca dengan inSampleSize dulu', () {
      expect(compressionPlan(4000, 3000), (target: 1920, sample: 1));
      expect(compressionPlan(3000, 4000), (target: 1920, sample: 1));
      expect(compressionPlan(5120, 5120), (target: 2560, sample: 2));
      expect(compressionPlan(12000, 9000), (target: 1920, sample: 4));
      // Foto yang sudah kecil tidak diperbesar.
      expect(compressionPlan(2000, 1000), (target: 1000, sample: 1));
      expect(compressionPlan(2560, 1440), (target: 1440, sample: 1));
    });

    test('taken_at dari EXIF foto asli, dengan offset dari EXIF atau dari HP', () {
      expect(exifTakenAt('2027:06:20 10:12:45', '+07:00'), '2027-06-20T10:12:45+07:00');
      expect(exifTakenAt('2027:06:20 10:12:45', '-03:30'), '2027-06-20T10:12:45-03:30');

      final minutes = DateTime(2027, 6, 20, 10, 12, 45).timeZoneOffset.inMinutes;
      final zone =
          '${minutes < 0 ? '-' : '+'}${(minutes.abs() ~/ 60).toString().padLeft(2, '0')}:'
          '${(minutes.abs() % 60).toString().padLeft(2, '0')}';
      expect(exifTakenAt('2027:06:20 10:12:45', null), '2027-06-20T10:12:45$zone');

      expect(exifTakenAt('0000:00:00 00:00:00', null), isNull);
      expect(exifTakenAt('2027:02:30 10:00:00', '+07:00'), isNull);
      expect(exifTakenAt('', '+07:00'), isNull);
      expect(exifTakenAt(null, null), isNull);
    });

    test('URL bertanda tangan berlaku 7 hari, dan dianggap habis satu jam lebih awal', () {
      final url = signedPhotoUrl(photoId);
      expect(signedUrlExpiry(url), DateTime.utc(2026, 10, 15, 10));
      expect(isSignedUrlExpired(url, DateTime.utc(2026, 10, 15, 8, 59)), isFalse);
      expect(isSignedUrlExpired(url, DateTime.utc(2026, 10, 15, 9)), isTrue);

      expect(signedUrlExpiry('https://contoh.test/foto.jpg'), isNull);
      expect(isSignedUrlExpired('https://contoh.test/foto.jpg', DateTime.utc(2030)), isFalse);
    });
  });

  // ------------------------------------------------------------------ linimasa

  test('linimasa per tahun dan bulan dari visited_on, terbaru dulu; sampul adalah position terkecil', () {
    final household = Household(
      me: User.fromJson(userJson()),
      spaces: [Space.fromJson(sharedSpaceJson()), Space.fromJson(personalSpaceJson())],
    );
    String id(String suffix) => '01m4dr8c50jk2mt7xw3pq9vb8$suffix';

    final memories = [
      memoryJson(id: id('a'), tripId: tripId, visitedOn: '2027-06-20', createdAt: t0),
      memoryJson(id: id('b'), visitedOn: '2027-06-20', createdAt: t1),
      memoryJson(id: id('c'), visitedOn: '2027-01-05', spaceId: personalSpaceId),
      memoryJson(id: id('d'), visitedOn: '2026-12-31'),
      memoryJson(id: id('e'), visitedOn: '2027-07-01', deletedAt: t1),
      memoryJson(id: id('f'), visitedOn: '2027-08-01', spaceId: '01m4dgdt40te98hy85v3fe2t99'),
    ].map(Memory.fromJson).toList();
    final photos = [
      memoryPhotoJson(id: '01m4drb7k0qz3n8st5vw2hx6a1', memory: id('a'), position: 2048),
      memoryPhotoJson(id: '01m4drb7k0qz3n8st5vw2hx6a2', memory: id('a'), position: 1024),
      memoryPhotoJson(id: '01m4drb7k0qz3n8st5vw2hx6a3', memory: id('a'), position: 1, deletedAt: t1),
    ].map(MemoryPhoto.fromJson).toList();

    final items = buildMemoryItems(
      memories: memories,
      photos: photos,
      trips: [Trip.fromJson(tripJson())],
      household: household,
    );

    expect([for (final item in items) item.memory.id], [id('b'), id('a'), id('c'), id('d')]);
    final withPhotos = items[1];
    expect(withPhotos.photos.map((photo) => photo.position), [1024, 2048]);
    expect(withPhotos.cover!.id, '01m4drb7k0qz3n8st5vw2hx6a2');
    expect(withPhotos.trip!.title, 'Liburan ke Bali');
    expect(items.first.cover, isNull);

    final years = memoryTimeline(items);
    expect([for (final year in years) (year.year, year.count)], [(2027, 3), (2026, 1)]);
    expect([for (final month in years.first.months) (month.month, month.items.length)], [(6, 2), (1, 1)]);
    expect(memoriesOfTrip(items, tripId).single.memory.id, id('a'));
  });

  // ------------------------------------------------------------------ repository dan antrean

  group('repository dan antrean', () {
    late Harness h;

    setUp(() async {
      h = Harness();
      await h.seed();
    });
    tearDown(() => h.dispose());

    Future<Memory> createMemory({String? story = '  ', String? trip}) => h.account.memories.create(
      spaceId: sharedSpaceId,
      title: ' Liburan ke Bali ',
      placeName: 'Ubud, Bali',
      visitedOn: '2027-06-20',
      story: story,
      tripId: trip,
    );

    test('buat kenangan: PUT /memories dengan isi yang dirapikan, langsung di HP', () async {
      final memory = await createMemory(trip: tripId);

      final op = (await h.ops()).single;
      expect('${op.method} ${op.entityType}', 'PUT memory');
      expect(payloadOf(op), {
        'space_id': sharedSpaceId,
        'title': 'Liburan ke Bali',
        'place_name': 'Ubud, Bali',
        'visited_on': '2027-06-20',
        'story': null,
        'trip_id': tripId,
      });
      expect(memory.createdBy, meId);
      expect((await h.local(EntityType.memory, memory.id))!['title'], 'Liburan ke Bali');

      expect(await h.account.outbox.flush(), FlushState.idle);
      expect(h.api.log, ['PUT /memories/${memory.id}']);
    });

    test('aturan isi sama dengan server', () async {
      Future<Memory> create({String title = 'Bali', String? place, String visitedOn = '2027-06-20', String? story}) => h
          .account
          .memories
          .create(spaceId: sharedSpaceId, title: title, placeName: place, visitedOn: visitedOn, story: story);

      await expectLater(create(title: '   '), throwsArgumentError);
      await expectLater(create(title: 'a' * 51), throwsArgumentError);
      await expectLater(create(place: 'a' * 101), throwsArgumentError);
      await expectLater(create(story: 'a' * 10001), throwsArgumentError);
      await expectLater(create(visitedOn: '2027-02-30'), throwsArgumentError);
      expect(await h.ops(), isEmpty);

      // Panjang dihitung per code point, seperti server.
      await create(title: '😀' * 50, place: 'a' * 100, story: '😀' * 10000);
      expect(await h.ops(), hasLength(1));
    });

    test('ubah: hanya kolom yang berubah yang dikirim', () async {
      final memory = await createMemory();
      await h.account.outbox.flush();

      await h.account.memories.edit(
        memory.id,
        title: 'Liburan ke Ubud',
        placeName: 'Ubud, Bali',
        visitedOn: '2027-06-20',
        story: 'Seru',
      );

      final op = (await h.ops()).single;
      expect(op.method, 'PATCH');
      expect(payloadOf(op), {'title': 'Liburan ke Ubud', 'story': 'Seru'});
    });

    test('tambah foto: POST multipart setelah PUT kenangannya, lalu berkasnya jadi cache versi penuh', () async {
      final memory = await createMemory();
      expect(await h.account.memories.addPhotos(memory, [prepared(1), prepared(2)]), 2);

      final ops = await h.ops();
      expect(h.opNames(ops), ['PUT memory', 'POST memoryPhoto', 'POST memoryPhoto']);
      expect(payloadOf(ops[1]), {'memory_id': memory.id, 'position': 1024.0, 'taken_at': '2027-06-20T10:12:45+07:00'});
      expect(payloadOf(ops[2])['position'], 2048.0);

      final photos = await h.photosOf(memory.id);
      expect([for (final photo in photos) photo.isUploaded], [false, false]);
      expect([for (final photo in photos) (photo.width, photo.height)], [(2560, 1920), (2560, 1920)]);
      expect(h.photoFiles.files.keys, [for (final photo in photos) photo.id]);

      expect(await h.account.outbox.flush(), FlushState.idle);
      expect(h.api.log, [
        'PUT /memories/${memory.id}',
        'POST /memory-photos/${photos[0].id}',
        'POST /memory-photos/${photos[1].id}',
      ]);
      final upload = h.api.sent('POST').first.upload!;
      expect((upload.field, upload.filename, upload.mimeType), ('photo', '${photos[0].id}.jpg', 'image/jpeg'));
      expect(upload.bytes, orderedEquals(fakeJpeg(1)));

      final uploaded = await h.photosOf(memory.id);
      expect([for (final photo in uploaded) photo.isUploaded], [true, true]);
      expect(uploaded.first.spaceId, sharedSpaceId);
      expect(h.photoFiles.files, isEmpty);
      expect(h.photoCache.fulls.keys, [for (final photo in photos) photo.id]);
    });

    test('paling banyak 50 foto per kenangan', () async {
      final memory = await createMemory();

      expect(await h.account.memories.addPhotos(memory, [for (var i = 0; i < 49; i++) prepared(i)]), 49);
      expect(await h.account.memories.addPhotos(memory, [prepared(1), prepared(2)]), 1);
      expect(await h.account.memories.addPhotos(memory, [prepared(3)]), 0);

      expect(await h.photosOf(memory.id), hasLength(50));
    });

    test('Jadikan sampul: PATCH position lebih kecil dari foto pertama', () async {
      await h.seedMemory();
      final photos = await h.photosOf(memoryId);

      await h.account.memories.makeCover(photos.first);
      expect(await h.ops(), isEmpty, reason: 'sudah jadi sampul');

      await h.account.memories.makeCover(photos.last);
      final op = (await h.ops()).single;
      expect((op.method, op.entityId), ('PATCH', photo2Id));
      expect(payloadOf(op), {'position': 0.0});
      expect([for (final photo in await h.photosOf(memoryId)) photo.id], [photo2Id, photoId]);
    });

    test('hapus foto: tunggu 5 detik selama Urungkan tampil', () async {
      await h.seedMemory();

      final first = await h.account.memories.deletePhoto(photoId);
      expect(await h.account.memories.undo(first!), isTrue);
      expect(await h.photosOf(memoryId), hasLength(2));
      expect(await h.ops(), isEmpty);

      await h.account.memories.deletePhoto(photoId);
      expect(await h.account.outbox.flush(), FlushState.waitingUndo);
      h.clock.advance(Outbox.undoWindow);
      expect(await h.account.outbox.flush(), FlushState.idle);
      expect(h.api.log, ['DELETE /memory-photos/$photoId']);
      expect([for (final photo in await h.photosOf(memoryId)) photo.id], [photo2Id]);
    });

    test('hapus kenangan berfoto: foto yang belum terunggah tidak dikirim lagi', () async {
      final memory = await createMemory();
      await h.account.memories.addPhotos(memory, [prepared(1), prepared(2)]);
      final photos = await h.photosOf(memory.id);

      await h.account.memories.delete(memory.id);

      expect(h.opNames(await h.ops()), ['PUT memory', 'DELETE memory']);
      expect(h.photoFiles.files, isEmpty);
      for (final photo in photos) {
        expect(await h.local(EntityType.memoryPhoto, photo.id), isNull);
      }

      await h.account.outbox.flush();
      expect(h.api.log, ['PUT /memories/${memory.id}', 'DELETE /memories/${memory.id}']);
    });

    test('hapus kenangan tanpa foto: bisa diurungkan selama 5 detik', () async {
      final memory = await createMemory();
      await h.account.outbox.flush();

      final opId = await h.account.memories.delete(memory.id, undoable: true);
      expect((await h.local(EntityType.memory, memory.id))!['deleted_at'], isNotNull);

      expect(await h.account.memories.undo(opId!), isTrue);
      expect((await h.local(EntityType.memory, memory.id))!['deleted_at'], isNull);
      expect(await h.ops(), isEmpty);
    });

    test('409 parent_deleted: foto ke kenangan yang sudah dihapus dibuang, lalu diberi tahu', () async {
      final memory = await createMemory();
      await h.account.outbox.flush();
      await h.account.memories.addPhotos(memory, [prepared()]);
      final photo = (await h.photosOf(memory.id)).single;
      h.api.rows['memories']![memory.id]!['deleted_at'] = t1;

      final events = <OutboxEvent>[];
      final subscription = h.account.outbox.events.listen(events.add);
      addTearDown(subscription.cancel);

      expect(await h.account.outbox.flush(), FlushState.idle);
      await Future<void>.delayed(Duration.zero);

      expect(await h.ops(), isEmpty);
      expect(await h.local(EntityType.memoryPhoto, photo.id), isNull);
      expect(h.photoFiles.files, isEmpty);
      expect([for (final event in events.whereType<OutboxRejected>()) event.message], ['Kenangan ini sudah dihapus.']);
    });

    test('POST dibalas 200: data tersimpan dipakai; 410: fotonya dihapus dari HP', () async {
      final memory = await createMemory();
      await h.account.outbox.flush();
      await h.account.memories.addPhotos(memory, [prepared(1), prepared(2)]);
      final photos = await h.photosOf(memory.id);
      h.api
        ..seed('memory-photos', memoryPhotoJson(id: photos[0].id, memory: memory.id, position: 512))
        ..seed('memory-photos', memoryPhotoJson(id: photos[1].id, memory: memory.id, deletedAt: t1));

      expect(await h.account.outbox.flush(), FlushState.idle);

      final kept = (await h.photosOf(memory.id)).single;
      expect((kept.id, kept.isUploaded, kept.position), (photos[0].id, true, 512));
      expect(await h.local(EntityType.memoryPhoto, photos[1].id), isNull);
      expect(h.photoFiles.files, isEmpty);
      expect(await h.ops(), isEmpty);
    });

    test('berkas yang hilang dari HP: operasinya dibuang tanpa dikirim', () async {
      final memory = await createMemory();
      await h.account.memories.addPhotos(memory, [prepared()]);
      final photo = (await h.photosOf(memory.id)).single;
      h.photoFiles.files.clear();

      expect(await h.account.outbox.flush(), FlushState.idle);

      expect(h.api.log, ['PUT /memories/${memory.id}']);
      expect(await h.local(EntityType.memoryPhoto, photo.id), isNull);
    });

    test('foto ke-51 ditolak 422: dibuang dan diberi tahu', () async {
      final memory = await createMemory();
      await h.account.outbox.flush();
      for (var i = 0; i < 50; i++) {
        h.api.seed(
          'memory-photos',
          memoryPhotoJson(id: '01m4drb7k0qz3n8st5vw2hx7${i.toString().padLeft(2, '0')}', memory: memory.id),
        );
      }
      await h.account.memories.addPhotos(memory, [prepared()]);
      final photo = (await h.photosOf(memory.id)).single;

      final events = <OutboxEvent>[];
      final subscription = h.account.outbox.events.listen(events.add);
      addTearDown(subscription.cancel);
      await h.account.outbox.flush();
      await Future<void>.delayed(Duration.zero);

      expect(await h.local(EntityType.memoryPhoto, photo.id), isNull);
      expect(h.photoFiles.files, isEmpty);
      expect(events.whereType<OutboxRejected>().single.message, 'Satu kenangan paling banyak 50 foto.');
    });
  });

  // ------------------------------------------------------------------ gambar foto

  group('gambar foto', () {
    late Harness h;

    setUp(() async {
      h = Harness();
      await h.seed();
    });
    tearDown(() => h.dispose());

    MemoryPhoto photoFrom(Map<String, dynamic> json) => MemoryPhoto.fromJson(json);

    test('thumbnail diunduh sekali lalu dipakai dari cache; versi penuh baru diunduh saat dibuka', () async {
      final photo = photoFrom(memoryPhotoJson());

      expect(await h.account.photoImages.thumb(photo), isNotNull);
      expect(await h.account.photoImages.thumb(photo), isNotNull);
      expect(h.photoCache.downloads, [photo.thumbUrl]);

      expect(await h.account.photoImages.full(photo), isNotNull);
      expect(h.photoCache.downloads, [photo.thumbUrl, photo.url]);
    });

    test('foto yang baru diunggah dari HP ini dipakai langsung, tanpa unduhan', () async {
      final memory = await h.account.memories.create(spaceId: sharedSpaceId, title: 'Bali', visitedOn: '2027-06-20');
      await h.account.memories.addPhotos(memory, [prepared()]);
      final pending = (await h.photosOf(memory.id)).single;
      expect(await h.account.photoImages.thumb(pending), isNotNull);

      await h.account.outbox.flush();
      final uploaded = (await h.photosOf(memory.id)).single;
      expect(await h.account.photoImages.thumb(uploaded), isNotNull);
      expect(await h.account.photoImages.full(uploaded), isNotNull);
      expect(h.photoCache.downloads, isEmpty);
    });

    test('R2 membalas 403: ambil URL baru lewat GET /memories/{id}/photos, lalu unduh lagi', () async {
      await h.seedMemory(photos: 1);
      final old = memoryPhotoJson(signedAt: '20261007T100000Z');
      await h.account.store.write(EntityType.memoryPhoto, old, serverUpdatedAt: t0);
      final photo = photoFrom(old);
      h.photoCache.expired.add(photo.thumbUrl!);

      expect(await h.account.photoImages.thumb(photo), isNotNull);

      final fresh = h.api.photoUrl(photoId, thumb: true);
      expect(h.photoCache.downloads, [photo.thumbUrl, fresh]);
      expect(h.api.log, ['GET /memories/$memoryId/photos']);
      expect((await h.local(EntityType.memoryPhoto, photoId))!['thumb_url'], fresh);
    });

    test('URL berumur 7 hari langsung diganti tanpa mencoba yang lama, sekali per kenangan', () async {
      await h.seedMemory();
      final photos = [
        photoFrom(memoryPhotoJson(signedAt: '20261001T100000Z')),
        photoFrom(memoryPhotoJson(id: photo2Id, position: 2048, signedAt: '20261001T100000Z')),
      ];

      await Future.wait([for (final photo in photos) h.account.photoImages.thumb(photo)]);

      expect(h.api.log, ['GET /memories/$memoryId/photos']);
      expect(h.photoCache.downloads.toSet(), {
        h.api.photoUrl(photoId, thumb: true),
        h.api.photoUrl(photo2Id, thumb: true),
      });
    });

    test('kenangan yang sudah dihapus di server: tidak ada URL baru, gambarnya kosong', () async {
      await h.seedMemory(photos: 1);
      h.api.rows['memories']![memoryId]!['deleted_at'] = t1;

      expect(await h.account.photoImages.thumb(photoFrom(memoryPhotoJson(signedAt: '20261001T100000Z'))), isNull);
      expect(h.photoCache.downloads, isEmpty);
    });

    test('thumbnail diunduh setelah sync; berhenti setelah tiga kegagalan berturut-turut', () async {
      final photos = [
        for (var i = 0; i < 5; i++)
          photoFrom(memoryPhotoJson(id: '01m4drb7k0qz3n8st5vw2hx8a$i', position: 1024.0 * (i + 1))),
      ];

      h.photoCache.offline = true;
      await h.account.photoImages.prefetchThumbs(photos);
      expect(h.photoCache.downloads, hasLength(3));

      h.photoCache.offline = false;
      await h.account.photoImages.prefetchThumbs(photos);
      expect(h.photoCache.downloads, hasLength(8));
      expect(h.photoCache.thumbs, hasLength(5));

      await h.account.photoImages.prefetchThumbs(photos);
      expect(h.photoCache.downloads, hasLength(8), reason: 'semuanya sudah di cache');
      expect(h.photoCache.fulls, isEmpty, reason: 'versi penuh hanya saat dibuka');
    });
  });

  // ------------------------------------------------------------------ sync dan database

  group('sync', () {
    late Harness h;

    setUp(() => h = Harness());
    tearDown(() => h.dispose());

    test('sync membawa kenangan dan fotonya', () async {
      h.api.syncPages.add(
        h.api.syncPage(
          spaces: [sharedSpaceJson()],
          memories: [memoryJson()],
          memoryPhotos: [
            memoryPhotoJson(),
            memoryPhotoJson(id: photo2Id, position: 512),
          ],
        ),
      );

      expect(await h.account.sync.sync(), isTrue);

      expect((await h.local(EntityType.memory, memoryId))!['place_name'], 'Ubud, Bali');
      expect([for (final photo in await h.photosOf(memoryId)) photo.id], [photo2Id, photoId]);
    });

    test('kenangan yang dihapus pasangan: fotonya ikut terhapus, kecuali yang masih menunggu terkirim', () async {
      await h.seed();
      await h.seedMemory(photos: 1);
      final memory = Memory.fromJson(memoryJson());
      await h.account.memories.addPhotos(memory, [prepared()]);
      final pending = (await h.photosOf(memoryId)).firstWhere((photo) => !photo.isUploaded);

      h.api.syncPages.add(
        h.api.syncPage(
          memories: [memoryJson(deletedAt: t1, updatedAt: t1)],
        ),
      );
      await h.account.store.setMeta(MetaKeys.syncSince, 'T-lama');
      await h.account.store.setMeta(MetaKeys.syncCollections, '${SyncEngine.collectionsVersion}');
      // Unggahannya belum berhasil, jadi operasinya masih tertunda saat data ditarik.
      h.api.failNext(const NetworkFailure());
      await h.account.sync.sync();

      expect((await h.local(EntityType.memory, memoryId))!['deleted_at'], isNotNull);
      expect((await h.local(EntityType.memoryPhoto, photoId))!['deleted_at'], isNotNull);
      expect((await h.local(EntityType.memoryPhoto, pending.id))!['deleted_at'], isNull);
    });

    test('sync penuh sekali setelah app mengenal kenangan (v0.3)', () async {
      await h.account.store.setMeta(MetaKeys.syncSince, 'T-lama');
      await h.account.store.setMeta(MetaKeys.syncCollections, '3');
      h.api.syncPages.add(h.api.syncPage(serverTime: 'T-1'));

      expect(SyncEngine.collectionsVersion, 4);
      expect(await h.account.sync.sync(), isTrue);

      expect(
        [
          for (final request in h.api.requests)
            if (request.path == '/sync') request.query,
        ],
        [null],
      );
      expect(await h.account.store.meta(MetaKeys.syncCollections), '4');
      expect(await h.account.store.meta(MetaKeys.syncSince), 'T-1');
    });
  });

  test('database versi 3 dinaikkan ke versi 4: tabel kenangan dan foto, isi lama tetap ada', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = await Directory.systemTemp.createTemp('denly_migrasi4');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/akun.sqlite');

    final old = AppDatabase(NativeDatabase(file));
    await old.into(old.taskLists).insert(taskListCompanion(TaskList.fromJson(listJson())));
    for (final statement in ['DROP TABLE memories', 'DROP TABLE memory_photos', 'PRAGMA user_version = 3']) {
      await old.customStatement(statement);
    }
    await old.close();

    final upgraded = AppDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);

    expect(await upgraded.select(upgraded.memories).get(), isEmpty);
    expect(await upgraded.select(upgraded.memoryPhotos).get(), isEmpty);
    expect((await upgraded.select(upgraded.taskLists).getSingle()).name, 'Belanja');

    await upgraded.into(upgraded.memories).insert(memoryCompanion(Memory.fromJson(memoryJson())));
    await upgraded.into(upgraded.memoryPhotos).insert(memoryPhotoCompanion(MemoryPhoto.fromJson(memoryPhotoJson())));
    expect((await upgraded.select(upgraded.memoryPhotos).getSingle()).thumbUrl, signedPhotoUrl(photoId, thumb: true));
  });

  // ------------------------------------------------------------------ layar

  group('tab Kenangan', () {
    testWidgets('kosong: buat kenangan dengan dua foto, lalu detailnya terbuka', (tester) async {
      final h = Harness();
      await h.seed();
      final picker = FakePhotoPicker()..picks.add(['galeri/a.jpg', 'galeri/b.jpg', 'galeri/c.jpg']);
      await pumpApp(tester, h, photoPicker: picker);

      await tester.tap(find.text('Kenangan'));
      await settle(tester);
      expect(find.text(l10n.memoriesEmpty), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Kenangan baru'));
      await settle(tester);
      expect(find.text('Mau dikenang sebagai apa?'), findsOneWidget);

      await reveal(tester, find.widgetWithText(FilledButton, 'Simpan'));
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await settle(tester);
      expect(find.text('Judul kenangan belum diisi.'), findsOneWidget);
      expect(await h.ops(), isEmpty);

      await tester.enterText(find.byType(TextField).at(0), 'Liburan ke Bali');
      await tester.enterText(find.byType(TextField).at(1), 'Ubud, Bali');
      await tester.enterText(find.byType(TextField).at(2), 'Hari pertama hujan.');

      await reveal(tester, find.text('Pilih foto'));
      await settle(tester);
      await tester.tap(find.text('Pilih foto'));
      await settle(tester);
      expect(picker.limits, [50]);
      expect(find.byTooltip('Batal pilih foto 3'), findsOneWidget);

      await tester.tap(find.byTooltip('Batal pilih foto 3'));
      await settle(tester);
      expect(find.byTooltip('Batal pilih foto 3'), findsNothing);

      await reveal(tester, find.widgetWithText(FilledButton, 'Simpan'));
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await settle(tester);

      expect(find.text('Liburan ke Bali'), findsOneWidget);
      expect(find.text('Ubud, Bali'), findsOneWidget);
      expect(find.text('Hari pertama hujan.'), findsOneWidget);
      expect(find.text('2 foto'), findsOneWidget);
      expect(find.byType(MemoryPhotoTile), findsNWidgets(2));
      expect(picker.prepared, ['galeri/a.jpg', 'galeri/b.jpg']);

      final ops = await h.ops();
      expect(h.opNames(ops), ['PUT memory', 'POST memoryPhoto', 'POST memoryPhoto']);
      expect(payloadOf(ops.first), {
        'space_id': sharedSpaceId,
        'title': 'Liburan ke Bali',
        'place_name': 'Ubud, Bali',
        'visited_on': '2026-10-08',
        'story': 'Hari pertama hujan.',
        'trip_id': null,
      });

      await disposeApp(tester, h);
    });

    testWidgets('linimasa per tahun dan bulan; kartu membuka detail, dan foto membuka galeri', (tester) async {
      final h = Harness();
      await h.seed();
      await h.account.store.write(EntityType.trip, tripJson(), serverUpdatedAt: t0);
      await h.seedMemory();
      await h.account.store.write(
        EntityType.memory,
        memoryJson(
          id: '01m4dr8c50jk2mt7xw3pq9vb6f',
          title: 'Makan malam pertama',
          placeName: null,
          visitedOn: '2026-08-01',
        ),
        serverUpdatedAt: t0,
      );
      final container = await pumpApp(tester, h);

      container.read(routerProvider).go(Routes.memories);
      await settle(tester);
      expect(find.text('2027'), findsOneWidget);
      expect(find.text('2026'), findsOneWidget);
      expect(find.text('Juni'), findsOneWidget);
      expect(find.text('Agustus'), findsOneWidget);
      expect(find.text('Min, 20 Jun 2027 · Ubud, Bali'), findsOneWidget);
      expect(find.text('2 foto'), findsOneWidget);
      expect(find.text('Belum ada foto'), findsOneWidget);

      await tester.tap(find.text('Liburan ke Bali'));
      await settle(tester);
      expect(container.read(routerProvider).state.uri.path, Routes.memory(memoryId));
      expect(find.text('Dari perjalanan Liburan ke Bali'), findsOneWidget);
      expect(find.text('Hari pertama hujan, tapi sawahnya tetap hijau.'), findsOneWidget);

      await reveal(tester, find.byType(MemoryPhotoTile).last);
      await settle(tester);
      await tester.tap(find.byType(MemoryPhotoTile).last);
      await settle(tester);
      expect(container.read(routerProvider).state.uri.path, Routes.memoryPhoto(memoryId, photo2Id));
      expect(find.text('2 dari 2'), findsOneWidget);
      expect(find.text('Diambil Min, 20 Jun 2027, 10.12'), findsOneWidget);

      // Jadikan sampul: foto yang sama tetap tampil, kini sebagai foto pertama.
      await tester.tap(find.byTooltip('Opsi lainnya'));
      await settle(tester);
      await tester.tap(find.text('Jadikan sampul'));
      await settle(tester);
      expect(find.text('1 dari 2'), findsOneWidget);
      expect(find.text('Foto sampul'), findsOneWidget);
      expect(find.text('Foto ini jadi sampul.'), findsOneWidget);

      // Hapus lalu Urungkan.
      await tester.tap(find.byTooltip('Opsi lainnya'));
      await settle(tester);
      expect(find.text('Jadikan sampul'), findsNothing);
      await tester.tap(find.text('Hapus foto'));
      await settle(tester);
      expect(find.text('1 dari 1'), findsOneWidget);
      await tester.tap(find.text('Urungkan'));
      await settle(tester);
      expect(find.text('1 dari 2'), findsOneWidget);
      expect(h.opNames(await h.ops()), ['PATCH memoryPhoto']);

      await tester.tap(find.byTooltip('Kembali'));
      await settle(tester);
      expect(container.read(routerProvider).state.uri.path, Routes.memory(memoryId));

      await disposeApp(tester, h);
    });

    testWidgets('ubah dari menu, lalu hapus: yang berfoto minta konfirmasi, yang tanpa foto bisa diurungkan', (
      tester,
    ) async {
      final h = Harness();
      await h.seed();
      await h.seedMemory(linkedTrip: null);
      const plainId = '01m4dr8c50jk2mt7xw3pq9vb6f';
      await h.account.store.write(
        EntityType.memory,
        memoryJson(id: plainId, title: 'Makan malam pertama', visitedOn: '2026-08-01'),
        serverUpdatedAt: t0,
      );
      final container = await pumpApp(tester, h);

      container.read(routerProvider).go(Routes.memory(memoryId));
      await settle(tester);
      await tester.tap(find.byTooltip('Opsi lainnya'));
      await settle(tester);
      await tester.tap(find.text('Ubah'));
      await settle(tester);
      expect(find.text('Ubah kenangan'), findsOneWidget);
      expect(find.text('Pilih foto'), findsNothing, reason: 'foto dikelola di Detail kenangan');

      await tester.enterText(find.byType(TextField).first, 'Liburan ke Ubud');
      await reveal(tester, find.widgetWithText(FilledButton, 'Simpan'));
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await settle(tester);
      expect(find.text('Liburan ke Ubud'), findsOneWidget);
      final edit = (await h.ops()).single;
      expect(edit.method, 'PATCH');
      expect(payloadOf(edit), {'title': 'Liburan ke Ubud'});

      await tester.tap(find.byTooltip('Opsi lainnya'));
      await settle(tester);
      await tester.tap(find.text('Hapus'));
      await settle(tester);
      expect(find.text('Hapus Liburan ke Ubud?'), findsOneWidget);
      expect(find.text('2 fotonya ikut terhapus dan tidak bisa dikembalikan.'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Hapus'));
      await settle(tester);
      expect(container.read(routerProvider).state.uri.path, Routes.memories);
      expect(find.text('Liburan ke Ubud'), findsNothing);
      expect(h.opNames(await h.ops()), ['PATCH memory', 'DELETE memory']);

      container.read(routerProvider).go(Routes.memory(plainId));
      await settle(tester);
      await tester.tap(find.byTooltip('Opsi lainnya'));
      await settle(tester);
      await tester.tap(find.text('Hapus'));
      await settle(tester);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Kenangan dihapus.'), findsOneWidget);
      expect(find.text('Makan malam pertama'), findsNothing);
      await tester.tap(find.text('Urungkan'));
      await settle(tester);
      expect(find.text('Makan malam pertama'), findsOneWidget);
      expect(h.opNames(await h.ops()), ['PATCH memory', 'DELETE memory']);

      await disposeApp(tester, h);
    });

    testWidgets('tambah foto dari detail: foto yang tidak bisa dibaca diberi tahu', (tester) async {
      final h = Harness();
      await h.seed();
      await h.seedMemory(photos: 0);
      final picker = FakePhotoPicker()
        ..picks.add(['galeri/a.jpg', 'galeri/rusak.jpg'])
        ..unreadable.add('galeri/rusak.jpg');
      final container = await pumpApp(tester, h, photoPicker: picker);

      container.read(routerProvider).go(Routes.memory(memoryId));
      await settle(tester);
      expect(find.text(l10n.memoryPhotosEmpty), findsOneWidget);

      await reveal(tester, find.widgetWithText(TextButton, 'Tambah foto'));
      await tester.tap(find.widgetWithText(TextButton, 'Tambah foto'));
      await settle(tester);

      expect(find.text('1 foto tidak bisa dibaca, jadi tidak ditambahkan.'), findsOneWidget);
      expect(find.byType(MemoryPhotoTile), findsOneWidget);
      expect(find.byType(PendingBadge), findsOneWidget, reason: 'belum terkirim');
      expect(h.opNames(await h.ops()), ['POST memoryPhoto']);

      await disposeApp(tester, h);
    });

    testWidgets('Simpan jadi kenangan dari perjalanan yang sudah selesai', (tester) async {
      final h = Harness();
      await h.seed();
      await h.account.store.write(
        EntityType.trip,
        tripJson(startDate: '2026-08-01', endDate: '2026-08-03'),
        serverUpdatedAt: t0,
      );
      final container = await pumpApp(tester, h);

      await tester.tap(find.text('Liburan'));
      await settle(tester);
      await tester.tap(find.textContaining('Sudah selesai ('));
      await settle(tester);
      await reveal(tester, find.text('Simpan jadi kenangan'));
      await tester.tap(find.text('Simpan jadi kenangan'));
      await settle(tester);

      expect(container.read(routerProvider).state.uri.toString(), Routes.newMemory(tripId: tripId));
      expect(find.widgetWithText(TextField, 'Liburan ke Bali'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Bali'), findsOneWidget);
      expect(find.text('Sab, 1 Agu'), findsOneWidget);
      expect(find.text('Simpan di mana?'), findsNothing, reason: 'ruangnya ruang perjalanan itu');

      await reveal(tester, find.widgetWithText(FilledButton, 'Simpan'));
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await settle(tester);

      final op = (await h.ops()).single;
      expect(payloadOf(op), {
        'space_id': sharedSpaceId,
        'title': 'Liburan ke Bali',
        'place_name': 'Bali',
        'visited_on': '2026-08-01',
        'story': null,
        'trip_id': tripId,
      });
      expect(find.text('Dari perjalanan Liburan ke Bali'), findsOneWidget);

      // Detail perjalanan menampilkan kenangannya.
      container.read(routerProvider).go(Routes.trip(tripId));
      await settle(tester);
      expect(find.text('Sab, 1 Agu · Belum ada foto'), findsOneWidget);

      await disposeApp(tester, h);
    });
  });

  testWidgets('push kenangan baru: channel aktivitas, lalu ketukannya membuka Detail kenangan', (tester) async {
    final h = Harness();
    await h.seed();
    await h.seedMemory();
    final push = FakePushService();
    final container = await pumpApp(tester, h, push: push);

    const created = PushMessage(
      title: 'Liburan ke Bali',
      body: 'Anisa menyimpan kenangan baru',
      data: {'type': 'memory_created', 'space_id': sharedSpaceId, 'memory_id': memoryId},
    );
    push.receive(created);
    await settle(tester);
    expect(push.shown.single.channel, PushChannels.activity);
    expect(push.shown.single.tag, 'memory-$memoryId');

    push.tap(created);
    await settle(tester);
    expect(container.read(routerProvider).state.uri.path, Routes.memory(memoryId));

    push.tap(
      const PushMessage(
        data: {'type': 'memory_created', 'space_id': sharedSpaceId, 'memory_id': '01m4dr8c50jk2mt7xw3pq9vb9z'},
      ),
    );
    await settle(tester);
    expect(container.read(routerProvider).state.uri.path, Routes.memories);
    expect(find.text('Kenangan itu belum tersedia di HP ini.'), findsOneWidget);

    await disposeApp(tester, h);
  });

  test('foto tanpa URL dianggap belum terkirim', () {
    final photo = MemoryPhoto.fromJson({...memoryPhotoJson(), 'url': null, 'thumb_url': null});
    expect(photo.isUploaded, isFalse);
    expect(photo.aspectRatio, closeTo(4 / 3, 0.001));
    expect(photoCacheKey(photoId, thumb: true), 'photo-$photoId-thumb');
    expect(photoCacheKey(photoId, thumb: false), 'photo-$photoId');
  });

  test('ApiError dari FakeApi tetap dikenali', () {
    expect(apiError(409, ApiErrorCode.parentDeleted).code, ApiErrorCode.parentDeleted);
    expect(FakeApi().photoUrl(photoId), contains('X-Amz-Expires=604800'));
  });
}
