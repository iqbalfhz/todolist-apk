import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/api/api_error.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/file_sizes.dart';
import '../../../core/widgets/widgets.dart';
import '../../home/presentation/main_shell.dart';
import '../data/data_export.dart';

/// Perkiraan jumlah foto di ZIP ekspor (v1.x), dari cache lokal: foto kenangan yang sudah
/// terunggah, ditambah foto profil kalau ada. Jumlah pastinya baru diketahui dari berkas ekspor.
final exportPhotoCountProvider = Provider<int?>((ref) {
  final photos = ref.watch(memoryPhotosProvider).value;
  final me = ref.watch(profileProvider).value;
  if (photos == null || me == null) return null;
  return photos.where((photo) => photo.isUploaded).length + (me.avatarUrl == null ? 0 : 1);
});

/// Pengaturan > Ekspor data: ZIP berisi data dan semua foto (v1.x) di `Download/Denly Days`, atau
/// file JSON saja (v1.0) di `Download/Denly Days/{tanggal}` dengan fotonya yang bisa diunduh
/// sesudahnya ke folder yang sama. Nama menunya sama dengan halaman publik `/hapus-akun`.
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  // ---------------------------------------------------------------- JSON saja (v1.0)

  DataExport? _export;
  String? _location;
  bool _exporting = false;
  String? _error;

  bool _downloading = false;
  int _photosTotal = 0;
  int _photosDone = 0;

  /// Foto yang belum tersimpan setelah unduhan terakhir; `null` selama belum ada unduhan yang
  /// selesai. "Coba lagi" hanya mengulang yang ini, karena sisanya sudah tersimpan.
  List<ExportPhoto>? _failed;

  // ---------------------------------------------------------------- ZIP berisi foto (v1.x)

  bool _zipping = false;

  /// ZIP yang masih terbuka karena ada foto yang gagal; ditutup lewat "Coba lagi" atau dibuang
  /// lewat "Ekspor tanpa foto".
  ExportZipJob? _zipJob;
  List<ExportPhoto>? _zipFailed;
  SavedZip? _zipSaved;
  String? _zipError;
  bool _zipFinishing = false;

  bool get _busy => _exporting || _downloading || _zipping;

  @override
  void dispose() {
    // ZIP yang belum selesai tidak boleh tertinggal di folder unduhan.
    _zipJob?.cancel().ignore();
    super.dispose();
  }

  void _back() => context.canPop() ? context.pop() : context.go(Routes.settings);

  String _apiMessage(ApiError error) {
    final wait = error.retryAfter;
    return error.code == ApiErrorCode.tooManyRequests && wait != null
        ? context.l10n.exportTooOften((wait.inSeconds / 60).ceil().clamp(1, 60))
        : error.message;
  }

  String _networkMessage(NetworkFailure failure) =>
      (failure.status ?? 0) >= 500 ? context.l10n.genericError : context.l10n.needsConnection;

  // ---------------------------------------------------------------- JSON saja

  Future<void> _start() async {
    final account = ref.read(accountProvider);
    if (account == null || _busy) return;
    await _discardZip();
    if (!mounted) return;

    setState(() {
      _exporting = true;
      _error = null;
      _export = null;
      _failed = null;
      _zipError = null;
      _zipSaved = null;
    });

    try {
      final export = await account.exports.fetch();
      await _saveJson(export);
    } on ApiError catch (error) {
      if (mounted) setState(() => _error = _apiMessage(error));
    } on NetworkFailure catch (failure) {
      if (mounted) setState(() => _error = _networkMessage(failure));
    } on Object catch (error) {
      // Gagal menulis ke HP, misalnya penyimpanan penuh.
      debugPrint('Berkas ekspor gagal disimpan: $error');
      if (mounted) setState(() => _error = context.l10n.exportSaveFailed);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  /// Simpan berkas JSON [export] ke folder unduhan. Gagal menulis dilempar ke pemanggil.
  Future<void> _saveJson(DataExport export) async {
    final location = await ref
        .read(exportSaverProvider)
        .save(folder: export.folder, name: export.fileName, mimeType: 'application/json', bytes: export.bytes);
    if (!mounted) return;
    setState(() {
      _export = export;
      _location = location;
    });
  }

  /// Unduh [photos] ke folder hasil ekspor JSON, satu per satu.
  Future<void> _downloadPhotos(List<ExportPhoto> photos) async {
    final export = _export;
    if (export == null || _busy) return;

    final saver = ref.read(exportSaverProvider);
    final fetcher = ref.read(exportPhotoFetcherProvider);
    setState(() {
      _downloading = true;
      _photosTotal = photos.length;
      _photosDone = 0;
      _failed = null;
    });

    final failed = <ExportPhoto>[];
    for (final photo in photos) {
      try {
        final bytes = await fetcher.fetch(photo);
        await saver.save(folder: export.folder, name: photo.fileName, mimeType: 'image/jpeg', bytes: bytes);
      } on Object catch (error) {
        debugPrint('Foto ${photo.fileName} gagal diunduh: $error');
        failed.add(photo);
      }
      if (!mounted) return;
      setState(() => _photosDone++);
    }

    setState(() {
      _downloading = false;
      _failed = failed;
    });
  }

  Future<void> _share(DataExport export) => SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(export.bytes, name: export.fileName, mimeType: 'application/json')],
      fileNameOverrides: [export.fileName],
    ),
  );

  // ---------------------------------------------------------------- ZIP berisi foto

  Future<void> _startZip() async {
    final account = ref.read(accountProvider);
    if (account == null || _busy) return;
    await _discardZip();
    if (!mounted) return;

    final l10n = context.l10n;
    final writer = ref.read(exportZipWriterProvider);
    setState(() {
      _zipping = true;
      _zipError = null;
      _zipSaved = null;
      _zipFailed = null;
      _photosDone = 0;
      _photosTotal = 0;
      _error = null;
      _export = null;
    });

    try {
      final export = await account.exports.fetch();

      // Foto ditulis langsung ke ZIP, jadi yang dibutuhkan kira-kira ukuran ZIP-nya saja.
      final need = export.zipSizeEstimate;
      final free = await writer.freeSpace();
      if (free != null && free < need + zipSpaceMargin) {
        if (mounted) setState(() => _zipError = l10n.exportZipNoSpace(formatFileSize(need), formatFileSize(free)));
        return;
      }

      final job = ExportZipJob(
        export: export,
        session: await writer.start(export.zipName),
        fetcher: ref.read(exportPhotoFetcherProvider),
      );
      if (!mounted) {
        await job.cancel();
        return;
      }
      _zipJob = job;
      await job.addData();
      await _addZipPhotos(job);
    } on ApiError catch (error) {
      if (mounted) setState(() => _zipError = _apiMessage(error));
    } on NetworkFailure catch (failure) {
      if (mounted) setState(() => _zipError = _networkMessage(failure));
    } on Object catch (error) {
      debugPrint('ZIP ekspor gagal disimpan: $error');
      await _discardZip();
      if (mounted) setState(() => _zipError = l10n.exportSaveFailed);
    } finally {
      if (mounted) setState(() => _zipping = false);
    }
  }

  /// Masukkan foto yang tersisa ke ZIP [job]; kalau semuanya masuk, ZIP-nya disimpan.
  Future<void> _addZipPhotos(ExportZipJob job) async {
    setState(() {
      _photosTotal = job.remaining.length;
      _photosDone = 0;
      _zipFailed = null;
    });

    final failed = await job.addPhotos(
      onProgress: (done) {
        if (mounted) setState(() => _photosDone = done);
      },
    );
    if (!mounted) return;
    if (failed.isNotEmpty) {
      setState(() => _zipFailed = failed);
      return;
    }

    setState(() => _zipFinishing = true);
    try {
      final saved = await job.finish();
      _zipJob = null;
      if (mounted) setState(() => _zipSaved = saved);
    } finally {
      if (mounted) setState(() => _zipFinishing = false);
    }
  }

  /// "Coba lagi": hanya foto yang gagal, ke ZIP yang sama.
  Future<void> _retryZip() async {
    final job = _zipJob;
    if (job == null || _busy) return;
    final l10n = context.l10n;
    setState(() {
      _zipping = true;
      _zipError = null;
    });
    try {
      await _addZipPhotos(job);
    } on Object catch (error) {
      debugPrint('ZIP ekspor gagal disimpan: $error');
      await _discardZip();
      if (mounted) setState(() => _zipError = l10n.exportSaveFailed);
    } finally {
      if (mounted) setState(() => _zipping = false);
    }
  }

  /// "Ekspor tanpa foto": buang ZIP yang belum lengkap, lalu simpan berkas JSON dari ekspor yang
  /// sama, tanpa meminta ekspor baru ke server.
  Future<void> _zipWithoutPhotos() async {
    final job = _zipJob;
    if (job == null || _busy) return;
    final l10n = context.l10n;
    await _discardZip();
    if (!mounted) return;

    setState(() {
      _zipFailed = null;
      _exporting = true;
      _error = null;
    });
    try {
      await _saveJson(job.export);
    } on Object catch (error) {
      debugPrint('Berkas ekspor gagal disimpan: $error');
      if (mounted) setState(() => _error = l10n.exportSaveFailed);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _discardZip() async {
    final job = _zipJob;
    _zipJob = null;
    if (job != null) await job.cancel();
  }

  // ---------------------------------------------------------------- tampilan

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;
    final export = _export;
    final photoCount = ref.watch(exportPhotoCountProvider);

    return AppScaffold(
      child: PageBody(
        children: [
          ScreenHeader(title: l10n.exportTitle, onBack: _back),
          const SizedBox(height: AppDimens.gap10),
          Text(l10n.exportIntro, style: text.body),
          const SizedBox(height: AppDimens.gap16),
          _Option(
            icon: Symbols.folder_zip_rounded,
            title: l10n.exportZipTitle,
            body: l10n.exportZipBody,
            note: photoCount == null
                ? null
                : l10n.exportZipEstimate(photoCount, formatFileSize(photoCount * photoSizeEstimate)),
            children: [
              PrimaryButton(
                label: l10n.exportZipButton,
                icon: Symbols.download_rounded,
                onPressed: _busy ? null : _startZip,
              ),
              ..._zipStatus(context),
            ],
          ),
          const SizedBox(height: AppDimens.gap12),
          _Option(
            icon: Symbols.data_object_rounded,
            title: l10n.exportJsonTitle,
            body: l10n.exportJsonBody,
            children: [
              OutlinedButton.icon(
                onPressed: _busy ? null : _start,
                icon: const Icon(Symbols.download_rounded, size: AppDimens.iconLg),
                label: Text(l10n.exportJsonButton),
              ),
              if (_exporting) _Working(text: l10n.exportWorking),
              if (_error != null) _Problem(text: _error!),
              if (export != null) ...[const SizedBox(height: AppDimens.gap16), _jsonResult(context, export)],
            ],
          ),
          const SizedBox(height: AppDimens.gap12),
          Text(l10n.exportServerNote, style: text.caption),
        ],
      ),
    );
  }

  List<Widget> _zipStatus(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final failed = _zipFailed;
    final saved = _zipSaved;

    return [
      if (_zipping && _photosTotal == 0 && failed == null) _Working(text: l10n.exportWorking),
      if (_zipping && _photosTotal > 0 && !_zipFinishing && failed == null) ...[
        const SizedBox(height: AppDimens.gap12),
        _Progress(done: _photosDone, total: _photosTotal),
      ],
      if (_zipFinishing) _Working(text: l10n.exportZipFinishing),
      if (_zipError != null) _Problem(text: _zipError!),
      if (failed != null && !_zipping) ...[
        const SizedBox(height: AppDimens.gap12),
        StatusText(
          text: l10n.exportZipFailed(failed.length, _photosTotal),
          icon: Symbols.warning_rounded,
          color: palette.warn,
        ),
        Wrap(
          spacing: AppDimens.gap8,
          children: [
            TextButton(onPressed: _retryZip, child: Text(l10n.commonRetry)),
            TextButton(onPressed: _zipWithoutPhotos, child: Text(l10n.exportWithoutPhotos)),
          ],
        ),
      ],
      if (saved != null) ...[
        const SizedBox(height: AppDimens.gap16),
        Semantics(
          liveRegion: true,
          child: Row(
            children: [
              Icon(Symbols.check_circle_rounded, size: AppDimens.iconLg, color: palette.ok),
              const SizedBox(width: AppDimens.gap8),
              Expanded(child: Text(l10n.exportZipSaved, style: text.cardTitle)),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.gap6),
        Text(saved.name, style: text.bodyStrong),
        Text(l10n.exportSavedIn(saved.location), style: text.caption),
        const SizedBox(height: AppDimens.gap8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => ref.read(exportZipWriterProvider).share(saved),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            icon: const Icon(Symbols.share_rounded, size: AppDimens.iconSm),
            label: Text(l10n.exportShare),
          ),
        ),
      ],
    ];
  }

  Widget _jsonResult(BuildContext context, DataExport export) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final failed = _failed;
    final total = export.photos.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Row(
            children: [
              Icon(Symbols.check_circle_rounded, size: AppDimens.iconLg, color: palette.ok),
              const SizedBox(width: AppDimens.gap8),
              Expanded(child: Text(l10n.exportSaved, style: text.cardTitle)),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.gap6),
        Text(export.fileName, style: text.bodyStrong),
        Text(l10n.exportSavedIn(_location ?? export.folder), style: text.caption),
        if (total > 0) ...[
          const SizedBox(height: AppDimens.gap16),
          if (_downloading)
            _Progress(done: _photosDone, total: _photosTotal)
          else if (failed == null)
            OutlinedButton.icon(
              onPressed: _busy ? null : () => _downloadPhotos(export.photos),
              icon: const Icon(Symbols.photo_library_rounded, size: AppDimens.iconLg),
              label: Text(l10n.exportPhotosButton(total)),
            )
          else if (failed.isEmpty)
            StatusText(text: l10n.exportPhotosDone(total), icon: Symbols.check_rounded, color: palette.ok)
          else ...[
            StatusText(
              text: l10n.exportPhotosPartial(total - failed.length, total, failed.length),
              icon: Symbols.warning_rounded,
              color: palette.warn,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _busy ? null : () => _downloadPhotos(failed),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text(l10n.commonRetry),
              ),
            ),
          ],
        ],
        const SizedBox(height: AppDimens.gap8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _downloading ? null : () => _share(export),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            icon: const Icon(Symbols.share_rounded, size: AppDimens.iconSm),
            label: Text(l10n.exportShare),
          ),
        ),
      ],
    );
  }
}

/// Satu cara ekspor: ikon, judul, penjelasan, lalu tombol dan hasilnya.
class _Option extends StatelessWidget {
  const _Option({required this.icon, required this.title, required this.body, required this.children, this.note});

  final IconData icon;
  final String title;
  final String body;
  final String? note;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final note = this.note;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: AppDimens.iconLg, color: context.palette.brand),
              const SizedBox(width: AppDimens.gap8),
              Expanded(
                child: Semantics(header: true, child: Text(title, style: text.cardTitle)),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.gap6),
          Text(body, style: text.body),
          if (note != null) ...[const SizedBox(height: AppDimens.gap4), Text(note, style: text.caption)],
          const SizedBox(height: AppDimens.gap12),
          ...children,
        ],
      ),
    );
  }
}

/// "Mengunduh foto 3 dari 12", persen, dan bar progresnya.
class _Progress extends StatelessWidget {
  const _Progress({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final text = context.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Row(
            children: [
              Expanded(child: Text(context.l10n.exportPhotosProgress(done, total), style: text.caption)),
              Text('${(done * 100 / total).floor()}%', style: text.captionStrong),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.gap6),
        ProgressBar(fraction: done / total),
      ],
    );
  }
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
