import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/utils/file_sizes.dart';
import 'package:todolist/features/settings/data/data_export.dart';
import 'package:todolist/features/settings/presentation/export_screen.dart';

import 'helpers/app_harness.dart';
import 'helpers/fake_api.dart';
import 'helpers/fixtures.dart';

/// Ekspor data (v1.0) dan ZIP berisi foto (v1.x).
void main() {
  setUpAll(prepareAppTests);

  Map<String, dynamic> exportFile() => {
    'app': 'Denly Days',
    'format_version': 1,
    'exported_at': t0,
    'user': {...userJson(), 'avatar_url': 'https://r2.contoh/avatar.jpg?sig=1'},
    'devices': [
      {'platform': 'android', 'created_at': t0, 'updated_at': t0},
    ],
    'memory_photos': [
      {...memoryPhotoJson(), 'url': 'https://r2.contoh/$photoId.jpg?sig=1'},
      {...memoryPhotoJson(id: photo2Id), 'url': 'https://r2.contoh/$photo2Id.jpg?sig=1'},
      // Bukan ULID: tidak pernah dijadikan nama berkas.
      {'id': '../rahasia', 'url': 'https://r2.contoh/x.jpg'},
    ],
  };

  group('berkas', () {
    test('nama berkas dari Content-Disposition; nama yang tidak aman diganti tanggal hari ini', () {
      final now = DateTime(2026, 10, 31, 9);
      expect(exportFileName('attachment; filename="denly-days-2026-10-31.json"', now), 'denly-days-2026-10-31.json');
      expect(exportFileName('attachment; filename=denly-days-2026-10-30.json', now), 'denly-days-2026-10-30.json');
      for (final header in [
        null,
        'attachment',
        'attachment; filename="../akun.json"',
        'attachment; filename="a/b.json"',
      ]) {
        expect(exportFileName(header, now), 'denly-days-2026-10-31.json', reason: '$header');
      }
    });

    test('foto: profil dulu, lalu foto kenangan yang ID-nya ULID, dinamai menurut ID-nya', () {
      expect(
        [for (final photo in exportPhotos(exportFile())) (photo.fileName, photo.isAvatar)],
        [('foto-profil.jpg', true), ('$photoId.jpg', false), ('$photo2Id.jpg', false)],
      );
      expect(exportPhotos({'memory_photos': <dynamic>[]}), isEmpty);
    });

    test('GET /me/export: isi balasan disimpan apa adanya, dengan nama dari header', () async {
      final h = Harness();
      addTearDown(h.dispose);
      h.api
        ..exportFile = exportFile()
        ..exportRaw = '{\n  "app": "Denly Days"\n}';

      final export = await h.account.exports.fetch();

      expect('${h.api.requests.single.method} ${h.api.requests.single.path}', 'GET /me/export');
      expect(export.fileName, 'denly-days-2026-10-08.json');
      expect(export.folder, 'denly-days-2026-10-08');
      expect(utf8.decode(export.bytes), '{\n  "app": "Denly Days"\n}');
      expect(export.photos, hasLength(3));
    });
  });

  group('layar Ekspor data', () {
    testWidgets('dari Pengaturan: berkas tersimpan di folder unduhan, lalu fotonya ke folder yang sama', (
      tester,
    ) async {
      final h = Harness();
      await h.seed();
      h.api.exportFile = exportFile();
      final files = FakeExportFiles()..failOnce.add('$photo2Id.jpg');
      final container = await pumpApp(tester, h, exportFiles: files);

      container.read(routerProvider).go(Routes.settings);
      await settle(tester);
      // Gulir sampai tombol Keluar di paling bawah, supaya barisnya tidak tertutup tab bawah.
      await tester.scrollUntilVisible(
        find.widgetWithText(OutlinedButton, 'Keluar'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Simpan salinan semua datamu ke HP'));
      await settle(tester);
      expect(find.byType(ExportScreen), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Ekspor JSON'));
      await settle(tester);

      expect(files.saved.keys, ['denly-days-2026-10-08/denly-days-2026-10-08.json']);
      expect(jsonDecode(utf8.decode(files.saved.values.single)), exportFile());
      expect(find.text('File tersimpan'), findsOneWidget);
      expect(find.text('Di folder Download/Denly Days/denly-days-2026-10-08'), findsOneWidget);

      await tester.ensureVisible(find.text('Unduh semua foto juga (3 foto)'));
      await tester.tap(find.text('Unduh semua foto juga (3 foto)'));
      await settle(tester);
      expect(find.text('2 dari 3 foto tersimpan. 1 gagal diunduh.'), findsOneWidget);
      expect(
        files.saved.keys,
        containsAll(['denly-days-2026-10-08/foto-profil.jpg', 'denly-days-2026-10-08/$photoId.jpg']),
      );

      await tester.tap(find.text('Coba lagi'));
      await settle(tester);
      expect(find.text('3 foto tersimpan di folder yang sama.'), findsOneWidget);
      expect(files.saved.keys, contains('denly-days-2026-10-08/$photo2Id.jpg'));
      expect(files.saved.keys.where((key) => key.contains('rahasia')), isEmpty);

      await disposeApp(tester, h);
    });

    testWidgets('dibatasi 5 kali per jam, tanpa koneksi, atau penyimpanan penuh: pesannya tampil', (tester) async {
      final h = Harness();
      await h.seed();
      final files = FakeExportFiles();
      final container = await pumpApp(tester, h, exportFiles: files);
      container.read(routerProvider).go(Routes.exportData);
      await settle(tester);

      Future<void> export() async {
        await tester.tap(find.widgetWithText(OutlinedButton, 'Ekspor JSON'));
        await settle(tester);
      }

      h.api.failNext(
        apiError(
          429,
          ApiErrorCode.tooManyRequests,
          message: 'Terlalu sering. Coba lagi sebentar lagi.',
          retryAfter: const Duration(minutes: 37, seconds: 10),
        ),
      );
      await export();
      expect(find.text('Ekspor dibatasi 5 kali per jam. Coba lagi sekitar 38 menit lagi.'), findsOneWidget);

      h.api.failNext(const NetworkFailure());
      await export();
      expect(find.text('Butuh koneksi internet. Coba lagi saat online.'), findsOneWidget);

      files.full = true;
      await export();
      expect(
        find.text('File tidak bisa disimpan di HP. Pastikan penyimpanan masih cukup, lalu coba lagi.'),
        findsOneWidget,
      );
      expect(files.saved, isEmpty);
      expect(find.text('File tersimpan'), findsNothing);

      await disposeApp(tester, h);
    });
  });

  group('ZIP berisi foto', () {
    test('ukuran berkas: dibulatkan ke atas', () {
      expect(formatFileSize(300), '1 KB');
      expect(formatFileSize(850 * 1024), '850 KB');
      expect(formatFileSize(120 * 1024 * 1024 + 1), '121 MB');
      expect(formatFileSize(1024 * 1024 * 1024), '1 GB');
      expect(formatFileSize(1288490188), '1,2 GB');
    });

    test(
      'data.json dikompres, foto apa adanya di foto-kenangan/ dan foto-profil.jpg; yang gagal dicoba lagi',
      () async {
        final files = FakeExportFiles()..failOnce.add('$photoId.jpg');
        final export = DataExport(
          fileName: 'denly-days-2026-11-03.json',
          bytes: Uint8List.fromList(utf8.encode('{"app":"Denly Days"}')),
          photos: exportPhotos(exportFile()),
        );
        expect(export.zipName, 'denly-days-2026-11-03.zip');
        expect(export.zipSizeEstimate, 20 + 3 * 1024 * 1024);

        final job = ExportZipJob(
          export: export,
          session: await files.start(export.zipName),
          fetcher: files,
          retryDelays: const [Duration.zero, Duration.zero],
        );
        await job.addData();
        final progress = <int>[];
        expect(await job.addPhotos(onProgress: progress.add), isEmpty);
        await job.finish();

        expect(progress, [1, 2, 3]);
        final zip = files.zips['denly-days-2026-11-03.zip']!;
        expect(zip.keys, ['data.json', 'foto-profil.jpg', 'foto-kenangan/$photoId.jpg', 'foto-kenangan/$photo2Id.jpg']);
        expect([for (final entry in zip.values) entry.compress], [true, false, false, false]);
        expect(utf8.decode(zip['data.json']!.bytes), '{"app":"Denly Days"}');
      },
    );

    test(
      'foto yang tetap gagal setelah dicoba ulang: ZIP tidak disimpan, dan hanya foto itu yang dicoba lagi',
      () async {
        final files = FakeExportFiles()..failAlways.add('$photo2Id.jpg');
        final export = DataExport(
          fileName: 'denly-days-2026-11-03.json',
          bytes: Uint8List.fromList(utf8.encode('{}')),
          photos: exportPhotos(exportFile()),
        );
        final job = ExportZipJob(
          export: export,
          session: await files.start(export.zipName),
          fetcher: files,
          retryDelays: const [Duration.zero, Duration.zero],
        );
        await job.addData();

        final failed = await job.addPhotos();
        expect([for (final photo in failed) photo.fileName], ['$photo2Id.jpg']);
        expect(files.zips, isEmpty);

        files.failAlways.clear();
        final progress = <int>[];
        expect(await job.addPhotos(onProgress: progress.add), isEmpty);
        expect(progress, [1]);
        await job.finish();
        expect(files.zips['denly-days-2026-11-03.zip']!.keys, contains('foto-kenangan/$photo2Id.jpg'));
      },
    );

    testWidgets('ZIP tersimpan di Download/Denly Days, lalu dibagikan; jumlah fotonya disebut sebelum mulai', (
      tester,
    ) async {
      final h = Harness();
      await h.seed();
      // Dua foto kenangan yang sudah terunggah dan satu yang belum, ditambah foto profil.
      final withAvatar = {...userJson(), 'avatar_url': 'https://r2.contoh/avatar.jpg'};
      await h.account.store.write(EntityType.me, withAvatar);
      h.api.me = withAvatar;
      await h.account.store.write(EntityType.memory, memoryJson(), serverUpdatedAt: t0);
      for (final (id, url) in [(photoId, 'https://r2.contoh/1.jpg'), (photo2Id, 'https://r2.contoh/2.jpg')]) {
        await h.account.store.write(EntityType.memoryPhoto, {
          ...memoryPhotoJson(id: id),
          'url': url,
          'thumb_url': url,
        }, serverUpdatedAt: t0);
      }
      await h.account.store.write(EntityType.memoryPhoto, {
        ...memoryPhotoJson(id: '01m4drb7k0qz3n8st5vw2hx4cz'),
        'url': null,
        'thumb_url': null,
      }, serverUpdatedAt: t0);
      h.api.exportFile = exportFile();
      final files = FakeExportFiles()..freeBytes = 4 * 1024 * 1024 * 1024;
      final container = await pumpApp(tester, h, exportFiles: files);
      container.read(routerProvider).go(Routes.exportData);
      await settle(tester);

      expect(find.text('3 foto, kira-kira 3 MB.'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Ekspor ZIP'));
      await settle(tester);

      expect(files.zips.keys, ['denly-days-2026-10-08.zip']);
      expect(files.zips.values.single.keys, [
        'data.json',
        'foto-profil.jpg',
        'foto-kenangan/$photoId.jpg',
        'foto-kenangan/$photo2Id.jpg',
      ]);
      expect(jsonDecode(utf8.decode(files.zips.values.single['data.json']!.bytes)), exportFile());
      expect(find.text('ZIP tersimpan'), findsOneWidget);
      expect(find.text('denly-days-2026-10-08.zip'), findsOneWidget);
      expect(find.text('Di folder Download/Denly Days'), findsOneWidget);
      expect(files.saved, isEmpty);

      await tester.ensureVisible(find.text('Bagikan file'));
      await tester.tap(find.text('Bagikan file'));
      await settle(tester);
      expect(files.shared.single.uri, 'content://media/external/downloads/7');

      await disposeApp(tester, h);
    });

    testWidgets('foto yang tetap gagal: coba lagi, atau ekspor tanpa foto (berkas JSON dari ekspor yang sama)', (
      tester,
    ) async {
      final h = Harness();
      await h.seed();
      h.api.exportFile = exportFile();
      final files = FakeExportFiles()..failAlways.add('$photo2Id.jpg');
      final container = await pumpApp(tester, h, exportFiles: files);
      container.read(routerProvider).go(Routes.exportData);
      await settle(tester);

      Future<void> exportZip() async {
        await tester.tap(find.widgetWithText(FilledButton, 'Ekspor ZIP'));
        await settle(tester);
        // Dua kali dicoba ulang, dengan jeda 2 dan 4 detik.
        await tester.pump(const Duration(seconds: 7));
        await settle(tester);
      }

      await exportZip();
      expect(find.text('1 dari 3 foto gagal diunduh, jadi ZIP belum disimpan.'), findsOneWidget);
      expect(files.zips, isEmpty);

      // Masih gagal: tetap ditawarkan.
      await tester.tap(find.text('Coba lagi'));
      await settle(tester);
      await tester.pump(const Duration(seconds: 7));
      await settle(tester);
      expect(find.text('1 dari 1 foto gagal diunduh, jadi ZIP belum disimpan.'), findsOneWidget);

      await tester.tap(find.text('Ekspor tanpa foto'));
      await settle(tester);
      expect(files.cancelledZips, ['denly-days-2026-10-08.zip']);
      expect(files.saved.keys, ['denly-days-2026-10-08/denly-days-2026-10-08.json']);
      expect(find.text('File tersimpan'), findsOneWidget);
      expect(h.api.requests.where((request) => request.path == '/me/export'), hasLength(1));

      // ZIP baru, dan kali ini fotonya berhasil setelah dicoba lagi.
      await exportZip();
      files.failAlways.clear();
      await tester.tap(find.text('Coba lagi'));
      await settle(tester);
      expect(find.text('ZIP tersimpan'), findsOneWidget);
      expect(files.zips.values.single.keys, hasLength(4));

      await disposeApp(tester, h);
    });

    testWidgets('ruang kosong di HP kurang: ZIP tidak dimulai; layar ditutup di tengah jalan: ZIP dibuang', (
      tester,
    ) async {
      final h = Harness();
      await h.seed();
      h.api.exportFile = exportFile();
      final files = FakeExportFiles()
        ..freeBytes = 20 * 1024 * 1024
        ..failAlways.add('$photo2Id.jpg');
      final container = await pumpApp(tester, h, exportFiles: files);
      container.read(routerProvider).go(Routes.exportData);
      await settle(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Ekspor ZIP'));
      await settle(tester);
      expect(
        find.text(
          'Ruang kosong di HP tinggal 20 MB, padahal ZIP-nya kira-kira 4 MB. Kosongkan sebagian penyimpanan, '
          'atau ekspor file JSON saja.',
        ),
        findsOneWidget,
      );
      expect(files.zips, isEmpty);
      expect(files.cancelledZips, isEmpty);

      files.freeBytes = null;
      await tester.tap(find.widgetWithText(FilledButton, 'Ekspor ZIP'));
      await settle(tester);
      await tester.pump(const Duration(seconds: 7));
      await settle(tester);
      expect(find.text('Ekspor tanpa foto'), findsOneWidget);

      container.read(routerProvider).go(Routes.settings);
      await settle(tester);
      expect(files.cancelledZips, ['denly-days-2026-10-08.zip']);
      expect(files.zips, isEmpty);

      await disposeApp(tester, h);
    });
  });

  group('saran ekspor dulu', () {
    testWidgets('konfirmasi keluar dari Ruang Bersama dan hapus akun: "Ekspor data dulu" membuka Ekspor data', (
      tester,
    ) async {
      final h = Harness();
      await h.seed();
      final container = await pumpApp(tester, h);

      Future<void> exportFirst() async {
        expect(find.textContaining('Kalau perlu, simpan salinannya dulu lewat Ekspor data.'), findsOneWidget);
        await tester.tap(find.text('Ekspor data dulu').last);
        await settle(tester);
        expect(find.byType(ExportScreen), findsOneWidget);
      }

      container.read(routerProvider).go(Routes.pairing);
      await settle(tester);
      await tester.ensureVisible(find.text('Keluar dari Ruang Bersama'));
      await tester.tap(find.text('Keluar dari Ruang Bersama'));
      await settle(tester);
      await exportFirst();
      expect(h.api.requests.where((request) => request.method == 'DELETE'), isEmpty);

      container.read(routerProvider).go(Routes.deleteAccount);
      await settle(tester);
      await tester.enterText(find.byType(TextField), 'rahasia-banget');
      await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Hapus akun'));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Hapus akun'));
      await settle(tester);
      await exportFirst();
      expect(h.api.requests.where((request) => request.method == 'DELETE'), isEmpty);

      await disposeApp(tester, h);
    });
  });
}
