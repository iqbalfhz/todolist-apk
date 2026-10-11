import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../spaces/domain/household.dart';
import '../domain/task_list.dart';

/// Tombol pilihan daftar: titik warna, nama, dan keterangan "Daftar bersama" atau "Daftar pribadi".
class ListPickerField extends StatelessWidget {
  const ListPickerField({super.key, required this.list, required this.household, required this.onTap});

  final TaskList list;
  final Household household;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimens.fieldRadius),
      side: BorderSide(color: palette.line, width: AppDimens.borderWidth),
    );

    return Semantics(
      container: true,
      button: true,
      label: l10n.addTaskPickList,
      child: Material(
        color: palette.surface,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppDimens.fieldHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.fieldSidePadding, vertical: AppDimens.gap8),
              child: Row(
                children: [
                  ColorDot(color: context.personColor(list.color), size: AppDimens.dotLarge),
                  const SizedBox(width: AppDimens.gap10),
                  Expanded(child: Text(listTitle(list), style: text.rowTitle)),
                  const SizedBox(width: AppDimens.gap8),
                  Text(
                    household.isShared(list.spaceId) ? l10n.addTaskListShared : l10n.addTaskListPersonal,
                    style: text.caption,
                  ),
                  if (onTap != null) Icon(Symbols.chevron_right_rounded, size: AppDimens.iconMd, color: palette.muted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Nama daftar dengan emojinya di depan, kalau ada.
String listTitle(TaskList list) => list.emoji == null ? list.name : '${list.emoji} ${list.name}';

/// Lembar pilihan daftar. Mengembalikan daftar yang dipilih.
Future<TaskList?> showListPicker(
  BuildContext context, {
  required List<TaskList> lists,
  required Household household,
  required String selectedId,
}) => showAppSheet<TaskList>(
  context,
  builder: (sheetContext) {
    final l10n = sheetContext.l10n;
    final palette = sheetContext.palette;
    final text = sheetContext.text;

    return AppSheet(
      title: l10n.addTaskPickList,
      children: [
        for (final list in lists)
          Semantics(
            container: true,
            button: true,
            selected: list.id == selectedId,
            child: InkWell(
              onTap: () => Navigator.of(sheetContext).pop(list),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppDimens.minTouch),
                child: Row(
                  children: [
                    ColorDot(color: sheetContext.personColor(list.color), size: AppDimens.dotLarge),
                    const SizedBox(width: AppDimens.gap10),
                    Expanded(child: Text(listTitle(list), style: text.rowTitle)),
                    Text(
                      household.isShared(list.spaceId) ? l10n.addTaskListShared : l10n.addTaskListPersonal,
                      style: text.caption,
                    ),
                    const SizedBox(width: AppDimens.gap8),
                    SizedBox(
                      width: AppDimens.iconLg,
                      child: list.id == selectedId
                          ? Icon(Symbols.check_rounded, size: AppDimens.iconLg, color: palette.brand)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  },
);
