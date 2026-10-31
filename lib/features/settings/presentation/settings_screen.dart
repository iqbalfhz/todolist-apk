import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/currencies.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/session/session.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/domain/user.dart';
import '../../auth/presentation/auth_actions.dart';
import '../../home/presentation/main_shell.dart';
import '../../savings/presentation/goal_form_sheet.dart';
import '../../spaces/domain/household.dart';
import '../../spaces/presentation/member_avatar.dart';

/// Pengaturan: akun dan ruang, tema, notifikasi, mata uang, dan keluar.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _loggingOut = false;

  void _back() => context.canPop() ? context.pop() : context.go(Routes.home);

  Future<void> _pickCurrency(User me) async {
    final l10n = context.l10n;
    final picked = await showCurrencyPicker(context, title: l10n.settingsCurrencySheet, selected: me.defaultCurrency);
    if (picked == null || picked == me.defaultCurrency) return;
    await ref.read(accountProvider)?.profile.update(defaultCurrency: picked);
  }

  Future<void> _logout() async {
    final l10n = context.l10n;
    // Peringatkan kalau masih ada perubahan yang belum terkirim.
    final pending = await ref.read(accountProvider)?.outbox.pendingCount() ?? 0;
    if (!mounted) return;

    final confirmed = await confirmDialog(
      context,
      title: l10n.logoutConfirmTitle,
      body: pending > 0 ? l10n.logoutPendingBody(pending) : l10n.logoutConfirmBody,
      confirmLabel: l10n.settingsLogout,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    final container = ProviderScope.containerOf(context, listen: false);
    setState(() => _loggingOut = true);
    await signOut(container);
  }

  /// Minta launcher menyematkan widget; kalau tidak bisa, jelaskan cara menambahkannya sendiri.
  Future<void> _pinWidget() async {
    final pinned = await ref.read(devicePlatformProvider).pinWidget();
    if (!pinned && mounted) showMessage(context, context.l10n.settingsWidgetManual);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final household = ref.watch(householdProvider);
    final theme = ref.watch(themeProvider);

    return AppScaffold(
      child: PageBody(
        children: [
          ScreenHeader(title: l10n.settingsTitle, onBack: _back),
          const SizedBox(height: AppDimens.gap10),
          if (household == null)
            const SkeletonCard(lines: 2)
          else
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.cardPadding, vertical: AppDimens.gap4),
              child: Column(
                children: [
                  _NavRow(
                    leading: _ProfileBadge(me: household.me),
                    title: l10n.settingsProfile,
                    subtitle: l10n.settingsProfileSub,
                    minHeight: AppDimens.rowMinHeightTall,
                    onTap: () => context.push(Routes.profile),
                  ),
                  const RowDivider(),
                  _NavRow(
                    leading: Container(
                      width: AppDimens.iconCircle,
                      height: AppDimens.iconCircle,
                      decoration: BoxDecoration(color: palette.soft, shape: BoxShape.circle),
                      child: const Icon(Symbols.group_rounded, size: AppDimens.iconLg),
                    ),
                    title: l10n.settingsSharedSpace,
                    subtitle: household.isPaired ? l10n.settingsSharedSpacePaired : l10n.settingsSharedSpaceUnpaired,
                    minHeight: AppDimens.rowMinHeightTall,
                    onTap: () => context.push(Routes.pairing),
                  ),
                  const RowDivider(),
                  _NavRow(
                    leading: Container(
                      width: AppDimens.iconCircle,
                      height: AppDimens.iconCircle,
                      decoration: BoxDecoration(color: palette.soft, shape: BoxShape.circle),
                      child: Icon(Symbols.favorite_rounded, size: AppDimens.iconLg, color: palette.brand),
                    ),
                    title: l10n.settingsSpecialDates,
                    subtitle: l10n.settingsSpecialDatesSub,
                    minHeight: AppDimens.rowMinHeightTall,
                    onTap: () => context.push(Routes.specialDates),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppDimens.gap10),
          SectionTitle(l10n.settingsTheme),
          const SizedBox(height: AppDimens.gap10),
          Semantics(
            container: true,
            label: l10n.settingsThemePick,
            child: Row(
              children: [
                Expanded(
                  child: _ThemeCard(
                    name: AppThemeName.mawar,
                    label: l10n.themeMawar,
                    code: l10n.themeMawarCode,
                    selected: theme.name == AppThemeName.mawar,
                  ),
                ),
                const SizedBox(width: AppDimens.gap10),
                Expanded(
                  child: _ThemeCard(
                    name: AppThemeName.anggrek,
                    label: l10n.themeAnggrek,
                    code: l10n.themeAnggrekCode,
                    selected: theme.name == AppThemeName.anggrek,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.gap10),
          SegmentedControl<ThemeMode>(
            semanticLabel: l10n.settingsModePick,
            selected: theme.mode,
            // Perubahan langsung terlihat.
            onChanged: ref.read(themeProvider.notifier).setMode,
            segments: [
              Segment(value: ThemeMode.light, label: l10n.modeLight),
              Segment(value: ThemeMode.dark, label: l10n.modeDark),
              Segment(value: ThemeMode.system, label: l10n.modeSystem),
            ],
          ),
          const SizedBox(height: AppDimens.gap10),
          SectionTitle(l10n.settingsNotifications),
          const SizedBox(height: AppDimens.gap10),
          if (household == null) const SkeletonCard() else _NotificationSwitches(prefs: household.me.notificationPrefs),
          const SizedBox(height: AppDimens.gap16),
          if (household != null)
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.cardPadding),
              child: Column(
                children: [
                  _NavRow(
                    title: l10n.settingsCurrency,
                    subtitle: currencyOf(household.me.defaultCurrency).label,
                    onTap: () => _pickCurrency(household.me),
                  ),
                  const RowDivider(),
                  _NavRow(title: l10n.settingsWidget, subtitle: l10n.settingsWidgetSub, onTap: _pinWidget),
                  const RowDivider(),
                  _NavRow(
                    title: l10n.settingsExport,
                    subtitle: l10n.settingsExportSub,
                    onTap: () => context.push(Routes.exportData),
                  ),
                  const RowDivider(),
                  _NavRow(
                    title: l10n.settingsDeleteAccount,
                    subtitle: l10n.settingsDeleteAccountSub,
                    onTap: () => context.push(Routes.deleteAccount),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppDimens.gap20),
          OutlinedButton.icon(
            onPressed: _loggingOut ? null : _logout,
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.danger,
              side: BorderSide(color: palette.line),
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Symbols.logout_rounded, size: AppDimens.iconLg),
            label: Text(l10n.settingsLogout),
          ),
        ],
      ),
    );
  }
}

/// Avatar 44 dengan lencana kamera, penanda foto bisa diubah dari Profil.
class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({required this.me});

  final User me;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SizedBox(
      width: AppDimens.avatarRow + AppDimens.gap2,
      height: AppDimens.avatarRow + AppDimens.gap2,
      child: Stack(
        children: [
          MyAvatar(user: me, size: AppDimens.avatarRow, filled: true),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: AppDimens.badge,
              height: AppDimens.badge,
              decoration: BoxDecoration(
                color: palette.primary,
                shape: BoxShape.circle,
                border: Border.all(color: palette.surface, width: AppDimens.borderWidthStrong),
              ),
              child: Icon(Symbols.photo_camera_rounded, size: AppDimens.gap10, color: palette.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris yang membuka layar atau pilihan lain: judul, keterangan, dan panah.
class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.leading,
    this.minHeight = AppDimens.rowMinHeightSettings,
  });

  final Widget? leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final text = context.text;

    return MergeSemantics(
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.gap8),
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: AppDimens.gap12)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: text.rowTitle),
                      Text(subtitle, style: text.small),
                    ],
                  ),
                ),
                const Icon(Symbols.chevron_right_rounded, size: AppDimens.iconMd),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu pilihan tema: tiga contoh warna bertumpuk, tanda centang, nama, dan kode palet.
class _ThemeCard extends ConsumerWidget {
  const _ThemeCard({required this.name, required this.label, required this.code, required this.selected});

  final AppThemeName name;
  final String label;
  final String code;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final text = context.text;
    final swatches = AppPalette.swatchesOf(name);

    return Semantics(
      container: true,
      button: true,
      selected: selected,
      child: Material(
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.cardRadiusSmall),
          side: BorderSide(
            color: selected ? palette.primary : palette.line,
            width: selected ? AppDimens.borderWidthStrong : AppDimens.borderWidth,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => ref.read(themeProvider.notifier).setName(name),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppDimens.themeCardMinHeight),
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.gap12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ExcludeSemantics(
                          child: SizedBox(
                            height: AppDimens.themeSwatch,
                            child: Stack(
                              children: [
                                for (final (index, color) in swatches.indexed)
                                  Positioned(
                                    left: index * (AppDimens.themeSwatch - AppDimens.gap6),
                                    child: Container(
                                      width: AppDimens.themeSwatch,
                                      height: AppDimens.themeSwatch,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: palette.surface, width: AppDimens.borderWidthStrong),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Pilihan tidak hanya ditandai warna garis.
                      if (selected)
                        Container(
                          width: AppDimens.checkCircle,
                          height: AppDimens.checkCircle,
                          decoration: BoxDecoration(color: palette.primary, shape: BoxShape.circle),
                          child: Icon(Symbols.check_rounded, size: AppDimens.checkIcon, color: palette.onPrimary),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.gap10),
                  Text(label, style: text.sectionTitle),
                  Text(code, style: text.small),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Switch yang memetakan `notification_prefs`.
class _NotificationSwitches extends ConsumerWidget {
  const _NotificationSwitches({required this.prefs});

  final NotificationPrefs prefs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    void save(NotificationPrefs next) => ref.read(accountProvider)?.profile.updateNotificationPrefs(next);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.cardPadding),
      child: Column(
        children: [
          SwitchRow(
            title: l10n.notifTaskReminders,
            subtitle: l10n.notifTaskRemindersSub,
            value: prefs.taskReminders,
            onChanged: (value) => save(prefs.copyWith(taskReminders: value)),
          ),
          const RowDivider(),
          SwitchRow(
            title: l10n.notifPartnerActivity,
            subtitle: l10n.notifPartnerActivitySub,
            value: prefs.partnerActivity,
            onChanged: (value) => save(prefs.copyWith(partnerActivity: value)),
          ),
          const RowDivider(),
          SwitchRow(
            title: l10n.notifSavingsActivity,
            subtitle: l10n.notifSavingsActivitySub,
            value: prefs.savingsActivity,
            onChanged: (value) => save(prefs.copyWith(savingsActivity: value)),
          ),
          const RowDivider(),
          SwitchRow(
            title: l10n.notifSpecialDates,
            subtitle: l10n.notifSpecialDatesSub,
            value: prefs.specialDates,
            onChanged: (value) => save(prefs.copyWith(specialDates: value)),
          ),
          const RowDivider(),
          SwitchRow(
            title: l10n.notifTripReminders,
            subtitle: l10n.notifTripRemindersSub,
            value: prefs.tripReminders,
            onChanged: (value) => save(prefs.copyWith(tripReminders: value)),
          ),
          const RowDivider(),
          SwitchRow(
            title: l10n.notifSavingsReminders,
            subtitle: l10n.notifSavingsRemindersSub,
            value: prefs.savingsReminders,
            onChanged: (value) => save(prefs.copyWith(savingsReminders: value)),
          ),
        ],
      ),
    );
  }
}
