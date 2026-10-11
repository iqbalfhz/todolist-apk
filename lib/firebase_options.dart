// PENGGANTI SEMENTARA.
//
// Jalankan `flutterfire configure --project=todolist-cb119` untuk menimpa file ini
// dengan konfigurasi Firebase yang sebenarnya (sekaligus membuat
// android/app/google-services.json). Sebelum itu, app tetap berjalan tanpa push.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform =>
      throw UnsupportedError('Firebase belum dikonfigurasi. Jalankan flutterfire configure.');
}
