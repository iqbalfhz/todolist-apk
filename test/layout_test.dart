import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/platform/device_platform.dart';
import 'package:todolist/core/providers.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/core/widgets/widgets.dart';
import 'package:todolist/features/auth/data/google_accounts.dart';
import 'package:todolist/features/auth/presentation/google_sign_in_button.dart';
import 'package:todolist/features/memories/presentation/location_picker_screen.dart';
import 'package:todolist/features/memories/presentation/memory_form_screen.dart';
import 'package:todolist/features/savings/domain/savings_views.dart';
import 'package:todolist/features/savings/presentation/entry_detail_sheet.dart';
import 'package:todolist/features/savings/presentation/goal_detail_screen.dart';
import 'package:todolist/features/spaces/domain/household.dart';
import 'package:todolist/features/savings/presentation/goal_form_sheet.dart';
import 'package:todolist/features/savings/presentation/reminder_sheet.dart';
import 'package:todolist/features/savings/presentation/savings_screen.dart';
import 'package:todolist/features/search/domain/search.dart';
import 'package:todolist/features/settings/data/data_import.dart';
import 'package:todolist/features/special_dates/presentation/special_date_sheet.dart';
import 'package:todolist/features/special_dates/presentation/special_dates_screen.dart';
import 'package:todolist/features/tasks/presentation/list_form_sheet.dart';
import 'package:todolist/features/tasks/domain/task.dart';
import 'package:todolist/features/tasks/presentation/manage_lists_screen.dart';
import 'package:todolist/features/tasks/presentation/repeat_sheet.dart';
import 'package:todolist/features/tasks/presentation/task_detail_screen.dart';
import 'package:todolist/features/trips/presentation/checklist_screen.dart';
import 'package:todolist/features/trips/presentation/trip_detail_screen.dart';
import 'package:todolist/features/trips/presentation/trip_form_sheet.dart';
import 'package:todolist/features/trips/presentation/trips_screen.dart';

import 'helpers/app_harness.dart';
import 'helpers/fake_api.dart';
import 'helpers/fake_google.dart';
import 'helpers/fake_photos.dart';
import 'helpers/fake_push.dart';
import 'helpers/fixtures.dart';
import 'helpers/rich_fixtures.dart';

