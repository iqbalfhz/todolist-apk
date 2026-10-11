import 'package:material_ui/material_ui.dart';

import 'app_palette.dart';

const String appFontFamily = 'Plus Jakarta Sans';

/// Satu gaya huruf per peran, dari tabel "Huruf" di `.claude/rules/tema.md`.
/// Ukuran dalam dp (1 px di mockup = 1 dp).
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.homeTitle,
    required this.screenTitle,
    required this.heroTitle,
    required this.amountLarge,
    required this.sheetTitle,
    required this.cardTitle,
    required this.button,
    required this.input,
    required this.inputStrong,
    required this.sectionTitle,
    required this.rowTitle,
    required this.rowTitleDone,
    required this.rowTitlePlain,
    required this.body,
    required this.bodyStrong,
    required this.chip,
    required this.chipSelected,
    required this.amount,
    required this.caption,
    required this.captionStrong,
    required this.link,
    required this.label,
    required this.small,
    required this.smallStrong,
    required this.axis,
    required this.axisStrong,
    required this.navLabel,
    required this.navLabelSelected,
  });

  factory AppTextStyles.from(AppPalette palette) {
    TextStyle style(double size, FontWeight weight, {Color? color, double? height, double? spacing}) => TextStyle(
      fontFamily: appFontFamily,
      fontSize: size,
      fontWeight: weight,
      color: color ?? palette.text,
      height: height,
      letterSpacing: spacing,
    );

    const regular = FontWeight.w400;
    const medium = FontWeight.w500;
    const semiBold = FontWeight.w600;
    const bold = FontWeight.w700;

    return AppTextStyles(
      homeTitle: style(24, bold, spacing: -0.2),
      screenTitle: style(20, bold),
      heroTitle: style(22, bold, spacing: -0.2),
      amountLarge: style(22, bold, spacing: -0.3),
      sheetTitle: style(18, bold),
      cardTitle: style(16, bold),
      button: style(16, bold),
      input: style(16, regular),
      inputStrong: style(16, semiBold),
      sectionTitle: style(15, bold),
      rowTitle: style(15, semiBold),
      rowTitleDone: style(
        15,
        medium,
        color: palette.muted,
      ).copyWith(decoration: TextDecoration.lineThrough, decorationColor: palette.muted),
      rowTitlePlain: style(15, medium),
      body: style(14, regular, color: palette.muted, height: 20 / 14),
      bodyStrong: style(14, semiBold),
      chip: style(14, medium),
      chipSelected: style(14, semiBold),
      amount: style(14, bold),
      caption: style(13, regular, color: palette.muted),
      captionStrong: style(13, semiBold),
      link: style(13, semiBold, color: palette.link),
      label: style(13, semiBold, color: palette.muted),
      small: style(12, regular, color: palette.muted),
      smallStrong: style(12, semiBold),
      axis: style(11, regular, color: palette.muted),
      axisStrong: style(11, bold),
      navLabel: style(12, medium, color: palette.muted),
      navLabelSelected: style(12, bold, color: palette.link),
    );
  }

  /// Judul Beranda, karakter kode undangan — 24 Bold.
  final TextStyle homeTitle;

  /// Judul layar — 20 Bold.
  final TextStyle screenTitle;

  /// Judul layar Ajak pasangan — 22 Bold.
  final TextStyle heroTitle;

  /// Nominal besar — 22 Bold.
  final TextStyle amountLarge;

  /// Judul lembar bawah — 18 Bold.
  final TextStyle sheetTitle;

  /// Judul kartu — 16 Bold.
  final TextStyle cardTitle;

  /// Teks tombol utama — 16 Bold.
  final TextStyle button;

  /// Teks di isian — 16 Regular.
  final TextStyle input;

  /// Judul tugas dan kode undangan di isian — 16 SemiBold.
  final TextStyle inputStrong;

  /// Judul bagian, nama daftar — 15 Bold.
  final TextStyle sectionTitle;

  /// Judul baris — 15 SemiBold.
  final TextStyle rowTitle;

  /// Tugas selesai — 15 Medium dicoret.
  final TextStyle rowTitleDone;

  /// Baris dengan switch di lembar ("Tandai penting") — 15 Medium.
  final TextStyle rowTitlePlain;

  /// Paragraf — 14 Regular.
  final TextStyle body;

  /// Judul baris kecil (riwayat tabungan) — 14 SemiBold.
  final TextStyle bodyStrong;

  /// Chip filter — 14 Medium.
  final TextStyle chip;

  /// Chip filter terpilih — 14 SemiBold.
  final TextStyle chipSelected;

  /// Nominal di riwayat — 14 Bold.
  final TextStyle amount;

  /// Keterangan — 13 Regular.
  final TextStyle caption;

  /// Keterangan yang ditekankan ("Sisa Rp3.500.000") — 13 SemiBold.
  final TextStyle captionStrong;

  /// Tautan — 13 SemiBold.
  final TextStyle link;

  /// Label isian — 13 SemiBold.
  final TextStyle label;

  /// Keterangan kecil — 12 Regular.
  final TextStyle small;

  /// Chip penanggung jawab, label ruang — 12 SemiBold.
  final TextStyle smallStrong;

  /// Label sumbu grafik — 11 Regular.
  final TextStyle axis;

  /// Label sumbu grafik untuk bulan berjalan — 11 Bold.
  final TextStyle axisStrong;

  /// Label tab bawah — 12 Medium.
  final TextStyle navLabel;

  /// Label tab bawah yang aktif — 12 Bold.
  final TextStyle navLabelSelected;

  @override
  AppTextStyles copyWith() => this;

  @override
  AppTextStyles lerp(ThemeExtension<AppTextStyles>? other, double t) {
    if (other is! AppTextStyles) return this;
    TextStyle mix(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;

    return AppTextStyles(
      homeTitle: mix(homeTitle, other.homeTitle),
      screenTitle: mix(screenTitle, other.screenTitle),
      heroTitle: mix(heroTitle, other.heroTitle),
      amountLarge: mix(amountLarge, other.amountLarge),
      sheetTitle: mix(sheetTitle, other.sheetTitle),
      cardTitle: mix(cardTitle, other.cardTitle),
      button: mix(button, other.button),
      input: mix(input, other.input),
      inputStrong: mix(inputStrong, other.inputStrong),
      sectionTitle: mix(sectionTitle, other.sectionTitle),
      rowTitle: mix(rowTitle, other.rowTitle),
      rowTitleDone: mix(rowTitleDone, other.rowTitleDone),
      rowTitlePlain: mix(rowTitlePlain, other.rowTitlePlain),
      body: mix(body, other.body),
      bodyStrong: mix(bodyStrong, other.bodyStrong),
      chip: mix(chip, other.chip),
      chipSelected: mix(chipSelected, other.chipSelected),
      amount: mix(amount, other.amount),
      caption: mix(caption, other.caption),
      captionStrong: mix(captionStrong, other.captionStrong),
      link: mix(link, other.link),
      label: mix(label, other.label),
      small: mix(small, other.small),
      smallStrong: mix(smallStrong, other.smallStrong),
      axis: mix(axis, other.axis),
      axisStrong: mix(axisStrong, other.axisStrong),
      navLabel: mix(navLabel, other.navLabel),
      navLabelSelected: mix(navLabelSelected, other.navLabelSelected),
    );
  }
}
