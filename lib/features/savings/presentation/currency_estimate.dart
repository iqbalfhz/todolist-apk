import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../spaces/domain/household.dart';
import '../domain/exchange_rates.dart';

/// Perkiraan kurs (v1.x): teks yang tampil, dan teks untuk pembaca layar tanpa tanda "≈".
typedef Estimate = ({String text, String spoken});

/// Yang dibutuhkan untuk perkiraan kurs: kurs ECB tersimpan, mata uang bawaan, dan tahun ini.
class EstimateContext {
  const EstimateContext({required this.rates, required this.currency, required this.currentYear});

  final ExchangeRates rates;

  /// Mata uang bawaan akun (`default_currency`).
  final String currency;
  final int currentYear;

  /// Perkiraan [amount] (dan [target] kalau ada) dari mata uang [from] ke mata uang bawaan,
  /// misalnya "≈ Rp1.813.610 · kurs ECB 2 Nov". Selalu dengan "ECB" dan tanggal kursnya, sesuai
  /// syarat pemakaian ulang statistik ECB. `null` kalau [from] sama dengan mata uang bawaan.
  Estimate? of(AppLocalizations l10n, {required String from, required int amount, int? target}) {
    if (from == currency) return null;
    final converted = rates.convert(amount, from: from, to: currency);
    final convertedTarget = target == null ? null : rates.convert(target, from: from, to: currency);
    if (converted == null || (target != null && convertedTarget == null)) return null;

    final date = formatDayMonth(rates.date, currentYear: currentYear);
    final money = formatMoney(converted, currency);
    if (convertedTarget == null) {
      return (text: l10n.estimateAmount(money, date), spoken: l10n.estimateAmountSpoken(money, date));
    }
    final targetMoney = formatMoney(convertedTarget, currency);
    return (
      text: l10n.estimateGoal(money, targetMoney, date),
      spoken: l10n.estimateGoalSpoken(money, targetMoney, date),
    );
  }
}

/// `null` selama kurs belum pernah diambil atau profil belum terbaca; perkiraan lalu tidak tampil.
final estimateContextProvider = Provider<EstimateContext?>((ref) {
  final me = ref.watch(householdProvider)?.me;
  final rates = ref.watch(exchangeRatesProvider).value;
  if (me == null || rates == null) return null;
  return EstimateContext(rates: rates, currency: me.defaultCurrency, currentYear: ref.watch(nowProvider).year);
});

/// Baris perkiraan di bawah nominal target yang mata uangnya bukan mata uang bawaan, misalnya
/// "≈ Rp1.813.610 dari Rp9.068.051 · kurs ECB 2 Nov". Kosong kalau tidak perlu atau belum ada kurs.
class GoalEstimate extends ConsumerWidget {
  const GoalEstimate({super.key, required this.currency, required this.saved, required this.target});

  final String currency;
  final int saved;
  final int target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estimate = ref
        .watch(estimateContextProvider)
        ?.of(context.l10n, from: currency, amount: saved, target: target);
    if (estimate == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.gap2),
      child: Text(estimate.text, semanticsLabel: estimate.spoken, style: context.text.small),
    );
  }
}
