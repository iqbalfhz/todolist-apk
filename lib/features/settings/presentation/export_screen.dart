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
import '../../../core/widgets/widgets.dart';
import '../../home/presentation/main_shell.dart';
import '../data/data_export.dart';

/// Pengaturan > Ekspor data (v1.0): simpan salinan semua data sebagai satu berkas JSON di
/// `Download/Denly Days/{tanggal}`, lalu tawarkan unduh fotonya ke folder yang sama. Nama
/// menunya sama dengan halaman publik `/hapus-akun`.
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
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

  bool get _busy => _exporting || _downloading;

  void _back() => context.canPop() ? context.pop() : context.go(Routes.settings);

  Future<void> _start() async {
    final account = ref.read(accountProvider);
    if (account == null || _busy) return;

    final l10n = context.l10n;
    final saver = ref.read(exportSaverProvider);
    setState(() {
      _exporting = true;
      _error = null;
      _export = null;
      _failed = null;
    });

    try {
      final export = await account.exports.fetch();
      final location = await saver.save(
        folder: export.folder,
        name: export.fileName,
        mimeType: 'application/json',
        bytes: export.bytes,
      );
      if (!mounted) return;
      setState(() {
        _export = export;
        _location = location;
      });
    } on ApiError catch (error) {
      final wait = error.retryAfter;
      final message = error.code == ApiErrorCode.tooManyRequests && wait != null
          ? l10n.exportTooOften((wait.inSeconds / 60).ceil().clamp(1, 60))
          : error.message;
      if (mounted) setState(() => _error = message);
    } on NetworkFailure catch (failure) {
      final message = (failure.status ?? 0) >= 500 ? l10n.genericError : l10n.needsConnection;
      if (mounted) setState(() => _error = message);
    } on Object catch (error) {
      // Gagal menulis ke HP, misalnya penyimpanan penuh.
      debugPrint('Berkas ekspor gagal disimpan: $error');
      if (mounted) setState(() => _error = l10n.exportSaveFailed);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  /// Unduh [photos] ke folder hasil ekspor, satu per satu.
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final export = _export;

    return AppScaffold(
      child: PageBody(
        children: [
          ScreenHeader(title: l10n.exportTitle, onBack: _back),
          const SizedBox(height: AppDimens.gap10),
          Text(l10n.exportIntro, style: text.body),
          const SizedBox(height: AppDimens.gap8),
          Text(l10n.exportPhotosNote, style: text.body),
          const SizedBox(height: AppDimens.gap8),
          Text(l10n.exportServerNote, style: text.caption),
          const SizedBox(height: AppDimens.gap20),
          PrimaryButton(
            label: export == null ? l10n.exportButton : l10n.exportAgain,
            icon: Symbols.download_rounded,
            onPressed: _busy ? null : _start,
          ),
          if (_exporting) ...[
            const SizedBox(height: AppDimens.gap8),
            Semantics(
              liveRegion: true,
              child: Text(l10n.exportWorking, style: text.small, textAlign: TextAlign.center),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: AppDimens.gap12),
            Semantics(
              liveRegion: true,
              child: StatusText(text: _error!, icon: Symbols.error_rounded, color: palette.danger),
            ),
          ],
          if (export != null) ...[const SizedBox(height: AppDimens.gap20), _result(context, export)],
        ],
      ),
    );
  }

  Widget _result(BuildContext context, DataExport export) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final failed = _failed;
    final total = export.photos.length;

    return AppCard(
      child: Column(
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
            if (_downloading) ...[
              Semantics(
                liveRegion: true,
                child: Row(
                  children: [
                    Expanded(child: Text(l10n.exportPhotosProgress(_photosDone, _photosTotal), style: text.caption)),
                    Text('${(_photosDone * 100 / _photosTotal).floor()}%', style: text.captionStrong),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.gap6),
              ProgressBar(fraction: _photosDone / _photosTotal),
            ] else if (failed == null)
              OutlinedButton.icon(
                onPressed: () => _downloadPhotos(export.photos),
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
                  onPressed: () => _downloadPhotos(failed),
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
      ),
    );
  }
}
