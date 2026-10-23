import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/session/account.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../spaces/domain/household.dart';
import '../domain/task_list.dart';
import '../domain/task_views.dart';
import 'pickers.dart';
import 'task_actions.dart';
import 'task_text.dart';

/// Detail tugas. Tersimpan otomatis, tanpa tombol Simpan.
///
/// Teks dikirim 1 detik setelah berhenti mengetik, dan langsung ditulis ke antrean
/// saat app masuk ke latar belakang atau layar ditutup.
class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({super.key, required this.taskId, this.fromHome = false, this.backTo});

  final String taskId;

  /// Dibuka dari Beranda; tombol kembali pulang ke sana.
  final bool fromHome;

  /// Alamat yang dibuka tombol kembali, misalnya checklist perjalanan. Mengalahkan [fromHome].
  final String? backTo;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> with WidgetsBindingObserver {
  static const Duration _typingPause = Duration(seconds: 1);

  final TextEditingController _title = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _notesFocus = FocusNode();

  Timer? _debounce;
  bool _titleDirty = false;
  bool _notesDirty = false;
  bool _filled = false;

  /// Disimpan supaya perubahan terakhir masih bisa ditulis saat layar ditutup.
  Account? _account;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fill(_find(ref.read(taskItemsProvider)));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _flush();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flush();
    _title.dispose();
    _notes.dispose();
    _titleFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  TaskItem? _find(List<TaskItem>? items) => items?.where((item) => item.task.id == widget.taskId).firstOrNull;

  /// Isi kolom teks dari cache. Kolom yang sedang disunting tidak ditimpa.
  void _fill(TaskItem? item) {
    if (item == null) return;

    final title = item.task.title;
    final notes = item.task.notes ?? '';

    if (!_filled || (!_titleDirty && !_titleFocus.hasFocus && _title.text != title)) _title.text = title;
    if (!_filled || (!_notesDirty && !_notesFocus.hasFocus && _notes.text != notes)) _notes.text = notes;
    _filled = true;
  }

  void _typed({required bool title}) {
    setState(() {
      if (title) {
        _titleDirty = true;
      } else {
        _notesDirty = true;
      }
    });
    _debounce?.cancel();
    _debounce = Timer(_typingPause, _flush);
  }

  /// Tulis perubahan teks ke cache dan antrean.
  void _flush() {
    _debounce?.cancel();
    final account = _account;
    if (account == null) return;

    if (_titleDirty) {
      _titleDirty = false;
      unawaited(account.tasks.rename(widget.taskId, _title.text));
    }
    if (_notesDirty) {
      _notesDirty = false;
      unawaited(account.tasks.setNotes(widget.taskId, _notes.text));
    }
  }

  void _back() => context.go(widget.backTo ?? (widget.fromHome ? Routes.home : Routes.tasks));

  Future<void> _delete() async {
    // Perubahan teks yang belum tersimpan tidak perlu lagi.
    _debounce?.cancel();
    _titleDirty = false;
    _notesDirty = false;

    await deleteTask(context, ref, widget.taskId);
    if (mounted) _back();
  }

  Future<void> _pickDate(TaskItem item) async {
    final picked = await pickDate(context, today: item.today, initial: item.task.dueDate);
    if (picked == null) return;
    await _account?.tasks.setDue(widget.taskId, date: picked, time: item.task.dueTime);
  }

  Future<void> _pickTime(TaskItem item) async {
    final picked = await pickTime(context, initial: item.task.dueTime);
    if (picked == null) return;
    await _account?.tasks.setDue(widget.taskId, date: item.task.dueDate, time: picked);
  }

  Future<void> _pickList(TaskItem item, List<TaskList> lists, Household household) async {
    // Pindah daftar hanya bisa di dalam ruang yang sama.
    final sameSpace = lists.where((list) => list.spaceId == item.space.id).toList();
    final picked = await showListPicker(context, lists: sameSpace, household: household, selectedId: item.list.id);
    if (picked == null || picked.id == item.list.id) return;
    await _account?.tasks.moveToList(widget.taskId, picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;

    _account = ref.watch(accountProvider);
    ref.listen(taskItemsProvider, (_, items) => _fill(_find(items)));

    final household = ref.watch(householdProvider);
    final items = ref.watch(taskItemsProvider);
    final lists = ref.watch(activeListsProvider);
    final item = _find(items);

    final header = ScreenHeader(
      title: l10n.taskDetailTitle,
      onBack: _back,
      trailing: item == null
          ? null
          : AppIconButton(
              icon: Symbols.delete_rounded,
              label: l10n.taskDelete,
              color: palette.danger,
              onPressed: _delete,
            ),
    );

    final Widget body;

    if (household == null || items == null || lists == null) {
      body = PageBody(
        children: [
          header,
          const SizedBox(height: AppDimens.gap12),
          const SkeletonCard(lines: 4),
        ],
      );
    } else if (item == null) {
      // Dihapus (mungkin oleh pasangan) atau belum sampai di HP ini.
      body = PageBody(
        children: [
          header,
          const SizedBox(height: AppDimens.gap24),
          EmptyState(
            message: l10n.taskGone,
            icon: Symbols.event_busy_rounded,
            actionLabel: l10n.commonBack,
            onAction: _back,
          ),
        ],
      );
    } else {
      final task = item.task;
      final clock = ref.watch(spaceClockProvider);
      final assignee = item.assigneeFor(household.me.id);
      final titleEmpty = _filled && _title.text.trim().isEmpty;
      final sameSpaceLists = lists.where((list) => list.spaceId == item.space.id).length;

      body = PageBody(
        children: [
          header,
          const SizedBox(height: AppDimens.gap12),
          LabeledField(
            label: l10n.addTaskWhat,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(-AppDimens.gap10, AppDimens.gap2),
                  child: TaskCheckButton(
                    done: item.isCompleted,
                    label: item.isCompleted ? l10n.taskMarkUndone(task.title) : l10n.taskMarkDone(task.title),
                    onChanged: (_) => toggleTask(context, ref, item),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _title,
                    focusNode: _titleFocus,
                    style: text.inputStrong,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      errorText: titleEmpty
                          ? l10n.errorTitleRequired
                          : textLength(_title.text.trim()) > Limits.taskTitle
                          ? l10n.errorTitleLong
                          : null,
                    ),
                    onChanged: (_) => _typed(title: true),
                  ),
                ),
              ],
            ),
          ),
          if (item.isCompleted) ...[
            const SizedBox(height: AppDimens.gap6),
            StatusText(
              text: completedText(l10n, item, household, clock),
              icon: Symbols.check_circle_rounded,
              color: palette.muted,
              style: text.caption,
            ),
          ],
          const SizedBox(height: AppDimens.gap14),
          LabeledField(
            label: l10n.taskNotesLabel,
            child: TextField(
              controller: _notes,
              focusNode: _notesFocus,
              style: text.input,
              minLines: 3,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: l10n.taskNotesHint,
                errorText: textLength(_notes.text.trim()) > Limits.taskNotes ? l10n.errorNotesLong : null,
              ),
              onChanged: (_) => _typed(title: false),
            ),
          ),
          const SizedBox(height: AppDimens.gap14),
          LabeledField(
            label: l10n.addTaskWhen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppDimens.gap8,
                  children: [
                    AppFilterChip(
                      label: task.dueDate == null
                          ? l10n.addTaskPickDate
                          : dayLabel(l10n, task.dueDate!, today: item.today),
                      icon: Symbols.calendar_today_rounded,
                      selected: task.dueDate != null,
                      onTap: () => _pickDate(item),
                    ),
                    // Jam butuh tanggal.
                    if (task.dueDate != null)
                      AppFilterChip(
                        label: task.dueTime == null ? l10n.addTaskPickTime : formatClock(task.dueTime!),
                        icon: Symbols.schedule_rounded,
                        selected: task.dueTime != null,
                        onTap: () => _pickTime(item),
                      ),
                    if (task.dueTime != null)
                      AppFilterChip(
                        label: l10n.addTaskNoTime,
                        selected: false,
                        onTap: () => _account?.tasks.setDue(widget.taskId, date: task.dueDate, time: null),
                      ),
                  ],
                ),
                if (item.isOverdue)
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimens.gap4),
                    child: StatusText(text: dueText(l10n, item), icon: Symbols.error_rounded, color: palette.warn),
                  ),
                if (task.dueDate != null)
                  TextButton(
                    onPressed: () => _account?.tasks.setDue(widget.taskId, date: null, time: null),
                    child: Text(l10n.taskClearDate),
                  ),
              ],
            ),
          ),
          SwitchRow(
            title: l10n.addTaskImportant,
            icon: Symbols.flag_rounded,
            titleStyle: text.rowTitlePlain,
            value: task.isImportant,
            onChanged: (value) => _account?.tasks.setImportant(widget.taskId, value),
          ),
          // Pasangan dan Kita hanya ada di Ruang Bersama.
          if (item.space.isShared) ...[
            const SizedBox(height: AppDimens.gap6),
            LabeledField(
              label: l10n.addTaskWho,
              child: Wrap(
                spacing: AppDimens.gap8,
                children: [for (final option in Assignee.values) _assigneeOption(context, option, assignee, household)],
              ),
            ),
          ],
          const SizedBox(height: AppDimens.gap14),
          LabeledField(
            label: l10n.taskListLabel,
            child: ListPickerField(
              list: item.list,
              household: household,
              // Item checklist tetap di checklist perjalanannya.
              onTap: !item.isChecklistItem && sameSpaceLists > 1 ? () => _pickList(item, lists, household) : null,
            ),
          ),
          const SizedBox(height: AppDimens.gap16),
          Text(l10n.taskAutosaved, style: text.small, textAlign: TextAlign.center),
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

  Widget _assigneeOption(BuildContext context, Assignee option, Assignee selected, Household household) {
    final chip = assigneeChip(context, option, household);
    return AppFilterChip(
      label: chip.label,
      leading: PersonDots(colors: chip.colors),
      selected: option == selected,
      onTap: () => _account?.tasks.setAssignees(widget.taskId, assigneeIdsFor(option, household)),
    );
  }
}
