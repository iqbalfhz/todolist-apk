import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/time/space_clock.dart';
import '../../spaces/domain/household.dart';
import '../../spaces/domain/space.dart';
import 'task.dart';
import 'task_list.dart';

/// Chip penanggung jawab: Semua, Aku, Pasangan.
enum PersonFilter { all, me, partner }

/// Segmen status di tab Tugas: Semua tugas, Belum selesai, Selesai.
enum StatusFilter { all, open, done }

/// Penanggung jawab tugas dari sudut pandang pengguna.
enum Assignee { me, partner, us }

/// Tugas beserta daftar, ruang, dan statusnya terhadap "hari ini" di zona waktu ruang.
class TaskItem {
  const TaskItem({
    required this.task,
    required this.list,
    required this.space,
    required this.today,
    required this.isOverdue,
    required this.completedOn,
  });

  final Task task;
  final TaskList list;
  final Space space;

  /// Tanggal hari ini (`YYYY-MM-DD`) di zona waktu ruang tugas ini.
  final String today;

  /// Belum selesai dan tenggatnya sudah lewat.
  final bool isOverdue;

  /// Tanggal tugas diselesaikan di zona waktu ruangnya, atau `null`.
  final String? completedOn;

  bool get isCompleted => task.isCompleted;

  bool get completedToday => completedOn == today;

  /// Termasuk "Tugas hari ini" di Beranda: tenggatnya hari ini atau sudah terlewat,
  /// dan belum selesai atau baru diselesaikan hari ini.
  bool get isForToday {
    final due = task.dueDate;
    if (due == null || due.compareTo(today) > 0) return false;
    return !isCompleted || completedToday;
  }

  /// Penanggung jawab menurut [meId]. Dua orang berarti "Kita".
  Assignee assigneeFor(String meId) {
    if (task.assigneeIds.length > 1) return Assignee.us;
    return task.assigneeIds.contains(meId) || task.assigneeIds.isEmpty ? Assignee.me : Assignee.partner;
  }

  bool matches(PersonFilter filter, {required String meId, required String? partnerId}) => switch (filter) {
    PersonFilter.all => true,
    PersonFilter.me => task.assigneeIds.contains(meId),
    PersonFilter.partner => partnerId != null && task.assigneeIds.contains(partnerId),
  };
}

/// Gabungkan tugas dengan daftar dan ruangnya.
///
/// Hanya tugas di daftar aktif yang lolos: tugas di daftar yang dihapus atau
/// diarsipkan tidak tampil di tampilan mana pun.
List<TaskItem> buildTaskItems({
  required List<Task> tasks,
  required List<TaskList> lists,
  required Household household,
  required SpaceClock clock,
}) {
  final listsById = {
    for (final list in lists)
      if (list.isActive) list.id: list,
  };
  final clocks = <String, ZonedNow>{};
  final items = <TaskItem>[];

  for (final task in tasks) {
    final list = listsById[task.taskListId];
    final space = household.spaceOf(list?.spaceId ?? '');
    if (list == null || space == null || task.deletedAt != null) continue;

    final now = clocks.putIfAbsent(space.timezone, () => clock.nowIn(space.timezone));
    final completedAt = task.completedAt;

    items.add(
      TaskItem(
        task: task,
        list: list,
        space: space,
        today: now.date,
        isOverdue: completedAt == null && _isPast(task, now),
        completedOn: completedAt == null ? null : clock.wallClock(completedAt, space.timezone).date,
      ),
    );
  }

  return items;
}

bool _isPast(Task task, ZonedNow now) {
  final due = task.dueDate;
  if (due == null) return false;

  final byDate = due.compareTo(now.date);
  if (byDate != 0) return byDate < 0;

  final time = task.dueTime;
  return time != null && time.compareTo(now.time) < 0;
}

/// Urutan "Tugas hari ini": yang terlewat paling lama dulu, lalu menurut jam,
/// dan yang sudah selesai di paling bawah.
int compareForToday(TaskItem a, TaskItem b) {
  if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
  if (a.isCompleted) return b.task.completedAt!.compareTo(a.task.completedAt!);

  final byDate = a.task.dueDate!.compareTo(b.task.dueDate!);
  if (byDate != 0) return byDate;

  // Tanpa jam berarti kapan saja hari itu, jadi ditaruh setelah yang berjam.
  final byTime = (a.task.dueTime ?? '99:99').compareTo(b.task.dueTime ?? '99:99');
  return byTime != 0 ? byTime : a.task.position.compareTo(b.task.position);
}

/// Daftar aktif dalam urutan tampil: Ruang Bersama dulu, lalu menurut `position`.
List<TaskList> orderLists(List<TaskList> lists, Household household) {
  final active = lists.where((list) => list.isActive && household.spaceOf(list.spaceId) != null).toList();
  int rank(TaskList list) => household.isShared(list.spaceId) ? 0 : 1;

  return active..sort((a, b) {
    final byRank = rank(a).compareTo(rank(b));
    if (byRank != 0) return byRank;
    final byPosition = a.position.compareTo(b.position);
    return byPosition != 0 ? byPosition : a.id.compareTo(b.id);
  });
}

/// Daftar aktif pertama di sebuah ruang; ke sinilah tambah cepat memasukkan tugas.
TaskList? firstActiveList(List<TaskList> lists, String spaceId) {
  final inSpace = lists.where((list) => list.isActive && list.spaceId == spaceId).toList()
    ..sort((a, b) => a.position.compareTo(b.position));
  return inSpace.firstOrNull;
}

/// Semua tugas yang boleh tampil; `null` selama cache belum terbaca.
final taskItemsProvider = Provider<List<TaskItem>?>((ref) {
  final tasks = ref.watch(tasksProvider).value;
  final lists = ref.watch(taskListsProvider).value;
  final household = ref.watch(householdProvider);
  if (tasks == null || lists == null || household == null) return null;

  // Dihitung ulang saat waktu berjalan, supaya "hari ini" dan "Terlewat" ikut berganti.
  ref.watch(nowProvider);

  return buildTaskItems(tasks: tasks, lists: lists, household: household, clock: ref.watch(spaceClockProvider));
});

/// Daftar aktif dalam urutan tampil; `null` selama cache belum terbaca.
final activeListsProvider = Provider<List<TaskList>?>((ref) {
  final lists = ref.watch(taskListsProvider).value;
  final household = ref.watch(householdProvider);
  if (lists == null || household == null) return null;
  return orderLists(lists, household);
});
