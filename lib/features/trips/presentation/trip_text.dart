import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/utils/dates.dart';
import '../domain/trip_views.dart';

/// Hitung mundur atau status perjalanan: "12 hari lagi", "Besok berangkat",
/// "Hari ke-2 dari 6", "Sedang berlangsung", "Selesai", atau "Tanggal belum pasti".
String tripCountdown(AppLocalizations l10n, TripItem item) => switch (item.status) {
  TripStatus.planned => switch (item.daysUntilStart) {
    null => l10n.tripUndated,
    1 => l10n.tripTomorrow,
    final days => l10n.tripInDays(days),
  },
  TripStatus.ongoing =>
    (item.durationDays ?? 1) > 1 ? l10n.tripOngoingDay(item.dayNumber!, item.durationDays!) : l10n.tripOngoing,
  TripStatus.done => l10n.tripDone,
};

/// Tanggal dan lamanya: "20–25 Jun 2027 · 6 hari", atau hanya "Sab, 20 Jun" kalau sehari.
/// `null` kalau tanggalnya belum pasti.
String? tripDates(AppLocalizations l10n, TripItem item, {required int currentYear}) {
  final start = item.trip.startDate;
  if (start == null) return null;

  final range = formatDateRange(start, item.trip.endDate, currentYear: currentYear);
  final days = item.durationDays ?? 1;
  return days > 1 ? '$range · ${l10n.tripDays(days)}' : range;
}

/// Ikon status, supaya status tidak hanya dibedakan lewat teks.
IconData tripStatusIcon(TripStatus status) => switch (status) {
  TripStatus.planned => Symbols.flight_takeoff_rounded,
  TripStatus.ongoing => Symbols.luggage_rounded,
  TripStatus.done => Symbols.flight_land_rounded,
};

/// Tahun "sekarang" untuk menentukan perlu tidaknya tahun ditulis di tanggal.
int currentYearOf(TripItem item) => parseYmd(item.today).year;
