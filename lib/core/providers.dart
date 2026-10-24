import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/auth/domain/user.dart';
import '../features/memories/domain/memory.dart';
import '../features/memories/domain/memory_photo.dart';
import '../features/savings/domain/savings_entry.dart';
import '../features/savings/domain/savings_goal.dart';
import '../features/spaces/domain/space.dart';
import '../features/special_dates/domain/special_date.dart';
import '../features/tasks/domain/task.dart';
import '../features/tasks/domain/task_list.dart';
import '../features/trips/domain/trip.dart';
import 'api/api_transport.dart';
import 'config/env.dart';
import 'database/app_database.dart';
import 'media/photo_cache.dart';
import 'media/photo_files.dart';
import 'media/photo_picker.dart';
import 'session/account.dart';
import 'session/session.dart';
import 'time/space_clock.dart';

/// Keadaan hubungan ke server, dipakai banner offline.
class Connectivity {
  const Connectivity({this.offline = false, this.needsAppUpdate = false});

  /// Request terakhir tidak sampai ke server (tanpa koneksi, atau server bermasalah).
  final bool offline;

  /// Server tidak mengenal endpoint yang dipanggil: versi app tertinggal.
  final bool needsAppUpdate;
}

class ConnectivityController extends Notifier<Connectivity> {
  @override
  Connectivity build() => const Connectivity();

  void report({required bool reachable}) {
    if (state.offline == !reachable) return;
    state = Connectivity(offline: !reachable, needsAppUpdate: state.needsAppUpdate);
  }

  void flagAppUpdate() {
    if (state.needsAppUpdate) return;
    state = Connectivity(offline: state.offline, needsAppUpdate: true);
  }
}

final connectivityProvider = NotifierProvider<ConnectivityController, Connectivity>(ConnectivityController.new);

/// Klien HTTP ke API. Ditimpa di tes dengan API palsu.
final httpTransportProvider = Provider<ApiTransport>(
  (ref) => DioApiTransport(baseUrl: Env.apiBaseUrl, token: () => ref.read(sessionProvider).token),
);

/// Klien API yang dipakai seluruh app: [httpTransportProvider] ditambah pengamatan
/// untuk banner offline dan sesi yang berakhir.
final apiTransportProvider = Provider<ApiTransport>((ref) {
  return ObservedTransport(
    ref.watch(httpTransportProvider),
    // 401 hanya berarti token tidak berlaku lagi, jadi selalu aman dianggap "keluar".
    onUnauthenticated: () => unawaited(ref.read(sessionProvider.notifier).signOut(expired: true)),
    onReachability: (reachable) => ref.read(connectivityProvider.notifier).report(reachable: reachable),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(apiTransportProvider)));

/// Cara membuka akun untuk sebuah ID pengguna. Ditimpa di tes dengan database di memori.
final accountFactoryProvider = Provider<Account Function(String userId)>((ref) {
  final api = ref.watch(apiTransportProvider);
  return (userId) => Account(
    userId: userId,
    db: AppDatabase.forAccount(userId),
    api: api,
    photoCache: DevicePhotoCache.instance,
    photoFiles: PhotoFiles.forAccount(userId, DevicePhotoCache.instance),
  );
});

/// Akun yang sedang masuk, atau `null`. Akun lain di HP yang sama membuka database yang berbeda.
final accountProvider = Provider<Account?>((ref) {
  final userId = ref.watch(sessionProvider.select((session) => session.userId));
  if (userId == null) return null;

  final account = ref.watch(accountFactoryProvider)(userId);
  ref.onDispose(account.dispose);
  return account;
});

final spaceClockProvider = Provider<SpaceClock>((ref) => SpaceClock());

/// Waktu sekarang, diperbarui berkala supaya "hari ini" dan "Terlewat" ikut berganti
/// tanpa menunggu app dibuka ulang.
class NowTicker extends Notifier<DateTime> {
  static const Duration interval = Duration(seconds: 30);

  @override
  DateTime build() {
    final clock = ref.watch(spaceClockProvider);
    final timer = Timer.periodic(interval, (_) => state = clock.now());
    ref.onDispose(timer.cancel);
    return clock.now();
  }
}

final nowProvider = NotifierProvider<NowTicker, DateTime>(NowTicker.new);

// ------------------------------------------------------------------ data dari cache lokal

final profileProvider = StreamProvider<User?>(
  (ref) => ref.watch(accountProvider)?.profile.watch() ?? Stream.value(null),
);

final spacesProvider = StreamProvider<List<Space>>(
  (ref) => ref.watch(accountProvider)?.spaces.watchAll() ?? Stream.value(const []),
);

/// Daftar yang belum dihapus, termasuk yang diarsipkan.
final taskListsProvider = StreamProvider<List<TaskList>>(
  (ref) => ref.watch(accountProvider)?.lists.watchAll() ?? Stream.value(const []),
);

/// Tugas yang belum dihapus, termasuk yang daftarnya diarsipkan.
final tasksProvider = StreamProvider<List<Task>>(
  (ref) => ref.watch(accountProvider)?.tasks.watchAll() ?? Stream.value(const []),
);

final goalsProvider = StreamProvider<List<SavingsGoal>>(
  (ref) => ref.watch(accountProvider)?.savings.watchGoals() ?? Stream.value(const []),
);

final entriesProvider = StreamProvider<List<SavingsEntry>>(
  (ref) => ref.watch(accountProvider)?.savings.watchEntries() ?? Stream.value(const []),
);

/// Tanggal penting yang belum dihapus (v0.2).
final specialDatesProvider = StreamProvider<List<SpecialDate>>(
  (ref) => ref.watch(accountProvider)?.dates.watchAll() ?? Stream.value(const []),
);

/// Perjalanan yang belum dihapus (v0.2).
final tripsProvider = StreamProvider<List<Trip>>(
  (ref) => ref.watch(accountProvider)?.trips.watchAll() ?? Stream.value(const []),
);

/// Kenangan yang belum dihapus (v0.3).
final memoriesProvider = StreamProvider<List<Memory>>(
  (ref) => ref.watch(accountProvider)?.memories.watchAll() ?? Stream.value(const []),
);

/// Foto kenangan yang belum dihapus, urut `position` (v0.3).
final memoryPhotosProvider = StreamProvider<List<MemoryPhoto>>(
  (ref) => ref.watch(accountProvider)?.memories.watchPhotos() ?? Stream.value(const []),
);

/// Memilih dan menyiapkan foto kenangan. Ditimpa di tes dengan versi palsu.
final photoPickerProvider = Provider<PhotoPicker>((ref) => DevicePhotoPicker(ref.watch(devicePlatformProvider)));

/// Jumlah perubahan yang belum terkirim ke server.
final pendingCountProvider = StreamProvider<int>(
  (ref) => ref.watch(accountProvider)?.outbox.watchPendingCount() ?? Stream.value(0),
);
