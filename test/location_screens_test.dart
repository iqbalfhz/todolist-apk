import 'dart:convert';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/features/memories/presentation/location_picker_screen.dart';
import 'package:todolist/features/memories/presentation/memories_map_screen.dart';
import 'package:todolist/features/memories/presentation/memory_detail_screen.dart';

import 'helpers/app_harness.dart';
import 'helpers/fake_api.dart';
import 'helpers/fake_map.dart';
import 'helpers/fixtures.dart';

/// Pin lokasi kenangan dan Peta kenangan (v1.x): layar.
void main() {
  setUpAll(prepareAppTests);

  const otherMemoryId = '01m4dr8c50jk2mt7xw3pq9vb7c';

  Map<String, dynamic> pinned(Map<String, dynamic> memory, num latitude, num longitude) => {
    ...memory,
    'latitude': latitude,
    'longitude': longitude,
  };

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).first);
    await settle(tester);
  }

  Map<String, dynamic> payloadOf(dynamic op) => jsonDecode(op.payload as String) as Map<String, dynamic>;

  Future<void> openNewMemory(WidgetTester tester, Harness h) async {
    await h.seed();
    final container = await pumpApp(tester, h);
    container.read(routerProvider).go(Routes.newMemory());
    await settle(tester);
  }

  Future<void> openPicker(WidgetTester tester) async {
    await scrollTo(tester, find.text('Pasang pin di peta'));
    await tester.tap(find.text('Pasang pin di peta'));
    await settle(tester);
    expect(find.byType(LocationPickerScreen), findsOneWidget);
  }

  group('Pilih lokasi', () {
    testWidgets('cari tempat hanya lewat tombol, pilih hasilnya, lalu simpan bersama kenangan', (tester) async {
      final h = Harness();
      final tiles = FakeTileProvider();
      h.api.places = [
        {'name': 'Ubud', 'address': 'Ubud, Gianyar, Bali, Indonesia', 'latitude': -8.506853, 'longitude': 115.262477},
        {'name': 'Ubud Palace', 'address': 'Jalan Raya Ubud, Bali', 'latitude': -8.5069, 'longitude': 115.2625},
      ];
      await h.seed();
      final container = await pumpApp(tester, h, tiles: tiles);
      container.read(routerProvider).go(Routes.newMemory());
      await settle(tester);

      await tester.enterText(find.byType(TextField).first, 'Liburan ke Bali');
      await openPicker(tester);
      expect(find.text('Ketuk peta untuk memasang pin'), findsOneWidget);
      expect(find.text('© OpenStreetMap contributors'), findsOneWidget);
      expect(tiles.requested, isNotEmpty, reason: 'ubin peta diminta lewat penyedia ubin');

      // Mengetik saja tidak mencari: kebijakan Nominatim melarang autocomplete.
      await tester.enterText(find.byType(TextField), 'ubud');
      await settle(tester);
      expect(h.api.requests.where((request) => request.path == '/places'), isEmpty);

      await tester.tap(find.byTooltip('Cari tempat'));
      await settle(tester);
      expect(h.api.requests.where((request) => request.path == '/places').single.query, {'q': 'ubud'});
      expect(find.text('Ubud, Gianyar, Bali, Indonesia'), findsOneWidget);
      expect(find.text('© OpenStreetMap contributors'), findsNWidgets(2), reason: 'di bawah hasil dan di peta');

      await tester.tap(find.text('Ubud'));
      await settle(tester);
      expect(find.text('Ketuk peta untuk memasang pin'), findsNothing);
      await tester.tap(find.text('Pakai titik ini'));
      await settle(tester);

      // Kembali ke formulir: peta kecil tampil, dan "Di mana?" terisi dari hasil pencarian.
      expect(find.byType(LocationPickerScreen), findsNothing);
      expect(find.text('Ubah pin'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Ubud'), findsOneWidget);

      await scrollTo(tester, find.text('Simpan'));
      await tester.tap(find.text('Simpan'));
      await settle(tester);

      final op = (await h.ops()).firstWhere((op) => op.entityType == 'memory');
      expect(payloadOf(op), containsPair('latitude', -8.506853));
      expect(payloadOf(op), containsPair('longitude', 115.262477));
      expect(payloadOf(op), containsPair('place_name', 'Ubud'));
      expect(find.byType(MemoryDetailScreen), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('pin manual: ketuk peta, walau pencarian sedang tidak tersedia', (tester) async {
      final h = Harness();
      await openNewMemory(tester, h);
      await tester.enterText(find.byType(TextField).first, 'Pantai');
      await openPicker(tester);

      // Terlalu pendek: belum mencari.
      await tester.enterText(find.byType(TextField), 'ub');
      await tester.tap(find.byTooltip('Cari tempat'));
      await settle(tester);
      expect(find.text('Ketik paling sedikit 3 huruf, lalu ketuk Cari.'), findsOneWidget);
      expect(h.api.requests.where((request) => request.path == '/places'), isEmpty);

      // Server mematikan pencarian: pesannya tampil, peta tetap bisa dipakai.
      h.api.failNext(apiError(503, ApiErrorCode.placesUnavailable, message: 'Pencarian tempat sedang tidak tersedia.'));
      await tester.enterText(find.byType(TextField), 'ubud');
      await tester.tap(find.byTooltip('Cari tempat'));
      await settle(tester);
      expect(find.text('Pencarian tempat sedang tidak tersedia.'), findsOneWidget);

      // Offline.
      h.api.offline = true;
      await tester.tap(find.byTooltip('Cari tempat'));
      await settle(tester);
      expect(find.textContaining('butuh koneksi internet'), findsOneWidget);
      h.api.offline = false;

      // Tanpa hasil.
      await tester.tap(find.byTooltip('Cari tempat'));
      await settle(tester);
      expect(find.text('Tidak ada tempat yang cocok dengan "ubud". Coba kata lain, atau ketuk peta.'), findsOneWidget);

      // Pakai titik ini baru aktif setelah ada pin.
      final use = find.widgetWithText(FilledButton, 'Pakai titik ini');
      expect(tester.widget<FilledButton>(use).onPressed, isNull);
      await tester.tap(find.byType(FlutterMap));
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);
      expect(tester.widget<FilledButton>(use).onPressed, isNotNull);
      await tester.tap(use);
      await settle(tester);

      await scrollTo(tester, find.text('Simpan'));
      await tester.tap(find.text('Simpan'));
      await settle(tester);
      final payload = payloadOf((await h.ops()).firstWhere((op) => op.entityType == 'memory'));
      expect(payload['latitude'], isA<double>());
      expect(payload['longitude'], isA<double>());

      await disposeApp(tester, h);
    });

    testWidgets('ubah kenangan: Lepas pin mengirim lintang dan bujur kosong berdua', (tester) async {
      final h = Harness();
      await h.seed();
      await h.account.store.write(EntityType.memory, pinned(memoryJson(), -8.5, 115.2), serverUpdatedAt: t0);
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.editMemory(memoryId));
      await settle(tester);

      await scrollTo(tester, find.text('Lepas pin'));
      await tester.tap(find.text('Lepas pin'));
      await settle(tester);
      expect(find.text('Pasang pin di peta'), findsOneWidget);

      await scrollTo(tester, find.text('Simpan'));
      await tester.tap(find.text('Simpan'));
      await settle(tester);

      final patches = [
        for (final op in await h.ops())
          if (op.method == 'PATCH') payloadOf(op),
      ];
      expect(patches.last, containsPair('latitude', null));
      expect(patches.last, containsPair('longitude', null));

      await disposeApp(tester, h);
    });
  });

  group('Peta kenangan', () {
    testWidgets('dari Detail kenangan: kenangan itu langsung terpilih, ketuk kartunya untuk kembali', (tester) async {
      final h = Harness();
      await h.seed();
      await h.account.store.write(EntityType.memory, pinned(memoryJson(), -8.5, 115.2), serverUpdatedAt: t0);
      await h.account.store.write(
        EntityType.memory,
        pinned(memoryJson(id: otherMemoryId, title: 'Makan malam pertama', placeName: 'Bandung'), -6.9, 107.6),
        serverUpdatedAt: t0,
      );
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.memory(memoryId));
      await settle(tester);

      final preview = find.bySemanticsLabel('Lokasi di peta. Ketuk untuk membuka Peta kenangan.');
      await scrollTo(tester, preview);
      await tester.tap(preview);
      await settle(tester);

      expect(find.byType(MemoriesMapScreen), findsOneWidget);
      expect(find.text('2 kenangan berpin'), findsOneWidget);
      expect(find.text('Buka kenangan'), findsOneWidget);

      expect(find.text('Min, 20 Jun 2027 · Ubud, Bali'), findsOneWidget);

      // Tanpa fokus, semua pin muat di layar; pilih pin lain.
      container.read(routerProvider).go(Routes.memoriesMap());
      await settle(tester);
      expect(find.text('Buka kenangan'), findsNothing);
      await tester.tap(find.bySemanticsLabel('Makan malam pertama'));
      await settle(tester);
      expect(find.text('Min, 20 Jun 2027 · Bandung'), findsOneWidget);
      await tester.tap(find.text('Buka kenangan'));
      await settle(tester);
      expect(container.read(routerProvider).state.uri.path, Routes.memory(otherMemoryId));

      await disposeApp(tester, h);
    });

    testWidgets('dari tab Kenangan; tanpa kenangan berpin, ada petunjuknya', (tester) async {
      final h = Harness();
      await h.seed();
      await h.account.store.write(EntityType.memory, memoryJson(), serverUpdatedAt: t0);
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.memories);
      await settle(tester);

      await tester.tap(find.byTooltip('Peta kenangan'));
      await settle(tester);
      expect(find.text('Belum ada kenangan berpin. Pasang pin lewat Ubah kenangan.'), findsOneWidget);
      expect(find.text('© OpenStreetMap contributors'), findsOneWidget);

      await disposeApp(tester, h);
    });
  });
}
