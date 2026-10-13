import 'dart:async';

import 'package:todolist/core/notifications/push_service.dart';

/// Layanan notifikasi palsu: izin, token, dan pesan dikendalikan dari tes.
class FakePushService implements PushService {
  FakePushService({this.granted = false, this.grantOnRequest = true, this.fcmToken, this.opened});

  bool granted;

  /// Jawaban pengguna di dialog izin Android.
  bool grantOnRequest;

  String? fcmToken;

  /// Notifikasi yang diketuk untuk membuka app dari keadaan tertutup.
  PushMessage? opened;

  int permissionRequests = 0;
  int settingsOpened = 0;
  bool tokenDeleted = false;

  /// Notifikasi lokal yang ditampilkan, urut waktu.
  final List<PushMessage> shown = [];

  final StreamController<PushMessage> _taps = StreamController.broadcast();
  final StreamController<PushMessage> _foreground = StreamController.broadcast();
  final StreamController<String> _tokens = StreamController.broadcast();

  /// Pengguna mengetuk notifikasi selagi app berjalan.
  void tap(PushMessage message) => _taps.add(message);

  /// Push masuk saat app sedang terbuka.
  void receive(PushMessage message) => _foreground.add(message);

  /// FCM mengganti token HP ini.
  void refreshToken(String token) => _tokens.add(token);

  @override
  Future<void> init() async {}

  @override
  Future<bool> hasPermission() async => granted;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return granted = grantOnRequest;
  }

  @override
  Future<bool> openSystemSettings() async {
    settingsOpened++;
    return true;
  }

  @override
  Future<String?> token() async => fcmToken;

  @override
  Stream<String> get tokenRefreshes => _tokens.stream;

  @override
  Stream<PushMessage> get foregroundMessages => _foreground.stream;

  @override
  Stream<PushMessage> get taps => _taps.stream;

  @override
  Future<PushMessage?> initialTap() async => opened;

  @override
  Future<void> show(PushMessage message) async => shown.add(message);

  @override
  Future<void> deleteToken() async => tokenDeleted = true;
}
