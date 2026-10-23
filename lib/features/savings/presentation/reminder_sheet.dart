import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/widgets.dart';
import '../../spaces/domain/household.dart';
import '../domain/savings_goal.dart';

/// "Ingatkan setor tiap Jumat": jadwal pengingat setor sebuah target (v0.2).
String reminderTitle(AppLocalizations l10n, SavingsReminder? reminder) => switch (reminder) {
  null => l10n.savingsReminderOff,
  SavingsReminder(frequency: ReminderFrequency.weekly, :final day) => l10n.savingsReminderWeekly(weekdayName(day)),
  SavingsReminder(frequency: ReminderFrequency.monthly, :final day) => l10n.savingsReminderMonthly(day),
};

/// Baris pengingat setor di ringkasan Detail target. Ketuk barisnya untuk memilih jadwal;
/// switch-nya menyalakan (lewat pilihan jadwal) atau mematikan pengingat.
class SavingsReminderRow extends ConsumerWidget {
  const SavingsReminderRow({super.key, required this.goal, required this.today});

  final SavingsGoal goal;

  /// Hari ini (`YYYY-MM-DD`) di zona waktu ruang target, untuk pilihan bawaan jadwal.
  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = context.text;
    final household = ref.watch(householdProvider);
    final reminder = goal.reminder;
    final prefsOff = household != null && !household.me.notificationPrefs.savingsReminders;
    final shared = household?.isShared(goal.spaceId) ?? false;

    final subtitle = reminder == null
        ? l10n.savingsReminderOffSub
        : prefsOff
        ? l10n.savingsReminderPrefsOff
        : shared
        ? l10n.savingsReminderSubShared
        : l10n.savingsReminderSubPersonal;

    void edit() => showSavingsReminderSheet(context, goal: goal, today: today);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppDimens.rowMinHeightSettings),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              container: true,
              button: true,
              child: InkWell(
                onTap: edit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppDimens.gap8),
                  child: Row(
                    children: [
                      const Icon(Symbols.notifications_rounded, size: AppDimens.iconMd),
                      const SizedBox(width: AppDimens.gap10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(reminderTitle(l10n, reminder), style: text.bodyStrong),
                            Text(subtitle, style: text.small),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.gap12),
          Semantics(
            label: l10n.savingsReminderSheet,
            child: Switch(
              value: reminder != null,
              onChanged: (on) => on ? edit() : ref.read(accountProvider)?.savings.setReminder(goal.id, null),
            ),
          ),
        ],
      ),
    );
  }
}

/// Buka lembar pilihan jadwal pengingat setor untuk [goal].
Future<void> showSavingsReminderSheet(BuildContext context, {required SavingsGoal goal, required String today}) =>
    showAppSheet<void>(
      context,
      builder: (_) => SavingsReminderSheet(goal: goal, today: today),
    );

/// Lembar jadwal pengingat setor: mingguan (pilih hari) atau bulanan (pilih tanggal 1–31),
/// selalu pukul 08.00 di zona waktu ruang target.
class SavingsReminderSheet extends ConsumerStatefulWidget {
  const SavingsReminderSheet({super.key, required this.goal, required this.today});

  final SavingsGoal goal;
  final String today;

  @override
  ConsumerState<SavingsReminderSheet> createState() => _SavingsReminderSheetState();
}

class _SavingsReminderSheetState extends ConsumerState<SavingsReminderSheet> {
  late final SavingsReminder? _current = widget.goal.reminder;
  late ReminderFrequency _frequency = _current?.frequency ?? ReminderFrequency.weekly;

  // Bawaan: hari ini, supaya pengingat pertama jatuh di hari yang sama minggu atau bulan depan.
  late int _weekday = _current?.frequency == ReminderFrequency.weekly ? _current!.day : parseYmd(widget.today).weekday;
  late int _monthDay = _current?.frequency == ReminderFrequency.monthly ? _current!.day : parseYmd(widget.today).day;

  Future<void> _save() async {
    final day = _frequency == ReminderFrequency.weekly ? _weekday : _monthDay;
    await ref
        .read(accountProvider)
        ?.savings
        .setReminder(widget.goal.id, SavingsReminder(frequency: _frequency, day: day));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _turnOff() async {
    await ref.read(accountProvider)?.savings.setReminder(widget.goal.id, null);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final household = ref.watch(householdProvider);
    final shared = household?.isShared(widget.goal.spaceId) ?? false;

    return AppSheet(
      title: l10n.savingsReminderSheet,
      footer: PrimaryButton(label: l10n.commonSave, onPressed: _save),
      children: [
        LabeledField(
          label: l10n.savingsReminderHowOften,
          child: SegmentedControl<ReminderFrequency>(
            semanticLabel: l10n.savingsReminderHowOften,
            selected: _frequency,
            onChanged: (frequency) => setState(() => _frequency = frequency),
            segments: [
              Segment(value: ReminderFrequency.weekly, label: l10n.savingsReminderWeeklyOption),
              Segment(value: ReminderFrequency.monthly, label: l10n.savingsReminderMonthlyOption),
            ],
          ),
        ),
        if (_frequency == ReminderFrequency.weekly)
          LabeledField(
            label: l10n.savingsReminderWhichDay,
            child: Wrap(
              spacing: AppDimens.gap8,
              children: [
                for (var day = 1; day <= ReminderFrequency.weekly.lastDay; day++)
                  AppFilterChip(
                    label: weekdayName(day, short: true),
                    selected: _weekday == day,
                    onTap: () => setState(() => _weekday = day),
                  ),
              ],
            ),
          )
        else
          LabeledField(
            label: l10n.savingsReminderWhichDate,
            // Tanggal 29–31 tidak ada di setiap bulan.
            help: _monthDay > 28 ? l10n.savingsReminderShortMonth : null,
            child: DropdownButtonFormField<int>(
              initialValue: _monthDay,
              style: text.input,
              items: [
                for (var day = 1; day <= ReminderFrequency.monthly.lastDay; day++)
                  DropdownMenuItem(value: day, child: Text(l10n.savingsReminderDateOption(day))),
              ],
              onChanged: (day) => setState(() => _monthDay = day ?? _monthDay),
            ),
          ),
        Text(shared ? l10n.savingsReminderNoteShared : l10n.savingsReminderNote, style: text.small),
        if (_current != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _turnOff,
              style: TextButton.styleFrom(foregroundColor: palette.danger),
              icon: const Icon(Symbols.notifications_off_rounded, size: AppDimens.iconMd),
              label: Text(l10n.savingsReminderTurnOff),
            ),
          ),
      ],
    );
  }
}
