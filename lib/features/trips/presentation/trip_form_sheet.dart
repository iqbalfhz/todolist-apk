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
import '../domain/trip.dart';

/// Buka lembar perjalanan baru, atau ubah [trip] kalau diisi. Perjalanan baru langsung dibuka
/// detailnya setelah disimpan, supaya checklistnya bisa segera diisi.
Future<void> showTripFormSheet(BuildContext context, {Trip? trip}) async {
  final router = GoRouter.of(context);
  final created = await showAppSheet<Trip>(context, builder: (_) => TripFormSheet(trip: trip));
  if (created != null) router.go(Routes.trip(created.id));
}

/// Lembar buat atau ubah perjalanan: nama, tujuan, tanggal berangkat dan pulang (boleh kosong),
/// catatan, dan ruangnya. Ruang hanya dipilih saat dibuat.
class TripFormSheet extends ConsumerStatefulWidget {
  const TripFormSheet({super.key, this.trip});

  final Trip? trip;

  @override
  ConsumerState<TripFormSheet> createState() => _TripFormSheetState();
}

class _TripFormSheetState extends ConsumerState<TripFormSheet> {
  late final TextEditingController _title = TextEditingController(text: widget.trip?.title ?? '');
  late final TextEditingController _destination = TextEditingController(text: widget.trip?.destination ?? '');
  late final TextEditingController _notes = TextEditingController(text: widget.trip?.notes ?? '');
  late String? _start = widget.trip?.startDate;
  late String? _end = widget.trip?.endDate;
  bool _shared = true;
  String? _titleError;
  String? _destinationError;
  String? _notesError;
  bool _saving = false;

  bool get _editing => widget.trip != null;

  @override
  void dispose() {
    _title.dispose();
    _destination.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickStart(String today) async {
    final picked = await pickDate(context, today: today, initial: _start);
    if (picked == null || !mounted) return;

    setState(() {
      _start = picked;
      // Tanggal pulang tidak boleh sebelum tanggal berangkat.
      if (_end != null && _end!.compareTo(picked) < 0) _end = null;
    });
  }

  Future<void> _pickEnd(String today) async {
    final start = _start;
    if (start == null) return;
    final picked = await pickDate(context, today: today, initial: _end ?? start, earliest: start);
    if (picked != null && mounted) setState(() => _end = picked);
  }

  Future<void> _save(Household household) async {
    final l10n = context.l10n;
    final title = _title.text.trim();
    final destination = _destination.text.trim();
    final notes = _notes.text.trim();

    final titleError = title.isEmpty
        ? l10n.errorTripTitleRequired
        : textLength(title) > Limits.tripTitle
        ? l10n.errorNameLong
        : null;
    final destinationError = textLength(destination) > Limits.tripDestination ? l10n.errorDestinationLong : null;
    final notesError = textLength(notes) > Limits.tripNotes ? l10n.errorNotesLong : null;

    if (titleError != null || destinationError != null || notesError != null) {
      return setState(() {
        _titleError = titleError;
        _destinationError = destinationError;
        _notesError = notesError;
      });
    }

    final account = ref.read(accountProvider);
    if (account == null || _saving) return;
    setState(() => _saving = true);

    final existing = widget.trip;
    Trip? created;
    if (existing == null) {
      // Belum berpasangan: semuanya disimpan di Ruang Pribadi.
      final space = _shared && household.isPaired ? household.shared : (household.personal ?? household.shared);
      if (space == null) return;
      created = await account.trips.create(
        spaceId: space.id,
        title: title,
        destination: destination,
        startDate: _start,
        endDate: _end,
        notes: notes,
      );
    } else {
      await account.trips.edit(
        existing.id,
        title: title,
        destination: destination,
        startDate: _start,
        endDate: _end,
        notes: notes,
      );
    }

    if (mounted) Navigator.of(context).pop(created);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final household = ref.watch(householdProvider);
    final title = _editing ? l10n.tripSheetEdit : l10n.tripSheetNew;

    if (household == null) {
      return AppSheet(
        title: title,
        children: const [SkeletonBox(height: AppDimens.fieldHeight)],
      );
    }

    final existing = widget.trip;
    final spaceId = existing?.spaceId ?? (household.shared ?? household.personal)?.id ?? '';
    final today = ref.watch(spaceClockProvider).today(household.timezoneOf(spaceId));
    final currentYear = parseYmd(today).year;
    final private = existing == null ? !_shared : !household.isShared(existing.spaceId);

    return AppSheet(
      title: title,
      footer: PrimaryButton(label: l10n.commonSave, onPressed: _saving ? null : () => _save(household)),
      children: [
        LabeledField(
          label: l10n.tripTitleLabel,
          child: TextField(
            controller: _title,
            autofocus: !_editing,
            style: text.inputStrong,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(hintText: l10n.tripTitleHint, errorText: _titleError),
            onChanged: (_) {
              if (_titleError != null) setState(() => _titleError = null);
            },
          ),
        ),
        LabeledField(
          label: l10n.tripDestinationLabel,
          child: TextField(
            controller: _destination,
            style: text.input,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(hintText: l10n.tripDestinationHint, errorText: _destinationError),
            onChanged: (_) {
              if (_destinationError != null) setState(() => _destinationError = null);
            },
          ),
        ),
        LabeledField(
          label: l10n.tripStartLabel,
          help: l10n.tripStartHelp,
          child: FieldButton(
            label: _start == null ? l10n.tripDatePick : formatDayShort(_start!, currentYear: currentYear),
            filled: _start != null,
            icon: Symbols.flight_takeoff_rounded,
            onTap: () => _pickStart(today),
          ),
        ),
        // Tanggal pulang butuh tanggal berangkat.
        if (_start != null)
          LabeledField(
            label: l10n.tripEndLabel,
            help: l10n.tripEndHelp,
            child: FieldButton(
              label: _end == null ? l10n.tripDatePick : formatDayShort(_end!, currentYear: currentYear),
              filled: _end != null,
              icon: Symbols.flight_land_rounded,
              onTap: () => _pickEnd(today),
            ),
          ),
        if (_start != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() {
                _start = null;
                _end = null;
              }),
              child: Text(l10n.tripDateClear),
            ),
          ),
        LabeledField(
          label: l10n.tripNotesLabel,
          child: TextField(
            controller: _notes,
            style: text.input,
            minLines: 2,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: l10n.tripNotesHint, errorText: _notesError),
            onChanged: (_) {
              if (_notesError != null) setState(() => _notesError = null);
            },
          ),
        ),
        // Ruang hanya dipilih saat membuat, dan hanya kalau sudah punya Ruang Bersama.
        if (existing == null && household.isPaired)
          LabeledField(
            label: l10n.spaceWhereLabel,
            help: private ? l10n.tripWherePrivateHelp : null,
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
        if (existing != null && private && household.isPaired)
          Row(
            children: [
              Icon(Symbols.lock_rounded, size: AppDimens.iconXs, color: palette.muted),
              const SizedBox(width: AppDimens.gap4),
              Expanded(child: Text(l10n.labelPersonal, style: text.small)),
            ],
          ),
      ],
    );
  }
}
