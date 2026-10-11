/// Mata uang yang diterima API, disalin dari tabel Uang di `docs/kontrak-api.md`.
///
/// Jumlah desimal mengikuti tabel itu, bukan `intl`: IDR sengaja tanpa desimal.
class CurrencyInfo {
  const CurrencyInfo({required this.code, required this.decimals, required this.symbol, required this.name});

  final String code;
  final int decimals;
  final String symbol;
  final String name;

  /// Banyaknya satuan terkecil dalam satu satuan utama (1 untuk IDR, 100 untuk USD).
  int get unitsPerMajor => decimals == 0 ? 1 : 100;

  /// Label di pilihan mata uang, misalnya "Rupiah (IDR)".
  String get label => '$name ($code)';
}

const String defaultCurrencyCode = 'IDR';

const List<CurrencyInfo> supportedCurrencies = [
  CurrencyInfo(code: 'IDR', decimals: 0, symbol: 'Rp', name: 'Rupiah'),
  CurrencyInfo(code: 'USD', decimals: 2, symbol: r'US$', name: 'Dolar AS'),
  CurrencyInfo(code: 'SGD', decimals: 2, symbol: r'S$', name: 'Dolar Singapura'),
  CurrencyInfo(code: 'MYR', decimals: 2, symbol: 'RM', name: 'Ringgit Malaysia'),
  CurrencyInfo(code: 'EUR', decimals: 2, symbol: '€', name: 'Euro'),
  CurrencyInfo(code: 'JPY', decimals: 0, symbol: '¥', name: 'Yen Jepang'),
];

/// Nominal paling besar yang diterima API, dalam satuan terkecil (10^15).
const int maxAmount = 1000000000000000;

CurrencyInfo currencyOf(String code) {
  for (final currency in supportedCurrencies) {
    if (currency.code == code) return currency;
  }
  return supportedCurrencies.first;
}
