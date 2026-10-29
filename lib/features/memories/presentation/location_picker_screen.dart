import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/api/api_error.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../home/presentation/main_shell.dart';
import '../domain/memory.dart';
import 'memory_map.dart';

/// Hasil layar Pilih lokasi.
sealed class PinChoice {
  const PinChoice();
}

/// Pin dipasang di [point]. [placeName] diisi kalau titiknya dipilih dari hasil pencarian.
class PinSet extends PinChoice {
  const PinSet(this.point, {this.placeName});

  final GeoPoint point;
  final String? placeName;
}

/// Pin dilepas.
class PinCleared extends PinChoice {
  const PinCleared();
}

/// Buka Pilih lokasi di atas layar sekarang. `null` kalau ditutup tanpa memilih.
Future<PinChoice?> pickLocation(BuildContext context, {GeoPoint? current}) => Navigator.of(context)
    .push<PinChoice>(MaterialPageRoute(fullscreenDialog: true, builder: (_) => LocationPickerScreen(current: current)));

/// Panjang kata kunci cari tempat menurut kontrak.
const int placeQueryMin = 3;
const int placeQueryMax = 100;

/// Pilih lokasi (v1.x): cari tempat lewat tombol Cari (bukan sambil mengetik, karena kebijakan
/// Nominatim melarang autocomplete), atau ketuk peta untuk memasang pin. Pin manual tetap
/// bisa dipasang walau pencarian sedang tidak tersedia atau HP offline.
class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key, this.current});

  /// Pin yang sudah ada; menampilkan tombol Lepas pin.
  final GeoPoint? current;

  @override
  ConsumerState<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  final TextEditingController _query = TextEditingController();
  final MapController _map = MapController();
  late GeoPoint? _point = widget.current;
  String? _placeName;

  /// `null` sebelum mencari; daftar kosong kalau tidak ada yang cocok.
  List<Place>? _results;
  String? _searchedFor;
  String? _error;
  bool _searching = false;

  @override
  void dispose() {
    _query.dispose();
    _map.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final l10n = context.l10n;
    final query = _query.text.trim();
    FocusScope.of(context).unfocus();

    if (textLength(query) < placeQueryMin) {
      return setState(() {
        _error = l10n.pickerQueryShort(placeQueryMin);
        _results = null;
      });
    }

    final account = ref.read(accountProvider);
    if (account == null || _searching) return;
    setState(() {
      _searching = true;
      _error = null;
    });

    try {
      final results = await account.memories.searchPlaces(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _searchedFor = query;
      });
    } on ApiError catch (error) {
      if (!mounted) return;
      setState(() {
        _results = null;
        // 503 places_unavailable dan 422 membawa pesan dari server yang siap ditampilkan.
        _error = error.code == ApiErrorCode.tooManyRequests ? l10n.pickerTooOften : error.message;
      });
    } on NetworkFailure {
      if (!mounted) return;
      setState(() {
        _results = null;
        _error = l10n.pickerOffline;
      });
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _choose(Place place) {
    final point = GeoPoint.tryCreate(place.point.latitude, place.point.longitude);
    if (point == null) return;
    setState(() {
      _point = point;
      _placeName = place.name.isEmpty ? null : place.name;
      _results = null;
    });
    _map.move(latLngOf(point), pinMapZoom);
  }

  void _tapMap(LatLng position) {
    final point = GeoPoint.tryCreate(position.latitude, position.longitude);
    if (point == null) return;
    setState(() {
      _point = point;
      // Titik digeser sendiri: nama tempat dari pencarian tidak lagi pasti benar.
      _placeName = null;
      _results = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final point = _point;
    final initial = widget.current;
    final results = _results;
    final error = _error;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return AppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pageSide - AppDimens.gap10,
              AppDimens.gap12,
              AppDimens.pageSide,
              AppDimens.gap8,
            ),
            child: Row(
              children: [
                BackIconButton(label: l10n.commonBack, onPressed: () => Navigator.of(context).pop()),
                const SizedBox(width: AppDimens.gap4),
                Expanded(
                  child: Semantics(header: true, child: Text(l10n.pickerTitle, style: text.screenTitle)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.pageSide),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _query,
                    style: text.input,
                    textInputAction: TextInputAction.search,
                    inputFormatters: [LengthLimitingTextInputFormatter(placeQueryMax)],
                    decoration: InputDecoration(hintText: l10n.pickerSearchHint),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: AppDimens.gap8),
                AppIconButton(
                  icon: Symbols.search_rounded,
                  label: l10n.pickerSearch,
                  outlined: true,
                  onPressed: _searching ? null : _search,
                ),
              ],
            ),
          ),
          // Hasil dan peta berbagi sisa ruang, supaya keduanya tetap muat saat keyboard terbuka
          // atau huruf diperbesar; daftar hasil bisa digulir.
          if (_searching || error != null || results != null)
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppDimens.pageSide, AppDimens.gap8, AppDimens.pageSide, 0),
                child: Semantics(
                  liveRegion: true,
                  child: results != null && !_searching && error == null
                      ? _ResultList(results: results, query: _searchedFor ?? '', onChoose: _choose)
                      : SingleChildScrollView(
                          child: _searching
                              ? const SkeletonCard(lines: 2)
                              : StatusText(text: error!, icon: Symbols.info_rounded, color: palette.muted),
                        ),
                ),
              ),
            ),
          const SizedBox(height: AppDimens.gap8),
          Expanded(
            flex: 3,
            child: Semantics(
              label: l10n.pickerMapSemantic,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FlutterMap(
                    mapController: _map,
                    options: MapOptions(
                      initialCenter: point == null ? defaultMapCenter : latLngOf(point),
                      initialZoom: point == null ? defaultMapZoom : pinMapZoom,
                      maxZoom: maxMapZoom,
                      backgroundColor: palette.track,
                      interactionOptions: const InteractionOptions(flags: mapGestures),
                      onTap: (_, position) => _tapMap(position),
                    ),
                    children: [
                      const OsmTiles(),
                      if (point != null) MarkerLayer(markers: [pinMarker(point, selected: true)]),
                      const OsmAttribution(),
                    ],
                  ),
                  if (point == null)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimens.gap10),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: palette.surface,
                            borderRadius: BorderRadius.circular(AppDimens.chipHeight / 2),
                            border: Border.all(color: palette.line, width: AppDimens.borderWidth),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.chipSidePadding,
                              vertical: AppDimens.gap8,
                            ),
                            child: Text(l10n.pickerTapHint, style: text.captionStrong),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Tertutup keyboard selama mengetik; muncul lagi setelah Cari atau keyboard ditutup.
          if (!keyboardOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.pageSide,
                AppDimens.gap12,
                AppDimens.pageSide,
                AppDimens.gap12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryButton(
                    label: l10n.pickerUse,
                    icon: Symbols.check_rounded,
                    onPressed: point == null
                        ? null
                        : () => Navigator.of(context).pop(PinSet(point, placeName: _placeName)),
                  ),
                  if (initial != null)
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(const PinCleared()),
                      style: TextButton.styleFrom(foregroundColor: palette.danger),
                      icon: const Icon(Symbols.location_off_rounded, size: AppDimens.iconMd),
                      label: Text(l10n.memoryPinRemove),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Hasil cari tempat: nama dan alamat, lalu atribusi OpenStreetMap yang wajib tampil.
class _ResultList extends StatelessWidget {
  const _ResultList({required this.results, required this.query, required this.onChoose});

  final List<Place> results;
  final String query;
  final ValueChanged<Place> onChoose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (results.isEmpty)
          Flexible(
            child: SingleChildScrollView(
              child: StatusText(
                text: l10n.pickerNoResults(query),
                icon: Symbols.search_off_rounded,
                color: context.palette.muted,
              ),
            ),
          )
        else
          Flexible(
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.cardPadding),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  for (final (index, place) in results.indexed) ...[
                    if (index > 0) const RowDivider(),
                    MergeSemantics(
                      child: Semantics(
                        button: true,
                        child: InkWell(
                          onTap: () => onChoose(place),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: AppDimens.rowMinHeight),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppDimens.gap8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(place.name, style: text.bodyStrong),
                                  if (place.address.isNotEmpty) Text(place.address, style: text.small),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        const SizedBox(height: AppDimens.gap4),
        Text(l10n.osmAttribution, style: text.small),
      ],
    );
  }
}
