import 'package:material_ui/material_ui.dart';

import 'app_dimens.dart';
import 'app_palette.dart';
import 'app_text_styles.dart';

export 'app_dimens.dart';
export 'app_palette.dart';
export 'app_text_styles.dart';

/// Jalan pintas ke token tema, supaya layar tidak menulis warna atau ukuran huruf sendiri.
extension AppThemeContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;

  AppTextStyles get text => Theme.of(this).extension<AppTextStyles>()!;

  /// Warna diri atau warna daftar untuk kunci seperti `mawar` atau `ungu`.
  Color personColor(String key) => PersonColors.resolve(key, Theme.of(this).brightness);

  /// "Kurangi gerakan" di pengaturan sistem.
  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);
}

/// Satu [ThemeData] untuk setiap kombinasi tema dan mode.
/// [ColorScheme] diisi manual dari palet, bukan `ColorScheme.fromSeed`.
ThemeData buildAppTheme(AppThemeName name, Brightness brightness) {
  final palette = AppPalette.resolve(name, brightness);
  final text = AppTextStyles.from(palette);
  final isDark = brightness == Brightness.dark;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: palette.primary,
    onPrimary: palette.onPrimary,
    primaryContainer: palette.soft,
    onPrimaryContainer: palette.text,
    secondary: palette.brand,
    onSecondary: palette.onPrimary,
    secondaryContainer: palette.soft,
    onSecondaryContainer: palette.text,
    tertiary: palette.accent,
    onTertiary: palette.text,
    tertiaryContainer: palette.track,
    onTertiaryContainer: palette.text,
    error: palette.danger,
    onError: isDark ? palette.bg : palette.surface,
    errorContainer: palette.soft,
    onErrorContainer: palette.text,
    surface: palette.surface,
    onSurface: palette.text,
    onSurfaceVariant: palette.muted,
    surfaceDim: palette.bg,
    surfaceBright: palette.surface,
    surfaceContainerLowest: palette.surface,
    surfaceContainerLow: palette.surface,
    surfaceContainer: palette.surface,
    surfaceContainerHigh: palette.surface,
    surfaceContainerHighest: palette.soft,
    surfaceTint: palette.surface,
    outline: palette.muted,
    outlineVariant: palette.line,
    shadow: const Color(0xFF000000),
    scrim: palette.scrim,
    inverseSurface: palette.text,
    onInverseSurface: palette.bg,
    inversePrimary: palette.accent,
  );

  final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppDimens.fieldRadius),
    borderSide: BorderSide(color: palette.line, width: AppDimens.borderWidth),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: palette.bg,
    canvasColor: palette.surface,
    fontFamily: appFontFamily,
    extensions: [palette, text],
    textTheme: TextTheme(
      displaySmall: text.homeTitle,
      headlineMedium: text.homeTitle,
      headlineSmall: text.heroTitle,
      titleLarge: text.screenTitle,
      titleMedium: text.cardTitle,
      titleSmall: text.sectionTitle,
      bodyLarge: text.input,
      bodyMedium: text.body.copyWith(color: palette.text),
      bodySmall: text.caption,
      labelLarge: text.chipSelected,
      labelMedium: text.label,
      labelSmall: text.small,
    ),
    iconTheme: IconThemeData(color: palette.text, size: AppDimens.iconXl, fill: 0, weight: 400, opticalSize: 24),
    dividerTheme: DividerThemeData(color: palette.line, thickness: AppDimens.borderWidth, space: AppDimens.borderWidth),
    appBarTheme: AppBarTheme(
      backgroundColor: palette.bg,
      foregroundColor: palette.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: text.screenTitle,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: palette.primary,
        foregroundColor: palette.onPrimary,
        disabledBackgroundColor: palette.track,
        disabledForegroundColor: palette.muted,
        minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
        shape: const StadiumBorder(),
        textStyle: text.button,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.gap20),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: palette.surface,
        foregroundColor: palette.link,
        minimumSize: const Size(0, AppDimens.buttonHeight),
        side: BorderSide(color: palette.primary, width: AppDimens.borderWidthSelected),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.fieldRadius)),
        textStyle: text.sectionTitle,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.gap20),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: palette.link,
        minimumSize: const Size(0, AppDimens.chipHeight),
        textStyle: text.link,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.gap12),
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: palette.surface,
      hintStyle: text.input.copyWith(color: palette.muted),
      errorStyle: text.small.copyWith(color: palette.danger),
      errorMaxLines: 3,
      constraints: const BoxConstraints(minHeight: AppDimens.fieldHeight),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.fieldSidePadding, vertical: AppDimens.gap14),
      border: fieldBorder,
      enabledBorder: fieldBorder,
      disabledBorder: fieldBorder,
      focusedBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: palette.primary, width: AppDimens.borderWidthSelected),
      ),
      errorBorder: fieldBorder.copyWith(borderSide: BorderSide(color: palette.danger)),
      focusedErrorBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: palette.danger, width: AppDimens.borderWidthSelected),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? palette.onPrimary : palette.muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? palette.primary : palette.surface,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? palette.primary : palette.muted,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: palette.primary,
      foregroundColor: palette.onPrimary,
      elevation: 4,
      highlightElevation: 6,
      sizeConstraints: const BoxConstraints.tightFor(width: AppDimens.fab, height: AppDimens.fab),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.fabRadius)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: palette.surface,
      modalBackgroundColor: palette.surface,
      modalBarrierColor: palette.scrim,
      surfaceTintColor: palette.surface,
      elevation: 0,
      modalElevation: 0,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.sheetRadius)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: palette.surface,
      barrierColor: palette.scrim,
      titleTextStyle: text.sheetTitle,
      contentTextStyle: text.body,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.cardRadius)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: palette.text,
      contentTextStyle: text.chip.copyWith(color: palette.bg),
      // Snackbar memakai warna kebalikan; teks aksinya ikut diambil dari mode sebaliknya.
      actionTextColor: isDark ? AppPalette.resolve(name, Brightness.light).link : palette.accent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.fieldRadius)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: palette.surface,
      surfaceTintColor: palette.surface,
      textStyle: text.rowTitlePlain,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.fieldRadius),
        side: BorderSide(color: palette.line),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: palette.brand,
      linearTrackColor: palette.track,
      circularTrackColor: palette.track,
    ),
    listTileTheme: ListTileThemeData(iconColor: palette.text, textColor: palette.text),
  );
}
