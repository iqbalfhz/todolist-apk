import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/sync/sync_actions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../home/presentation/home_screen.dart' show goalTitle;
import '../../memories/domain/memory_views.dart';
import '../../savings/domain/savings_views.dart';
import '../../savings/presentation/goal_form_sheet.dart';
import '../../spaces/domain/household.dart';
import '../../tasks/presentation/task_row.dart';
import '../domain/trip_views.dart';
import 'trip_form_sheet.dart';
import 'trip_text.dart';
import 'trips_screen.dart' show SaveAsMemoryButton;

enum _TripAction { edit, delete }

/// Detail perjalanan: hitung mundur dan tanggal, progres persiapan dengan beberapa item
/// yang belum beres, dana dari target tabungan yang ditautkan, dan catatan.
class TripDetailScreen extends ConsumerWidget {
  const TripDetailScreen({super.key, required this.tripId});

  final String tripId;

  /// Item yang belum beres yang tampil sebelum "Lihat semua".
  static const int _preview = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final household = ref.watch(householdProvider);
    final trips = ref.watch(tripItemsProvider);
    final item = trips?.where((trip) => trip.trip.id == tripId).firstOrNull;
    void back() => context.go(Routes.trips);

    final Widget body;

    if (household == null || trips == null) {
      body = PageBody(
        children: [
          ScreenHeader(onBack: back),
          const SizedBox(height: AppDimens.gap12),
          const SkeletonCard(lines: 3),
          const SizedBox(height: AppDimens.gap12),
          const SkeletonCard(lines: 2),
        ],
      );
    } else if (item == null) {
      // Dihapus (mungkin oleh pasangan) atau belum sampai di HP ini.
      body = PageBody(
        children: [
          ScreenHeader(onBack: back),
          const SizedBox(height: AppDimens.gap24),
          EmptyState(
            message: l10n.tripGone,
            icon: Symbols.flight_takeoff_rounded,
            actionLabel: l10n.commonBack,
            onAction: back,
          ),
        ],
      );
    } else {
      final trip = item.trip;
      final open = item.openItems;
      final notes = trip.notes;

      body = PageBody(
        onRefresh: () => refreshFromServer(ref),
        children: [
          ScreenHeader(
            title: trip.title,
            onBack: back,
            trailing: PopupMenuButton<_TripAction>(
              tooltip: l10n.commonOptions,
              icon: const Icon(Symbols.more_vert_rounded, size: AppDimens.iconLg),
              onSelected: (action) => _onAction(context, ref, action, item),
              itemBuilder: (_) => [
                PopupMenuItem(value: _TripAction.edit, child: Text(l10n.commonEdit)),
                PopupMenuItem(value: _TripAction.delete, child: Text(l10n.commonDelete)),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.gap12),
          _SummaryCard(item: item, household: household),
          if (item.isDone) ...[
            const SizedBox(height: AppDimens.gap10),
            _SectionHeader(title: l10n.tripMemoriesTitle),
            _MemoriesCard(item: item),
          ],
          const SizedBox(height: AppDimens.gap10),
          _SectionHeader(
            title: l10n.tripChecklistTitle,
            action: item.total == 0 ? null : l10n.commonSeeAll,
            onAction: () => context.go(Routes.tripChecklist(trip.id)),
          ),
          AppCard(
            semanticLabel: l10n.tripChecklistTitle,
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.cardPadding, vertical: AppDimens.gap4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (item.total == 0)
                  EmptyState(
                    message: l10n.tripChecklistEmpty,
                    icon: Symbols.checklist_rounded,
                    actionLabel: l10n.tripChecklistAdd,
                    onAction: () => context.go(Routes.tripChecklist(trip.id)),
                  )
                else ...[
                  ChecklistProgress(item: item),
                  for (final task in open.take(_preview)) ...[
                    const RowDivider(),
                    TaskRow(
                      key: ValueKey(task.task.id),
                      item: task,
                      household: household,
                      onTap: () => context.go(Routes.tripTask(trip.id, task.task.id)),
                    ),
                  ],
                  const RowDivider(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => context.go(Routes.tripChecklist(trip.id)),
                      icon: Icon(
                        open.length > _preview ? Symbols.checklist_rounded : Symbols.add_rounded,
                        size: AppDimens.iconMd,
                      ),
                      label: Text(
                        open.length > _preview ? l10n.tripChecklistMore(open.length - _preview) : l10n.tripChecklistAdd,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppDimens.gap10),
          _SectionHeader(
            title: l10n.tripFundTitle,
            action: item.goal == null ? null : l10n.tripFundChange,
            onAction: () => pickTripGoal(context, ref, item),
          ),
          _FundCard(item: item),
          if (notes != null) ...[
            const SizedBox(height: AppDimens.gap10),
            _SectionHeader(title: l10n.tripNotesTitle),
            AppCard(
              semanticLabel: l10n.tripNotesTitle,
              child: Text(notes, style: context.text.body),
            ),
          ],
        ],
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) back();
      },
      child: body,
    );
  }

  Future<void> _onAction(BuildContext context, WidgetRef ref, _TripAction action, TripItem item) async {
    final l10n = context.l10n;
    final trip = item.trip;

    switch (action) {
      case _TripAction.edit:
        await showTripFormSheet(context, trip: trip);
      case _TripAction.delete:
        final confirmed = await confirmDialog(
          context,
          title: l10n.tripDeleteConfirmTitle(trip.title),
          body: l10n.tripDeleteConfirmBody(item.total),
          confirmLabel: l10n.commonDelete,
          destructive: true,
        );
        if (!confirmed || !context.mounted) return;
        await ref.read(accountProvider)?.trips.delete(trip.id);
        if (context.mounted) context.go(Routes.trips);
    }
  }
}

/// Judul bagian dengan tombol teks di kanan, misalnya "Persiapan" dan "Lihat semua".
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: AppDimens.minTouch),
    child: Row(
      children: [
        Expanded(
          child: Semantics(header: true, child: Text(title, style: context.text.sectionTitle)),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(action!),
          ),
      ],
    ),
  );
}

