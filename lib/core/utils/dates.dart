import 'package:intl/intl.dart';

/// Tanggal kalender ditulis `YYYY-MM-DD` dan jam `HH:MM`, sama seperti di kontrak.
/// Keduanya tidak membawa zona; artinya ditentukan zona waktu ruangnya.

const String dateLocale = 'id_ID';

String _two(int value) => value.toString().padLeft(2, '0');

/// Ubah komponen tanggal menjadi `YYYY-MM-DD`.
String toYmd(int year, int month, int day) => '${year.toString().padLeft(4, '0')}-${_two(month)}-${_two(day)}';

/// Tanggal kalender dari [date], tanpa mengubah zonanya.
String ymdOf(DateTime date) => toYmd(date.year, date.month, date.day);

/// Jam `HH:MM` dari [time], tanpa mengubah zonanya.
String hmOf(DateTime time) => '${_two(time.hour)}:${_two(time.minute)}';

/// Baca `YYYY-MM-DD` sebagai tengah malam UTC, supaya selisih hari tidak terganggu DST.
DateTime parseYmd(String ymd) {
  final parts = ymd.split('-');
  return DateTime.utc(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}

String addDays(String ymd, int days) => ymdOf(parseYmd(ymd).add(Duration(days: days)));

/// Jumlah hari dari [from] ke [to]; negatif kalau [to] lebih dulu.
int daysBetween(String from, String to) => parseYmd(to).difference(parseYmd(from)).inDays;

/// "Kam, 8 Okt", ditambah tahun kalau bukan [currentYear].
String formatDayShort(String ymd, {required int currentYear}) {
  final date = parseYmd(ymd);
  final pattern = date.year == currentYear ? 'EEE, d MMM' : 'EEE, d MMM y';
  return DateFormat(pattern, dateLocale).format(date);
}

/// "28 Feb 2027".
String formatDateMedium(String ymd) => DateFormat('d MMM y', dateLocale).format(parseYmd(ymd));

/// "Kamis, 8 Oktober" untuk kepala Beranda.
String formatWeekdayLong(DateTime date) => DateFormat('EEEE, d MMMM', dateLocale).format(date);

/// "Okt" untuk sumbu grafik.
String formatMonthShort(int year, int month) => DateFormat('MMM', dateLocale).format(DateTime.utc(year, month));

/// Jam 24 jam dengan titik: `17:00` menjadi "17.00".
String formatClock(String hm) => hm.replaceAll(':', '.');

/// Tanggal lahir dari kontrak: `YYYY-MM-DD`, atau `--MM-DD` kalau tahun tidak diisi.
class BirthDate {
  const BirthDate({this.year, required this.month, required this.day});

  final int? year;
  final int month;
  final int day;

  /// Tahun kabisat, supaya 29 Februari diterima saat tahun dikosongkan (sama dengan server).
  static const int _yearWhenOmitted = 2000;

  static final RegExp _pattern = RegExp(r'^(\d{4}|-)-(\d{2})-(\d{2})$');

  static BirthDate? tryParse(String? value) {
    if (value == null) return null;
    final match = _pattern.firstMatch(value);
    if (match == null) return null;

    final date = BirthDate(
      year: match.group(1) == '-' ? null : int.parse(match.group(1)!),
      month: int.parse(match.group(2)!),
      day: int.parse(match.group(3)!),
    );
    return date.isValid ? date : null;
  }

  /// Cek kalender: `--02-30` ditolak, `--02-29` boleh.
  bool get isValid {
    if (month < 1 || month > 12 || day < 1) return false;
    if (year != null && (year! < 1900 || year! > 9999)) return false;
    final checked = DateTime.utc(year ?? _yearWhenOmitted, month, day);
    return checked.month == month && checked.day == day;
  }

  String toContract() => year == null ? '--${_two(month)}-${_two(day)}' : toYmd(year!, month, day);

  /// "2 Maret" atau "2 Maret 1998".
  String format() {
    final date = DateTime.utc(year ?? _yearWhenOmitted, month, day);
    return DateFormat(year == null ? 'd MMMM' : 'd MMMM y', dateLocale).format(date);
  }
}
