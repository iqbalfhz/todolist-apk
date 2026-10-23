import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/sync/sync_actions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../spaces/domain/household.dart';
import '../../tasks/domain/task_views.dart';
import '../../tasks/presentation/task_row.dart';
import '../domain/trip_views.dart';
import 'trip_detail_screen.dart' show ChecklistProgress;

/// Checklist persiapan perjalanan: semua item dengan progresnya, dan isian di bawah untuk
/// menambah item satu per satu tanpa menutup keyboard.
///
/// Itemnya tugas biasa: diketuk membuka Detail tugas (penanggung jawab, tenggat, pengingat),
/// dan yang bertenggat ikut tampil di Tugas hari ini.
class ChecklistScreen extends ConsumerStatefulWidget {
  const ChecklistScreen({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {
  final TextEditingController _input = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _showDone = false;
  String? _error;
  bool _adding = false;

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _back() => context.go(Routes.trip(widget.tripId));

  Future<void> _add(TripItem item) async {
    final l10n = context.l10n;
    final title = _input.text.trim();
    if (title.isEmpty) return;
    if (textLength(title) > Limits.taskTitle) return setState(() => _error = l10n.errorTitleLong);

    final account = ref.read(accountProvider);
    if (account == null || _adding) return;
    setState(() => _adding = true);

    try {
      final checklist = item.checklist ?? await account.trips.checklistFor(item.trip);
      // Penanggung jawab bawaannya Aku, supaya mencatat banyak item tidak mengirim
      // notifikasi titipan ke pasangan; bisa diubah di Detail tugas.
      await account.tasks.create(list: checklist, title: title);
      _input.clear();
    } finally {
      if (mounted) setState(() => _adding = false);
    }
    // Keyboard tetap terbuka untuk item berikutnya.
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final household = ref.watch(householdProvider);
    final trips = ref.watch(tripItemsProvider);
    final item = trips?.where((trip) => trip.trip.id == widget.tripId).firstOrNull;

    final header = ScreenHeader(title: l10n.tripChecklistTitle, onBack: _back);

    final Widget body;
    if (household == null || trips == null) {
      body = PageBody(
        children: [
          header,
          const SizedBox(height: AppDimens.gap12),
          const SkeletonCard(lines: 4),
        ],
      );
    } else if (item == null) {
      body = PageBody(
        children: [
          header,
          const SizedBox(height: AppDimens.gap24),
          EmptyState(
            message: l10n.tripGone,
            icon: Symbols.flight_takeoff_rounded,
            actionLabel: l10n.commonBack,
            onAction: () => context.go(Routes.trips),
          ),
        ],
      );
    } else {
      final open = item.openItems;
      final done = item.items.where((task) => task.isCompleted).toList()
        ..sort((a, b) => b.task.completedAt!.compareTo(a.task.completedAt!));

      body = Column(
        children: [
          Expanded(
            child: PageBody(
              onRefresh: () => refreshFromServer(ref),
              bottomPadding: AppDimens.gap12,
              children: [
                header,
                Text(item.trip.title, style: text.caption),
                const SizedBox(height: AppDimens.gap12),
                if (item.total == 0)
                  AppCard(
                    child: EmptyState(message: l10n.checklistEmpty, icon: Symbols.checklist_rounded),
                  )
                else ...[
                  AppCard(
                    semanticLabel: l10n.tripChecklistTitle,
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.cardPadding, vertical: AppDimens.gap4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ChecklistProgress(item: item),
                        for (final task in open) ...[const RowDivider(), _row(task, household)],
                      ],
                    ),
                  ),
                  if (done.isNotEmpty) ...[const SizedBox(height: AppDimens.gap8), _doneToggle(context, done.length)],
                  if (_showDone && done.isNotEmpty)
                    AppCard(
                      semanticLabel: l10n.statusDone,
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.cardPadding, vertical: AppDimens.gap4),
                      child: Column(
                        children: [
                          for (final (index, task) in done.indexed) ...[
                            if (index > 0) const RowDivider(),
                            _row(task, household),
                          ],
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border(
                top: BorderSide(color: palette.line, width: AppDimens.borderWidth),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(AppDimens.pageSide, AppDimens.gap8, AppDimens.gap8, AppDimens.gap8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    focusNode: _focus,
                    // Checklist yang masih kosong langsung siap diisi.
                    autofocus: item.total == 0,
                    style: text.input,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: l10n.tripChecklistAdd,
                      hintText: l10n.checklistAddHint,
                      errorText: _error,
                    ),
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                    // Mengganti perilaku bawaan supaya keyboard tidak tertutup setelah menambah.
                    onEditingComplete: () => _add(item),
                  ),
                ),
                const SizedBox(width: AppDimens.gap4),
                AppIconButton(
                  icon: Symbols.add_rounded,
                  label: l10n.tripChecklistAdd,
                  color: palette.link,
                  onPressed: _adding ? null : () => _add(item),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: body,
    );
  }

  Widget _row(TaskItem task, Household household) => TaskRow(
    key: ValueKey(task.task.id),
    item: task,
    household: household,
    onTap: () => context.go(Routes.tripTask(widget.tripId, task.task.id, fromChecklist: true)),
  );

  Widget _doneToggle(BuildContext context, int count) {
    final palette = context.palette;

    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        container: true,
        button: true,
        expanded: _showDone,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.segmentItemRadius),
          onTap: () => setState(() => _showDone = !_showDone),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppDimens.minTouch),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.gap4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.tasksDoneCount(count),
                    style: context.text.chipSelected.copyWith(color: palette.muted),
                  ),
                  const SizedBox(width: AppDimens.gap6),
                  Icon(
                    _showDone ? Symbols.expand_less_rounded : Symbols.expand_more_rounded,
                    size: AppDimens.iconSm,
                    color: palette.muted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
