import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/sync/sync_actions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../spaces/domain/household.dart';
import '../domain/task_list.dart';
import '../domain/task_views.dart';
import 'list_form_sheet.dart';
import 'pickers.dart';
import 'task_row.dart';

/// Tab Tugas: tugas dikelompokkan per daftar, dengan filter status dan penanggung jawab.
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  /// Tugas selesai yang ditampilkan paling banyak sekian, yang terbaru lebih dulu.
  static const int _doneLimit = 100;

  StatusFilter _status = StatusFilter.all;
  PersonFilter _person = PersonFilter.all;
  bool _showDone = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final household = ref.watch(householdProvider);
    final items = ref.watch(taskItemsProvider);
    final lists = ref.watch(activeListsProvider);

    final header = Row(
      children: [
        Expanded(
          child: Semantics(header: true, child: Text(l10n.tasksTitle, style: context.text.homeTitle)),
        ),
        AppIconButton(
          icon: Symbols.playlist_add_rounded,
          label: l10n.tasksNewList,
          outlined: true,
          iconSize: AppDimens.iconLg,
          onPressed: household == null ? null : () => showListFormSheet(context),
        ),
      ],
    );

    if (household == null || items == null || lists == null) {
      return PageBody(
        children: [
          header,
          const SizedBox(height: AppDimens.gap10),
          const SkeletonCard(),
          const SizedBox(height: AppDimens.gap10),
          const SkeletonCard(lines: 2),
        ],
      );
    }

    final meId = household.me.id;
    final partnerId = household.partner?.id;
    final person = household.isPaired ? _person : PersonFilter.all;
    // Item checklist perjalanan tampil di layar perjalanannya, bukan di sini.
    final matching = items
        .where((item) => !item.isChecklistItem && item.matches(person, meId: meId, partnerId: partnerId))
        .toList();
    final open = matching.where((item) => !item.isCompleted).toList();
    final done = matching.where((item) => item.isCompleted).toList()
      ..sort((a, b) => b.task.completedAt!.compareTo(a.task.completedAt!));

    return PageBody(
      onRefresh: () => refreshFromServer(ref),
      bottomPadding: AppDimens.fabClearance,
      children: [
        header,
        const SizedBox(height: AppDimens.gap10),
        SegmentedControl<StatusFilter>(
          semanticLabel: l10n.statusLabel,
          selected: _status,
          onChanged: (status) => setState(() => _status = status),
          segments: [
            Segment(value: StatusFilter.all, label: l10n.statusAll),
            Segment(value: StatusFilter.open, label: l10n.statusOpen),
            Segment(value: StatusFilter.done, label: l10n.statusDone),
          ],
        ),
        // Filter orang hanya berarti kalau sudah punya pasangan.
        if (household.isPaired) ...[
          const SizedBox(height: AppDimens.gap8),
          Semantics(
            container: true,
            label: l10n.filterPeopleLabel,
            child: Wrap(
              spacing: AppDimens.gap8,
              children: [
                _personChip(l10n.peopleAll, PersonFilter.all),
                _personChip(l10n.labelMe, PersonFilter.me),
                _personChip(l10n.labelPartner, PersonFilter.partner),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppDimens.gap8),
        if (_status != StatusFilter.done) ..._openSections(context, lists, open, household, person),
        if (_status == StatusFilter.all && done.isNotEmpty) _doneToggle(context, done.length),
        if (_status == StatusFilter.done || (_status == StatusFilter.all && _showDone))
          _doneSection(context, done, household),
      ],
    );
  }

  Widget _personChip(String label, PersonFilter filter) =>
      AppFilterChip(label: label, selected: _person == filter, onTap: () => setState(() => _person = filter));

  List<Widget> _openSections(
    BuildContext context,
    List<TaskList> lists,
    List<TaskItem> open,
    Household household,
    PersonFilter person,
  ) {
    final sections = <Widget>[];

    for (final list in lists) {
      final tasks = open.where((item) => item.list.id == list.id).toList()
        ..sort((a, b) => a.task.position.compareTo(b.task.position));

      // Saat difilter per orang, daftar tanpa tugas yang cocok tidak perlu tampil.
      if (tasks.isEmpty && person != PersonFilter.all) continue;

      sections
        ..add(_ListCard(list: list, tasks: tasks, household: household))
        ..add(const SizedBox(height: AppDimens.gap10));
    }

    if (sections.isEmpty) {
      sections.add(EmptyState(message: context.l10n.tasksEmptyFiltered, icon: Symbols.task_alt_rounded));
    }
    return sections;
  }

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

  Widget _doneSection(BuildContext context, List<TaskItem> done, Household household) {
    if (done.isEmpty) {
      return EmptyState(message: context.l10n.tasksEmptyDone, icon: Symbols.task_alt_rounded);
    }

    final shown = done.take(_doneLimit).toList();

    return AppCard(
      semanticLabel: context.l10n.statusDone,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.cardPadding, vertical: AppDimens.gap4),
      child: Column(
        children: [
          for (final (index, item) in shown.indexed) ...[
            if (index > 0) const RowDivider(),
            TaskRow(
              key: ValueKey(item.task.id),
              item: item,
              household: household,
              onTap: () => context.go(Routes.task(item.task.id)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Kartu satu daftar: titik warna, nama, label ruang dan jumlah, lalu tugasnya.
class _ListCard extends StatelessWidget {
  const _ListCard({required this.list, required this.tasks, required this.household});

  final TaskList list;
  final List<TaskItem> tasks;
  final Household household;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final shared = household.isShared(list.spaceId);

    return AppCard(
      semanticLabel: list.name,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.cardPadding, vertical: AppDimens.gap4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            container: true,
            button: true,
            label: l10n.manageList(list.name),
            child: InkWell(
              onTap: () => context.go(Routes.manageLists),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppDimens.listHeaderHeight),
                child: Row(
                  children: [
                    ColorDot(color: context.personColor(list.color), size: AppDimens.dotLarge),
                    const SizedBox(width: AppDimens.gap8),
                    Expanded(child: Text(listTitle(list), style: text.sectionTitle)),
                    // Ruang Pribadi ditandai ikon gembok, bukan hanya teks.
                    if (!shared) ...[
                      Icon(Symbols.lock_rounded, size: AppDimens.iconXs, color: palette.muted),
                      const SizedBox(width: AppDimens.gap4),
                    ],
                    Text(
                      l10n.listSpaceCount(shared ? l10n.labelShared : l10n.labelPersonal, tasks.length),
                      style: text.smallStrong.copyWith(color: palette.muted),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (tasks.isEmpty) ...[
            const RowDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.gap14),
              child: Text(l10n.tasksEmptyList, style: text.caption),
            ),
          ],
          for (final item in tasks) ...[
            const RowDivider(),
            TaskRow(
              key: ValueKey(item.task.id),
              item: item,
              household: household,
              onTap: () => context.go(Routes.task(item.task.id)),
            ),
          ],
        ],
      ),
    );
  }
}
