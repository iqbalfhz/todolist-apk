import '../../../core/database/entity_type.dart';
import '../../../core/database/local_writer.dart';
import '../../../core/utils/ulid.dart';
import '../../../core/utils/validators.dart';
import '../domain/savings_entry.dart';
import '../domain/savings_goal.dart';

/// Target tabungan dan setorannya: dibaca dari cache lokal, ditulis lewat antrean.
///
/// Progres dihitung di HP dari daftar setoran; server menghitung total hanya
/// untuk menandai target tercapai dan mengirim notifikasi.
class SavingsRepository {
  SavingsRepository({required this.writer, required this.userId});

  final LocalWriter writer;
  final String userId;

  Stream<List<SavingsGoal>> watchGoals() => writer.store.watchGoals();

  Stream<List<SavingsEntry>> watchEntries() => writer.store.watchEntries();

  // ---------------------------------------------------------------- target

  /// Mata uang hanya bisa dipilih di sini, saat target dibuat.
  Future<SavingsGoal> createGoal({
    required String spaceId,
    required String name,
    String? emoji,
    required int targetAmount,
    required String currency,
    String? targetDate,
  }) async {
    final nowIso = writer.nowIso();

    final payload = <String, dynamic>{
      'space_id': spaceId,
      'name': _requireName(name),
      'emoji': _cleanEmoji(emoji),
      'target_amount': _requireAmount(targetAmount),
      'currency': currency,
      'target_date': targetDate,
    };

    final row = <String, dynamic>{
      ...payload,
      'id': newUlid(now: writer.now()),
      'achieved_at': null,
      'archived_at': null,
      'created_by': userId,
      'created_at': nowIso,
      'updated_at': nowIso,
      'deleted_at': null,
    };

    await writer.create(EntityType.goal, row, payload);
    return SavingsGoal.fromJson(row);
  }

  Future<void> editGoal(
    String id, {
    required String name,
    required String? emoji,
    required int targetAmount,
    required String? targetDate,
  }) => writer.update(EntityType.goal, id, {
    'name': _requireName(name),
    'emoji': _cleanEmoji(emoji),
    'target_amount': _requireAmount(targetAmount),
    'target_date': targetDate,
  });

  /// Jadwal pengingat setor (v0.2); `null` mematikannya. Frekuensi dan harinya selalu
  /// dikirim bersama, karena server mengecek keduanya berpasangan.
  Future<void> setReminder(String id, SavingsReminder? reminder) => writer.update(EntityType.goal, id, {
    'reminder_frequency': reminder?.frequency.name,
    'reminder_day': reminder?.day,
  }, sendTogether: true);

  Future<void> archiveGoal(String id) => writer.update(EntityType.goal, id, {'archived_at': writer.nowIso()});

  Future<void> unarchiveGoal(String id) => writer.update(EntityType.goal, id, {'archived_at': null});

  /// Hapus target beserta setorannya.
  Future<void> deleteGoal(String id) => writer.delete(EntityType.goal, id);

  // ---------------------------------------------------------------- setoran

  /// Catat setoran, atau penarikan kalau [withdrawal] (v1.x). [entryDate] adalah tanggal setor
  /// menurut HP. `type` hanya dikirim untuk penarikan; tanpa itu server menganggapnya setoran.
  /// Penarikan yang melebihi saldo dicegah layarnya, bukan di sini: server juga menerimanya.
  Future<SavingsEntry> createEntry({
    required SavingsGoal goal,
    required int amount,
    required String entryDate,
    String? note,
    bool withdrawal = false,
  }) async {
    final nowIso = writer.nowIso();

    final payload = <String, dynamic>{
      'savings_goal_id': goal.id,
      'amount': _requireAmount(amount),
      'entry_date': entryDate,
      'note': _cleanNote(note),
      if (withdrawal) 'type': EntryType.withdrawal,
    };

    final row = <String, dynamic>{
      ...payload,
      'id': newUlid(now: writer.now()),
      'space_id': goal.spaceId,
      'user_id': userId,
      'type': withdrawal ? EntryType.withdrawal : EntryType.deposit,
      'created_at': nowIso,
      'updated_at': nowIso,
      'deleted_at': null,
    };

    await writer.create(EntityType.entry, row, payload);
    return SavingsEntry.fromJson(row);
  }

  /// Kedua anggota boleh mengubah setoran siapa pun. `type` tidak bisa diubah (PATCH
  /// mengabaikannya), jadi setoran tetap setoran dan penarikan tetap penarikan.
  Future<void> editEntry(String id, {required int amount, required String entryDate, required String? note}) =>
      writer.update(EntityType.entry, id, {
        'amount': _requireAmount(amount),
        'entry_date': entryDate,
        'note': _cleanNote(note),
      });

  Future<void> deleteEntry(String id) => writer.delete(EntityType.entry, id);

  // ---------------------------------------------------------------- validasi

  static String _requireName(String name) {
    final cleanName = name.trim();
    if (!isValidRequiredText(cleanName, Limits.name)) {
      throw ArgumentError.value(name, 'name', 'Nama wajib diisi, paling banyak ${Limits.name} karakter.');
    }
    return cleanName;
  }

  static int _requireAmount(int amount) {
    if (!isValidAmount(amount)) throw ArgumentError.value(amount, 'amount', 'Nominal harus lebih dari 0.');
    return amount;
  }

  static String? _cleanEmoji(String? emoji) {
    final value = nullIfBlank(emoji);
    return value != null && isSingleEmoji(value) ? value : null;
  }

  static String? _cleanNote(String? note) {
    final value = nullIfBlank(note);
    if (value != null && textLength(value) > Limits.entryNote) {
      throw ArgumentError.value(note, 'note', 'Catatan paling banyak ${Limits.entryNote} karakter.');
    }
    return value;
  }
}
