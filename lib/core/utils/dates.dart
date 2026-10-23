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

final RegExp _ymdPattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// `YYYY-MM-DD` yang benar-benar ada di kalender, sama seperti `date_format:Y-m-d` di server.
bool isValidYmd(String value) {
  if (!_ymdPattern.hasMatch(value)) return false;
  final date = parseYmd(value);
  return ymdOf(date) == value;
}

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

/// Rentang tanggal, misalnya perjalanan: "Sab, 20 Jun" kalau hanya sehari, "20–25 Jun",
/// "28 Jun – 3 Jul", atau "28 Des 2026 – 3 Jan 2027". Tahun ditulis kalau bukan [currentYear].
String formatDateRange(String start, String? end, {required int currentYear}) {
  if (end == null || end == start) return formatDayShort(start, currentYear: currentYear);

  final from = parseYmd(start);
  final to = parseYmd(end);
  final dayMonth = DateFormat('d MMM', dateLocale);
  final year = from.year == currentYear && to.year == currentYear ? '' : ' ${to.year}';

  if (from.year != to.year) {
    final full = DateFormat('d MMM y', dateLocale);
    return '${full.format(from)} – ${full.format(to)}';
  }
  if (from.month == to.month) return '${from.day}–${dayMonth.format(to)}$year';
  return '${dayMonth.format(from)} – ${dayMonth.format(to)}$year';
}

/// Nama hari ISO, 1 = Senin sampai 7 = Minggu: "Jumat", atau "Jum" kalau [short].
String weekdayName(int isoDay, {bool short = false}) =>
    // 3 Agustus 2026 jatuh pada hari Senin.
    DateFormat(short ? 'EEE' : 'EEEE', dateLocale).format(DateTime.utc(2026, 8, 2 + isoDay));

/// "Kamis, 8 Oktober" untuk kepala Beranda.
String formatWeekdayLong(DateTime date) => DateFormat('EEEE, d MMMM', dateLocale).format(date);

/// "Okt" untuk sumbu grafik.
String formatMonthShort(int year, int month) => DateFormat('MMM', dateLocale).format(DateTime.utc(year, month));

/// Jam 24 jam dengan titik: `17:00` menjadi "17.00".
String formatClock(String hm) => hm.replaceAll(':', '.');

/// Tanggal tahunan dari kontrak, dipakai `birth_date` dan tanggal penting:
/// `YYYY-MM-DD`, atau `--MM-DD` kalau tahun tidak diisi.
class AnnualDate {
  const AnnualDate({this.year, required this.month, required this.day});

  final int? year;
  final int month;
  final int day;

  /// Tahun kabisat, supaya 29 Februari diterima saat tahun dikosongkan (sama dengan server).
  static const int _yearWhenOmitted = 2000;

  static final RegExp _pattern = RegExp(r'^(\d{4}|-)-(\d{2})-(\d{2})$');

  static AnnualDate? tryParse(String? value) {
    if (value == null) return null;
    final match = _pattern.firstMatch(value);
    if (match == null) return null;

    final date = AnnualDate(
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

  /// Hari jatuhnya tanggal ini pada [year] (`YYYY-MM-DD`). Sama dengan server,
  /// 29 Februari jatuh pada 28 Februari di tahun biasa.
  String inYear(int year) {
    final leap = DateTime.utc(year, 2, 29).month == 2;
    return toYmd(year, month, month == 2 && day == 29 && !leap ? 28 : day);
  }

  /// Hari jatuhnya berikutnya mulai [today]: tahun ini kalau belum lewat, selain itu tahun depan.
  /// Tahunnya tidak dipakai, sama seperti pengingat di server.
  String nextFrom(String today) {
    final year = parseYmd(today).year;
    final thisYear = inYear(year);
    return daysBetween(today, thisYear) >= 0 ? thisYear : inYear(year + 1);
  }

  /// Ini yang ke berapa pada [occurrence], misalnya 3 untuk hari jadi ketiga.
  /// `null` kalau tahunnya tidak diisi atau [occurrence] belum melewati tahun itu.
  int? ordinalAt(String occurrence) {
    if (year == null) return null;
    final ordinal = parseYmd(occurrence).year - year!;
    return ordinal >= 1 ? ordinal : null;
  }
}
