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

/// Layar Masuk: email dan kata sandi.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => const _AuthForm(registering: false);
}

/// Layar Daftar: nama panggilan, email, dan kata sandi (minimal 8 karakter).
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) => const _AuthForm(registering: true);
}

class _AuthForm extends ConsumerStatefulWidget {
  const _AuthForm({required this.registering});

  final bool registering;

  @override
  ConsumerState<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<_AuthForm> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _formError;
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _validate() {
    final l10n = context.l10n;
    final registering = widget.registering;
    final name = _name.text.trim();

    setState(() {
      _formError = null;
      _nameError = !registering
          ? null
          : name.isEmpty
          ? l10n.errorNameRequired
          : textLength(name) > Limits.name
          ? l10n.errorNameLong
          : null;
      _emailError = isValidEmail(_email.text) ? null : l10n.errorEmailInvalid;
      _passwordError = _password.text.isEmpty
          ? l10n.errorPasswordRequired
          : registering && _password.text.length < Limits.passwordMin
          ? l10n.errorPasswordShort
          : null;
    });

    return _nameError == null && _emailError == null && _passwordError == null;
  }

  Future<void> _submit() async {
    if (_busy || !_validate()) return;

    final l10n = context.l10n;
    final auth = ref.read(authRepositoryProvider);
    final deviceName = ref.read(deviceInfoProvider).name;
    setState(() => _busy = true);

    try {
      final result = widget.registering
          ? await auth.register(
              name: _name.text,
              email: _email.text,
              password: _password.text,
              deviceName: deviceName,
              timezone: await deviceTimezone(),
            )
          : await auth.login(email: _email.text, password: _password.text, deviceName: deviceName);

      // Layar berikutnya ditentukan router begitu sesi berubah.
      await completeSignIn(ref, result);
    } on ApiError catch (error) {
      if (!mounted) return;
      // Pesan error diambil dari `message` balasan API.
      setState(() {
        _nameError = error.errors['name']?.firstOrNull;
        _emailError = error.errors['email']?.firstOrNull;
        _passwordError = error.errors['password']?.firstOrNull;
        if (_nameError == null && _emailError == null && _passwordError == null) _formError = error.message;
      });
    } on NetworkFailure {
      if (mounted) setState(() => _formError = l10n.needsConnection);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final registering = widget.registering;
    final expired = ref.watch(sessionProvider).expired;

    return AppScaffold(
      child: PageBody(
        children: [
          const SizedBox(height: AppDimens.gap24),
          Semantics(
            header: true,
            child: Text(registering ? l10n.registerTitle : l10n.loginTitle, style: text.homeTitle),
          ),
          const SizedBox(height: AppDimens.gap6),
          Text(registering ? l10n.registerSubtitle : l10n.loginSubtitle, style: text.body),
          if (!registering && expired) ...[
            const SizedBox(height: AppDimens.gap12),
            StatusText(text: l10n.sessionExpired, icon: Symbols.error_rounded, color: palette.warn),
          ],
          const SizedBox(height: AppDimens.gap20),
          AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (registering) ...[
                  LabeledField(
                    label: l10n.fieldName,
                    child: TextField(
                      controller: _name,
                      style: text.input,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.nickname],
                      decoration: InputDecoration(hintText: l10n.fieldNameHint, errorText: _nameError),
                    ),
                  ),
                  const SizedBox(height: AppDimens.gap14),
                ],
                LabeledField(
                  label: l10n.fieldEmail,
                  child: TextField(
                    controller: _email,
                    style: text.input,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(hintText: l10n.fieldEmailHint, errorText: _emailError),
                  ),
                ),
                const SizedBox(height: AppDimens.gap14),
                LabeledField(
                  label: l10n.fieldPassword,
                  child: TextField(
                    controller: _password,
                    style: text.input,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    autofillHints: [registering ? AutofillHints.newPassword : AutofillHints.password],
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: registering ? l10n.fieldPasswordHint : null,
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
            ),
          ),
          if (_formError != null) ...[
            const SizedBox(height: AppDimens.gap12),
            Semantics(
              liveRegion: true,
              child: StatusText(text: _formError!, icon: Symbols.error_rounded, color: palette.danger),
            ),
          ],
          const SizedBox(height: AppDimens.gap20),
          PrimaryButton(label: registering ? l10n.registerButton : l10n.loginButton, onPressed: _busy ? null : _submit),
          const SizedBox(height: AppDimens.gap8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: Text(registering ? l10n.registerHasAccount : l10n.loginNoAccount, style: text.body)),
              TextButton(
                onPressed: _busy ? null : () => context.go(registering ? Routes.login : Routes.register),
                child: Text(registering ? l10n.loginButton : l10n.registerButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
