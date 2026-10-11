import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/time/space_clock.dart';
import '../../../core/utils/dates.dart';
import '../../spaces/domain/household.dart';
import '../domain/task_views.dart';

/// Nama hari untuk sebuah tanggal relatif terhadap [today]: "Hari ini", "Besok",
/// "Kemarin", atau "Kam, 8 Okt".
String dayLabel(AppLocalizations l10n, String date, {required String today}) {
  final distance = daysBetween(today, date);
  return switch (distance) {
    0 => l10n.dueToday,
    1 => l10n.dueTomorrow,
    -1 => l10n.dueYesterday,
    _ => formatDayShort(date, currentYear: parseYmd(today).year),
  };
}

/// Keterangan tenggat sebuah tugas: "Hari ini, 17.00", "Tanpa tenggat", atau
/// "Terlewat · kemarin" kalau sudah lewat. Teksnya ramah: "Terlewat", bukan "Terlambat!".
String dueText(AppLocalizations l10n, TaskItem item) {
  final date = item.task.dueDate;
  if (date == null) return l10n.dueNone;

  final day = dayLabel(l10n, date, today: item.today);
  final time = item.task.dueTime;
  final when = time == null ? day : l10n.dueWithTime(day, formatClock(time));
  if (!item.isOverdue) return when;

  return l10n.dueOverdue(_midSentence(when, date, today: item.today));
}

/// Di tengah kalimat, "Kemarin", "Hari ini", dan "Besok" ditulis dengan huruf kecil;
/// nama hari seperti "Sen, 5 Okt" tetap.
String _midSentence(String label, String date, {required String today}) {
  final relative = daysBetween(today, date).abs() <= 1;
  return relative ? label[0].toLowerCase() + label.substring(1) : label;
}

/// "Diselesaikan Sari, 12.40"; untuk hari lain memakai tanggalnya.
String completedText(AppLocalizations l10n, TaskItem item, Household household, SpaceClock clock) {
  final completedAt = item.task.completedAt;
  if (completedAt == null) return '';

  final by = item.task.completedBy;
  final who = by == null || by == household.me.id ? l10n.labelYou : household.nameOf(by) ?? l10n.labelPartner;
  final wall = clock.wallClock(completedAt, item.space.timezone);
  final when = item.completedToday
      ? formatClock(wall.time)
      : _midSentence(dayLabel(l10n, wall.date, today: item.today), wall.date, today: item.today);

  return l10n.taskCompletedBy(who, when);
}

/// Label dan titik warna chip penanggung jawab.
({String label, List<Color> colors}) assigneeChip(BuildContext context, Assignee assignee, Household household) {
  final l10n = context.l10n;
  final mine = context.personColor(household.me.color);
  final theirs = context.personColor(household.partner?.color ?? household.me.color);

  return switch (assignee) {
    Assignee.me => (label: l10n.labelMe, colors: [mine]),
    Assignee.partner => (label: l10n.labelPartner, colors: [theirs]),
    Assignee.us => (label: l10n.labelUs, colors: [mine, theirs]),
  };
}

/// ID penanggung jawab untuk pilihan Aku, Pasangan, atau Kita.
List<String> assigneeIdsFor(Assignee assignee, Household household) {
  final partnerId = household.partner?.id;
  return switch (assignee) {
    Assignee.me => [household.me.id],
    Assignee.partner => [partnerId ?? household.me.id],
    Assignee.us => [household.me.id, ?partnerId],
  };
}

/// Nama warna untuk pembaca layar.
String colorName(AppLocalizations l10n, String key) => switch (key) {
  'ungu' => l10n.colorUngu,
  'toska' => l10n.colorToska,
  'bata' => l10n.colorBata,
  'biru' => l10n.colorBiru,
  'lavender' => l10n.colorLavender,
  _ => l10n.colorMawar,
};
