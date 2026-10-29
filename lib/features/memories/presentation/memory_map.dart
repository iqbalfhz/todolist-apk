import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/memory.dart';

/// Peta untuk pin lokasi kenangan (v1.x), dengan ubin OpenStreetMap.
///
/// Kebijakan tile OSM (https://operations.osmfoundation.org/policies/tiles/): User-Agent
/// menyebut app ini, ubin disimpan di cache HP, dan atribusi "© OpenStreetMap contributors"
/// selalu tampil di peta. Hanya bagian inti flutter_map yang dipakai (ubin, penanda, kamera);
/// atribusi dan tombolnya dibuat sendiri, karena widget bawaannya memakai Material dari Flutter,
/// bukan `material_ui`.
const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/// Nama paket app untuk User-Agent ubin.
const String osmUserAgentPackage = 'id.my.iqbalfhz.denlydays';

/// Batas cache ubin di HP.
const int _tileCacheBytes = 200 * 1024 * 1024;

/// Pusat peta saat belum ada pin: Indonesia.
const LatLng defaultMapCenter = LatLng(-2.5, 118);
const double defaultMapZoom = 4;

/// Zoom saat menampilkan satu pin.
const double pinMapZoom = 15;

/// Batas zoom ubin OSM.
const double maxMapZoom = 19;

/// Penyedia ubin peta. Ditimpa di tes dengan ubin kosong, supaya tidak mengunduh dari internet.
final mapTileProviderProvider = Provider<TileProvider>(
  (ref) => NetworkTileProvider(
    cachingProvider: BuiltInMapCachingProvider.getOrCreateInstance(maxCacheSize: _tileCacheBytes),
  ),
);

LatLng latLngOf(GeoPoint point) => LatLng(point.latitude, point.longitude);

/// Gerakan peta penuh: geser, cubit, dan ketuk dua kali, tanpa memutar.
const int mapGestures = InteractiveFlag.all & ~InteractiveFlag.rotate;

/// Lapisan ubin OpenStreetMap.
class OsmTiles extends ConsumerWidget {
  const OsmTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => TileLayer(
    urlTemplate: osmTileUrl,
    userAgentPackageName: osmUserAgentPackage,
    tileProvider: ref.watch(mapTileProviderProvider),
    maxNativeZoom: maxMapZoom.toInt(),
  );
}

/// "© OpenStreetMap contributors" di pojok kiri bawah peta, wajib menurut kebijakan OSM.
class OsmAttribution extends StatelessWidget {
  const OsmAttribution({super.key});

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.bottomStart,
    child: Padding(
      padding: const EdgeInsets.all(AppDimens.gap6),
      child: DecoratedBox(
        decoration: BoxDecoration(color: context.palette.surface, borderRadius: BorderRadius.circular(AppDimens.gap6)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.gap6, vertical: AppDimens.gap2),
          child: Text(context.l10n.osmAttribution, style: context.text.small),
        ),
      ),
    ),
  );
}

/// Pin di peta: lingkaran warna `brand` bergaris `surface`, lebih besar saat dipilih.
class MapPin extends StatelessWidget {
  const MapPin({super.key, this.selected = false});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final size = selected ? AppDimens.mapPinSelected : AppDimens.mapPin;

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: palette.brand,
          shape: BoxShape.circle,
          border: Border.all(color: palette.surface, width: AppDimens.mapPinBorder),
          boxShadow: [BoxShadow(color: palette.scrim, blurRadius: AppDimens.gap4)],
        ),
      ),
    );
  }
}

/// Penanda satu pin, dengan area sentuh minimal 48.
Marker pinMarker(GeoPoint point, {bool selected = false, Widget? child}) => Marker(
  point: latLngOf(point),
  width: AppDimens.minTouch,
  height: AppDimens.minTouch,
  child: child ?? MapPin(selected: selected),
);

/// Peta kecil yang tidak bisa digeser, berisi satu pin. [onTap] membuka peta yang lebih besar.
class MemoryMapPreview extends StatelessWidget {
  const MemoryMapPreview({super.key, required this.point, required this.semanticLabel, this.onTap});

  final GeoPoint point;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    label: semanticLabel,
    excludeSemantics: true,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      child: SizedBox(
        height: AppDimens.mapPreviewHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FlutterMap(
              // Kunci per titik: pratinjau tidak bisa digeser, jadi pindah titik berarti peta baru.
              key: ValueKey(point),
              options: MapOptions(
                initialCenter: latLngOf(point),
                initialZoom: pinMapZoom,
                backgroundColor: context.palette.track,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                const OsmTiles(),
                MarkerLayer(markers: [pinMarker(point)]),
                const OsmAttribution(),
              ],
            ),
            if (onTap != null)
              Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onTap),
              ),
          ],
        ),
      ),
    ),
  );
}
