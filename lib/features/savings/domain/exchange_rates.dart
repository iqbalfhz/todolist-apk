import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/constants/currencies.dart';

part 'exchange_rates.freezed.dart';
part 'exchange_rates.g.dart';

/// Kurs referensi harian ECB dari `GET /exchange-rates` (v1.x), untuk perkiraan nominal target
/// dalam mata uang bawaan. Hanya tampilan: tidak ada data yang dikonversi.
@freezed
abstract class ExchangeRates with _$ExchangeRates {
  const ExchangeRates._();

  const factory ExchangeRates({
    /// Selalu `EUR`.
    required String base,

    /// Tanggal kurs dari ECB (`YYYY-MM-DD`); di akhir pekan tetap hari kerja terakhir.
    required String date,

    /// Waktu terakhir server berhasil mengambil kurs.
    required DateTime fetchedAt,

    /// Banyaknya satuan utama tiap mata uang untuk 1 [base], sebagai teks desimal persis dari
    /// ECB, misalnya `"20341.45"` untuk IDR.
    required Map<String, String> rates,
  }) = _ExchangeRates;

  factory ExchangeRates.fromJson(Map<String, dynamic> json) => _$ExchangeRatesFromJson(json);

  /// Perkiraan [amount] (satuan terkecil [from]) dalam satuan terkecil [to]: nominal dalam
  /// satuan utama ÷ `rates[from]` × `rates[to]`, dibulatkan ke desimal [to] (setengah ke atas).
  ///
  /// Dihitung dengan bilangan bulat, supaya hasilnya persis rumus di kontrak tanpa pembulatan
  /// float. `null` kalau salah satu kurs tidak ada atau tidak terbaca.
  int? convert(int amount, {required String from, required String to}) {
    final rateFrom = _parseRate(rates[from]);
    final rateTo = _parseRate(rates[to]);
    if (rateFrom == null || rateTo == null) return null;

    final ten = BigInt.from(10);
    final numerator =
        BigInt.from(amount).abs() * rateTo.digits * ten.pow(rateFrom.scale) * BigInt.from(currencyOf(to).unitsPerMajor);
    final denominator = BigInt.from(currencyOf(from).unitsPerMajor) * rateFrom.digits * ten.pow(rateTo.scale);
    final rounded = (numerator * BigInt.two + denominator) ~/ (denominator * BigInt.two);

    final result = amount < 0 ? -rounded : rounded;
    return result.isValidInt ? result.toInt() : null;
  }

  /// Teks desimal positif seperti `"1.1216"` menjadi digitnya (`11216`) dan banyaknya angka di
  /// belakang titik (`4`). Nol atau teks lain tidak dipakai.
  static ({BigInt digits, int scale})? _parseRate(String? text) {
    final match = RegExp(r'^(\d+)(?:\.(\d+))?$').firstMatch(text?.trim() ?? '');
    if (match == null) return null;
    final fraction = match.group(2) ?? '';
    final digits = BigInt.parse('${match.group(1)}$fraction');
    if (digits == BigInt.zero) return null;
    return (digits: digits, scale: fraction.length);
  }
}
