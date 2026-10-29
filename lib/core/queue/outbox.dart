import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../api/api_error.dart';
import '../api/api_transport.dart';
import '../database/app_database.dart';
import '../database/entity_type.dart';
import '../database/local_store.dart';
import '../sync/row_applier.dart';
import 'upload_files.dart';

/// Keadaan antrean setelah satu putaran kirim.
enum FlushState {
  /// Antrean kosong.
  idle,

  /// Operasi terdepan masih menunggu tombol Urungkan.
  waitingUndo,

  /// Menunggu jeda coba ulang (tanpa koneksi, 5xx, 429, atau versi app tertinggal).
  waitingRetry,

  /// Token tidak berlaku lagi; isi antrean tetap tersimpan untuk akun ini.
  stopped,
}

/// Kejadian di antrean yang perlu diketahui lapisan lain.
sealed class OutboxEvent {
  const OutboxEvent();
}

/// Server menolak sebuah perubahan; [message] dari server dan bisa langsung ditampilkan.
class OutboxRejected extends OutboxEvent {
  const OutboxRejected(this.message);

  final String message;
}

/// Tugas dipindah ke daftar aktif pertama karena daftar asalnya dihapus atau diarsipkan.
class OutboxTaskRelocated extends OutboxEvent {
  const OutboxTaskRelocated({required this.listName});

  final String listName;
}

/// Cache lokal perlu disegarkan dari server.
class OutboxNeedsSync extends OutboxEvent {
  const OutboxNeedsSync();
}

/// Server tidak mengenal endpoint yang dipanggil: versi app dan server berbeda.
class OutboxNeedsAppUpdate extends OutboxEvent {
  const OutboxNeedsAppUpdate();
}

typedef TimerFactory = Timer Function(Duration delay, void Function() callback);

/// Antrean offline (outbox).
///
/// Aturannya dari bagian "Antrean di HP" dan tabel Error di kontrak:
/// - dikirim berurutan, satu per satu, dan ditandai "pernah dikirim" sebelum dikirim;
/// - perubahan baru hanya digabung ke operasi untuk data yang sama kalau operasi itu
///   paling akhir di antrean, belum pernah dikirim, dan tidak sedang menunggu Urungkan;
/// - selesai dan hapus tugas menjadi operasi tersendiri dengan jeda kirim 5 detik;
/// - data lokal hanya dibuang kalau balasannya JSON dengan `code` yang dikenal;
/// - foto kenangan diunggah lewat `POST` multipart, dengan berkas dari [uploads].
class Outbox {
  Outbox({
    required this.store,
    required this.api,
    RowApplier? applier,
    this.uploads,
    DateTime Function()? now,
    TimerFactory? createTimer,
    this.autoFlush = true,
  }) : applier = applier ?? RowApplier(store),
       _now = now ?? DateTime.now,
       _createTimer = createTimer ?? Timer.new;

  final LocalStore store;
  final ApiTransport api;
  final RowApplier applier;

  /// Berkas untuk operasi `POST`. Tanpa ini, operasi `POST` dibuang karena tidak bisa dikirim.
  final UploadFiles? uploads;
  final DateTime Function() _now;
  final TimerFactory _createTimer;

  /// Kirim otomatis setiap ada operasi baru. Dimatikan di tes supaya urutan bisa diatur.
  final bool autoFlush;

  /// Lama tombol Urungkan tampil; selama itu operasinya belum dikirim.
  static const Duration undoWindow = Duration(seconds: 5);

  /// Jeda coba ulang: 2, 4, 8 detik dan seterusnya, paling lama 5 menit.
  static const Duration maxBackoff = Duration(minutes: 5);

  /// Jeda untuk 429 kalau server tidak mengirim `Retry-After`.
  static const Duration defaultRetryAfter = Duration(seconds: 30);

  final StreamController<OutboxEvent> _events = StreamController.broadcast();

  /// Zone tempat antrean dibuat. Pengiriman selalu dijalankan di sini: drift merutekan
  /// kueri lewat zone, jadi pengiriman yang dipicu dari dalam transaksi pemanggil
  /// tidak boleh ikut menumpang transaksi itu.
  final Zone _zone = Zone.current;

