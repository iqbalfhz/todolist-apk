// Uji jalan penuh lewat layar app terhadap API Laravel yang sungguhan.
//
// Yang dijalankan sama dengan di HP: layar, repository, antrean, dan sync yang asli,
// dengan HTTP sungguhan ke server. Yang diganti hanya bagian yang butuh perangkat:
// penyimpanan aman, file database (di folder sementara), dan layanan notifikasi.
// Pasangan diperankan HP kedua yang bekerja langsung lewat lapisan data.
//
// Dilewati kecuali E2E_API_URL diisi; cara menjalankan dan batasannya sama dengan
// `api_e2e_test.dart`. Sekali jalan memakai tiga permintaan daftar, jadi beri jeda
// satu menit sebelum menjalankan tes ujung ke ujung mana pun lagi.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/app.dart';
import 'package:todolist/app_services.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/api/api_transport.dart';
import 'package:todolist/core/database/app_database.dart';
import 'package:todolist/core/media/media_caches.dart';
import 'package:todolist/core/notifications/push_service.dart';
import 'package:todolist/core/platform/device_platform.dart';
import 'package:todolist/core/providers.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/core/session/account.dart';
import 'package:todolist/core/session/session.dart';
import 'package:todolist/core/storage/key_value_store.dart';
import 'package:todolist/core/time/space_clock.dart';
import 'package:todolist/core/utils/dates.dart';
import 'package:todolist/core/widgets/widgets.dart';
import 'package:todolist/features/auth/data/auth_repository.dart';
import 'package:todolist/features/auth/domain/user.dart';
import 'package:todolist/features/spaces/domain/space.dart';
import 'package:todolist/features/special_dates/domain/special_date.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_photos.dart';
import '../helpers/fake_push.dart';
import '../helpers/fixtures.dart';

/// Menjalankan request di zone akar. Tes widget memakai jam palsu, dan HTTP sungguhan
/// hanya selesai kalau berjalan di luar zone itu.
class RootZoneTransport implements ApiTransport {
  RootZoneTransport(this.inner);

  final ApiTransport inner;

  /// Selama menyala, semua request gagal seperti HP tanpa koneksi.
  bool offline = false;

  int inFlight = 0;
  final List<String> log = [];

  @override
  Future<ApiResponse> send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    ApiUpload? upload,
  }) async {
    log.add('$method $path');
    if (offline) throw const NetworkFailure();

    inFlight++;
    // Error tidak bisa menyeberang antar-zone, jadi dibawa pulang sebagai nilai
    // lalu dilempar ulang di zone pemanggil.
    final (response, error, stack) = await Zone.root.run(() async {
      try {
        final response = await inner.send(method, path, body: body, query: query, upload: upload);
        return (response, null, null);
      } on Object catch (error, stack) {
        return (null, error, stack);
      } finally {
        inFlight--;
      }
    });

    if (error != null) Error.throwWithStackTrace(error, stack!);
    return response!;
  }
}

/// HP pasangan: token, klien API sungguhan, dan database lokal di memori.
class PartnerDevice {
  PartnerDevice(String baseUrl) {
    api = DioApiTransport(baseUrl: baseUrl, token: () => token);
  }

  late final ApiTransport api;
  late Account account;
  late User user;
  String? token;

  Future<void> register(String email) async {
    final result = await AuthRepository(api)
        .register(name: 'Sari', email: email, password: 'rahasia-banget', deviceName: 'HP Pasangan');
    token = result.token;
    user = result.user;
    account = Account(userId: user.id, db: AppDatabase(NativeDatabase.memory()), api: api, autoFlush: false);
    await account.profile.save(user);
    await account.sync.sync();
  }

  /// Kirim antrean (melewati jeda Urungkan), lalu tarik perubahan.
  Future<void> syncNow() async {
    await account.db.customUpdate('UPDATE outbox_ops SET hold_until = NULL');
    await account.outbox.flush(retryNow: true);
    await account.sync.sync(retryNow: true);
  }

  Future<Space> sharedSpace() async => (await account.store.spaces()).firstWhere((space) => space.isShared);
}

