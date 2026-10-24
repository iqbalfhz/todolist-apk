import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../spaces/domain/household.dart';
import '../../trips/domain/trip.dart';
import '../domain/memory.dart';
import 'memory_actions.dart';
import 'memory_photo_view.dart';
import 'photo_imports.dart';

/// Tanggal paling awal yang bisa dipilih untuk kenangan.
const String _earliestVisit = '1900-01-01';

/// Tambah atau ubah kenangan: judul, tempat, tanggal, cerita, dan (saat dibuat) foto dan ruangnya.
///
/// [tripId] mengisi formulir dari perjalanan yang sudah selesai ("Simpan jadi kenangan"):
/// judul, tujuan sebagai tempat, tanggal berangkat, dan ruang perjalanan itu.
class MemoryFormScreen extends ConsumerStatefulWidget {
  const MemoryFormScreen({super.key, this.memoryId, this.tripId});

  /// Kenangan yang diubah; `null` untuk kenangan baru.
  final String? memoryId;
  final String? tripId;

  @override
  ConsumerState<MemoryFormScreen> createState() => _MemoryFormScreenState();
}

class _MemoryFormScreenState extends ConsumerState<MemoryFormScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _place = TextEditingController();
  final TextEditingController _story = TextEditingController();
  String? _visitedOn;
  bool _shared = true;
  final List<String> _paths = [];
  bool _filled = false;
  String? _titleError;
  String? _placeError;
  String? _storyError;
  bool _saving = false;

  bool get _editing => widget.memoryId != null;

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    _story.dispose();
    super.dispose();
  }

  String _backTo() {
    final memoryId = widget.memoryId;
    final tripId = widget.tripId;
    if (memoryId != null) return Routes.memory(memoryId);
    if (tripId != null) return Routes.trip(tripId);
    return Routes.memories;
  }

  void _back() => context.go(_backTo());

  /// Isi formulir sekali, begitu kenangan atau perjalanannya terbaca dari cache.
  void _fill({Memory? memory, Trip? trip}) {
    if (_filled) return;
    if (memory != null) {
      _title.text = memory.title;
      _place.text = memory.placeName ?? '';
      _story.text = memory.story ?? '';
      _visitedOn = memory.visitedOn;
    } else if (trip != null) {
      _title.text = trip.title;
      _place.text = trip.destination ?? '';
      _visitedOn = trip.startDate;
    }
    _filled = true;
  }

  Future<void> _pickDate(String today) async {
    final picked = await pickDate(context, today: today, initial: _visitedOn ?? today, earliest: _earliestVisit);
    if (picked != null && mounted) setState(() => _visitedOn = picked);
  }

  Future<void> _pickPhotos() async {
    final room = Limits.memoryPhotos - _paths.length;
    if (room <= 0) return;

    final List<String> picked;
    try {
      picked = await ref.read(photoPickerProvider).pickFromGallery(limit: room);
    } on Object {
      // Galeri tidak bisa dibuka (izin ditolak atau tidak ada app galeri).
      return;
    }
    if (picked.isNotEmpty && mounted) setState(() => _paths.addAll(picked.take(room)));
  }

  Future<void> _save({required Household household, required String spaceId, required String today}) async {
    final l10n = context.l10n;
    final title = _title.text.trim();
    final place = _place.text.trim();
    final story = _story.text.trim();

    final titleError = title.isEmpty
        ? l10n.errorMemoryTitleRequired
        : textLength(title) > Limits.memoryTitle
        ? l10n.errorNameLong
        : null;
    final placeError = textLength(place) > Limits.memoryPlace ? l10n.errorPlaceLong : null;
    final storyError = textLength(story) > Limits.memoryStory ? l10n.errorStoryLong : null;

    if (titleError != null || placeError != null || storyError != null) {
      return setState(() {
        _titleError = titleError;
        _placeError = placeError;
        _storyError = storyError;
      });
    }

    final account = ref.read(accountProvider);
    if (account == null || _saving) return;
    setState(() => _saving = true);

    final visitedOn = _visitedOn ?? today;
    final memoryId = widget.memoryId;
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final imports = ref.read(photoImportsProvider.notifier);

    if (memoryId != null) {
      await account.memories.edit(memoryId, title: title, placeName: place, visitedOn: visitedOn, story: story);
      router.go(Routes.memory(memoryId));
      return;
    }

    final memory = await account.memories.create(
      spaceId: spaceId,
      title: title,
      placeName: place,
      visitedOn: visitedOn,
      story: story,
      tripId: widget.tripId,
    );

    // Foto disiapkan di latar belakang dan muncul satu per satu di Detail kenangan.
    final paths = List.of(_paths);
    router.go(Routes.memory(memory.id));
    if (paths.isNotEmpty) {
      unawaited(imports.start(memory, paths).then((result) => reportPhotoImport(messenger, l10n, result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final household = ref.watch(householdProvider);
    final memories = ref.watch(memoriesProvider).value;
    final trips = ref.watch(tripsProvider).value;
    final title = _editing ? l10n.memoryFormEdit : l10n.memoryFormNew;

    final memory = memories?.where((item) => item.id == widget.memoryId && item.deletedAt == null).firstOrNull;
    final trip = trips?.where((item) => item.id == widget.tripId && item.deletedAt == null).firstOrNull;
    final loading = household == null || memories == null || trips == null;

    final Widget body;
    if (loading) {
      body = PageBody(
        children: [
          ScreenHeader(title: title, onBack: _back),
          const SizedBox(height: AppDimens.gap12),
          const SkeletonCard(lines: 4),
        ],
      );
    } else if (_editing && memory == null) {
      body = PageBody(
        children: [
          ScreenHeader(onBack: _back),
          const SizedBox(height: AppDimens.gap24),
          EmptyState(
            message: l10n.memoryGone,
            icon: Symbols.photo_library_rounded,
            actionLabel: l10n.commonBack,
            onAction: () => context.go(Routes.memories),
          ),
        ],
      );
    } else {
      _fill(memory: memory, trip: trip);

      // Belum berpasangan: semuanya disimpan di Ruang Pribadi. Dari perjalanan: ruang perjalanannya.
      final chosen = _shared && household.isPaired ? household.shared : (household.personal ?? household.shared);
      final spaceId = memory?.spaceId ?? trip?.spaceId ?? chosen?.id ?? '';
      final today = ref.watch(spaceClockProvider).today(household.timezoneOf(spaceId));
      final currentYear = parseYmd(today).year;
      final visitedOn = _visitedOn ?? today;
      final private = !household.isShared(spaceId) && household.isPaired;
      final choosesSpace = memory == null && trip == null && household.isPaired;

      body = PageBody(
        children: [
          ScreenHeader(title: title, onBack: _back),
          const SizedBox(height: AppDimens.gap12),
          LabeledField(
            label: l10n.memoryTitleLabel,
            child: TextField(
              controller: _title,
              autofocus: !_editing && trip == null,
              style: text.inputStrong,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(hintText: l10n.memoryTitleHint, errorText: _titleError),
              onChanged: (_) {
                if (_titleError != null) setState(() => _titleError = null);
              },
            ),
          ),
          const SizedBox(height: AppDimens.gap14),
          LabeledField(
            label: l10n.memoryPlaceLabel,
            child: TextField(
              controller: _place,
              style: text.input,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(hintText: l10n.memoryPlaceHint, errorText: _placeError),
              onChanged: (_) {
                if (_placeError != null) setState(() => _placeError = null);
              },
            ),
          ),
          const SizedBox(height: AppDimens.gap14),
          LabeledField(
            label: l10n.memoryDateLabel,
            child: FieldButton(
              label: formatDayShort(visitedOn, currentYear: currentYear),
              filled: true,
              icon: Symbols.calendar_today_rounded,
              onTap: () => _pickDate(today),
            ),
          ),
          const SizedBox(height: AppDimens.gap14),
          LabeledField(
            label: l10n.memoryStoryLabel,
            child: TextField(
              controller: _story,
              style: text.input,
              minLines: 3,
              maxLines: 12,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(hintText: l10n.memoryStoryHint, errorText: _storyError),
              onChanged: (_) {
                if (_storyError != null) setState(() => _storyError = null);
              },
            ),
          ),
          // Foto kenangan yang sudah ada dikelola di Detail kenangan.
          if (!_editing) ...[
            const SizedBox(height: AppDimens.gap14),
            LabeledField(
              label: l10n.memoryPhotosLabel,
              help: l10n.memoryPhotosHelp(Limits.memoryPhotos),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_paths.isNotEmpty) ...[
                    PhotoGrid(
                      children: [
                        for (final (index, path) in _paths.indexed)
                          _PickedPhoto(
                            key: ValueKey(path),
                            path: path,
                            removeLabel: l10n.memoryPhotoUnpick(index + 1),
                            onRemove: () => setState(() => _paths.removeAt(index)),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.gap4),
                  ],
                  if (_paths.length < Limits.memoryPhotos)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _pickPhotos,
                        icon: const Icon(Symbols.add_photo_alternate_rounded, size: AppDimens.iconMd),
                        label: Text(l10n.memoryPhotosPick),
                      ),
                    ),
                ],
              ),
            ),
          ],
          // Ruang hanya dipilih saat membuat, dan hanya kalau sudah punya Ruang Bersama.
          if (choosesSpace) ...[
            const SizedBox(height: AppDimens.gap14),
            LabeledField(
              label: l10n.spaceWhereLabel,
              help: private ? l10n.memoryWherePrivateHelp : null,
              child: SegmentedControl<bool>(
                semanticLabel: l10n.spaceWhereLabel,
                selected: _shared,
                onChanged: (shared) => setState(() => _shared = shared),
                segments: [
                  Segment(value: true, label: l10n.labelShared),
                  Segment(value: false, label: l10n.labelPersonal),
                ],
              ),
            ),
          ] else if (private) ...[
            const SizedBox(height: AppDimens.gap14),
            Row(
              children: [
                Icon(Symbols.lock_rounded, size: AppDimens.iconXs, color: palette.muted),
                const SizedBox(width: AppDimens.gap4),
                Expanded(child: Text(l10n.labelPersonal, style: text.small)),
              ],
            ),
          ],
          const SizedBox(height: AppDimens.gap24),
          PrimaryButton(
            label: l10n.commonSave,
            onPressed: _saving ? null : () => _save(household: household, spaceId: spaceId, today: today),
          ),
        ],
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: body,
    );
  }
}

/// Foto yang baru dipilih dari galeri, belum disimpan, dengan tombol batal pilih.
class _PickedPhoto extends StatelessWidget {
  const _PickedPhoto({super.key, required this.path, required this.removeLabel, required this.onRemove});

  final String path;
  final String removeLabel;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.photoRadius),
          child: LayoutBuilder(
            builder: (context, constraints) => Image.file(
              File(path),
              fit: BoxFit.cover,
              // Foto asli bisa puluhan megapiksel; cukup dibaca seukuran kotaknya.
              cacheWidth: constraints.hasBoundedWidth
                  ? (constraints.maxWidth * MediaQuery.devicePixelRatioOf(context)).ceil()
                  : null,
              errorBuilder: (_, _, _) => ColoredBox(
                color: palette.track,
                child: Center(
                  child: Icon(Symbols.image_rounded, size: AppDimens.iconXl, color: palette.muted),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: AppIconButton(
            icon: Symbols.close_rounded,
            label: removeLabel,
            outlined: true,
            iconSize: AppDimens.iconMd,
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }
}
