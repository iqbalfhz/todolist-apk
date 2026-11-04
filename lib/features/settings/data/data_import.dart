import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import '../../../core/api/api_transport.dart';
import '../../../core/database/entity_type.dart';
import '../../../core/database/local_store.dart';
import '../../../core/platform/device_platform.dart';
import '../../../core/sync/sync_engine.dart';
import '../../../core/utils/ulid.dart';
import '../../memories/data/memory_repository.dart';

/// Koleksi yang diimpor, induk lebih dulu (kontrak, bagian Impor data). Urutan yang sama dipakai
/// server untuk menyimpan isi satu request.
const List<String> importCollections = [
  'savings_goals',
  'trips',
  'task_lists',
  'tasks',
  'savings_entries',
  'special_dates',
  'memories',
];

/// Paling banyak baris dalam satu `POST /me/import`.
const int importPartRows = 1000;

/// Berkas ekspor yang dipilih untuk diimpor, sebelum diurai.
class PickedImportFile {
  const PickedImportFile({required this.name, required this.isZip, required this.json, this.photos = const {}});

  final String name;
  final bool isZip;

  /// Isi `data.json` di ZIP, atau isi berkas JSON; `null` kalau ZIP-nya tanpa `data.json`.
  final String? json;

  /// Foto kenangan di ZIP per ID foto di file, beserta letak salinannya di HP.
  final Map<String, String> photos;
}

/// Memilih berkas ekspor di HP (v1.x). Ditimpa di tes.
abstract interface class ImportFilePicker {
  /// Buka pemilih berkas Android. Foto dari ZIP disalin ke folder impor [token]. `null` kalau
  /// pemilihnya ditutup. Melempar [PlatformException] kalau berkasnya tidak bisa dibaca.
  Future<PickedImportFile?> pick(String token);

  /// Hapus salinan foto impor [token] yang tidak dibutuhkan lagi.
  Future<void> discard(String token);
}

/// [ImportFilePicker] lewat kanal `todolist/device` (`ImportFiles.kt`).
class DeviceImportFilePicker implements ImportFilePicker {
  const DeviceImportFilePicker(this.platform);

  final DevicePlatform platform;

  @override
  Future<PickedImportFile?> pick(String token) async {
    final raw = await platform.pickImportFile(token);
    if (raw == null) return null;
    return PickedImportFile(
      name: raw['name'] as String? ?? '',
      isZip: raw['kind'] == 'zip',
      json: raw['json'] as String?,
      photos: {
        for (final MapEntry(:key, :value) in (raw['photos'] as Map<Object?, Object?>? ?? const {}).entries)
          key.toString(): value.toString(),
      },
    );
  }

  @override
  Future<void> discard(String token) => platform.discardImport(token);
}

/// Kenapa berkas yang dipilih tidak bisa diimpor.
enum ImportFileProblem {
  /// Bukan file ekspor Denly Days, atau ZIP tanpa `data.json`.
  notExport,

  /// `format_version` lebih baru dari yang dikenal app ini.
  newerVersion,
}

class ImportFileInvalid implements Exception {
  const ImportFileInvalid(this.problem);

  final ImportFileProblem problem;
}

/// Urai isi file ekspor, dan pastikan `app` bernilai "Denly Days" dan `format_version` 1.
Map<String, dynamic> parseExportFile(String? raw) {
  if (raw == null) throw const ImportFileInvalid(ImportFileProblem.notExport);
  final Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } on FormatException {
    throw const ImportFileInvalid(ImportFileProblem.notExport);
  }
  if (decoded is! Map<String, dynamic> || decoded['app'] != 'Denly Days') {
    throw const ImportFileInvalid(ImportFileProblem.notExport);
  }
  final version = decoded['format_version'];
  if (version is int && version > 1) throw const ImportFileInvalid(ImportFileProblem.newerVersion);
  if (version != 1) throw const ImportFileInvalid(ImportFileProblem.notExport);
  return decoded;
}

/// Ruang di file ekspor beserta isinya yang bisa diimpor.
class ImportSpace {
  const ImportSpace({
    required this.id,
    required this.isShared,
    required this.otherMembers,
    required this.counts,
    required this.photos,
  });

  final String id;
  final bool isShared;

  /// Nama anggota selain pemilik file, untuk "Ruang Bersama dengan Sari".
  final List<String> otherMembers;

  /// Jumlah baris per koleksi di [importCollections].
  final Map<String, int> counts;

  /// Foto kenangan di ruang ini yang ada di ZIP.
  final int photos;

  int get rows => counts.values.fold(0, (sum, count) => sum + count);
}

List<Map<String, dynamic>> _rows(Map<String, dynamic> file, String key) => [
  for (final row in file[key] as List<dynamic>? ?? const [])
    if (row is Map<String, dynamic> && row['id'] is String && row['deleted_at'] == null) row,
];

