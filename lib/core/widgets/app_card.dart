import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Kartu: radius 20, garis 1 warna `line`, padding 16.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.cardPadding),
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Nama bagian untuk pembaca layar, misalnya "Tugas hari ini".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      side: BorderSide(color: palette.line, width: AppDimens.borderWidth),
    );

    final content = Padding(padding: padding, child: child);

    return Semantics(
      container: true,
      label: semanticLabel,
      child: Material(
        color: palette.surface,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

/// Judul bagian di luar kartu, misalnya "Tema" dan "Notifikasi" di Pengaturan.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppDimens.gap6),
    child: Semantics(header: true, child: Text(title, style: context.text.sectionTitle)),
  );
}

/// Garis pemisah antarbaris di dalam kartu.
class RowDivider extends StatelessWidget {
  const RowDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Divider(height: AppDimens.borderWidth, thickness: AppDimens.borderWidth, color: context.palette.line);
}
