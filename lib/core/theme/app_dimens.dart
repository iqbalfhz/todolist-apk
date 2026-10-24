/// Ukuran, radius, dan jarak dari tabel "Bentuk dan jarak" di `.claude/rules/tema.md`.
///
/// Layar tidak menulis angka sendiri; kalau nilainya belum ada, tambahkan di sini dulu.
abstract final class AppDimens {
  // Jarak antarelemen.
  static const double gap2 = 2;
  static const double gap4 = 4;
  static const double gap6 = 6;
  static const double gap8 = 8;
  static const double gap10 = 10;
  static const double gap12 = 12;
  static const double gap14 = 14;
  static const double gap16 = 16;
  static const double gap20 = 20;
  static const double gap24 = 24;

  // Halaman.
  static const double pageSide = 20;
  static const double pageTop = 24;
  static const double pageBottom = 24;

  /// Ruang di bawah daftar supaya baris terakhir tidak tertutup FAB.
  static const double fabClearance = 88;

  // Kartu.
  static const double cardRadius = 20;
  static const double cardPadding = 16;
  static const double cardRadiusSmall = 16;
  static const double borderWidth = 1;
  static const double borderWidthSelected = 1.5;
  static const double borderWidthStrong = 2;

  // Lembar bawah.
  static const double sheetRadius = 28;
  static const double sheetHandleWidth = 40;
  static const double sheetHandleHeight = 4;

  // Isian dan tombol.
  static const double fieldHeight = 52;
  static const double fieldRadius = 14;
  static const double fieldSidePadding = 14;
  static const double buttonHeight = 52;
  static const double chipHeight = 44;
  static const double chipSidePadding = 16;
  static const double iconButton = 44;

  /// Area sentuh minimal untuk aksesibilitas.
  static const double minTouch = 48;

  // Kontrol segmen (status tugas, mode tampilan).
  static const double segmentRadius = 16;
  static const double segmentItemRadius = 12;
  static const double segmentItemHeight = 40;
  static const double segmentPadding = 4;

  // Baris.
  static const double rowMinHeight = 52;
  static const double rowMinHeightTall = 60;
  static const double rowMinHeightSettings = 56;
  static const double rowMinHeightHistory = 48;

  /// Baris di daftar "Akan datang" Tanggal penting.
  static const double rowMinHeightLarge = 72;
  static const double listHeaderHeight = 40;

  // Tugas.
  static const double checkArea = 44;
  static const double checkCircle = 22;
  static const double checkIcon = 14;
  static const double dot = 8;
  static const double dotLarge = 10;

  /// Dua titik "Kita" saling menumpuk sejauh ini.
  static const double dotOverlap = 4;
  static const double assigneeChipPadV = 5;
  static const double assigneeChipPadH = 10;

  // FAB dan tab bawah.
  static const double fab = 56;
  static const double fabRadius = 18;
  static const double fabIcon = 26;
  static const double navHeight = 80;
  static const double navIndicatorWidth = 56;
  static const double navIndicatorHeight = 32;

  // Avatar.
  static const double avatarSmall = 36;
  static const double avatarRow = 44;
  static const double avatarMedium = 80;
  static const double avatarLarge = 112;
  static const double avatarOverlap = 10;
  static const double avatarBorder = 2;
  static const double avatarBorderLarge = 3;

  /// Lingkaran ikon di baris Pengaturan.
  static const double iconCircle = 40;

  /// Lingkaran ikon di kartu "Bersama sejak".
  static const double featureCircle = 56;
  static const double badge = 20;

  // Progres.
  static const double progressThin = 6;
  static const double progressThick = 8;
  static const double ring = 112;
  static const double ringStroke = 12;

  // Kode undangan.
  static const double codeBoxHeight = 52;
  static const double codeBoxRadius = 12;

  // Grafik setoran per bulan.
  static const double chartHeight = 96;

  /// Ruang untuk nama bulan di bawah batang dan nominal di atasnya.
  static const double chartLabelSpace = 44;
  static const double chartBarWidth = 32;
  static const double chartBarRadiusTop = 8;
  static const double chartBarRadiusBottom = 4;

  // Pilihan warna diri.
  static const double swatchRing = 44;
  static const double swatchDot = 30;
  static const double themeSwatch = 24;
  static const double themeCardMinHeight = 92;

  // Foto kenangan (v0.3).
  /// Radius foto di kisi dan sampul.
  static const double photoRadius = 12;

  /// Jarak antarfoto di kisi.
  static const double photoGap = 4;

  /// Kolom kisi foto di Detail kenangan dan Kenangan baru.
  static const int photoColumns = 3;

  /// Lebar dibagi tinggi sampul di kartu linimasa.
  static const double coverAspectCard = 16 / 9;

  /// Lebar dibagi tinggi sampul di Detail kenangan.
  static const double coverAspectDetail = 4 / 3;

  /// Lingkaran penanda "Menunggu terkirim" di pojok foto.
  static const double photoBadge = 24;

  // Ikon.
  static const double iconXs = 14;
  static const double iconSm = 16;
  static const double iconMd = 18;
  static const double iconLg = 20;
  static const double iconXl = 22;

  /// Ikon di lingkaran [featureCircle].
  static const double iconFeature = 28;
  static const double iconXxl = 34;
  static const double iconHero = 52;

  // Switch.
  static const double switchWidth = 44;
  static const double switchHeight = 26;
}