/// Ruang di [file] yang punya isi, urut seperti di file, dengan jumlah isinya. [photos] adalah
/// foto kenangan yang ada di ZIP, per ID foto.
List<ImportSpace> importSpaces(Map<String, dynamic> file, {Map<String, String> photos = const {}}) {
  final ownerId = (file['user'] as Map<String, dynamic>?)?['id'];
  final memoriesById = {for (final memory in _rows(file, 'memories')) memory['id']: memory};

  final spaces = <ImportSpace>[];
  for (final space in file['spaces'] as List<dynamic>? ?? const []) {
    if (space is! Map<String, dynamic> || space['id'] is! String) continue;
    final id = space['id'] as String;
    final counts = {
      for (final key in importCollections) key: _rows(file, key).where((row) => row['space_id'] == id).length,
    };
    final photoCount = _rows(
      file,
      'memory_photos',
    ).where((photo) => photos.containsKey(photo['id']) && memoriesById[photo['memory_id']]?['space_id'] == id).length;
    final result = ImportSpace(
      id: id,
      isShared: space['type'] == 'shared',
      otherMembers: [
        for (final member in space['members'] as List<dynamic>? ?? const [])
          if (member is Map<String, dynamic> && member['id'] != ownerId && member['name'] is String)
            member['name'] as String,
      ],
      counts: counts,
      photos: photoCount,
    );
    if (result.rows > 0) spaces.add(result);
  }
  return spaces;
}

/// Satu `POST /me/import`: baris per koleksi, paling banyak [importPartRows].
class ImportPart {
  const ImportPart(this.rows);

  final Map<String, List<Map<String, dynamic>>> rows;

  int get size => rows.values.fold(0, (sum, rows) => sum + rows.length);

  Map<String, dynamic> toJson() => rows;

  factory ImportPart.fromJson(Map<String, dynamic> json) => ImportPart({
    for (final MapEntry(:key, :value) in json.entries)
      key: [for (final row in value as List<dynamic>) row as Map<String, dynamic>],
  });
}

/// Foto kenangan dari ZIP yang diunggah setelah semua bagian terkirim.
class ImportPhoto {
  const ImportPhoto({
    required this.id,
    required this.memoryId,
    required this.spaceId,
    required this.position,
    required this.takenAt,
    required this.width,
    required this.height,
    required this.path,
  });

  /// ID baru foto dan kenangannya.
  final String id;
  final String memoryId;
  final String spaceId;
  final num position;
  final String? takenAt;
  final int width;
  final int height;

  /// Salinan foto di HP, dari ZIP.
  final String path;

  Map<String, dynamic> toJson() => {
    'id': id,
    'memory_id': memoryId,
    'space_id': spaceId,
    'position': position,
    'taken_at': takenAt,
    'width': width,
    'height': height,
    'path': path,
  };

  factory ImportPhoto.fromJson(Map<String, dynamic> json) => ImportPhoto(
    id: json['id'] as String,
    memoryId: json['memory_id'] as String,
    spaceId: json['space_id'] as String,
    position: json['position'] as num,
    takenAt: json['taken_at'] as String?,
    width: json['width'] as int,
    height: json['height'] as int,
    path: json['path'] as String,
  );
}

/// Rencana impor (v1.x): semua baris dengan ID baru, dibagi per request, dan sampai mana sudah
/// terkirim. Disimpan di HP sampai selesai, supaya impor yang terputus dilanjutkan dengan ID
/// yang sama; server melewati ID yang sudah ada di ruang yang sama.
class ImportPlan {
  ImportPlan({
    required this.id,
    required this.fileName,
    required this.parts,
    required this.photos,
    this.next = 0,
    Map<String, int>? created,
    Map<String, int>? skipped,
  }) : created = created ?? {for (final key in importCollections) key: 0},
       skipped = skipped ?? {for (final key in importCollections) key: 0};

  /// ULID; juga nama folder foto impor di HP.
  final String id;
  final String fileName;
  final List<ImportPart> parts;
  final List<ImportPhoto> photos;

  /// Bagian berikutnya yang dikirim.
  int next;

  /// Jumlah baris yang dibuat dan dilewati server, per koleksi.
  final Map<String, int> created;
  final Map<String, int> skipped;

  bool get partsDone => next >= parts.length;

  int get rows => parts.fold(0, (sum, part) => sum + part.size);

