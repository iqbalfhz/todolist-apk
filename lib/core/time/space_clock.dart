import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../utils/dates.dart';

/// Zona waktu bawaan server kalau HP tidak mengirim zona.
const String fallbackTimezone = 'Asia/Jakarta';

bool _initialized = false;

/// Muat basis data zona waktu. Aman dipanggil berkali-kali.
void ensureTimezonesLoaded() {
  if (_initialized) return;
  tzdata.initializeTimeZones();
  _initialized = true;
}

/// Jam dinding di sebuah zona waktu pada satu saat tertentu.
class ZonedNow {
  const ZonedNow({required this.date, required this.time, required this.year});

  /// `YYYY-MM-DD`.
  final String date;

  /// `HH:MM`.
  final String time;

  final int year;
}

/// Menghitung "hari ini" dan jam menurut zona waktu ruang, bukan zona waktu HP.
class SpaceClock {
  SpaceClock({DateTime Function()? now}) : _now = now ?? DateTime.now {
    ensureTimezonesLoaded();
  }

  final DateTime Function() _now;

  DateTime now() => _now();

  tz.Location _location(String timezone) {
    try {
      return tz.getLocation(timezone);
    } on tz.LocationNotFoundException {
      return tz.getLocation(fallbackTimezone);
    }
  }

  ZonedNow nowIn(String timezone) => wallClock(_now(), timezone);

  /// Tanggal hari ini (`YYYY-MM-DD`) di zona [timezone].
  String today(String timezone) => nowIn(timezone).date;

  /// Jam dinding dari [instant] di zona [timezone].
  ZonedNow wallClock(DateTime instant, String timezone) {
    final zoned = tz.TZDateTime.from(instant, _location(timezone));
    return ZonedNow(date: ymdOf(zoned), time: hmOf(zoned), year: zoned.year);
  }
}
