import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../tasks/presentation/task_actions.dart' show showUndoSnackBar;
import '../domain/memory.dart';
import '../domain/memory_views.dart';
import 'photo_imports.dart';

/// Pilih foto dari galeri lalu tambahkan ke [memory], yang sudah berisi [existing] foto.
/// Foto disiapkan di latar belakang; hasilnya dilaporkan lewat snackbar.
Future<void> pickAndAddPhotos(BuildContext context, WidgetRef ref, Memory memory, {required int existing}) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final imports = ref.read(photoImportsProvider.notifier);

  final room = Limits.memoryPhotos - existing - imports.remaining(memory.id);
  if (room <= 0) return showMessage(context, l10n.memoryPhotosFull(Limits.memoryPhotos));

  final List<String> paths;
  try {
    paths = await ref.read(photoPickerProvider).pickFromGallery(limit: room);
  } on Object {
    // Galeri tidak bisa dibuka (izin ditolak atau tidak ada app galeri).
    return;
  }
  if (paths.isEmpty) return;

  final result = await imports.start(memory, paths.take(room).toList());
  reportPhotoImport(messenger, l10n, result);
}

/// Beri tahu foto yang tidak ikut masuk. Foto yang berhasil tidak perlu pesan: langsung tampil.
void reportPhotoImport(ScaffoldMessengerState messenger, AppLocalizations l10n, PhotoImportResult result) {
  final messages = [
    if (result.unreadable > 0) l10n.memoryPhotosUnreadable(result.unreadable),
    if (result.overLimit > 0) l10n.memoryPhotosFull(Limits.memoryPhotos),
  ];
  if (messages.isEmpty) return;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(messages.join(' '))));
}

/// Hapus kenangan. Yang berfoto meminta konfirmasi dulu, karena fotonya ikut terhapus dari
/// server dan tidak bisa dipulihkan; yang tanpa foto bisa diurungkan selama 5 detik.
/// Mengembalikan `true` kalau kenangannya dihapus.
Future<bool> deleteMemory(BuildContext context, WidgetRef ref, MemoryItem item) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final memories = ref.read(accountProvider)?.memories;
  if (memories == null) return false;

  final memory = item.memory;
  final photos = item.photos.length;

  if (photos > 0) {
    final confirmed = await confirmDialog(
      context,
      title: l10n.memoryDeleteConfirmTitle(memory.title),
      body: l10n.memoryDeleteConfirmBody(photos),
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return false;
    await memories.delete(memory.id);
    return true;
  }

  final opId = await memories.delete(memory.id, undoable: true);
  if (opId == null) return false;

  showUndoSnackBar(
    messenger,
    message: l10n.memoryDeletedSnack,
    undoLabel: l10n.commonUndo,
    onUndo: () => memories.undo(opId),
  );
  return true;
}

/// Hapus satu foto dengan kesempatan Urungkan selama 5 detik.
Future<void> deleteMemoryPhoto(BuildContext context, WidgetRef ref, String photoId) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final memories = ref.read(accountProvider)?.memories;
  if (memories == null) return;

  final opId = await memories.deletePhoto(photoId);
  if (opId == null) return;

  showUndoSnackBar(
    messenger,
    message: l10n.galleryDeletedSnack,
    undoLabel: l10n.commonUndo,
    onUndo: () => memories.undo(opId),
  );
}
