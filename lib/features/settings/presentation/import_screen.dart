import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/api/api_error.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../home/presentation/main_shell.dart';
import '../../spaces/domain/household.dart';
import '../data/data_import.dart';

/// Tujuan satu ruang di file ekspor.
enum _Destination { personal, shared, skip }

/// Berkas yang sudah dipilih dan diurai, beserta tujuan setiap ruangnya.
class _Picked {
  _Picked({required this.token, required this.file, required this.json, required this.spaces, required this.choices});

  /// Folder foto impor di HP, juga ID rencananya nanti.
  final String token;
  final PickedImportFile file;
  final Map<String, dynamic> json;
  final List<ImportSpace> spaces;
  final Map<String, _Destination> choices;

  /// Foto kenangan di file, termasuk yang tidak ikut karena file-nya JSON.
  int get photosInFile => (json['memory_photos'] as List<dynamic>? ?? const []).length;
}

/// Hasil impor yang selesai.
class _Summary {
  const _Summary({required this.created, required this.skipped, required this.photos});

  final Map<String, int> created;
  final Map<String, int> skipped;
  final int photos;
}

/// Urutan jumlah yang ditampilkan: tugas dulu, karena paling sering dicari.
const List<String> _displayOrder = [
  'tasks',
  'task_lists',
  'savings_goals',
  'savings_entries',
  'trips',
  'special_dates',
  'memories',
];

/// "12 tugas", "3 daftar", ... untuk jumlah yang lebih dari nol.
List<String> importCountLabels(AppLocalizations l10n, Map<String, int> counts, {int photos = 0}) => [
  for (final key in _displayOrder)
    if ((counts[key] ?? 0) > 0)
      switch (key) {
        'tasks' => l10n.countTasks(counts[key]!),
        'task_lists' => l10n.countLists(counts[key]!),
        'savings_goals' => l10n.countGoals(counts[key]!),
        'savings_entries' => l10n.countEntries(counts[key]!),
        'trips' => l10n.countTrips(counts[key]!),
        'special_dates' => l10n.countDates(counts[key]!),
        _ => l10n.countMemories(counts[key]!),
      },
  if (photos > 0) l10n.countPhotos(photos),
];

