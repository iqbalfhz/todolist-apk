import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../platform/device_platform.dart';

/// Foto yang sudah disiapkan untuk diunggah: JPEG dengan sisi terpanjang paling besar
/// [maxPhotoSide] px, tanpa EXIF.
class PreparedPhoto {
  const PreparedPhoto({required this.jpeg, required this.width, required this.height, this.takenAt});

  final Uint8List jpeg;
  final int width;
  final int height;

  /// Waktu foto diambil menurut EXIF berkas aslinya, dengan offset, misalnya
  /// "2027-06-20T10:12:45+07:00"; `null` kalau berkasnya tidak mencatatnya.
  final String? takenAt;
}

/// Sisi terpanjang foto kenangan yang diunggah (kontrak, bagian Foto kenangan).
const int maxPhotoSide = 2560;

/// Mutu JPEG hasil kompres; biasanya membuat foto 2560 px di bawah 1,5 MB.
const int photoQuality = 85;

/// Memilih foto dari galeri, lalu menyiapkannya untuk diunggah. Di tes diganti versi palsu.
abstract interface class PhotoPicker {
  /// Pilih paling banyak [limit] foto dari galeri. Kosong kalau dibatalkan.
  Future<List<String>> pickFromGallery({required int limit});

  /// Kecilkan dan kompres foto di [path]; `null` kalau berkasnya tidak bisa dibaca sebagai gambar.
  Future<PreparedPhoto?> prepare(String path);
}

/// [PhotoPicker] di atas image_picker, flutter_image_compress, dan EXIF dari kode native.
class DevicePhotoPicker implements PhotoPicker {
  const DevicePhotoPicker(this._platform);

  final DevicePlatform _platform;

  @override
  Future<List<String>> pickFromGallery({required int limit}) async {
    if (limit <= 0) return const [];
    final picker = ImagePicker();

    // pickMultiImage menolak batas di bawah 2.
    final files = limit == 1
        ? [?await picker.pickImage(source: ImageSource.gallery)]
        : await picker.pickMultiImage(limit: limit);
    return [for (final file in files) file.path];
  }

  @override
  Future<PreparedPhoto?> prepare(String path) async {
    final info = await _platform.photoInfo(path);
    if (info == null) return null;

    final plan = compressionPlan(info.width, info.height);
    final jpeg = await FlutterImageCompress.compressWithFile(
      path,
      minWidth: plan.target,
      minHeight: plan.target,
      quality: photoQuality,
      format: CompressFormat.jpeg,
      // EXIF tidak ikut diunggah, termasuk lokasinya; putarannya sudah diterapkan ke gambar.
      keepExif: false,
      inSampleSize: plan.sample,
    );
    if (jpeg == null) return null;

    final size = await _sizeOf(jpeg);
    return PreparedPhoto(
      jpeg: jpeg,
      width: size.width,
      height: size.height,
      takenAt: exifTakenAt(info.takenAt, info.offset),
    );
  }

  static Future<({int width, int height})> _sizeOf(Uint8List jpeg) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(jpeg);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final size = (width: descriptor.width, height: descriptor.height);
    descriptor.dispose();
    buffer.dispose();
    return size;
  }
}

/// Cara mengecilkan foto berukuran [width] × [height] supaya sisi terpanjangnya [maxPhotoSide].
///
/// flutter_image_compress memperkecil gambar dengan skala `min(w / minWidth, h / minHeight)`
/// (tidak pernah memperbesar), jadi [target] adalah sisi pendek hasilnya. [sample] membaca
/// berkasnya dalam ukuran 1/2, 1/4, dan seterusnya lebih dulu, supaya foto 200 MP tidak
/// memenuhi memori; hasil bacaannya tetap paling kecil [maxPhotoSide].
({int target, int sample}) compressionPlan(int width, int height) {
  final longest = math.max(width, height);
  final shortest = math.min(width, height);
  if (longest <= maxPhotoSide) return (target: shortest, sample: 1);

  var sample = 1;
  while (longest ~/ (sample * 2) >= maxPhotoSide) {
    sample *= 2;
  }
  return (target: (maxPhotoSide * shortest / longest).round(), sample: sample);
}

final RegExp _exifDateTime = RegExp(r'^(\d{4})[:\-](\d{2})[:\-](\d{2})[ T](\d{2}):(\d{2}):(\d{2})');
final RegExp _exifOffset = RegExp(r'^([+-])(\d{2}):(\d{2})$');

/// Ubah EXIF `DateTimeOriginal` ("2027:06:20 10:12:45") dan `OffsetTimeOriginal` ("+07:00")
/// menjadi waktu ISO 8601 dengan offset, untuk `taken_at`.
///
/// Tanpa offset di EXIF, waktunya dianggap waktu setempat HP ini pada tanggal itu.
/// Tanggal kosong atau tidak masuk akal ("0000:00:00 00:00:00") menghasilkan `null`.
String? exifTakenAt(String? dateTime, String? offset) {
  final match = _exifDateTime.firstMatch(dateTime?.trim() ?? '');
  if (match == null) return null;

  final parts = [for (var i = 1; i <= 6; i++) int.parse(match.group(i)!)];
  final (year, month, day, hour, minute, second) = (parts[0], parts[1], parts[2], parts[3], parts[4], parts[5]);
  final local = DateTime(year, month, day, hour, minute, second);
  final valid =
      year >= 1900 &&
      local.year == year &&
      local.month == month &&
      local.day == day &&
      local.hour == hour &&
      local.minute == minute &&
      local.second == second;
  if (!valid) return null;

  final explicit = _exifOffset.firstMatch(offset?.trim() ?? '');
  final String zone;
  if (explicit != null) {
    zone = '${explicit.group(1)}${explicit.group(2)}:${explicit.group(3)}';
  } else {
    final minutes = local.timeZoneOffset.inMinutes;
    final sign = minutes < 0 ? '-' : '+';
    zone = '$sign${_two(minutes.abs() ~/ 60)}:${_two(minutes.abs() % 60)}';
  }

  final date = '${year.toString().padLeft(4, '0')}-${_two(month)}-${_two(day)}';
  return '${date}T${_two(hour)}:${_two(minute)}:${_two(second)}$zone';
}

String _two(int value) => value.toString().padLeft(2, '0');
