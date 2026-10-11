import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../platform/device_platform.dart';
import '../storage/key_value_store.dart';

/// Nilai yang dibaca dari HP sebelum frame pertama, supaya app langsung tahu
/// apakah sedang masuk dan tema apa yang dipakai.
class Bootstrap {
  const Bootstrap({
    this.token,
    this.userId,
    this.themeName,
    this.themeMode,
    this.notificationsOnboarded = false,
    this.pairingOnboarded = false,
    this.device = DeviceInfo.unknown,
  });

  final String? token;
  final String? userId;
  final String? themeName;
  final String? themeMode;
  final bool notificationsOnboarded;
  final bool pairingOnboarded;
  final DeviceInfo device;

  static Future<Bootstrap> load(KeyValueStore storage, DevicePlatform platform) async {
    final token = await storage.read(StorageKeys.token);
    final userId = await storage.read(StorageKeys.userId);
    final signedIn = token != null && userId != null;

    return Bootstrap(
      token: signedIn ? token : null,
      userId: signedIn ? userId : null,
      themeName: await storage.read(StorageKeys.themeName),
      themeMode: await storage.read(StorageKeys.themeMode),
      notificationsOnboarded: await storage.read(StorageKeys.notificationsOnboarded) != null,
      pairingOnboarded: signedIn && await storage.read(StorageKeys.pairingOnboarded(userId)) != null,
      device: await platform.info(),
    );
  }
}

/// Ditimpa di `main()` dengan hasil [Bootstrap.load].
final bootstrapProvider = Provider<Bootstrap>((ref) => const Bootstrap());

final keyValueStoreProvider = Provider<KeyValueStore>((ref) => const SecureKeyValueStore());

final devicePlatformProvider = Provider<DevicePlatform>((ref) => const DevicePlatform());

final deviceInfoProvider = Provider<DeviceInfo>((ref) => ref.watch(bootstrapProvider).device);

/// Keadaan masuk di HP ini. Satu HP memegang satu token yang berlaku sampai keluar.
class Session {
  const Session.signedOut({this.expired = false}) : userId = null, token = null;

  const Session.signedIn({required String this.userId, required String this.token}) : expired = false;

  final String? userId;
  final String? token;

  /// Keluar karena server membalas 401 (token tidak berlaku lagi), bukan karena pengguna.
  final bool expired;

  bool get isSignedIn => userId != null;
}

class SessionController extends Notifier<Session> {
  @override
  Session build() {
    final bootstrap = ref.watch(bootstrapProvider);
    return bootstrap.userId == null
        ? const Session.signedOut()
        : Session.signedIn(userId: bootstrap.userId!, token: bootstrap.token!);
  }

  KeyValueStore get _storage => ref.read(keyValueStoreProvider);

  Future<void> signIn({required String userId, required String token}) async {
    await _storage.write(StorageKeys.token, token);
    await _storage.write(StorageKeys.userId, userId);
    await ref.read(onboardingProvider.notifier).loadFor(userId);
    state = Session.signedIn(userId: userId, token: token);
  }

  /// Hapus token dari HP. Database lokal akun tidak dihapus.
  Future<void> signOut({bool expired = false}) async {
    if (!state.isSignedIn) return;
    state = Session.signedOut(expired: expired);
    await _storage.write(StorageKeys.token, null);
    await _storage.write(StorageKeys.userId, null);
  }
}

final sessionProvider = NotifierProvider<SessionController, Session>(SessionController.new);

/// Langkah alur pertama kali yang sudah dilewati.
class Onboarding {
  const Onboarding({required this.notificationsDone, required this.pairingDone});

  final bool notificationsDone;
  final bool pairingDone;
}

class OnboardingController extends Notifier<Onboarding> {
  @override
  Onboarding build() {
    final bootstrap = ref.watch(bootstrapProvider);
    return Onboarding(notificationsDone: bootstrap.notificationsOnboarded, pairingDone: bootstrap.pairingOnboarded);
  }

  KeyValueStore get _storage => ref.read(keyValueStoreProvider);

  Future<void> loadFor(String userId) async {
    final pairingDone = await _storage.read(StorageKeys.pairingOnboarded(userId)) != null;
    state = Onboarding(notificationsDone: state.notificationsDone, pairingDone: pairingDone);
  }

  Future<void> completeNotifications() async {
    state = Onboarding(notificationsDone: true, pairingDone: state.pairingDone);
    await _storage.write(StorageKeys.notificationsOnboarded, '1');
  }

  Future<void> completePairing() async {
    state = Onboarding(notificationsDone: state.notificationsDone, pairingDone: true);
    final userId = ref.read(sessionProvider).userId;
    if (userId != null) await _storage.write(StorageKeys.pairingOnboarded(userId), '1');
  }
}

final onboardingProvider = NotifierProvider<OnboardingController, Onboarding>(OnboardingController.new);
