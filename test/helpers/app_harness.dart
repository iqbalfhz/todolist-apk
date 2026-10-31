import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/app.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/media/media_caches.dart';
import 'package:todolist/core/media/photo_picker.dart';
import 'package:todolist/core/notifications/push_service.dart';
import 'package:todolist/core/platform/device_platform.dart';
import 'package:todolist/core/providers.dart';
import 'package:todolist/core/session/account_files.dart';
import 'package:todolist/core/session/session.dart';
import 'package:todolist/core/time/space_clock.dart';
import 'package:todolist/features/memories/presentation/memory_map.dart';

import 'fake_google.dart';
import 'fake_map.dart';
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
///
/// Kalau [signedIn] dimatikan, app mulai dari layar Masuk; akun [harness] baru dibuka
/// setelah berhasil masuk. [device] dan [push] menggantikan info HP dan layanan notifikasi,
/// dan [photoPicker] galeri foto.
Future<ProviderContainer> pumpApp(
  WidgetTester tester,
  Harness harness, {
  bool signedIn = true,
  bool notificationsDone = true,
  bool pairingDone = true,
  MemoryKeyValueStore? storage,
  DeviceInfo device = DeviceInfo.unknown,
  PushService? push,
  PhotoPicker? photoPicker,
  String? themeName,
  String? themeMode,
  FakeTileProvider? tiles,
  FakeGoogleAccounts? google,
  FakeAccountFiles? accountFiles,
}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  // Zona waktu HP tidak terbaca di tes (daftar dan masuk dengan Google); server lalu memakai
  // Asia/Jakarta. Tanpa ini, permintaannya menunggu kanal yang tidak pernah menjawab.
  const timezoneChannel = MethodChannel('flutter_timezone');
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    timezoneChannel,
    (_) async => throw PlatformException(code: 'unavailable'),
  );
  addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(timezoneChannel, null));

  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      bootstrapProvider.overrideWithValue(
        Bootstrap(
          token: signedIn ? '1|token-palsu' : null,
          userId: signedIn ? meId : null,
          themeName: themeName,
          themeMode: themeMode,
          notificationsOnboarded: notificationsDone,
          pairingOnboarded: pairingDone,
          device: device,
        ),
      ),
      keyValueStoreProvider.overrideWithValue(storage ?? MemoryKeyValueStore()),
      httpTransportProvider.overrideWithValue(harness.api),
      accountFactoryProvider.overrideWithValue((_) => harness.account),
      spaceClockProvider.overrideWithValue(SpaceClock(now: harness.clock.call)),
      mediaCachesProvider.overrideWithValue(harness.mediaCaches),
      // Peta kenangan (v1.x) tidak pernah mengunduh ubin sungguhan di tes.
      mapTileProviderProvider.overrideWithValue(tiles ?? FakeTileProvider()),
      // Masuk dengan Google (v1.x) tidak pernah membuka pilihan akun sungguhan di tes.
      googleAccountsProvider.overrideWithValue(google ?? FakeGoogleAccounts()),
      // Hapus akun (v1.0) tidak pernah menyentuh berkas sungguhan di tes.
      accountFilesProvider.overrideWithValue(accountFiles ?? FakeAccountFiles()),
      revocationTransportProvider.overrideWithValue((token) {
        harness.revocationTokens.add(token);
        return harness.api;
      }),
      if (push != null) pushServiceProvider.overrideWithValue(push),
      if (photoPicker != null) photoPickerProvider.overrideWithValue(photoPicker),
    ],
  );
  _container = container;

  // Antrean dan sync akun palsu ikut lewat klien API milik app, seperti di app sungguhan.
  harness.transport.inner = container.read(apiTransportProvider);

  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const TodoApp()));
  await settle(tester);

  return container;
}

ProviderContainer? _container;

/// Berkas akun palsu: mencatat akun yang berkasnya dihapus.
class FakeAccountFiles implements AccountFiles {
  final List<String> deleted = [];

  @override
  Future<void> delete(String userId) async => deleted.add(userId);
}

/// Biarkan kueri database, permintaan ke API palsu, dan animasi selesai.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pumpAndSettle();
}

/// Bongkar app sebelum database ditutup, supaya tidak ada kueri atau timer yang tertinggal.
Future<void> disposeApp(WidgetTester tester, Harness harness) async {
  await tester.pumpWidget(const SizedBox.shrink());
  _container?.dispose();
  _container = null;
  // Beri waktu drift membereskan langganan stream yang baru dilepas.
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