  Stream<OutboxEvent> get events => _events.stream;

  Future<FlushState>? _running;
  bool _again = false;
  bool _stopped = false;
  bool _disposed = false;
  int _failures = 0;
  DateTime? _retryAt;
  Timer? _timer;

  /// Daftar yang sudah ditolak server untuk sebuah operasi tugas, supaya tidak dicoba lagi.
  final Map<int, Set<String>> _rejectedLists = {};

  AppDatabase get _db => store.db;

  // ---------------------------------------------------------------- memasukkan operasi

  /// `PUT`: buat data dengan ID dari HP. [payload] adalah body lengkapnya.
  Future<void> enqueueCreate(EntityType type, String id, Map<String, dynamic> payload) async {
    await _insert(type, id, 'PUT', payload: payload);
    _kick();
  }

  /// `POST` multipart: unggah berkas data baru (foto kenangan) dengan ID dari HP.
  /// [payload] berisi kolom formulirnya; berkasnya diambil dari [uploads] saat dikirim.
  Future<void> enqueueUpload(EntityType type, String id, Map<String, dynamic> payload) async {
    await _insert(type, id, 'POST', payload: payload);
    _kick();
  }

  /// `PATCH`: ubah kolom di [changes]. [before] berisi nilai kolom itu sebelum diubah.
  ///
  /// Digabung ke operasi paling akhir kalau aturan gabung terpenuhi; selain itu
  /// masuk sebagai operasi baru di ujung antrean.
  Future<void> enqueueUpdate(
    EntityType type,
    String id,
    Map<String, dynamic> changes,
    Map<String, dynamic> before,
  ) async {
    if (changes.isEmpty) return;

    await store.transaction(() async {
      final last = await _last();

      if (last != null && _canMergeInto(last, type, id)) {
        await (_db.update(_db.outboxOps)..where((t) => t.id.equals(last.id))).write(
          OutboxOpsCompanion(
            payload: Value(jsonEncode({..._decode(last.payload), ...changes})),
            // Nilai "sebelum diubah" yang disimpan adalah yang paling awal.
            before: Value(jsonEncode({...before, ..._decode(last.before)})),
          ),
        );
        return;
      }

      await _insert(type, id, 'PATCH', payload: changes, before: before);
    });
    _kick();
  }

  /// `PATCH` tersendiri yang menunggu [undoWindow] sebelum dikirim (menyelesaikan tugas).
  /// Mengembalikan ID operasi untuk [undo].
  Future<int> enqueueUndoableUpdate(
    EntityType type,
    String id,
    Map<String, dynamic> changes,
    Map<String, dynamic> before,
  ) async {
    final opId = await _insert(type, id, 'PATCH', payload: changes, before: before, held: true);
    _kick();
    return opId;
  }

  /// `DELETE`. Dengan [undoable], operasinya menunggu [undoWindow] sebelum dikirim.
  /// Mengembalikan ID operasi untuk [undo].
  Future<int> enqueueDelete(
    EntityType type,
    String id, {
    Map<String, dynamic> before = const {},
    bool undoable = false,
  }) async {
    final opId = await _insert(type, id, 'DELETE', before: before, held: undoable);
    _kick();
    return opId;
  }

  /// Batalkan unggahan [ids] yang belum pernah dikirim, misalnya foto yang dihapus bersama
  /// kenangannya: operasinya (termasuk perubahan sesudahnya), barisnya, dan berkasnya dibuang.
  /// Unggahan yang sudah pernah dikirim dibiarkan; server menghapusnya bersama induknya.
  Future<void> cancelUploads(EntityType type, Iterable<String> ids) async {
    final wanted = ids.toSet();
    if (wanted.isEmpty) return;

    final cancelled = await store.transaction(() async {
      final ops = await (_db.select(
        _db.outboxOps,
      )..where((t) => t.entityType.equals(type.name) & t.entityId.isIn(wanted) & t.attempted.equals(false))).get();
      final unsent = {
        for (final op in ops)
          if (op.method == 'POST') op.entityId,
      };

      for (final op in ops) {
        if (unsent.contains(op.entityId)) await _delete(op.id);
      }
      for (final id in unsent) {
        await store.remove(type, id);
      }
      return unsent;
    });

    for (final id in cancelled) {
      await _forgetFile(type, id);
    }
  }

