import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/currencies.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../spaces/domain/household.dart';
import '../../tasks/presentation/list_form_sheet.dart';
import '../domain/savings_goal.dart';

/// Buka lembar buat target baru, atau ubah [goal] kalau diisi. Mengembalikan target yang baru dibuat.
///
/// [spaceId] menetapkan ruang target baru, misalnya ruang perjalanan yang akan menautkannya,
/// dan [initialName] mengisi namanya lebih dulu.
Future<SavingsGoal?> showGoalFormSheet(
  BuildContext context, {
  SavingsGoal? goal,
  String? spaceId,
  String? initialName,
}) => showAppSheet<SavingsGoal>(
  context,
  builder: (_) => GoalFormSheet(goal: goal, spaceId: spaceId, initialName: initialName),
);

/// Lembar pilihan mata uang. Mengembalikan kode yang dipilih.
Future<String?> showCurrencyPicker(BuildContext context, {required String title, required String selected}) =>
    showAppSheet<String>(
      context,
      builder: (sheetContext) => AppSheet(
        title: title,
        children: [
          for (final currency in supportedCurrencies)
            Semantics(
              container: true,
              button: true,
              selected: currency.code == selected,
              child: InkWell(
                onTap: () => Navigator.of(sheetContext).pop(currency.code),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: AppDimens.minTouch),
                  child: Row(
                    children: [
                      Expanded(child: Text(currency.label, style: sheetContext.text.rowTitle)),
                      SizedBox(
                        width: AppDimens.iconLg,
                        child: currency.code == selected
                            ? Icon(Symbols.check_rounded, size: AppDimens.iconLg, color: sheetContext.palette.brand)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );

/// Isian nominal dengan simbol mata uang dan pemisah ribuan otomatis.
class MoneyField extends StatelessWidget {
  const MoneyField({
    super.key,
    required this.controller,
    required this.currency,
    this.errorText,
    this.autofocus = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String currency;
  final String? errorText;
  final bool autofocus;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final info = currencyOf(currency);

    return TextField(
      controller: controller,
      autofocus: autofocus,
      style: context.text.inputStrong,
      keyboardType: TextInputType.numberWithOptions(decimal: info.decimals > 0),
      inputFormatters: [MoneyInputFormatter(currency)],
      decoration: InputDecoration(
        prefixText: '${info.symbol} ',
        prefixStyle: context.text.inputStrong,
        errorText: errorText,
      ),
      onChanged: (_) => onChanged?.call(),
    );
  }
}

/// Lembar buat atau ubah target: nama, emoji, nominal, mata uang, dan tanggal target.
class GoalFormSheet extends ConsumerStatefulWidget {
  const GoalFormSheet({super.key, this.goal, this.spaceId, this.initialName});

  final SavingsGoal? goal;

  /// Ruang target baru yang sudah ditetapkan; pilihan Bersama atau Pribadi tidak ditampilkan.
  final String? spaceId;
  final String? initialName;

  @override
  ConsumerState<GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends ConsumerState<GoalFormSheet> {
  late final TextEditingController _name = TextEditingController(text: widget.goal?.name ?? widget.initialName ?? '');
  late final TextEditingController _emoji = TextEditingController(text: widget.goal?.emoji ?? '');
  late final TextEditingController _amount = TextEditingController(
    text: widget.goal == null ? '' : moneyInputText(widget.goal!.targetAmount, widget.goal!.currency),
  );
  late String? _currency = widget.goal?.currency;
  late String? _targetDate = widget.goal?.targetDate;
  bool? _shared;
  String? _nameError;
  String? _amountError;

  bool get _editing => widget.goal != null;

  @override
  void dispose() {
    _name.dispose();
    _emoji.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickCurrency(String current) async {
    final l10n = context.l10n;
    final picked = await showCurrencyPicker(context, title: l10n.goalCurrencyLabel, selected: current);
    if (picked == null || picked == current || !mounted) return;

    setState(() {
      // Jumlah desimal bisa berbeda, jadi nominal yang sudah diketik dikosongkan.
      if (currencyOf(picked).decimals != currencyOf(current).decimals) _amount.clear();
      _currency = picked;
    });
  }

  Future<void> _pickDate(String today) async {
    final picked = await pickDate(context, today: today, initial: _targetDate);
    if (picked != null && mounted) setState(() => _targetDate = picked);
  }

  Future<void> _save(Household household, String currency) async {
    final l10n = context.l10n;
    final name = _name.text.trim();
    final amount = parseMoneyInput(_amount.text, currency);

    final nameError = name.isEmpty
        ? l10n.errorGoalNameRequired
        : textLength(name) > Limits.name
        ? l10n.errorNameLong
        : null;
    final amountError = amount == null || amount < 1
        ? l10n.errorAmountRequired
        : !isValidAmount(amount)
        ? l10n.errorAmountTooLarge
        : null;

    if (nameError != null || amountError != null) {
      return setState(() {
        _nameError = nameError;
        _amountError = amountError;
      });
    }

    final account = ref.read(accountProvider);
    if (account == null) return;

    final goal = widget.goal;
    SavingsGoal? created;
    if (goal == null) {
      final fixed = widget.spaceId;
      final space = fixed != null
          ? household.spaceOf(fixed)
          : (_shared ?? household.isPaired)
          ? household.shared
          : household.personal;
      final target = space ?? household.personal ?? household.shared;
      if (target == null) return;
      created = await account.savings.createGoal(
        spaceId: target.id,
        name: name,
        emoji: _emoji.text,
        targetAmount: amount!,
        currency: currency,
        targetDate: _targetDate,
      );
    } else {
      await account.savings.editGoal(
        goal.id,
        name: name,
        emoji: _emoji.text,
        targetAmount: amount!,
        targetDate: _targetDate,
      );
    }

    if (mounted) Navigator.of(context).pop(created);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final household = ref.watch(householdProvider);

    if (household == null) {
      return AppSheet(
        title: l10n.goalFormNew,
        children: const [SkeletonBox(height: AppDimens.fieldHeight)],
      );
    }

    // Bawaan target baru: mata uang dari profil.
    final currency = _currency ?? household.me.defaultCurrency;
    final spaceId = widget.goal?.spaceId ?? widget.spaceId ?? (household.shared ?? household.personal)?.id ?? '';
    final spaceFixed = _editing || widget.spaceId != null;
    final today = ref.watch(spaceClockProvider).today(household.timezoneOf(spaceId));

    return AppSheet(
      title: _editing ? l10n.goalFormEdit : l10n.goalFormNew,
      footer: PrimaryButton(label: l10n.commonSave, onPressed: () => _save(household, currency)),
      children: [
        LabeledField(
          label: l10n.goalNameLabel,
          child: TextField(
            controller: _name,
            autofocus: !_editing,
            style: text.inputStrong,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: l10n.goalNameHint, errorText: _nameError),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
        ),
        LabeledField(
          label: l10n.listEmojiLabel,
          child: EmojiField(controller: _emoji),
        ),
        LabeledField(
          label: l10n.goalAmountLabel,
          child: MoneyField(
            controller: _amount,
            currency: currency,
            errorText: _amountError,
            onChanged: () {
              if (_amountError != null) setState(() => _amountError = null);
            },
          ),
        ),
        LabeledField(
          label: l10n.goalCurrencyLabel,
          // Mata uang hanya bisa dipilih saat target dibuat.
          help: _editing ? l10n.goalCurrencyLocked : null,
          child: Align(
            alignment: Alignment.centerLeft,
            child: AppFilterChip(
              label: currencyOf(currency).label,
              selected: false,
              onTap: _editing ? null : () => _pickCurrency(currency),
            ),
          ),
        ),
        LabeledField(
          label: l10n.goalDateLabel,
          child: Wrap(
            spacing: AppDimens.gap8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppFilterChip(
                label: _targetDate == null ? l10n.goalDatePick : formatDateMedium(_targetDate!),
                icon: Symbols.calendar_today_rounded,
                selected: _targetDate != null,
                onTap: () => _pickDate(today),
              ),
              if (_targetDate != null)
                TextButton(onPressed: () => setState(() => _targetDate = null), child: Text(l10n.goalDateClear)),
            ],
          ),
        ),
        // Ruang hanya dipilih saat membuat; target tidak bisa pindah ruang.
        if (!spaceFixed && household.isPaired)
          LabeledField(
            label: l10n.spaceWhereLabel,
            child: SegmentedControl<bool>(
              semanticLabel: l10n.spaceWhereLabel,
              selected: _shared ?? true,
              onChanged: (shared) => setState(() => _shared = shared),
              segments: [
                Segment(value: true, label: l10n.labelShared),
                Segment(value: false, label: l10n.labelPersonal),
              ],
            ),
          ),
        if (spaceFixed && !household.isShared(spaceId))
          Row(
            children: [
              Icon(Symbols.lock_rounded, size: AppDimens.iconXs, color: palette.muted),
              const SizedBox(width: AppDimens.gap4),
              Text(l10n.labelPersonal, style: text.small),
            ],
          ),
      ],
    );
  }
}
