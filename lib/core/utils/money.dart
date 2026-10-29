import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../constants/currencies.dart';

const String _locale = 'id_ID';

/// Format nominal (satuan terkecil) untuk ditampilkan: `150000` IDR menjadi "Rp150.000".
///
/// `decimalDigits` selalu diisi dari tabel di kontrak, karena `intl` memakai 2 desimal untuk IDR.
///
/// Nominal negatif selalu diawali tanda minus "−" (U+2212), misalnya penarikan "−Rp200.000";
/// [withSign] menambah "+" untuk yang positif.
String formatMoney(int amount, String currencyCode, {bool withSign = false}) {
  final currency = currencyOf(currencyCode);
  final formatter = NumberFormat.currency(locale: _locale, symbol: currency.symbol, decimalDigits: currency.decimals);
  final text = formatter.format(amount.abs() / currency.unitsPerMajor);
  if (amount < 0) return '−$text';
  return withSign && amount > 0 ? '+$text' : text;
}

/// Format ringkas untuk label grafik: `1000000` IDR menjadi "1,0 jt".
String formatMoneyCompact(int amount, String currencyCode) {
  final currency = currencyOf(currencyCode);
  final major = amount / currency.unitsPerMajor;
  final oneDecimal = NumberFormat('0.0', _locale);

  // Batasnya tepat di titik pembulatan, supaya 999.500 menjadi "1,0 jt", bukan "1000 rb".
  if (major >= 999.95e9) return '${oneDecimal.format(major / 1e12)} T';
  if (major >= 999.95e6) return '${oneDecimal.format(major / 1e9)} M';
  if (major >= 999.5e3) return '${oneDecimal.format(major / 1e6)} jt';
  if (major >= 1e3) return '${NumberFormat('0', _locale).format(major / 1e3)} rb';
  return NumberFormat(currency.decimals == 0 ? '0' : '0.00', _locale).format(major);
}

/// Baca isian nominal ("150.000" atau "10,50") menjadi satuan terkecil, atau `null` kalau kosong.
int? parseMoneyInput(String text, String currencyCode) {
  final currency = currencyOf(currencyCode);
  final cleaned = text.replaceAll(RegExp(r'[^0-9,]'), '');
  if (cleaned.isEmpty) return null;

  final parts = cleaned.split(',');
  final whole = int.tryParse(parts.first.isEmpty ? '0' : parts.first);
  if (whole == null) return null;
  if (currency.decimals == 0) return whole;

  final fraction = parts.length > 1 ? parts[1] : '';
  final padded = fraction.padRight(currency.decimals, '0').substring(0, currency.decimals);
  return whole * currency.unitsPerMajor + int.parse(padded);
}

/// Teks awal isian nominal untuk nilai yang sudah ada, tanpa simbol mata uang.
String moneyInputText(int amount, String currencyCode) {
  final currency = currencyOf(currencyCode);
  final pattern = currency.decimals == 0 ? '#,##0' : '#,##0.00';
  return NumberFormat(pattern, _locale).format(amount / currency.unitsPerMajor);
}

/// Memberi pemisah ribuan saat nominal diketik, dan membatasi desimal sesuai mata uangnya.
class MoneyInputFormatter extends TextInputFormatter {
  MoneyInputFormatter(this.currencyCode);

  final String currencyCode;

  /// 10^15 punya 16 digit; lebih dari itu pasti ditolak server.
  static const int _maxWholeDigits = 16;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final currency = currencyOf(currencyCode);
    final raw = newValue.text.replaceAll(RegExp(r'[^0-9,]'), '');
    if (raw.isEmpty) return const TextEditingValue();

    final commaAt = raw.indexOf(',');
    final hasComma = currency.decimals > 0 && commaAt >= 0;
    var whole = (commaAt >= 0 ? raw.substring(0, commaAt) : raw).replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (whole.length > _maxWholeDigits) whole = whole.substring(0, _maxWholeDigits);
    if (whole.isEmpty) whole = '0';

    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buffer.write('.');
      buffer.write(whole[i]);
    }

    if (hasComma) {
      final fraction = raw.substring(commaAt + 1).replaceAll(',', '');
      buffer
        ..write(',')
        ..write(fraction.length > currency.decimals ? fraction.substring(0, currency.decimals) : fraction);
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