/// Pengaturan > Impor data (v1.x): salin isi file ekspor, JSON atau ZIP, ke Ruang Pribadi atau
/// Ruang Bersama sebagai data baru. Rencananya disimpan di HP sampai selesai, jadi impor yang
/// terputus bisa dilanjutkan dari layar ini dengan ID yang sama.
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  bool _loading = true;

  /// Rencana yang sedang dikirim, atau yang tertunda dari sebelumnya.
  ImportPlan? _plan;
  _Picked? _picked;
  bool _picking = false;
  bool _running = false;
  bool _finishing = false;
  String? _error;
  _Summary? _done;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  @override
  void dispose() {
    // Bagian yang sedang terkirim dibiarkan selesai; sisanya dilanjutkan lain kali.
    _disposed = true;
    final picked = _picked;
    if (picked != null) ref.read(importFilePickerProvider).discard(picked.token).ignore();
    super.dispose();
  }

  Future<void> _loadPending() async {
    final plan = await ref.read(accountProvider)?.imports.pending();
    if (mounted) {
      setState(() {
        _plan = plan;
        _loading = false;
      });
    }
  }

  void _back() => context.canPop() ? context.pop() : context.go(Routes.settings);

  // ---------------------------------------------------------------- pilih berkas

  Future<void> _pick() async {
    final household = ref.read(householdProvider);
    if (_picking || _running || household == null) return;
    final l10n = context.l10n;
    final picker = ref.read(importFilePickerProvider);
    final previous = _picked;
    final token = newImportId();
    setState(() {
      _picking = true;
      _error = null;
    });

    try {
      final file = await picker.pick(token);
      if (file == null) return;
      if (previous != null) await picker.discard(previous.token);

      final json = parseExportFile(file.json);
      final spaces = importSpaces(json, photos: file.photos);
      if (!mounted) return;
      if (spaces.isEmpty) {
        await picker.discard(token);
        setState(() {
          _picked = null;
          _error = l10n.importNothing;
        });
        return;
      }
      setState(() {
        _picked = _Picked(
          token: token,
          file: file,
          json: json,
          spaces: spaces,
          choices: {
            for (final space in spaces)
              space.id: space.isShared && household.isPaired ? _Destination.shared : _Destination.personal,
          },
        );
      });
    } on ImportFileInvalid catch (invalid) {
      await picker.discard(token);
      if (mounted) {
        setState(() {
          _picked = null;
          _error = invalid.problem == ImportFileProblem.newerVersion ? l10n.importNewerVersion : l10n.importNotExport;
        });
      }
    } on PlatformException catch (error) {
      debugPrint('Berkas impor tidak bisa dibaca: ${error.message}');
      await picker.discard(token);
      if (mounted) {
        setState(() {
          _picked = null;
          _error = l10n.importUnreadable;
        });
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  /// Tujuan setiap ruang di file yang tidak dilewati: ruang di file → ruangku.
  Map<String, String> _destinations(_Picked picked, Household household) => {
    for (final space in picked.spaces)
      space.id: ?switch (picked.choices[space.id]) {
        _Destination.personal => household.personal?.id,
        _Destination.shared => household.shared?.id,
        _ => null,
      },
  };

  // ---------------------------------------------------------------- kirim

  Future<void> _startImport() async {
    final picked = _picked;
    final household = ref.read(householdProvider);
    final account = ref.read(accountProvider);
    if (picked == null || household == null || account == null || _running) return;

    final l10n = context.l10n;
    final destinations = _destinations(picked, household);
    if (destinations.isEmpty) return;
    final rows = picked.spaces
        .where((space) => destinations.containsKey(space.id))
        .fold(0, (sum, space) => sum + space.rows);

    final confirmed = await confirmDialog(
      context,
      title: l10n.importConfirmTitle,
      body: l10n.importConfirmBody(rows),
      confirmLabel: l10n.importConfirm,
    );
    if (!confirmed || !mounted) return;

    final plan = planImport(
      id: picked.token,
      fileName: picked.file.name,
      file: picked.json,
      destinations: destinations,
      newId: newImportId,
      photos: picked.file.photos,
    );
    await account.imports.save(plan);
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _picked = null;
    });
    await _send(plan);
  }

  Future<void> _send(ImportPlan plan) async {
    final account = ref.read(accountProvider);
    if (account == null || _running) return;
    final l10n = context.l10n;
    final picker = ref.read(importFilePickerProvider);
    setState(() {
      _running = true;
      _error = null;
    });

    try {
      await account.imports.send(
        plan,
        onProgress: () {
          if (mounted) setState(() {});
        },
        stopped: () => _disposed,
      );
      if (_disposed || !plan.partsDone) return;

      setState(() => _finishing = true);
      final photos = await account.imports.finish(plan);
      // Fotonya sudah disalin ke folder unggah, jadi salinan dari ZIP tidak dibutuhkan lagi.
      await picker.discard(plan.id);
      if (!mounted) return;
      setState(() {
        _done = _Summary(created: plan.created, skipped: plan.skipped, photos: photos);
        _plan = null;
      });
    } on ApiError catch (error) {
      if (mounted) setState(() => _error = _sendError(l10n, error));
    } on NetworkFailure catch (failure) {
      if (mounted) setState(() => _error = (failure.status ?? 0) >= 500 ? l10n.genericError : l10n.needsConnection);
    } finally {
      if (mounted) {
        setState(() {
          _running = false;
          _finishing = false;
        });
      }
    }
  }

  String _sendError(AppLocalizations l10n, ApiError error) {
    final wait = error.retryAfter;
    return switch (error.code) {
      ApiErrorCode.tooManyRequests when wait != null => l10n.importTooOften((wait.inSeconds / 60).ceil().clamp(1, 60)),
      ApiErrorCode.validationFailed => l10n.importRejected(error.message),
      _ => error.message,
    };
  }

  Future<void> _cancel(ImportPlan plan) async {
    final account = ref.read(accountProvider);
    if (account == null || _running) return;
    final l10n = context.l10n;
    final confirmed = await confirmDialog(
      context,
      title: l10n.importCancelTitle,
      body: l10n.importCancelBody,
      confirmLabel: l10n.importCancel,
      destructive: true,
    );
    if (!confirmed) return;
    await account.imports.forget();
    await ref.read(importFilePickerProvider).discard(plan.id);
    if (mounted) {
      setState(() {
        _plan = null;
        _error = null;
      });
    }
  }

  // ---------------------------------------------------------------- tampilan

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final household = ref.watch(householdProvider);
    final plan = _plan;
    final picked = _picked;
    final done = _done;

    return AppScaffold(
      child: PageBody(
        children: [
          ScreenHeader(title: l10n.importTitle, onBack: _back),
          const SizedBox(height: AppDimens.gap10),
          if (_loading || household == null)
            const SkeletonCard(lines: 3)
          else if (done != null)
            ..._doneView(context, done)
          else if (plan != null)
            ..._planView(context, plan)
          else if (picked != null)
            ..._pickedView(context, picked, household)
          else
            ..._startView(context),
        ],
      ),
    );
  }

  List<Widget> _startView(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;

    return [
      Text(l10n.importIntro, style: text.body),
      const SizedBox(height: AppDimens.gap12),
      _Note(icon: Symbols.content_copy_rounded, text: l10n.importNoteTwice),
      _Note(icon: Symbols.photo_library_rounded, text: l10n.importNotePhotos),
      _Note(icon: Symbols.chat_bubble_rounded, text: l10n.importNoteLeftOut),
      const SizedBox(height: AppDimens.gap20),
      PrimaryButton(label: l10n.importPick, icon: Symbols.upload_file_rounded, onPressed: _picking ? null : _pick),
      if (_picking) _Working(text: l10n.importReading),
      if (_error != null) _Problem(text: _error!),
    ];
  }

  List<Widget> _pickedView(BuildContext context, _Picked picked, Household household) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final file = picked.file;
    final destinations = _destinations(picked, household);
    final toShared = picked.choices.values.contains(_Destination.shared) && household.isPaired;
    final partner = household.partner;

    return [
      AppCard(
        child: Row(
          children: [
            Icon(
              file.isZip ? Symbols.folder_zip_rounded : Symbols.data_object_rounded,
              size: AppDimens.iconLg,
              color: palette.brand,
            ),
            const SizedBox(width: AppDimens.gap10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(file.name, style: text.rowTitle),
                  Text(file.isZip ? l10n.importFileZip(file.photos.length) : l10n.importFileJson, style: text.caption),
                ],
              ),
            ),
          ],
        ),
      ),
      for (final space in picked.spaces) ...[
        const SizedBox(height: AppDimens.gap12),
        _SpaceChoice(
          space: space,
          choice: picked.choices[space.id]!,
          canShare: household.isPaired,
          photos: file.isZip ? space.photos : 0,
          onChanged: _running ? null : (choice) => setState(() => picked.choices[space.id] = choice),
        ),
      ],
      const SizedBox(height: AppDimens.gap16),
      if (toShared && partner != null) _Note(icon: Symbols.group_rounded, text: l10n.importSharedVisible(partner.name)),
      if (!file.isZip && picked.photosInFile > 0)
        _Note(icon: Symbols.no_photography_rounded, text: l10n.importPhotosLeftOut),
      _Note(icon: Symbols.content_copy_rounded, text: l10n.importNoteTwice),
      const SizedBox(height: AppDimens.gap16),
      PrimaryButton(
        label: l10n.importStart,
        icon: Symbols.upload_rounded,
        onPressed: destinations.isEmpty || _running || _picking ? null : _startImport,
      ),
      const SizedBox(height: AppDimens.gap8),
      Center(
        child: TextButton(onPressed: _running || _picking ? null : _pick, child: Text(l10n.importPickOther)),
      ),
      if (_picking) _Working(text: l10n.importReading),
      if (_error != null) _Problem(text: _error!),
    ];
  }

  List<Widget> _planView(BuildContext context, ImportPlan plan) {
    final l10n = context.l10n;
    final text = context.text;
    final total = plan.parts.length;

    if (_running) {
      return [
        Semantics(
          liveRegion: true,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _finishing ? l10n.importFinishing : l10n.importProgress((plan.next + 1).clamp(1, total), total),
                  style: text.caption,
                ),
              ),
              if (total > 0) Text('${(plan.next * 100 / total).floor()}%', style: text.captionStrong),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.gap6),
        ProgressBar(fraction: total == 0 ? 1 : plan.next / total),
        const SizedBox(height: AppDimens.gap12),
        Text(l10n.importKeepOpen, style: text.small),
      ];
    }

    return [
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.importPendingTitle, style: text.cardTitle),
            const SizedBox(height: AppDimens.gap6),
            Text(l10n.importPendingBody(plan.fileName, plan.next, total), style: text.body),
          ],
        ),
      ),
      if (_error != null) _Problem(text: _error!),
      const SizedBox(height: AppDimens.gap20),
      PrimaryButton(label: l10n.importResume, icon: Symbols.upload_rounded, onPressed: () => _send(plan)),
      const SizedBox(height: AppDimens.gap8),
      Center(
        child: TextButton(
          onPressed: () => _cancel(plan),
          style: TextButton.styleFrom(foregroundColor: context.palette.danger),
          child: Text(l10n.importCancel),
        ),
      ),
    ];
  }

  List<Widget> _doneView(BuildContext context, _Summary done) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final created = importCountLabels(l10n, done.created);
    final skipped = done.skipped.values.fold(0, (sum, count) => sum + count);

    return [
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              liveRegion: true,
              child: Row(
                children: [
                  Icon(Symbols.check_circle_rounded, size: AppDimens.iconLg, color: palette.ok),
                  const SizedBox(width: AppDimens.gap8),
                  Expanded(child: Text(l10n.importDone, style: text.cardTitle)),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.gap8),
            Text(created.isEmpty ? l10n.importCreatedNone : l10n.importCreated(created.join(', ')), style: text.body),
            if (skipped > 0) ...[
              const SizedBox(height: AppDimens.gap4),
              Text(l10n.importSkipped(skipped), style: text.caption),
            ],
            if (done.photos > 0) ...[
              const SizedBox(height: AppDimens.gap4),
              Text(l10n.importPhotosQueued(done.photos), style: text.caption),
            ],
          ],
        ),
      ),
      const SizedBox(height: AppDimens.gap20),
      PrimaryButton(label: l10n.importDoneButton, onPressed: _back),
    ];
  }
}

