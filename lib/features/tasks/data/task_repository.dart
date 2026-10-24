import 'dart:convert';

import '../../../core/database/entity_type.dart';
import '../../../core/database/local_writer.dart';
import '../../../core/utils/ulid.dart';
import '../../../core/utils/validators.dart';
import '../domain/task.dart';
import '../domain/task_list.dart';

/// Tugas: dibaca dari cache lokal, ditulis lewat antrean.
class TaskRepository {
  TaskRepository({required this.writer, required this.userId});

  final LocalWriter writer;
  final String userId;

  Stream<List<Task>> watchAll() => writer.store.watchTasks();

  /// Buat tugas di [list]. Tugas langsung tampil sebelum server membalas.
  ///
  /// [repeat] (v1.0) butuh [dueDate] sebagai patokan, dan tidak boleh di checklist perjalanan.
  Future<Task> create({
    required TaskList list,
    required String title,
    String? dueDate,
    String? dueTime,
    List<String>? assigneeIds,
    bool important = false,
    TaskRepeat? repeat,
  }) async {
    final cleanTitle = title.trim();
    if (!isValidRequiredText(cleanTitle, Limits.taskTitle)) {
      throw ArgumentError.value(title, 'title', 'Judul wajib diisi, paling banyak ${Limits.taskTitle} karakter.');
    }
    if (repeat != null) _checkRepeat(repeat, dueDate: dueDate, checklist: list.isChecklist);

    final id = newUlid(now: writer.now());
    final nowIso = writer.nowIso();
    // Server mengembalikan penanggung jawab terurut; disamakan supaya tidak berubah saat dibalas.
    final assignees = [
      ...(assigneeIds == null || assigneeIds.isEmpty ? [userId] : assigneeIds),
    ]..sort();

    final payload = <String, dynamic>{
      'task_list_id': list.id,
      'title': cleanTitle,
      'notes': null,
      'due_date': dueDate,
      // Jam butuh tanggal.
      'due_time': dueDate == null ? null : dueTime,
      'priority': important ? priorityImportant : priorityNone,
      'position': await writer.nextPosition(EntityType.task, parentId: list.id),
      'assignee_ids': assignees,
      'repeat_frequency': repeat?.frequency.name,
      'repeat_interval': repeat?.interval,
    };

    final row = <String, dynamic>{
      ...payload,
      'id': id,
      'space_id': list.spaceId,
      'remind_at': null,
      'completed_at': null,
      'completed_by': null,
      'next_task_id': null,
      'created_by': userId,
      'updated_by': userId,
      'created_at': nowIso,
      'updated_at': nowIso,
      'deleted_at': null,
    };

    await writer.create(EntityType.task, row, payload);
    return Task.fromJson(row);
  }

  Future<void> rename(String id, String title) async {
    final cleanTitle = title.trim();
    // Judul wajib: isian kosong atau terlalu panjang tidak disimpan.
    if (!isValidRequiredText(cleanTitle, Limits.taskTitle)) return;
    await writer.update(EntityType.task, id, {'title': cleanTitle});
  }

  Future<void> setNotes(String id, String notes) async {
    if (!isValidOptionalText(notes, Limits.taskNotes)) return;
    await writer.update(EntityType.task, id, {'notes': nullIfBlank(notes)});
  }

  /// Tenggat. Tanggal dan jam selalu dikirim bersama; mengosongkan tanggal ikut mengosongkan jam
  /// dan aturan ulang, sama seperti yang dilakukan server.
  Future<void> setDue(String id, {required String? date, required String? time}) => writer.update(EntityType.task, id, {
    'due_date': date,
    'due_time': date == null ? null : time,
    if (date == null) ...{'repeat_frequency': null, 'repeat_interval': null},
  }, sendTogether: true);

  /// Aturan ulang (v1.0); `null` menghentikan pengulangan. Frekuensi dan selangnya selalu
  /// dikirim berdua. Tugas berulang butuh tenggat, dan item checklist perjalanan tidak bisa berulang.
  Future<void> setRepeat(String id, TaskRepeat? repeat) async {
    if (repeat != null) {
      final task = await writer.store.read(EntityType.task, id);
      if (task == null) return;
      final list = await writer.store.read(EntityType.list, task['task_list_id'] as String);
      _checkRepeat(repeat, dueDate: task['due_date'] as String?, checklist: list?['trip_id'] != null);
    }

    await writer.update(EntityType.task, id, {
      'repeat_frequency': repeat?.frequency.name,
      'repeat_interval': repeat?.interval,
    }, sendTogether: true);
  }

  /// Aturan yang sama dengan server, supaya 422 dari antrean tidak terjadi.
  static void _checkRepeat(TaskRepeat repeat, {required String? dueDate, required bool checklist}) {
    if (dueDate == null) throw ArgumentError.value(repeat, 'repeat', 'Tugas berulang butuh tanggal.');
    if (checklist) throw ArgumentError.value(repeat, 'repeat', 'Checklist perjalanan tidak bisa berulang.');
    if (repeat.interval < 1 || repeat.interval > Limits.repeatInterval) {
      throw ArgumentError.value(repeat, 'repeat', 'Selang ulang 1–${Limits.repeatInterval}.');
    }
  }

  Future<void> setImportant(String id, bool important) =>
      writer.update(EntityType.task, id, {'priority': important ? priorityImportant : priorityNone});

  /// Satu ID berarti satu orang, dua ID berarti "Kita".
  Future<void> setAssignees(String id, List<String> assigneeIds) {
    assert(assigneeIds.isNotEmpty && assigneeIds.length <= 2);
    return writer.update(EntityType.task, id, {
      'assignee_ids': [...assigneeIds]..sort(),
    });
  }

  /// Pindah daftar; hanya ke daftar di ruang yang sama.
  Future<void> moveToList(String id, TaskList list) => writer.update(EntityType.task, id, {'task_list_id': list.id});

  /// Tandai selesai. Operasinya menunggu 5 detik selama tombol Urungkan tampil.
  /// Mengembalikan ID operasi untuk [undo].
  Future<int?> complete(String id) {
    final nowIso = writer.nowIso();
    return writer.updateUndoable(EntityType.task, id, {'completed_at': nowIso}, localOnly: {'completed_by': userId});
  }

  /// Batalkan selesai. Kalau penyelesaiannya belum terkirim, cukup diurungkan.
  Future<void> uncomplete(String id) async {
    final held = await writer.outbox.heldOpFor(EntityType.task, id);
    if (held != null && held.method == 'PATCH') {
      final payload = jsonDecode(held.payload ?? '{}') as Map<String, dynamic>;
      if (payload['completed_at'] != null && await writer.outbox.undo(held.id)) return;
    }

    await writer.update(EntityType.task, id, {'completed_at': null}, localOnly: {'completed_by': null});
  }

  /// Hapus tugas. Operasinya menunggu 5 detik selama tombol Urungkan tampil.
  /// Mengembalikan ID operasi untuk [undo].
  Future<int?> delete(String id) => writer.delete(EntityType.task, id, undoable: true);

  /// Urungkan selesai atau hapus. `false` kalau operasinya sudah terlanjur dikirim.
  Future<bool> undo(int opId) => writer.outbox.undo(opId);
}
