import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/notifications/push_service.dart';
import '../../../core/session/session.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../home/presentation/main_shell.dart';

/// Izin notifikasi: alasan singkat dan tombol minta izin (Android 13+). Bisa dilewati.
///
/// Panduan mematikan optimasi baterai tidak ditampilkan lagi: langkahnya di Pengaturan HP
/// terlalu merepotkan untuk alur pertama kali (keputusan pemilik, 23 Oktober 2026).
class NotificationPermissionScreen extends ConsumerStatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  ConsumerState<NotificationPermissionScreen> createState() => _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState extends ConsumerState<NotificationPermissionScreen> {
  /// `null` selama belum diminta; lalu hasil permintaannya.
  bool? _granted;
  bool _asking = false;

  @override
  void initState() {
    super.initState();
    _checkExisting();
  }

  Future<void> _checkExisting() async {
    final granted = await ref.read(pushServiceProvider).hasPermission();
    if (mounted && granted) setState(() => _granted = true);
  }

  Future<void> _ask() async {
    setState(() => _asking = true);
    final granted = await ref.read(pushServiceProvider).requestPermission();
    if (mounted) {
      setState(() {
        _granted = granted;
        _asking = false;
      });
    }
  }

  void _finish() => ref.read(onboardingProvider.notifier).completeNotifications();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final device = ref.watch(deviceInfoProvider);
    final needsPermission = device.needsNotificationPermission && _granted != true;

    return AppScaffold(
      child: PageBody(
        children: [
          const SizedBox(height: AppDimens.gap24),
          Center(
            child: Container(
              width: AppDimens.avatarMedium,
              height: AppDimens.avatarMedium,
              decoration: BoxDecoration(color: palette.soft, shape: BoxShape.circle),
              child: Icon(Symbols.notifications_rounded, size: AppDimens.iconXxl, color: palette.brand),
            ),
          ),
          const SizedBox(height: AppDimens.gap16),
          Semantics(
            header: true,
            child: Text(l10n.notifTitle, style: text.heroTitle, textAlign: TextAlign.center),
          ),
          const SizedBox(height: AppDimens.gap6),
          Text(l10n.notifBody, style: text.body, textAlign: TextAlign.center),
          const SizedBox(height: AppDimens.gap20),
          if (needsPermission)
            PrimaryButton(
              label: l10n.notifAllow,
              icon: Symbols.notifications_rounded,
              onPressed: _asking ? null : _ask,
            ),
          if (_granted == true)
            // Di dalam kartu: `ok` di atas `bg` Anggrek terang kontrasnya di bawah 4.5:1.
            AppCard(
              child: Center(
                child: StatusText(text: l10n.notifAllowed, icon: Symbols.check_circle_rounded, color: palette.ok),
              ),
            ),
          if (_granted == false) ...[
            const SizedBox(height: AppDimens.gap12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.notifDenied, style: text.body),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => ref.read(pushServiceProvider).openSystemSettings(),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(l10n.notifOpenSettings),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppDimens.gap20),
          // Setelah izin diberikan (atau tidak diperlukan), tombolnya menjadi "Lanjut".
          if (needsPermission)
            Center(
              child: TextButton(onPressed: _finish, child: Text(l10n.commonSkip)),
            )
          else
            PrimaryButton(label: l10n.commonContinue, onPressed: _finish),
        ],
      ),
    );
  }
}
