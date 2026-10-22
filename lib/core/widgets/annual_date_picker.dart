import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../utils/dates.dart';
import 'controls.dart';

/// Hasil [pickAnnualDate]. [value] `null` berarti tanggalnya dihapus.
class AnnualDatePick {
  const AnnualDatePick(this.value);

  final AnnualDate? value;
}

/// Pilih tanggal tahunan (tanggal lahir, hari jadi). Tahun boleh dikosongkan.
///
/// [clearLabel] menampilkan tombol hapus kalau sudah ada tanggal. Mengembalikan
/// `null` kalau dibatalkan.
Future<AnnualDatePick?> pickAnnualDate(
  BuildContext context, {
  required String title,
  AnnualDate? initial,
  String? clearLabel,
}) => showDialog<AnnualDatePick>(
  context: context,
  builder: (_) => _AnnualDateDialog(title: title, initial: initial, clearLabel: clearLabel),
);

/// Tombol berbentuk isian teks, untuk nilai yang dipilih lewat dialog.
class FieldButton extends StatelessWidget {
  const FieldButton({
    super.key,
    required this.label,
    required this.filled,
    required this.icon,
    required this.onTap,
    this.errorText,
  });

  final String label;

  /// `false` menampilkan [label] sebagai petunjuk (warna `muted`).
  final bool filled;
  final IconData icon;
  final VoidCallback? onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final error = errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: palette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.fieldRadius),
            side: BorderSide(color: error == null ? palette.line : palette.danger, width: AppDimens.borderWidth),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppDimens.fieldHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.fieldSidePadding),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: context.text.input.copyWith(color: filled ? palette.text : palette.muted),
                      ),
                    ),
                    Icon(icon, size: AppDimens.iconMd),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: AppDimens.gap6),
          Text(error, style: context.text.small.copyWith(color: palette.danger)),
        ],
      ],
    );
  }
}

class _AnnualDateDialog extends StatefulWidget {
  const _AnnualDateDialog({required this.title, this.initial, this.clearLabel});

  final String title;
  final AnnualDate? initial;
  final String? clearLabel;

  @override
  State<_AnnualDateDialog> createState() => _AnnualDateDialogState();
}

class _AnnualDateDialogState extends State<_AnnualDateDialog> {
  late int _day = widget.initial?.day ?? 1;
  late int _month = widget.initial?.month ?? 1;
  late final TextEditingController _year = TextEditingController(text: widget.initial?.year?.toString() ?? '');
  String? _error;

  @override
  void dispose() {
    _year.dispose();
    super.dispose();
  }

  void _submit() {
    final yearText = _year.text.trim();
    final date = AnnualDate(year: yearText.isEmpty ? null : int.tryParse(yearText), month: _month, day: _day);

    // Dicek dengan kalender: 30 Februari ditolak, 29 Februari boleh tanpa tahun.
    if ((yearText.isNotEmpty && date.year == null) || !date.isValid) {
      return setState(() => _error = context.l10n.birthInvalid);
    }
    Navigator.of(context).pop(AnnualDatePick(date));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;
    final clearLabel = widget.clearLabel;

    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: LabeledField(
                    label: l10n.birthDay,
                    child: DropdownButtonFormField<int>(
                      initialValue: _day,
                      style: text.input,
                      items: [for (var day = 1; day <= 31; day++) DropdownMenuItem(value: day, child: Text('$day'))],
                      onChanged: (day) => setState(() {
                        _day = day ?? _day;
                        _error = null;
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.gap8),
                Expanded(
                  flex: 3,
                  child: LabeledField(
                    label: l10n.birthMonth,
                    child: DropdownButtonFormField<int>(
                      initialValue: _month,
                      style: text.input,
                      isExpanded: true,
                      items: [
                        for (var month = 1; month <= 12; month++)
                          DropdownMenuItem(
                            value: month,
                            child: Text(DateFormat('MMMM', dateLocale).format(DateTime.utc(2000, month))),
                          ),
                      ],
                      onChanged: (month) => setState(() {
                        _month = month ?? _month;
                        _error = null;
                      }),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.gap12),
            LabeledField(
              label: l10n.birthYear,
              child: TextField(
                controller: _year,
                style: text.input,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                decoration: InputDecoration(errorText: _error),
                onChanged: (_) => setState(() => _error = null),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.initial != null && clearLabel != null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(const AnnualDatePick(null)),
            style: TextButton.styleFrom(foregroundColor: context.palette.danger),
            child: Text(clearLabel),
          ),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        TextButton(onPressed: _submit, child: Text(l10n.commonSave)),
      ],
    );
  }
}
