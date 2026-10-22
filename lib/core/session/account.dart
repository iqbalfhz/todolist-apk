import '../../features/auth/data/profile_repository.dart';
import '../../features/savings/data/savings_repository.dart';
import '../../features/spaces/data/space_repository.dart';
import '../../features/special_dates/data/special_date_repository.dart';
import '../../features/tasks/data/task_list_repository.dart';
import '../../features/tasks/data/task_repository.dart';
import '../api/api_transport.dart';
import '../database/app_database.dart';
import '../database/local_store.dart';
import '../database/local_writer.dart';
import '../queue/outbox.dart';
import '../sync/row_applier.dart';
import '../sync/sync_engine.dart';

/// Semua yang terikat pada satu akun yang sedang masuk: database lokal, antrean,
/// sync, dan repository-nya. Saat akun keluar, semuanya ditutup bersama; isi
/// database (termasuk antrean) tetap tersimpan untuk akun itu.
class Account {
  Account({
    required this.userId,
    required this.db,
    required ApiTransport api,
    DateTime Function()? now,
    TimerFactory? createTimer,
    bool autoFlush = true,
  }) {
    store = LocalStore(db);
    applier = RowApplier(store);
    outbox = Outbox(store: store, api: api, applier: applier, now: now, createTimer: createTimer, autoFlush: autoFlush);
    sync = SyncEngine(store: store, api: api, outbox: outbox, applier: applier, createTimer: createTimer);

    final writer = LocalWriter(store: store, outbox: outbox, now: now);
    tasks = TaskRepository(writer: writer, userId: userId);
    lists = TaskListRepository(writer: writer, userId: userId);
    savings = SavingsRepository(writer: writer, userId: userId);
    dates = SpecialDateRepository(writer: writer, userId: userId);
    profile = ProfileRepository(writer: writer, api: api, applier: applier, userId: userId);
    spaces = SpaceRepository(store: store, api: api, applier: applier);
  }

  final String userId;
  final AppDatabase db;

  late final LocalStore store;
  late final RowApplier applier;
  late final Outbox outbox;
  late final SyncEngine sync;

  late final TaskRepository tasks;
  late final TaskListRepository lists;
  late final SavingsRepository savings;
  late final SpecialDateRepository dates;
  late final ProfileRepository profile;
  late final SpaceRepository spaces;

  bool _disposed = false;

  /// Aman dipanggil lebih dari sekali.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    outbox.dispose();
    sync.dispose();
    await db.close();
  }
}
