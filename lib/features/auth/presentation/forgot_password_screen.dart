import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/api/api_error.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/session/session.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../home/presentation/main_shell.dart';
import 'auth_actions.dart';

/// Pesan saat meminta kode lewat email ditolak (v1.0). Untuk 429, kira-kira berapa menit lagi
/// menurut `Retry-After`, karena batasnya per 15 menit atau per jam; selain itu pesan server.
String codeRequestError(AppLocalizations l10n, ApiError error) {
  final wait = error.retryAfter;
  if (error.code != ApiErrorCode.tooManyRequests || wait == null) return error.message;
  return l10n.codeTooOften((wait.inSeconds / 60).ceil().clamp(1, 60));
}

/// Lupa kata sandi (v1.0): minta kode 6 angka lewat email, lalu isi kode dan kata sandi baru.
/// Berhasil sama dengan baru masuk; server mencabut token di semua HP lain.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.email});

  /// Email yang sudah diketik di layar Masuk, kalau ada.
  final String? email;

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late final TextEditingController _email = TextEditingController(text: widget.email ?? '');
  final TextEditingController _code = TextEditingController();
  final TextEditingController _password = TextEditingController();

  /// Kode sudah diminta, jadi isian kode dan kata sandi baru tampil.
  bool _sent = false;
  bool _busy = false;
  bool _obscure = true;
  String? _emailError;
  String? _codeError;
  String? _passwordError;
  String? _formError;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  void _back() => context.go(Routes.login);

  void _clearErrors() {
    _emailError = null;
    _codeError = null;
    _passwordError = null;
    _formError = null;
  }

  /// Pesan error dari balasan API: per kolom kalau ada, selain itu pesan umumnya.
  void _showApiError(ApiError error) {
    _emailError = error.errors['email']?.firstOrNull;
    _codeError = error.errors['code']?.firstOrNull;
    _passwordError = error.errors['password']?.firstOrNull;
    if (_emailError == null && _codeError == null && _passwordError == null) _formError = error.message;
  }

  String _networkMessage(NetworkFailure failure) =>
      (failure.status ?? 0) >= 500 ? context.l10n.genericError : context.l10n.needsConnection;

  Future<void> _sendCode() async {
    if (_busy) return;
    final l10n = context.l10n;
    setState(_clearErrors);
    if (!isValidEmail(_email.text)) {
      setState(() => _emailError = l10n.errorEmailInvalid);
      return;
    }

    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).forgotPassword(_email.text);
      if (mounted) setState(() => _sent = true);
    } on ApiError catch (error) {
      if (mounted) {
        setState(() {
          _showApiError(error);
          if (_formError != null) _formError = codeRequestError(l10n, error);
        });
      }
    } on NetworkFailure catch (failure) {
      if (mounted) setState(() => _formError = _networkMessage(failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reset() async {
    if (_busy) return;
    final l10n = context.l10n;
    setState(() {
      _clearErrors();
      if (!isValidEmail(_email.text)) _emailError = l10n.errorEmailInvalid;
      if (!isValidEmailCode(_code.text)) _codeError = l10n.errorEmailCode;
      if (_password.text.isEmpty) {
        _passwordError = l10n.errorPasswordRequired;
      } else if (_password.text.length < Limits.passwordMin) {
        _passwordError = l10n.errorPasswordShort;
      }
    });
    if (_emailError != null || _codeError != null || _passwordError != null) return;

    final container = ProviderScope.containerOf(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final deviceName = ref.read(deviceInfoProvider).name;
    setState(() => _busy = true);
    try {
      final result = await ref
          .read(authRepositoryProvider)
          .resetPassword(email: _email.text, code: _code.text, password: _password.text, deviceName: deviceName);
      // Sama dengan baru masuk; layar berikutnya ditentukan router begitu sesi berubah.
      await completeSignIn(container, result);
      messenger.showSnackBar(SnackBar(content: Text(l10n.forgotDone)));
    } on ApiError catch (error) {
      if (mounted) setState(() => _showApiError(error));
    } on NetworkFailure catch (failure) {
      if (mounted) setState(() => _formError = _networkMessage(failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;

    // Tombol kembali Android juga ke layar Masuk, bukan menutup app.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: AppScaffold(
        child: PageBody(
          children: [
            ScreenHeader(onBack: _back),
            const SizedBox(height: AppDimens.gap8),
            Semantics(header: true, child: Text(l10n.forgotTitle, style: text.homeTitle)),
            const SizedBox(height: AppDimens.gap6),
            Text(l10n.forgotSubtitle, style: text.body),
            const SizedBox(height: AppDimens.gap20),
            LabeledField(
              label: l10n.fieldEmail,
              child: TextField(
                controller: _email,
                style: text.input,
                enabled: !_busy,
                keyboardType: TextInputType.emailAddress,
                textInputAction: _sent ? TextInputAction.next : TextInputAction.done,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                onSubmitted: (_) => _sent ? null : _sendCode(),
                decoration: InputDecoration(hintText: l10n.fieldEmailHint, errorText: _emailError),
              ),
            ),
            if (_sent) ...[
              const SizedBox(height: AppDimens.gap12),
              Semantics(
                liveRegion: true,
                child: StatusText(text: l10n.forgotSent, icon: Symbols.mark_email_read_rounded, color: palette.muted),
              ),
              const SizedBox(height: AppDimens.gap14),
              LabeledField(
                label: l10n.forgotCode,
                child: TextField(
                  controller: _code,
                  style: text.inputStrong,
                  enabled: !_busy,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                  decoration: InputDecoration(hintText: l10n.forgotCodeHint, errorText: _codeError),
                ),
              ),
              const SizedBox(height: AppDimens.gap14),
              LabeledField(
                label: l10n.forgotNewPassword,
                child: TextField(
                  controller: _password,
                  style: text.input,
                  enabled: !_busy,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmitted: (_) => _reset(),
                  decoration: InputDecoration(
                    hintText: l10n.fieldPasswordHint,
                    errorText: _passwordError,
                    suffixIcon: IconButton(
                      tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Symbols.visibility_rounded : Symbols.visibility_off_rounded,
                        size: AppDimens.iconLg,
                        color: palette.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (_formError != null) ...[
              const SizedBox(height: AppDimens.gap12),
              Semantics(
                liveRegion: true,
                child: StatusText(text: _formError!, icon: Symbols.error_rounded, color: palette.danger),
              ),
            ],
            const SizedBox(height: AppDimens.gap20),
            if (_sent) ...[
              PrimaryButton(label: l10n.forgotSave, onPressed: _busy ? null : _reset),
              const SizedBox(height: AppDimens.gap8),
              Center(
                child: TextButton(onPressed: _busy ? null : _sendCode, child: Text(l10n.forgotResend)),
              ),
            ] else
              PrimaryButton(label: l10n.forgotSend, onPressed: _busy ? null : _sendCode),
          ],
        ),
      ),
    );
  }
}