  void count(Map<String, dynamic> result) {
    for (final (counts, key) in [(created, 'created'), (skipped, 'skipped')]) {
      final values = result[key];
      if (values is! Map) continue;
      for (final MapEntry(:key, :value) in values.entries) {
        if (value is int) counts[key.toString()] = (counts[key.toString()] ?? 0) + value;
      }
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'file_name': fileName,
    'parts': [for (final part in parts) part.toJson()],
    'photos': [for (final photo in photos) photo.toJson()],
    'next': next,
    'created': created,
    'skipped': skipped,
  };

  factory ImportPlan.fromJson(Map<String, dynamic> json) => ImportPlan(
    id: json['id'] as String,
    fileName: json['file_name'] as String,
    parts: [for (final part in json['parts'] as List<dynamic>) ImportPart.fromJson(part as Map<String, dynamic>)],
    photos: [for (final photo in json['photos'] as List<dynamic>) ImportPhoto.fromJson(photo as Map<String, dynamic>)],
    next: json['next'] as int,
    created: (json['created'] as Map<String, dynamic>).cast<String, int>(),
    skipped: (json['skipped'] as Map<String, dynamic>).cast<String, int>(),
  );
}

/// Kolom yang tidak perlu dikirim: diisi ulang server saat impor.
const Set<String> _serverOnly = {'updated_at', 'deleted_at'};

/// Buat rencana impor [file]: setiap baris di ruang yang punya tujuan di [destinations] (ruang di
/// file → ruangku) mendapat ID baru dari [newId], rujukannya (`task_list_id`, `savings_goal_id`,
/// `trip_id`, dan `next_task_id`) disesuaikan, dan `space_id`-nya diganti tujuannya. Ruang lain
/// dilewati. [photos] adalah foto kenangan di ZIP per ID foto; yang kenangannya ikut diimpor
/// diunggah sesudahnya.
ImportPlan planImport({
  required String id,
  required String fileName,
  required Map<String, dynamic> file,
  required Map<String, String> destinations,
  required String Function() newId,
  Map<String, String> photos = const {},
}) {
  final included = {
    for (final key in importCollections)
      key: [
        for (final row in _rows(file, key))
          if (destinations.containsKey(row['space_id'])) row,
      ],
  };

  // ID baru untuk semua baris dulu, supaya rujukan ke baris mana pun bisa disesuaikan.
  final ids = <String, String>{
    for (final rows in included.values)
      for (final row in rows) row['id'] as String: newId(),
  };
  String? mapped(Object? oldId) => ids[oldId];

  Map<String, dynamic> renamed(Map<String, dynamic> row, [Map<String, dynamic> references = const {}]) => {
    for (final MapEntry(:key, :value) in row.entries)
      if (!_serverOnly.contains(key)) key: value,
    'id': ids[row['id']],
    'space_id': destinations[row['space_id']],
    ...references,
  };

  final out = <String, List<Map<String, dynamic>>>{
    'savings_goals': [for (final row in included['savings_goals']!) renamed(row)],
    'trips': [
      for (final row in included['trips']!) renamed(row, {'savings_goal_id': mapped(row['savings_goal_id'])}),
    ],
    'task_lists': [
      for (final row in included['task_lists']!) renamed(row, {'trip_id': mapped(row['trip_id'])}),
    ],
    // Tugas tanpa daftarnya ditolak server, jadi tidak dikirim.
    'tasks': _nextTasksFirst([
      for (final row in included['tasks']!)
        if (mapped(row['task_list_id']) case final listId?)
          renamed(row, {'task_list_id': listId, 'next_task_id': mapped(row['next_task_id'])}),
    ]),
    'savings_entries': [
      for (final row in included['savings_entries']!)
        if (mapped(row['savings_goal_id']) case final goalId?) renamed(row, {'savings_goal_id': goalId}),
    ],
    'special_dates': [for (final row in included['special_dates']!) renamed(row)],
    'memories': [
      for (final row in included['memories']!) renamed(row, {'trip_id': mapped(row['trip_id'])}),
    ],
  };

  final parts = <ImportPart>[];
  var current = <String, List<Map<String, dynamic>>>{};
  var size = 0;
  for (final key in importCollections) {
    for (final row in out[key]!) {
      if (size == importPartRows) {
        parts.add(ImportPart(current));
        current = {};
        size = 0;
      }
      current.putIfAbsent(key, () => []).add(row);
      size++;
    }
  }
  if (size > 0) parts.add(ImportPart(current));

  final memorySpaces = {for (final memory in included['memories']!) memory['id']: memory['space_id']};
  final plannedPhotos = <ImportPhoto>[];
  for (final photo in _rows(file, 'memory_photos')) {
    final path = photos[photo['id']];
    final memoryId = mapped(photo['memory_id']);
    final spaceId = destinations[memorySpaces[photo['memory_id']]];
    if (path == null || memoryId == null || spaceId == null) continue;
    plannedPhotos.add(
      ImportPhoto(
        id: newId(),
        memoryId: memoryId,
        spaceId: spaceId,
        position: photo['position'] as num? ?? 0,
        takenAt: photo['taken_at'] as String?,
        width: photo['width'] as int? ?? 0,
        height: photo['height'] as int? ?? 0,
        path: path,
      ),
    );
  }

  return ImportPlan(id: id, fileName: fileName, parts: parts, photos: plannedPhotos);
}

/// Urutkan tugas supaya tugas berikutnya (`next_task_id`) selalu sebelum tugas sebelumnya. Server
/// hanya menautkan ke tugas yang sudah tersimpan, jadi tautannya tetap utuh walau rantainya
/// terbagi ke dua request.
List<Map<String, dynamic>> _nextTasksFirst(List<Map<String, dynamic>> tasks) {
  final byId = {for (final task in tasks) task['id'] as String: task};
  final placed = <String>{};
  final ordered = <Map<String, dynamic>>[];

  for (final task in tasks) {
    final chain = <Map<String, dynamic>>[];
    final seen = <String>{};
    Map<String, dynamic>? current = task;
    while (current != null && !placed.contains(current['id']) && seen.add(current['id'] as String)) {
      chain.add(current);
      current = byId[current['next_task_id']];
    }
    for (final item in chain.reversed) {
      placed.add(item['id'] as String);
      ordered.add(item);
    }
  }
  return ordered;
}

/// Impor data (v1.x): rencana disimpan di meta database akun sampai selesai, lalu dikirim lewat
/// `POST /me/import` per bagian, langsung dan tidak lewat antrean. Setelah bagian terakhir, sync
/// biasa mengambil hasilnya, dan foto dari ZIP masuk antrean unggah.
class ImportRepository {
  ImportRepository({required this.api, required this.store, required this.sync, required this.memories});

