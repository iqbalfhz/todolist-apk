import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/api/api_error.dart';
import 'core/database/entity_type.dart';
import 'core/database/local_store.dart';
import 'core/l10n/l10n.dart';
import 'core/notifications/push_service.dart';
import 'core/providers.dart';
import 'core/queue/outbox.dart';
import 'core/router/app_router.dart';
import 'core/router/routes.dart';
import 'core/session/account.dart';
import 'core/session/session.dart';
import 'core/session/token_revocations.dart';

/// Menghubungkan akun yang sedang masuk dengan siklus hidup app.
///
/// Pemicu sync: app dibuka atau kembali aktif, dan push yang masuk saat app terbuka
/// (tarik untuk menyegarkan ditangani tiap layar). Di sini juga pesan dari antrean
/// ditampilkan, HP didaftarkan untuk push, dan notifikasi yang diketuk dibuka.
class AppServices extends ConsumerStatefulWidget {
  const AppServices({super.key, required this.messengerKey, required this.child});

  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final Widget child;

  @override
  ConsumerState<AppServices> createState() => _AppServicesState();
}

class _AppServicesState extends ConsumerState<AppServices> with WidgetsBindingObserver {
  /// Batas menunggu sync sebelum membuka layar dari notifikasi yang diketuk.
  static const Duration _tapSyncLimit = Duration(seconds: 3);

  final List<StreamSubscription<Object?>> _pushSubscriptions = [];
  StreamSubscription<OutboxEvent>? _outboxSubscription;
  StreamSubscription<void>? _pulledSubscription;
  bool _prefetching = false;
  bool _revoking = false;
  Account? _account;

  AppLocalizations get _l10n => lookupAppLocalizations(const Locale('id'));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final push = ref.read(pushServiceProvider);
    _pushSubscriptions
      ..add(push.foregroundMessages.listen(_onForegroundMessage))
      ..add(push.tokenRefreshes.listen((token) => _registerDevice(_account, token)))
      ..add(push.taps.listen(_openFromPush));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _attach(ref.read(accountProvider));
      unawaited(_revokeLeftoverTokens());

