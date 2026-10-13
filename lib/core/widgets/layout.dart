import 'dart:math' as math;

import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import 'controls.dart';

/// Kepala layar: tombol kembali, judul 20 Bold, dan aksi di kanan.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, this.title, this.onBack, this.trailing});

  final String? title;

  /// `null` menyembunyikan tombol kembali.
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: AppDimens.iconButton),
    child: Row(
      children: [
        if (onBack != null)
          Transform.translate(
            offset: const Offset(-AppDimens.gap10, 0),
            child: BackIconButton(label: context.l10n.commonBack, onPressed: onBack!),
          ),
        Expanded(
          child: title == null
              ? const SizedBox.shrink()
              : Semantics(
                  header: true,
                  child: Text(title!, style: context.text.screenTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
        ),
        ?trailing,
      ],
    ),
  );
}

/// Halaman bergulir dengan padding samping 20 dan atas 24.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.onRefresh, this.bottomPadding = AppDimens.pageBottom});

  final List<Widget> children;

  /// Tarik untuk menyegarkan (menjalankan sync).
  final Future<void> Function()? onRefresh;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(AppDimens.pageSide, AppDimens.pageTop, AppDimens.pageSide, bottomPadding),
      children: children,
    );

    return onRefresh == null ? list : RefreshIndicator(onRefresh: onRefresh!, child: list);
  }
}

/// Isi lembar bawah: pegangan 40 × 4, judul 18 Bold, tombol tutup, lalu isinya.
///
/// [footer] (tombol utama, misalnya Simpan) tidak ikut bergulir, supaya selalu
/// terlihat di atas keyboard walaupun isinya lebih tinggi dari layar.
class AppSheet extends StatelessWidget {
  const AppSheet({super.key, required this.title, required this.children, this.footer});

  final String title;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // Beri ruang untuk bilah navigasi sistem (nol selama keyboard terbuka).
    final bottom = math.max(AppDimens.gap24, MediaQuery.paddingOf(context).bottom + AppDimens.gap12);

    return Padding(
      // Naik bersama keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppDimens.pageSide,
                AppDimens.gap12,
                AppDimens.pageSide,
                footer == null ? bottom : AppDimens.gap14,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: AppDimens.sheetHandleWidth,
                      height: AppDimens.sheetHandleHeight,
                      decoration: BoxDecoration(
                        color: palette.line,
                        borderRadius: BorderRadius.circular(AppDimens.sheetHandleHeight / 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.gap14),
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(header: true, child: Text(title, style: context.text.sheetTitle)),
                      ),
                      AppIconButton(
                        icon: Symbols.close_rounded,
                        label: context.l10n.commonClose,
                        color: palette.muted,
                        iconSize: AppDimens.iconLg,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  for (final child in children) ...[const SizedBox(height: AppDimens.gap14), child],
                ],
              ),
            ),
          ),
          if (footer != null)
            Padding(padding: EdgeInsets.fromLTRB(AppDimens.pageSide, 0, AppDimens.pageSide, bottom), child: footer),
        ],
      ),
    );
  }
}

/// Buka lembar bawah dengan radius atas 28 dan latar redup `scrim`.
///
/// Selalu di navigator utama, supaya lembar yang dibuka dari dalam tab ikut menutupi tab bawah.
Future<T?> showAppSheet<T>(BuildContext context, {required WidgetBuilder builder}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  useRootNavigator: true,
  builder: builder,
);

/// Dialog konfirmasi untuk tindakan yang tidak bisa diurungkan.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(dialogContext.l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: destructive ? TextButton.styleFrom(foregroundColor: dialogContext.palette.danger) : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Tampilkan pesan singkat di bawah layar.
void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
