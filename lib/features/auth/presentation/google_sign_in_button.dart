import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';

/// Logo G resmi dari paket aset panduan merek Google, tanpa latar.
const String googleLogoAsset = 'assets/images/google_g.png';

/// Tombol masuk dengan Google (v1.x), menurut panduan merek Google: logo G berwarna standar
/// yang tidak diubah, dan warna tombol Google untuk mode terang atau gelap, bukan warna tema.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, required this.label, required this.onPressed});

  /// "Masuk dengan Google" atau "Daftar dengan Google".
  final String label;

  /// `null` menonaktifkan tombol, misalnya selama masuk masih berjalan.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = GoogleButtonColors.of(Theme.of(context).brightness);
    final enabled = onPressed != null;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: colors.fill,
        foregroundColor: colors.text,
        disabledBackgroundColor: colors.fill,
        disabledForegroundColor: colors.text.withValues(alpha: GoogleButtonColors.disabledOpacity),
        minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
        side: BorderSide(color: colors.stroke),
        shape: const StadiumBorder(),
        textStyle: context.text.button,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.gap12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: enabled ? 1 : GoogleButtonColors.disabledOpacity,
            child: Image.asset(
              googleLogoAsset,
              width: AppDimens.googleLogo,
              height: AppDimens.googleLogo,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(width: AppDimens.gap10),
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
