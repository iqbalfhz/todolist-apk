import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Bar progres: bulat penuh, jalur `track`, isi `brand`.
///
/// Hanya gambar; pemanggil selalu menampilkan angka persennya di dekatnya.
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.fraction, this.height = AppDimens.progressThin});

  /// 0 sampai 1.
  final double fraction;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final radius = BorderRadius.circular(height / 2);

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          height: height,
          color: palette.track,
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: fraction.clamp(0, 1).toDouble(),
            child: Container(
              decoration: BoxDecoration(color: palette.brand, borderRadius: radius),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cincin progres 112 di Detail tabungan, dengan isi di tengahnya.
class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.fraction, required this.child});

  final double fraction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SizedBox.square(
      dimension: AppDimens.ring,
      child: CustomPaint(
        painter: _RingPainter(fraction: fraction.clamp(0, 1).toDouble(), track: palette.track, fill: palette.brand),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.fraction, required this.track, required this.fill});

  final double fraction;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = AppDimens.ringStroke;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, 0, math.pi * 2, false, paint..color = track);
    if (fraction > 0) {
      canvas.drawArc(arcRect, -math.pi / 2, math.pi * 2 * fraction, false, paint..color = fill);
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.track != track || oldDelegate.fill != fill;
}
