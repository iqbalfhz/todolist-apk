import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../spaces/domain/household.dart';
import '../domain/special_date.dart';
import 'special_date_text.dart';

/// Buka lembar tanggal penting baru, atau ubah [date] kalau diisi.
Future<void> showSpecialDateSheet(BuildContext context, {SpecialDate? date}) =>
    showAppSheet<void>(context, builder: (_) => SpecialDateSheet(date: date));

/// Lembar buat atau ubah tanggal penting: jenis, nama, tanggal (tahun boleh kosong),
/// dan ruangnya. Ruang hanya dipilih saat dibuat.
class SpecialDateSheet extends ConsumerStatefulWidget {
  const SpecialDateSheet({super.key, this.date});

  final SpecialDate? date;

  @override
  ConsumerState<SpecialDateSheet> createState() => _SpecialDateSheetState();
}

class _SpecialDateSheetState extends ConsumerState<SpecialDateSheet> {
  late SpecialDateType _type = widget.date?.kind ?? SpecialDateType.anniversary;
  late final TextEditingController _title = TextEditingController(text: widget.date?.title ?? '');
  late AnnualDate? _date = AnnualDate.tryParse(widget.date?.date);
  bool _shared = true;
  String? _titleError;
  String? _dateError;
  bool _saving = false;

  bool get _editing => widget.date != null;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  String _hint(AppLocalizations l10n) => switch (_type) {
    SpecialDateType.birthday => l10n.dateTitleHintBirthday,
    SpecialDateType.anniversary => l10n.dateTitleHintAnniversary,
    SpecialDateType.other => l10n.dateTitleHintOther,
  };

  Future<void> _pickDate() async {
    final picked = await pickAnnualDate(context, title: context.l10n.dateWhenLabel, initial: _date);
    if (picked == null || !mounted) return;

    setState(() {
      _date = picked.value;
      _dateError = null;
    });
  }

  Future<void> _save(Household household) async {
    final l10n = context.l10n;
    final title = _title.text.trim();
    final date = _date;

    final titleError = title.isEmpty
        ? l10n.errorDateTitleRequired
        : textLength(title) > Limits.specialDateTitle
        ? l10n.errorNameLong
        : null;
    final dateError = date == null ? l10n.errorDateRequired : null;

    if (titleError != null || dateError != null) {
      return setState(() {
        _titleError = titleError;
        _dateError = dateError;
      });
    }

    final account = ref.read(accountProvider);
    if (account == null || _saving) return;
    setState(() => _saving = true);

    final existing = widget.date;
    if (existing == null) {
      // Belum berpasangan: semuanya disimpan di Ruang Pribadi.
      final space = _shared && household.isPaired ? household.shared : (household.personal ?? household.shared);
      if (space == null) return;
      await account.dates.create(spaceId: space.id, type: _type, title: title, date: date!.toContract());
    } else {
      await account.dates.edit(existing.id, type: _type, title: title, date: date!.toContract());
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete(SpecialDate date) async {
    final l10n = context.l10n;
    final confirmed = await confirmDialog(
      context,
      title: l10n.dateDeleteConfirmTitle(date.title),
      body: l10n.dateDeleteConfirmBody,
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    await ref.read(accountProvider)?.dates.delete(date.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final household = ref.watch(householdProvider);
    final title = _editing ? l10n.dateSheetEdit : l10n.dateSheetNew;

    if (household == null) {
      return AppSheet(
        title: title,
        children: const [SkeletonBox(height: AppDimens.fieldHeight)],
      );
    }

    final existing = widget.date;
    final private = existing == null ? !_shared : !household.isShared(existing.spaceId);

    return AppSheet(
      title: title,
      footer: PrimaryButton(label: l10n.commonSave, onPressed: _saving ? null : () => _save(household)),
      children: [
        LabeledField(
          label: l10n.dateTypeLabel,
          child: Wrap(
            spacing: AppDimens.gap8,
            children: [
              for (final type in SpecialDateType.values)
                AppFilterChip(
                  label: typeLabel(l10n, type),
                  icon: typeIcon(type),
                  selected: _type == type,
                  onTap: () => setState(() => _type = type),
                ),
            ],
          ),
        ),
        LabeledField(
          label: l10n.dateTitleLabel,
          child: TextField(
            controller: _title,
            style: text.inputStrong,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(hintText: _hint(l10n), errorText: _titleError),
            onChanged: (_) {
              if (_titleError != null) setState(() => _titleError = null);
            },
          ),
        ),
        LabeledField(
          label: l10n.dateWhenLabel,
          help: l10n.dateWhenHelp,
          child: FieldButton(
            label: _date?.format() ?? l10n.dateWhenPick,
            filled: _date != null,
            icon: Symbols.calendar_today_rounded,
            errorText: _dateError,
            onTap: _pickDate,
          ),
        ),
        // Ruang hanya dipilih saat membuat, dan hanya kalau sudah punya Ruang Bersama.
        if (existing == null && household.isPaired)
          LabeledField(
            label: l10n.spaceWhereLabel,
            help: private ? l10n.dateWherePrivateHelp : null,
            child: SegmentedControl<bool>(
              semanticLabel: l10n.spaceWhereLabel,
              selected: _shared,
              onChanged: (shared) => setState(() => _shared = shared),
              segments: [
                Segment(value: true, label: l10n.labelShared),
                Segment(value: false, label: l10n.labelPersonal),
              ],
            ),
          ),
        if (existing != null && private && household.isPaired)
          Row(
            children: [
              Icon(Symbols.lock_rounded, size: AppDimens.iconXs, color: palette.muted),
              const SizedBox(width: AppDimens.gap4),
              Expanded(child: Text(l10n.datesInPrivate, style: text.small)),
            ],
          ),
        if (existing != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _delete(existing),
              style: TextButton.styleFrom(foregroundColor: palette.danger),
              icon: const Icon(Symbols.delete_rounded, size: AppDimens.iconMd),
              label: Text(l10n.dateDelete),
            ),
          ),
      ],
    );
  }
}
