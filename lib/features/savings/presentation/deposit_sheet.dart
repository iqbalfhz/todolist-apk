import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../tasks/presentation/task_text.dart';
import '../domain/savings_entry.dart';
import '../domain/savings_goal.dart';
import 'goal_form_sheet.dart';

/// Buka lembar setor untuk [goal], lembar ambil kalau [withdrawal] (v1.x), atau ubah [entry]
/// kalau diisi (jenisnya mengikuti [entry]). [today] adalah hari ini di zona waktu ruang
/// target, dan [saved] total bersih yang terkumpul saat ini.
Future<void> showDepositSheet(
  BuildContext context, {
  required SavingsGoal goal,
  required String today,
  required int saved,
  SavingsEntry? entry,
  bool withdrawal = false,
}) => showAppSheet<void>(
  context,
  builder: (_) =>
      DepositSheet(goal: goal, today: today, saved: saved, entry: entry, withdrawal: entry?.isWithdrawal ?? withdrawal),
);

/// Lembar setor atau ambil: nominal dengan keyboard angka, tanggal (bawaan hari ini), dan
/// catatan opsional. Penarikan tidak boleh melebihi yang terkumpul; server menerimanya, jadi
/// layar inilah yang mencegahnya (kontrak, Penarikan tabungan).
class DepositSheet extends ConsumerStatefulWidget {
  const DepositSheet({
    super.key,
    required this.goal,
    required this.today,
    required this.saved,
    this.entry,
    this.withdrawal = false,
  });

  final SavingsGoal goal;
  final String today;
  final int saved;
  final SavingsEntry? entry;
  final bool withdrawal;

  /// Paling banyak yang bisa diambil: yang terkumpul, ditambah nominal penarikan yang sedang
  /// diubah (karena nominal itu diganti, bukan ditambah).
  int get withdrawable => math.max(0, saved + (entry?.isWithdrawal ?? false ? entry!.amount : 0));

  @override
  ConsumerState<DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends ConsumerState<DepositSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: widget.entry == null ? '' : moneyInputText(widget.entry!.amount, widget.goal.currency),
  );
  late final TextEditingController _note = TextEditingController(text: widget.entry?.note ?? '');
  late String _date = widget.entry?.entryDate ?? widget.today;
  String? _amountError;
  String? _noteError;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await pickDate(context, today: widget.today, initial: _date);
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final amount = parseMoneyInput(_amount.text, widget.goal.currency);

    final currency = widget.goal.currency;
    final amountError = amount == null || amount < 1
        ? l10n.errorAmountRequired
        : !isValidAmount(amount)
        ? l10n.errorAmountTooLarge
        : widget.withdrawal && amount > widget.withdrawable
        ? l10n.withdrawTooMuch(formatMoney(widget.withdrawable, currency))
        : null;
    final noteError = textLength(_note.text.trim()) > Limits.entryNote ? l10n.errorNoteLong : null;

    if (amountError != null || noteError != null) {
      return setState(() {
        _amountError = amountError;
        _noteError = noteError;
      });
    }

    final account = ref.read(accountProvider);
    if (account == null) return;

    final entry = widget.entry;
    if (entry == null) {
      await account.savings.createEntry(
        goal: widget.goal,
        amount: amount!,
        entryDate: _date,
        note: _note.text,
        withdrawal: widget.withdrawal,
      );
    } else {
      await account.savings.editEntry(entry.id, amount: amount!, entryDate: _date, note: _note.text);
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete(SavingsEntry entry) async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);

    final confirmed = await confirmDialog(
      context,
      title: entry.isWithdrawal
          ? l10n.withdrawDeleteConfirm(formatMoney(entry.amount, widget.goal.currency))
          : l10n.depositDeleteConfirm(formatMoney(entry.amount, widget.goal.currency)),
      body: widget.goal.name,
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;

    await ref.read(accountProvider)?.savings.deleteEntry(entry.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entry = widget.entry;
    final withdrawal = widget.withdrawal;

    return AppSheet(
      title: withdrawal
          ? (entry == null ? l10n.withdrawTitle : l10n.withdrawEditTitle)
          : (entry == null ? l10n.depositTitle : l10n.depositEditTitle),
      footer: PrimaryButton(label: l10n.commonSave, onPressed: _save),
      children: [
        LabeledField(
          label: withdrawal ? l10n.withdrawAmountLabel : l10n.depositAmountLabel,
          help: withdrawal ? l10n.withdrawAvailable(formatMoney(widget.withdrawable, widget.goal.currency)) : null,
          child: MoneyField(
            controller: _amount,
            currency: widget.goal.currency,
            autofocus: entry == null,
            errorText: _amountError,
            onChanged: () {
              if (_amountError != null) setState(() => _amountError = null);
            },
          ),
        ),
        LabeledField(
          label: l10n.depositDateLabel,
          child: Align(
            alignment: Alignment.centerLeft,
            child: AppFilterChip(
              label: dayLabel(l10n, _date, today: widget.today),
              icon: Symbols.calendar_today_rounded,
              selected: true,
              onTap: _pickDate,
            ),
          ),
        ),
        LabeledField(
          label: l10n.depositNoteLabel,
          child: TextField(
            controller: _note,
            style: context.text.input,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: withdrawal ? l10n.withdrawNoteHint : l10n.depositNoteHint,
              errorText: _noteError,
            ),
            onChanged: (_) {
              if (_noteError != null) setState(() => _noteError = null);
            },
          ),
        ),
        if (entry != null)
          TextButton.icon(
            onPressed: () => _delete(entry),
            style: TextButton.styleFrom(foregroundColor: context.palette.danger),
            icon: const Icon(Symbols.delete_rounded, size: AppDimens.iconMd),
            label: Text(entry.isWithdrawal ? l10n.withdrawDelete : l10n.depositDelete),
          ),
      ],
    );
  }
}
