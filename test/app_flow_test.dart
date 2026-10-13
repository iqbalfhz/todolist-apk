import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/queue/outbox.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/features/tasks/presentation/add_task_sheet.dart';

import 'helpers/app_harness.dart';
import 'helpers/fixtures.dart';

void main() {
  setUpAll(prepareAppTests);

  Map<String, dynamic> payloadOf(dynamic op) => jsonDecode(op.payload as String) as Map<String, dynamic>;

  group('tambah cepat', () {
    testWidgets('dari Beranda: tugas langsung tampil sebelum server membalas', (tester) async {
      final h = Harness();
      await h.seed();
      await pumpApp(tester, h);

      expect(find.text('Belum ada tugas hari ini. Santai dulu, atau tambah yang baru.'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await settle(tester);
      expect(find.text('Tugas baru'), findsOneWidget);
      expect(find.text('Mau mengerjakan apa?'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Beli galon');
      await tester.tap(find.text('Simpan'));
      await settle(tester);

      // Lembar tertutup dan tugasnya sudah ada di "Tugas hari ini".
      expect(find.text('Tugas baru'), findsNothing);
      expect(find.text('Beli galon'), findsOneWidget);
      expect(find.text('0 dari 1 beres'), findsOneWidget);

      // Server belum dihubungi; operasinya menunggu di antrean.
      expect(h.api.sent('PUT'), isEmpty);
      final op = (await h.ops()).single;
      expect(op.method, 'PUT');
      expect(payloadOf(op), containsPair('title', 'Beli galon'));
      expect(payloadOf(op), containsPair('due_date', '2026-10-08'));
      expect(payloadOf(op), containsPair('task_list_id', listId));
      expect(payloadOf(op), containsPair('assignee_ids', [meId]));
      expect(payloadOf(op), containsPair('priority', 0));

      await disposeApp(tester, h);
    });

    testWidgets('judul wajib diisi; Pasangan dan penting ikut tersimpan', (tester) async {
      final h = Harness();
      await h.seed();
      await pumpApp(tester, h);

      await tester.tap(find.byType(FloatingActionButton));
      await settle(tester);

      await tester.tap(find.text('Simpan'));
      await settle(tester);
      expect(find.text('Tulis dulu apa yang mau dikerjakan.'), findsOneWidget);
      expect(await h.ops(), isEmpty);

      await tester.enterText(find.byType(TextField), 'Bayar listrik');
      await tester.tap(find.text('Pasangan').last);
      await tester.tap(find.text('Tandai penting'));
      await tester.tap(find.text('Simpan'));
      await settle(tester);

      final payload = payloadOf((await h.ops()).single);
      expect(payload, containsPair('assignee_ids', [partnerId]));
      expect(payload, containsPair('priority', 3));

      await disposeApp(tester, h);
    });

    testWidgets('daftar bawaan selalu daftar aktif pertama di Ruang Bersama, bukan yang terakhir dipakai', (
      tester,
    ) async {
      final h = Harness();
      await h.seed();
      final other = listJson(id: otherListId, name: 'Rumah', color: 'biru', position: 2048);
      await h.account.store.write(EntityType.list, other, serverUpdatedAt: t0);
      await pumpApp(tester, h);
      final inSheet = find.byType(AddTaskSheet);

      await tester.tap(find.byType(FloatingActionButton));
      await settle(tester);
      expect(find.descendant(of: inSheet, matching: find.text('Belanja')), findsOneWidget);

      // Kali ini sengaja memilih daftar lain.
      await tester.tap(find.text('Daftar bersama'));
      await settle(tester);
      await tester.tap(find.text('Rumah').last);
      await settle(tester);
      await tester.enterText(find.byType(TextField), 'Ganti lampu');
      await tester.tap(find.text('Simpan'));
      await settle(tester);
      expect(payloadOf((await h.ops()).single), containsPair('task_list_id', otherListId));

      // Kontrak: tambah cepat masuk ke daftar aktif dengan `position` terkecil di ruang yang dipilih.
      await tester.tap(find.byType(FloatingActionButton));
      await settle(tester);
      expect(find.descendant(of: inSheet, matching: find.text('Belanja')), findsOneWidget);
      expect(find.descendant(of: inSheet, matching: find.text('Rumah')), findsNothing);

      await disposeApp(tester, h);
    });

    testWidgets('keyboard terbuka: tombol Simpan tetap terlihat walau isi lembar lebih tinggi dari layar', (
      tester,
    ) async {
      const keyboard = 320.0;
      final h = Harness();
      await h.seed();
      await pumpApp(tester, h);

      tester.view.viewInsets = const FakeViewPadding(bottom: keyboard);
      await tester.tap(find.byType(FloatingActionButton));
      await settle(tester);

      // Dibuka dari Beranda, "Hari ini" sudah terpilih, jadi baris jam ikut tampil
      // dan isi lembar lebih tinggi dari ruang di atas keyboard.
      expect(find.text('Pilih jam'), findsOneWidget);

      final save = tester.getRect(find.widgetWithText(FilledButton, 'Simpan'));
      expect(save.bottom, lessThanOrEqualTo(tester.view.physicalSize.height - keyboard));

      await tester.enterText(find.byType(TextField), 'Siram tanaman');
      await tester.tap(find.text('Simpan'));
      await settle(tester);

      expect(find.text('Tugas baru'), findsNothing);
      expect(payloadOf((await h.ops()).single), containsPair('title', 'Siram tanaman'));

      await disposeApp(tester, h);
    });
  });

  group('Beranda', () {
    testWidgets('tanggal dan sapaan mengikuti zona waktu ruang, sama seperti "Tugas hari ini"', (tester) async {
      final h = Harness();
      await h.seed();
      // 23.30 UTC tanggal 8 sudah 06.30 tanggal 9 di Asia/Jakarta.
      h.clock.now = DateTime.utc(2026, 10, 8, 23, 30);
      await h.account.store.write(EntityType.task, taskJson(dueDate: '2026-10-09'), serverUpdatedAt: t0);
      await pumpApp(tester, h);

      expect(find.text('Jumat, 9 Oktober'), findsOneWidget);
      expect(find.text('Selamat pagi!'), findsOneWidget);
      expect(find.text('0 dari 1 beres'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('tugas terlewat yang penting tetap menampilkan tanda Penting', (tester) async {
      final h = Harness();
      await h.seed();
      await h.account.store.write(EntityType.task, taskJson(dueDate: '2026-10-06', priority: 3), serverUpdatedAt: t0);
      await pumpApp(tester, h);

      // Pemisahnya memakai spasi yang tidak memutus baris.
      final caption = find.textContaining(RegExp(r'Terlewat\s· Sel, 6 Okt\s· Belanja'));
      expect(caption, findsOneWidget);
      expect(find.descendant(of: caption, matching: find.text('Penting')), findsOneWidget);

      await disposeApp(tester, h);
    });
  });

  group('detail tugas', () {
    const secondTaskId = '01m4dh1yn0t6cdn39q4f091896';

    Future<void> openDetail(WidgetTester tester, GoRouter router, String id) async {
      router.go(Routes.task(id));
      await settle(tester);
      expect(find.text('Detail tugas'), findsOneWidget);
    }

    testWidgets('ketikan tersimpan 1 detik setelah berhenti mengetik, tanpa tombol Simpan', (tester) async {
      final h = Harness();
      await h.seed(withTask: true);
      final container = await pumpApp(tester, h);
      await openDetail(tester, container.read(routerProvider), taskId);

      await tester.enterText(find.byType(TextField).first, 'Beli galon dua');
      await tester.pump(const Duration(milliseconds: 900));
      expect(await h.ops(), isEmpty);

      await tester.pump(const Duration(milliseconds: 200));
      await settle(tester);

      // Hanya kolom yang berubah yang dikirim.
      final op = (await h.ops()).single;
      expect(op.method, 'PATCH');
      expect(payloadOf(op), {'title': 'Beli galon dua'});
      expect(find.text('Simpan'), findsNothing);

      await disposeApp(tester, h);
    });

    testWidgets('app masuk ke latar belakang: ketikan langsung ditulis ke antrean', (tester) async {
      final h = Harness();
      await h.seed(withTask: true);
      final container = await pumpApp(tester, h);
      await openDetail(tester, container.read(routerProvider), taskId);

      await tester.enterText(find.byType(TextField).at(1), 'Yang 19 liter');
      // Keadaan pertama yang dilewati saat app meninggalkan layar.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      addTearDown(() => tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed));
      // Jauh sebelum jeda mengetik 1 detik habis.
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(payloadOf((await h.ops()).single), {'notes': 'Yang 19 liter'});

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await settle(tester);
      await disposeApp(tester, h);
    });

    testWidgets('pindah langsung ke tugas lain: isian ikut berganti, ketikan lama tersimpan ke tugas lama', (
      tester,
    ) async {
      final h = Harness();
      await h.seed(withTask: true);
      final second = taskJson(id: secondTaskId, title: 'Bayar listrik', notes: 'Token 100 ribu');
      await h.account.store.write(EntityType.task, second, serverUpdatedAt: t0);
      h.api.rows['tasks']![secondTaskId] = second;
      final container = await pumpApp(tester, h);
      final router = container.read(routerProvider);
      await openDetail(tester, router, taskId);

      await tester.enterText(find.byType(TextField).first, 'Beli galon dua');

      // Seperti ketukan notifikasi untuk tugas lain selagi masih mengetik.
      await openDetail(tester, router, secondTaskId);

      expect(find.widgetWithText(TextField, 'Bayar listrik'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Token 100 ribu'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await settle(tester);

      final op = (await h.ops()).single;
      expect(op.entityId, taskId);
      expect(payloadOf(op), {'title': 'Beli galon dua'});
      expect((await h.local(EntityType.task, secondTaskId))!['title'], 'Bayar listrik');

      await disposeApp(tester, h);
    });
  });

  group('centang dan Urungkan', () {
    testWidgets('Urungkan memulihkan tugas dan tidak ada yang dikirim', (tester) async {
      final semantics = tester.ensureSemantics();
      final h = Harness();
      await h.seed(withTask: true);
      await pumpApp(tester, h);

      await tester.tap(find.text('Tugas'));
      await settle(tester);
      expect(find.text('Beli galon'), findsOneWidget);
      expect(find.text('Bersama · 1'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Tandai selesai: Beli galon'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Tugas selesai.'), findsOneWidget);
      expect(find.text('Urungkan'), findsOneWidget);
      expect(find.text('Selesai (1)'), findsOneWidget);
      expect((await h.local(EntityType.task, taskId))!['completed_at'], isNotNull);
      expect(await h.ops(), hasLength(1));

      await tester.tap(find.text('Urungkan'));
      await settle(tester);

      expect(find.text('Selesai (1)'), findsNothing);
      expect(find.text('Bersama · 1'), findsOneWidget);
      expect((await h.local(EntityType.task, taskId))!['completed_at'], isNull);
      expect(await h.ops(), isEmpty);
      expect(h.api.sent('PATCH'), isEmpty);

      semantics.dispose();
      await disposeApp(tester, h);
    });

    testWidgets('tanpa Urungkan, penyelesaian dikirim setelah 5 detik', (tester) async {
      final semantics = tester.ensureSemantics();
      final h = Harness();
      await h.seed(withTask: true);
      await pumpApp(tester, h);

      await tester.tap(find.text('Tugas'));
      await settle(tester);
      await tester.tap(find.bySemanticsLabel('Tandai selesai: Beli galon'));
      await tester.pump();

      // Selama tombol Urungkan tampil, belum ada yang dikirim.
      expect(await h.account.outbox.flush(), FlushState.waitingUndo);
      expect(h.api.sent('PATCH'), isEmpty);

      // Snackbar muncul, tampil, lalu hilang sendiri sebelum jeda kirim berakhir.
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Urungkan'), findsOneWidget);
      await tester.pump(Outbox.undoWindow - const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.text('Urungkan'), findsNothing);
      h.clock.advance(Outbox.undoWindow);

      expect(await h.account.outbox.flush(), FlushState.idle);
      expect(h.api.sent('PATCH').single.body!.keys, ['completed_at']);
      expect(h.api.row('tasks', taskId)!['completed_at'], isNotNull);

      semantics.dispose();
      await disposeApp(tester, h);
    });
  });

  group('setor tabungan', () {
    testWidgets('nominal diformat otomatis, lalu progres dan riwayat langsung berubah', (tester) async {
      final h = Harness();
      await h.seed(withGoal: true);
      await pumpApp(tester, h);

      // Kartu Tabungan di Beranda menampilkan target utama.
      expect(find.text('Dana Liburan'), findsOneWidget);
      expect(find.text('Rp0 dari Rp10.000.000'), findsOneWidget);

      await tester.tap(find.text('Dana Liburan'));
      await settle(tester);
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('dari Rp10.000.000'), findsOneWidget);

      await tester.tap(find.text('Setor'));
      await settle(tester);
      expect(find.text('Setor tabungan'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '6500000');
      await tester.pump();
      expect(find.text('6.500.000'), findsOneWidget);

      await tester.tap(find.text('Simpan'));
      await settle(tester);

      expect(find.text('Setor tabungan'), findsNothing);
      expect(find.text('65%'), findsOneWidget);
      expect(find.text('Rp6.500.000'), findsOneWidget);
      expect(find.text('Sisa Rp3.500.000'), findsOneWidget);
      expect(find.text('Target 28 Feb 2027'), findsOneWidget);
      expect(find.text('Perlu Rp175.000 per minggu'), findsOneWidget);
      expect(find.text('+Rp6.500.000'), findsOneWidget);

      final op = (await h.ops()).single;
      expect('${op.entityType}:${op.method}', 'entry:PUT');
      expect(payloadOf(op), {'savings_goal_id': goalId, 'amount': 6500000, 'entry_date': '2026-10-08', 'note': null});

      await disposeApp(tester, h);
    });

    testWidgets('nominal wajib diisi', (tester) async {
      final h = Harness();
      await h.seed(withGoal: true);
      await pumpApp(tester, h);

      await tester.tap(find.text('Dana Liburan'));
      await settle(tester);
      await tester.tap(find.text('Setor'));
      await settle(tester);
      await tester.tap(find.text('Simpan'));
      await settle(tester);

      expect(find.text('Isi nominalnya dulu, lebih dari 0.'), findsOneWidget);
      expect(await h.ops(), isEmpty);

      await disposeApp(tester, h);
    });
  });

  group('kode undangan', () {
    testWidgets('kode diseragamkan, lalu Ruang Bersama terbentuk dan Beranda dibuka', (tester) async {
      final h = Harness();
      await h.seedUnpaired();
      h.api.acceptedSpace = sharedSpaceJson(updatedAt: t1);
      final container = await pumpApp(tester, h);

      // Belum berpasangan: filter orang belum tampil di Beranda.
      expect(find.text('Pasangan'), findsNothing);

      unawaited(container.read(routerProvider).push(Routes.pairing));
      await settle(tester);

      expect(find.text('Pakai berdua, lebih ringan'), findsOneWidget);
      expect(find.text('Kode undanganmu'), findsOneWidget);
      // Kode sendiri dari POST /invitations tampil per karakter.
      for (final character in 'K7M2QX'.split('')) {
        expect(find.text(character), findsOneWidget);
      }

      await tester.enterText(find.byType(TextField), 'k7p-2qm');
      await tester.pump();
      expect(find.text('K7P2QM'), findsOneWidget);

      await tester.tap(find.text('Gabung'));
      await settle(tester);

      final accept = h.api.requests.singleWhere((request) => request.path == '/invitations/accept');
      expect(accept.body, {'code': 'K7P2QM'});

      // Setelah gabung: sync dijalankan, lalu Beranda dengan filter orang.
      expect(h.api.log, contains('GET /sync'));
      expect(find.text('Tugas hari ini'), findsOneWidget);
      expect(find.text('Pasangan'), findsOneWidget);
      expect(find.text('Kalian sudah terhubung. Ruang Bersama siap dipakai.'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('kode tidak berlaku: pesan dari server ditampilkan', (tester) async {
      final h = Harness();
      await h.seedUnpaired();
      final container = await pumpApp(tester, h);

      unawaited(container.read(routerProvider).push(Routes.pairing));
      await settle(tester);

      // Tombol Gabung baru aktif setelah kodenya lengkap.
      await tester.enterText(find.byType(TextField), 'K7P');
      await tester.pump();
      await tester.tap(find.text('Gabung'));
      await settle(tester);
      expect(h.api.requests.where((request) => request.path == '/invitations/accept'), isEmpty);

      await tester.enterText(find.byType(TextField), 'K7P2QM');
      await tester.pump();
      await tester.tap(find.text('Gabung'));
      await settle(tester);

      expect(find.text('Kode tidak berlaku, minta kode baru.'), findsOneWidget);
      expect(find.text('Pakai berdua, lebih ringan'), findsOneWidget);

      await disposeApp(tester, h);
    });
  });
}