/// Hitung mundur besar, tanggal dan lamanya, tujuan, dan penanda Ruang Pribadi.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.item, required this.household});

  final TripItem item;
  final Household household;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final trip = item.trip;
    final dates = tripDates(l10n, item, currentYear: currentYearOf(item));
    final destination = trip.destination;

    Widget detail(IconData icon, String value) => Padding(
      padding: const EdgeInsets.only(top: AppDimens.gap4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppDimens.gap2),
            child: Icon(icon, size: AppDimens.iconXs, color: palette.muted),
          ),
          const SizedBox(width: AppDimens.gap6),
          Expanded(child: Text(value, style: text.caption)),
        ],
      ),
    );

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Container(
              width: AppDimens.featureCircle,
              height: AppDimens.featureCircle,
              decoration: BoxDecoration(color: palette.soft, shape: BoxShape.circle),
              child: Icon(tripStatusIcon(item.status), size: AppDimens.iconFeature, color: palette.brand),
            ),
          ),
          const SizedBox(width: AppDimens.gap14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Angka hitung mundur dibuat besar; status tanpa tanggal cukup ukuran biasa.
                Text(tripCountdown(l10n, item), style: trip.startDate == null ? text.countdown : text.countdownLarge),
                if (dates != null) detail(Symbols.calendar_today_rounded, dates),
                if (destination != null) detail(Symbols.location_on_rounded, destination),
                if (!household.isShared(trip.spaceId) && household.isPaired)
                  detail(Symbols.lock_rounded, l10n.labelPersonal),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kenangan dari perjalanan yang sudah selesai, dan tombol untuk menyimpan yang baru.
class _MemoriesCard extends ConsumerWidget {
  const _MemoriesCard({required this.item});

  final TripItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = context.text;
    final memories = memoriesOfTrip(ref.watch(memoryItemsProvider), item.trip.id);
    final currentYear = currentYearOf(item);

    return AppCard(
      semanticLabel: l10n.tripMemoriesTitle,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.cardPadding, vertical: AppDimens.gap4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final memory in memories) ...[
            InkWell(
              onTap: () => context.go(Routes.memory(memory.memory.id)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppDimens.rowMinHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppDimens.gap8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(memory.memory.title, style: text.rowTitle),
                            Text(
                              [
                                formatDayShort(memory.memory.visitedOn, currentYear: currentYear),
                                l10n.memoryPhotoCount(memory.photos.length),
                              ].join(' · '),
                              style: text.caption,
                            ),
                          ],
                        ),
                      ),
                      Icon(Symbols.chevron_right_rounded, size: AppDimens.iconLg, color: context.palette.muted),
                    ],
                  ),
                ),
              ),
            ),
            const RowDivider(),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: SaveAsMemoryButton(tripId: item.trip.id),
          ),
        ],
      ),
    );
  }
}

/// "7 dari 12 beres", bar progres, dan persennya; atau ucapan kalau semuanya sudah beres.
class ChecklistProgress extends StatelessWidget {
  const ChecklistProgress({super.key, required this.item});

  final TripItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;
    final allDone = item.total > 0 && item.done == item.total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.gap10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.tripChecklistProgress(item.done, item.total), style: text.caption)),
              // Bar progres selalu disertai angka persen.
              Text(l10n.percent(item.percent), style: text.captionStrong),
            ],
          ),
          const SizedBox(height: AppDimens.gap6),
          ProgressBar(fraction: item.fraction, height: AppDimens.progressThick),
          if (allDone) ...[
            const SizedBox(height: AppDimens.gap10),
            StatusText(text: l10n.tripChecklistAllDone, icon: Symbols.celebration_rounded, color: context.palette.ok),
          ],
        ],
      ),
    );
  }
}

