import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../spaces/domain/household.dart';
import '../../spaces/domain/space.dart';
import '../domain/task_list.dart';
import 'list_form_sheet.dart';
import 'pickers.dart';

/// Kelola daftar: urutkan dengan menggeser, ketuk untuk mengubah, mengarsipkan, atau menghapus.
class ManageListsScreen extends ConsumerWidget {
  const ManageListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final household = ref.watch(householdProvider);
    // Checklist perjalanan dikelola dari perjalanannya: tidak bisa diurutkan, diarsipkan, atau dihapus di sini.
    final lists = ref.watch(taskListsProvider).value?.where((list) => !list.isChecklist).toList();
    final tasks = ref.watch(tasksProvider).value;

    final header = ScreenHeader(
      title: l10n.listsManageTitle,
      onBack: () => context.go(Routes.tasks),
      trailing: AppIconButton(
        icon: Symbols.playlist_add_rounded,
        label: l10n.tasksNewList,
        outlined: true,
        iconSize: AppDimens.iconLg,
        onPressed: household == null ? null : () => showListFormSheet(context),
      ),
    );

    if (household == null || lists == null || tasks == null) {
      return PageBody(
        children: [
          header,
          const SizedBox(height: AppDimens.gap12),
          const SkeletonCard(),
        ],
      );
    }

    final openCounts = <String, int>{};
    for (final task in tasks) {
      if (!task.isCompleted) openCounts.update(task.taskListId, (count) => count + 1, ifAbsent: () => 1);
    }

    final archived = lists.where((list) => list.archivedAt != null && household.spaceOf(list.spaceId) != null).toList();

    return PageBody(
      children: [
        header,
        const SizedBox(height: AppDimens.gap4),
        Text(l10n.listReorderHint, style: context.text.caption),
        for (final space in household.spaces) ...[
          const SizedBox(height: AppDimens.gap12),
          SectionTitle(space.isShared ? l10n.labelShared : l10n.labelPersonal),
          const SizedBox(height: AppDimens.gap8),
          _SpaceLists(
            space: space,
            lists: lists.where((list) => list.spaceId == space.id && list.archivedAt == null).toList(),
            openCounts: openCounts,
          ),
        ],
        if (archived.isNotEmpty) ...[
          const SizedBox(height: AppDimens.gap12),
          SectionTitle(l10n.listArchivedSection),
          const SizedBox(height: AppDimens.gap8),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.cardPadding),
            child: Column(
              children: [
                for (final (index, list) in archived.indexed) ...[
                  if (index > 0) const RowDivider(),
                  _ListRow(list: list, count: openCounts[list.id] ?? 0),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Daftar aktif di satu ruang, bisa digeser untuk diurutkan.
class _SpaceLists extends ConsumerWidget {
  const _SpaceLists({required this.space, required this.lists, required this.openCounts});

  final Space space;
  final List<TaskList> lists;
  final Map<String, int> openCounts;

  /// [target] sudah disesuaikan dengan baris yang dicabut dari [oldIndex].
  void _reorder(WidgetRef ref, int oldIndex, int target) {
    if (target == oldIndex) return;

    final ordered = [...lists];
    final moved = ordered.removeAt(oldIndex);
    ordered.insert(target, moved);

    ref
        .read(accountProvider)
        ?.lists
        .reorder(
          moved.id,
          after: target > 0 ? ordered[target - 1].position : null,
          before: target < ordered.length - 1 ? ordered[target + 1].position : null,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: AppDimens.cardPadding),
    child: ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      onReorderItem: (oldIndex, newIndex) => _reorder(ref, oldIndex, newIndex),
      children: [
        for (final (index, list) in lists.indexed)
          _ListRow(key: ValueKey(list.id), list: list, count: openCounts[list.id] ?? 0, dragIndex: index),
      ],
    ),
  );
}

class _ListRow extends StatelessWidget {
  const _ListRow({super.key, required this.list, required this.count, this.dragIndex});

  final TaskList list;
  final int count;

  /// Posisi di daftar yang bisa digeser; `null` untuk daftar arsip.
  final int? dragIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;

    return Material(
      color: palette.surface,
      child: InkWell(
        onTap: () => showListFormSheet(context, list: list),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppDimens.rowMinHeightSettings),
          child: Row(
            children: [
              if (dragIndex != null)
                ReorderableDragStartListener(
                  index: dragIndex!,
                  child: Semantics(
                    label: l10n.listReorderHandle(list.name),
                    child: SizedBox(
                      width: AppDimens.checkArea,
                      height: AppDimens.minTouch,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(Symbols.drag_indicator_rounded, size: AppDimens.iconLg, color: palette.muted),
                      ),
                    ),
                  ),
                ),
              ColorDot(color: context.personColor(list.color), size: AppDimens.dotLarge),
              const SizedBox(width: AppDimens.gap10),
              Expanded(child: Text(listTitle(list), style: text.rowTitle)),
              Text('$count', style: text.smallStrong.copyWith(color: palette.muted)),
              const SizedBox(width: AppDimens.gap4),
              Icon(Symbols.chevron_right_rounded, size: AppDimens.iconMd, color: palette.muted),
            ],
          ),
        ),
      ),
    );
  }
}
