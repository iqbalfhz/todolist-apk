import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/theme/app_theme.dart';

/// Rasio kontras WCAG antara dua warna.
double contrast(Color a, Color b) {
  double luminance(Color color) {
    double channel(double value) =>
        value <= 0.03928 ? value / 12.92 : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(color.r) + 0.7152 * channel(color.g) + 0.0722 * channel(color.b);
  }

  final la = luminance(a);
  final lb = luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  const minTextContrast = 4.5;

  final combinations = [
    for (final name in AppThemeName.values)
      for (final brightness in Brightness.values) (name, brightness),
  ];

  for (final (name, brightness) in combinations) {
    final label = '${name.name} ${brightness.name}';
    final palette = AppPalette.resolve(name, brightness);

    group(label, () {
      test('kontras teks minimal 4.5:1', () {
        final pairs = <String, (Color, Color)>{
          'text di atas bg': (palette.text, palette.bg),
          'text di atas surface': (palette.text, palette.surface),
          'text di atas soft': (palette.text, palette.soft),
          'text di atas track': (palette.text, palette.track),
          'muted di atas bg': (palette.muted, palette.bg),
          'muted di atas surface': (palette.muted, palette.surface),
          'muted di atas soft': (palette.muted, palette.soft),
          'onPrimary di atas primary': (palette.onPrimary, palette.primary),
          'link di atas bg': (palette.link, palette.bg),
          'link di atas surface': (palette.link, palette.surface),
          'link di atas soft': (palette.link, palette.soft),
          // `ok` hanya dipakai di atas surface; lihat tes "ok di atas bg" di bawah.
          'ok di atas surface': (palette.ok, palette.surface),
          'warn di atas surface': (palette.warn, palette.surface),
          'warn di atas bg': (palette.warn, palette.bg),
          'danger di atas surface': (palette.danger, palette.surface),
          'danger di atas bg': (palette.danger, palette.bg),
        };

        for (final entry in pairs.entries) {
          final ratio = contrast(entry.value.$1, entry.value.$2);
          expect(
            ratio,
            greaterThanOrEqualTo(minTextContrast),
            reason: '$label: ${entry.key} = ${ratio.toStringAsFixed(2)}',
          );
        }
      });

      test('warna diri terbaca di atas surface dan soft', () {
        for (final key in PersonColors.keys) {
          final color = PersonColors.resolve(key, brightness);
          expect(
            contrast(color, palette.surface),
            greaterThanOrEqualTo(minTextContrast),
            reason: '$label: $key di atas surface',
          );
          // Di atas soft, warna diri hanya dipakai untuk inisial besar dan garis (cukup 3:1).
          expect(contrast(color, palette.soft), greaterThanOrEqualTo(3), reason: '$label: $key di atas soft');
        }
      });

      test('snackbar terbaca', () {
        final theme = buildAppTheme(name, brightness);
        final background = theme.snackBarTheme.backgroundColor!;

        expect(
          contrast(theme.snackBarTheme.contentTextStyle!.color!, background),
          greaterThanOrEqualTo(minTextContrast),
        );
        expect(contrast(theme.snackBarTheme.actionTextColor!, background), greaterThanOrEqualTo(minTextContrast));
      });

      test('ColorScheme diisi dari palet', () {
        final scheme = buildAppTheme(name, brightness).colorScheme;

        expect(scheme.primary, palette.primary);
        expect(scheme.onPrimary, palette.onPrimary);
        expect(scheme.surface, palette.surface);
        expect(scheme.onSurface, palette.text);
        expect(scheme.onSurfaceVariant, palette.muted);
        expect(scheme.secondaryContainer, palette.soft);
        expect(scheme.outlineVariant, palette.line);
        expect(scheme.tertiary, palette.accent);
        expect(scheme.error, palette.danger);
        expect(contrast(scheme.onError, scheme.error), greaterThanOrEqualTo(minTextContrast));
      });
    });
  }

  test('nilai palet sama dengan tabel di tema.md', () {
    expect(AppPalette.mawarLight.primary, const Color(0xFFCB2F69));
    expect(AppPalette.mawarLight.brand, const Color(0xFFD54B7E));
    expect(AppPalette.anggrekLight.primary, const Color(0xFFCA4189));
    expect(AppPalette.anggrekLight.link, const Color(0xFFA3326C));
    expect(AppPalette.mawarDark.primary, const Color(0xFFE38BB3));
    expect(AppPalette.anggrekDark.primary, const Color(0xFFDD799F));
    expect(AppPalette.mawarDark.soft, const Color(0xFF3B2530));
    expect(AppPalette.anggrekDark.soft, const Color(0xFF3A2434));
    expect(PersonColors.resolve('ungu', Brightness.light), const Color(0xFF5B57A6));
    expect(PersonColors.resolve('ungu', Brightness.dark), const Color(0xFFA9A3F0));
    expect(PersonColors.resolve('tidak-ada', Brightness.light), const Color(0xFFCB2F69));
  });

  test('ok di atas bg: Anggrek terang sedikit di bawah 4.5:1, jadi ok hanya dipakai di atas surface', () {
    // Nilai `ok` dari tema.md tidak diubah di sini. Kalau tokennya diperbaiki, tes ini ikut disesuaikan.
    expect(contrast(AppPalette.anggrekLight.ok, AppPalette.anggrekLight.bg), closeTo(4.46, 0.01));
    expect(contrast(AppPalette.mawarLight.ok, AppPalette.mawarLight.bg), greaterThanOrEqualTo(minTextContrast));
    expect(contrast(AppPalette.mawarDark.ok, AppPalette.mawarDark.bg), greaterThanOrEqualTo(minTextContrast));
    expect(contrast(AppPalette.anggrekDark.ok, AppPalette.anggrekDark.bg), greaterThanOrEqualTo(minTextContrast));
  });

  test('hanya primary yang boleh menjadi latar teks putih; brand Mawar tidak', () {
    const white = Color(0xFFFFFFFF);
    expect(contrast(white, AppPalette.mawarLight.primary), greaterThanOrEqualTo(minTextContrast));
    expect(contrast(white, AppPalette.mawarLight.brand), lessThan(minTextContrast));
  });
}
