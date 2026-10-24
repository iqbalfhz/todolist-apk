import '../api/api_transport.dart';
import '../database/app_database.dart';
import '../database/entity_type.dart';

/// Berkas yang ikut dikirim operasi `POST` (foto kenangan), dan nasibnya setelah server membalas.
///
/// Antrean tidak tahu cara menyimpan berkas di HP; di tes, antarmuka ini diganti
/// dengan berkas di folder sementara.
abstract interface class UploadFiles {
  /// Berkas untuk operasi [op], atau `null` kalau sudah tidak ada di HP.
  Future<ApiUpload?> fileFor(OutboxRow op);

  /// Server sudah menyimpan berkas operasi [op]; [data] adalah sumber yang dibalasnya.
  Future<void> uploaded(OutboxRow op, Map<String, dynamic> data);

  /// Data [type] dengan ID [id] dibuang dari HP, jadi berkasnya tidak dibutuhkan lagi.
  Future<void> discard(EntityType type, String id);
}
