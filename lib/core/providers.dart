import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/auth/domain/user.dart';
import '../features/savings/domain/savings_entry.dart';
import '../features/savings/domain/savings_goal.dart';
import '../features/spaces/domain/space.dart';
import '../features/tasks/domain/task.dart';
import '../features/tasks/domain/task_list.dart';
import 'api/api_transport.dart';
import 'config/env.dart';
import 'database/app_database.dart';
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

final apiTransportProvider = Provider<ApiTransport>((ref) {
  return DioApiTransport(
    baseUrl: Env.apiBaseUrl,
    token: () => ref.read(sessionProvider).token,
    // 401 hanya berarti token tidak berlaku lagi, jadi selalu aman dianggap "keluar".
    onUnauthenticated: () => unawaited(ref.read(sessionProvider.notifier).signOut(expired: true)),
    onReachability: (reachable) => ref.read(connectivityProvider.notifier).report(reachable: reachable),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(apiTransportProvider)));

/// Akun yang sedang masuk, atau `null`. Akun lain di HP yang sama membuka database yang berbeda.
final accountProvider = Provider<Account?>((ref) {
  final userId = ref.watch(sessionProvider.select((session) => session.userId));
  if (userId == null) return null;

  final account = Account(userId: userId, db: AppDatabase.forAccount(userId), api: ref.watch(apiTransportProvider));
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
  (ref) => ref.watch(accountProvider)?.profile.watch() ?? const Stream.empty(),
);

final spacesProvider = StreamProvider<List<Space>>(
  (ref) => ref.watch(accountProvider)?.spaces.watchAll() ?? const Stream.empty(),
);

/// Daftar yang belum dihapus, termasuk yang diarsipkan.
final taskListsProvider = StreamProvider<List<TaskList>>(
  (ref) => ref.watch(accountProvider)?.lists.watchAll() ?? const Stream.empty(),
);

/// Tugas yang belum dihapus, termasuk yang daftarnya diarsipkan.
final tasksProvider = StreamProvider<List<Task>>(
  (ref) => ref.watch(accountProvider)?.tasks.watchAll() ?? const Stream.empty(),
);

final goalsProvider = StreamProvider<List<SavingsGoal>>(
  (ref) => ref.watch(accountProvider)?.savings.watchGoals() ?? const Stream.empty(),
);

final entriesProvider = StreamProvider<List<SavingsEntry>>(
  (ref) => ref.watch(accountProvider)?.savings.watchEntries() ?? const Stream.empty(),
);

/// Jumlah perubahan yang belum terkirim ke server.
final pendingCountProvider = StreamProvider<int>(
  (ref) => ref.watch(accountProvider)?.outbox.watchPendingCount() ?? const Stream.empty(),
);
