import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../firebase_options.dart';

/// Channel Android, dibuat saat app pertama dibuka. Keduanya bisa dimatikan
/// terpisah dari pengaturan Android.
abstract final class PushChannels {
  /// Penting dan bersuara: pengingat tenggat dan tanggal penting.
  static const String reminders = 'pengingat';

  /// Normal: titipan, tugas selesai, setoran, dan pasangan bergabung.
  static const String activity = 'aktivitas';
}

/// Pesan push dari server. Semua nilai `data` berupa teks, sesuai aturan FCM.
class PushMessage {
  const PushMessage({this.title, this.body, required this.data});

  final String? title;
  final String? body;

  /// `type` dan `space_id`, ditambah `task_id`, `savings_goal_id`, `special_date_id`, atau `member_id`.
  final Map<String, String> data;

  String get type => data['type'] ?? '';

  String? get taskId => data['task_id'];

  String? get goalId => data['savings_goal_id'];

  /// Tanggal penting yang diingatkan `special_date_reminder` (v0.2).
  String? get specialDateId => _filled(data['special_date_id']);

  /// Anggota yang berulang tahun, untuk `special_date_reminder` (v0.2).
  String? get memberId => _filled(data['member_id']);

  bool get isAboutTask => type.startsWith('task_');

  bool get isAboutSavings => type.startsWith('savings_');

  String get channel =>
      type == 'task_reminder' || type == 'special_date_reminder' ? PushChannels.reminders : PushChannels.activity;

  /// Kunci yang membuat notifikasi untuk hal yang sama menimpa yang lama.
  String get tag {
    if (taskId != null) return 'task-$taskId';
    if (goalId != null) return 'goal-$goalId';
    if (specialDateId != null) return 'date-$specialDateId';
    if (memberId != null) return 'birthday-$memberId';
    return 'space-${data['space_id'] ?? ''}';
  }

  static String? _filled(String? value) => value == null || value.isEmpty ? null : value;

  /// ID angka notifikasi lokal, diturunkan dari [tag] (FNV-1a, 31 bit).
  int get localId {
    var hash = 0x811c9dc5;
    for (final unit in tag.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }

  String encode() => jsonEncode({'title': title, 'body': body, 'data': data});

  static PushMessage? tryDecode(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      return PushMessage(
        title: json['title'] as String?,
        body: json['body'] as String?,
        data: (json['data'] as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString())),
      );
    } on Object {
      return null;
    }
  }
}

/// Push notification (FCM) dan notifikasi lokal.
abstract interface class PushService {
  /// Buat channel dan siapkan Firebase. Tidak pernah melempar: kalau Firebase
  /// belum dikonfigurasi, push dinonaktifkan dan app tetap berjalan.
  Future<void> init();

  /// Apakah izin notifikasi sudah diberikan.
  Future<bool> hasPermission();

  /// Minta izin notifikasi (Android 13+).
  Future<bool> requestPermission();

  /// Buka pengaturan notifikasi app di sistem.
  Future<bool> openSystemSettings();

  /// Token FCM HP ini, atau `null` kalau push tidak tersedia.
  Future<String?> token();

  Stream<String> get tokenRefreshes;

  /// Pesan yang masuk saat app sedang terbuka.
  Stream<PushMessage> get foregroundMessages;

  /// Notifikasi yang diketuk selagi app berjalan.
  Stream<PushMessage> get taps;

  /// Notifikasi yang diketuk untuk membuka app dari keadaan tertutup.
  Future<PushMessage?> initialTap();

  /// Tampilkan notifikasi lokal untuk pesan yang masuk saat app terbuka.
  Future<void> show(PushMessage message);

  /// Hapus token FCM, supaya HP yang sudah keluar tidak menerima push.
  Future<void> deleteToken();
}

/// Tanpa push; dipakai di tes.
class NoPushService implements PushService {
  const NoPushService();

  @override
  Future<void> init() async {}

  @override
  Future<bool> hasPermission() async => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<bool> openSystemSettings() async => false;

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> get tokenRefreshes => const Stream.empty();

  @override
  Stream<PushMessage> get foregroundMessages => const Stream.empty();

  @override
  Stream<PushMessage> get taps => const Stream.empty();

  @override
  Future<PushMessage?> initialTap() async => null;

  @override
  Future<void> show(PushMessage message) async {}