  /// Urungkan: hapus operasi itu saja dan pulihkan nilai sebelumnya, jadi pasangan
  /// tidak menerima notifikasi yang dibatalkan. `false` kalau operasinya sudah dikirim.
  Future<bool> undo(int opId) async {
    final undone = await store.transaction(() async {
      final op = await (_db.select(_db.outboxOps)..where((t) => t.id.equals(opId))).getSingleOrNull();
      if (op == null || op.attempted) return false;

      final before = _decode(op.before);
      if (before.isNotEmpty) await store.patch(EntityType.byName(op.entityType), op.entityId, before);
      await _delete(op.id);
      return true;
    });
    _kick();
    return undone;
  }

  /// Operasi tertunda paling akhir untuk sebuah data, kalau masih bisa diurungkan.
  Future<OutboxRow?> heldOpFor(EntityType type, String id) async {
    final last =
        await (_db.select(_db.outboxOps)
              ..where((t) => t.entityType.equals(type.name) & t.entityId.equals(id))
              ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)])
              ..limit(1))
            .getSingleOrNull();
    return last != null && !last.attempted && _isHeld(last) ? last : null;
  }

  Stream<int> watchPendingCount() {
    final count = _db.outboxOps.id.count();
    return (_db.selectOnly(_db.outboxOps)..addColumns([count])).watchSingle().map((row) => row.read(count) ?? 0);
  }

  Future<int> pendingCount() async {
    final count = _db.outboxOps.id.count();
    final row = await (_db.selectOnly(_db.outboxOps)..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  // ---------------------------------------------------------------- mengirim

  /// Kirim semua operasi yang bisa dikirim saat ini, lalu berhenti.
  ///
  /// [retryNow] mengabaikan jeda coba ulang yang sedang berjalan (app kembali aktif
  /// atau pengguna menarik layar untuk menyegarkan).
  Future<FlushState> flush({bool retryNow = false}) {
    if (retryNow) _retryAt = null;

    final running = _running;
    if (running != null) {
      _again = true;
      return running;
    }

    return _running = _zone.run(_run).whenComplete(() => _running = null);
  }

  Future<FlushState> _run() async {
    FlushState state;
    do {
      _again = false;
      try {
        state = await _drain();
      } catch (_) {
        // Database ditutup saat akun keluar di tengah pengiriman.
        if (_disposed) return FlushState.stopped;
        rethrow;
      }
    } while (_again && !_disposed);
    return state;
  }

  Future<FlushState> _drain() async {
    while (true) {
      if (_stopped || _disposed) return FlushState.stopped;

      final head =
          await (_db.select(_db.outboxOps)
                ..orderBy([(t) => OrderingTerm(expression: t.id)])
                ..limit(1))
              .getSingleOrNull();

      if (head == null) {
        _timer?.cancel();
        return FlushState.idle;
      }

      final now = _now();

      if (_isHeld(head)) {
        _wakeAt(DateTime.fromMillisecondsSinceEpoch(head.holdUntil!));
        return FlushState.waitingUndo;
      }

      final retryAt = _retryAt;
      if (retryAt != null && retryAt.isAfter(now)) {
        _wakeAt(retryAt);
        return FlushState.waitingRetry;
      }

      final op = await _claim(head.id);
      if (op == null) continue;

      try {
        ApiUpload? upload;
        if (op.method == 'POST') {
          upload = await uploads?.fileFor(op);
          if (upload == null) {
            await _dropUnsendable(op);
            continue;
          }
        }

        final response = await api.send(
          op.method,
          _pathOf(op),
          body: op.method == 'DELETE' ? null : _decode(op.payload),
          upload: upload,
        );
        await _onSuccess(op, response);
        _failures = 0;
        _retryAt = null;
      } on ApiError catch (error) {
        final stopWith = await _onApiError(op, error);
        if (stopWith != null) return stopWith;
      } on NetworkFailure {
        _scheduleRetry();
        return FlushState.waitingRetry;
      }
    }
  }

  /// Tandai "pernah dikirim" lalu baca ulang isinya dalam satu transaksi, supaya
  /// perubahan yang sedang digabung tidak tertinggal dari kiriman ini.
  Future<OutboxRow?> _claim(int opId) => store.transaction(() async {
    final updated = await (_db.update(
      _db.outboxOps,
    )..where((t) => t.id.equals(opId))).write(const OutboxOpsCompanion(attempted: Value(true), holdUntil: Value(null)));
    if (updated == 0) return null;
    return (_db.select(_db.outboxOps)..where((t) => t.id.equals(opId))).getSingleOrNull();
  });

  Future<void> _onSuccess(OutboxRow op, ApiResponse response) async {
    final type = EntityType.byName(op.entityType);

    await store.transaction(() async {
      // Tugas berikutnya yang tertaut sebelum balasan ini, untuk Urungkan tugas berulang.
      final before = type == EntityType.task && op.method != 'DELETE' ? await store.read(type, op.entityId) : null;
      await _delete(op.id);

      // Balasan PUT (201, atau 200 kalau sudah tersimpan dari kiriman sebelumnya) dan
      // PATCH diterapkan seperti baris sync; kolom yang masih di antrean tetap dilindungi.
      if (op.method != 'DELETE' && response.body != null) {
        await applier.apply(type, response.data);
        if (type == EntityType.task) await _applyNextTask(response, previousNextId: before?['next_task_id'] as String?);
      }
    });

    // Server ikut menghapus checklist dan tugasnya bersama perjalanan. Balasan PUT checklist
    // yang dibuat offline bisa memunculkannya lagi di HP, jadi penghapusannya segera ditarik.
    if (op.method == 'DELETE' && op.entityType == EntityType.trip.name) _emit(const OutboxNeedsSync());

    // Berkas yang sudah tersimpan di server dipindah ke cache gambar. Gagal di sini tidak
    // menghentikan antrean: paling buruk, gambarnya diunduh lagi nanti.
    if (op.method == 'POST' && response.body != null) {
      try {
        await uploads?.uploaded(op, response.data);
      } on Object {
        await _forgetFile(EntityType.byName(op.entityType), op.entityId);
      }
    }
  }

  /// Balasan `PUT` dan `PATCH` tugas membawa `next_task` (v1.0): tugas berikutnya yang dibuat
  /// server saat tugas berulang selesai, diterapkan seperti baris sync. Kalau penyelesaiannya
  /// dibatalkan dan server ikut menghapus tugas berikutnya, `next_task_id` kembali kosong, jadi
  /// salinannya dihapus dari cache. Yang masih punya perubahan di antrean ditentukan balasan
  /// server untuk perubahan itu.
  Future<void> _applyNextTask(ApiResponse response, {required String? previousNextId}) async {
    final next = response.body?['next_task'];
    if (next is Map<String, dynamic>) {
      await applier.apply(EntityType.task, next);
      return;
    }

    if (previousNextId == null || response.data['next_task_id'] != null) return;
    if (await _hasOps(EntityType.task, previousNextId)) return;
    await store.remove(EntityType.task, previousNextId);
  }

  Future<bool> _hasOps(EntityType type, String id) async {
    final row =
        await (_db.select(_db.outboxOps)
              ..where((t) => t.entityType.equals(type.name) & t.entityId.equals(id))
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  /// Operasi `POST` yang berkasnya sudah tidak ada di HP tidak mungkin terkirim lagi.
  Future<void> _dropUnsendable(OutboxRow op) async {
    final type = EntityType.byName(op.entityType);
    await store.transaction(() async {
      await _delete(op.id);
      await store.remove(type, op.entityId);
    });
  }

  /// Berkas data yang dibuang dari HP tidak dibutuhkan lagi.
  Future<void> _forgetFile(EntityType type, String id) async {
    try {
      await uploads?.discard(type, id);
    } on Object {
      // Berkas yang tertinggal tidak mengganggu; dicoba lagi tidak ada gunanya.
    }
  }

  /// Tangani balasan error sesuai tabel Error di kontrak. Mengembalikan keadaan
  /// kalau pengiriman harus berhenti, atau `null` untuk lanjut ke operasi berikutnya.
  Future<FlushState?> _onApiError(OutboxRow op, ApiError error) async {
    final type = EntityType.byName(op.entityType);

    switch (error.code) {
      case ApiErrorCode.unauthenticated:
        _stopped = true;
        return FlushState.stopped;

      case ApiErrorCode.notFound || ApiErrorCode.resourceDeleted:
        await store.transaction(() async {
          await _delete(op.id);
          await store.remove(type, op.entityId);
        });
        await _forgetFile(type, op.entityId);
        return null;

      case ApiErrorCode.routeNotFound:
        _emit(const OutboxNeedsAppUpdate());
        _scheduleRetry();
        return FlushState.waitingRetry;

      case ApiErrorCode.parentDeleted || ApiErrorCode.parentArchived:
        if (type != EntityType.task) {
          // Setoran ke target, atau foto ke kenangan, yang sudah dihapus: buang dan beri tahu.
          await _discard(op, error);
          return null;
        }
        if (await _relocateTask(op)) return null;

        // Belum ada daftar aktif lain di cache; segarkan dulu, lalu coba lagi.
        _rejectedLists.remove(op.id);
        _emit(const OutboxNeedsSync());
        _scheduleRetry();
        return FlushState.waitingRetry;

      case ApiErrorCode.tooManyRequests:
        _retryAt = _now().add(error.retryAfter ?? defaultRetryAfter);
        _wakeAt(_retryAt!);
        return FlushState.waitingRetry;

      // `places_unavailable` hanya datang dari pencarian tempat, yang tidak lewat antrean; kalau
      // pun sampai di sini, perlakukan seperti gangguan server.
      case ApiErrorCode.serverError || ApiErrorCode.placesUnavailable:
        _scheduleRetry();
        return FlushState.waitingRetry;

      case ApiErrorCode.forbidden ||
          ApiErrorCode.lastList ||
          ApiErrorCode.idConflict ||
          ApiErrorCode.tripChecklist ||
          ApiErrorCode.sharedSpaceExists ||
          ApiErrorCode.validationFailed ||
          ApiErrorCode.invalidCredentials ||
          ApiErrorCode.invitationInvalid:
        await _discard(op, error);
        return null;
    }
  }

  /// Buang operasi, pakai `current`, dan tampilkan pesan.
  ///
  /// "Pakai `current`": kalau `null`, hapus versi lokal; kalau terisi, timpa versi
  /// lokal dengannya. Itu juga yang memulihkan daftar yang gagal dihapus.
  Future<void> _discard(OutboxRow op, ApiError error) async {
    final type = EntityType.byName(op.entityType);

    final removed = await store.transaction(() async {
      await _delete(op.id);

      if (error.hasCurrent) {
        final current = error.current;
        if (current == null) {
          await store.remove(type, op.entityId);
          return true;
        }
        await applier.apply(type, current, force: true);
        return false;
      }

      // Tanpa `current`: kembalikan ke keadaan sebelum operasi ini.
      if (op.method == 'PUT' || op.method == 'POST') {
        await store.remove(type, op.entityId);
        return true;
      }
      final before = _decode(op.before);
      if (before.isNotEmpty) await store.patch(type, op.entityId, before);
      return false;
    });

    if (removed) await _forgetFile(type, op.entityId);
    _emit(OutboxRejected(error.message));
  }

  /// Pindahkan tugas ke daftar aktif pertama di ruangnya, lalu biarkan operasinya dikirim ulang.
  /// Checklist perjalanan tidak dihitung sebagai daftar aktif, jadi tidak pernah menjadi tujuan.
  Future<bool> _relocateTask(OutboxRow op) async {
    final listName = await store.transaction(() async {
      final task = await store.read(EntityType.task, op.entityId);
      if (task == null) {
        await _delete(op.id);
        return '';
      }

      final payload = _decode(op.payload);
      final rejected = _rejectedLists.putIfAbsent(op.id, () => {})
        ..add((payload['task_list_id'] ?? task['task_list_id']) as String);

      final deleting = await _idsWithPendingDelete(EntityType.list);
      final target = (await store.taskLists())
          .where(
            (list) =>
                list.spaceId == task['space_id'] &&
                list.isRegularActive &&
                !rejected.contains(list.id) &&
                !deleting.contains(list.id),
          )
          .firstOrNull;
      if (target == null) return null;

      await store.patch(EntityType.task, op.entityId, {'task_list_id': target.id});
      await (_db.update(_db.outboxOps)..where((t) => t.id.equals(op.id))).write(
        OutboxOpsCompanion(payload: Value(jsonEncode({...payload, 'task_list_id': target.id}))),
      );
      return target.name;
    });

    if (listName == null) return false;
    if (listName.isNotEmpty) {
      _emit(OutboxTaskRelocated(listName: listName));
      _emit(const OutboxNeedsSync());
    }
    return true;
  }

  // ---------------------------------------------------------------- pembantu

  bool _canMergeInto(OutboxRow last, EntityType type, String id) =>
      last.entityType == type.name &&
      last.entityId == id &&
      last.method != 'DELETE' &&
      !last.attempted &&
      !_isHeld(last);

  bool _isHeld(OutboxRow op) => op.holdUntil != null && op.holdUntil! > _now().millisecondsSinceEpoch;

  Future<OutboxRow?> _last() =>
      (_db.select(_db.outboxOps)
            ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)])
            ..limit(1))
          .getSingleOrNull();

  Future<int> _insert(
    EntityType type,
    String id,
    String method, {
    Map<String, dynamic>? payload,
    Map<String, dynamic> before = const {},
    bool held = false,
  }) {
    final now = _now();
    return _db
        .into(_db.outboxOps)
        .insert(
          OutboxOpsCompanion.insert(
            entityType: type.name,
            entityId: id,
            method: method,
            payload: Value(payload == null ? null : jsonEncode(payload)),
            before: Value(before.isEmpty ? null : jsonEncode(before)),
            holdUntil: Value(held ? now.add(undoWindow).millisecondsSinceEpoch : null),
            createdAt: now.millisecondsSinceEpoch,
          ),
        );
  }

  Future<void> _delete(int opId) async {
    _rejectedLists.remove(opId);
    await (_db.delete(_db.outboxOps)..where((t) => t.id.equals(opId))).go();
  }

  Future<Set<String>> _idsWithPendingDelete(EntityType type) async {
    final rows = await (_db.select(
      _db.outboxOps,
    )..where((t) => t.entityType.equals(type.name) & t.method.equals('DELETE'))).get();
    return {for (final row in rows) row.entityId};
  }

  static Map<String, dynamic> _decode(String? json) =>
      json == null ? <String, dynamic>{} : jsonDecode(json) as Map<String, dynamic>;

  String _pathOf(OutboxRow op) {
    final type = EntityType.byName(op.entityType);
    return type == EntityType.me ? '/me' : '/${type.apiPath}/${op.entityId}';
  }

  void _scheduleRetry() {
    _failures++;
    final seconds = math.min(math.pow(2, math.min(_failures, 16)).toInt(), maxBackoff.inSeconds);
    _retryAt = _now().add(Duration(seconds: seconds));
    _wakeAt(_retryAt!);
  }

  void _wakeAt(DateTime time) {
    if (_disposed) return;
    final delay = time.difference(_now());
    _timer?.cancel();
    _timer = _createTimer(delay.isNegative ? Duration.zero : delay, _kick);
  }

  void _kick() {
    if (!autoFlush || _disposed) return;
    _zone.run(() => unawaited(flush().catchError((Object _) => FlushState.stopped)));
  }

  void _emit(OutboxEvent event) {
    if (!_events.isClosed) _events.add(event);
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    unawaited(_events.close());
  }
}