      final opened = await push.initialTap();
      if (opened != null) await _openFromPush(opened);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final subscription in _pushSubscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_outboxSubscription?.cancel());
    unawaited(_pulledSubscription?.cancel());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App kembali aktif: kirim antrean sekarang juga, lalu tarik perubahan.
    if (state == AppLifecycleState.resumed) {
      _account?.sync.sync(retryNow: true).ignore();
      unawaited(_revokeLeftoverTokens());
    }
  }

  /// Akun berganti (masuk, keluar, atau akun lain): pindahkan pendengar dan mulai dari awal.
  void _attach(Account? account) {
    if (identical(account, _account)) return;

    unawaited(_outboxSubscription?.cancel());
    unawaited(_pulledSubscription?.cancel());
    _outboxSubscription = null;
    _pulledSubscription = null;
    _account = account;
    if (account == null) return;

    _outboxSubscription = account.outbox.events.listen(_onOutboxEvent);
    _pulledSubscription = account.sync.pulled.listen((_) => unawaited(_prefetchThumbs(account)));

    account.sync.sync().ignore();
    unawaited(_refreshSignedUrls(account));
    unawaited(_registerDevice(account, null));
  }

  /// `avatar_url` hanya berlaku 7 hari, jadi diambil ulang setiap app dibuka dari awal.
  Future<void> _refreshSignedUrls(Account account) async {
    try {
      await account.profile.refresh();
      await account.spaces.refresh();
    } on NetworkFailure {
      // Offline; foto yang sudah ada di cache tetap tampil.
    } on ApiError {
      // 401 ditangani lewat sesi.
    } on Object {
      // Akun keluar di tengah jalan.
    }
  }

  /// Unduh thumbnail foto kenangan yang belum ada di HP tepat setelah sync, supaya linimasa
  /// dan galeri tetap tampil saat offline (kontrak, bagian URL foto).
  Future<void> _prefetchThumbs(Account account) async {
    if (_prefetching) return;
    _prefetching = true;
    try {
      final photos = await account.memories.watchPhotos().first;
      await account.photoImages.prefetchThumbs(photos);
    } on Object {
      // Offline atau akun keluar di tengah jalan; dicoba lagi setelah sync berikutnya.
    } finally {
      _prefetching = false;
    }
  }

  /// Cabut token lama yang tersisa dari keluar saat offline.
  Future<void> _revokeLeftoverTokens() async {
    if (_revoking) return;
    _revoking = true;
    try {
      await TokenRevocations(ref.read(keyValueStoreProvider)).revokeAll(ref.read(revocationTransportProvider));
    } on Object {
      // Dicoba lagi saat app dibuka atau kembali aktif.
    } finally {
      _revoking = false;
    }
  }

  /// Daftarkan token FCM HP ini. Dikirim ulang setiap FCM memberi token baru.
  Future<void> _registerDevice(Account? account, String? refreshedToken) async {
    if (account == null) return;

    try {
      final token = refreshedToken ?? await ref.read(pushServiceProvider).token();
      if (token == null) return;

      await ref.read(apiTransportProvider).send('POST', '/devices', body: {'token': token, 'platform': 'android'});
      await account.store.setMeta(MetaKeys.deviceToken, token);
    } on NetworkFailure {
      // Dicoba lagi saat app dibuka berikutnya.
    } on ApiError {
      // 401 ditangani lewat sesi.
    } on Object {
      // Akun keluar di tengah jalan.
    }
  }

  void _onForegroundMessage(PushMessage message) {
    _account?.sync.sync().ignore();
    unawaited(ref.read(pushServiceProvider).show(message));
  }

  void _onOutboxEvent(OutboxEvent event) {
    switch (event) {
      case OutboxRejected(:final message):
        _show(message);
      case OutboxTaskRelocated(:final listName):
        _show(_l10n.outboxRelocated(listName));
      case OutboxNeedsSync():
        _account?.sync.sync().ignore();
      case OutboxNeedsAppUpdate():
        ref.read(connectivityProvider.notifier).flagAppUpdate();
    }
  }

  /// Notifikasi diketuk: sync paling lama 3 detik, lalu buka layar sesuai `type`.
  /// Kalau datanya belum ada, buka layar induknya dengan pesan singkat.
  Future<void> _openFromPush(PushMessage message) async {
    final account = _account ?? ref.read(accountProvider);
    if (account == null) return;

    await account.sync.sync().timeout(_tapSyncLimit, onTimeout: () => false);
    if (!mounted || !identical(account, ref.read(accountProvider))) return;

    final router = ref.read(routerProvider);
    final taskId = message.taskId;
    final goalId = message.goalId;
    final tripId = message.tripId;
    final memoryId = message.memoryId;

    // Lembar bawah atau dialog yang masih terbuka ditutup, supaya layar tujuan terlihat.
    router.routerDelegate.navigatorKey.currentState?.popUntil((route) => route is! PopupRoute);

    if (message.isAboutTask && taskId != null) {
      if (await _exists(account, EntityType.task, taskId)) return router.go(Routes.task(taskId));
      router.go(Routes.tasks);
      return _show(_l10n.notifTapMissingTask);
    }

    if (message.isAboutSavings && goalId != null) {
      if (await _exists(account, EntityType.goal, goalId)) return router.go(Routes.goal(goalId));
      router.go(Routes.savings);
      return _show(_l10n.notifTapMissingGoal);
    }

    if (message.isAboutTrip && tripId != null) {
      if (await _exists(account, EntityType.trip, tripId)) return router.go(Routes.trip(tripId));
      router.go(Routes.trips);
      return _show(_l10n.notifTapMissingTrip);
    }

    if (message.isAboutMemory && memoryId != null) {
      if (await _exists(account, EntityType.memory, memoryId)) return router.go(Routes.memory(memoryId));
      router.go(Routes.memories);
      return _show(_l10n.notifTapMissingMemory);
    }

    router.go(Routes.home);
  }

  Future<bool> _exists(Account account, EntityType type, String id) async {
    final row = await account.store.read(type, id);
    return row != null && row['deleted_at'] == null;
  }

  void _show(String message) {
    widget.messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen(accountProvider, (_, account) => _attach(account))
      ..listen(sessionProvider, (previous, next) {
        // Token tidak berlaku lagi: beri tahu, layar Masuk dibuka router.
        if (next.expired && (previous?.isSignedIn ?? false)) _show(_l10n.sessionExpired);
      });

    return widget.child;
  }
}
