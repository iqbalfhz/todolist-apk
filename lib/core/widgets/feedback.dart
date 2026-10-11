import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import 'app_card.dart';

/// Kotak pengganti isi selama data dimuat. Skeleton, bukan spinner.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({super.key, this.width, required this.height, this.radius = AppDimens.gap8});

  final double? width;
  final double height;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.45,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // "Kurangi gerakan": skeleton diam.
    if (context.reduceMotion) {
      _controller
        ..stop()
        ..value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _controller,
    child: Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(color: context.palette.track, borderRadius: BorderRadius.circular(widget.radius)),
    ),
  );
}

/// Kartu skeleton dengan beberapa baris.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.lines = 3});

  final int lines;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 140, height: AppDimens.gap16),
          for (var i = 0; i < lines; i++) ...[
            const SizedBox(height: AppDimens.gap16),
            SkeletonBox(width: i.isEven ? null : 200, height: AppDimens.gap14),
          ],
        ],
      ),
    ),
  );
}

/// Banner kecil di atas layar, misalnya saat offline.
class InfoBanner extends StatelessWidget {
  const InfoBanner({super.key, required this.message, this.icon = Symbols.cloud_off_rounded});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        color: palette.soft,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.pageSide, vertical: AppDimens.gap8),
        child: Row(
          children: [
            Icon(icon, size: AppDimens.iconMd, color: palette.text),
            const SizedBox(width: AppDimens.gap8),
            Expanded(
              child: Text(message, style: context.text.small.copyWith(color: palette.text)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Layar atau bagian kosong, yang selalu menunjukkan langkah berikutnya.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.icon, this.actionLabel, this.onAction});

  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppDimens.gap12),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: AppDimens.iconXxl, color: context.palette.brand),
          const SizedBox(height: AppDimens.gap8),
        ],
        Text(message, style: context.text.body, textAlign: TextAlign.center),
        if (actionLabel != null) ...[
          const SizedBox(height: AppDimens.gap4),
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    ),
  );
}

/// Teks status dengan ikon. Status tidak pernah hanya mengandalkan warna.
class StatusText extends StatelessWidget {
  const StatusText({super.key, required this.text, required this.icon, required this.color, this.style});

  final String text;
  final IconData icon;
  final Color color;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: AppDimens.iconXs, color: color),
      const SizedBox(width: AppDimens.gap4),
      Flexible(
        child: Text(text, style: (style ?? context.text.captionStrong).copyWith(color: color)),
      ),
    ],
  );
}
