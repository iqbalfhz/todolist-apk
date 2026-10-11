import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/queue/outbox.dart';
import '../domain/task_views.dart';

/// Waktu snackbar muncul dan menghilang. Dikurangkan dari lama tampilnya, supaya tombol
/// Urungkan sudah hilang sebelum jeda kirim 5 detik di antrean berakhir.
const Duration _snackBarAnimation = Duration(milliseconds: 600);

/// Tampilkan snackbar dengan tombol Urungkan selama 5 detik.
///
/// Selama itu operasinya belum dikirim, jadi pasangan tidak menerima notifikasi
/// yang kemudian dibatalkan.
void showUndoSnackBar(
  ScaffoldMessengerState messenger, {
  required String message,
  required String undoLabel,
  required FutureOr<void> Function() onUndo,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Outbox.undoWindow - _snackBarAnimation,
        // Tanpa ini, snackbar beraksi tidak hilang sendiri saat pembaca layar aktif.
        persist: false,
        action: SnackBarAction(label: undoLabel, onPressed: () => unawaited(Future.sync(onUndo))),
      ),
    );
}

/// Centang atau batalkan centang sebuah tugas.
Future<void> toggleTask(BuildContext context, WidgetRef ref, TaskItem item) async {
  final account = ref.read(accountProvider);
  if (account == null) return;

  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final taskId = item.task.id;

  if (item.isCompleted) {
    messenger.hideCurrentSnackBar();
    await account.tasks.uncomplete(taskId);
    return;
  }

  final opId = await account.tasks.complete(taskId);
  if (opId == null) return;

  showUndoSnackBar(
    messenger,
    message: l10n.taskCompletedSnack,
    undoLabel: l10n.commonUndo,
    onUndo: () async {
      // Kalau operasinya sudah terlanjur dikirim, batalkan dengan perubahan baru.
      if (!await account.tasks.undo(opId)) await account.tasks.uncomplete(taskId);
    },
  );
}

/// Hapus tugas dengan kesempatan Urungkan.
Future<void> deleteTask(BuildContext context, WidgetRef ref, String taskId) async {
  final account = ref.read(accountProvider);
  if (account == null) return;

  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);

  final opId = await account.tasks.delete(taskId);
  if (opId == null) return;

  showUndoSnackBar(
    messenger,
    message: l10n.taskDeletedSnack,
    undoLabel: l10n.commonUndo,
    onUndo: () => account.tasks.undo(opId),
  );
}