  final ApiTransport api;
  final LocalStore store;
  final SyncEngine sync;
  final MemoryRepository memories;

  /// Membaca salinan foto dari ZIP; `null` kalau sudah tidak ada. Ditimpa di tes widget, yang
  /// tidak bisa menunggu berkas sungguhan.
  Future<Uint8List?> Function(String path) readPhoto = _readFile;

  static Future<Uint8List?> _readFile(String path) async {
    final file = File(path);
    return await file.exists() ? file.readAsBytes() : null;
  }

  /// Rencana yang belum selesai, kalau ada.
  Future<ImportPlan?> pending() async {
    final raw = await store.meta(MetaKeys.importPlan);
    if (raw == null) return null;
    try {
      return ImportPlan.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      // Rencana yang rusak tidak bisa dilanjutkan.
      await store.setMeta(MetaKeys.importPlan, null);
      return null;
    }
  }

  Future<void> save(ImportPlan plan) => store.setMeta(MetaKeys.importPlan, jsonEncode(plan.toJson()));

  /// Lupakan rencana yang selesai atau dibatalkan.
  Future<void> forget() => store.setMeta(MetaKeys.importPlan, null);

  /// Kirim bagian yang belum terkirim, satu per satu, dan simpan kemajuannya setelah setiap
  /// bagian. Berhenti di antara bagian kalau [stopped]. Melempar `ApiError` (422 per baris,
  /// 429) dan `NetworkFailure` apa adanya; bagian yang gagal boleh langsung dikirim ulang.
  Future<void> send(ImportPlan plan, {void Function()? onProgress, bool Function()? stopped}) async {
    while (!plan.partsDone) {
      if (stopped?.call() ?? false) return;
      final response = await api.send('POST', '/me/import', body: plan.parts[plan.next].toJson());
      plan
        ..count(response.data)
        ..next += 1;
      await save(plan);
      onProgress?.call();
    }
  }

  /// Setelah semua bagian terkirim: sync biasa, lalu foto dari ZIP ke antrean unggah. Foto yang
  /// sudah ada di HP (impor sebelumnya terputus di sini) tidak dimasukkan dua kali. Mengembalikan
  /// jumlah foto yang menunggu diunggah.
  Future<int> finish(ImportPlan plan) async {
    try {
      await sync.sync();
    } on Object {
      // Hasilnya tetap sampai lewat sync berikutnya.
    }

    var queued = 0;
    for (final photo in plan.photos) {
      if (await store.read(EntityType.memoryPhoto, photo.id) != null) {
        queued++;
        continue;
      }
      final jpeg = await readPhoto(photo.path);
      if (jpeg == null) continue;
      await memories.importPhoto(
        id: photo.id,
        memoryId: photo.memoryId,
        spaceId: photo.spaceId,
        position: photo.position,
        takenAt: photo.takenAt,
        width: photo.width,
        height: photo.height,
        jpeg: jpeg,
      );
      queued++;
    }
    await forget();
    return queued;
  }
}

/// ULID baru untuk impor; dipisah supaya tes bisa memakai urutan yang pasti.
String newImportId() => newUlid();
