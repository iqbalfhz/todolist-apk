import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../domain/task.dart';

/// "Tiap minggu", "Tiap 2 bulan", dan seterusnya; tugas mingguan di beberapa hari (v1.x)
/// menjadi "Tiap 2 minggu, Selasa dan Jumat", atau "Tiap 2 minggu, Sel dan Jum" kalau [short].
String repeatText(AppLocalizations l10n, TaskRepeat repeat, {bool short = false}) {
  final every = switch (repeat.frequency) {
    RepeatFrequency.daily => l10n.repeatEveryDay(repeat.interval),
    RepeatFrequency.weekly => l10n.repeatEveryWeek(repeat.interval),
    RepeatFrequency.monthly => l10n.repeatEveryMonth(repeat.interval),
    RepeatFrequency.yearly => l10n.repeatEveryYear(repeat.interval),
  };
  final days = repeat.days;
  if (days == null) return every;
  return l10n.repeatOnDays(every, joinWords(l10n, [for (final day in days) weekdayName(day, short: short)]));
}

/// "Senin", "Senin dan Rabu", "Senin, Rabu, dan Jumat".
String joinWords(AppLocalizations l10n, List<String> words) => switch (words.length) {
  0 => '',
  1 => words.single,
  2 => l10n.listTwo(words.first, words.last),
  _ => l10n.listMany(words.sublist(0, words.length - 1).join(', '), words.last),
};

String _frequencyLabel(AppLocalizations l10n, RepeatFrequency frequency) => switch (frequency) {
  RepeatFrequency.daily => l10n.repeatDaily,
  RepeatFrequency.weekly => l10n.repeatWeekly,
  RepeatFrequency.monthly => l10n.repeatMonthly,
  RepeatFrequency.yearly => l10n.repeatYearly,
};

/// Hasil [showRepeatSheet]. [repeat] `null` berarti tidak diulang.
class RepeatPick {
  const RepeatPick(this.repeat);

  final TaskRepeat? repeat;
}

/// Buka lembar "Ulangi tugas" untuk tugas bertenggat [dueDate]. Mengembalikan `null` kalau
/// ditutup tanpa menyimpan.
Future<RepeatPick?> showRepeatSheet(BuildContext context, {required TaskRepeat? current, required String dueDate}) =>
    showAppSheet<RepeatPick>(
      context,
      builder: (_) => RepeatSheet(current: current, dueDate: dueDate),
    );

/// Pilihan ulang (v1.0): tidak diulang, harian, mingguan, bulanan, atau tahunan, dengan
/// "setiap N", dan untuk mingguan hari-harinya (v1.x). Tenggatnya menjadi patokan; tugas
/// berikutnya dibuat server saat tugas ini selesai.
class RepeatSheet extends StatefulWidget {
  const RepeatSheet({super.key, required this.current, required this.dueDate});

  final TaskRepeat? current;

  /// Tenggat tugasnya (`YYYY-MM-DD`), untuk keterangan bulan yang lebih pendek.
  final String dueDate;

  @override
  State<RepeatSheet> createState() => _RepeatSheetState();
}

class _RepeatSheetState extends State<RepeatSheet> {
  late RepeatFrequency? _frequency = widget.current?.frequency;
  late int _interval = widget.current?.interval ?? 1;

  /// Hari tenggat patokan; tanpa pilihan lain, tugas mingguan berulang di hari ini.
  late final int _dueWeekday = parseYmd(widget.dueDate).weekday;
  late final Set<int> _days = {
    ...(widget.current?.days ?? [_dueWeekday]),
  };

  /// Hari yang dikirim: `null` kalau hanya hari tenggat, seperti tugas mingguan sebelumnya.
  List<int>? get _pickedDays {
    if (_frequency != RepeatFrequency.weekly) return null;
    final days = TaskRepeat.normalizeDays(_days);
    return days?.length == 1 && days!.single == _dueWeekday ? null : days;
  }

  TaskRepeat? get _repeat {
    final frequency = _frequency;
    return frequency == null ? null : TaskRepeat(frequency, _interval, _pickedDays);
  }

  /// Minimal satu hari tetap terpilih.
  void _toggleDay(int day) => setState(() {
    if (!_days.contains(day)) {
      _days.add(day);
    } else if (_days.length > 1) {
      _days.remove(day);
    }
  });

  void _save() => Navigator.of(context).pop(RepeatPick(_repeat));

  /// Keterangan untuk tanggal yang tidak ada di setiap bulan atau tahun.
  String? _help(AppLocalizations l10n) {
    final date = parseYmd(widget.dueDate);
    return switch (_frequency) {
      RepeatFrequency.monthly when date.day > 28 => l10n.repeatShortMonth,
      RepeatFrequency.yearly when date.month == 2 && date.day == 29 => l10n.repeatLeapDay,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;
    final frequency = _frequency;

    return AppSheet(
      title: l10n.repeatSheetTitle,
      footer: PrimaryButton(label: l10n.commonSave, onPressed: _save),
      children: [
        LabeledField(
          label: l10n.repeatHowOften,
          child: Wrap(
            spacing: AppDimens.gap8,
            children: [
              AppFilterChip(
                label: l10n.repeatNone,
                selected: frequency == null,
                onTap: () => setState(() => _frequency = null),
              ),
              for (final option in RepeatFrequency.values)
                AppFilterChip(
                  label: _frequencyLabel(l10n, option),
                  selected: frequency == option,
                  onTap: () => setState(() => _frequency = option),
                ),
            ],
          ),
        ),
        if (frequency != null)
          LabeledField(
            label: l10n.repeatEvery,
            help: _help(l10n),
            child: _IntervalStepper(
              value: _interval,
              label: repeatText(l10n, TaskRepeat(frequency, _interval)),
              onChanged: (value) => setState(() => _interval = value),
            ),
          ),
        if (frequency == RepeatFrequency.weekly)
          LabeledField(
            label: l10n.repeatWhichDays,
            // Ringkasan hanya kalau harinya bukan sekadar hari tenggat; itu sudah tertulis di atas.
            help: _pickedDays == null ? null : repeatText(l10n, _repeat!),
            child: Wrap(
              spacing: AppDimens.gap8,
              runSpacing: AppDimens.gap8,
              children: [
                for (var day = DateTime.monday; day <= DateTime.sunday; day++)
                  Semantics(
                    label: weekdayName(day),
                    excludeSemantics: true,
                    button: true,
                    selected: _days.contains(day),
                    child: AppFilterChip(
                      label: weekdayName(day, short: true),
                      selected: _days.contains(day),
                      onTap: () => _toggleDay(day),
                    ),
                  ),
              ],
            ),
          ),
        Text(l10n.repeatNote, style: text.small),
      ],
    );
  }
}

/// Tombol kurang dan tambah di kiri-kanan "Tiap 2 minggu", untuk 1–99.
class _IntervalStepper extends StatelessWidget {
  const _IntervalStepper({required this.value, required this.label, required this.onChanged});

  final int value;
  final String label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        AppIconButton(
          icon: Symbols.remove_rounded,
          label: l10n.repeatFewer,
          outlined: true,
          iconSize: AppDimens.iconLg,
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
        ),
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: Text(label, style: context.text.rowTitle, textAlign: TextAlign.center),
          ),
        ),
        AppIconButton(
          icon: Symbols.add_rounded,
          label: l10n.repeatMore,
          outlined: true,
          iconSize: AppDimens.iconLg,
          onPressed: value < Limits.repeatInterval ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}
