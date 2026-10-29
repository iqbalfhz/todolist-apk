import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/sync/sync_actions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../comments/domain/comment.dart';
import '../../comments/presentation/comments_section.dart';
import '../../spaces/domain/household.dart';
import '../domain/memory.dart';
import '../domain/memory_views.dart';
import 'memory_actions.dart';
import 'memory_map.dart';
import 'memory_photo_view.dart';
import 'photo_imports.dart';

enum _MemoryAction { edit, delete }

/// Detail kenangan: sampul, tanggal dan tempat, perjalanannya, cerita, kisi foto, dan
/// komentar serta reaksi (v1.x, hanya di Ruang Bersama).
class MemoryDetailScreen extends ConsumerStatefulWidget {
  const MemoryDetailScreen({super.key, required this.memoryId, this.showComments = false});

  final String memoryId;

  /// Dibuka dari notifikasi komentar atau reaksi: langsung gulir ke bagian Komentar.
  final bool showComments;

  @override
  ConsumerState<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends ConsumerState<MemoryDetailScreen> {
  final ScrollController _scroll = ScrollController();
  final GlobalKey _commentsKey = GlobalKey();
  bool _scrolledToComments = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memoryId = widget.memoryId;
    final l10n = context.l10n;
    final household = ref.watch(householdProvider);
    final items = ref.watch(memoryItemsProvider);
    final item = items?.where((item) => item.memory.id == memoryId).firstOrNull;
    final preparing = ref.watch(photoImportsProvider)[memoryId] ?? 0;
    void back() => context.go(Routes.memories);

    final Widget body;

    if (household == null || items == null) {
      body = PageBody(
        children: [
          ScreenHeader(onBack: back),
          const SizedBox(height: AppDimens.gap12),
          const SkeletonCard(lines: 3),
          const SizedBox(height: AppDimens.gap12),
          const SkeletonCard(lines: 2),
        ],
      );
    } else if (item == null) {
      // Dihapus (mungkin oleh pasangan) atau belum sampai di HP ini.
      body = PageBody(
        children: [
          ScreenHeader(onBack: back),
          const SizedBox(height: AppDimens.gap24),
          EmptyState(
            message: l10n.memoryGone,
            icon: Symbols.photo_library_rounded,
            actionLabel: l10n.commonBack,
            onAction: back,
          ),
        ],
      );
    } else {
      final memory = item.memory;
      final cover = item.cover;
      final story = memory.story;
      final photos = item.photos;
      final total = photos.length + preparing;
      final full = total >= Limits.memoryPhotos;
      final shared = household.isShared(memory.spaceId);

      if (widget.showComments && !_scrolledToComments && shared) {
        _scrolledToComments = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => scrollToComments(_scroll, _commentsKey));
      }

      body = PageBody(
        onRefresh: () => refreshFromServer(ref),
        controller: _scroll,
        children: [
          ScreenHeader(
            title: memory.title,
            onBack: back,
            trailing: PopupMenuButton<_MemoryAction>(
              tooltip: l10n.commonOptions,
              icon: const Icon(Symbols.more_vert_rounded, size: AppDimens.iconLg),
              onSelected: (action) async {
                switch (action) {
                  case _MemoryAction.edit:
                    context.go(Routes.editMemory(memory.id));
                  case _MemoryAction.delete:
                    if (await deleteMemory(context, ref, item) && context.mounted) back();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: _MemoryAction.edit, child: Text(l10n.commonEdit)),
                PopupMenuItem(value: _MemoryAction.delete, child: Text(l10n.commonDelete)),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.gap12),
          if (cover != null) ...[
            Semantics(
              button: true,
              image: true,
              label: l10n.memoryPhotoLabel(1, photos.length),
              excludeSemantics: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.cardRadius),
                child: AspectRatio(
                  aspectRatio: AppDimens.coverAspectDetail,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MemoryPhotoImage(photo: cover),
                      Material(
                        type: MaterialType.transparency,
                        child: InkWell(onTap: () => context.go(Routes.memoryPhoto(memory.id, cover.id))),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.gap12),
          ],
          _InfoCard(
            item: item,
            household: household,
            currentYear: parseYmd(ref.watch(spaceClockProvider).today(item.space.timezone)).year,
          ),
          // Pin lokasi (v1.x): ketuk untuk melihatnya bersama kenangan lain di Peta kenangan.
          if (memory.pin case final pin?) ...[
            const SizedBox(height: AppDimens.gap10),
            MemoryMapPreview(
              point: pin,
              semanticLabel: l10n.memoryMapPreview,
              onTap: () => context.go(Routes.memoriesMap(focusId: memory.id)),
            ),
          ],
          if (story != null) ...[
            const SizedBox(height: AppDimens.gap10),
            SectionTitle(l10n.memoryStoryTitle),
            const SizedBox(height: AppDimens.gap10),
            AppCard(
              semanticLabel: l10n.memoryStoryTitle,
              child: SelectableText(story, style: context.text.body),
            ),
          ],
          const SizedBox(height: AppDimens.gap10),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppDimens.minTouch),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(header: true, child: Text(l10n.memoryPhotosTitle, style: context.text.sectionTitle)),
                ),
                if (photos.isNotEmpty) Text(l10n.memoryPhotoCount(photos.length), style: context.text.caption),
              ],
            ),
          ),
          if (total == 0)
            AppCard(
              semanticLabel: l10n.memoryPhotosTitle,
              child: EmptyState(
                message: l10n.memoryPhotosEmpty,
                icon: Symbols.add_photo_alternate_rounded,
                actionLabel: l10n.memoryPhotosAdd,
                onAction: () => pickAndAddPhotos(context, ref, memory, existing: 0),
              ),
            )
          else ...[
            PhotoGrid(
              children: [
                for (final (index, photo) in photos.indexed)
                  MemoryPhotoTile(
                    key: ValueKey(photo.id),
                    photo: photo,
                    label: l10n.memoryPhotoLabel(index + 1, photos.length),
                    onTap: () => context.go(Routes.memoryPhoto(memory.id, photo.id)),
                  ),
                for (var i = 0; i < preparing; i++) const PreparingPhotoTile(),
              ],
            ),
            if (preparing > 0) ...[
              const SizedBox(height: AppDimens.gap8),
              Semantics(
                liveRegion: true,
                child: Text(l10n.memoryPhotosPreparing(preparing), style: context.text.caption),
              ),
            ],
            const SizedBox(height: AppDimens.gap4),
            Align(
              alignment: Alignment.centerLeft,
              child: full
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppDimens.gap8),
                      child: Text(l10n.memoryPhotosFull(Limits.memoryPhotos), style: context.text.caption),
                    )
                  : TextButton.icon(
                      onPressed: () => pickAndAddPhotos(context, ref, memory, existing: photos.length),
                      icon: const Icon(Symbols.add_photo_alternate_rounded, size: AppDimens.iconMd),
                      label: Text(l10n.memoryPhotosAdd),
                    ),
            ),
          ],
          // Komentar dan reaksi (v1.x) hanya di Ruang Bersama.
          if (shared) ...[
            const SizedBox(height: AppDimens.gap16),
            CommentsSection(
              key: _commentsKey,
              subject: Subject(SubjectType.memory, memory.id),
              spaceId: memory.spaceId,
              household: household,
            ),
          ],
        ],
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) back();
      },
      child: body,
    );
  }
}

