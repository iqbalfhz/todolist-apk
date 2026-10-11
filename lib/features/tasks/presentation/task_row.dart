import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../spaces/domain/household.dart';
import '../domain/task_views.dart';
import 'task_actions.dart';
import 'task_text.dart';

/// Satu baris tugas: tombol centang, judul, keterangan, dan chip penanggung jawab.
class TaskRow extends ConsumerWidget {
  const TaskRow({
    super.key,
    required this.item,
    required this.household,
    required this.onTap,
    this.showListName = false,
    this.minHeight = AppDimens.rowMinHeight,
  });

  final TaskItem item;
  final Household household;
  final VoidCallback onTap;

  /// Di Beranda, nama daftar ikut ditulis di keterangan ("Hari ini, 17.00 · Belanja").
  final bool showListName;
  final double minHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = context.text;
    final title = item.task.title;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Row(
          children: [
            Transform.translate(
              offset: const Offset(-AppDimens.gap10, 0),
              child: TaskCheckButton(
                done: item.isCompleted,
                label: item.isCompleted ? l10n.taskMarkUndone(title) : l10n.taskMarkDone(title),
                onChanged: (_) => toggleTask(context, ref, item),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimens.gap6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: item.isCompleted ? text.rowTitleDone : text.rowTitle),
                    const SizedBox(height: AppDimens.gap2),
                    _caption(context, ref),
                  ],
                ),
              ),
            ),
            // Chip penanggung jawab tidak tampil di Ruang Pribadi.
            if (item.space.isShared) ...[const SizedBox(width: AppDimens.gap8), _chip(context)],
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context) {
    final chip = assigneeChip(context, item.assigneeFor(household.me.id), household);
    return AssigneeChip(label: chip.label, colors: chip.colors);
  }

  Widget _caption(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;

    if (item.isCompleted) {
      return Text(completedText(l10n, item, household, ref.watch(spaceClockProvider)), style: text.caption);
    }

    final due = dueText(l10n, item);
    final suffix = showListName ? ' · ${item.list.name}' : '';

    if (item.isOverdue) {
      return StatusText(text: '$due$suffix', icon: Symbols.error_rounded, color: palette.warn);
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppDimens.gap4,
      children: [
        if (showListName && item.task.dueTime != null)
          Icon(Symbols.schedule_rounded, size: AppDimens.iconXs, color: palette.muted),
        Text('$due$suffix', style: text.caption),
        if (item.task.isImportant) ...[
          Text('·', style: text.caption),
          Icon(Symbols.flag_rounded, size: AppDimens.iconXs, color: palette.muted),
          Text(l10n.dueImportant, style: text.caption),
        ],
      ],
    );
  }
}
