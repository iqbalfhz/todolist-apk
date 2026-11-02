import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/config/env.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/session/session.dart';
import '../../../core/theme/app_theme.dart';

/// Buka halaman kebijakan (v1.0) di browser HP. Kalau tidak ada yang bisa membukanya,
/// alamatnya disebut supaya bisa dibuka sendiri.
Future<void> openPolicyPage(BuildContext context, WidgetRef ref, String url) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final opened = await ref.read(devicePlatformProvider).openUrl(url);
  if (!opened) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.linkOpenFailed(url))));
  }
}

/// "Dengan mendaftar atau masuk dengan Google, kamu menyetujui Syarat layanan dan Kebijakan
/// privasi" di layar Masuk dan Daftar (v1.0). Tautannya berupa tombol, supaya area sentuhnya
/// cukup besar.
class PolicyNotice extends ConsumerWidget {
  const PolicyNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = context.text;

    return Column(
      children: [
        Text(l10n.policyAgree, style: text.caption, textAlign: TextAlign.center),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton(onPressed: () => openPolicyPage(context, ref, Env.termsUrl), child: Text(l10n.policyTerms)),
            Text(l10n.policyAnd, style: text.caption),
            TextButton(onPressed: () => openPolicyPage(context, ref, Env.privacyUrl), child: Text(l10n.policyPrivacy)),
          ],
        ),
      ],
    );
  }
}
