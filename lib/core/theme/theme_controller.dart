import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../session/session.dart';
import '../storage/key_value_store.dart';
import 'app_palette.dart';

/// Pilihan tema (Mawar atau Anggrek) dan mode (terang, gelap, ikuti sistem).
/// Disimpan di HP, bukan di server.
class ThemeChoice {
  const ThemeChoice({required this.name, required this.mode});

  final AppThemeName name;
  final ThemeMode mode;
}

class ThemeController extends Notifier<ThemeChoice> {
  @override
  ThemeChoice build() {
    final bootstrap = ref.watch(bootstrapProvider);
    return ThemeChoice(
      name: AppThemeName.parse(bootstrap.themeName),
      mode: ThemeMode.values.firstWhere((mode) => mode.name == bootstrap.themeMode, orElse: () => ThemeMode.system),
    );
  }

  KeyValueStore get _storage => ref.read(keyValueStoreProvider);

  void setName(AppThemeName name) {
    state = ThemeChoice(name: name, mode: state.mode);
    unawaited(_storage.write(StorageKeys.themeName, name.name));
  }

  void setMode(ThemeMode mode) {
    state = ThemeChoice(name: state.name, mode: mode);
    unawaited(_storage.write(StorageKeys.themeMode, mode.name));
  }
}

final themeProvider = NotifierProvider<ThemeController, ThemeChoice>(ThemeController.new);
