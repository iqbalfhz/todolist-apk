import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../spaces/domain/household.dart';
import '../data/task_list_repository.dart';
import '../domain/task_list.dart';
import 'task_text.dart';

/// Buka lembar buat daftar baru, atau ubah [list] kalau diisi.
Future<void> showListFormSheet(BuildContext context, {TaskList? list}) =>
    showAppSheet<void>(context, builder: (_) => ListFormSheet(list: list));

/// Enam lingkaran pilihan warna; yang terpilih diberi cincin dan tanda centang.
class ColorPicker extends StatelessWidget {
  const ColorPicker({super.key, required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;

    return Wrap(
      spacing: AppDimens.gap6,
      children: [
        for (final key in PersonColors.keys)
          Semantics(
            container: true,
            button: true,
            selected: key == selected,
            label: l10n.colorSemantic(colorName(l10n, key)),
            onTap: () => onChanged(key),
            excludeSemantics: true,
            child: InkResponse(
              onTap: () => onChanged(key),
              radius: AppDimens.minTouch / 2,
              child: SizedBox(
                width: AppDimens.minTouch,
                height: AppDimens.minTouch,
                child: Center(
                  child: Container(
                    width: AppDimens.swatchRing,
                    height: AppDimens.swatchRing,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: key == selected ? palette.text : palette.text.withValues(alpha: 0),
                        width: AppDimens.borderWidthStrong,
                      ),
                    ),
                    child: Container(
                      width: AppDimens.swatchDot,
                      height: AppDimens.swatchDot,
                      decoration: BoxDecoration(color: context.personColor(key), shape: BoxShape.circle),
                      // Pilihan tidak hanya ditandai warna cincin.
                      child: key == selected
                          ? Icon(Symbols.check_rounded, size: AppDimens.iconSm, color: palette.surface)
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Isian emoji: hanya gugus emoji terakhir yang diketik yang disimpan.
class EmojiField extends StatelessWidget {
  const EmojiField({super.key, required this.controller, this.errorText, this.onChanged});

  final TextEditingController controller;
  final String? errorText;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    style: context.text.input,
    decoration: InputDecoration(hintText: context.l10n.listEmojiHint, errorText: errorText),
    onChanged: (value) {
      // App memastikan isinya satu emoji: huruf dan emoji tambahan dibuang.
      final emoji = lastEmojiOf(value) ?? '';
      if (emoji != value) {
        controller.value = TextEditingValue(
          text: emoji,
          selection: TextSelection.collapsed(offset: emoji.length),
        );
      }
      onChanged?.call();
    },
  );
}

/// Lembar buat atau ubah daftar: nama, emoji, warna, dan (saat membuat) ruangnya.
class ListFormSheet extends ConsumerStatefulWidget {
  const ListFormSheet({super.key, this.list});

  final TaskList? list;

  @override
  ConsumerState<ListFormSheet> createState() => _ListFormSheetState();
}

class _ListFormSheetState extends ConsumerState<ListFormSheet> {
  late final TextEditingController _name = TextEditingController(text: widget.list?.name ?? '');
  late final TextEditingController _emoji = TextEditingController(text: widget.list?.emoji ?? '');
  late String _color = widget.list?.color ?? PersonColors.keys.first;
  bool? _shared;
  String? _nameError;

  bool get _editing => widget.list != null;

  @override
  void dispose() {
    _name.dispose();
    _emoji.dispose();
    super.dispose();
  }

  Future<void> _save(Household household) async {
    final l10n = context.l10n;
    final name = _name.text.trim();

    if (name.isEmpty) return setState(() => _nameError = l10n.errorListNameRequired);
    if (textLength(name) > Limits.name) return setState(() => _nameError = l10n.errorNameLong);

    final account = ref.read(accountProvider);
    if (account == null) return;

    final list = widget.list;
    if (list == null) {
      final space = (_shared ?? household.isPaired) ? household.shared : household.personal;
      final target = space ?? household.personal ?? household.shared;
      if (target == null) return;
      await account.lists.create(spaceId: target.id, name: name, emoji: _emoji.text, color: _color);
    } else {
      await account.lists.edit(list.id, name: name, emoji: _emoji.text, color: _color);
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _archive(TaskList list) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      if (list.archivedAt == null) {
        await ref.read(accountProvider)?.lists.archive(list.id);
      } else {
        await ref.read(accountProvider)?.lists.unarchive(list.id);
      }
      navigator.pop();
    } on LastActiveListException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.listLastActive)));
    }
  }

  Future<void> _delete(TaskList list) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final tasks = ref.read(tasksProvider).value ?? const [];
    final count = tasks.where((task) => task.taskListId == list.id).length;

    final confirmed = await confirmDialog(
      context,
      title: l10n.listDeleteConfirmTitle(list.name),
      body: l10n.listDeleteConfirmBody(count),
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;

    try {
      await ref.read(accountProvider)?.lists.delete(list.id);
      navigator.pop();
    } on LastActiveListException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.listLastActive)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final household = ref.watch(householdProvider);
    final list = widget.list;

    if (household == null) {
      return AppSheet(
        title: l10n.listNew,
        children: const [SkeletonBox(height: AppDimens.fieldHeight)],
      );
    }

    return AppSheet(
      title: _editing ? l10n.listEdit : l10n.listNew,
      children: [
        LabeledField(
          label: l10n.listNameLabel,
          child: TextField(
            controller: _name,
            autofocus: !_editing,
            style: context.text.inputStrong,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: l10n.listNameHint, errorText: _nameError),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
        ),
        LabeledField(
          label: l10n.listEmojiLabel,
          child: EmojiField(controller: _emoji),
        ),
        LabeledField(
          label: l10n.listColorLabel,
          child: ColorPicker(selected: _color, onChanged: (color) => setState(() => _color = color)),
        ),
        // Ruang hanya dipilih saat membuat; daftar tidak bisa pindah ruang.
        if (!_editing && household.isPaired)
          LabeledField(
            label: l10n.spaceWhereLabel,
            child: SegmentedControl<bool>(
              semanticLabel: l10n.spaceWhereLabel,
              selected: _shared ?? true,
              onChanged: (shared) => setState(() => _shared = shared),
              segments: [
                Segment(value: true, label: l10n.labelShared),
                Segment(value: false, label: l10n.labelPersonal),
              ],
            ),
          ),
        PrimaryButton(label: l10n.commonSave, onPressed: () => _save(household)),
        if (list != null)
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _archive(list),
                  icon: Icon(
                    list.archivedAt == null ? Symbols.archive_rounded : Symbols.unarchive_rounded,
                    size: AppDimens.iconMd,
                  ),
                  label: Text(list.archivedAt == null ? l10n.listArchive : l10n.listUnarchive),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _delete(list),
                  style: TextButton.styleFrom(foregroundColor: palette.danger),
                  icon: const Icon(Symbols.delete_rounded, size: AppDimens.iconMd),
                  label: Text(l10n.listDelete),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
