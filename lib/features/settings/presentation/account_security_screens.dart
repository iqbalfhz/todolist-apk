import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/api/api_error.dart';
import '../../../core/database/local_store.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/notifications/push_service.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/data/google_accounts.dart';
import '../../auth/domain/user.dart';
import '../../auth/presentation/forgot_password_screen.dart';
import '../../auth/presentation/google_sign_in_button.dart';
import '../../home/presentation/main_shell.dart';

/// Ganti kata sandi, atau buat kata sandi untuk akun dari Google (v1.x). Langsung, tidak lewat
/// antrean. Server mengeluarkan akun dari HP lain; HP ini tetap masuk.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final TextEditingController _current = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _busy = false;
  String? _currentError;
  String? _passwordError;
  String? _googleError;
  String? _formError;

  /// Akun Google yang sedang dipakai untuk konfirmasi, selama request berjalan.
  String? _googleEmail;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    super.dispose();
  }

  void _back() => context.canPop() ? context.pop() : context.go(Routes.settings);

  void _clearErrors() {
    _currentError = null;
    _passwordError = null;
    _googleError = null;
    _formError = null;
  }

  /// Kata sandi baru: wajib dan minimal 8 karakter, sama dengan daftar.
  String? _checkNewPassword(AppLocalizations l10n) {
    if (_password.text.isEmpty) return l10n.errorPasswordRequired;
    if (_password.text.length < Limits.passwordMin) return l10n.errorPasswordShort;
    return null;
  }

  Future<void> _saveWithPassword(User me) async {
    if (_busy) return;
    final l10n = context.l10n;
    setState(() {
      _clearErrors();
      if (_current.text.isEmpty) _currentError = l10n.errorPasswordRequired;
      _passwordError = _checkNewPassword(l10n);
    });
    if (_currentError != null || _passwordError != null) return;
    await _save(me, currentPassword: _current.text);
  }

  Future<void> _saveWithGoogle(User me) async {
    if (_busy) return;
    final l10n = context.l10n;
    setState(() {
      _clearErrors();
      _passwordError = _checkNewPassword(l10n);
    });
    if (_passwordError != null) return;

    setState(() => _busy = true);
    final identity = await _pickGoogle(ref, () => _googleError = l10n.googleSignInFailed);
    if (!mounted) return;
    if (identity == null) {
      setState(() => _busy = false);
      return;
    }
    setState(() => _googleEmail = identity.email);
    await _save(me, idToken: identity.idToken);
  }

  Future<void> _save(User me, {String? currentPassword, String? idToken}) async {
    final account = ref.read(accountProvider);
    if (account == null) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await account.profile.changePassword(
        password: _password.text,
        currentPassword: currentPassword,
        idToken: idToken,
        fcmToken: await _deviceFcmToken(ref),
      );
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(me.hasPassword ? l10n.passwordChanged : l10n.passwordCreated)));
      _back();
    } on ApiError catch (error) {
      if (!mounted) return;
      setState(() {
        switch (error.code) {
          case ApiErrorCode.invalidCredentials:
            _currentError = error.message;
          case ApiErrorCode.googleTokenInvalid:
            _googleError = error.message;
          case ApiErrorCode.tooManyRequests:
            _formError = _tooOften(l10n, error);
          default:
            _passwordError = error.errors['password']?.firstOrNull;
            if (_passwordError == null) _formError = error.message;
        }
      });
    } on NetworkFailure catch (failure) {
      if (mounted) setState(() => _formError = _networkMessage(l10n, failure));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _googleEmail = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;
    final me = ref.watch(profileProvider).value;

    if (me == null) {
      return AppScaffold(
        child: PageBody(
          children: [
            ScreenHeader(title: l10n.passwordChangeTitle, onBack: _back),
            const SizedBox(height: AppDimens.gap10),
            const SkeletonCard(lines: 3),
          ],
        ),
      );
    }

    final newPassword = LabeledField(
      label: l10n.forgotNewPassword,
      child: _PasswordInput(
        controller: _password,
        enabled: !_busy,
        hint: l10n.fieldPasswordHint,
        error: _passwordError,
        newPassword: true,
        onSubmitted: () => me.hasPassword ? _saveWithPassword(me) : _saveWithGoogle(me),
        onChanged: () {
          if (_passwordError != null) setState(() => _passwordError = null);
        },
      ),
    );

    return AppScaffold(
      child: PageBody(
        children: [
          ScreenHeader(title: me.hasPassword ? l10n.passwordChangeTitle : l10n.passwordCreateTitle, onBack: _back),
          const SizedBox(height: AppDimens.gap10),
          Text(me.hasPassword ? l10n.passwordChangeIntro : l10n.passwordCreateIntro(me.email), style: text.body),
          const SizedBox(height: AppDimens.gap20),
          if (me.hasPassword) ...[
            LabeledField(
              label: l10n.fieldCurrentPassword,
              child: _PasswordInput(
                controller: _current,
                enabled: !_busy,
                error: _currentError,
                onChanged: () {
                  if (_currentError != null) setState(() => _currentError = null);
                },
              ),
            ),
            const SizedBox(height: AppDimens.gap14),
            newPassword,
            _FormError(message: _formError),
            const SizedBox(height: AppDimens.gap20),
            PrimaryButton(label: l10n.forgotSave, onPressed: _busy ? null : () => _saveWithPassword(me)),
          ] else ...[
            newPassword,
            const SizedBox(height: AppDimens.gap20),
            _GoogleConfirmation(
              busy: _busy,
              usingEmail: _googleEmail,
              error: _googleError,
              onPressed: () => _saveWithGoogle(me),
            ),
            _FormError(message: _formError),
          ],
        ],
      ),
    );
  }
}

