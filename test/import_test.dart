import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/core/widgets/widgets.dart';
import 'package:todolist/features/settings/data/data_import.dart';
import 'package:todolist/features/settings/presentation/import_screen.dart';

import 'helpers/app_harness.dart';
import 'helpers/fake_api.dart';
import 'helpers/fake_photos.dart';
import 'helpers/fixtures.dart';

/// Impor data dari file ekspor (v1.x).
void main() {
  setUpAll(prepareAppTests);

  const created = '2026-10-01T00:00:00.000000Z';

  Map<String, dynamic> row(String id, String space, Map<String, dynamic> fields) => {
    'id': id,
    'space_id': space,
    ...fields,
    'created_by': meId,
    'created_at': created,
    'updated_at': '2026-10-02T00:00:00.000000Z',
    'deleted_at': null,
  };

  Map<String, dynamic> photo(String id, num position) => {
    'id': id,
    'memory_id': 'kenangan',
    'space_id': 'ruang-bersama',
    'uploaded_by': partnerId,
    'position': position,
    'taken_at': '2026-06-20T03:00:00.000000Z',
    'width': 2560,
    'height': 1920,
    'url': 'https://r2.contoh/$id.jpg',
    'thumb_url': 'https://r2.contoh/$id-thumb.jpg',
    'created_at': created,
    'updated_at': created,
    'deleted_at': null,
  };

  /// File ekspor dengan Ruang Pribadi, Ruang Bersama dengan Sari, dan ruang tanpa isi.
  Map<String, dynamic> exportFile() => {
    'app': 'Denly Days',
    'format_version': 1,
    'exported_at': '2026-11-03T08:00:00.000000Z',
    'user': userJson(),
    'devices': <dynamic>[],
    'spaces': [
      {
        'id': 'ruang-pribadi',
        'type': 'personal',
        'name': 'Pribadi',
        'members': [
          {'id': meId, 'name': 'Iqbal'},
        ],
      },
      {
        'id': 'ruang-bersama',
        'type': 'shared',
        'name': 'Bersama',
        'members': [
          {'id': meId, 'name': 'Iqbal'},
          {'id': partnerId, 'name': 'Sari'},
        ],
      },
      {'id': 'ruang-kosong', 'type': 'shared', 'name': 'Lama', 'members': <dynamic>[]},
    ],
    'savings_goals': [
      row('target-pribadi', 'ruang-pribadi', {'name': 'Dana Darurat', 'target_amount': 1000000, 'currency': 'IDR'}),
      row('target-bersama', 'ruang-bersama', {'name': 'Dana Liburan', 'target_amount': 5000000, 'currency': 'IDR'}),
    ],
    'trips': [
      row('perjalanan', 'ruang-bersama', {'title': 'Bali', 'savings_goal_id': 'target-bersama'}),
    ],
    'task_lists': [
      row('daftar-pribadi', 'ruang-pribadi', {'name': 'Tugas', 'trip_id': null}),
      row('daftar-bersama', 'ruang-bersama', {'name': 'Belanja', 'trip_id': null}),
      row('checklist', 'ruang-bersama', {'name': 'Persiapan Bali', 'trip_id': 'perjalanan'}),
    ],
    'tasks': [
      row('tugas-pribadi', 'ruang-pribadi', {
        'task_list_id': 'daftar-pribadi',
        'title': 'Bayar listrik',
        'next_task_id': null,
      }),
      row('tugas-selesai', 'ruang-bersama', {
        'task_list_id': 'daftar-bersama',
        'title': 'Beli galon minggu lalu',
        'assignee_ids': [partnerId],
        'completed_at': '2026-10-05T03:00:00.000000Z',
        'completed_by': partnerId,
        'next_task_id': 'tugas-berikutnya',
      }),
      row('tugas-berikutnya', 'ruang-bersama', {
        'task_list_id': 'daftar-bersama',
        'title': 'Beli galon',
        'next_task_id': null,
      }),
      row('item-checklist', 'ruang-bersama', {'task_list_id': 'checklist', 'title': 'Sunblock', 'next_task_id': null}),
    ],
    'savings_entries': [
      row('setoran-pribadi', 'ruang-pribadi', {
        'savings_goal_id': 'target-pribadi',
        'type': 'deposit',
        'amount': 50000,
        'user_id': meId,
      }),
      row('setoran-bersama', 'ruang-bersama', {
        'savings_goal_id': 'target-bersama',
        'type': 'deposit',
        'amount': 200000,
        'user_id': partnerId,
      }),
    ],
    'special_dates': [
      row('hari-jadi', 'ruang-bersama', {'type': 'anniversary', 'title': 'Hari jadi', 'date': '2020-02-14'}),
    ],
    'memories': [
      row('kenangan', 'ruang-bersama', {'title': 'Pantai Kuta', 'visited_on': '2026-06-20', 'trip_id': 'perjalanan'}),
    ],
    'memory_photos': [photo('foto-1', 1024), photo('foto-2', 2048)],
    'comments': [
      {'id': 'komentar', 'subject_type': 'task', 'subject_id': 'tugas-selesai', 'body': 'Sudah, ya!'},
    ],
    'reactions': <dynamic>[],
  };

  String Function() counter() {
    var next = 0;
    return () => 'baru-${++next}';
  }

  ImportPlan plan(Map<String, String> destinations, {Map<String, String> photos = const {}, String id = 'rencana'}) =>
      planImport(
        id: id,
        fileName: 'denly-days-2026-11-03.zip',
        file: exportFile(),
        destinations: destinations,
        newId: counter(),
        photos: photos,
      );

  const both = {'ruang-pribadi': personalSpaceId, 'ruang-bersama': sharedSpaceId};

  group('berkas', () {
    test('hanya file ekspor Denly Days format 1', () {
      expect(parseExportFile(jsonEncode(exportFile()))['app'], 'Denly Days');

      Matcher problem(ImportFileProblem problem) =>
          throwsA(isA<ImportFileInvalid>().having((invalid) => invalid.problem, 'problem', problem));
      expect(() => parseExportFile(null), problem(ImportFileProblem.notExport));
      expect(() => parseExportFile('bukan json'), problem(ImportFileProblem.notExport));
      expect(() => parseExportFile('[1, 2]'), problem(ImportFileProblem.notExport));
      expect(() => parseExportFile('{"app": "Lain", "format_version": 1}'), problem(ImportFileProblem.notExport));
      expect(
        () => parseExportFile('{"app": "Denly Days", "format_version": "1"}'),
        problem(ImportFileProblem.notExport),
      );
      expect(
        () => parseExportFile('{"app": "Denly Days", "format_version": 2}'),
        problem(ImportFileProblem.newerVersion),
      );
    });

    test('ruang di file beserta isinya; ruang tanpa isi tidak ditampilkan', () {
      final spaces = importSpaces(exportFile(), photos: {'foto-1': '/impor/foto-1.jpg'});

      expect([for (final space in spaces) space.id], ['ruang-pribadi', 'ruang-bersama']);
      final (personal, shared) = (spaces[0], spaces[1]);
      expect(personal.isShared, isFalse);
      expect(personal.counts, {
        'savings_goals': 1,
        'trips': 0,
        'task_lists': 1,
        'tasks': 1,
        'savings_entries': 1,
        'special_dates': 0,
        'memories': 0,
      });
      expect(shared.isShared, isTrue);
      expect(shared.otherMembers, ['Sari']);
      expect(shared.rows, 10);
      // Hanya foto yang ada di ZIP.
      expect(shared.photos, 1);
      expect(personal.photos, 0);
    });
  });

  group('rencana', () {
    test('ID baru, rujukan disesuaikan, ruang diganti tujuannya, dan kolom server dibuang', () {
      final result = plan(both, photos: {'foto-1': '/impor/foto-1.jpg'});

      expect(result.parts, hasLength(1));
      final rows = result.parts.single.rows;
      expect(rows.keys, importCollections);

      final ids = <String, String>{};
      for (final MapEntry(:value) in rows.entries) {
        for (final row in value) {
          expect(row['id'], startsWith('baru-'));
          expect(row.containsKey('updated_at'), isFalse);
          expect(row.containsKey('deleted_at'), isFalse);
          expect(row['created_at'], created);
          expect(row['created_by'], meId);
          final label = row['name'] ?? row['title'];
          if (label is String) ids[label] = row['id'] as String;
        }
      }

      Map<String, dynamic> find(String key, String label) =>
          rows[key]!.firstWhere((row) => (row['name'] ?? row['title']) == label);

      expect(find('savings_goals', 'Dana Darurat')['space_id'], personalSpaceId);
      expect(find('trips', 'Bali')['savings_goal_id'], ids['Dana Liburan']);
      expect(find('task_lists', 'Persiapan Bali')['trip_id'], ids['Bali']);
      expect(find('task_lists', 'Belanja')['trip_id'], isNull);
      expect(find('memories', 'Pantai Kuta')['trip_id'], ids['Bali']);

      final done = find('tasks', 'Beli galon minggu lalu');
      expect(done['task_list_id'], ids['Belanja']);
      expect(done['space_id'], sharedSpaceId);
      expect(done['next_task_id'], ids['Beli galon']);
      // Pelaku dan penanggung jawab dari file tetap dikirim; server yang memutuskan.
      expect(done['completed_by'], partnerId);
      expect(done['assignee_ids'], [partnerId]);

      // Tugas berikutnya dikirim sebelum tugas yang menunjuknya.
      final order = [for (final task in rows['tasks']!) task['title']];
      expect(order.indexOf('Beli galon'), lessThan(order.indexOf('Beli galon minggu lalu')));

      expect(
        [for (final entry in rows['savings_entries']!) entry['savings_goal_id']],
        [ids['Dana Darurat'], ids['Dana Liburan']],
      );

      // Foto: hanya yang ada di ZIP, untuk kenangan barunya, dengan posisi dan waktu dari file.
      final photo = result.photos.single;
      expect(photo.memoryId, ids['Pantai Kuta']);
      expect(photo.spaceId, sharedSpaceId);
      expect(photo.position, 1024);
      expect(photo.takenAt, '2026-06-20T03:00:00.000000Z');
      expect((photo.width, photo.height, photo.path), (2560, 1920, '/impor/foto-1.jpg'));
      expect(photo.id, startsWith('baru-'));
    });

    test('ruang yang dilewati tidak ikut, begitu pula foto kenangannya', () {
      final result = plan({'ruang-pribadi': sharedSpaceId}, photos: {'foto-1': '/impor/foto-1.jpg'});

      final rows = result.parts.single.rows;
      expect(rows.keys, ['savings_goals', 'task_lists', 'tasks', 'savings_entries']);
      expect(
        {
          for (final rows in rows.values)
            for (final row in rows) row['space_id'],
        },
        {sharedSpaceId},
      );
      expect(result.photos, isEmpty);
      expect(result.rows, 4);
    });

    test('paling banyak 1.000 baris per bagian, induk lebih dulu; rantai tugas berikutnya tetap utuh', () {
      final file = exportFile()
        ..['tasks'] = [
          for (var i = 0; i < 1500; i++)
            row('tugas-$i', 'ruang-pribadi', {
              'task_list_id': 'daftar-pribadi',
              'title': 'Tugas $i',
              'next_task_id': i < 1499 ? 'tugas-${i + 1}' : null,
            }),
        ];
      final result = planImport(
        id: 'rencana',
        fileName: 'besar.json',
        file: file,
        destinations: {'ruang-pribadi': personalSpaceId},
        newId: counter(),
      );

      expect([for (final part in result.parts) part.size], [1000, 503]);
      expect(result.parts.first.rows.keys, ['savings_goals', 'task_lists', 'tasks']);
      expect(result.parts.last.rows.keys, ['tasks', 'savings_entries']);
      final tasks = [for (final part in result.parts) ...?part.rows['tasks']];
      // Tugas terakhir di rantai dikirim pertama.
      expect(tasks.first['title'], 'Tugas 1499');
      expect(tasks.last['title'], 'Tugas 0');
    });

    test('disimpan dan dibaca lagi apa adanya', () {
      final original = plan(both, photos: {'foto-2': '/impor/foto-2.jpg'})
        ..next = 1
        ..count({
          'created': {'tasks': 3},
          'skipped': {'tasks': 1},
        });
      final copy = ImportPlan.fromJson(jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>);

      expect(copy.toJson(), original.toJson());
      expect(copy.next, 1);
      expect(copy.created['tasks'], 3);
      expect(copy.skipped['tasks'], 1);
      expect(copy.photos.single.position, 2048);
    });
  });

  group('kirim', () {
    test('per bagian lewat POST /me/import, kemajuannya disimpan, lalu sync dan foto ke antrean', () async {
      final h = Harness();
      addTearDown(h.dispose);
      await h.seed();
      final imports = h.account.imports..readPhoto = (path) async => fakeJpeg(1);
      final result = plan(both, photos: {'foto-1': '/impor/foto-1.jpg'});
      await imports.save(result);

      var progress = 0;
      await imports.send(result, onProgress: () => progress++);

      expect(progress, 1);
      final post = h.api.requests.where((request) => request.path == '/me/import').single;
      expect(post.method, 'POST');
      expect(post.body, result.parts.single.toJson());
      expect(result.created['tasks'], 4);
      expect((await imports.pending())!.next, 1);

      final queued = await imports.finish(result);
      expect(queued, 1);
      expect(h.api.requests.any((request) => request.path == '/sync'), isTrue);
      expect(await imports.pending(), isNull);

      final photoId = result.photos.single.id;
      expect(h.photoFiles.files[photoId], fakeJpeg(1));
      final op = (await h.ops()).singleWhere((op) => op.entityType == EntityType.memoryPhoto.name);
      expect(op.entityId, photoId);
      expect(jsonDecode(op.payload!), {
        'memory_id': result.photos.single.memoryId,
        'position': 1024,
        'taken_at': '2026-06-20T03:00:00.000000Z',
      });

      // Impor yang terputus di sini dan diselesaikan lagi tidak memasukkan fotonya dua kali.
      expect(await imports.finish(result), 1);
      expect((await h.ops()).where((op) => op.entityType == EntityType.memoryPhoto.name), hasLength(1));
    });

    test('terputus di tengah: dilanjutkan dengan ID yang sama, dan yang sudah masuk dilewati server', () async {
      final h = Harness();
      addTearDown(h.dispose);
      await h.seed();
      final imports = h.account.imports;
      final file = exportFile()
        ..['tasks'] = [
          for (var i = 0; i < 1200; i++)
            row('tugas-$i', 'ruang-pribadi', {'task_list_id': 'daftar-pribadi', 'title': 'Tugas $i'}),
        ];
      final result = planImport(
        id: 'rencana',
        fileName: 'besar.json',
        file: file,
        destinations: {'ruang-pribadi': personalSpaceId},
        newId: counter(),
      );
      await imports.save(result);
      expect(result.parts, hasLength(2));

      // Bagian kedua sampai di server, tapi balasannya hilang.
      var calls = 0;
      h.api
        ..enqueue(h.api.handle)
        ..enqueue((request) {
          calls++;
          h.api.handle(request);
          throw const NetworkFailure();
        });
      await expectLater(imports.send(result), throwsA(isA<NetworkFailure>()));
      expect(calls, 1);

      final resumed = (await imports.pending())!;
      expect(resumed.next, 1);
      await imports.send(resumed);

      expect(resumed.partsDone, isTrue);
      expect(h.api.imported['tasks'], hasLength(1200));
      expect(resumed.created['tasks'], 998);
      expect(resumed.skipped['tasks'], 202);
      expect(resumed.created['savings_entries'], 0);
      expect(resumed.skipped['savings_entries'], 1);
    });
  });

  group('layar Impor data', () {
    PickedImportFile picked({bool zip = false, Map<String, dynamic>? file, Map<String, String> photos = const {}}) =>
        PickedImportFile(
          name: zip ? 'denly-days-2026-11-03.zip' : 'denly-days-2026-11-03.json',
          isZip: zip,
          json: jsonEncode(file ?? exportFile()),
          photos: photos,
        );

    Future<void> openFromSettings(WidgetTester tester) async {
      await tester.scrollUntilVisible(
        find.widgetWithText(OutlinedButton, 'Keluar'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Salin isi file ekspor ke ruangmu'));
      await settle(tester);
    }

    Future<void> tapButton(WidgetTester tester, String label) async {
      final button = find.widgetWithText(FilledButton, label);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await settle(tester);
    }

    Future<void> confirm(WidgetTester tester) async {
      await tester.tap(find.widgetWithText(TextButton, 'Impor'));
      await settle(tester);
    }

    testWidgets('dari Pengaturan: pilih file, atur tujuan setiap ruang, lalu impor', (tester) async {
      final h = Harness();
      await h.seed();
      final files = FakeImportFiles([picked()]);
      final container = await pumpApp(tester, h, importFiles: files);
      container.read(routerProvider).go(Routes.settings);
      await settle(tester);
      await openFromSettings(tester);

      expect(find.byType(ImportScreen), findsOneWidget);
      expect(find.text('Mengimpor file yang sama dua kali membuat salinannya dua kali.'), findsOneWidget);
      expect(find.text('Foto hanya ikut dari file ZIP.'), findsOneWidget);

      await tapButton(tester, 'Pilih file');

      expect(find.text('denly-days-2026-11-03.json'), findsOneWidget);
      expect(find.text('File JSON, tanpa foto'), findsOneWidget);
      expect(find.text('Ruang Pribadi'), findsWidgets);
      expect(find.text('Ruang Bersama dengan Sari'), findsOneWidget);
      expect(find.text('1 tugas · 1 daftar · 1 target · 1 setoran'), findsOneWidget);
      expect(
        find.text('3 tugas · 2 daftar · 1 target · 1 setoran · 1 perjalanan · 1 tanggal penting · 1 kenangan'),
        findsOneWidget,
      );
      expect(find.text('Isi yang diimpor ke Ruang Bersama juga terlihat oleh Sari.'), findsOneWidget);
      expect(find.text('Foto tidak ikut, karena file ini JSON. Pilih file ZIP supaya fotonya ikut.'), findsOneWidget);

      // Ruang Bersama di file dilewati.
      final sharedCard = find.ancestor(of: find.text('Ruang Bersama dengan Sari'), matching: find.byType(AppCard));
      await tester.ensureVisible(sharedCard);
      await tester.tap(find.descendant(of: sharedCard, matching: find.text('Lewati')));
      await settle(tester);
      expect(find.text('Isi yang diimpor ke Ruang Bersama juga terlihat oleh Sari.'), findsNothing);

      await tapButton(tester, 'Mulai impor');
      expect(find.text('Impor sekarang?'), findsOneWidget);
      expect(
        find.text('4 data disalin sebagai data baru. Kalau file yang sama diimpor lagi, isinya menjadi salinan kedua.'),
        findsOneWidget,
      );
      await confirm(tester);

      final body = h.api.requests.singleWhere((request) => request.path == '/me/import').body!;
      expect(body.keys, ['savings_goals', 'task_lists', 'tasks', 'savings_entries']);
      final rows = [for (final rows in body.values) ...rows as List<dynamic>];
      expect({for (final row in rows) (row as Map<String, dynamic>)['space_id']}, {personalSpaceId});
      expect(find.text('Impor selesai'), findsOneWidget);
      expect(find.text('Dibuat: 1 tugas, 1 daftar, 1 target, 1 setoran.'), findsOneWidget);
      expect(await h.account.imports.pending(), isNull);
      expect(files.discarded, contains(files.tokens.single));

      await tapButton(tester, 'Selesai');
      expect(find.byType(ImportScreen), findsNothing);

      await disposeApp(tester, h);
    });

    testWidgets('ZIP: foto kenangan yang ikut masuk antrean unggah', (tester) async {
      final h = Harness();
      await h.seed();
      h.account.imports.readPhoto = (path) async => fakeJpeg(path.length);
      final files = FakeImportFiles([
        picked(zip: true, photos: {'foto-1': '/impor/foto-1.jpg', 'foto-2': '/impor/foto-2.jpg'}),
      ]);
      final container = await pumpApp(tester, h, importFiles: files);
      container.read(routerProvider).go(Routes.importData);
      await settle(tester);

      await tapButton(tester, 'Pilih file');
      expect(find.text('ZIP berisi 2 foto'), findsOneWidget);
      expect(find.textContaining('· 1 kenangan · 2 foto'), findsOneWidget);
      expect(find.text('Foto tidak ikut, karena file ini JSON. Pilih file ZIP supaya fotonya ikut.'), findsNothing);

      await tapButton(tester, 'Mulai impor');
      await confirm(tester);

      expect(find.text('Impor selesai'), findsOneWidget);
      expect(find.text('2 foto sedang diunggah lewat antrean.'), findsOneWidget);
      final uploads = (await h.ops()).where((op) => op.entityType == EntityType.memoryPhoto.name).toList();
      expect(uploads, hasLength(2));
      expect(h.photoFiles.files.keys, [for (final op in uploads) op.entityId]);

      await disposeApp(tester, h);
    });

    testWidgets('berkas yang bukan ekspor, dari versi lebih baru, tidak terbaca, atau tanpa isi', (tester) async {
      final h = Harness();
      await h.seed();
      final files = FakeImportFiles([
        const PickedImportFile(name: 'catatan.txt', isZip: false, json: 'halo'),
        const PickedImportFile(name: 'baru.json', isZip: false, json: '{"app": "Denly Days", "format_version": 3}'),
        PlatformException(code: 'read_failed'),
        PickedImportFile(
          name: 'kosong.json',
          isZip: false,
          json: jsonEncode({
            ...exportFile(),
            'tasks': <dynamic>[],
            'task_lists': <dynamic>[],
            'savings_goals': <dynamic>[],
            'savings_entries': <dynamic>[],
            'trips': <dynamic>[],
            'special_dates': <dynamic>[],
            'memories': <dynamic>[],
          }),
        ),
        null,
      ]);
      final container = await pumpApp(tester, h, importFiles: files);
      container.read(routerProvider).go(Routes.importData);
      await settle(tester);

      await tapButton(tester, 'Pilih file');
      expect(
        find.text('File ini bukan file ekspor Denly Days. Pilih file JSON atau ZIP dari Ekspor data.'),
        findsOneWidget,
      );
      await tapButton(tester, 'Pilih file');
      expect(
        find.text('File ini dibuat versi Denly Days yang lebih baru. Perbarui app dulu, lalu coba lagi.'),
        findsOneWidget,
      );
      await tapButton(tester, 'Pilih file');
      expect(find.text('File tidak bisa dibaca. Coba pilih lagi.'), findsOneWidget);
      await tapButton(tester, 'Pilih file');
      expect(find.text('File ini tidak berisi data yang bisa diimpor.'), findsOneWidget);

      // Pemilih berkas ditutup: tidak terjadi apa-apa.
      await tapButton(tester, 'Pilih file');
      expect(find.text('Pilih file'), findsOneWidget);
      expect(files.discarded, files.tokens.take(4));
      expect(h.api.requests.where((request) => request.path == '/me/import'), isEmpty);

      await disposeApp(tester, h);
    });

    testWidgets('ditolak server (422, 429): bisa dilanjutkan; impor tertunda tampil lagi, lalu dibatalkan', (
      tester,
    ) async {
      final h = Harness();
      await h.seed();
      final files = FakeImportFiles([picked(), picked()]);
      final container = await pumpApp(tester, h, importFiles: files);
      container.read(routerProvider).go(Routes.importData);
      await settle(tester);

      await tapButton(tester, 'Pilih file');
      h.api.failNext(
        const ApiError(
          status: 422,
          code: ApiErrorCode.validationFailed,
          message: 'Judul wajib diisi.',
          errors: {
            'tasks.2.title': ['Judul wajib diisi.'],
          },
        ),
      );
      await tapButton(tester, 'Mulai impor');
      await confirm(tester);
      expect(find.text('Server menolak isi file: Judul wajib diisi.'), findsOneWidget);
      expect(find.text('Impor belum selesai'), findsOneWidget);
      expect(find.text('denly-days-2026-11-03.json: 0 dari 1 bagian sudah terkirim.'), findsOneWidget);

      h.api.failNext(
        apiError(
          429,
          ApiErrorCode.tooManyRequests,
          message: 'Terlalu sering.',
          retryAfter: const Duration(minutes: 41),
        ),
      );
      await tapButton(tester, 'Lanjutkan impor');
      expect(find.text('Impor dibatasi 30 bagian per jam. Lanjutkan sekitar 41 menit lagi.'), findsOneWidget);

      // Dibuka lagi nanti: rencananya masih tersimpan di HP.
      container.read(routerProvider).go(Routes.settings);
      await settle(tester);
      container.read(routerProvider).go(Routes.importData);
      await settle(tester);
      expect(find.text('Impor belum selesai'), findsOneWidget);
      final token = files.tokens.single;

      await tester.tap(find.widgetWithText(TextButton, 'Batalkan impor'));
      await settle(tester);
      expect(find.text('Batalkan impor?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Batalkan impor').last);
      await settle(tester);

      expect(await h.account.imports.pending(), isNull);
      expect(files.discarded, contains(token));
      expect(find.text('Pilih file'), findsOneWidget);

      // Impor baru dari awal, dan kali ini berhasil.
      await tapButton(tester, 'Pilih file');
      await tapButton(tester, 'Mulai impor');
      await confirm(tester);
      expect(find.text('Impor selesai'), findsOneWidget);
      expect(h.api.imported['tasks'], hasLength(4));

      await disposeApp(tester, h);
    });
  });
}
