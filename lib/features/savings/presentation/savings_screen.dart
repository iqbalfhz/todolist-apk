import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/sync/sync_actions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/widgets.dart';
import '../../home/presentation/home_screen.dart' show goalTitle;
import '../../spaces/domain/household.dart';
import '../domain/savings_views.dart';
import 'goal_form_sheet.dart';

/// Tab Tabungan: kartu untuk setiap target beserta progresnya.
class SavingsScreen extends ConsumerStatefulWidget {
  const SavingsScreen({super.key});

  @override
  ConsumerState<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends ConsumerState<SavingsScreen> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final household = ref.watch(householdProvider);
    final goals = ref.watch(goalProgressProvider);

    final header = Row(
      children: [
        Expanded(
          child: Semantics(header: true, child: Text(l10n.savingsTitle, style: context.text.homeTitle)),
        ),
        AppIconButton(
          icon: Symbols.add_rounded,
          label: l10n.savingsNewGoal,
          outlined: true,
          iconSize: AppDimens.iconLg,
          onPressed: household == null ? null : () => showGoalFormSheet(context),
        ),
      ],
    );

    if (household == null || goals == null) {
      return PageBody(
        children: [
          header,
          const SizedBox(height: AppDimens.gap12),
          const SkeletonCard(lines: 2),
          const SizedBox(height: AppDimens.gap12),
          const SkeletonCard(lines: 2),
        ],
      );
    }

    final active = goals.where((progress) => !progress.goal.isArchived).toList();
    final archived = goals.where((progress) => progress.goal.isArchived).toList();

    return PageBody(
      onRefresh: () => refreshFromServer(ref),
      children: [
        header,
        const SizedBox(height: AppDimens.gap12),
        if (active.isEmpty)
          EmptyState(
            message: household.isPaired ? l10n.savingsEmpty : l10n.savingsEmptySolo,
            icon: Symbols.savings_rounded,
            actionLabel: l10n.savingsNewGoal,
            onAction: () => showGoalFormSheet(context),
          ),
        for (final progress in active) ...[
          _GoalCard(progress: progress, household: household),
          const SizedBox(height: AppDimens.gap12),
        ],
        if (archived.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              button: true,
              expanded: _showArchived,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppDimens.segmentItemRadius),
                onTap: () => setState(() => _showArchived = !_showArchived),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: AppDimens.minTouch),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.gap4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.savingsArchivedCount(archived.length),
                          style: context.text.chipSelected.copyWith(color: palette.muted),
                        ),
                        const SizedBox(width: AppDimens.gap6),
                        Icon(
                          _showArchived ? Symbols.expand_less_rounded : Symbols.expand_more_rounded,
                          size: AppDimens.iconSm,
                          color: palette.muted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (_showArchived)
          for (final progress in archived) ...[
            _GoalCard(progress: progress, household: household),
            const SizedBox(height: AppDimens.gap12),
          ],
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.progress, required this.household});

  final GoalProgress progress;
  final Household household;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final goal = progress.goal;
    final shared = household.isShared(goal.spaceId);

    return AppCard(
      semanticLabel: goal.name,
      onTap: () => context.go(Routes.goal(goal.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(goalTitle(progress), style: text.rowTitle)),
              // Bar progres selalu disertai angka persen.
              Text(l10n.percent(progress.percent), style: text.rowTitle),
            ],
          ),
          const SizedBox(height: AppDimens.gap8),
          ProgressBar(fraction: progress.fraction, height: AppDimens.progressThick),
          const SizedBox(height: AppDimens.gap8),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.savingsOf(
                    formatMoney(progress.saved, goal.currency),
                    formatMoney(goal.targetAmount, goal.currency),
                  ),
                  style: text.caption,
                ),
              ),
              // Ruang Pribadi ditandai ikon gembok, bukan hanya teks.
              if (!shared) ...[
                Icon(Symbols.lock_rounded, size: AppDimens.iconXs, color: palette.muted),
                const SizedBox(width: AppDimens.gap4),
              ],
              Text(
                shared ? l10n.labelShared : l10n.labelPersonal,
                style: text.smallStrong.copyWith(color: palette.muted),
              ),
            ],
          ),
          if (progress.isAchieved) ...[
            const SizedBox(height: AppDimens.gap8),
            StatusText(
              text: household.isPaired ? l10n.savingsAchieved(goal.name) : l10n.savingsAchievedSolo(goal.name),
              icon: Symbols.celebration_rounded,
              color: palette.ok,
            ),
          ],
        ],
      ),
    );
  }
}