void main() {
  final baseUrl = Platform.environment['E2E_API_URL'];
  final skipReason = baseUrl == null ? 'E2E_API_URL belum diisi' : null;

  final stamp = DateTime.now().millisecondsSinceEpoch;
  final email = 'ui-aku-$stamp@contoh.test';
  final partnerEmail = 'ui-pasangan-$stamp@contoh.test';
  const password = 'rahasia-banget';

  setUpAll(() async {
    await prepareAppTests();
    // Tes widget menolak semua HTTP secara bawaan; tes ini justru butuh HTTP sungguhan.
    HttpOverrides.global = null;
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  testWidgets('seluruh fitur v0.1 sampai v1.x lewat layar, terhadap API sungguhan', (tester) async {
    final semantics = tester.ensureSemantics();
    WidgetController.hitTestWarningShouldBeFatal = true;
    addTearDown(() => WidgetController.hitTestWarningShouldBeFatal = false);

    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Zona waktu HP tidak terbaca di tes; server lalu memakai Asia/Jakarta.
    const timezoneChannel = MethodChannel('flutter_timezone');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      timezoneChannel,
      (_) async => throw PlatformException(code: 'unavailable'),
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(timezoneChannel, null));

    // Widget layar utama (v1.x): ringkasan yang dikirim app ke Android dicatat di sini.
    final widgetSnapshots = <Map<String, dynamic>>[];
    const deviceChannel = MethodChannel('todolist/device');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(deviceChannel, (call) async {
      if (call.method == 'updateWidget') {
        widgetSnapshots.add(jsonDecode((call.arguments as Map)['json'] as String) as Map<String, dynamic>);
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(deviceChannel, null));

    // Jam app bisa dimajukan bersama jam palsu tes, untuk melewati jeda Urungkan.
    var skew = Duration.zero;
    DateTime now() => DateTime.now().add(skew);
    final clock = SpaceClock(now: now);
    String today() => clock.today('Asia/Jakarta');

    final dir = Directory.systemTemp.createTempSync('todolist-ui-e2e-');
    final storage = MemoryKeyValueStore();
    final push = FakePushService();

    late final ProviderContainer container;
    final transport = RootZoneTransport(
      DioApiTransport(baseUrl: baseUrl!, token: () => container.read(sessionProvider).token),
    );

    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        bootstrapProvider.overrideWithValue(
          const Bootstrap(
            device: DeviceInfo(manufacturer: 'Google', brand: 'google', model: 'Pixel 8', sdkInt: 34),
          ),
        ),
        keyValueStoreProvider.overrideWithValue(storage),
        httpTransportProvider.overrideWithValue(transport),
        accountFactoryProvider.overrideWith((ref) {
          final api = ref.watch(apiTransportProvider);
          return (userId) => Account(
            userId: userId,
            db: AppDatabase(NativeDatabase(File('${dir.path}/akun_$userId.sqlite'))),
            api: api,
            now: now,
          );
        }),
        spaceClockProvider.overrideWithValue(clock),
        pushServiceProvider.overrideWithValue(push),
        mediaCachesProvider.overrideWithValue(FakeMediaCaches()),
        revocationTransportProvider.overrideWithValue(
          (token) => RootZoneTransport(DioApiTransport(baseUrl: baseUrl, token: () => token)),
        ),
      ],
    );

    // ---------------------------------------------------------------- pembantu

    /// Tunggu sampai tidak ada request yang berjalan dan animasi selesai.
    ///
    /// `pumpAndSettle` saja tidak cukup: selama balasan server belum tiba, kerangka
    /// pemuatan beranimasi terus, dan request yang baru mulai di tengah animasi
    /// hanya bisa selesai kalau tes kembali menunggu di luar jam palsu.
    Future<void> net() async {
      for (var round = 0; round < 40; round++) {
        var quiet = 0;
        for (var i = 0; i < 600 && quiet < 4; i++) {
          await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
          await tester.pump(const Duration(milliseconds: 10));
          quiet = transport.inFlight == 0 ? quiet + 1 : 0;
        }

        var frames = 0;
        while (tester.binding.hasScheduledFrame && transport.inFlight == 0 && frames < 100) {
          await tester.pump(const Duration(milliseconds: 100));
          frames++;
        }
        if (transport.inFlight == 0 && !tester.binding.hasScheduledFrame) return;
        if (transport.inFlight == 0) break;
      }

      final recent = transport.log.skip(transport.log.length > 6 ? transport.log.length - 6 : 0).toList();
      fail('Layar tidak kunjung diam. Request terakhir: $recent, masih berjalan: ${transport.inFlight}');
    }

    /// Majukan jam app dan jam tes bersama-sama.
    Future<void> advance(Duration duration) async {
      skew += duration;
      await tester.pump(duration);
      await net();
    }

    void step(String name) => debugPrint('— $name');

    /// Beberapa frame, tanpa menunggu animasi selesai.
    Future<void> breathe() async {
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 60));
      }
    }

    Future<void> tap(Finder finder) async {
      await tester.ensureVisible(finder);
      await breathe();
      await tester.tap(finder);
      await net();
    }

    Future<void> go(String path) async {
      container.read(routerProvider).go(path);
      await net();
    }

    Future<void> pullToRefresh() async {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 400));
      // Indikatornya turun dulu sebelum penyegaran benar-benar dimulai.
      await breathe();
      await breathe();
      await net();
    }

    Finder field(String label) => find.descendant(
      of: find.ancestor(of: find.text(label), matching: find.byType(LabeledField)),
      matching: find.byType(TextField),
    );

    /// Yang tersimpan di server untuk akun yang sedang masuk di app.
    Future<Map<String, dynamic>> server(String path) async {
      final token = container.read(sessionProvider).token;
      final api = DioApiTransport(baseUrl: baseUrl, token: () => token);
      final response = await tester.runAsync(() => api.send('GET', path));
      return response!.body!;
    }

    Future<List<Map<String, dynamic>>> serverRows(String key) async {
      final body = await server('/sync');
      return ((body['data'] as Map<String, dynamic>)[key] as List<dynamic>).cast<Map<String, dynamic>>();
    }

    Future<Map<String, dynamic>> serverRow(String key, bool Function(Map<String, dynamic> row) test) async =>
        (await serverRows(key)).firstWhere(test);

    Future<T> asPartner<T>(Future<T> Function() action) async => (await tester.runAsync(action)) as T;

    // ---------------------------------------------------------------- daftar dan alur pertama kali

    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const TodoApp()));
    await tester.pumpAndSettle();

    step('Daftar');
    expect(find.text('Senang melihatmu lagi.'), findsOneWidget);
    await tap(find.widgetWithText(TextButton, 'Daftar'));
    await tester.enterText(field('Nama panggilan'), 'Iqbal');
    await tester.enterText(field('Email'), email);
    await tester.enterText(field('Kata sandi'), password);
    await tap(find.widgetWithText(FilledButton, 'Daftar'));
    await net();

    expect(storage.values[StorageKeys.token], isNotNull);
    expect(find.text('Biar tidak ada yang terlewat'), findsOneWidget);

    step('Izin notifikasi');
    await tap(find.text('Izinkan notifikasi'));
    expect(push.permissionRequests, 1);
    expect(find.text('Notifikasi sudah diizinkan.'), findsOneWidget);
    await tap(find.text('Lanjut'));
    await net();

    step('Ajak pasangan: kode undangan dari server');
    expect(find.text('Pakai berdua, lebih ringan'), findsOneWidget);
    final me = await server('/me');
    final code = ((me['data'] as Map<String, dynamic>)['invitation'] as Map<String, dynamic>)['code'] as String;
    // Kotak kodenya dibacakan per karakter, supaya tidak terbaca sebagai satu kata.
    expect(find.bySemanticsLabel(RegExp('Kode undangan ${code.split('').join(' ')}')), findsWidgets);
    await tap(find.text('Nanti saja'));
    await net();

    step('Beranda kosong, dan sync penuh membawa Ruang Pribadi beserta daftar "Tugas"');
    expect(find.text('Belum ada tugas hari ini. Santai dulu, atau tambah yang baru.'), findsOneWidget);
    expect(find.text('Belum ada target tabungan. Mulai dari satu target dulu.'), findsOneWidget);
    await tap(find.text('Tugas').last);
    expect(find.text('Pribadi · 0'), findsOneWidget);
    // Belum berpasangan: tidak ada filter orang.
    expect(find.text('Semua orang'), findsNothing);

    // ---------------------------------------------------------------- tugas

    step('Tambah cepat dari Beranda');
    await tap(find.text('Beranda').last);
    await tap(find.byType(FloatingActionButton));
    expect(find.text('Tugas baru'), findsOneWidget);
    // Tanpa pasangan, pilihan Siapa? tidak ada.
    expect(find.text('Siapa?'), findsNothing);
    await tester.enterText(find.byType(TextField), 'Bayar listrik');
    await tap(find.text('Tandai penting'));
    await tap(find.widgetWithText(FilledButton, 'Simpan'));
    await net();

    expect(find.text('Bayar listrik'), findsOneWidget);
    expect(find.text('0 dari 1 beres'), findsOneWidget);
    var task = await serverRow('tasks', (row) => row['title'] == 'Bayar listrik');
    expect(task['due_date'], today());
    expect(task['due_time'], isNull);
    expect(task['priority'], 3);
    expect(task['remind_at'], isNotNull, reason: 'tanpa jam, diingatkan pukul 08.00');
    final taskId = task['id'] as String;
    expect(taskId, matches(RegExp(r'^[0-9a-hjkmnp-tv-z]{26}$')), reason: 'ULID huruf kecil');

    step('Detail tugas: judul, catatan, jam, dan penting tersimpan otomatis');
    await tap(find.text('Bayar listrik'));
    expect(find.text('Detail tugas'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Bayar listrik rumah');
    await tester.enterText(find.byType(TextField).at(1), 'Token 100 ribu');
    await advance(const Duration(milliseconds: 1200));
    await tap(find.text('Pilih jam'));
    await tap(find.text('OKE'));
    await net();
    await tap(find.text('Tandai penting'));
    await net();

    task = await serverRow('tasks', (row) => row['id'] == taskId);
    expect(task['title'], 'Bayar listrik rumah');
    expect(task['notes'], 'Token 100 ribu');
    expect(task['due_time'], matches(RegExp(r'^\d\d:\d\d$')));
    expect(task['priority'], 0);
    expect(find.text('Simpan'), findsNothing);

    step('Tenggat dihapus: jam ikut kosong');
    await tap(find.text('Hapus tenggat'));
    await net();
    task = await serverRow('tasks', (row) => row['id'] == taskId);
    expect(task['due_date'], isNull);
    expect(task['due_time'], isNull);
    expect(task['remind_at'], isNull);
    await tap(find.byTooltip('Kembali'));

    step('Centang lalu Urungkan: tidak ada yang sampai ke server');
    await tap(find.text('Tugas').last);
    expect(find.text('Tanpa tenggat'), findsOneWidget);
    await tap(find.bySemanticsLabel('Tandai selesai: Bayar listrik rumah'));
    expect(find.text('Tugas selesai.'), findsOneWidget);
    await tap(find.text('Urungkan'));
    await advance(const Duration(seconds: 6));
    task = await serverRow('tasks', (row) => row['id'] == taskId);
    expect(task['completed_at'], isNull);
    expect(find.bySemanticsLabel('Tandai selesai: Bayar listrik rumah'), findsOneWidget);

    step('Centang tanpa Urungkan: terkirim setelah 5 detik');
    await tap(find.bySemanticsLabel('Tandai selesai: Bayar listrik rumah'));
    await advance(const Duration(seconds: 6));
    task = await serverRow('tasks', (row) => row['id'] == taskId);
    expect(task['completed_at'], isNotNull);
    expect(task['completed_by'], (me['data'] as Map<String, dynamic>)['id']);
    expect(find.text('Selesai (1)'), findsOneWidget);

    step('Batalkan selesai');
    await tap(find.text('Selesai (1)'));
    expect(find.textContaining('Diselesaikan Aku'), findsOneWidget);
    await tap(find.bySemanticsLabel('Batalkan selesai: Bayar listrik rumah'));
    await net();
    task = await serverRow('tasks', (row) => row['id'] == taskId);
    expect(task['completed_at'], isNull);

    // ---------------------------------------------------------------- daftar

    step('Daftar baru dengan warna');
    await tap(find.byTooltip('Buat daftar baru'));
    expect(find.text('Daftar baru'), findsOneWidget);
    await tester.enterText(field('Nama daftar'), 'Belanja');
    await tap(find.bySemanticsLabel('Warna Toska'));
    await tap(find.widgetWithText(FilledButton, 'Simpan'));
    await net();
    var list = await serverRow('task_lists', (row) => row['name'] == 'Belanja');
    expect(list['color'], 'toska');
    final listId = list['id'] as String;
    expect(find.text('Belanja'), findsOneWidget);

    step('Pindah daftar dari Detail tugas');
    await tap(find.text('Bayar listrik rumah'));
    await tap(find.text('Daftar pribadi'));
    await tap(find.text('Belanja').last);
    await net();
    task = await serverRow('tasks', (row) => row['id'] == taskId);
    expect(task['task_list_id'], listId);
    await tap(find.byTooltip('Kembali'));

    step('Kelola daftar: ubah nama, arsipkan, keluarkan dari arsip');
    await go(Routes.manageLists);
    await tap(find.text('Belanja'));
    expect(find.text('Ubah daftar'), findsOneWidget);
    await tester.enterText(field('Nama daftar'), 'Belanja bulanan');
    await tap(find.widgetWithText(FilledButton, 'Simpan'));
    await net();
    list = await serverRow('task_lists', (row) => row['id'] == listId);
    expect(list['name'], 'Belanja bulanan');

    await tap(find.text('Belanja bulanan'));
    await tap(find.text('Arsipkan'));
    await net();
    list = await serverRow('task_lists', (row) => row['id'] == listId);
    expect(list['archived_at'], isNotNull);
    expect(find.text('Diarsipkan'), findsOneWidget);
    // Tugas di daftar arsip tidak tampil di tampilan mana pun.
    await go(Routes.tasks);
    expect(find.text('Bayar listrik rumah'), findsNothing);

    await go(Routes.manageLists);
    await tap(find.text('Belanja bulanan'));
    await tap(find.text('Keluarkan dari arsip'));
    await net();
    list = await serverRow('task_lists', (row) => row['id'] == listId);
    expect(list['archived_at'], isNull);

    step('Daftar aktif terakhir di sebuah ruang tidak bisa diarsipkan');
    await tap(find.text('Belanja bulanan'));
    await tap(find.text('Arsipkan'));
    await net();
    await tap(find.text('Tugas').first);
    await tap(find.text('Arsipkan'));
    expect(find.text('Setiap ruang harus punya minimal satu daftar aktif.'), findsOneWidget);
    await tap(find.byTooltip('Tutup'));
    await tap(find.text('Belanja bulanan'));
    await tap(find.text('Keluarkan dari arsip'));
    await net();

    step('Hapus tugas dari Detail, dengan Urungkan yang dibiarkan lewat');
    await go(Routes.task(taskId));
    await tap(find.byTooltip('Hapus tugas'));
    expect(find.text('Tugas dihapus.'), findsOneWidget);
    await advance(const Duration(seconds: 6));
    expect(
      (await serverRows('tasks')).where((row) => row['id'] == taskId),
      isEmpty,
      reason: 'sync penuh tanpa yang terhapus',
    );

    step('Hapus daftar dengan konfirmasi');
    await go(Routes.manageLists);
    await tap(find.text('Belanja bulanan'));
    await tap(find.text('Hapus daftar'));
    expect(find.text('Hapus daftar Belanja bulanan?'), findsOneWidget);
    expect(find.text('Daftar ini belum berisi tugas.'), findsOneWidget);
    await tap(find.widgetWithText(TextButton, 'Hapus'));
    await net();
    expect((await serverRows('task_lists')).where((row) => row['id'] == listId), isEmpty);

    // ---------------------------------------------------------------- tabungan

    step('Target baru dari tab Tabungan');
    await go(Routes.savings);
    expect(find.text('Belum ada target tabungan. Buat satu, lalu catat setoran pertamamu.'), findsOneWidget);
    await tap(find.widgetWithText(TextButton, 'Tambah target'));
    expect(find.text('Target baru'), findsOneWidget);
    await tester.enterText(field('Menabung untuk apa?'), 'Dana Liburan');
    await tester.enterText(field('Berapa targetnya?'), '1000000');
    await tap(find.widgetWithText(FilledButton, 'Simpan'));
    await net();
    var goal = await serverRow('savings_goals', (row) => row['name'] == 'Dana Liburan');
    expect(goal['target_amount'], 1000000);
    expect(goal['currency'], 'IDR');
    final goalId = goal['id'] as String;
    expect(find.text('Rp0 dari Rp1.000.000'), findsOneWidget);

    step('Setor, dengan nominal diformat otomatis');
    await tap(find.text('Dana Liburan'));
    await tap(find.widgetWithText(FilledButton, 'Setor'));
    expect(find.text('Setor tabungan'), findsOneWidget);
    await tester.enterText(field('Berapa?'), '250000');
    await tester.pump();
    expect(find.text('250.000'), findsOneWidget);
    await tester.enterText(field('Catatan (opsional)'), 'Gajian');
    await tap(find.widgetWithText(FilledButton, 'Simpan'));
    await net();
    var entry = await serverRow('savings_entries', (row) => row['savings_goal_id'] == goalId);
    expect(entry['amount'], 250000);
    expect(entry['entry_date'], today());
    expect(entry['note'], 'Gajian');
    expect(find.text('Aku · Gajian'), findsOneWidget);
    expect(find.text('+Rp250.000'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
    expect(find.text('Sisa Rp750.000'), findsOneWidget);

    step('Ubah setoran sampai target tercapai');
    await tap(find.text('Aku · Gajian'));
    expect(find.text('Ubah setoran'), findsOneWidget);
    await tester.enterText(field('Berapa?'), '1000000');
    await tap(find.widgetWithText(FilledButton, 'Simpan'));
    await net();
    entry = await serverRow('savings_entries', (row) => row['savings_goal_id'] == goalId);
    expect(entry['amount'], 1000000);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Dana Liburan tercapai. Selamat, kamu berhasil!'), findsOneWidget);
    goal = await serverRow('savings_goals', (row) => row['id'] == goalId);
    expect(goal['achieved_at'], isNotNull);

    step('Hapus setoran');
    await tap(find.text('Aku · Gajian'));
    await tap(find.text('Hapus setoran'));
    expect(find.text('Hapus setoran Rp1.000.000?'), findsOneWidget);
    await tap(find.widgetWithText(TextButton, 'Hapus'));
    await net();
    expect((await serverRows('savings_entries')).where((row) => row['savings_goal_id'] == goalId), isEmpty);
    expect(find.text('Belum ada setoran. Ketuk Setor untuk mencatat yang pertama.'), findsOneWidget);

    step('Ubah target, arsipkan, keluarkan dari arsip');
    await tap(find.byTooltip('Opsi lainnya'));
    await tap(find.text('Ubah'));
    expect(find.text('Ubah target'), findsOneWidget);
    expect(find.text('Mata uang hanya bisa dipilih saat target dibuat.'), findsOneWidget);
    await tester.enterText(field('Berapa targetnya?'), '2000000');
    await tap(find.widgetWithText(FilledButton, 'Simpan'));
    await net();
    goal = await serverRow('savings_goals', (row) => row['id'] == goalId);
    expect(goal['target_amount'], 2000000);

    await tap(find.byTooltip('Opsi lainnya'));
    await tap(find.text('Arsipkan'));
    await net();
    goal = await serverRow('savings_goals', (row) => row['id'] == goalId);
    expect(goal['archived_at'], isNotNull);
    await tap(find.byTooltip('Opsi lainnya'));
    await tap(find.text('Keluarkan dari arsip'));
    await net();
    goal = await serverRow('savings_goals', (row) => row['id'] == goalId);
    expect(goal['archived_at'], isNull);

    // ---------------------------------------------------------------- pengaturan dan profil

    step('Pengaturan: preferensi notifikasi dan mata uang lewat PATCH /me');
    await go(Routes.settings);
    await tap(find.text('Aktivitas pasangan'));
    await net();
    // Switch keempat (v0.2) ada di bawah; daftar baru membangunnya setelah digulir.
    await tester.scrollUntilVisible(
      find.text('H-7, H-1, dan hari H pukul 08.00'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tap(find.text('H-7, H-1, dan hari H pukul 08.00'));
    await net();
    await tap(find.text('Mata uang'));
    await tap(find.text('Dolar AS (USD)'));
    await net();
    var profile = (await server('/me'))['data'] as Map<String, dynamic>;
    expect(profile['notification_prefs'], {
      'task_reminders': true,
      'partner_activity': false,
      'savings_activity': true,
      'special_dates': false,
      'trip_reminders': true,
      'savings_reminders': true,
    });
    expect(profile['default_currency'], 'USD');
    expect(find.text('Dolar AS (USD)'), findsOneWidget);

    step('Tema disimpan di HP saja');
    final patchesBefore = transport.log.where((line) => line == 'PATCH /me').length;
    await tap(find.text('Anggrek'));
    await tap(find.text('Gelap'));
    await net();
    expect(storage.values[StorageKeys.themeName], 'anggrek');
    expect(storage.values[StorageKeys.themeMode], 'dark');
    expect(transport.log.where((line) => line == 'PATCH /me').length, patchesBefore);
    await tap(find.text('Mawar'));
    await tap(find.text('Terang'));

    step('Profil: nama, tanggal lahir tanpa tahun, dan warna diri');
    // Baris Profil ada di atas; isi daftar yang jauh di luar layar belum dibangun.
    await tester.scrollUntilVisible(find.text('Profil'), -300, scrollable: find.byType(Scrollable).first);
    await tap(find.text('Profil'));
    await tester.enterText(field('Nama panggilan'), 'Iqbal F');
    await tap(find.text('Belum diisi'));
    await tap(find.widgetWithText(TextButton, 'Simpan'));
    await tap(find.bySemanticsLabel('Warna Biru'));
    await tap(find.widgetWithText(FilledButton, 'Simpan'));
    await net();
    profile = (await server('/me'))['data'] as Map<String, dynamic>;
    expect(profile['name'], 'Iqbal F');
    expect(profile['birth_date'], '--01-01');
    expect(profile['color'], 'biru');
    expect(find.text('Profil disimpan.'), findsOneWidget);

    // ---------------------------------------------------------------- berpasangan

    step('Ajak pasangan dari Pengaturan: kode yang sama masih berlaku');
    expect(find.text('Belum berpasangan · ajak pasanganmu'), findsOneWidget);
    await tap(find.text('Ruang Bersama'));
    expect(find.text('Pakai berdua, lebih ringan'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Kode undangan ${code.split('').join(' ')}')), findsWidgets);

    step('Pasangan memakai kode undanganku');
    final partner = PartnerDevice(baseUrl);
    await asPartner(() async {
      await partner.register(partnerEmail);
      // Server menyeragamkan kode: huruf kecil dan tanda hubung tetap diterima.
      await partner.account.spaces.accept('${code.substring(0, 3).toLowerCase()}-${code.substring(3).toLowerCase()}');
      await partner.syncNow();
    });

    step('Layar ditarik untuk menyegarkan: Ruang Bersama tampil');
    await pullToRefresh();
    expect(find.text('Kamu dan Sari berbagi tugas dan tabungan di sini.'), findsOneWidget);
    expect(find.text('Iqbal F (kamu)'), findsOneWidget);
    expect(find.text('Sari'), findsOneWidget);

    step('Tugas untuk Pasangan masuk ke daftar bersama dan sampai ke HP pasangan');
    await go(Routes.home);
    expect(find.text('Pasangan'), findsOneWidget, reason: 'filter orang muncul setelah berpasangan');
    await tap(find.byType(FloatingActionButton));
    expect(find.text('Siapa?'), findsOneWidget);
    expect(find.text('Daftar bersama'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Beli galon');
    await tap(find.text('Pasangan').last);
    await tap(find.widgetWithText(FilledButton, 'Simpan'));
    await net();

    final sharedTaskId = await asPartner(() async {
      await partner.syncNow();
      final shared = await partner.sharedSpace();
      final received = (await partner.account.store.tasks()).firstWhere((row) => row.title == 'Beli galon');
      expect(received.spaceId, shared.id);
      expect(received.assigneeIds, [partner.user.id]);
      expect(received.dueDate, today());

      await partner.account.tasks.complete(received.id);
      await partner.syncNow();
      return received.id;
    });

    step('Pasangan menyelesaikannya: tampil setelah Beranda disegarkan');
    await pullToRefresh();
    expect(find.text('1 dari 1 beres'), findsOneWidget);
    expect(find.textContaining('Diselesaikan Pasangan'), findsOneWidget);
    expect((await serverRow('tasks', (row) => row['id'] == sharedTaskId))['completed_by'], partner.user.id);

    step('Filter orang di Beranda');
    await tap(find.text('Aku'));
    expect(find.text('Tidak ada tugas hari ini untuk pilihan ini.'), findsOneWidget);
    await tap(find.text('Semua'));
    expect(find.text('Beli galon'), findsOneWidget);

    step('Target bersama: setoran pasangan tampil di riwayat');
    await go(Routes.savings);
    await tap(find.byTooltip('Tambah target'));
    await tester.enterText(field('Menabung untuk apa?'), 'Dana Darurat');
    await tester.enterText(field('Berapa targetnya?'), '500');
    await tap(find.widgetWithText(FilledButton, 'Simpan'));
    await net();
    final sharedGoal = await serverRow('savings_goals', (row) => row['name'] == 'Dana Darurat');
    // Mata uang bawaan sudah diganti ke dolar: 500,00 disimpan sebagai 50000 sen.
    expect(sharedGoal['currency'], 'USD');
    expect(sharedGoal['target_amount'], 50000);

    await asPartner(() async {
      await partner.syncNow();
      final shared = await partner.sharedSpace();
      expect(sharedGoal['space_id'], shared.id);
      final goals = await partner.account.savings.watchGoals().first;
      final received = goals.firstWhere((row) => row.name == 'Dana Darurat');
      await partner.account.savings.createEntry(goal: received, amount: 12550, entryDate: today(), note: 'sisa gajian');
      await partner.syncNow();
    });

    await tap(find.text('Dana Darurat'));
    await pullToRefresh();
    expect(find.text('25%'), findsOneWidget);
    // Kontribusi per orang (v1.x): baru pasangan yang menyetor.
    await tester.scrollUntilVisible(find.text('Kontribusi'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Pasangan · sisa gajian'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(r'+US$125,50'), findsOneWidget);

    // ---------------------------------------------------------------- tanggal penting (v0.2)

    step('Tanggal penting: hari jadi di Ruang Bersama, dengan tahun');
    await go(Routes.specialDates);
    // Tanggal lahirku sudah diisi di Profil, jadi ulang tahunku langsung dihitung mundur.
    expect(find.text('Ulang tahunmu'), findsOneWidget);
    await tap(find.widgetWithText(FilledButton, 'Tambah tanggal'));
    await tester.enterText(find.byType(TextField), 'Hari jadi kita');
    await tap(find.text('Pilih tanggal'));
    await tap(find.text('Januari'));
    await tap(find.text('Februari').last);
    await tester.enterText(find.byType(TextField).last, '2023');
    await tap(find.widgetWithText(TextButton, 'Simpan'));
    await tap(find.widgetWithText(FilledButton, 'Simpan'));
    await net();

    final anniversary = await serverRow('special_dates', (row) => row['title'] == 'Hari jadi kita');
    expect(anniversary['type'], 'anniversary');
    expect(anniversary['date'], '2023-02-01');
    expect(find.text('Bersama sejak 1 Feb 2023'), findsOneWidget);

    step('Sampai ke HP pasangan bersama tanggal lahirku; pasangan menyiapkan kejutan di Ruang Pribadi');
    await asPartner(() async {
      await partner.syncNow();
      final shared = await partner.sharedSpace();
      final received = (await partner.account.dates.watchAll().first).singleWhere(
        (date) => date.id == anniversary['id'],
      );
      expect(received.spaceId, shared.id);
      expect(received.date, '2023-02-01');
      expect(shared.members.firstWhere((member) => member.id != partner.user.id).birthDate, '--01-01');

      final personal = (await partner.account.store.spaces()).firstWhere((space) => space.isPersonal);
      await partner.account.dates.create(
        spaceId: personal.id,
        type: SpecialDateType.birthday,
        title: 'Kejutan untuk Iqbal',
        date: '--01-01',
      );
      await partner.account.profile.update(birthDate: '1999-11-17');
      await partner.syncNow();
    });

    step('Ulang tahun pasangan dari profilnya tampil; tanggal pribadinya tidak');
    await pullToRefresh();
    expect(find.textContaining('Ulang tahun Sari ke-'), findsOneWidget);
    expect(find.text('Kejutan untuk Iqbal'), findsNothing);
    expect((await serverRows('special_dates')).where((row) => row['title'] == 'Kejutan untuk Iqbal'), isEmpty);

    step('Beranda menghitung mundur tanggal terdekat');
    await go(Routes.home);
    expect(find.bySemanticsLabel(RegExp('^Tanggal penting: ')), findsOneWidget);
    expect(find.text('Rencanakan liburan'), findsOneWidget);
    expect(find.textContaining(RegExp(r'^(\d+ hari lagi|Besok|.*Selamat!)$')), findsOneWidget);
    await go(Routes.specialDates);

    step('Ubah lalu hapus tanggal');
    // Baris di "Akan datang"; kartu "Bersama sejak" juga menyebut namanya.
    await tap(find.textContaining(RegExp(r'^Hari jadi kita ke-\d+$')));
    await tester.enterText(find.byType(TextField), 'Hari jadi');
    await tap(find.widgetWithText(FilledButton, 'Simpan'));
    await net();
    expect((await serverRow('special_dates', (row) => row['id'] == anniversary['id']))['title'], 'Hari jadi');

    await tap(find.textContaining(RegExp(r'^Hari jadi ke-\d+$')));
    await tap(find.text('Hapus tanggal'));
    expect(find.text('Hapus Hari jadi?'), findsOneWidget);
    await tap(find.widgetWithText(TextButton, 'Hapus'));
    await net();
    expect((await serverRows('special_dates')).where((row) => row['id'] == anniversary['id']), isEmpty);
    expect(find.text('Bersama sejak 1 Feb 2023'), findsNothing);

    await asPartner(() async {
      await partner.syncNow();
      expect((await partner.account.dates.watchAll().first).map((date) => date.id), isNot(contains(anniversary['id'])));
    });

    // ---------------------------------------------------------------- perjalanan (v0.2)

    step('Perjalanan baru dari tab Liburan: checklistnya ikut dibuat');
    await go(Routes.home);
    await tap(find.text('Liburan').last);
    expect(
      find.text('Belum ada rencana liburan. Buat perjalanan, lalu siapkan checklistnya bersama pasangan.'),
      findsOneWidget,
    );
    await tap(find.widgetWithText(TextButton, 'Buat perjalanan'));
    await tester.enterText(field('Apa nama perjalanannya?'), 'Liburan ke Bali');
    await tester.enterText(field('Ke mana?'), 'Bali');
    await tap(find.text('Pilih tanggal'));
    await tap(find.text('OKE'));
    await tap(find.widgetWithText(FilledButton, 'Simpan'));
    await net();

    final trip = await serverRow('trips', (row) => row['title'] == 'Liburan ke Bali');
    final tripId = trip['id'] as String;
    expect(trip['destination'], 'Bali');
    expect(trip['start_date'], today());
    expect(trip['end_date'], isNull);
    expect(trip['space_id'], sharedGoal['space_id']);
    final checklist = await serverRow('task_lists', (row) => row['trip_id'] == tripId);
    expect(checklist['name'], 'Persiapan Liburan ke Bali');
    expect(container.read(routerProvider).state.uri.path, Routes.trip(tripId));
    // Berangkat hari ini dan hanya sehari.
    expect(find.text('Sedang berlangsung'), findsOneWidget);

    step('Checklist: dua item dicatat beruntun, satu dicentang');
    await tap(find.widgetWithText(TextButton, 'Tambah persiapan'));
    await tester.enterText(find.byType(TextField), 'Beli sunscreen');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await net();
    await tester.enterText(find.byType(TextField), 'Tukar uang');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await net();
    expect(find.text('0 dari 2 beres'), findsOneWidget);
    final items = (await serverRows('tasks')).where((row) => row['task_list_id'] == checklist['id']).toList();
    expect(items.map((row) => row['title']), unorderedEquals(['Beli sunscreen', 'Tukar uang']));

    await tap(find.bySemanticsLabel('Tandai selesai: Beli sunscreen'));
    await advance(const Duration(seconds: 6));
    expect((await serverRow('tasks', (row) => row['title'] == 'Beli sunscreen'))['completed_at'], isNotNull);

    step('Pasangan menerima perjalanan dan checklistnya, lalu mencentang item kedua');
    await asPartner(() async {
      await partner.syncNow();
      final received = (await partner.account.trips.watchAll().first).singleWhere((row) => row.id == tripId);
      expect(received.title, 'Liburan ke Bali');
      final checklists = await partner.account.store.checklistsOf(tripId);
      expect(checklists.single.id, checklist['id']);
      final exchange = (await partner.account.store.tasks()).singleWhere((row) => row.title == 'Tukar uang');
      expect(exchange.taskListId, checklist['id']);
      await partner.account.tasks.complete(exchange.id);
      await partner.syncNow();
    });
    await pullToRefresh();
    expect(find.text('2 dari 2 beres'), findsOneWidget);
    expect(find.text('Persiapan beres semua. Selamat berlibur!'), findsOneWidget);

    step('Dana: target bersama ditautkan ke perjalanan');
    await tap(find.byTooltip('Kembali'));
    await tap(find.text('Pilih target'));
    await tap(find.text('Dana Darurat'));
    await net();
    expect((await serverRow('trips', (row) => row['id'] == tripId))['savings_goal_id'], sharedGoal['id']);
    expect(find.text('Dana Darurat'), findsOneWidget);

    step('Ubah judul: nama checklist di server ikut berubah');
    await tap(find.byTooltip('Opsi lainnya'));
    await tap(find.text('Ubah'));
    await tester.enterText(field('Apa nama perjalanannya?'), 'Liburan ke Bali dan Lombok');
    await tap(find.widgetWithText(FilledButton, 'Simpan'));
    await net();
    expect((await serverRow('trips', (row) => row['id'] == tripId))['title'], 'Liburan ke Bali dan Lombok');
    expect(
      (await serverRow('task_lists', (row) => row['id'] == checklist['id']))['name'],
      'Persiapan Liburan ke Bali dan Lombok',
    );

    step('Beranda: kartu Persiapan liburan; item checklist tidak masuk tab Tugas');
    await go(Routes.home);
    expect(find.text('2 dari 2'), findsOneWidget);
    expect(find.text('Persiapan Liburan ke Bali dan Lombok'), findsOneWidget);
    await go(Routes.tasks);
    expect(find.text('Tukar uang'), findsNothing);

    step('Pengingat perjalanan dimatikan dari tab Liburan');
    await go(Routes.trips);
    await tap(find.text('Ingatkan sebelum berangkat'));
    await net();
    profile = (await server('/me'))['data'] as Map<String, dynamic>;
    expect((profile['notification_prefs'] as Map<String, dynamic>)['trip_reminders'], isFalse);

    step('Pengingat setor: tiap Jumat, sampai ke HP pasangan, lalu dimatikan');
    await go(Routes.goal(sharedGoal['id'] as String));
    await tap(find.text('Ingatkan setor'));
    await tap(find.text('Jum'));
    await tap(find.widgetWithText(FilledButton, 'Simpan'));
    await net();
    var remindedGoal = await serverRow('savings_goals', (row) => row['id'] == sharedGoal['id']);
    expect((remindedGoal['reminder_frequency'], remindedGoal['reminder_day']), ('weekly', 5));
    expect(find.text('Ingatkan setor tiap Jumat'), findsOneWidget);
    await asPartner(() async {
      await partner.syncNow();
      final goals = await partner.account.savings.watchGoals().first;
      expect(goals.singleWhere((row) => row.id == sharedGoal['id']).reminderDay, 5);
    });

    await tap(find.byType(Switch));
    await net();
    remindedGoal = await serverRow('savings_goals', (row) => row['id'] == sharedGoal['id']);
    expect((remindedGoal['reminder_frequency'], remindedGoal['reminder_day']), (null, null));

    step('Hapus perjalanan: checklist dan isinya ikut terhapus di server dan di HP pasangan');
    await go(Routes.trip(tripId));
    await tap(find.byTooltip('Opsi lainnya'));
    await tap(find.text('Hapus'));
    expect(find.text('Checklist persiapannya (2 item) ikut terhapus.'), findsOneWidget);
    await tap(find.widgetWithText(TextButton, 'Hapus'));
    await net();
    expect(container.read(routerProvider).state.uri.path, Routes.trips);
    expect((await serverRows('trips')).where((row) => row['id'] == tripId), isEmpty);
    expect((await serverRows('task_lists')).where((row) => row['id'] == checklist['id']), isEmpty);
    expect((await serverRows('tasks')).where((row) => row['task_list_id'] == checklist['id']), isEmpty);
    await asPartner(() async {
      await partner.syncNow();
      expect((await partner.account.trips.watchAll().first).where((row) => row.id == tripId), isEmpty);
    });

    // ---------------------------------------------------------------- tugas berulang (v1.0)

    step('Tugas berulang dari tambah cepat: tiap hari, mulai hari ini');
    await go(Routes.home);
    await tap(find.byType(FloatingActionButton));
    await tester.enterText(field('Mau mengerjakan apa?'), 'Siram tanaman');
    await tap(find.text('Ulangi'));
    await tap(find.text('Harian'));
    await tap(find.widgetWithText(FilledButton, 'Simpan').last);
    expect(find.widgetWithText(InkWell, 'Tiap hari'), findsOneWidget);
    await tap(find.widgetWithText(FilledButton, 'Simpan'));
    await net();

    final watering = await serverRow('tasks', (row) => row['title'] == 'Siram tanaman');
    final wateringId = watering['id'] as String;
    expect((watering['due_date'], watering['repeat_frequency'], watering['repeat_interval']), (today(), 'daily', 1));

    step('Centang: tugas berikutnya bertenggat besok muncul dari balasan server');
    await go(Routes.tasks);
    await tap(find.bySemanticsLabel('Tandai selesai: Siram tanaman'));
    expect(find.text('Tugas selesai. Yang berikutnya muncul setelah tersimpan di server.'), findsOneWidget);
    await advance(const Duration(seconds: 6));
    final wateringNext = await serverRow('tasks', (row) => row['title'] == 'Siram tanaman' && row['id'] != wateringId);
    expect((wateringNext['due_date'], wateringNext['completed_at']), (addDays(today(), 1), null));
    expect(find.bySemanticsLabel('Tandai selesai: Siram tanaman'), findsOneWidget);
    expect(find.textContaining('Besok'), findsWidgets);

    step('Batal selesai: tugas berikutnya yang belum disentuh ikut terhapus');
    await go(Routes.task(wateringId));
    await tap(find.bySemanticsLabel('Batalkan selesai: Siram tanaman'));
    await advance(const Duration(seconds: 6));
    expect((await serverRows('tasks')).where((row) => row['id'] == wateringNext['id']), isEmpty);
    expect((await serverRow('tasks', (row) => row['id'] == wateringId))['completed_at'], isNull);
    await go(Routes.tasks);
    expect(find.bySemanticsLabel('Tandai selesai: Siram tanaman'), findsOneWidget);

    // ---------------------------------------------------------------- kenangan (v0.3)
    // Foto tidak diunggah di sini: API lokal tidak punya kunci R2.

    step('Kenangan baru dari tab Kenangan, tanpa foto');
    await go(Routes.home);
    await tap(find.text('Kenangan').last);
    expect(
      find.text('Belum ada kenangan. Simpan tempat yang pernah kalian datangi, lengkap dengan foto dan ceritanya.'),
      findsOneWidget,
    );
    await tap(find.widgetWithText(TextButton, 'Kenangan baru'));
    await tester.enterText(field('Mau dikenang sebagai apa?'), 'Makan malam pertama');
    await tester.enterText(field('Di mana?'), 'Warung Bu Ani');
    await tester.enterText(field('Ceritanya?'), 'Hujan deras, tapi sotonya enak.');
    await tap(find.widgetWithText(FilledButton, 'Simpan'));
    await net();

    final dinner = await serverRow('memories', (row) => row['title'] == 'Makan malam pertama');
    final dinnerId = dinner['id'] as String;
    expect(
      (dinner['place_name'], dinner['visited_on'], dinner['story'], dinner['space_id'], dinner['trip_id']),
      ('Warung Bu Ani', today(), 'Hujan deras, tapi sotonya enak.', sharedGoal['space_id'], null),
    );
    expect(container.read(routerProvider).state.uri.path, Routes.memory(dinnerId));

    step('Pasangan menerima kenangan, lalu mengubah tempatnya');
    await asPartner(() async {
      await partner.syncNow();
      final received = (await partner.account.memories.watchAll().first).singleWhere((row) => row.id == dinnerId);
      expect(received.story, 'Hujan deras, tapi sotonya enak.');
      await partner.account.memories.edit(
        dinnerId,
        title: received.title,
        placeName: 'Warung Bu Ani, Bandung',
        visitedOn: received.visitedOn,
        story: received.story,
      );
      await partner.syncNow();
    });
    await pullToRefresh();
    expect(find.text('Warung Bu Ani, Bandung'), findsOneWidget);

    step('Simpan jadi kenangan dari perjalanan pasangan yang sudah selesai');
    final pastStart = addDays(today(), -30);
    final pastTripId = await asPartner(() async {
      final space = await partner.sharedSpace();
      final made = await partner.account.trips.create(
        spaceId: space.id,
        title: 'Pangandaran',
        destination: 'Pantai Pangandaran',
        startDate: pastStart,
        endDate: addDays(pastStart, 2),
      );
      await partner.syncNow();
      return made.id;
    });
    await go(Routes.trips);
    await pullToRefresh();
    await tap(find.textContaining('Sudah selesai ('));
    await tap(find.text('Simpan jadi kenangan'));
    expect(find.widgetWithText(TextField, 'Pangandaran'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Pantai Pangandaran'), findsOneWidget);
    await tap(find.widgetWithText(FilledButton, 'Simpan'));
    await net();

    final fromTrip = await serverRow('memories', (row) => row['trip_id'] == pastTripId);
    final fromTripId = fromTrip['id'] as String;
    expect(
      (fromTrip['title'], fromTrip['place_name'], fromTrip['visited_on']),
      ('Pangandaran', 'Pantai Pangandaran', pastStart),
    );
    expect(find.text('Dari perjalanan Pangandaran'), findsOneWidget);

    step('Hapus kenangan tanpa foto: Urungkan dulu, lalu hapus sungguhan');
    await tap(find.byTooltip('Opsi lainnya'));
    await tap(find.text('Hapus'));
    expect(container.read(routerProvider).state.uri.path, Routes.memories);
    expect(find.text('Kenangan dihapus.'), findsOneWidget);
    await tap(find.text('Urungkan'));
    expect(find.text('Pangandaran'), findsOneWidget);

    await go(Routes.memory(fromTripId));
    await tap(find.byTooltip('Opsi lainnya'));
    await tap(find.text('Hapus'));
    await advance(const Duration(seconds: 6));
    expect((await serverRows('memories')).where((row) => row['id'] == fromTripId), isEmpty);
    await asPartner(() async {
      await partner.syncNow();
      final memories = await partner.account.memories.watchAll().first;
      expect(memories.map((row) => row.id), [dinnerId]);
    });

    // ---------------------------------------------------------------- v1.x

    step('Cari: kenangan ditemukan dari ceritanya');
    await go(Routes.home);
    await tap(find.byTooltip('Cari'));
    await tester.enterText(find.byType(TextField), 'soto');
    await net();
    expect(find.textContaining('sotonya enak', findRichText: true), findsOneWidget);
    await tap(find.text('Makan malam pertama', findRichText: true));
    expect(container.read(routerProvider).state.uri.path, Routes.memory(dinnerId));

    step('Setahun lalu, hari ini: kenangan pasangan dari tanggal yang sama tahun lalu');
    final lastYear = '${int.parse(today().substring(0, 4)) - 1}${today().substring(4)}';
    // 29 Februari tidak ada di tahun lalu; langkah ini dilewati di hari itu.
    if (!lastYear.endsWith('02-29')) {
      await asPartner(() async {
        final space = await partner.sharedSpace();
        await partner.account.memories.create(spaceId: space.id, title: 'Piknik tahun lalu', visitedOn: lastYear);
        await partner.syncNow();
      });
      await go(Routes.home);
      await pullToRefresh();
      expect(find.text('Setahun lalu, hari ini'), findsOneWidget);
      expect(find.text('Piknik tahun lalu'), findsOneWidget);
    }

    step('Sinkron langsung: tugas dari pasangan muncul tanpa menyegarkan, juga di widget');
    await go(Routes.home);
    await asPartner(() async {
      final space = await partner.sharedSpace();
      final lists = await partner.account.lists.watchAll().first;
      final list = lists.firstWhere((row) => row.spaceId == space.id && row.isRegularActive);
      await partner.account.tasks.create(list: list, title: 'Jemput paket', dueDate: today());
      await partner.syncNow();
    });
    // Tes ini jauh lebih rapat dari pemakaian sungguhan dan sudah dekat batas server 120 request
    // per menit per akun; tunggu jendelanya berganti supaya sync berkala tidak dibalas 429.
    await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 61)));
    await advance(liveSyncInterval);
    expect(find.text('Jemput paket'), findsOneWidget);
    expect(widgetSnapshots.last['signed_in'], isTrue);
    expect([for (final task in widgetSnapshots.last['tasks'] as List) task['title']], contains('Jemput paket'));

    // ---------------------------------------------------------------- offline

    step('Offline: perubahan tersimpan di antrean, lalu terkirim saat online');
    await go(Routes.home);
    transport.offline = true;
    await tap(find.byType(FloatingActionButton));
    await tester.enterText(find.byType(TextField), 'Dibuat saat offline');
    await tap(find.widgetWithText(FilledButton, 'Simpan'));
    await net();
    expect(find.text('Dibuat saat offline'), findsOneWidget);
    expect(find.text('Sedang offline. Perubahanmu aman dan dikirim saat online.'), findsOneWidget);
    expect(await container.read(accountProvider)!.outbox.pendingCount(), 1);

    transport.offline = false;
    await pullToRefresh();
    expect(find.text('Sedang offline. Perubahanmu aman dan dikirim saat online.'), findsNothing);
    expect(await container.read(accountProvider)!.outbox.pendingCount(), 0);
    expect((await serverRows('tasks')).where((row) => row['title'] == 'Dibuat saat offline'), hasLength(1));

    step('Hapus target dengan konfirmasi');
    await go(Routes.savings);
    await tap(find.text('Dana Liburan'));
    await tap(find.byTooltip('Opsi lainnya'));
    await tap(find.text('Hapus'));
    expect(find.text('Hapus target Dana Liburan?'), findsOneWidget);
    expect(find.text('Target ini belum punya setoran.'), findsOneWidget);
    await tap(find.widgetWithText(TextButton, 'Hapus'));
    await net();
    expect((await serverRows('savings_goals')).where((row) => row['id'] == goalId), isEmpty);
    expect(find.text('Dana Liburan'), findsNothing);
    expect(find.text('Dana Darurat'), findsOneWidget);

    // ---------------------------------------------------------------- keluar dan masuk lagi

    step('Keluar');
    await go(Routes.settings);
    // Tombol Keluar ada di paling bawah; daftar baru membangunnya setelah digulir.
    await tester.scrollUntilVisible(
      find.widgetWithText(OutlinedButton, 'Keluar'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tap(find.widgetWithText(OutlinedButton, 'Keluar'));
    expect(find.text('Keluar dari akun ini?'), findsOneWidget);
    expect(find.text('Kamu bisa masuk lagi kapan saja.'), findsOneWidget);
    final oldToken = container.read(sessionProvider).token!;
    await tap(find.widgetWithText(TextButton, 'Keluar'));
    await net();
    expect(find.text('Senang melihatmu lagi.'), findsOneWidget);
    expect(storage.values.containsKey(StorageKeys.token), isFalse);
    expect(push.tokenDeleted, isTrue);
    // Widget layar utama tidak lagi menampilkan tugas.
    expect(widgetSnapshots.last, {'signed_in': false});

    // Token lama sudah dicabut server.
    final revoked = DioApiTransport(baseUrl: baseUrl, token: () => oldToken);
    final rejected = await tester.runAsync(() async {
      try {
        await revoked.send('GET', '/me');
        return null;
      } on ApiError catch (error) {
        return error.code;
      }
    });
    expect(rejected, ApiErrorCode.unauthenticated);

    step('Daftar dengan email yang sudah terdaftar: pesan server tampil di isian Email');
    await tap(find.widgetWithText(TextButton, 'Daftar'));
    await tester.enterText(field('Nama panggilan'), 'Orang Lain');
    await tester.enterText(field('Email'), email);
    await tester.enterText(field('Kata sandi'), password);
    await tap(find.widgetWithText(FilledButton, 'Daftar'));
    await net();
    expect(find.text('Buat akun untuk mulai mencatat berdua.'), findsOneWidget);
    expect(tester.widget<TextField>(field('Email')).decoration!.errorText, isNotEmpty);
    await tap(find.widgetWithText(TextButton, 'Masuk'));

    step('Salah kata sandi: pesan dari server');
    await tester.enterText(field('Email'), email);
    await tester.enterText(field('Kata sandi'), 'salah-sandi-123');
    await tap(find.widgetWithText(FilledButton, 'Masuk'));
    await net();
    expect(find.text('Email atau kata sandi salah.'), findsOneWidget);

    step('Masuk lagi: langsung ke Beranda dengan data dari cache dan sync lanjutan');
    await tester.enterText(field('Kata sandi'), password);
    await tap(find.widgetWithText(FilledButton, 'Masuk'));
    await net();
    expect(find.text('Tugas hari ini'), findsOneWidget);
    expect(find.text('Beli galon'), findsOneWidget);
    expect(find.text('Dibuat saat offline'), findsOneWidget);
    // Database akun ini sudah punya kursor, jadi sync-nya melanjutkan, bukan penuh.
    expect(await container.read(accountProvider)!.sync.hasSynced, isTrue);

    // ---------------------------------------------------------------- selesai

    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() async {
      await partner.account.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      try {
        dir.deleteSync(recursive: true);
      } on FileSystemException {
        // File database masih dipegang Windows; folder sementara dibersihkan sistem.
      }
    });
    semantics.dispose();
  }, skip: skipReason != null);
}
