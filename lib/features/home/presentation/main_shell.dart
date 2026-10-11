import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../tasks/presentation/add_task_sheet.dart';

/// Banner keadaan hubungan ke server: offline, atau versi app tertinggal.
class ConnectivityBanners extends ConsumerWidget {
  const ConnectivityBanners({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final connectivity = ref.watch(connectivityProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (connectivity.offline) InfoBanner(message: l10n.offlineBanner),
        if (connectivity.needsAppUpdate) InfoBanner(message: l10n.updateBanner, icon: Symbols.system_update_rounded),
      ],
    );
  }
}

/// Kerangka layar di luar tab bawah (Pengaturan, Profil, Ajak pasangan, Masuk, dan lainnya).
class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          const ConnectivityBanners(),
          Expanded(child: child),
        ],
      ),
    ),
  );
}

/// Kerangka tiga tab v0.1: Beranda, Tugas, Tabungan.
///
/// Liburan (v0.2) dan Kenangan (v0.3) disembunyikan sampai rilisnya.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.location, required this.navigationShell});

  /// Alamat layar yang sedang tampil, misalnya `/tugas`.
  final String location;
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Tombol + mengambang hanya di Beranda dan Tugas.
    final showFab = location == Routes.home || location == Routes.tasks;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ConnectivityBanners(),
            Expanded(child: navigationShell),
          ],
        ),
      ),
      floatingActionButton: showFab
          ? Padding(
              // 20 dari tepi kanan (jarak bawaan Scaffold 16).
              padding: const EdgeInsets.only(right: AppDimens.pageSide - AppDimens.gap16),
              child: FloatingActionButton(
                tooltip: l10n.addTask,
                onPressed: () => showAddTaskSheet(context, dueToday: location == Routes.home),
                child: const Icon(Symbols.add_rounded, size: AppDimens.fabIcon),
              ),
            )
          : null,
      bottomNavigationBar: _NavBar(
        currentIndex: navigationShell.currentIndex,
        // Tab selalu membuka layar utamanya, bukan detail yang terakhir dibuka di tab itu.
        onTap: (index) => navigationShell.goBranch(index, initialLocation: true),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;

    final items = [
      (icon: Symbols.home_rounded, label: l10n.navHome),
      (icon: Symbols.check_box_rounded, label: l10n.navTasks),
      (icon: Symbols.account_balance_wallet_rounded, label: l10n.navSavings),
    ];

    return Semantics(
      container: true,
      label: l10n.navLabel,
      child: Container(
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border(
            top: BorderSide(color: palette.line, width: AppDimens.borderWidth),
          ),
        ),
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppDimens.navHeight),
            child: Row(
              children: [
                for (final (index, item) in items.indexed)
                  Expanded(
                    child: _NavItem(
                      icon: item.icon,
                      label: item.label,
                      selected: index == currentIndex,
                      onTap: () => onTap(index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.text;
    final color = selected ? palette.link : palette.muted;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: AppDimens.gap8, bottom: AppDimens.gap12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppDimens.navIndicatorWidth,
                height: AppDimens.navIndicatorHeight,
                decoration: ShapeDecoration(
                  color: selected ? palette.soft : palette.surface,
                  shape: const StadiumBorder(),
                ),
                child: Icon(icon, size: AppDimens.iconXl, color: color),
              ),
              const SizedBox(height: AppDimens.gap4),
              Text(label, style: selected ? text.navLabelSelected : text.navLabel, maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }
}
