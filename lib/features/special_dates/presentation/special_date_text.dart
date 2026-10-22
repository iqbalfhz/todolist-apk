import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../domain/special_date.dart';
import '../domain/upcoming_dates.dart';

/// Nama tanggal untuk ditampilkan, ditambah "ke-N" kalau tahunnya diisi.
/// Ulang tahun anggota bernama "Ulang tahunmu" atau "Ulang tahun Sari".
String upcomingTitle(AppLocalizations l10n, UpcomingDate item) {
  final base =
      item.specialDate?.title ?? (item.isMine ? l10n.datesBirthdayMine : l10n.datesBirthdayOf(item.memberName ?? ''));
  final ordinal = item.ordinal;
  return ordinal == null ? base : l10n.datesOrdinal(base, ordinal);
}

/// "Hari ini", "Besok", atau "12 hari".
String countdownShort(AppLocalizations l10n, int days) => switch (days) {
  0 => l10n.datesToday,
  1 => l10n.datesTomorrow,
  _ => l10n.datesDaysShort(days),
};

/// "Hari ini", "Besok", atau "12 hari lagi".
String countdownLong(AppLocalizations l10n, int days) => switch (days) {
  0 => l10n.datesToday,
  1 => l10n.datesTomorrow,
  _ => l10n.homeDatesInDays(days),
};

/// "Sel, 20 Okt", ditambah tahun kalau jatuhnya bukan tahun ini.
String upcomingDay(UpcomingDate item, {required int currentYear}) =>
    formatDayShort(item.next, currentYear: currentYear);

String typeLabel(AppLocalizations l10n, SpecialDateType type) => switch (type) {
  SpecialDateType.birthday => l10n.dateTypeBirthday,
  SpecialDateType.anniversary => l10n.dateTypeAnniversary,
  SpecialDateType.other => l10n.dateTypeOther,
};

IconData typeIcon(SpecialDateType type) => switch (type) {
  SpecialDateType.birthday => Symbols.redeem_rounded,
  SpecialDateType.anniversary => Symbols.favorite_rounded,
  SpecialDateType.other => Symbols.event_rounded,
};

/// Ikon jenis tanggal di lingkaran `soft`. Ulang tahun anggota memakai warna diri orangnya;
/// namanya selalu ikut tertulis, jadi warna bukan satu-satunya penanda.
class UpcomingIcon extends StatelessWidget {
  const UpcomingIcon({super.key, required this.item, this.size = AppDimens.iconCircle});

  final UpcomingDate item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final memberColor = item.memberColor;

    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: palette.soft, shape: BoxShape.circle),
        child: Icon(
          typeIcon(item.type),
          size: AppDimens.iconLg,
          color: memberColor == null ? palette.brand : context.personColor(memberColor),
        ),
      ),
    );
  }
}
