import 'dart:async';
import 'dart:convert';

import '../../../core/api/api_error.dart';
import '../../../core/api/api_transport.dart';
import '../../../core/database/local_store.dart';
import '../domain/exchange_rates.dart';

/// Kurs ECB untuk perkiraan di Tabungan (v1.x). `GET /exchange-rates` dipanggil langsung, tidak
/// lewat antrean, dan hasilnya disimpan di database akun, supaya perkiraan tetap tampil saat
/// offline beserta tanggal kursnya.
class ExchangeRateRepository {
  ExchangeRateRepository({required this.store, required this.api, DateTime Function()? now})
    : now = now ?? DateTime.now;

  final LocalStore store;
  final ApiTransport api;
  final DateTime Function() now;

  /// Kurs diambil paling sering sekali per 6 jam (kontrak); server sendiri memperbaruinya
  /// sekali sejam, dan ECB sekali tiap hari kerja.
  static const Duration refreshEvery = Duration(hours: 6);

  /// Jeda sebelum mencoba lagi setelah gagal, misalnya offline atau server belum punya kurs.
  static const Duration retryAfterFailure = Duration(minutes: 15);

  DateTime? _failedAt;
  Future<bool>? _running;

  /// Kurs tersimpan, atau `null` selama belum pernah berhasil diambil.
  Stream<ExchangeRates?> watch() => store.watchMeta(MetaKeys.exchangeRates).map(_decode);

  Future<ExchangeRates?> current() async => _decode(await store.meta(MetaKeys.exchangeRates));

  /// Ambil kurs baru kalau yang tersimpan sudah berumur 6 jam atau belum ada. `true` kalau kurs
  /// baru tersimpan. Gagal (offline, atau 503 `exchange_rates_unavailable` karena server belum
  /// pernah berhasil mengambil kurs) tidak menghapus kurs tersimpan; dicoba lagi 15 menit
  /// kemudian. Error lain diteruskan.
  Future<bool> refresh() => _running ??= _refresh().whenComplete(() => _running = null);

  Future<bool> _refresh() async {
    final time = now();
    final savedAt = await store.meta(MetaKeys.exchangeRatesSavedAt);
    if (savedAt != null && time.difference(DateTime.parse(savedAt)) < refreshEvery) return false;
    final failedAt = _failedAt;
    if (failedAt != null && time.difference(failedAt) < retryAfterFailure) return false;

    try {
      final response = await api.send('GET', '/exchange-rates');
      final rates = ExchangeRates.fromJson(response.data);
      await store.transaction(() async {
        await store.setMeta(MetaKeys.exchangeRates, jsonEncode(rates.toJson()));
        await store.setMeta(MetaKeys.exchangeRatesSavedAt, time.toUtc().toIso8601String());
      });
      _failedAt = null;
      return true;
    } on NetworkFailure {
      _failedAt = time;
      return false;
    } on ApiError catch (error) {
      if (error.code != ApiErrorCode.exchangeRatesUnavailable) rethrow;
      _failedAt = time;
      return false;
    }
  }

  static ExchangeRates? _decode(String? raw) {
    if (raw == null) return null;
    try {
      return ExchangeRates.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return null;
    }
  }
}