/// Dana perjalanan: progres target yang ditautkan, atau ajakan menautkan target.
class _FundCard extends ConsumerWidget {
  const _FundCard({required this.item});

  final TripItem item;

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final trips = ref.read(accountProvider)?.trips;
    final name = context.l10n.tripFundDefaultName(item.trip.title);
    final goal = await showGoalFormSheet(
      context,
      spaceId: item.trip.spaceId,
      initialName: textLength(name) <= Limits.name ? name : item.trip.title,
    );
    if (goal != null) await trips?.linkGoal(item.trip.id, goal.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = context.text;
    final goal = item.goal;
    final candidates = linkableGoals(ref.watch(goalProgressProvider), item);

    if (goal == null) {
      return AppCard(
        semanticLabel: l10n.tripFundTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.tripFundEmpty, style: text.body),
            const SizedBox(height: AppDimens.gap4),
            Wrap(
              spacing: AppDimens.gap8,
              children: [
                if (candidates.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => pickTripGoal(context, ref, item),
                    icon: const Icon(Symbols.link_rounded, size: AppDimens.iconMd),
                    label: Text(l10n.tripFundPick),
                  ),
                TextButton.icon(
                  onPressed: () => _create(context, ref),
                  icon: const Icon(Symbols.add_rounded, size: AppDimens.iconMd),
                  label: Text(l10n.tripFundCreate),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final currency = goal.goal.currency;
    return AppCard(
      semanticLabel: l10n.tripFundTitle,
      onTap: () => context.go(Routes.tripGoal(item.trip.id, goal.goal.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(goalTitle(goal), style: text.rowTitle)),
              // Bar progres selalu disertai angka persen.
              Text(l10n.percent(goal.percent), style: text.rowTitle),
            ],
          ),
          const SizedBox(height: AppDimens.gap8),
          ProgressBar(fraction: goal.fraction, height: AppDimens.progressThick),
          const SizedBox(height: AppDimens.gap8),
          Text(
            l10n.savingsOf(formatMoney(goal.saved, currency), formatMoney(goal.goal.targetAmount, currency)),
            style: text.caption,
          ),
        ],
      ),
    );
  }
}

/// Target di ruang perjalanan [item] yang bisa ditautkan: belum dihapus dan tidak diarsipkan.
List<GoalProgress> linkableGoals(List<GoalProgress>? goals, TripItem item) => [
  for (final goal in goals ?? const <GoalProgress>[])
    if (goal.goal.spaceId == item.trip.spaceId && !goal.goal.isArchived) goal,
];

/// Pilih target tabungan untuk perjalanan [item], atau lepas tautannya.
Future<void> pickTripGoal(BuildContext context, WidgetRef ref, TripItem item) async {
  final trips = ref.read(accountProvider)?.trips;
  final candidates = linkableGoals(ref.read(goalProgressProvider), item);
  final picked = await showGoalPicker(context, goals: candidates, selectedId: item.goal?.goal.id);
  if (picked != null) await trips?.linkGoal(item.trip.id, picked.goalId);
}

/// Hasil [showGoalPicker]. [goalId] `null` berarti tautannya dilepas.
class GoalPick {
  const GoalPick(this.goalId);

  final String? goalId;
}

/// Lembar pilihan target tabungan untuk perjalanan, ditambah "Tanpa tabungan" kalau sudah
/// ada yang ditautkan. Mengembalikan `null` kalau ditutup tanpa memilih.
Future<GoalPick?> showGoalPicker(
  BuildContext context, {
  required List<GoalProgress> goals,
  required String? selectedId,
}) => showAppSheet<GoalPick>(
  context,
  builder: (sheetContext) {
    final l10n = sheetContext.l10n;
    final palette = sheetContext.palette;
    final text = sheetContext.text;

    Widget option({required String label, String? trailing, required bool selected, required GoalPick pick}) =>
        Semantics(
          container: true,
          button: true,
          selected: selected,
          child: InkWell(
            onTap: () => Navigator.of(sheetContext).pop(pick),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppDimens.minTouch),
              child: Row(
                children: [
                  Expanded(child: Text(label, style: text.rowTitle)),
                  if (trailing != null) ...[Text(trailing, style: text.caption), const SizedBox(width: AppDimens.gap8)],
                  SizedBox(
                    width: AppDimens.iconLg,
                    child: selected ? Icon(Symbols.check_rounded, size: AppDimens.iconLg, color: palette.brand) : null,
                  ),
                ],
              ),
            ),
          ),
        );

    return AppSheet(
      title: l10n.tripFundPickerTitle,
      children: [
        if (goals.isEmpty) Text(l10n.tripFundPickerEmpty, style: text.body),
        for (final goal in goals)
          option(
            label: goalTitle(goal),
            trailing: l10n.percent(goal.percent),
            selected: goal.goal.id == selectedId,
            pick: GoalPick(goal.goal.id),
          ),
        if (selectedId != null) option(label: l10n.tripFundNone, selected: false, pick: const GoalPick(null)),
      ],
    );
  },
);