  @override
  Future<void> deleteToken() async {}
}

/// [PushService] di atas firebase_messaging dan flutter_local_notifications.
class FirebasePushService implements PushService {
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  final StreamController<PushMessage> _taps = StreamController.broadcast();

  bool _firebaseReady = false;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<void> init() async {
    try {
      await _local.initialize(
        settings: const InitializationSettings(android: AndroidInitializationSettings('ic_stat_notify')),
        onDidReceiveNotificationResponse: (response) {
          final message = PushMessage.tryDecode(response.payload);
          if (message != null) _taps.add(message);
        },
      );

      await _android?.createNotificationChannel(
        const AndroidNotificationChannel(
          PushChannels.reminders,
          'Pengingat',
          description: 'Pengingat saat tenggat tugas tiba dan menjelang tanggal penting.',
          importance: Importance.high,
        ),
      );
      await _android?.createNotificationChannel(
        const AndroidNotificationChannel(
          PushChannels.activity,
          'Aktivitas',
          description: 'Titipan baru, tugas selesai, setoran tabungan, dan pasangan bergabung.',
        ),
      );
    } on Object catch (error) {
      debugPrint('Notifikasi lokal tidak tersedia: $error');
    }

    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      FirebaseMessaging.onMessageOpenedApp.listen((message) => _taps.add(_convert(message)));
      _firebaseReady = true;
    } on Object catch (error) {
      // Paling sering: flutterfire configure belum dijalankan.
      debugPrint('Push dinonaktifkan: $error');
    }
  }

  static PushMessage _convert(RemoteMessage message) => PushMessage(
    title: message.notification?.title,
    body: message.notification?.body,
    data: message.data.map((key, value) => MapEntry(key, value.toString())),
  );

  @override
  Future<bool> hasPermission() async {
    try {
      return await _android?.areNotificationsEnabled() ?? false;
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      return await _android?.requestNotificationsPermission() ?? false;
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> openSystemSettings() async {
    try {
      return await _android?.openAppNotificationSettings() ?? false;
    } on Object {
      return false;
    }
  }

  @override
  Future<String?> token() async {
    if (!_firebaseReady) return null;
    try {
      return await FirebaseMessaging.instance.getToken();
    } on Object catch (error) {
      debugPrint('Token FCM tidak tersedia: $error');
      return null;
    }
  }

  @override
  Stream<String> get tokenRefreshes =>
      _firebaseReady ? FirebaseMessaging.instance.onTokenRefresh : const Stream.empty();

  @override
  Stream<PushMessage> get foregroundMessages =>
      _firebaseReady ? FirebaseMessaging.onMessage.map(_convert) : const Stream.empty();

  @override
  Stream<PushMessage> get taps => _taps.stream;

  @override
  Future<PushMessage?> initialTap() async {
    try {
      if (_firebaseReady) {
        final opened = await FirebaseMessaging.instance.getInitialMessage();
        if (opened != null) return _convert(opened);
      }

      final launch = await _local.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        return PushMessage.tryDecode(launch!.notificationResponse?.payload);
      }
    } on Object catch (error) {
      debugPrint('Notifikasi pembuka app tidak terbaca: $error');
    }
    return null;
  }

  @override
  Future<void> show(PushMessage message) async {
    final reminder = message.channel == PushChannels.reminders;

    try {
      await _local.show(
        id: message.localId,
        title: message.title,
        body: message.body,
        payload: message.encode(),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            message.channel,
            reminder ? 'Pengingat' : 'Aktivitas',
            importance: reminder ? Importance.high : Importance.defaultImportance,
            priority: reminder ? Priority.high : Priority.defaultPriority,
            tag: message.tag,
            // Nominal tabungan tidak tampil di layar kunci.
            visibility: message.isAboutSavings ? NotificationVisibility.private : null,
          ),
        ),
      );
    } on Object catch (error) {
      debugPrint('Notifikasi lokal gagal ditampilkan: $error');
    }
  }

  @override
  Future<void> deleteToken() async {
    if (!_firebaseReady) return;
    try {
      await FirebaseMessaging.instance.deleteToken();
    } on Object catch (error) {
      debugPrint('Token FCM gagal dihapus: $error');
    }
  }
}

/// Ditimpa di `main()` dengan [FirebasePushService] yang sudah disiapkan.
final pushServiceProvider = Provider<PushService>((ref) => const NoPushService());
