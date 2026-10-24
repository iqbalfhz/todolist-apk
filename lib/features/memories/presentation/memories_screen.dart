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
import '../../../core/widgets/widgets.dart';
import '../../spaces/domain/household.dart';
import '../domain/memory_views.dart';
import 'memory_photo_view.dart';

/// Tab Kenangan (v0.3): linimasa per tahun dan bulan dari `visited_on`, terbaru dulu.
class MemoriesScreen extends ConsumerWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = context.text;
    final household = ref.watch(householdProvider);
    final items = ref.watch(memoryItemsProvider);

    final header = Row(
      children: [
        Expanded(
          child: Semantics(header: true, child: Text(l10n.memoriesTitle, style: text.homeTitle)),
        ),
        AppIconButton(
          icon: Symbols.add_rounded,
          label: l10n.memoriesNew,
          outlined: true,
          iconSize: AppDimens.iconLg,
          onPressed: household == null ? null : () => context.go(Routes.newMemory()),
        ),
      ],
    );

    if (household == null || items == null) {
      return PageBody(
        children: [
          header,
          const SizedBox(height: AppDimens.gap12),
          const SkeletonCard(lines: 2),
          const SizedBox(height: AppDimens.gap12),
          const SkeletonCard(lines: 2),
        ],
      );
    }

    final currentYear = parseYmd(ref.watch(spaceClockProvider).today(household.me.timezone)).year;

    return PageBody(
      onRefresh: () => refreshFromServer(ref),
      children: [
        header,
        const SizedBox(height: AppDimens.gap12),
        if (items.isEmpty)
          EmptyState(
            message: household.isPaired ? l10n.memoriesEmpty : l10n.memoriesEmptySolo,
            icon: Symbols.photo_library_rounded,
            actionLabel: l10n.memoriesNew,
            onAction: () => context.go(Routes.newMemory()),
          ),
        for (final year in memoryTimeline(items)) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: SectionTitle('${year.year}')),
              Text(l10n.memoriesYearCount(year.count), style: text.caption),
            ],
          ),
          for (final month in year.months) ...[
            const SizedBox(height: AppDimens.gap10),
            Text(
              formatMonthLong(month.year, month.month),
              style: text.captionStrong.copyWith(color: context.palette.muted),
            ),
            const SizedBox(height: AppDimens.gap8),
            for (final item in month.items) ...[
              MemoryCard(item: item, household: household, currentYear: currentYear),
              const SizedBox(height: AppDimens.gap12),
            ],
          ],
          const SizedBox(height: AppDimens.gap8),
        ],
      ],
    );
  }
}

/// Kartu satu kenangan: sampul (kalau ada foto), judul, tanggal dan tempat, jumlah foto.
class MemoryCard extends StatelessWidget {
  const MemoryCard({super.key, required this.item, required this.household, required this.currentYear});

  final MemoryItem item;
  final Household household;
  final int currentYear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;
    final memory = item.memory;
    final cover = item.cover;
    final details = [formatDayShort(memory.visitedOn, currentYear: currentYear), ?memory.placeName].join(' · ');
    final private = !household.isShared(memory.spaceId) && household.isPaired;

    return AppCard(
      semanticLabel: memory.title,
      padding: EdgeInsets.zero,
      onTap: () => context.go(Routes.memory(memory.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (cover != null)
            ExcludeSemantics(
              child: AspectRatio(
                aspectRatio: AppDimens.coverAspectCard,
                child: MemoryPhotoImage(photo: cover),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(memory.title, style: text.rowTitle),
                const SizedBox(height: AppDimens.gap2),
                Text(details, style: text.caption),
                const SizedBox(height: AppDimens.gap8),
                Wrap(
                  spacing: AppDimens.gap12,
                  runSpacing: AppDimens.gap4,
                  children: [
                    _Meta(icon: Symbols.photo_library_rounded, label: l10n.memoryPhotoCount(item.photos.length)),
                    // Ruang Pribadi ditandai ikon gembok, bukan hanya teks.
                    if (private) _Meta(icon: Symbols.lock_rounded, label: l10n.labelPersonal),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimens.iconXs, color: palette.muted),
        const SizedBox(width: AppDimens.gap4),
        Flexible(
          child: Text(label, style: context.text.smallStrong.copyWith(color: palette.muted)),
        ),
      ],
    );
  }
}
