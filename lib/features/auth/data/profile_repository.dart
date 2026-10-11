import 'dart:typed_data';

import '../../../core/api/api_transport.dart';
import '../../../core/database/entity_type.dart';
import '../../../core/database/local_writer.dart';
import '../../../core/sync/row_applier.dart';
import '../../../core/utils/validators.dart';
import '../domain/user.dart';

/// Profil sendiri. Disimpan di cache lokal supaya tampil saat offline;
/// `PATCH /me` lewat antrean, foto profil dipanggil langsung.
class ProfileRepository {
  ProfileRepository({required this.writer, required this.api, required this.applier, required this.userId});

  final LocalWriter writer;
  final ApiTransport api;
  final RowApplier applier;
  final String userId;

  Stream<User?> watch() => writer.store.watchProfile();

  Future<User?> current() => writer.store.profile();

  /// Simpan profil dari balasan daftar atau masuk.
  Future<void> save(User user) => applier.apply(EntityType.me, user.toJson());

  /// Ambil profil terbaru, termasuk kode undangan aktif dan URL foto yang baru.
  Future<User> refresh() async {
    final response = await api.send('GET', '/me');
    await applier.apply(EntityType.me, response.data);
    return User.fromJson(response.data);
  }

  /// Simpan beberapa kolom profil sekaligus; hanya yang berubah yang dikirim.
  /// [birthDate] boleh `null` untuk menghapus tanggal lahir.
  Future<void> update({String? name, String? color, String? defaultCurrency, Object? birthDate = _unset}) {
    if (name != null && !isValidRequiredText(name, Limits.name)) {
      throw ArgumentError.value(name, 'name', 'Nama wajib diisi, paling banyak ${Limits.name} karakter.');
    }

    final changes = <String, dynamic>{
      'name': ?name?.trim(),
      'color': ?color,
      'default_currency': ?defaultCurrency,
      if (!identical(birthDate, _unset)) 'birth_date': birthDate as String?,
    };
    return writer.update(EntityType.me, userId, changes);
  }

  /// Preferensi dikirim utuh, supaya dua perubahan yang digabung di antrean tidak saling menimpa.
  Future<void> updateNotificationPrefs(NotificationPrefs prefs) =>
      writer.update(EntityType.me, userId, {'notification_prefs': prefs.toJson()});

  /// Unggah foto profil yang sudah dipotong persegi dan dikecilkan ke 512 × 512 (JPEG).
  Future<User> uploadAvatar(Uint8List jpegBytes) async {
    final response = await api.send(
      'POST',
      '/me/avatar',
      upload: ApiUpload(field: 'photo', bytes: jpegBytes, filename: 'avatar.jpg', mimeType: 'image/jpeg'),
    );
    await applier.apply(EntityType.me, response.data);
    return User.fromJson(response.data);
  }

  /// Hapus foto profil; app kembali menampilkan inisial dengan warna diri.
  Future<void> deleteAvatar() async {
    await api.send('DELETE', '/me/avatar');
    await refresh();
  }
}

const Object _unset = Object();
