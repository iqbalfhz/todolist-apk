import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/notifications/push_service.dart';
import '../../../core/platform/device_platform.dart';
import '../../../core/session/session.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../home/presentation/main_shell.dart';

/// Izin notifikasi: alasan singkat, tombol minta izin (Android 13+), lalu panduan
/// mematikan optimasi baterai sesuai merek HP. Bisa dilewati.
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

  Future<void> _openBatterySettings() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final opened = await ref.read(devicePlatformProvider).openBatterySettings();
    if (!opened) messenger.showSnackBar(SnackBar(content: Text(l10n.batteryOpenFailed)));
  }

  void _finish() => ref.read(onboardingProvider.notifier).completeNotifications();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final device = ref.watch(deviceInfoProvider);
    final brand = device.batteryGuideBrand;
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
            Center(
              child: StatusText(text: l10n.notifAllowed, icon: Symbols.check_circle_rounded, color: palette.ok),
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
          if (brand != null) ...[
            const SizedBox(height: AppDimens.gap16),
            AppCard(
              semanticLabel: l10n.batteryTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Symbols.battery_saver_rounded, size: AppDimens.iconLg, color: palette.brand),
                      const SizedBox(width: AppDimens.gap8),
                      Expanded(child: Text(l10n.batteryTitle, style: text.sectionTitle)),
                    ],
                  ),
                  const SizedBox(height: AppDimens.gap8),
                  Text(l10n.batteryBody(_brandName(brand)), style: text.body),
                  const SizedBox(height: AppDimens.gap8),
                  Text(_steps(l10n, brand), style: text.body.copyWith(color: palette.text)),
                  const SizedBox(height: AppDimens.gap6),
                  Text(l10n.batteryNote, style: text.small),
                  const SizedBox(height: AppDimens.gap8),
                  OutlinedButton(onPressed: _openBatterySettings, child: Text(l10n.batteryOpen)),
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

  static String _brandName(BatteryGuideBrand brand) => switch (brand) {
    BatteryGuideBrand.xiaomi => 'Xiaomi',
    BatteryGuideBrand.oppo => 'Oppo',
    BatteryGuideBrand.vivo => 'Vivo',
    BatteryGuideBrand.realme => 'Realme',
  };

  static String _steps(AppLocalizations l10n, BatteryGuideBrand brand) => switch (brand) {
    BatteryGuideBrand.xiaomi => l10n.batteryStepsXiaomi,
    BatteryGuideBrand.oppo => l10n.batteryStepsOppo,
    BatteryGuideBrand.vivo => l10n.batteryStepsVivo,
    BatteryGuideBrand.realme => l10n.batteryStepsRealme,
  };
}
