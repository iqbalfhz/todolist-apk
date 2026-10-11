import 'dart:math';

/// Alfabet Crockford Base32 huruf kecil. Server menolak ULID huruf besar.
const String _alphabet = '0123456789abcdefghjkmnpqrstvwxyz';

final Random _secureRandom = Random.secure();

/// Bentuk ULID yang diterima API: 26 karakter Crockford huruf kecil.
final RegExp ulidPattern = RegExp(r'^[0-7][0-9a-hjkmnp-tv-z]{25}$');

/// Buat ULID huruf kecil: 48 bit waktu (milidetik) lalu 80 bit acak.
///
/// ID daftar, tugas, target, dan setoran dibuat di HP dengan fungsi ini,
/// supaya kunci di SQLite sama dengan di server.
String newUlid({DateTime? now, Random? random}) {
  final rng = random ?? _secureRandom;
  var time = (now ?? DateTime.now()).millisecondsSinceEpoch;
  final chars = List<String>.filled(26, '0');

  for (var i = 9; i >= 0; i--) {
    chars[i] = _alphabet[time % 32];
    time ~/= 32;
  }
  for (var i = 10; i < 26; i++) {
    chars[i] = _alphabet[rng.nextInt(32)];
  }

  return chars.join();
}
