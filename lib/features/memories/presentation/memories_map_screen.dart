import 'package:flutter_map/flutter_map.dart';
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
import '../../spaces/domain/household.dart';
import '../domain/memory.dart';
import '../domain/memory_views.dart';
import 'memory_map.dart';

/// Peta kenangan (v1.x): semua kenangan berpin di satu peta. Ketuk pin untuk melihat kartunya,
/// lalu ketuk kartunya untuk membuka Detail kenangan. Dibuka dari tab Kenangan, atau dari
/// pratinjau peta di Detail kenangan dengan [focusId].
class MemoriesMapScreen extends ConsumerStatefulWidget {
  const MemoriesMapScreen({super.key, this.focusId});

  /// Kenangan yang langsung dipilih dan menjadi pusat peta.
  final String? focusId;

  @override
  ConsumerState<MemoriesMapScreen> createState() => _MemoriesMapScreenState();
}

class _MemoriesMapScreenState extends ConsumerState<MemoriesMapScreen> {
  late String? _selected = widget.focusId;

  void _back() {
    final focus = widget.focusId;
    context.go(focus == null ? Routes.memories : Routes.memory(focus));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final household = ref.watch(householdProvider);
    final items = ref.watch(memoryItemsProvider);

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(AppDimens.pageSide, AppDimens.gap12, AppDimens.pageSide, AppDimens.gap8),
      child: ScreenHeader(title: l10n.memoriesMapTitle, onBack: _back),
    );

    if (household == null || items == null) {
      return Column(
        children: [
          header,
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimens.pageSide),
            child: SkeletonCard(lines: 4),
          ),
        ],
      );
    }

    final pinned = [
      for (final item in items)
        if (item.memory.pin != null) item,
    ];
    final selected = pinned.where((item) => item.memory.id == _selected).firstOrNull;
    final focus = pinned.where((item) => item.memory.id == widget.focusId).firstOrNull;
    final currentYear = parseYmd(ref.watch(spaceClockProvider).today(household.me.timezone)).year;

    // Kamera awal: kenangan yang dibuka, satu-satunya pin, semua pin, atau Indonesia.
    final points = [for (final item in pinned) latLngOf(item.memory.pin!)];
    final center = focus?.memory.pin ?? (pinned.length == 1 ? pinned.single.memory.pin : null);
    final fitAll = center == null && points.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Padding(
          padding: const EdgeInsets.fromLTRB(AppDimens.pageSide, 0, AppDimens.pageSide, AppDimens.gap8),
          child: Text(
            pinned.isEmpty ? l10n.memoriesMapEmpty : l10n.memoriesMapCount(pinned.length),
            style: context.text.caption,
          ),
        ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: center == null ? defaultMapCenter : latLngOf(center),
                  initialZoom: center == null ? defaultMapZoom : pinMapZoom,
                  initialCameraFit: fitAll
                      ? CameraFit.coordinates(
                          coordinates: points,
                          padding: const EdgeInsets.all(AppDimens.mapFitPadding),
                          maxZoom: pinMapZoom,
                        )
                      : null,
                  maxZoom: maxMapZoom,
                  backgroundColor: context.palette.track,
                  interactionOptions: const InteractionOptions(flags: mapGestures),
                  onTap: (_, _) => setState(() => _selected = null),
                ),
                children: [
                  const OsmTiles(),
                  MarkerLayer(
                    markers: [
                      for (final item in pinned)
                        pinMarker(
                          item.memory.pin!,
                          child: Semantics(
                            button: true,
                            label: item.memory.title,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() => _selected = item.memory.id),
                              child: MapPin(selected: item.memory.id == _selected),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const OsmAttribution(),
                ],
              ),
              if (selected != null)
                Positioned(
                  left: AppDimens.pageSide,
                  right: AppDimens.pageSide,
                  bottom: AppDimens.mapCardBottom,
                  child: _SelectedMemory(item: selected, household: household, currentYear: currentYear),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kartu kenangan yang dipilih di peta: judul, tanggal dan tempat; ketuk membuka detailnya.
class _SelectedMemory extends StatelessWidget {
  const _SelectedMemory({required this.item, required this.household, required this.currentYear});

  final MemoryItem item;
  final Household household;
  final int currentYear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;
    final memory = item.memory;
    final details = [formatDayShort(memory.visitedOn, currentYear: currentYear), ?memory.placeName].join(' · ');

    return AppCard(
      semanticLabel: memory.title,
      onTap: () => context.go(Routes.memory(memory.id)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(memory.title, style: text.rowTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppDimens.gap2),
                Text(details, style: text.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppDimens.gap4),
                Text(l10n.memoriesMapOpen, style: text.link),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.gap8),
          const Icon(Symbols.chevron_right_rounded, size: AppDimens.iconMd),
        ],
      ),
    );
  }
}
