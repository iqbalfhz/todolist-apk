// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  color: json['color'] as String,
  timezone: json['timezone'] as String,
  locale: json['locale'] as String,
  defaultCurrency: json['default_currency'] as String,
  birthDate: json['birth_date'] as String?,
  notificationPrefs: NotificationPrefs.fromJson(json['notification_prefs'] as Map<String, dynamic>),
  avatarUrl: json['avatar_url'] as String?,
  avatarVersion: (json['avatar_version'] as num?)?.toInt() ?? 0,
  invitation: json['invitation'] == null ? null : Invitation.fromJson(json['invitation'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'color': instance.color,
  'timezone': instance.timezone,
  'locale': instance.locale,
  'default_currency': instance.defaultCurrency,
  'birth_date': instance.birthDate,
  'notification_prefs': instance.notificationPrefs.toJson(),
  'avatar_url': instance.avatarUrl,
  'avatar_version': instance.avatarVersion,
  'invitation': instance.invitation?.toJson(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

_NotificationPrefs _$NotificationPrefsFromJson(Map<String, dynamic> json) => _NotificationPrefs(
  taskReminders: json['task_reminders'] as bool? ?? true,
  partnerActivity: json['partner_activity'] as bool? ?? true,
  savingsActivity: json['savings_activity'] as bool? ?? true,
);

Map<String, dynamic> _$NotificationPrefsToJson(_NotificationPrefs instance) => <String, dynamic>{
  'task_reminders': instance.taskReminders,
  'partner_activity': instance.partnerActivity,
  'savings_activity': instance.savingsActivity,
};

_Invitation _$InvitationFromJson(Map<String, dynamic> json) =>
    _Invitation(code: json['code'] as String, expiresAt: DateTime.parse(json['expires_at'] as String));

Map<String, dynamic> _$InvitationToJson(_Invitation instance) => <String, dynamic>{
  'code': instance.code,
  'expires_at': instance.expiresAt.toIso8601String(),
};

_AuthResult _$AuthResultFromJson(Map<String, dynamic> json) =>
    _AuthResult(token: json['token'] as String, user: User.fromJson(json['user'] as Map<String, dynamic>));

Map<String, dynamic> _$AuthResultToJson(_AuthResult instance) => <String, dynamic>{
  'token': instance.token,
  'user': instance.user.toJson(),
};