/// Ganti email (v1.x): email baru dan konfirmasi (kata sandi, atau akun Google untuk akun tanpa
/// kata sandi), lalu kode 6 angka yang dikirim ke email baru. Emailnya baru berganti setelah
/// kodenya benar; semua HP tetap masuk.
class ChangeEmailScreen extends ConsumerStatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  ConsumerState<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

/// Konfirmasi pemilik akun yang dipakai meminta kode, disimpan untuk "Kirim ulang kode".
typedef _Confirmation = ({String? password, String? idToken});

class _ChangeEmailScreenState extends ConsumerState<ChangeEmailScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _code = TextEditingController();

  /// Email tujuan kode terakhir; selama terisi, isian kode tampil.
  String? _sentTo;
  _Confirmation? _confirmation;

  bool _busy = false;
  String? _emailError;
  String? _passwordError;
  String? _googleError;
  String? _codeError;
  String? _formError;
  String? _googleEmail;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _code.dispose();
    super.dispose();
  }

  void _back() => context.canPop() ? context.pop() : context.go(Routes.settings);

  void _clearErrors() {
    _emailError = null;
    _passwordError = null;
    _googleError = null;
    _codeError = null;
    _formError = null;
  }

  /// Email baru: format email dan bukan email sekarang, seperti aturan server.
  String? _checkEmail(AppLocalizations l10n, User me) {
    final email = _email.text.trim();
    if (!isValidEmail(email)) return l10n.errorEmailInvalid;
    if (email.toLowerCase() == me.email.toLowerCase()) return l10n.errorEmailSame;
    return null;
  }

  Future<void> _sendWithPassword(User me) async {
    if (_busy) return;
    final l10n = context.l10n;
    setState(() {
      _clearErrors();
      _emailError = _checkEmail(l10n, me);
      if (_password.text.isEmpty) _passwordError = l10n.errorPasswordRequired;
    });
    if (_emailError != null || _passwordError != null) return;
    await _request((password: _password.text, idToken: null));
  }

  Future<void> _sendWithGoogle(User me) async {
    if (_busy) return;
    final l10n = context.l10n;
    setState(() {
      _clearErrors();
      _emailError = _checkEmail(l10n, me);
    });
    if (_emailError != null) return;

    setState(() => _busy = true);
    final identity = await _pickGoogle(ref, () => _googleError = l10n.googleSignInFailed);
    if (!mounted) return;
    if (identity == null) {
      setState(() => _busy = false);
      return;
    }
    setState(() => _googleEmail = identity.email);
    await _request((password: null, idToken: identity.idToken));
  }

  /// Kirim ulang kode ke email di isian, dengan konfirmasi yang sama.
  Future<void> _resend(User me) async {
    final confirmation = _confirmation;
    if (_busy || confirmation == null) return;
    final l10n = context.l10n;
    setState(() {
      _clearErrors();
      _emailError = _checkEmail(l10n, me);
    });
    if (_emailError != null) return;
    await _request(confirmation);
  }

  Future<void> _request(_Confirmation confirmation) async {
    final account = ref.read(accountProvider);
    if (account == null) return;
    final l10n = context.l10n;
    final email = _email.text.trim();
    setState(() => _busy = true);
    try {
      await account.profile.requestEmailChange(
        email: email,
        password: confirmation.password,
        idToken: confirmation.idToken,
      );
      if (!mounted) return;
      setState(() {
        _sentTo = email;
        _confirmation = confirmation;
        _code.clear();
      });
    } on ApiError catch (error) {
      if (!mounted) return;
      setState(() {
        switch (error.code) {
          // Konfirmasi yang tersimpan tidak berlaku lagi: ulangi dari awal.
          case ApiErrorCode.invalidCredentials:
            _restart();
            _passwordError = error.message;
          case ApiErrorCode.googleTokenInvalid:
            _restart();
            _googleError = error.message;
          case ApiErrorCode.tooManyRequests:
            _formError = codeRequestError(l10n, error);
          default:
            _emailError = error.errors['email']?.firstOrNull;
            if (_emailError == null) _formError = error.message;
        }
      });
    } on NetworkFailure catch (failure) {
      if (mounted) setState(() => _formError = _networkMessage(l10n, failure));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _googleEmail = null;
        });
      }
    }
  }

  void _restart() {
    _sentTo = null;
    _confirmation = null;
  }

  Future<void> _confirm() async {
    final account = ref.read(accountProvider);
    if (account == null || _busy) return;
    final l10n = context.l10n;
    setState(() {
      _clearErrors();
      if (!isValidEmailCode(_code.text)) _codeError = l10n.errorEmailCode;
    });
    if (_codeError != null) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final user = await account.profile.confirmEmailChange(_code.text);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.emailChanged(user.email))));
      _back();
    } on ApiError catch (error) {
      if (!mounted) return;
      setState(() {
        _codeError = error.errors['code']?.firstOrNull;
        // Email baru keburu dipakai akun lain: ganti emailnya, lalu minta kode lagi.
        _emailError = error.errors['email']?.firstOrNull;
        if (_codeError == null && _emailError == null) _formError = error.message;
      });
    } on NetworkFailure catch (failure) {
      if (mounted) setState(() => _formError = _networkMessage(l10n, failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final me = ref.watch(profileProvider).value;
    final sentTo = _sentTo;

    return AppScaffold(
      child: PageBody(
        children: [
          ScreenHeader(title: l10n.emailChangeTitle, onBack: _back),
          const SizedBox(height: AppDimens.gap10),
          if (me == null)
            const SkeletonCard(lines: 3)
          else ...[
            Text(l10n.emailChangeIntro(me.email), style: text.body),
            if (!me.hasPassword) ...[
              const SizedBox(height: AppDimens.gap6),
              Text(l10n.emailChangeGoogleNote, style: text.caption),
            ],
            const SizedBox(height: AppDimens.gap20),
            LabeledField(
              label: l10n.fieldNewEmail,
              child: TextField(
                controller: _email,
                style: text.input,
                enabled: !_busy,
                keyboardType: TextInputType.emailAddress,
                textInputAction: me.hasPassword && sentTo == null ? TextInputAction.next : TextInputAction.done,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
                decoration: InputDecoration(hintText: l10n.fieldEmailHint, errorText: _emailError),
              ),
            ),
            if (sentTo == null) ...[
              const SizedBox(height: AppDimens.gap20),
              SectionTitle(l10n.deleteAccountVerifyTitle),
              const SizedBox(height: AppDimens.gap10),
              if (me.hasPassword) ...[
                LabeledField(
                  label: l10n.fieldPassword,
                  child: _PasswordInput(
                    controller: _password,
                    enabled: !_busy,
                    error: _passwordError,
                    onSubmitted: () => _sendWithPassword(me),
                    onChanged: () {
                      if (_passwordError != null) setState(() => _passwordError = null);
                    },
                  ),
                ),
                _FormError(message: _formError),
                const SizedBox(height: AppDimens.gap20),
                PrimaryButton(label: l10n.forgotSend, onPressed: _busy ? null : () => _sendWithPassword(me)),
              ] else ...[
                _GoogleConfirmation(
                  busy: _busy,
                  usingEmail: _googleEmail,
                  error: _googleError,
                  onPressed: () => _sendWithGoogle(me),
                ),
                _FormError(message: _formError),
              ],
            ] else ...[
              const SizedBox(height: AppDimens.gap12),
              Semantics(
                liveRegion: true,
                child: StatusText(
                  text: l10n.verifySent(sentTo),
                  icon: Symbols.mark_email_read_rounded,
                  color: palette.muted,
                ),
              ),
              const SizedBox(height: AppDimens.gap14),
              LabeledField(
                label: l10n.forgotCode,
                child: TextField(
                  controller: _code,
                  style: text.inputStrong,
                  enabled: !_busy,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                  onSubmitted: (_) => _confirm(),
                  decoration: InputDecoration(hintText: l10n.forgotCodeHint, errorText: _codeError),
                ),
              ),
              _FormError(message: _formError),
              const SizedBox(height: AppDimens.gap20),
              PrimaryButton(label: l10n.emailChangeConfirm, onPressed: _busy ? null : _confirm),
              const SizedBox(height: AppDimens.gap8),
              Center(
                child: TextButton(onPressed: _busy ? null : () => _resend(me), child: Text(l10n.forgotResend)),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Pilih akun Google untuk memastikan ini pemilik akun. `null` kalau pilihan akun ditutup atau
/// gagal di HP; kegagalan di HP dilaporkan lewat [onFailure].
Future<GoogleIdentity?> _pickGoogle(WidgetRef ref, void Function() onFailure) async {
  try {
    return await ref.read(googleAccountsProvider).pick();
  } on GoogleAccountsFailure catch (failure) {
    debugPrint('Memilih akun Google gagal di HP: ${failure.detail}');
    onFailure();
    return null;
  }
}

/// Token FCM HP ini, supaya tetap terdaftar setelah kata sandi diganti.
Future<String?> _deviceFcmToken(WidgetRef ref) async {
  final account = ref.read(accountProvider);
  return await account?.store.meta(MetaKeys.deviceToken) ?? await ref.read(pushServiceProvider).token();
}

String _networkMessage(AppLocalizations l10n, NetworkFailure failure) =>
    (failure.status ?? 0) >= 500 ? l10n.genericError : l10n.needsConnection;

/// 429 saat mengganti kata sandi: kira-kira berapa menit lagi menurut `Retry-After`.
String _tooOften(AppLocalizations l10n, ApiError error) {
  final wait = error.retryAfter;
  if (wait == null) return error.message;
  return l10n.passwordTooOften((wait.inSeconds / 60).ceil().clamp(1, 60));
}

/// Isian kata sandi dengan tombol lihat.
class _PasswordInput extends StatefulWidget {
  const _PasswordInput({
    required this.controller,
    required this.enabled,
    this.hint,
    this.error,
    this.newPassword = false,
    this.onSubmitted,
    this.onChanged,
  });

  final TextEditingController controller;
  final bool enabled;
  final String? hint;
  final String? error;

  /// Kata sandi baru: isi otomatis menawarkan kata sandi baru, bukan yang tersimpan.
  final bool newPassword;
  final VoidCallback? onSubmitted;
  final VoidCallback? onChanged;

  @override
  State<_PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<_PasswordInput> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onSubmitted = widget.onSubmitted;

    return TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      style: context.text.input,
      obscureText: _obscure,
      textInputAction: onSubmitted == null ? TextInputAction.next : TextInputAction.done,
      autofillHints: [widget.newPassword ? AutofillHints.newPassword : AutofillHints.password],
      onSubmitted: onSubmitted == null ? null : (_) => onSubmitted(),
      onChanged: (_) => widget.onChanged?.call(),
      decoration: InputDecoration(
        hintText: widget.hint,
        errorText: widget.error,
        suffixIcon: IconButton(
          tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
            _obscure ? Symbols.visibility_rounded : Symbols.visibility_off_rounded,
            size: AppDimens.iconLg,
            color: context.palette.muted,
          ),
        ),
      ),
    );
  }
}

/// Konfirmasi lewat akun Google yang tersambung, untuk akun tanpa kata sandi.
class _GoogleConfirmation extends StatelessWidget {
  const _GoogleConfirmation({required this.busy, required this.onPressed, this.usingEmail, this.error});

  final bool busy;
  final VoidCallback onPressed;
  final String? usingEmail;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final usingEmail = this.usingEmail;
    final error = this.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(l10n.deleteAccountVerifyTitle),
        const SizedBox(height: AppDimens.gap10),
        Text(l10n.accountGoogleHint, style: text.body),
        const SizedBox(height: AppDimens.gap10),
        GoogleSignInButton(label: l10n.googleContinue, onPressed: busy ? null : onPressed),
        if (usingEmail != null) ...[
          const SizedBox(height: AppDimens.gap12),
          Semantics(
            liveRegion: true,
            child: Text(l10n.googleUsingAccount(usingEmail), style: text.small, textAlign: TextAlign.center),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: AppDimens.gap12),
          Semantics(
            liveRegion: true,
            child: StatusText(text: error, icon: Symbols.error_rounded, color: palette.danger),
          ),
        ],
      ],
    );
  }
}

/// Pesan error di bawah isian, kalau ada.
class _FormError extends StatelessWidget {
  const _FormError({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.gap12),
      child: Semantics(
        liveRegion: true,
        child: StatusText(text: message, icon: Symbols.error_rounded, color: context.palette.danger),
      ),
    );
  }
}
