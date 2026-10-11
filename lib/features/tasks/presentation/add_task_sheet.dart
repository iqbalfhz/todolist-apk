import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/local_store.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../spaces/domain/household.dart';
import '../domain/task_list.dart';
import '../domain/task_views.dart';
import 'pickers.dart';
import 'task_text.dart';

/// Buka lembar "Tugas baru". [dueToday] mengisi "Hari ini" sejak awal (dibuka dari Beranda).
Future<void> showAddTaskSheet(BuildContext context, {bool dueToday = false}) =>
    showAppSheet<void>(context, builder: (_) => AddTaskSheet(dueToday: dueToday));

/// Lembar tambah cepat. Satu-satunya isian wajib adalah "Mau mengerjakan apa?".
class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({super.key, this.dueToday = false});

  final bool dueToday;

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final TextEditingController _title = TextEditingController();

  /// Selisih hari dari "hari ini" (0 atau 1), atau tanggal pilihan sendiri.
  int? _dayOffset;
  String? _customDate;
  String? _time;
  Assignee _assignee = Assignee.me;
  String? _listId;
  bool _important = false;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.dueToday) _dayOffset = 0;
    _restoreLastList();
  }

  /// Daftar yang terakhir dipakai menjadi pilihan awal.
  Future<void> _restoreLastList() async {
    final lastId = await ref.read(accountProvider)?.store.meta(MetaKeys.lastListId);
    if (!mounted || lastId == null || _listId != null) return;

    final lists = ref.read(activeListsProvider) ?? const <TaskList>[];
    if (lists.any((list) => list.id == lastId)) setState(() => _listId = lastId);
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  TaskList? _selectedList(List<TaskList> lists, Household household) {
    final chosen = lists.where((list) => list.id == _listId).firstOrNull;
    if (chosen != null) return chosen;

    // Bawaan: daftar aktif pertama di Ruang Bersama kalau ada, selain itu di Ruang Pribadi.
    final space = household.shared ?? household.personal;
    return (space == null ? null : firstActiveList(lists, space.id)) ?? lists.firstOrNull;
  }

  String? _date(String today) {
    if (_customDate != null) return _customDate;
    return _dayOffset == null ? null : addDays(today, _dayOffset!);
  }

  void _pickAssignee(Assignee assignee, List<TaskList> lists, Household household, TaskList current) {
    setState(() {
      _assignee = assignee;
      // Pasangan dan Kita hanya ada di Ruang Bersama, jadi pilihan daftar ikut pindah ke sana.
      final shared = household.shared;
      if (assignee != Assignee.me && shared != null && current.spaceId != shared.id) {
        _listId = firstActiveList(lists, shared.id)?.id ?? _listId;
      }
    });
  }

  Future<void> _pickList(List<TaskList> lists, Household household, TaskList current) async {
    final picked = await showListPicker(context, lists: lists, household: household, selectedId: current.id);
    if (picked == null || !mounted) return;

    setState(() {
      _listId = picked.id;
      if (!household.isShared(picked.spaceId)) _assignee = Assignee.me;
    });
  }

  Future<void> _pickCustomDate(String today) async {
    final picked = await pickDate(context, today: today, initial: _date(today));
    if (picked == null || !mounted) return;

    setState(() {
      final offset = daysBetween(today, picked);
      _dayOffset = offset == 0 || offset == 1 ? offset : null;
      _customDate = _dayOffset == null ? picked : null;
    });
  }

  Future<void> _pickTime() async {
    final picked = await pickTime(context, initial: _time);
    if (picked != null && mounted) setState(() => _time = picked);
  }

  void _toggleDay(int offset) => setState(() {
    _customDate = null;
    _dayOffset = _dayOffset == offset ? null : offset;
    if (_dayOffset == null) _time = null;
  });

  Future<void> _save(TaskList list, Household household, String today) async {
    final l10n = context.l10n;
    final title = _title.text.trim();

    if (title.isEmpty) return setState(() => _error = l10n.errorTitleRequired);
    if (textLength(title) > Limits.taskTitle) return setState(() => _error = l10n.errorTitleLong);

    final account = ref.read(accountProvider);
    if (account == null || _saving) return;
    setState(() => _saving = true);

    final shared = household.isShared(list.spaceId);
    await account.tasks.create(
      list: list,
      title: title,
      dueDate: _date(today),
      dueTime: _time,
      assigneeIds: assigneeIdsFor(shared ? _assignee : Assignee.me, household),
      important: _important,
    );
    await account.store.setMeta(MetaKeys.lastListId, list.id);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;
    final household = ref.watch(householdProvider);
    final lists = ref.watch(activeListsProvider);

    if (household == null || lists == null) {
      return AppSheet(
        title: l10n.addTaskTitle,
        children: const [SkeletonBox(height: AppDimens.fieldHeight)],
      );
    }

    final list = _selectedList(lists, household);
    if (list == null) {
      return AppSheet(
        title: l10n.addTaskTitle,
        children: [EmptyState(message: l10n.listLastActive)],
      );
    }

    final today = ref.watch(spaceClockProvider).today(household.timezoneOf(list.spaceId));
    final date = _date(today);
    final shared = household.isShared(list.spaceId);
    final assignee = shared ? _assignee : Assignee.me;

    return AppSheet(
      title: l10n.addTaskTitle,
      children: [
        LabeledField(
          label: l10n.addTaskWhat,
          child: TextField(
            controller: _title,
            autofocus: true,
            style: text.inputStrong,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(errorText: _error),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _save(list, household, today),
          ),
        ),
        LabeledField(
          label: l10n.addTaskWhen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppDimens.gap8,
                children: [
                  AppFilterChip(label: l10n.dueToday, selected: _dayOffset == 0, onTap: () => _toggleDay(0)),
                  AppFilterChip(label: l10n.dueTomorrow, selected: _dayOffset == 1, onTap: () => _toggleDay(1)),
                  AppFilterChip(
                    label: _customDate == null
                        ? l10n.addTaskPickDate
                        : formatDayShort(_customDate!, currentYear: parseYmd(today).year),
                    icon: Symbols.calendar_today_rounded,
                    selected: _customDate != null,
                    onTap: () => _pickCustomDate(today),
                  ),
                ],
              ),
              // Jam butuh tanggal.
              if (date != null)
                Wrap(
                  spacing: AppDimens.gap8,
                  children: [
                    AppFilterChip(
                      label: _time == null ? l10n.addTaskPickTime : formatClock(_time!),
                      icon: Symbols.schedule_rounded,
                      selected: _time != null,
                      onTap: _pickTime,
                    ),
                    AppFilterChip(
                      label: l10n.addTaskNoTime,
                      selected: _time == null,
                      onTap: () => setState(() => _time = null),
                    ),
                  ],
                ),
            ],
          ),
        ),
        // Pasangan dan Kita hanya ada kalau sudah punya Ruang Bersama.
        if (household.isPaired)
          LabeledField(
            label: l10n.addTaskWho,
            child: Wrap(
              spacing: AppDimens.gap8,
              children: [
                for (final option in Assignee.values)
                  _assigneeOption(context, option, assignee, lists, household, list),
              ],
            ),
          ),
        ListPickerField(
          list: list,
          household: household,
          onTap: lists.length > 1 ? () => _pickList(lists, household, list) : null,
        ),
        SwitchRow(
          title: l10n.addTaskImportant,
          icon: Symbols.flag_rounded,
          titleStyle: text.rowTitlePlain,
          minHeight: AppDimens.chipHeight,
          value: _important,
          onChanged: (value) => setState(() => _important = value),
        ),
        PrimaryButton(label: l10n.commonSave, onPressed: _saving ? null : () => _save(list, household, today)),
      ],
    );
  }

  Widget _assigneeOption(
    BuildContext context,
    Assignee option,
    Assignee selected,
    List<TaskList> lists,
    Household household,
    TaskList list,
  ) {
    final chip = assigneeChip(context, option, household);
    return AppFilterChip(
      label: chip.label,
      leading: PersonDots(colors: chip.colors),
      selected: option == selected,
      onTap: () => _pickAssignee(option, lists, household, list),
    );
  }
}
