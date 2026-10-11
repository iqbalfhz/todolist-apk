import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/api/api_error.dart';
import '../../../core/providers.dart';
import '../../../core/session/account.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/domain/user.dart';
import '../domain/space.dart';

/// Kunci cache gambar: URL bertanda tangan berganti tiap 7 hari, fotonya tidak.
String avatarCacheKey(String userId, int version) => 'avatar-$userId-$version';

DateTime? _lastAvatarRefresh;

/// Ambil URL foto yang baru saat penyimpanan foto menolak URL lama (403).
/// Dibatasi sekali per menit supaya foto yang memang rusak tidak memicu permintaan beruntun.
void refreshAvatarUrls(Account? account) {
  final now = DateTime.now();
  final last = _lastAvatarRefresh;
  if (account == null || (last != null && now.difference(last) < const Duration(minutes: 1))) return;
  _lastAvatarRefresh = now;

  unawaited(() async {
    try {
      await account.spaces.refresh();
      await account.profile.refresh();
    } on NetworkFailure {
      // Dicoba lagi saat app dibuka dari awal berikutnya.
    } on ApiError {
      // Sesi berakhir ditangani di tempat lain.
    }
  }());
}

/// Avatar diri sendiri, dari profil lokal (langsung berubah saat nama atau warna disunting).
class MyAvatar extends ConsumerWidget {
  const MyAvatar({super.key, required this.user, required this.size, this.filled = false});

  final User user;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PersonAvatar(
    name: user.name,
    colorKey: user.color,
    size: size,
    filled: filled,
    avatarUrl: user.avatarUrl,
    cacheKey: avatarCacheKey(user.id, user.avatarVersion),
    onImageError: () => refreshAvatarUrls(ref.read(accountProvider)),
  );
}

/// Avatar anggota ruang (pasangan).
class MemberAvatar extends ConsumerWidget {
  const MemberAvatar({super.key, required this.member, required this.size, this.filled = false});

  final SpaceMember member;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PersonAvatar(
    name: member.name,
    colorKey: member.color,
    size: size,
    filled: filled,
    avatarUrl: member.avatarUrl,
    cacheKey: avatarCacheKey(member.id, member.avatarVersion),
    onImageError: () => refreshAvatarUrls(ref.read(accountProvider)),
  );
}
