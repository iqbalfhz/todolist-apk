import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/auth/presentation/auth_screens.dart';
import '../../features/auth/presentation/notification_permission_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/main_shell.dart';
import '../../features/savings/presentation/goal_detail_screen.dart';
import '../../features/savings/presentation/savings_screen.dart';
import '../../features/settings/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/spaces/presentation/pairing_screen.dart';
import '../../features/tasks/presentation/manage_lists_screen.dart';
import '../../features/tasks/presentation/task_detail_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../session/session.dart';
import 'routes.dart';

/// Memberi tahu go_router saat sesi atau langkah alur pertama kali berubah,
/// supaya pengalihan dihitung ulang.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref
      ..listen(sessionProvider, (_, _) => notifyListeners())
      ..listen(onboardingProvider, (_, _) => notifyListeners());
  }
}

/// Alur pertama kali: Masuk atau Daftar → Izin notifikasi → Ajak pasangan → Beranda.
String? _redirect(Ref ref, GoRouterState state) {
  final session = ref.read(sessionProvider);
  final onboarding = ref.read(onboardingProvider);
  final path = state.uri.path;
  final atAuth = path == Routes.login || path == Routes.register;

  if (!session.isSignedIn) return atAuth ? null : Routes.login;
  if (!onboarding.notificationsDone) return path == Routes.notifications ? null : Routes.notifications;
  if (!onboarding.pairingDone) return path == Routes.pairing ? null : Routes.pairing;
  if (atAuth || path == Routes.notifications || path == '/') return Routes.home;
  return null;
}

bool _fromHome(GoRouterState state) => state.uri.queryParameters[Routes.fromParam] == Routes.fromHome;

/// Layar detail diberi kunci per ID. Tanpa itu, pindah langsung dari satu detail ke detail lain
/// (misalnya lewat ketukan notifikasi) memakai ulang isian milik data sebelumnya.
ValueKey<String> _detailKey(GoRouterState state) => ValueKey(state.pathParameters['id']!);

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: Routes.home,
    refreshListenable: refresh,
    redirect: (_, state) => _redirect(ref, state),
    routes: [
      GoRoute(path: '/', redirect: (_, _) => Routes.home),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.register, builder: (_, _) => const RegisterScreen()),
      GoRoute(path: Routes.notifications, builder: (_, _) => const NotificationPermissionScreen()),
      GoRoute(path: Routes.pairing, builder: (_, _) => const PairingScreen()),
      GoRoute(
        path: Routes.settings,
        builder: (_, _) => const SettingsScreen(),
        routes: [GoRoute(path: 'profil', builder: (_, _) => const ProfileScreen())],
      ),
      // Tab bawah v0.1. Detail tugas dan detail tabungan tetap menampilkan tab bawah.
      StatefulShellRoute.indexedStack(
        builder: (_, state, navigationShell) => MainShell(location: state.uri.path, navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.tasks,
                builder: (_, _) => const TasksScreen(),
                routes: [
                  GoRoute(path: 'daftar', builder: (_, _) => const ManageListsScreen()),
                  GoRoute(
                    path: ':id',
                    builder: (_, state) => TaskDetailScreen(
                      key: _detailKey(state),
                      taskId: state.pathParameters['id']!,
                      fromHome: _fromHome(state),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.savings,
                builder: (_, _) => const SavingsScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, state) => GoalDetailScreen(
                      key: _detailKey(state),
                      goalId: state.pathParameters['id']!,
                      fromHome: _fromHome(state),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);

  return router;
});
