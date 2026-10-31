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
import '../../../core/widgets/widgets.dart';
import '../../auth/data/google_accounts.dart';
import '../../auth/presentation/auth_actions.dart';
import '../../auth/presentation/google_sign_in_button.dart';
import '../../home/presentation/main_shell.dart';
import '../../spaces/domain/household.dart';

/// Pengaturan > Hapus akun (v1.0): akibatnya, lalu konfirmasi dengan kata sandi atau akun Google
/// yang tersambung. Nama dan langkahnya sama dengan halaman publik `/hapus-akun`.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final TextEditingController _password = TextEditingController();

  bool _obscure = true;
  bool _busy = false;
  String? _passwordError;
  String? _googleError;

  /// `DELETE /me` sudah pernah dikirim tanpa balasan yang jelas. Kalau 204-nya hilang, kiriman
  /// berikutnya dibalas 401, dan itu berarti akunnya sudah terhapus.
  bool _requested = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _back() => context.canPop() ? context.pop() : context.go(Routes.settings);

  Future<void> _deleteWithPassword() async {
    if (_busy) return;
    final l10n = context.l10n;
    if (_password.text.isEmpty) {
      setState(() {
        _passwordError = l10n.errorPasswordRequired;
        _googleError = null;
      });
      return;
    }
    setState(() {
      _passwordError = null;
      _googleError = null;
    });
    if (!await _confirm()) return;
    await _delete(password: _password.text, onError: (message) => _passwordError = message);
  }

  Future<void> _deleteWithGoogle() async {
    if (_busy) return;
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _passwordError = null;
      _googleError = null;
    });

    GoogleIdentity? identity;
    try {
      identity = await ref.read(googleAccountsProvider).pick();
    } on GoogleAccountsFailure catch (failure) {
      debugPrint('Memilih akun Google gagal di HP: ${failure.detail}');
      if (mounted) setState(() => _googleError = l10n.googleSignInFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }

    if (identity == null || !mounted) return;
    if (!await _confirm(googleEmail: identity.email)) return;
    await _delete(idToken: identity.idToken, onError: (message) => _googleError = message);
  }

  Future<bool> _confirm({String? googleEmail}) {
    final l10n = context.l10n;
    return confirmDialog(
      context,
      title: l10n.deleteAccountConfirmTitle,
      body: googleEmail == null ? l10n.deleteAccountConfirmBody : l10n.deleteAccountConfirmGoogle(googleEmail),
      confirmLabel: l10n.deleteAccountButton,
      destructive: true,
    );
  }

  Future<void> _delete({String? password, String? idToken, required void Function(String message) onError}) async {
    final userId = ref.read(sessionProvider).userId;
    if (userId == null || !mounted) return;

    final l10n = context.l10n;
    final container = ProviderScope.containerOf(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final account = ref.read(accountProvider);
    setState(() => _busy = true);

    Future<void> finish() async {
      await completeAccountDeletion(container, userId: userId, account: account);
      // Pesan "sesi berakhir" dari 401 kiriman ulang tidak relevan lagi.
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.deleteAccountDone)));
    }

    try {
      await ref.read(authRepositoryProvider).deleteAccount(password: password, idToken: idToken);
      await finish();
    } on ApiError catch (error) {
      if (error.code == ApiErrorCode.unauthenticated && _requested) return finish();
      if (mounted) setState(() => onError(error.message));
    } on NetworkFailure catch (failure) {
      // Request-nya mungkin sudah sampai; kiriman berikutnya yang dibalas 401 berarti selesai.
      _requested = true;
      final message = (failure.status ?? 0) >= 500 ? l10n.genericError : l10n.needsConnection;
      if (mounted) setState(() => onError(message));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final partner = ref.watch(householdProvider)?.partner;

    return AppScaffold(
      child: PageBody(
        children: [
          ScreenHeader(title: l10n.deleteAccountTitle, onBack: _back),
          const SizedBox(height: AppDimens.gap10),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Symbols.warning_rounded, size: AppDimens.iconLg, color: palette.danger),
                    const SizedBox(width: AppDimens.gap8),
                    Expanded(child: Text(l10n.deleteAccountWarning, style: text.cardTitle)),
                  ],
                ),
                const SizedBox(height: AppDimens.gap12),
                _Point(text: l10n.deleteAccountWhatProfile),
                _Point(text: l10n.deleteAccountWhatPersonal),
                if (partner != null) _Point(text: l10n.deleteAccountWhatShared(partner.name)),
                _Point(text: l10n.deleteAccountWhatDevices),
                const SizedBox(height: AppDimens.gap8),
                Text(l10n.deleteAccountAfter, style: text.caption),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.gap20),
          SectionTitle(l10n.deleteAccountVerifyTitle),
          const SizedBox(height: AppDimens.gap10),
          LabeledField(
            label: l10n.fieldPassword,
            child: TextField(
              controller: _password,
              enabled: !_busy,
              style: text.input,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _deleteWithPassword(),
              onChanged: (_) {
                if (_passwordError != null) setState(() => _passwordError = null);
              },
              decoration: InputDecoration(
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
          const SizedBox(height: AppDimens.gap16),
          OutlinedButton.icon(
            onPressed: _busy ? null : _deleteWithPassword,
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.danger,
              side: BorderSide(color: palette.line),
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Symbols.delete_forever_rounded, size: AppDimens.iconLg),
            label: Text(l10n.deleteAccountButton),
          ),
          const SizedBox(height: AppDimens.gap20),
          OrDivider(label: l10n.authOr),
          const SizedBox(height: AppDimens.gap16),
          Text(l10n.deleteAccountGoogleHint, style: text.body),
          const SizedBox(height: AppDimens.gap10),
          GoogleSignInButton(label: l10n.googleContinue, onPressed: _busy ? null : _deleteWithGoogle),
          if (_googleError != null) ...[
            const SizedBox(height: AppDimens.gap12),
            Semantics(
              liveRegion: true,
              child: StatusText(text: _googleError!, icon: Symbols.error_rounded, color: palette.danger),
            ),
          ],
          if (_busy) ...[
            const SizedBox(height: AppDimens.gap12),
            Semantics(
              liveRegion: true,
              child: Text(l10n.deleteAccountWorking, style: text.small, textAlign: TextAlign.center),
            ),
          ],
        ],
      ),
    );
  }
}

/// Satu butir yang ikut terhapus.
class _Point extends StatelessWidget {
  const _Point({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppDimens.gap6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppDimens.gap2),
          child: Icon(Symbols.delete_rounded, size: AppDimens.iconSm, color: context.palette.muted),
        ),
        const SizedBox(width: AppDimens.gap8),
        Expanded(child: Text(text, style: context.text.body)),
      ],
    ),
  );
}
