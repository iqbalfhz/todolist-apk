import 'dart:async';
import 'dart:math' as math;

import '../api/api_error.dart';
import '../api/api_transport.dart';
import '../database/entity_type.dart';
import '../database/local_store.dart';
import '../queue/outbox.dart';
import 'row_applier.dart';

/// Menarik perubahan dari `GET /sync` ke cache lokal.
///
/// Aturannya dari bagian "Aturan di HP" di kontrak:
/// - hanya satu sync berjalan pada satu waktu;
/// - operasi antrean yang bisa dikirim dikirim dulu, lalu data tetap ditarik walau
///   masih ada yang menunggu jeda Urungkan atau coba ulang. Pengiriman ditunggu paling
///   lama [flushLimit], supaya unggahan foto yang panjang tidak menahan perubahan pasangan;
///   sisanya tetap berjalan di latar belakang;
/// - halaman pertama memakai `since` yang tersimpan, halaman berikutnya memakai `cursor`
///   apa adanya;
/// - tanpa `since` (sync penuh) kalau database lokal akun itu masih kosong, atau sekali
///   setelah app mengenal koleksi baru, supaya data yang dibuat pasangan selama app masih
///   versi lama ikut sampai;
/// - `server_time` disimpan setelah halaman terakhir sebagai `since` berikutnya.
class SyncEngine {
  SyncEngine({
    required this.store,
    required this.api,
    required this.outbox,
    RowApplier? applier,
    TimerFactory? createTimer,
  }) : applier = applier ?? RowApplier(store),
       _createTimer = createTimer ?? Timer.new;

  final LocalStore store;
  final ApiTransport api;
  final Outbox outbox;
  final RowApplier applier;
  final TimerFactory _createTimer;

  /// Jeda coba ulang saat server tidak terjangkau: 2, 4, 8 detik dan seterusnya, paling lama 5 menit.
  static const Duration maxBackoff = Duration(minutes: 5);

  /// Versi daftar koleksi `GET /sync` yang dikenal app ini; naik setiap ada koleksi baru
  /// atau kolom baru yang perlu diisi untuk baris lama.
  /// 1: v0.1. 2: `special_dates`. 3: `trips`, `trip_id` di daftar, dan jadwal pengingat
  /// setor di target (semuanya v0.2). 4: `memories` dan `memory_photos` (v0.3).
  /// 5: aturan ulang dan `next_task_id` di `tasks` (v1.0). 6: pin lokasi di `memories` (v1.x).
  /// 7: `comments` dan `reactions` (v1.x).
  static const int collectionsVersion = 7;

  /// Paling lama menunggu antrean terkirim sebelum menarik data.
  static const Duration flushLimit = Duration(seconds: 8);

  final Zone _zone = Zone.current;

  final StreamController<void> _pulled = StreamController.broadcast();

  /// Berbunyi setiap data selesai ditarik sampai halaman terakhir, misalnya untuk
  /// mengunduh thumbnail foto yang baru datang.
  Stream<void> get pulled => _pulled.stream;

  Future<bool>? _running;
  bool _again = false;
  bool _disposed = false;
  int _failures = 0;
  Timer? _retryTimer;

  /// Apakah database lokal akun ini pernah selesai sync.
  Future<bool> get hasSynced async => await store.meta(MetaKeys.syncSince) != null;

  /// Jalankan sync. Mengembalikan `true` kalau data berhasil ditarik sampai halaman terakhir.
  ///
  /// Permintaan yang datang saat sync sedang berjalan tidak membuat sync kedua;
  /// sync dijalankan sekali lagi setelah yang sekarang selesai.
  Future<bool> sync({bool retryNow = false}) {
    final running = _running;
    if (running != null) {
      _again = true;
      return running;
    }

    return _running = _zone.run(() => _run(retryNow)).whenComplete(() => _running = null);
  }

  Future<bool> _run(bool retryNow) async {
    var pulled = false;
    var flushNow = retryNow;

    do {
      _again = false;
      try {
        await outbox.flush(retryNow: flushNow).timeout(flushLimit, onTimeout: () => FlushState.waitingRetry);
        await _pull();
        pulled = true;
        if (!_pulled.isClosed) _pulled.add(null);
        _failures = 0;
        _retryTimer?.cancel();
      } on NetworkFailure {
        pulled = false;
        _scheduleRetry();
      } on ApiError {
        // 401 ditangani lewat sesi; kode lain tidak punya tindak lanjut di sini.
        pulled = false;
      } catch (_) {
        // Database ditutup saat akun keluar di tengah sync.
        if (_disposed) return false;
        rethrow;
      }
      flushNow = false;
    } while (_again && !_disposed);

    return pulled;
  }

  Future<void> _pull() async {
    var restarted = false;

    while (true) {
      final known = int.tryParse(await store.meta(MetaKeys.syncCollections) ?? '') ?? 1;
      final since = known < collectionsVersion ? null : await store.meta(MetaKeys.syncSince);
      String? cursor;
      String? serverTime;

      try {
        do {
          final response = await api.send(
            'GET',
            '/sync',
            query: cursor != null
                ? {'cursor': cursor}
                : since != null
                ? {'since': since}
                : null,
          );

          await _applyPage(response.data);

          final meta = response.meta;
          serverTime = meta['server_time'] as String;
          cursor = meta['has_more'] == true ? meta['next_cursor'] as String? : null;
        } while (cursor != null);
      } on ApiError catch (error) {
        // `cursor` yang ditolak server: ulangi sync dari `since` yang tersimpan.
        if (error.code == ApiErrorCode.validationFailed && cursor != null && !restarted) {
          restarted = true;
          continue;
        }
        rethrow;
      }

      await store.setMeta(MetaKeys.syncSince, serverTime);
      await store.setMeta(MetaKeys.syncCollections, '$collectionsVersion');
      return;
    }
  }

  /// Terapkan satu halaman dalam satu transaksi, induk lebih dulu.
  Future<void> _applyPage(Map<String, dynamic> data) => store.transaction(() async {
    final pending = await applier.loadPending();

    for (final type in EntityType.syncOrder) {
      final rows = data[type.syncKey] as List<dynamic>? ?? const [];
      for (final row in rows) {
        await applier.apply(type, row as Map<String, dynamic>, pending: pending);
      }
    }
  });

  void _scheduleRetry() {
    if (_disposed) return;
    _failures++;
    final seconds = math.min(math.pow(2, math.min(_failures, 16)).toInt(), maxBackoff.inSeconds);
    _retryTimer?.cancel();
    _retryTimer = _createTimer(Duration(seconds: seconds), () {
      if (_disposed) return;
      unawaited(sync().catchError((Object _) => false));
    });
  }

  void dispose() {
    _disposed = true;
    _retryTimer?.cancel();
    unawaited(_pulled.close());
  }
}