/// Satu ruang di file: isinya, lalu "Simpan ke mana?".
class _SpaceChoice extends StatelessWidget {
  const _SpaceChoice({
    required this.space,
    required this.choice,
    required this.canShare,
    required this.photos,
    required this.onChanged,
  });

  final ImportSpace space;
  final _Destination choice;

  /// Sudah punya Ruang Bersama, jadi ia bisa dipilih sebagai tujuan.
  final bool canShare;
  final int photos;
  final ValueChanged<_Destination>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;
    final onChanged = this.onChanged;
    final title = !space.isShared
        ? l10n.importSpacePersonal
        : space.otherMembers.isEmpty
        ? l10n.importSpaceShared
        : l10n.importSpaceSharedWith(space.otherMembers.join(', '));

    Widget chip(_Destination value, String label) => AppFilterChip(
      label: label,
      selected: choice == value,
      onTap: onChanged == null ? null : () => onChanged(value),
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(header: true, child: Text(title, style: text.cardTitle)),
          const SizedBox(height: AppDimens.gap4),
          Text(importCountLabels(l10n, space.counts, photos: photos).join(' · '), style: text.caption),
          const SizedBox(height: AppDimens.gap12),
          Text(l10n.importWhere, style: text.label),
          Wrap(
            spacing: AppDimens.gap8,
            children: [
              chip(_Destination.personal, l10n.importSpacePersonal),
              if (canShare) chip(_Destination.shared, l10n.importSpaceShared),
              chip(_Destination.skip, l10n.importSkip),
            ],
          ),
        ],
      ),
    );
  }
}

/// Catatan berikon kecil.
class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppDimens.gap6),
    child: StatusText(text: text, icon: icon, color: context.palette.muted),
  );
}

class _Working extends StatelessWidget {
  const _Working({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppDimens.gap8),
    child: Semantics(
      liveRegion: true,
      child: Text(text, style: context.text.small, textAlign: TextAlign.center),
    ),
  );
}

class _Problem extends StatelessWidget {
  const _Problem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppDimens.gap12),
    child: Semantics(
      liveRegion: true,
      child: StatusText(text: text, icon: Symbols.error_rounded, color: context.palette.danger),
    ),
  );
}
