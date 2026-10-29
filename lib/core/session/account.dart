import 'dart:io';

import '../../features/auth/data/profile_repository.dart';
import '../../features/comments/data/comment_repository.dart';
import '../../features/memories/data/memory_photo_images.dart';
import '../../features/memories/data/memory_repository.dart';
import '../../features/savings/data/savings_repository.dart';
import '../../features/spaces/data/space_repository.dart';
import '../../features/special_dates/data/special_date_repository.dart';
import '../../features/tasks/data/task_list_repository.dart';
import '../../features/tasks/data/task_repository.dart';
import '../../features/trips/data/trip_repository.dart';
import '../api/api_transport.dart';
import '../database/app_database.dart';
import '../database/local_store.dart';
import '../database/local_writer.dart';
import '../media/photo_cache.dart';
import '../media/photo_files.dart';
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
    PhotoCache photoCache = const NoPhotoCache(),
    PhotoFiles? photoFiles,
    DateTime Function()? now,
    TimerFactory? createTimer,
    bool autoFlush = true,
  }) {
    // Tanpa folder yang ditentukan (tes dan HP uji), berkas foto disimpan di folder sementara.
    final files = this.photoFiles =
        photoFiles ??
        PhotoFiles(
          directory: () async => Directory('${Directory.systemTemp.path}/denly_foto_$userId'),
          cache: photoCache,
        );

    store = LocalStore(db);
    applier = RowApplier(store);
    outbox = Outbox(
      store: store,
      api: api,
      applier: applier,
      uploads: files,
      now: now,
      createTimer: createTimer,
      autoFlush: autoFlush,
    );
    sync = SyncEngine(store: store, api: api, outbox: outbox, applier: applier, createTimer: createTimer);

    final writer = LocalWriter(store: store, outbox: outbox, now: now);
    tasks = TaskRepository(writer: writer, userId: userId);
    lists = TaskListRepository(writer: writer, userId: userId);
    savings = SavingsRepository(writer: writer, userId: userId);
    dates = SpecialDateRepository(writer: writer, userId: userId);
    trips = TripRepository(writer: writer, userId: userId);
    memories = MemoryRepository(writer: writer, api: api, applier: applier, files: files, userId: userId);
    comments = CommentRepository(writer: writer, userId: userId);
    photoImages = MemoryPhotoImages(cache: photoCache, files: files, refreshUrls: memories.refreshPhotos, now: now);
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
  late final TripRepository trips;
  late final MemoryRepository memories;

  /// Komentar dan reaksi (v1.x).
  late final CommentRepository comments;

  /// Foto kenangan yang sudah dikompres dan menunggu diunggah.
  late final PhotoFiles photoFiles;

  /// Gambar foto kenangan untuk layar, dari cache, berkas yang menunggu diunggah, atau unduhan.
  late final MemoryPhotoImages photoImages;
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
