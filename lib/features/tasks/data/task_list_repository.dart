import '../../../core/database/entity_type.dart';
import '../../../core/database/local_writer.dart';
import '../../../core/utils/ulid.dart';
import '../../../core/utils/validators.dart';
import '../domain/task_list.dart';

/// Setiap ruang harus punya minimal satu daftar aktif (409 `last_list` di server).
class LastActiveListException implements Exception {
  const LastActiveListException();
}

/// Daftar tugas: dibaca dari cache lokal, ditulis lewat antrean.
class TaskListRepository {
  TaskListRepository({required this.writer, required this.userId});

  final LocalWriter writer;
  final String userId;

  Stream<List<TaskList>> watchAll() => writer.store.watchTaskLists();

  Future<TaskList> create({
    required String spaceId,
    required String name,
    String? emoji,
    String color = 'mawar',
  }) async {
    final cleanName = _requireName(name);
    final nowIso = writer.nowIso();

    final payload = <String, dynamic>{
      'space_id': spaceId,
      'name': cleanName,
      'emoji': _cleanEmoji(emoji),
      'color': color,
      'position': await writer.nextPosition(EntityType.list, parentId: spaceId),
    };

    final row = <String, dynamic>{
      ...payload,
      'id': newUlid(now: writer.now()),
      'archived_at': null,
      'created_by': userId,
      'created_at': nowIso,
      'updated_at': nowIso,
      'deleted_at': null,
    };

    await writer.create(EntityType.list, row, payload);
    return TaskList.fromJson(row);
  }

  Future<void> edit(String id, {required String name, required String? emoji, required String color}) =>
      writer.update(EntityType.list, id, {'name': _requireName(name), 'emoji': _cleanEmoji(emoji), 'color': color});

  /// Pindahkan daftar ke antara dua tetangganya; `null` berarti di ujung.
  Future<void> reorder(String id, {double? after, double? before}) {
    final double position;
    if (after != null && before != null) {
      position = (after + before) / 2;
    } else if (after != null) {
      position = after + positionStep;
    } else if (before != null) {
      position = before - positionStep;
    } else {
      return Future.value();
    }
    return writer.update(EntityType.list, id, {'position': position});
  }

  /// Arsipkan. Tugas di dalamnya tidak tampil di tampilan mana pun sampai dikeluarkan dari arsip.
  Future<void> archive(String id) async {
    await _ensureNotLastActive(id);
    await writer.update(EntityType.list, id, {'archived_at': writer.nowIso()});
  }

  Future<void> unarchive(String id) => writer.update(EntityType.list, id, {'archived_at': null});

  /// Hapus daftar beserta tugasnya.
  Future<void> delete(String id) async {
    await _ensureNotLastActive(id);
    await writer.delete(EntityType.list, id);
  }

  Future<void> _ensureNotLastActive(String id) async {
    final lists = await writer.store.taskLists();
    final target = lists.where((list) => list.id == id).firstOrNull;
    if (target == null || !target.isActive) return;

    final anotherIsActive = lists.any((list) => list.spaceId == target.spaceId && list.id != id && list.isActive);
    if (!anotherIsActive) throw const LastActiveListException();
  }

  static String _requireName(String name) {
    final cleanName = name.trim();
    if (!isValidRequiredText(cleanName, Limits.name)) {
      throw ArgumentError.value(name, 'name', 'Nama wajib diisi, paling banyak ${Limits.name} karakter.');
    }
    return cleanName;
  }

  static String? _cleanEmoji(String? emoji) {
    final value = nullIfBlank(emoji);
    return value != null && isSingleEmoji(value) ? value : null;
  }
}
