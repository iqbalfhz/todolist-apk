import 'package:google_sign_in/google_sign_in.dart';

/// Akun Google yang dipilih di HP (v1.x): ID token untuk ditukar dengan token Denly Days di
/// server, dan email untuk disebut di layar.
class GoogleIdentity {
  const GoogleIdentity({required this.idToken, required this.email});

  final String idToken;
  final String email;
}

/// Memilih akun Google gagal di HP, bukan di server: Google Play Services, pengaturan klien
/// di Google Cloud, atau jaringan. [detail] hanya untuk log.
class GoogleAccountsFailure implements Exception {
  const GoogleAccountsFailure(this.detail);

  final String detail;

  @override
  String toString() => 'GoogleAccountsFailure: $detail';
}

/// Pilihan akun Google di HP. Ditimpa di tes.
abstract interface class GoogleAccounts {
  /// Membuka pilihan akun Google, lalu mengembalikan ID token akun yang dipilih, atau `null`
  /// kalau pengguna menutupnya.
  ///
  /// Melempar [GoogleAccountsFailure] untuk kegagalan lain.
  Future<GoogleIdentity?> pick();
}

/// [GoogleAccounts] lewat Credential Manager Android (paket `google_sign_in`).
///
/// App tidak menyimpan sesi Google: begitu ID token didapat, pilihan akunnya dilupakan, jadi
/// masuk berikutnya bertanya lagi akun mana yang dipakai.
class PlatformGoogleAccounts implements GoogleAccounts {
  PlatformGoogleAccounts({required this.serverClientId});

  /// Client ID klien Web. Server hanya menerima ID token yang diterbitkan untuk client ID ini.
  final String serverClientId;

  Future<void>? _initialized;

  @override
  Future<GoogleIdentity?> pick() async {
    final google = GoogleSignIn.instance;
    final GoogleSignInAccount account;
    try {
      await _initialize(google);
      account = await google.authenticate();
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return null;
      throw GoogleAccountsFailure('${error.code.name}: ${error.description}');
    } on Object catch (error) {
      // Kanal platform bermasalah atau plugin tidak tersedia.
      throw GoogleAccountsFailure('$error');
    }

    google.signOut().ignore();
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) throw const GoogleAccountsFailure('Google tidak memberi ID token');
    return GoogleIdentity(idToken: idToken, email: account.email);
  }

  /// `initialize` hanya boleh dipanggil sekali; yang gagal boleh diulang.
  Future<void> _initialize(GoogleSignIn google) async {
    final pending = _initialized ??= google.initialize(serverClientId: serverClientId);
    try {
      await pending;
    } on Object {
      _initialized = null;
      rethrow;
    }
  }
}
