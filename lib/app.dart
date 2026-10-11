import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app_services.dart';
import 'core/l10n/l10n.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

/// Tempat pesan singkat dari luar layar ditampilkan (antrean, sesi, notifikasi).
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

final Map<(AppThemeName, Brightness), ThemeData> _themes = {};

ThemeData _themeFor(AppThemeName name, Brightness brightness) =>
    _themes.putIfAbsent((name, brightness), () => buildAppTheme(name, brightness));

class TodoApp extends ConsumerWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choice = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'todolist',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: _themeFor(choice.name, Brightness.light),
      darkTheme: _themeFor(choice.name, Brightness.dark),
      themeMode: choice.mode,
      // Semua teks di layar berbahasa Indonesia.
      locale: const Locale('id'),
      supportedLocales: const [Locale('id')],
      localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
      builder: (context, child) {
        final dark = Theme.of(context).brightness == Brightness.dark;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          // Ikon bilah status mengikuti mode terang atau gelap.
          value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
            statusBarColor: const Color(0x00000000),
            systemNavigationBarColor: context.palette.surface,
            systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
          ),
          child: AppServices(messengerKey: scaffoldMessengerKey, child: child!),
        );
      },
    );
  }
}
