import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/widgets.dart';
import '../../comments/domain/comment.dart';
import '../../comments/presentation/comments_section.dart';
import '../../spaces/domain/household.dart';
import '../domain/savings_entry.dart';
import '../domain/savings_views.dart';
import 'deposit_sheet.dart';

/// Buka detail setoran atau penarikan di target bersama (v1.x), dengan reaksi dan komentarnya.
Future<void> showEntryDetailSheet(
  BuildContext context, {
  required String goalId,
  required String entryId,
  required Household household,
}) => showAppSheet<void>(
  context,
  builder: (_) => EntryDetailSheet(goalId: goalId, entryId: entryId, household: household),
);

/// Detail satu setoran di Ruang Bersama: nominal ("+Rp200.000" atau "−Rp350.000"), siapa dan
/// tanggalnya, catatan, tombol Ubah (lembar setor), lalu reaksi dan komentar. Setoran di Ruang
/// Pribadi langsung membuka lembar setor, karena tidak punya komentar.
class EntryDetailSheet extends ConsumerWidget {
  const EntryDetailSheet({super.key, required this.goalId, required this.entryId, required this.household});

  final String goalId;
  final String entryId;
  final Household household;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = context.text;
    final progress = ref.watch(goalProgressProvider)?.where((item) => item.goal.id == goalId).firstOrNull;
    final entry = progress?.entries.where((item) => item.id == entryId).firstOrNull;

    if (progress == null || entry == null) {
      // Dihapus (mungkin oleh pasangan) selagi lembar ini terbuka.
      return AppSheet(
        title: l10n.entryDetailDeposit,
        children: [EmptyState(message: l10n.entryGone, icon: Symbols.savings_rounded)],
      );
    }

    final currency = progress.goal.currency;
    final who = personLabel(l10n, household, entry.userId);
    final day = formatDayShort(entry.entryDate, currentYear: parseYmd(progress.today).year);
    final note = entry.note;

    return AppSheet(
      title: entry.isWithdrawal ? l10n.entryDetailWithdrawal : l10n.entryDetailDeposit,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formatMoney(entry.signedAmount, currency, withSign: true), style: text.amountLarge),
            const SizedBox(height: AppDimens.gap2),
            Text('$who · $day', style: text.caption),
            if (note != null) ...[
              const SizedBox(height: AppDimens.gap8),
              Text(note, style: text.body.copyWith(color: context.palette.text)),
            ],
            const SizedBox(height: AppDimens.gap4),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                showDepositSheet(
                  context,
                  goal: progress.goal,
                  today: progress.today,
                  saved: progress.saved,
                  entry: entry,
                );
              },
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              icon: const Icon(Symbols.edit_rounded, size: AppDimens.iconMd),
              label: Text(entry.isWithdrawal ? l10n.withdrawEditTitle : l10n.depositEditTitle),
            ),
          ],
        ),
        CommentsSection(
          subject: Subject(SubjectType.savingsEntry, entry.id),
          spaceId: entry.spaceId,
          household: household,
        ),
      ],
    );
  }
}