/// Tata letak tetap rapi saat huruf sistem diperbesar dan di layar kecil.
///
/// Setiap layar dirender dengan data yang ramai. Isi yang meluap dilaporkan Flutter
/// sebagai error, jadi tesnya gagal sendiri tanpa perlu membandingkan gambar.
void main() {
  setUpAll(prepareAppTests);

  /// Ukuran mockup, dan HP kecil yang masih umum dipakai.
  const mockup = Size(390, 844);
  const small = Size(360, 640);
  const keyboard = 280.0;

  Future<void> apply(WidgetTester tester, {required Size size, required double textScale}) async {
    tester.view.physicalSize = size;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await settle(tester);
  }

  Future<void> go(WidgetTester tester, ProviderContainer container, String path) async {
    container.read(routerProvider).go(path);
    await settle(tester);
  }

  /// Gulir sampai bawah, supaya bagian yang belum terlihat ikut ditata.
  Future<void> scrollThrough(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isEmpty) return;
      await tester.drag(scrollable.first, const Offset(0, -400), warnIfMissed: false);
      await settle(tester);
    }
  }

  /// Gulir sampai [finder] tampil, karena isi halaman hanya dibangun saat dekat layar: ke paling
  /// atas dulu, lalu turun sedikit demi sedikit.
  Future<void> reveal(WidgetTester tester, Finder finder) async {
    final scrollable = find.byType(Scrollable).first;
    if (finder.evaluate().isEmpty) {
      await tester.drag(scrollable, const Offset(0, 5000), warnIfMissed: false);
      await settle(tester);
    }
    if (finder.evaluate().isEmpty) await tester.scrollUntilVisible(finder, 200, scrollable: scrollable);
    await tester.ensureVisible(finder);
    await settle(tester);
  }

  Future<void> visit(WidgetTester tester, ProviderContainer container, String path) async {
    await go(tester, container, path);
    await scrollThrough(tester);
  }

  /// Lembar bawah diperiksa dengan keyboard terbuka, keadaan tersempitnya.
  Future<void> withSheet(WidgetTester tester, ProviderContainer container, Future<void> Function() open) async {
    await open();
    tester.view.viewInsets = const FakeViewPadding(bottom: keyboard);
    await settle(tester);
    expect(find.byType(AppSheet), findsOneWidget, reason: 'lembar bawahnya tidak terbuka');
    await scrollThrough(tester);

    container.read(routerProvider).routerDelegate.navigatorKey.currentState!.pop();
    tester.view.resetViewInsets();
    await settle(tester);
  }

  for (final (label, size, textScale) in [
    ('ukuran mockup', mockup, 1.0),
    ('huruf 1,3x', mockup, 1.3),
    ('huruf 2x', mockup, 2.0),
    ('layar kecil', small, 1.0),
    ('layar kecil, huruf 1,3x', small, 1.3),
  ]) {
    testWidgets('$label: semua layar setelah masuk', (tester) async {
      final h = Harness();
      await h.seedRich();
      // "Setahun lalu, hari ini" (v1.x) di Beranda, dengan sampul dan judul panjang.
      await h.account.store.write(
        EntityType.memory,
        memoryJson(
          id: '01m4dr8c50jk2mt7xw3pq9vb9z',
          title: 'Ulang tahun pertama bersama di rumah makan tepi danau yang ramai sekali',
          placeName: 'Danau Toba, Sumatera Utara, Indonesia',
          visitedOn: '2025-10-08',
        ),
        serverUpdatedAt: t0,
      );
      await h.account.store.write(
        EntityType.memoryPhoto,
        memoryPhotoJson(id: '01m4drb7k0qz3n8st5vw2hx5zz', memory: '01m4dr8c50jk2mt7xw3pq9vb9z'),
        serverUpdatedAt: t0,
      );
      // Komentar dan reaksi (v1.x): komentar panjang, yang diedit, dan beberapa reaksi.
      final longComment = List.filled(
        6,
        'Sudah aku cek, tagihannya naik sedikit karena paket kuotanya berubah bulan ini.',
      ).join(' ');
      for (final (subjectType, subjectId, ids) in [
        (
          'task',
          importantTaskId,
          [
            '01m4dt2k70f3qzr8vw5hx9cy7a',
            '01m4dt2k70f3qzr8vw5hx9cy7b',
            '01m4dt3f80g7mnp2xs6ty8vk7a',
            '01m4dt3f80g7mnp2xs6ty8vk7b',
          ],
        ),
        (
          'memory',
          longMemoryId,
          [
            '01m4dt2k70f3qzr8vw5hx9cy8a',
            '01m4dt2k70f3qzr8vw5hx9cy8b',
            '01m4dt3f80g7mnp2xs6ty8vk8a',
            '01m4dt3f80g7mnp2xs6ty8vk8b',
          ],
        ),
      ]) {
        await h.account.store.write(
          EntityType.comment,
          commentJson(id: ids[0], subjectType: subjectType, subjectId: subjectId, body: longComment),
          serverUpdatedAt: t0,
        );
        await h.account.store.write(
          EntityType.comment,
          commentJson(
            id: ids[1],
            subjectType: subjectType,
            subjectId: subjectId,
            userId: meId,
            body: 'Oke, nanti aku yang bayar.',
            createdAt: t1,
            updatedAt: t2,
          ),
          serverUpdatedAt: t0,
        );
        await h.account.store.write(
          EntityType.reaction,
          reactionJson(id: ids[2], subjectType: subjectType, subjectId: subjectId, emoji: '😂'),
          serverUpdatedAt: t0,
        );
        await h.account.store.write(
          EntityType.reaction,
          reactionJson(id: ids[3], subjectType: subjectType, subjectId: subjectId, userId: meId, emoji: '❤️'),
          serverUpdatedAt: t0,
        );
      }
      final picker = FakePhotoPicker();
      final exportFiles = FakeExportFiles();
      final importFiles = FakeImportFiles();
      final container = await pumpApp(
        tester,
        h,
        photoPicker: picker,
        exportFiles: exportFiles,
        importFiles: importFiles,
      );
      await apply(tester, size: size, textScale: textScale);

      await visit(tester, container, Routes.home);
      await withSheet(tester, container, () => tester.tap(find.byType(FloatingActionButton)));

      // Cari (v1.x): hasil dari semua jenis, termasuk potongan cerita dan catatan.
      container.read(searchTextProvider.notifier).set('an');
      await visit(tester, container, Routes.search);
      container.read(searchTextProvider.notifier).set('hujan');
      await visit(tester, container, Routes.search);

      await visit(tester, container, Routes.tasks);
      await tester.tap(find.textContaining('Selesai ('));
      await settle(tester);
      await scrollThrough(tester);

      await visit(tester, container, Routes.task(importantTaskId));
      // Lembar Ulangi tugas (v1.0) dengan selang besar dan keterangan bulan yang lebih pendek.
      await withSheet(tester, container, () async {
        showRepeatSheet(
          tester.element(find.byType(TaskDetailScreen)),
          current: const TaskRepeat(RepeatFrequency.monthly, 12),
          dueDate: '2026-10-31',
        ).ignore();
      });
      // Mingguan di beberapa hari (v1.x): tujuh pilihan hari dan ringkasan yang panjang.
      await withSheet(tester, container, () async {
        showRepeatSheet(
          tester.element(find.byType(TaskDetailScreen)),
          current: const TaskRepeat(RepeatFrequency.weekly, 12, [1, 2, 3, 4, 5, 6]),
          dueDate: '2026-10-31',
        ).ignore();
      });
      // Komentar dengan pilihan reaksi terbuka.
      await visit(tester, container, Routes.task(importantTaskId, comments: true));
      await tester.ensureVisible(find.byTooltip('Beri reaksi'));
      await settle(tester);
      await tester.tap(find.byTooltip('Beri reaksi'));
      await settle(tester);
      await scrollThrough(tester);
      await visit(tester, container, Routes.task(longTaskId));
      await visit(tester, container, Routes.task(doneRepeatTaskId));

      await visit(tester, container, Routes.manageLists);
      await withSheet(tester, container, () async {
        final list = container.read(taskListsProvider).value!.firstWhere((list) => list.id == shoppingListId);
        showListFormSheet(tester.element(find.byType(ManageListsScreen)), list: list).ignore();
      });

      // Target dolar (v1.x): perkiraan dalam rupiah di kartu, Detail, dan saat setor, dengan
      // nominal yang panjang.
      const usdGoalId = '01m4dfr0yg0n6e2k5f3m8t1q2j';
      await h.account.store.write(
        EntityType.goal,
        goalJson(id: usdGoalId, name: 'Tiket pesawat ke Jepang', currency: 'USD', targetAmount: 1234567890),
        serverUpdatedAt: t0,
      );
      await h.account.store.write(
        EntityType.entry,
        entryJson(id: '01m4dfr2e3b7w9x1y5z8a0c4d6', savingsGoalId: usdGoalId, amount: 987654321),
        serverUpdatedAt: t0,
      );
      await h.account.exchangeRates.refresh();
      await go(tester, container, Routes.goal(usdGoalId));
      expect(find.textContaining('kurs ECB'), findsWidgets);
      await scrollThrough(tester);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 4000), warnIfMissed: false);
      await settle(tester);
      await withSheet(tester, container, () async {
        await reveal(tester, find.text('Setor'));
        await tester.tap(find.text('Setor'));
        await settle(tester);
        await tester.enterText(find.byType(TextField).first, '9876543,21');
        await settle(tester);
        expect(find.textContaining(RegExp(r'^≈ Rp[\d.]+ · kurs ECB')), findsOneWidget);
      });

      await visit(tester, container, Routes.savings);
      await tester.tap(find.textContaining('Diarsipkan ('));
      await settle(tester);
      await scrollThrough(tester);
      await withSheet(tester, container, () async {
        showGoalFormSheet(tester.element(find.byType(SavingsScreen))).ignore();
      });

      // Penarikan (v1.x) dengan catatan panjang di riwayat.
      await h.account.store.write(EntityType.entry, {
        ...entryJson(
          id: '01m4dk06v0p3ew0dm0dk94s3zz',
          savingsGoalId: tripGoalId,
          amount: 350000,
          note: 'Uang muka penginapan di Ubud untuk tiga malam pertama',
        ),
        'type': 'withdrawal',
      }, serverUpdatedAt: t0);
      await visit(tester, container, Routes.goal(tripGoalId));
      // Kembali ke atas: tombol Setor harus benar-benar tampil sebelum diketuk.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 4000), warnIfMissed: false);
      await settle(tester);
      await tester.ensureVisible(find.text('Setor'));
      await settle(tester);
      await withSheet(tester, container, () => tester.tap(find.text('Setor')));
      await withSheet(tester, container, () => tester.tap(find.text('Ambil')));
      // Jadwal bulanan tanggal 31 menampilkan keterangan bulan yang lebih pendek.
      await withSheet(tester, container, () async {
        final goal = container.read(goalProgressProvider)!.firstWhere((item) => item.goal.id == tripGoalId).goal;
        showSavingsReminderSheet(
          tester.element(find.byType(GoalDetailScreen)),
          goal: goal,
          today: '2026-10-08',
        ).ignore();
      });
      // Detail setoran di target bersama (v1.x), dengan komentar.
      await withSheet(tester, container, () async {
        final progress = container.read(goalProgressProvider)!.firstWhere((item) => item.goal.id == tripGoalId);
        showEntryDetailSheet(
          tester.element(find.byType(GoalDetailScreen)),
          goalId: tripGoalId,
          entryId: progress.entries.first.id,
          household: container.read(householdProvider)!,
        ).ignore();
      });
      await visit(tester, container, Routes.goal(achievedGoalId));

      // Ajakan verifikasi email (v1.0) dengan email panjang, lalu lembarnya dengan kode yang salah.
      final unverified = {...userJson(emailVerifiedAt: null), 'email': 'nama.yang.cukup.panjang.untuk.diuji@gmail.com'};
      h.api.me = unverified;
      await h.account.store.write(EntityType.me, unverified);
      // Ajakannya di paling atas, jadi lembarnya dibuka sebelum Pengaturan digulir.
      await go(tester, container, Routes.settings);
      await withSheet(tester, container, () async {
        await tester.tap(find.widgetWithText(TextButton, 'Verifikasi'));
        await settle(tester);
        await tester.tap(find.widgetWithText(FilledButton, 'Kirim kode'));
        await settle(tester);
        await tester.enterText(find.byType(TextField), '111111');
        await tester.tap(find.widgetWithText(FilledButton, 'Verifikasi'));
        await settle(tester);
        expect(find.text('Kode salah atau sudah tidak berlaku. Minta kode baru kalau perlu.'), findsOneWidget);
      });
      await scrollThrough(tester);
      await visit(tester, container, Routes.profile);
      await visit(tester, container, Routes.pairing);
      // Konfirmasi keluar dari Ruang Bersama (v1.0), dengan penjelasan akibatnya yang panjang.
      await tester.ensureVisible(find.text('Keluar dari Ruang Bersama'));
      await tester.tap(find.text('Keluar dari Ruang Bersama'));
      await settle(tester);
      expect(find.text('Keluar dari Ruang Bersama?'), findsOneWidget);
      await scrollThrough(tester);
      await tester.tap(find.text('Batal'));
      await settle(tester);

      // Hapus akun (v1.0): akibatnya, isian kata sandi dengan pesan error, dan konfirmasinya.
      await visit(tester, container, Routes.deleteAccount);
      await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Hapus akun'));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Hapus akun'));
      await settle(tester);
      expect(find.text('Kata sandi belum diisi.'), findsOneWidget);
      await scrollThrough(tester);
      await tester.enterText(find.byType(TextField), 'rahasia-banget');
      await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Hapus akun'));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Hapus akun'));
      await settle(tester);
      expect(find.text('Hapus akun sekarang?'), findsOneWidget);
      await tester.tap(find.text('Batal'));
      await settle(tester);

      // Ganti kata sandi (v1.x): kedua isian dengan pesan error.
      await visit(tester, container, Routes.changePassword);
      await reveal(tester, find.widgetWithText(FilledButton, 'Simpan kata sandi baru'));
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan kata sandi baru'));
      await settle(tester);
      expect(find.text('Kata sandi belum diisi.'), findsNWidgets(2));
      await scrollThrough(tester);

      // Ganti email (v1.x): email baru yang panjang, lalu isian kode dengan pesan error.
      await visit(tester, container, Routes.changeEmail);
      await reveal(tester, find.byType(TextField).at(0));
      await tester.enterText(find.byType(TextField).at(0), 'alamat.email.yang.cukup.panjang.untuk.diuji@email.com');
      await reveal(tester, find.byType(TextField).at(1));
      await tester.enterText(find.byType(TextField).at(1), 'sandi-lama-123');
      await reveal(tester, find.widgetWithText(FilledButton, 'Kirim kode'));
      await tester.tap(find.widgetWithText(FilledButton, 'Kirim kode'));
      await settle(tester);
      expect(find.textContaining('Kode sudah dikirim ke alamat.email'), findsOneWidget);
      await reveal(tester, find.widgetWithText(FilledButton, 'Ganti email'));
      await tester.tap(find.widgetWithText(FilledButton, 'Ganti email'));
      await settle(tester);
      expect(find.text('Kodenya 6 angka, sesuai email yang kami kirim.'), findsOneWidget);
      await scrollThrough(tester);

      // Akun dari Google tanpa kata sandi: Buat kata sandi, dan ganti email lewat Google.
      final me = (await h.account.profile.current())!;
      await h.account.store.write(EntityType.me, me.copyWith(hasPassword: false).toJson());
      await visit(tester, container, Routes.changePassword);
      expect(find.text('Buat kata sandi'), findsOneWidget);
      await visit(tester, container, Routes.changeEmail);
      expect(find.byType(GoogleSignInButton), findsOneWidget);
      await h.account.store.write(EntityType.me, me.toJson());

      // Impor data (v1.x): nama berkas dan nama anggota yang panjang, pilihan tujuan, lalu hasilnya.
      Map<String, dynamic> fileRow(String id, String space, Map<String, dynamic> fields) => {
        'id': id,
        'space_id': space,
        ...fields,
        'created_by': meId,
        'created_at': t0,
        'updated_at': t0,
        'deleted_at': null,
      };
      importFiles.results.add(
        PickedImportFile(
          name: 'denly-days-2026-11-03-salinan-dari-hp-lama-yang-namanya-cukup-panjang.json',
          isZip: false,
          json: jsonEncode({
            'app': 'Denly Days',
            'format_version': 1,
            'user': userJson(),
            'spaces': [
              {
                'id': 'ruang-pribadi',
                'type': 'personal',
                'members': [
                  {'id': meId, 'name': 'Iqbal'},
                ],
              },
              {
                'id': 'ruang-bersama',
                'type': 'shared',
                'members': [
                  {'id': meId, 'name': 'Iqbal'},
                  {'id': partnerId, 'name': 'Sari Kusumawardhani Putri Ramadhani'},
                ],
              },
            ],
            'savings_goals': [
              fileRow('target', 'ruang-bersama', {'name': 'Dana Liburan', 'target_amount': 1000000, 'currency': 'IDR'}),
            ],
            'task_lists': [
              fileRow('daftar', 'ruang-pribadi', {'name': 'Tugas'}),
              fileRow('daftar-2', 'ruang-bersama', {'name': 'Belanja'}),
            ],
            'tasks': [
              for (var i = 0; i < 12; i++)
                fileRow('tugas-$i', 'ruang-bersama', {'task_list_id': 'daftar-2', 'title': 'Tugas $i'}),
              fileRow('tugas-pribadi', 'ruang-pribadi', {'task_list_id': 'daftar', 'title': 'Tugas pribadi'}),
            ],
            'savings_entries': [
              for (var i = 0; i < 40; i++)
                fileRow('setoran-$i', 'ruang-bersama', {
                  'savings_goal_id': 'target',
                  'type': 'deposit',
                  'amount': 1000,
                }),
            ],
            'special_dates': [
              fileRow('hari-jadi', 'ruang-bersama', {'type': 'anniversary', 'title': 'Jadian', 'date': '2020-02-14'}),
            ],
            'trips': [
              fileRow('perjalanan', 'ruang-bersama', {'title': 'Bali'}),
            ],
            'memories': [
              fileRow('kenangan', 'ruang-bersama', {'title': 'Kuta', 'visited_on': '2026-06-20'}),
            ],
            'memory_photos': [
              {'id': 'foto', 'memory_id': 'kenangan', 'space_id': 'ruang-bersama', 'deleted_at': null},
            ],
          }),
        ),
      );
      await visit(tester, container, Routes.importData);
      await reveal(tester, find.widgetWithText(FilledButton, 'Pilih file'));
      await tester.tap(find.widgetWithText(FilledButton, 'Pilih file'));
      await settle(tester);
      expect(find.text('Ruang Bersama dengan Sari Kusumawardhani Putri Ramadhani'), findsOneWidget);
      await scrollThrough(tester);
      await reveal(tester, find.widgetWithText(FilledButton, 'Mulai impor'));
      await tester.tap(find.widgetWithText(FilledButton, 'Mulai impor'));
      await settle(tester);
      expect(find.text('Impor sekarang?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Impor'));
      await settle(tester);
      expect(find.text('Impor selesai'), findsOneWidget);
      await scrollThrough(tester);

      // Ekspor data (v1.0): berkas tersimpan, lalu fotonya.
      h.api.exportFile = {
        'memory_photos': [
          for (final id in [photoId, photo2Id]) {'id': id, 'url': 'https://r2.contoh/foto.jpg'},
        ],
      };
      await visit(tester, container, Routes.exportData);
      // ZIP berisi foto (v1.x): satu foto tetap gagal, lalu tawaran coba lagi atau tanpa foto.
      exportFiles.failAlways.add('$photo2Id.jpg');
      await reveal(tester, find.widgetWithText(FilledButton, 'Ekspor ZIP'));
      await tester.tap(find.widgetWithText(FilledButton, 'Ekspor ZIP'));
      await settle(tester);
      await tester.pump(const Duration(seconds: 7));
      await settle(tester);
      expect(find.text('1 dari 2 foto gagal diunduh, jadi ZIP belum disimpan.'), findsOneWidget);
      await scrollThrough(tester);
      exportFiles.failAlways.clear();
      await reveal(tester, find.text('Coba lagi'));
      await tester.tap(find.text('Coba lagi'));
      await settle(tester);
      expect(find.text('ZIP tersimpan'), findsOneWidget);
      await scrollThrough(tester);
      await reveal(tester, find.widgetWithText(OutlinedButton, 'Ekspor JSON'));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Ekspor JSON'));
      await settle(tester);
      expect(find.text('File tersimpan'), findsOneWidget);
      await scrollThrough(tester);
      await tester.ensureVisible(find.text('Unduh semua foto juga (2 foto)'));
      await tester.tap(find.text('Unduh semua foto juga (2 foto)'));
      await settle(tester);
      expect(find.text('2 foto tersimpan di folder yang sama.'), findsOneWidget);
      await scrollThrough(tester);

      await visit(tester, container, Routes.specialDates);
      await withSheet(tester, container, () async {
        final date = container.read(specialDatesProvider).value!.firstWhere((date) => date.id == longDateId);
        showSpecialDateSheet(tester.element(find.byType(SpecialDatesScreen)), date: date).ignore();
      });
      await withSheet(tester, container, () async {
        await tester.tap(find.widgetWithText(FilledButton, 'Tambah tanggal'));
        await settle(tester);
        // Pilihan Pribadi menambah keterangan di bawahnya.
        await tester.tap(find.text('Pribadi'));
      });

      await visit(tester, container, Routes.trips);
      await tester.ensureVisible(find.textContaining('Sudah selesai ('));
      await settle(tester);
      await tester.tap(find.textContaining('Sudah selesai ('));
      await settle(tester);
      await scrollThrough(tester);
      await withSheet(tester, container, () async {
        showTripFormSheet(tester.element(find.byType(TripsScreen))).ignore();
        await settle(tester);
        // Pilihan Pribadi menambah keterangan di bawahnya.
        final private = find.descendant(of: find.byType(AppSheet), matching: find.text('Pribadi'));
        await tester.ensureVisible(private);
        await settle(tester);
        await tester.tap(private);
      });

      await visit(tester, container, Routes.trip(longTripId));
      await withSheet(tester, container, () async {
        final trip = container.read(tripsProvider).value!.firstWhere((trip) => trip.id == longTripId);
        showTripFormSheet(tester.element(find.byType(TripDetailScreen)), trip: trip).ignore();
      });
      await withSheet(tester, container, () async {
        final goals = container.read(goalProgressProvider)!;
        showGoalPicker(tester.element(find.byType(TripDetailScreen)), goals: goals, selectedId: tripGoalId).ignore();
      });
      await visit(tester, container, Routes.tripChecklist(longTripId));
      await tester.tap(find.textContaining('Selesai ('));
      await settle(tester);
      await scrollThrough(tester);
      // Isian tambah item tetap muat saat keyboard terbuka.
      tester.view.viewInsets = const FakeViewPadding(bottom: keyboard);
      await settle(tester);
      expect(find.byType(ChecklistScreen), findsOneWidget);
      tester.view.resetViewInsets();
      await settle(tester);

      await visit(tester, container, Routes.trip(ongoingTripId));
      await visit(tester, container, Routes.trip(undatedTripId));
      await visit(tester, container, Routes.tripChecklist(undatedTripId));
      await visit(tester, container, Routes.trip(doneTripId));

      // Kenangan (v0.3).
      await visit(tester, container, Routes.memories);
      await visit(tester, container, Routes.memory(longMemoryId, comments: true));
      await visit(tester, container, Routes.memory(privateMemoryId));
      await visit(tester, container, Routes.memoryPhoto(longMemoryId, longMemoryCoverId));
      await visit(tester, container, Routes.editMemory(longMemoryId));
      await visit(tester, container, Routes.newMemory(tripId: doneTripId));
      await go(tester, container, Routes.newMemory());
      // Foto yang dipilih tampil sebagai kisi; formulirnya tetap muat saat keyboard terbuka.
      picker.picks.add([for (var i = 0; i < 5; i++) 'galeri/foto_$i.jpg']);
      await tester.scrollUntilVisible(find.text('Pilih foto'), 200, scrollable: find.byType(Scrollable).first);
      await settle(tester);
      await tester.tap(find.text('Pilih foto'));
      await settle(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: keyboard);
      await settle(tester);
      await scrollThrough(tester);
      expect(find.byType(MemoryFormScreen), findsOneWidget);
      tester.view.resetViewInsets();
      await settle(tester);

      // Pin lokasi dan Peta kenangan (v1.x).
      // Langsung di cache: lewat antrean, API palsu yang tidak mengenal kenangan ini akan membalas 404.
      for (final (id, latitude, longitude) in [(longMemoryId, -7.689, 108.651), (privateMemoryId, -6.2088, 106.8456)]) {
        final row = (await h.local(EntityType.memory, id))!;
        await h.account.store.write(EntityType.memory, {
          ...row,
          'latitude': latitude,
          'longitude': longitude,
        }, serverUpdatedAt: t0);
      }
      await visit(tester, container, Routes.memory(longMemoryId));
      await visit(tester, container, Routes.memoriesMap());
      await visit(tester, container, Routes.memoriesMap(focusId: longMemoryId));
      expect(find.text('Buka kenangan'), findsOneWidget);
      await visit(tester, container, Routes.editMemory(longMemoryId));
      // Pilih lokasi dengan hasil pencarian yang namanya panjang, dan dengan keyboard terbuka.
      h.api.places = [
        for (var i = 0; i < 8; i++)
          {
            'name': 'Pantai Batu Hiu dan sekitarnya nomor $i',
            'address': 'Jalan Raya Pangandaran, Kabupaten Pangandaran, Jawa Barat, Indonesia',
            'latitude': -7.68 - i / 100,
            'longitude': 108.65,
          },
      ];
      // Formulirnya sudah digulir sampai bawah; isian pin ada di atas. Menarik layar bisa
      // mengenai kolom cerita yang punya gulir sendiri, jadi gulir langsung ke tombolnya.
      await tester.ensureVisible(find.text('Ubah pin', skipOffstage: false));
      await settle(tester);
      await tester.tap(find.text('Ubah pin'));
      await settle(tester);
      expect(find.byType(LocationPickerScreen), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'pantai');
      await tester.tap(find.byTooltip('Cari tempat'));
      await settle(tester);
      await scrollThrough(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: keyboard);
      await settle(tester);
      tester.view.resetViewInsets();
      await settle(tester);
      Navigator.of(tester.element(find.byType(LocationPickerScreen))).pop();
      await settle(tester);

      await disposeApp(tester, h);
    });
  }

  for (final (label, size, textScale) in [('huruf 2x', mockup, 2.0), ('layar kecil, huruf 1,3x', small, 1.3)]) {
    testWidgets('$label: Masuk dan Daftar dengan pesan error', (tester) async {
      final h = Harness();
      await pumpApp(tester, h, signedIn: false);
      await apply(tester, size: size, textScale: textScale);

      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Masuk'));
      await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
      await settle(tester);
      await scrollThrough(tester);

      await tester.ensureVisible(find.widgetWithText(TextButton, 'Daftar'));
      await tester.tap(find.widgetWithText(TextButton, 'Daftar'));
      await settle(tester);
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Daftar'));
      await tester.tap(find.widgetWithText(FilledButton, 'Daftar'));
      await settle(tester);
      await scrollThrough(tester);

      expect(find.text('Nama panggilan belum diisi.'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('$label: Lupa kata sandi dengan kode dan pesan error', (tester) async {
      final h = Harness();
      await pumpApp(tester, h, signedIn: false);
      await apply(tester, size: size, textScale: textScale);

      await tester.ensureVisible(find.text('Lupa kata sandi?'));
      await tester.tap(find.text('Lupa kata sandi?'));
      await settle(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Kirim kode'));
      await settle(tester);
      await scrollThrough(tester);
      expect(find.text('Tulis email yang benar, misalnya nama@email.com.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'nama.yang.cukup.panjang.untuk.diuji@gmail.com');
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Kirim kode'));
      await tester.tap(find.widgetWithText(FilledButton, 'Kirim kode'));
      await settle(tester);

      // Kode dan kata sandi yang belum benar, lalu kirim ulang yang dibatasi; semuanya juga
      // diperiksa dengan keyboard terbuka.
      await tester.enterText(find.byType(TextField).at(1), '1234');
      await reveal(tester, find.widgetWithText(FilledButton, 'Simpan kata sandi baru'));
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan kata sandi baru'));
      await settle(tester);
      await reveal(tester, find.text('Kodenya 6 angka, sesuai email yang kami kirim.'));
      tester.view.viewInsets = const FakeViewPadding(bottom: keyboard);
      addTearDown(tester.view.resetViewInsets);
      await settle(tester);
      await scrollThrough(tester);
      h.api.failNext(
        const ApiError(
          status: 429,
          code: ApiErrorCode.tooManyRequests,
          message: 'Terlalu sering. Coba lagi sebentar lagi.',
          retryAfter: Duration(minutes: 15),
        ),
      );
      await reveal(tester, find.widgetWithText(TextButton, 'Kirim ulang kode'));
      await tester.tap(find.widgetWithText(TextButton, 'Kirim ulang kode'));
      await settle(tester);
      await reveal(tester, find.textContaining('Kode sudah beberapa kali diminta'));
      await scrollThrough(tester);

      await disposeApp(tester, h);
    });

    testWidgets('$label: masuk dengan Google, dengan akun yang disebut lalu pesan error', (tester) async {
      final h = Harness();
      final reply = Completer<ApiResponse>();
      h.api.enqueue((_) => reply.future);
      const identity = GoogleIdentity(idToken: 'token', email: 'nama.yang.cukup.panjang.untuk.diuji@gmail.com');
      await pumpApp(tester, h, signedIn: false, google: FakeGoogleAccounts([identity]));
      await apply(tester, size: size, textScale: textScale);

      await tester.ensureVisible(find.byType(GoogleSignInButton));
      await tester.tap(find.byType(GoogleSignInButton));
      await tester.pump();
      await tester.pump();
      expect(find.textContaining('Memakai akun Google'), findsOneWidget);
      await scrollThrough(tester);

      reply.completeError(
        apiError(422, ApiErrorCode.googleTokenInvalid, message: 'Email akun Google ini belum terverifikasi.'),
      );
      await settle(tester);
      await scrollThrough(tester);
      expect(find.text('Email akun Google ini belum terverifikasi.'), findsOneWidget);

      await tester.ensureVisible(find.widgetWithText(TextButton, 'Daftar'));
      await tester.tap(find.widgetWithText(TextButton, 'Daftar'));
      await settle(tester);
      await scrollThrough(tester);
      expect(find.widgetWithText(GoogleSignInButton, 'Daftar dengan Google'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('$label: Izin notifikasi yang ditolak, lalu Ajak pasangan', (tester) async {
      const xiaomi = DeviceInfo(manufacturer: 'Xiaomi', brand: 'Redmi', model: 'Redmi Note 13', sdkInt: 34);
      final h = Harness();
      await h.seedUnpaired();
      await pumpApp(
        tester,
        h,
        push: FakePushService(grantOnRequest: false),
        device: xiaomi,
        notificationsDone: false,
        pairingDone: false,
      );
      await apply(tester, size: size, textScale: textScale);

      // Izin ditolak: kartu petunjuk ke pengaturan notifikasi tampil.
      await tester.tap(find.text('Izinkan notifikasi'));
      await settle(tester);
      await scrollThrough(tester);

      await tester.ensureVisible(find.text('Lewati'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lewati'));
      await settle(tester);

      expect(find.text('Kode undanganmu'), findsOneWidget);
      await scrollThrough(tester);

      await disposeApp(tester, h);
    });
  }
}
