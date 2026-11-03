import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/api/api_error.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/domain/user.dart';
import '../../auth/presentation/forgot_password_screen.dart';

/// Kartu ajakan verifikasi email di Pengaturan (v1.0), selama `email_verified_at` kosong.
/// Tidak ada fitur yang dibatasi; ini hanya ajakan.
class VerifyEmailCard extends StatelessWidget {
  const VerifyEmailCard({super.key, required this.me});

  final User me;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;

    return AppCard(
      child: Row(
        children: [
          Icon(Symbols.mark_email_unread_rounded, size: AppDimens.iconXl, color: palette.warn),
          const SizedBox(width: AppDimens.gap12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.verifyTitle, style: text.rowTitle),
                const SizedBox(height: AppDimens.gap2),
                Text(l10n.verifyCardBody(me.email), style: text.caption),
              ],
            ),
          ),
          TextButton(onPressed: () => showVerifyEmailSheet(context, me.email), child: Text(l10n.verifyAction)),
        ],
      ),
    );
  }
}

Future<void> showVerifyEmailSheet(BuildContext context, String email) =>
    showAppSheet<void>(context, builder: (_) => VerifyEmailSheet(email: email));

/// Kirim kode verifikasi ke email akun, lalu isi kodenya (v1.0).
class VerifyEmailSheet extends ConsumerStatefulWidget {
  const VerifyEmailSheet({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyEmailSheet> createState() => _VerifyEmailSheetState();
}

class _VerifyEmailSheetState extends ConsumerState<VerifyEmailSheet> {
  final TextEditingController _code = TextEditingController();

  bool _sent = false;
  bool _busy = false;
  String? _codeError;
  String? _formError;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  String _networkMessage(NetworkFailure failure) =>
      (failure.status ?? 0) >= 500 ? context.l10n.genericError : context.l10n.needsConnection;

  /// Tutup lembar ini dan beri tahu hasilnya.
  void _finish(String message) {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _send() async {
    final account = ref.read(accountProvider);
    if (account == null || _busy) return;
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _codeError = null;
      _formError = null;
    });
    try {
      final sent = await account.profile.requestEmailVerification();
      if (!mounted) return;
      if (!sent) return _finish(l10n.verifyAlready);
      setState(() => _sent = true);
    } on ApiError catch (error) {
      if (mounted) setState(() => _formError = codeRequestError(l10n, error));
    } on NetworkFailure catch (failure) {
      if (mounted) setState(() => _formError = _networkMessage(failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm() async {
    final account = ref.read(accountProvider);
    if (account == null || _busy) return;
    final l10n = context.l10n;
    if (!isValidEmailCode(_code.text)) {
      setState(() => _codeError = l10n.errorEmailCode);
      return;
    }
    setState(() {
      _busy = true;
      _codeError = null;
      _formError = null;
    });
    try {
      await account.profile.confirmEmailVerification(_code.text);
      if (mounted) _finish(l10n.verifyDone);
    } on ApiError catch (error) {
      if (mounted) {
        setState(() {
          _codeError = error.errors['code']?.firstOrNull;
          if (_codeError == null) _formError = error.message;
        });
      }
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

    return AppSheet(
      title: l10n.verifyTitle,
      footer: PrimaryButton(
        label: _sent ? l10n.verifyConfirm : l10n.forgotSend,
        onPressed: _busy ? null : (_sent ? _confirm : _send),
      ),
      children: [
        Text(_sent ? l10n.verifySent(widget.email) : l10n.verifySheetBody(widget.email), style: text.body),
        if (_sent) ...[
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
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _busy ? null : _send,
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(l10n.forgotResend),
            ),
          ),
        ],
        if (_formError != null)
          Semantics(
            liveRegion: true,
            child: StatusText(text: _formError!, icon: Symbols.error_rounded, color: palette.danger),
          ),
      ],
    );
  }
}
