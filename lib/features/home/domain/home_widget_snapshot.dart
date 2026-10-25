import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/utils/dates.dart';
import '../../savings/domain/savings_views.dart';
import '../../spaces/domain/household.dart';
import '../../tasks/domain/task_views.dart';

/// Ringkasan untuk widget "Tugas hari ini" di layar utama HP (v1.x), dikirim ke
/// `TasksWidget.kt` sebagai JSON.
///
/// Memuat tugas yang belum selesai dengan tenggat paling lama [horizonDays] hari ke depan
/// (termasuk yang terlewat), supaya widget tetap benar beberapa hari walau app tidak dibuka;
/// widget sendiri yang memilih tenggat hari ini dan yang terlewat menurut [timezone].
/// Tugas pasangan ikut, sama seperti Tugas hari ini di Beranda. Nominal tabungan tidak ikut,
/// hanya nama target utama dan persennya.
Map<String, dynamic> homeWidgetSnapshot({
  required List<TaskItem> tasks,
  required GoalProgress? goal,
  required String timezone,
  required String today,
}) {
  final horizon = addDays(today, horizonDays);
  final open = tasks.where((item) {
    final due = item.task.dueDate;
    return !item.isCompleted && due != null && due.compareTo(horizon) <= 0;
  }).toList()..sort(compareForToday);

  return {
    'signed_in': true,
    'timezone': timezone,
    'tasks': [
      for (final item in open.take(maxTasks))
        {'title': item.task.title, 'due': item.task.dueDate, 'time': item.task.dueTime},
    ],
    'goal': goal == null
        ? null
        : {
            'label': goal.goal.emoji == null ? goal.goal.name : '${goal.goal.emoji} ${goal.goal.name}',
            'percent': goal.percent,
          },
  };
}

/// Hari ke depan yang ikut di ringkasan.
const int horizonDays = 7;

/// Paling banyak tugas di ringkasan; widget hanya menampilkan beberapa dan "+N lainnya".
const int maxTasks = 40;

/// Isi widget saat belum masuk atau sudah keluar: tidak ada data apa pun.
const Map<String, dynamic> signedOutSnapshot = {'signed_in': false};

/// JSON untuk widget, atau `null` selama cache belum terbaca (widget dibiarkan seperti
/// sebelumnya). Zona waktunya sama dengan kepala Beranda.
final homeWidgetJsonProvider = Provider<String?>((ref) {
  if (ref.watch(accountProvider) == null) return jsonEncode(signedOutSnapshot);

  final household = ref.watch(householdProvider);
  final tasks = ref.watch(taskItemsProvider);
  final goals = ref.watch(goalProgressProvider);
  if (household == null || tasks == null || goals == null) return null;

  final timezone = (household.shared ?? household.personal)?.timezone ?? household.me.timezone;
  return jsonEncode(
    homeWidgetSnapshot(
      tasks: tasks,
      goal: primaryGoal(goals),
      timezone: timezone,
      today: ref.watch(spaceClockProvider).today(timezone),
    ),
  );
});
