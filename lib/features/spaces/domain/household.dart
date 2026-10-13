import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../auth/domain/user.dart';
import 'space.dart';

/// Aku, pasangan, dan ruang-ruang kami, dirangkum dari cache lokal.
///
/// Data tentang diriku diambil dari profil (yang langsung berubah saat disunting),
/// sedangkan data pasangan diambil dari anggota Ruang Bersama.
class Household {
  const Household({required this.me, required this.spaces});

  final User me;
  final List<Space> spaces;

  /// Ruang Bersama, kalau sudah berpasangan. Di v0.1 paling banyak satu.
  Space? get shared => spaces.where((space) => space.isShared).firstOrNull;

  Space? get personal => spaces.where((space) => space.isPersonal).firstOrNull;

  bool get isPaired => shared != null;

  SpaceMember? get partner => shared?.members.where((member) => member.id != me.id).firstOrNull;

  Space? spaceOf(String spaceId) => spaces.where((space) => space.id == spaceId).firstOrNull;

  /// Zona waktu ruang; "hari ini" dihitung di zona ini.
  String timezoneOf(String spaceId) => spaceOf(spaceId)?.timezone ?? me.timezone;

  bool isShared(String spaceId) => spaceOf(spaceId)?.isShared ?? false;

  /// Kunci warna diri seseorang.
  String colorOf(String? userId) {
    if (userId == null || userId == me.id) return me.color;
    return partner?.id == userId ? partner!.color : me.color;
  }
}

/// `null` selama profil atau daftar ruang belum terbaca dari cache.
final householdProvider = Provider<Household?>((ref) {
  final me = ref.watch(profileProvider).value;
  final spaces = ref.watch(spacesProvider).value;
  if (me == null || spaces == null) return null;
  return Household(me: me, spaces: spaces);
});
