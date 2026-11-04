/// Ukuran berkas untuk pengguna: "850 KB", "120 MB", "1,2 GB". Dibulatkan ke atas, supaya
/// perkiraan ruang yang dibutuhkan tidak pernah terlalu kecil.
String formatFileSize(int bytes) {
  const kilo = 1024;
  const mega = kilo * 1024;
  const giga = mega * 1024;

  if (bytes >= giga) {
    final tenths = (bytes * 10 / giga).ceil();
    return tenths % 10 == 0 ? '${tenths ~/ 10} GB' : '${tenths ~/ 10},${tenths % 10} GB';
  }
  if (bytes >= mega) return '${(bytes / mega).ceil()} MB';
  return '${(bytes / kilo).ceil().clamp(1, 1024)} KB';
}
