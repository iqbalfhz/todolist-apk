import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../domain/memory_photo.dart';

/// Gambar foto kenangan: dari cache, dari berkas yang menunggu diunggah, atau diunduh.
/// Selama belum ada, atau kalau gagal dimuat, tampil kotak `track` dengan ikon foto.
///
/// [full] memakai versi penuh (galeri); selain itu thumbnail 800 px.
class MemoryPhotoImage extends ConsumerStatefulWidget {
  const MemoryPhotoImage({super.key, required this.photo, this.full = false, this.fit = BoxFit.cover});

  final MemoryPhoto photo;
  final bool full;
  final BoxFit fit;

  @override
  ConsumerState<MemoryPhotoImage> createState() => _MemoryPhotoImageState();
}

class _MemoryPhotoImageState extends ConsumerState<MemoryPhotoImage> {
  late Future<File?> _file = _load();

  Future<File?> _load() async {
    final images = ref.read(accountProvider)?.photoImages;
    if (images == null) return null;
    try {
      return await (widget.full ? images.full(widget.photo) : images.thumb(widget.photo));
    } on Object {
      // Offline atau URL-nya tidak bisa diperbarui: tampil kotak pengganti.
      return null;
    }
  }

  @override
  void didUpdateWidget(MemoryPhotoImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final before = oldWidget.photo;
    final now = widget.photo;
    // Unggahan selesai atau URL diperbarui: sumber gambarnya bisa pindah.
    if (before.id != now.id ||
        before.url != now.url ||
        before.thumbUrl != now.thumbUrl ||
        oldWidget.full != widget.full) {
      _file = _load();
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<File?>(
    future: _file,
    builder: (context, snapshot) {
      final file = snapshot.data;
      if (file == null) return _PhotoPlaceholder(loading: snapshot.connectionState != ConnectionState.done);

      return LayoutBuilder(
        builder: (context, constraints) => Image.file(
          file,
          fit: widget.fit,
          width: double.infinity,
          height: double.infinity,
          // Thumbnail dibaca seukuran kotaknya saja, supaya kisi 50 foto tetap ringan.
          cacheWidth: widget.full ? null : _decodeWidth(context, constraints, widget.photo.aspectRatio),
          gaplessPlayback: true,
          // Selama berkasnya dibaca, kotaknya tetap berwarna `track`, tidak kosong.
          frameBuilder: (_, child, frame, synchronous) =>
              frame == null && !synchronous ? const _PhotoPlaceholder(loading: true) : child,
          errorBuilder: (_, _, _) => const _PhotoPlaceholder(loading: false),
        ),
      );
    },
  );

  /// Lebar baca untuk mengisi kotak [constraints] secara `cover`: foto melebar diukur dari
  /// tingginya, foto tegak dari lebarnya.
  static int? _decodeWidth(BuildContext context, BoxConstraints constraints, double? aspect) {
    if (!constraints.hasBoundedWidth) return null;
    final ratio = MediaQuery.devicePixelRatioOf(context);
    final height = constraints.hasBoundedHeight ? constraints.maxHeight : 0.0;
    final width = math.max(constraints.maxWidth, height * (aspect ?? 1));
    return (width * ratio).ceil();
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.loading});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return ColoredBox(
      color: palette.track,
      child: loading
          ? const SizedBox.expand()
          : Center(
              child: Icon(Symbols.image_rounded, size: AppDimens.iconXl, color: palette.muted),
            ),
    );
  }
}

/// Kotak foto di kisi: persegi, sudut 12, dengan penanda kalau belum terkirim.
class MemoryPhotoTile extends StatelessWidget {
  const MemoryPhotoTile({super.key, required this.photo, required this.label, required this.onTap});

  final MemoryPhoto photo;

  /// "Foto 3 dari 12", untuk pembaca layar.
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pending = !photo.isUploaded;
    final semantics = pending ? '$label, ${context.l10n.memoryPhotoPending}' : label;

    return Semantics(
      button: true,
      image: true,
      label: semantics,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.photoRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            MemoryPhotoImage(photo: photo),
            if (pending) const Positioned(right: AppDimens.gap4, bottom: AppDimens.gap4, child: PendingBadge()),
            Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lingkaran kecil berikon unggah: foto ini belum sampai di server.
class PendingBadge extends StatelessWidget {
  const PendingBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Tooltip(
      message: context.l10n.memoryPhotoPending,
      child: Container(
        width: AppDimens.photoBadge,
        height: AppDimens.photoBadge,
        decoration: BoxDecoration(
          color: palette.surface,
          shape: BoxShape.circle,
          border: Border.all(color: palette.line, width: AppDimens.borderWidth),
        ),
        child: Icon(Symbols.cloud_upload_rounded, size: AppDimens.iconXs, color: palette.text),
      ),
    );
  }
}

/// Kotak skeleton untuk foto yang masih disiapkan.
class PreparingPhotoTile extends StatelessWidget {
  const PreparingPhotoTile({super.key});

  @override
  Widget build(BuildContext context) => const ExcludeSemantics(
    child: SkeletonBox(height: double.infinity, radius: AppDimens.photoRadius),
  );
}

/// Kisi foto tiga kolom, persegi, dengan jarak 4. Tingginya mengikuti isinya.
class PhotoGrid extends StatelessWidget {
  const PhotoGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: AppDimens.photoColumns,
    mainAxisSpacing: AppDimens.photoGap,
    crossAxisSpacing: AppDimens.photoGap,
    shrinkWrap: true,
    padding: EdgeInsets.zero,
    physics: const NeverScrollableScrollPhysics(),
    children: children,
  );
}
