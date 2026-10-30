import 'package:todolist/features/auth/data/google_accounts.dart';

/// Pilihan akun Google palsu (v1.x): setiap [pick] memakai hasil berikutnya di [results].
class FakeGoogleAccounts implements GoogleAccounts {
  FakeGoogleAccounts([List<Object?>? results]) : results = results ?? [];

  /// [GoogleIdentity], `null` (pilihan akun ditutup), atau [GoogleAccountsFailure] yang dilempar.
  /// Kalau habis, pilihan akun dianggap ditutup.
  final List<Object?> results;

  /// Berapa kali pilihan akun dibuka.
  int picks = 0;

  @override
  Future<GoogleIdentity?> pick() async {
    picks++;
    if (results.isEmpty) return null;
    final next = results.removeAt(0);
    if (next is GoogleAccountsFailure) throw next;
    return next as GoogleIdentity?;
  }
}
