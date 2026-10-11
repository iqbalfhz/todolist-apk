import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Avatar seseorang: foto profil, atau inisial dengan warna diri kalau belum punya foto.
///
/// Warna tidak pernah menjadi satu-satunya penanda: inisial selalu ikut tampil.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.name,
    required this.colorKey,
    required this.size,
    this.avatarUrl,
    this.cacheKey,
    this.filled = false,
    this.onImageError,
  });

  final String name;

  /// Kunci warna diri, misalnya `mawar` atau `ungu`.
  final String colorKey;
  final double size;

  /// URL bertanda tangan yang berlaku 7 hari.
  final String? avatarUrl;

  /// `avatar-{id}-{avatar_version}`, supaya URL baru untuk foto yang sama tidak diunduh ulang.
  final String? cacheKey;

  /// Latar `soft` (avatar besar di Profil dan Ajak pasangan); selain itu `surface`.
  final bool filled;

  /// Dipanggil saat foto gagal dimuat, misalnya URL-nya sudah kedaluwarsa (403).
  final VoidCallback? onImageError;

  static String initialsOf(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    final letters = words.take(2).map((word) => word.characters.first.toUpperCase());
    return letters.join();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = context.personColor(colorKey);
    final border = size >= AppDimens.avatarMedium ? AppDimens.avatarBorderLarge : AppDimens.avatarBorder;

    final initials = Center(
      child: SizedBox(
        width: size * 0.5,
        height: size * 0.4,
        child: FittedBox(
          child: Text(initialsOf(name), style: context.text.cardTitle.copyWith(color: color)),
        ),
      ),
    );

    final url = avatarUrl;

    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? palette.soft : palette.surface,
          border: Border.all(color: color, width: border),
        ),
        child: url == null
            ? initials
            : ClipOval(
                child: CachedNetworkImage(
                  imageUrl: url,
                  cacheKey: cacheKey,
                  fit: BoxFit.cover,
                  fadeInDuration: context.reduceMotion ? Duration.zero : const Duration(milliseconds: 200),
                  placeholder: (_, _) => initials,
                  errorWidget: (_, _, _) => initials,
                  errorListener: (_) => onImageError?.call(),
                ),
              ),
      ),
    );
  }
}

/// Titik warna penanda orang atau daftar.
class ColorDot extends StatelessWidget {
  const ColorDot({super.key, required this.color, this.size = AppDimens.dot});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

/// Satu titik untuk satu orang, dua titik bertumpuk untuk "Kita".
class PersonDots extends StatelessWidget {
  const PersonDots({super.key, required this.colors});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: AppDimens.dot + (colors.length - 1) * (AppDimens.dot - AppDimens.dotOverlap),
    height: AppDimens.dot,
    child: Stack(
      children: [
        for (final (index, color) in colors.indexed)
          Positioned(
            left: index * (AppDimens.dot - AppDimens.dotOverlap),
            child: ColorDot(color: color),
          ),
      ],
    ),
  );
}

/// Chip penanggung jawab: bulat penuh, latar `soft`, titik warna dan label Aku / Pasangan / Kita.
class AssigneeChip extends StatelessWidget {
  const AssigneeChip({super.key, required this.label, required this.colors});

  final String label;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppDimens.assigneeChipPadH, vertical: AppDimens.assigneeChipPadV),
    decoration: ShapeDecoration(color: context.palette.soft, shape: const StadiumBorder()),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PersonDots(colors: colors),
        const SizedBox(width: AppDimens.gap6),
        Text(label, style: context.text.smallStrong),
      ],
    ),
  );
}

/// Tombol centang tugas: lingkaran 22 dengan garis 2, di area 44 (sentuh 48).
class TaskCheckButton extends StatelessWidget {
  const TaskCheckButton({super.key, required this.done, required this.label, required this.onChanged});

  final bool done;

  /// "Tandai selesai: Beli galon" atau "Batalkan selesai: Beli galon".
  final String label;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final duration = context.reduceMotion ? Duration.zero : const Duration(milliseconds: 180);

    void toggle() {
      HapticFeedback.lightImpact();
      onChanged?.call(!done);
    }

    return Semantics(
      // Simpul tersendiri dengan aksi ketuk, supaya pembaca layar bisa mencentang
      // tanpa ikut membuka baris tugasnya.
      container: true,
      button: true,
      checked: done,
      label: label,
      onTap: onChanged == null ? null : toggle,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onChanged == null ? null : toggle,
        radius: AppDimens.minTouch / 2,
        child: SizedBox(
          width: AppDimens.checkArea,
          height: AppDimens.minTouch,
          child: Center(
            child: AnimatedContainer(
              duration: duration,
              width: AppDimens.checkCircle,
              height: AppDimens.checkCircle,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? palette.brand : palette.surface.withValues(alpha: 0),
                border: Border.all(color: done ? palette.brand : palette.muted, width: AppDimens.borderWidthStrong),
              ),
              child: AnimatedScale(
                scale: done ? 1 : 0,
                duration: duration,
                curve: Curves.easeOutBack,
                child: Icon(Symbols.check_rounded, size: AppDimens.checkIcon, color: palette.onPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
