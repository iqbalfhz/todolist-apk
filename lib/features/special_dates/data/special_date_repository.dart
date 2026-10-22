import '../../../core/database/entity_type.dart';
import '../../../core/database/local_writer.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/ulid.dart';
import '../../../core/utils/validators.dart';
import '../domain/special_date.dart';

/// Tanggal penting (v0.2): dibaca dari cache lokal, ditulis lewat antrean.
///
/// Kedua anggota Ruang Bersama boleh mengubah dan menghapus tanggal siapa pun.
/// Ruangnya hanya dipilih saat dibuat.
class SpecialDateRepository {
  SpecialDateRepository({required this.writer, required this.userId});

  final LocalWriter writer;
  final String userId;

  Stream<List<SpecialDate>> watchAll() => writer.store.watchSpecialDates();

  /// [date] berformat `YYYY-MM-DD`, atau `--MM-DD` kalau tahunnya tidak diketahui.
  Future<SpecialDate> create({
    required String spaceId,
    required SpecialDateType type,
    required String title,
    required String date,
  }) async {
    final nowIso = writer.nowIso();

    final payload = <String, dynamic>{
      'space_id': spaceId,
      'type': type.name,
      'title': _requireTitle(title),
      'date': _requireDate(date),
    };

    final row = <String, dynamic>{
      ...payload,
      'id': newUlid(now: writer.now()),
      'created_by': userId,
      'created_at': nowIso,
      'updated_at': nowIso,
      'deleted_at': null,
    };

    await writer.create(EntityType.specialDate, row, payload);
    return SpecialDate.fromJson(row);
  }

  /// Hanya kolom yang berubah yang dikirim.
  Future<void> edit(String id, {required SpecialDateType type, required String title, required String date}) =>
      writer.update(EntityType.specialDate, id, {
        'type': type.name,
        'title': _requireTitle(title),
        'date': _requireDate(date),
      });

  Future<void> delete(String id) => writer.delete(EntityType.specialDate, id);

  // ---------------------------------------------------------------- validasi

  static String _requireTitle(String title) {
    final clean = title.trim();
    if (!isValidRequiredText(clean, Limits.specialDateTitle)) {
      throw ArgumentError.value(
        title,
        'title',
        'Nama tanggal wajib diisi, paling banyak ${Limits.specialDateTitle} karakter.',
      );
    }
    return clean;
  }

  static String _requireDate(String date) {
    final parsed = AnnualDate.tryParse(date);
    if (parsed == null) throw ArgumentError.value(date, 'date', 'Tanggal harus YYYY-MM-DD atau --MM-DD.');
    return parsed.toContract();
  }
}
