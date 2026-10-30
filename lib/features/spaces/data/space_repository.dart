import '../../../core/api/api_transport.dart';
import '../../../core/database/entity_type.dart';
import '../../../core/database/local_store.dart';
import '../../../core/queue/outbox.dart';
import '../../../core/sync/row_applier.dart';
import '../../../core/utils/validators.dart';
import '../../auth/domain/user.dart';
import '../domain/space.dart';

/// Ruang dan undangan. Endpoint undangan dan keluar dari Ruang Bersama tidak lewat antrean dan
/// butuh koneksi.
class SpaceRepository {
  SpaceRepository({required this.store, required this.api, required this.applier, required this.outbox});

  final LocalStore store;
  final ApiTransport api;
  final RowApplier applier;
  final Outbox outbox;

  Stream<List<Space>> watchAll() => store.watchSpaces();

  /// Ambil semua ruang beserta profil anggotanya.
  ///
  /// `avatar_url` adalah URL bertanda tangan yang berlaku 7 hari, jadi ini dipanggil
  /// setiap app dibuka dari awal dan saat penyimpanan foto membalas 403.
  Future<void> refresh() async {
    final response = await api.send('GET', '/spaces');
    await store.transaction(() async {
      final pending = await applier.loadPending();
      for (final space in response.dataList) {
        await applier.apply(EntityType.space, space, pending: pending);
      }
    });
  }

  /// Ambil kode undangan aktif, atau buat yang baru. [renew] mencabut kode lama.
  Future<Invitation> invitation({bool renew = false}) async {
    final response = await api.send('POST', '/invitations', body: renew ? {'renew': true} : null);
    final invitation = Invitation.fromJson(response.data);
    await store.patch(EntityType.me, '', {'invitation': invitation.toJson()});
    return invitation;
  }

  /// Pakai kode pasangan. Ruang Bersama dibuat untuk berdua; setelah ini pemanggil menjalankan sync.
  Future<Space> accept(String code) async {
    final response = await api.send('POST', '/invitations/accept', body: {'code': normalizeInvitationCode(code)});
    await applier.apply(EntityType.space, response.data);
    // Kode sendiri ikut dicabut server begitu Ruang Bersama terbentuk.
    await store.patch(EntityType.me, '', {'invitation': null});
    return Space.fromJson(response.data);
  }

  /// Keluar dari Ruang Bersama (v1.0): ruang ditutup untuk berdua, dan isinya disimpan server
  /// 30 hari kalau kalian bergabung lagi.
  ///
  /// Antrean dikirim dulu, supaya perubahan terakhir ikut tersimpan. Setelah 204, ruang dan
  /// isinya dihapus dari cache dan operasi yang tersisa untuk ruang itu dibuang. Error dari
  /// server atau jaringan dilempar tanpa mengubah apa pun di HP.
  Future<void> leave(String spaceId) async {
    await outbox.flush(retryNow: true);
    await api.send('DELETE', '/spaces/$spaceId');
    await outbox.forgetSpace(spaceId);
  }
}
