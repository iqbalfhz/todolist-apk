import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Tombol utama: tinggi 52, bulat penuh, dengan ikon opsional.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final IconData? icon;

  /// `null` menonaktifkan tombol, misalnya selama permintaan masih berjalan.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: AppDimens.iconLg), const SizedBox(width: AppDimens.gap8)],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    ),
  );
}

/// Tombol ikon 44 × 44 (area sentuh 48) dengan label untuk pembaca layar.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.color,
    this.iconSize = AppDimens.iconXl,
  });

  final IconData icon;

  /// Wajib: setiap tombol ikon punya label `Semantics`.
  final String label;
  final VoidCallback? onPressed;

  /// Lingkaran bergaris dengan latar `surface`, seperti tombol daftar baru di tab Tugas.
  final bool outlined;
  final Color? color;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return IconButton(
      onPressed: onPressed,
      tooltip: label,
      iconSize: iconSize,
      color: color ?? palette.text,
      constraints: const BoxConstraints.tightFor(width: AppDimens.iconButton, height: AppDimens.iconButton),
      padding: EdgeInsets.zero,
      style: outlined
          ? IconButton.styleFrom(
              backgroundColor: palette.surface,
              side: BorderSide(color: palette.line, width: AppDimens.borderWidth),
            )
          : null,
      icon: Icon(icon),
    );
  }
}

/// Tombol kembali di kepala layar.
class BackIconButton extends StatelessWidget {
  const BackIconButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => AppIconButton(
    icon: Symbols.arrow_back_ios_new_rounded,
    label: label,
    onPressed: onPressed,
    iconSize: AppDimens.iconLg,
  );
}

/// Chip filter: tinggi 44, bulat penuh. Terpilih: garis `primary` 1,5 dan latar `soft`.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  /// Penanda di depan label, misalnya titik warna penanggung jawab.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.text;
    final shape = StadiumBorder(
      side: BorderSide(
        color: selected ? palette.primary : palette.line,
        width: selected ? AppDimens.borderWidthSelected : AppDimens.borderWidth,
      ),
    );

    return Semantics(
      container: true,
      button: true,
      selected: selected,
      child: Padding(
        // Tampilan 44, area sentuh 48.
        padding: const EdgeInsets.symmetric(vertical: (AppDimens.minTouch - AppDimens.chipHeight) / 2),
        child: Material(
          color: selected ? palette.soft : palette.surface,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppDimens.chipHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.chipSidePadding, vertical: AppDimens.gap8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: AppDimens.iconSm, color: palette.text),
                      const SizedBox(width: AppDimens.gap6),
                    ],
                    if (leading != null) ...[leading!, const SizedBox(width: AppDimens.gap6)],
                    Flexible(child: Text(label, style: selected ? text.chipSelected : text.chip)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Satu pilihan di [SegmentedControl].
class Segment<T> {
  const Segment({required this.value, required this.label});

  final T value;
  final String label;
}

/// Kontrol segmen: latar `soft` radius 16, pilihan aktif berlatar `surface` radius 12.
class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    required this.semanticLabel,
  });

  final List<Segment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.text;

    return Semantics(
      container: true,
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.segmentPadding),
        decoration: BoxDecoration(color: palette.soft, borderRadius: BorderRadius.circular(AppDimens.segmentRadius)),
        child: Row(
          children: [
            for (final (index, segment) in segments.indexed) ...[
              if (index > 0) const SizedBox(width: AppDimens.segmentPadding),
              Expanded(
                child: Semantics(
                  container: true,
                  button: true,
                  selected: segment.value == selected,
                  child: Material(
                    color: segment.value == selected ? palette.surface : palette.soft,
                    borderRadius: BorderRadius.circular(AppDimens.segmentItemRadius),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => onChanged(segment.value),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: AppDimens.segmentItemHeight),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppDimens.gap4, vertical: AppDimens.gap8),
                            child: Text(
                              segment.label,
                              textAlign: TextAlign.center,
                              style: segment.value == selected ? text.amount : text.chip,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Label 13 SemiBold di atas sebuah isian. Label form berupa pertanyaan.
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child, this.help});

  final String label;
  final Widget child;

  /// Keterangan kecil di bawah isian.
  final String? help;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(label, style: context.text.label),
      const SizedBox(height: AppDimens.gap6),
      child,
      if (help != null) ...[const SizedBox(height: AppDimens.gap6), Text(help!, style: context.text.small)],
    ],
  );
}

/// Baris switch di dalam kartu atau lembar: ikon opsional, judul, keterangan, dan switch.
class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
    this.titleStyle,
    this.minHeight = AppDimens.rowMinHeightSettings,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final TextStyle? titleStyle;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final text = context.text;

    return MergeSemantics(
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Row(
            children: [
              if (icon != null) ...[Icon(icon, size: AppDimens.iconMd), const SizedBox(width: AppDimens.gap10)],
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppDimens.gap8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: titleStyle ?? text.rowTitle),
                      if (subtitle != null) Text(subtitle!, style: text.small),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.gap12),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}
