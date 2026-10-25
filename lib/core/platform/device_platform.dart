import 'package:flutter/services.dart';

/// Info HP dari sisi Android (`MainActivity.kt`).
class DeviceInfo {
  const DeviceInfo({required this.manufacturer, required this.brand, required this.model, required this.sdkInt});

  /// Dipakai kalau kanal native tidak tersedia (misalnya di tes).
  static const DeviceInfo unknown = DeviceInfo(manufacturer: '', brand: '', model: 'Android', sdkInt: 0);

  final String manufacturer;
  final String brand;
  final String model;
  final int sdkInt;

  /// Nama HP untuk `device_name` saat daftar dan masuk, misalnya "Xiaomi Redmi Note 13".
  String get name {
    final maker = manufacturer.isEmpty ? '' : manufacturer[0].toUpperCase() + manufacturer.substring(1);
    if (maker.isEmpty || model.toLowerCase().startsWith(maker.toLowerCase())) return model;
    return '$maker $model';
  }

  /// Izin notifikasi baru diminta saat berjalan mulai Android 13 (API 33).
  bool get needsNotificationPermission => sdkInt >= 33;
}

/// Kanal ke kode native untuk hal yang tidak punya paket di Stack.
class DevicePlatform {
  const DevicePlatform();

  static const MethodChannel _channel = MethodChannel('todolist/device');

  Future<DeviceInfo> info() async {
    try {
      final raw = await _channel.invokeMapMethod<String, dynamic>('info');
      if (raw == null) return DeviceInfo.unknown;
      return DeviceInfo(
        manufacturer: raw['manufacturer'] as String? ?? '',
        brand: raw['brand'] as String? ?? '',
        model: raw['model'] as String? ?? 'Android',
        sdkInt: raw['sdkInt'] as int? ?? 0,
      );
    } on MissingPluginException {
      return DeviceInfo.unknown;
    } on PlatformException {
      return DeviceInfo.unknown;
    }
  }

  /// Ukuran asli dan waktu pengambilan foto di [path], dibaca sebelum fotonya dikompres.
  /// `null` kalau berkasnya bukan gambar yang bisa dibaca HP ini.
  Future<PhotoInfo?> photoInfo(String path) async {
    try {
      final raw = await _channel.invokeMapMethod<String, dynamic>('photoInfo', {'path': path});
      if (raw == null) return null;
      return PhotoInfo(
        width: raw['width'] as int? ?? 0,
        height: raw['height'] as int? ?? 0,
        takenAt: raw['takenAt'] as String?,
        offset: raw['offset'] as String?,
      );
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  /// Kirim ringkasan baru ke widget "Tugas hari ini" di layar utama (v1.x). Gagal diam-diam
  /// di tempat tanpa kanal native, misalnya di tes.
  Future<void> updateWidget(String json) async {
    try {
      await _channel.invokeMethod<void>('updateWidget', {'json': json});
    } on MissingPluginException {
      // Tanpa widget.
    } on PlatformException {
      // Widget tetap memakai ringkasan sebelumnya.
    }
  }

  /// Minta launcher menyematkan widget "Tugas hari ini". `false` kalau launcher tidak
  /// mendukungnya, jadi pengguna perlu menambahkannya sendiri dari layar utama.
  Future<bool> pinWidget() async {
    try {
      return await _channel.invokeMethod<bool>('pinWidget') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}

/// Isi `photoInfo` dari `MainActivity.kt`.
class PhotoInfo {
  const PhotoInfo({required this.width, required this.height, this.takenAt, this.offset});

  /// Ukuran berkas asli, sebelum diputar menurut EXIF.
  final int width;
  final int height;

  /// EXIF `DateTimeOriginal` apa adanya, misalnya "2027:06:20 10:12:45".
  final String? takenAt;

  /// EXIF `OffsetTimeOriginal`, misalnya "+07:00".
  final String? offset;
}
