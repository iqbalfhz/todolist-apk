import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/notifications/push_service.dart';
import 'core/platform/device_platform.dart';
import 'core/session/session.dart';
import 'core/storage/key_value_store.dart';
import 'core/time/space_clock.dart';
import 'core/utils/dates.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Env.isConfigured) {
    runApp(const _MissingEnv());
    return;
  }

  await initializeDateFormatting(dateLocale);
  ensureTimezonesLoaded();

  const storage = SecureKeyValueStore();
  const platform = DevicePlatform();

  // Dibaca sebelum frame pertama: sudah masuk atau belum, dan tema yang dipilih.
  final bootstrap = await Bootstrap.load(storage, platform);

  // Dua channel Android dibuat saat app pertama dibuka.
  final push = FirebasePushService();
  await push.init();

  runApp(
    ProviderScope(
      // Provider di app ini hanya membaca cache lokal; kegagalannya tidak diulang otomatis.
      retry: (_, _) => null,
      overrides: [
        bootstrapProvider.overrideWithValue(bootstrap),
        keyValueStoreProvider.overrideWithValue(storage),
        devicePlatformProvider.overrideWithValue(platform),
        pushServiceProvider.overrideWithValue(push),
      ],
      child: const TodoApp(),
    ),
  );
}

/// Tampil kalau app dijalankan tanpa `--dart-define-from-file=env/<nama>.json`.
class _MissingEnv extends StatelessWidget {
  const _MissingEnv();

  @override
  Widget build(BuildContext context) => const Directionality(
    textDirection: TextDirection.ltr,
    child: ColoredBox(
      color: Color(0xFFFCF3F7),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'API_BASE_URL belum diisi.\n\n'
              'Jalankan dengan:\nflutter run --dart-define-from-file=env/dev.json',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF2B1A22), fontSize: 16, height: 1.4),
            ),
          ),
        ),
      ),
    ),
  );
}
