import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/features/memories/presentation/memory_detail_screen.dart';
import 'package:todolist/features/search/domain/search.dart';
import 'package:todolist/features/tasks/presentation/task_detail_screen.dart';

import 'helpers/app_harness.dart';
import 'helpers/fixtures.dart';
import 'helpers/rich_fixtures.dart';

typedef _Note = ({String title, String? notes});

List<(String, int, String?)> _search(List<_Note> items, String input) => [
  for (final hit in searchItems(
    items,
    SearchQuery.parse(input),
    title: (item) => item.title,
    others: (item) => [item.notes],
  ))
    (hit.title, hit.rank, hit.snippet),
];

void main() {
  setUpAll(prepareAppTests);

  group('pencocokan', () {
    test('huruf besar-kecil dan aksen diabaikan, panjang teks tidak berubah', () {
      expect(foldForSearch('Café ÜBUD'), 'cafe ubud');
      for (final text in ['Café 😀 İstanbul', 'Ñandú', '𐐀 Deseret']) {
        expect(foldForSearch(text).length, text.length);
      }
    });

    test('kata kunci dirapikan; kurang dari dua huruf belum mencari', () {
      final query = SearchQuery.parse('  Beli   GALON ');
      expect(query.text, 'Beli GALON');
      expect(query.tokens, ['galon', 'beli']);
      expect(SearchQuery.parse('a').isSearchable, isFalse);
      expect(SearchQuery.parse('ab').isSearchable, isTrue);
    });

    test('semua kata harus ada; judul yang diawali kata kunci paling atas, lalu urutan semula', () {
      final items = <_Note>[
        (title: 'Bayar listrik', notes: null),
        (title: 'Bayar internet', notes: 'Tagihan Oktober lewat m-banking.'),
        (title: 'Internet rumah', notes: 'Cek kabel'),
        (title: 'Belanja', notes: 'Kabel internet dan kuota'),
      ];

      expect(_search(items, 'internet'), [
        ('Internet rumah', 0, null),
        ('Bayar internet', 1, null),
        ('Belanja', 2, 'Kabel internet dan kuota'),
      ]);
      expect(_search(items, 'bayar m-banking'), [('Bayar internet', 2, 'Tagihan Oktober lewat m-banking.')]);
      expect(_search(items, 'bayar kuota'), isEmpty, reason: 'kata harus ada di data yang sama');
      expect(_search(items, 'x'), isEmpty);
    });

    test('potongan dipotong di batas kata dan diberi elipsis', () {
      final story = List.filled(8, 'Hari pertama hujan tapi sawahnya tetap hijau.').join(' ');
      final at = story.indexOf('sawahnya', 120);
      final snippet = snippetAround('${story.substring(0, at)}\nSAWAHNYA${story.substring(at + 8)}', at, 8);

      expect(snippet, startsWith('…'));
      expect(snippet, endsWith('…'));
      expect(snippet, contains('SAWAHNYA'));
      expect(snippet, isNot(contains('\n')));
      expect(snippetAround('Pendek saja', 0, 6), 'Pendek saja');
    });

    test('rentang sorotan urut dan tidak bertumpuk', () {
      expect(matchRanges('Beli Galon galon', ['galon', 'li']), [(2, 4), (5, 10), (11, 16)]);
      expect(matchRanges('Banana', ['ana', 'nan']), [(1, 6)]);
    });
  });

  group('layar Cari', () {
    testWidgets('dibuka dari Beranda, hasil per jenis, ketuk membuka detail, kata kunci tetap ada', (tester) async {
      final h = Harness();
      await h.seedRich();
      final container = await pumpApp(tester, h);

      await tester.tap(find.byTooltip('Cari'));
      await settle(tester);
      expect(find.text('Mau cari apa?'), findsOneWidget);
      expect(find.textContaining('Bisa juga saat offline'), findsOneWidget);

      // Judul perjalanan dan catatan setoran.
      await tester.enterText(find.byType(TextField), 'keluarga');
      await settle(tester);
      expect(find.text('Tugas'), findsOneWidget);
      expect(find.text('Liburan'), findsOneWidget);
      expect(find.text('Setoran'), findsOneWidget);
      expect(find.text('3 hasil'), findsOneWidget);
      expect(find.textContaining('Hasil jual tanah warisan', findRichText: true), findsOneWidget);

      // Cocok di catatan tugas: potongannya ikut tampil.
      await tester.enterText(find.byType(TextField), 'm-banking');
      await settle(tester);
      expect(find.text('Tugas'), findsOneWidget);
      expect(find.textContaining('simpan buktinya', findRichText: true), findsOneWidget);

      await tester.tap(find.text('Bayar internet', findRichText: true));
      await settle(tester);
      expect(find.byType(TaskDetailScreen), findsOneWidget);

      // Dibuka lagi: kata kunci dan hasilnya masih ada.
      container.read(routerProvider).go(Routes.home);
      await settle(tester);
      await tester.tap(find.byTooltip('Cari'));
      await settle(tester);
      expect(find.widgetWithText(TextField, 'm-banking'), findsOneWidget);
      expect(find.text('Bayar internet', findRichText: true), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'zzzz');
      await settle(tester);
      expect(find.text('Belum ketemu "zzzz". Coba kata lain.'), findsOneWidget);

      // Hapus kata kunci: kembali ke penjelasan.
      await tester.tap(find.byTooltip('Hapus kata kunci'));
      await settle(tester);
      expect(find.textContaining('Bisa juga saat offline'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('kenangan ditemukan dari ceritanya; lebih dari lima hasil dilipat', (tester) async {
      final h = Harness();
      await h.seedRich();
      final container = await pumpApp(tester, h);
      container.read(searchTextProvider.notifier).set('ombaknya');
      container.read(routerProvider).go(Routes.search);
      await settle(tester);

      expect(find.text('Kenangan'), findsOneWidget);
      await tester.tap(find.textContaining('Keliling pantai selatan', findRichText: true));
      await settle(tester);
      expect(find.byType(MemoryDetailScreen), findsOneWidget);

      container.read(searchTextProvider.notifier).set('er');
      container.read(routerProvider).go(Routes.search);
      await settle(tester);
      final showAll = find.textContaining('Tampilkan semua');
      expect(showAll, findsWidgets);
      await tester.ensureVisible(showAll.first);
      await tester.tap(showAll.first);
      await settle(tester);

      await disposeApp(tester, h);
    });
  });
}