/// Tanggal, tempat, perjalanan yang ditautkan, dan penanda Ruang Pribadi.
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.item, required this.household, required this.currentYear});

  final MemoryItem item;
  final Household household;

  /// Tahun ini di zona waktu ruangnya; tanggal di tahun lain ditulis dengan tahunnya.
  final int currentYear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final memory = item.memory;
    final place = memory.placeName;
    final trip = item.trip;

    Widget detail(IconData icon, String value, {TextStyle? style}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.gap4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppDimens.gap2),
            child: Icon(icon, size: AppDimens.iconSm, color: palette.muted),
          ),
          const SizedBox(width: AppDimens.gap8),
          Expanded(child: Text(value, style: style ?? text.body)),
        ],
      ),
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          detail(Symbols.calendar_today_rounded, formatDayShort(memory.visitedOn, currentYear: currentYear)),
          if (place != null) detail(Symbols.location_on_rounded, place),
          if (trip != null)
            InkWell(
              borderRadius: BorderRadius.circular(AppDimens.segmentItemRadius),
              onTap: () => context.go(Routes.trip(trip.id)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppDimens.minTouch),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: detail(Symbols.flight_land_rounded, l10n.memoryFromTrip(trip.title), style: text.link),
                ),
              ),
            ),
          if (!household.isShared(memory.spaceId) && household.isPaired)
            detail(Symbols.lock_rounded, l10n.labelPersonal),
        ],
      ),
    );
  }
}
