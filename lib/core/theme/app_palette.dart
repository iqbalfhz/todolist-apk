import 'package:material_ui/material_ui.dart';

/// Dua tema warna; masing-masing punya mode terang dan gelap.
enum AppThemeName {
  mawar,
  anggrek;

  static AppThemeName parse(String? value) => values.firstWhere((name) => name.name == value, orElse: () => mawar);
}

/// Token warna dari `.claude/rules/tema.md` (sama dengan objek `t` di mockup).
///
/// Aturan pakainya:
/// - hanya [primary] yang boleh menjadi latar teks ([onPrimary]); [brand] tidak;
/// - [soft], [accent], dan [track] selalu diberi teks [text];
/// - [ok], [warn], dan [danger] hanya untuk teks atau ikon di atas [bg] atau [surface],
///   dan selalu ditemani ikon.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.bg,
    required this.surface,
    required this.soft,
    required this.line,
    required this.text,
    required this.muted,
    required this.primary,
    required this.onPrimary,
    required this.link,
    required this.brand,
    required this.accent,
    required this.track,
    required this.scrim,
    required this.ok,
    required this.warn,
    required this.danger,
  });

  /// Latar layar.
  final Color bg;

  /// Kartu, lembar bawah, tab bawah.
  final Color surface;

  /// Chip terpilih dan latar sorotan.
  final Color soft;

  /// Garis dan batas.
  final Color line;

  /// Teks utama.
  final Color text;

  /// Teks sekunder.
  final Color muted;

  /// Tombol utama dan FAB.
  final Color primary;

  /// Teks dan ikon di atas [primary].
  final Color onPrimary;

  /// Teks tautan dan tombol teks.
  final Color link;

  /// Isi progres, centang, ikon aktif. Bukan untuk latar teks.
  final Color brand;

  /// Ilustrasi dan aksen.
  final Color accent;

  /// Jalur bar progres.
  final Color track;

  /// Latar redup di belakang lembar bawah dan dialog.
  final Color scrim;

  final Color ok;
  final Color warn;
  final Color danger;

  static const AppPalette mawarLight = AppPalette(
    bg: Color(0xFFFCF3F7),
    surface: Color(0xFFFFFFFF),
    soft: Color(0xFFF9E4EC),
    line: Color(0xFFEFD9E2),
    text: Color(0xFF2B1A22),
    muted: Color(0xFF6E5A63),
    primary: Color(0xFFCB2F69),
    onPrimary: Color(0xFFFFFFFF),
    link: Color(0xFFB42A5E),
    brand: Color(0xFFD54B7E),
    accent: Color(0xFFE38BB3),
    track: Color(0xFFF6DCE6),
    scrim: Color(0x732B1A22),
    ok: Color(0xFF2E7D4F),
    warn: Color(0xFF9A5B00),
    danger: Color(0xFFB3261E),
  );

  static const AppPalette anggrekLight = AppPalette(
    bg: Color(0xFFF9EEF4),
    surface: Color(0xFFFFFFFF),
    soft: Color(0xFFF3DCE9),
    line: Color(0xFFEBD3E0),
    text: Color(0xFF2B1A22),
    muted: Color(0xFF6E5A63),
    primary: Color(0xFFCA4189),
    onPrimary: Color(0xFFFFFFFF),
    link: Color(0xFFA3326C),
    brand: Color(0xFFCA4189),
    accent: Color(0xFFCF679C),
    track: Color(0xFFF1D7E5),
    scrim: Color(0x732B1A22),
    ok: Color(0xFF2E7D4F),
    warn: Color(0xFF9A5B00),
    danger: Color(0xFFB3261E),
  );

  static const AppPalette mawarDark = AppPalette(
    bg: Color(0xFF1E1519),
    surface: Color(0xFF2A1F24),
    soft: Color(0xFF3B2530),
    line: Color(0xFF43343B),
    text: Color(0xFFF5E9EE),
    muted: Color(0xFFBBA6AF),
    primary: Color(0xFFE38BB3),
    onPrimary: Color(0xFF1E1519),
    link: Color(0xFFE38BB3),
    brand: Color(0xFFE38BB3),
    accent: Color(0xFFECB1C7),
    track: Color(0xFF4A2E3B),
    scrim: Color(0x8C000000),
    ok: Color(0xFF7FD3A0),
    warn: Color(0xFFF0B45C),
    danger: _dangerDark,
  );

  static const AppPalette anggrekDark = AppPalette(
    bg: Color(0xFF1E1519),
    surface: Color(0xFF2A1F24),
    soft: Color(0xFF3A2434),
    line: Color(0xFF43343B),
    text: Color(0xFFF5E9EE),
    muted: Color(0xFFBBA6AF),
    primary: Color(0xFFDD799F),
    onPrimary: Color(0xFF1E1519),
    link: Color(0xFFDD799F),
    brand: Color(0xFFDD799F),
    accent: Color(0xFFCF679C),
    track: Color(0xFF482C3E),
    scrim: Color(0x8C000000),
    ok: Color(0xFF7FD3A0),
    warn: Color(0xFFF0B45C),
    danger: _dangerDark,
  );

  /// `danger` gelap belum ditetapkan di tema.md. Dipilih varian yang lebih terang;
  /// kontrasnya terhadap `surface` dan `bg` gelap dijaga `test/core/theme_test.dart`.
  static const Color _dangerDark = Color(0xFFFFB4AB);

  static AppPalette resolve(AppThemeName name, Brightness brightness) => switch ((name, brightness)) {
    (AppThemeName.mawar, Brightness.light) => mawarLight,
    (AppThemeName.mawar, Brightness.dark) => mawarDark,
    (AppThemeName.anggrek, Brightness.light) => anggrekLight,
    (AppThemeName.anggrek, Brightness.dark) => anggrekDark,
  };

  /// Tiga contoh warna di kartu pilihan tema; sama di mode terang dan gelap.
  static List<Color> swatchesOf(AppThemeName name) => switch (name) {
    AppThemeName.mawar => const [Color(0xFFECB1C7), Color(0xFFD54B7E), Color(0xFFE38BB3)],
    AppThemeName.anggrek => const [Color(0xFFCF679C), Color(0xFFCA4189), Color(0xFFDD799F)],
  };

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      soft: Color.lerp(soft, other.soft, t)!,
      line: Color.lerp(line, other.line, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      link: Color.lerp(link, other.link, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      track: Color.lerp(track, other.track, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      ok: Color.lerp(ok, other.ok, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

/// Enam kunci warna yang dipakai untuk warna diri (`color` milik user) dan warna
/// daftar (`color` milik daftar tugas).
abstract final class PersonColors {
  static const List<String> keys = ['mawar', 'ungu', 'toska', 'bata', 'biru', 'lavender'];

  static const Map<String, Color> _light = {
    'mawar': Color(0xFFCB2F69),
    'ungu': Color(0xFF5B57A6),
    'toska': Color(0xFF2E7D73),
    'bata': Color(0xFFB4541F),
    'biru': Color(0xFF3567B5),
    'lavender': Color(0xFF8A4FA0),
  };

  /// Hanya `ungu` yang ditetapkan di tema.md. Sisanya varian yang lebih terang;
  /// kontrasnya terhadap `surface` gelap dijaga `test/core/theme_test.dart`.
  static const Map<String, Color> _dark = {
    'mawar': Color(0xFFE38BB3),
    'ungu': Color(0xFFA9A3F0),
    'toska': Color(0xFF7FCFC4),
    'bata': Color(0xFFF0A27A),
    'biru': Color(0xFF9BB8F2),
    'lavender': Color(0xFFD3A6E8),
  };

  static Color resolve(String key, Brightness brightness) {
    final colors = brightness == Brightness.dark ? _dark : _light;
    return colors[key] ?? colors['mawar']!;
  }
}

/// Warna tombol masuk dengan Google (v1.x), dari panduan merek Google
/// (developers.google.com/identity/branding-guidelines). Tidak mengikuti tema Mawar atau
/// Anggrek, supaya tombolnya tetap dikenali sebagai tombol Google.
@immutable
class GoogleButtonColors {
  const GoogleButtonColors._({required this.fill, required this.stroke, required this.text});

  final Color fill;
  final Color stroke;
  final Color text;

  static const GoogleButtonColors light = GoogleButtonColors._(
    fill: Color(0xFFFFFFFF),
    stroke: Color(0xFF747775),
    text: Color(0xFF1F1F1F),
  );

  static const GoogleButtonColors dark = GoogleButtonColors._(
    fill: Color(0xFF131314),
    stroke: Color(0xFF8E918F),
    text: Color(0xFFE3E3E3),
  );

  /// Logo dan teks tombol yang nonaktif, seperti contoh tombol dari Google.
  static const double disabledOpacity = 0.38;

  static GoogleButtonColors of(Brightness brightness) => brightness == Brightness.dark ? dark : light;
}
