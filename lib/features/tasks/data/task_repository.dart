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
  Future<Task> create({
    required TaskList list,
    required String title,
    String? dueDate,
    String? dueTime,
    List<String>? assigneeIds,
    bool important = false,
  }) async {
    final cleanTitle = title.trim();
    if (!isValidRequiredText(cleanTitle, Limits.taskTitle)) {
      throw ArgumentError.value(title, 'title', 'Judul wajib diisi, paling banyak ${Limits.taskTitle} karakter.');
    }

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
    };

    final row = <String, dynamic>{
      ...payload,
      'id': id,
      'space_id': list.spaceId,
      'remind_at': null,
      'completed_at': null,
      'completed_by': null,
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

  /// Tenggat. Tanggal dan jam selalu dikirim bersama; mengosongkan tanggal ikut mengosongkan jam.
  Future<void> setDue(String id, {required String? date, required String? time}) => writer.update(EntityType.task, id, {
    'due_date': date,
    'due_time': date == null ? null : time,
  }, sendTogether: true);

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
