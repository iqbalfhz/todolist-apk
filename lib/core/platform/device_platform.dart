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

  /// Merek yang sering menghentikan app di latar belakang, jadi butuh panduan baterai.
  BatteryGuideBrand? get batteryGuideBrand {
    final names = '${manufacturer.toLowerCase()} ${brand.toLowerCase()}';
    if (names.contains('xiaomi') || names.contains('redmi') || names.contains('poco')) return BatteryGuideBrand.xiaomi;
    if (names.contains('realme')) return BatteryGuideBrand.realme;
    if (names.contains('oppo')) return BatteryGuideBrand.oppo;
    if (names.contains('vivo') || names.contains('iqoo')) return BatteryGuideBrand.vivo;
    return null;
  }
}

enum BatteryGuideBrand { xiaomi, oppo, vivo, realme }

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

  /// Buka pengaturan optimasi baterai. `false` kalau HP tidak punya layarnya.
  Future<bool> openBatterySettings() async {
    try {
      return await _channel.invokeMethod<bool>('openBatterySettings') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
