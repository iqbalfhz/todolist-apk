import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/widgets.dart';
import '../../home/presentation/main_shell.dart' show AppScaffold;
import '../domain/memory_photo.dart';
import '../domain/memory_views.dart';
import 'memory_actions.dart';
import 'memory_photo_view.dart';

enum _PhotoAction { cover, delete }

/// Galeri foto kenangan: geser antarfoto, cubit untuk memperbesar, jadikan sampul, dan hapus.
/// Dibuka di luar tab bawah supaya fotonya tampil selebar mungkin.
class MemoryGalleryScreen extends ConsumerStatefulWidget {
  const MemoryGalleryScreen({super.key, required this.memoryId, required this.photoId});

  final String memoryId;

  /// Foto yang dibuka pertama kali.
  final String photoId;

  @override
  ConsumerState<MemoryGalleryScreen> createState() => _MemoryGalleryScreenState();
}

class _MemoryGalleryScreenState extends ConsumerState<MemoryGalleryScreen> {
  PageController? _pages;

  /// Foto yang sedang tampil, supaya tetap di foto itu walaupun urutannya berubah. Selama
  /// fotonya terhapus, ID-nya tetap disimpan: kalau penghapusannya diurungkan, galeri kembali ke foto itu.
  late String _currentId = widget.photoId;
  int _currentIndex = 0;

  @override
  void dispose() {
    _pages?.dispose();
    super.dispose();
  }

  void _back() => context.go(Routes.memory(widget.memoryId));

  /// Indeks foto yang tampil. Kalau fotonya baru saja dihapus, pindah ke foto di tempatnya.
  int _indexIn(List<MemoryPhoto> photos) {
    final found = photos.indexWhere((photo) => photo.id == _currentId);
    if (found >= 0) return found;
    return _currentIndex.clamp(0, photos.length - 1);
  }

  Future<void> _onAction(_PhotoAction action, MemoryPhoto photo) async {
    final l10n = context.l10n;
    final memories = ref.read(accountProvider)?.memories;

    switch (action) {
      case _PhotoAction.cover:
        await memories?.makeCover(photo);
        if (mounted) showMessage(context, l10n.galleryCoverSet);
      case _PhotoAction.delete:
        await deleteMemoryPhoto(context, ref, photo.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;
    final items = ref.watch(memoryItemsProvider);
    final item = items?.where((item) => item.memory.id == widget.memoryId).firstOrNull;
    final photos = item?.photos ?? const <MemoryPhoto>[];

    final Widget body;
    if (items == null) {
      body = PageBody(
        children: [
          ScreenHeader(onBack: _back),
          const SizedBox(height: AppDimens.gap12),
          const AspectRatio(
            aspectRatio: AppDimens.coverAspectDetail,
            child: SkeletonBox(height: double.infinity, radius: AppDimens.photoRadius),
          ),
        ],
      );
    } else if (item == null || photos.isEmpty) {
      // Kenangan atau foto terakhirnya dihapus, mungkin oleh pasangan.
      body = PageBody(
        children: [
          ScreenHeader(onBack: _back),
          const SizedBox(height: AppDimens.gap24),
          EmptyState(
            message: item == null ? l10n.memoryGone : l10n.galleryGone,
            icon: Symbols.photo_library_rounded,
            actionLabel: l10n.commonBack,
            onAction: item == null ? () => context.go(Routes.memories) : _back,
          ),
        ],
      );
    } else {
      final index = _indexIn(photos);
      final photo = photos[index];
      _currentIndex = index;

      final pages = _pages ??= PageController(initialPage: index);
      // Urutan berubah (foto dihapus atau dijadikan sampul): geser ke foto yang sama.
      if (pages.hasClients && pages.page?.round() != index) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && pages.hasClients) pages.jumpToPage(index);
        });
      }

      body = Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppDimens.pageSide, AppDimens.gap12, AppDimens.pageSide, 0),
            child: ScreenHeader(
              title: l10n.galleryCounter(index + 1, photos.length),
              onBack: _back,
              trailing: PopupMenuButton<_PhotoAction>(
                tooltip: l10n.commonOptions,
                icon: const Icon(Symbols.more_vert_rounded, size: AppDimens.iconLg),
                onSelected: (action) => _onAction(action, photo),
                itemBuilder: (_) => [
                  if (index > 0) PopupMenuItem(value: _PhotoAction.cover, child: Text(l10n.galleryMakeCover)),
                  PopupMenuItem(value: _PhotoAction.delete, child: Text(l10n.galleryDelete)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimens.gap8),
          Expanded(
            child: PageView.builder(
              controller: pages,
              itemCount: photos.length,
              onPageChanged: (page) => setState(() {
                _currentIndex = page;
                _currentId = photos[page].id;
              }),
              itemBuilder: (context, page) => Semantics(
                image: true,
                label: l10n.memoryPhotoLabel(page + 1, photos.length),
                child: InteractiveViewer(
                  maxScale: 4,
                  child: MemoryPhotoImage(
                    key: ValueKey(photos[page].id),
                    photo: photos[page],
                    full: true,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pageSide,
              AppDimens.gap12,
              AppDimens.pageSide,
              AppDimens.pageBottom,
            ),
            child: _Caption(photo: photo, isCover: index == 0, timezone: item.space.timezone, style: text.caption),
          ),
        ],
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: AppScaffold(child: body),
    );
  }
}

/// Keterangan di bawah foto: sampul, waktu diambil, dan status unggah.
class _Caption extends ConsumerWidget {
  const _Caption({required this.photo, required this.isCover, required this.timezone, required this.style});

  final MemoryPhoto photo;
  final bool isCover;
  final String timezone;
  final TextStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final palette = context.palette;
    final clock = ref.watch(spaceClockProvider);
    final takenAt = photo.takenAt;

    String? taken;
    if (takenAt != null) {
      final local = clock.wallClock(takenAt, timezone);
      final currentYear = clock.nowIn(timezone).year;
      taken = l10n.galleryTakenAt(formatDayShort(local.date, currentYear: currentYear), formatClock(local.time));
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppDimens.gap12,
      runSpacing: AppDimens.gap4,
      children: [
        if (isCover) StatusText(text: l10n.galleryIsCover, icon: Symbols.star_rounded, color: palette.muted),
        if (taken != null) Text(taken, style: style),
        if (!photo.isUploaded)
          StatusText(text: l10n.memoryPhotoPending, icon: Symbols.cloud_upload_rounded, color: palette.muted),
      ],
    );
  }
}
