import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/app.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/providers.dart';
import 'package:todolist/core/session/session.dart';
import 'package:todolist/core/time/space_clock.dart';

import 'fixtures.dart';

/// Siapkan hal yang biasanya dikerjakan `main()`: format tanggal, zona waktu, dan font.
Future<void> prepareAppTests() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  ensureTimezonesLoaded();

  // Font bawaan tes jauh lebih lebar dari Plus Jakarta Sans dan membuat tata letak
  // tampak meluap padahal tidak; pakai font app yang sebenarnya.
  final loader = FontLoader('Plus Jakarta Sans');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final bytes = File('assets/fonts/PlusJakartaSans-$weight.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

/// Jalankan app sungguhan di atas akun palsu [harness], dengan layar seukuran mockup (390 × 844).
Future<ProviderContainer> pumpApp(
  WidgetTester tester,
  Harness harness, {
  bool notificationsDone = true,
  bool pairingDone = true,
}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        bootstrapProvider.overrideWithValue(
          Bootstrap(
            token: '1|token-palsu',
            userId: meId,
            notificationsOnboarded: notificationsDone,
            pairingOnboarded: pairingDone,
          ),
        ),
        keyValueStoreProvider.overrideWithValue(MemoryKeyValueStore()),
        apiTransportProvider.overrideWithValue(harness.api),
        accountProvider.overrideWithValue(harness.account),
        spaceClockProvider.overrideWithValue(SpaceClock(now: harness.clock.call)),
      ],
      child: const TodoApp(),
    ),
  );
  await settle(tester);

  return ProviderScope.containerOf(tester.element(find.byType(TodoApp)));
}

/// Biarkan kueri database, permintaan ke API palsu, dan animasi selesai.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pumpAndSettle();
}

/// Bongkar app sebelum database ditutup, supaya tidak ada kueri yang tertinggal.
Future<void> disposeApp(WidgetTester tester, Harness harness) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
  await harness.dispose();
}

extension UnpairedHarness on Harness {
  /// Isi cache untuk akun yang belum berpasangan: profil, Ruang Pribadi, dan satu daftar di dalamnya.
  Future<void> seedUnpaired() async {
    final list = listJson(spaceId: personalSpaceId, name: 'Tugas');
    await account.store.write(EntityType.me, userJson());
    await account.store.write(EntityType.space, personalSpaceJson(), serverUpdatedAt: t0);
    await account.store.write(EntityType.list, list, serverUpdatedAt: t0);
    api
      ..me = userJson()
      ..spaces = [personalSpaceJson()]
      ..rows.putIfAbsent('lists', () => {})[listId] = list;
  }
}
