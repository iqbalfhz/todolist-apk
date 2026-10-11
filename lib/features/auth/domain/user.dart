import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Sumber user di kontrak: dipakai `GET /me`, `PATCH /me`, dan balasan daftar atau masuk.
@freezed
abstract class User with _$User {
  const User._();

  const factory User({
    required String id,
    required String name,
    required String email,
    required String color,
    required String timezone,
    required String locale,
    required String defaultCurrency,

    /// `YYYY-MM-DD`, atau `--MM-DD` kalau tahun tidak diisi.
    String? birthDate,
    required NotificationPrefs notificationPrefs,
    String? avatarUrl,
    @Default(0) int avatarVersion,

    /// Kode undangan yang masih berlaku, atau `null`.
    Invitation? invitation,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// Tiga kelompok preferensi notifikasi, sesuai switch di layar Pengaturan.
@freezed
abstract class NotificationPrefs with _$NotificationPrefs {
  const factory NotificationPrefs({
    @Default(true) bool taskReminders,
    @Default(true) bool partnerActivity,
    @Default(true) bool savingsActivity,
  }) = _NotificationPrefs;

  factory NotificationPrefs.fromJson(Map<String, dynamic> json) => _$NotificationPrefsFromJson(json);
}

/// Kode undangan: 6 karakter, berlaku 48 jam, sekali pakai.
@freezed
abstract class Invitation with _$Invitation {
  const Invitation._();

  const factory Invitation({required String code, required DateTime expiresAt}) = _Invitation;

  factory Invitation.fromJson(Map<String, dynamic> json) => _$InvitationFromJson(json);

  bool isActiveAt(DateTime now) => expiresAt.isAfter(now);
}

/// Balasan `POST /auth/register` dan `POST /auth/login`.
@freezed
abstract class AuthResult with _$AuthResult {
  const factory AuthResult({required String token, required User user}) = _AuthResult;

  factory AuthResult.fromJson(Map<String, dynamic> json) => _$AuthResultFromJson(json);
}
