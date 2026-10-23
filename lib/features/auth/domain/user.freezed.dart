// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

 String get id; String get name; String get email; String get color; String get timezone; String get locale; String get defaultCurrency;/// `YYYY-MM-DD`, atau `--MM-DD` kalau tahun tidak diisi.
 String? get birthDate; NotificationPrefs get notificationPrefs; String? get avatarUrl; int get avatarVersion;/// Kode undangan yang masih berlaku, atau `null`.
 Invitation? get invitation; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as User;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone)&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&(identical(other.defaultCurrency, _this.defaultCurrency) || other.defaultCurrency == _this.defaultCurrency)&&(identical(other.birthDate, _this.birthDate) || other.birthDate == _this.birthDate)&&(identical(other.notificationPrefs, _this.notificationPrefs) || other.notificationPrefs == _this.notificationPrefs)&&(identical(other.avatarUrl, _this.avatarUrl) || other.avatarUrl == _this.avatarUrl)&&(identical(other.avatarVersion, _this.avatarVersion) || other.avatarVersion == _this.avatarVersion)&&(identical(other.invitation, _this.invitation) || other.invitation == _this.invitation)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as User;
  return Object.hash(runtimeType,_this.id,_this.name,_this.email,_this.color,_this.timezone,_this.locale,_this.defaultCurrency,_this.birthDate,_this.notificationPrefs,_this.avatarUrl,_this.avatarVersion,_this.invitation,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as User;
  return 'User(id: ${_this.id}, name: ${_this.name}, email: ${_this.email}, color: ${_this.color}, timezone: ${_this.timezone}, locale: ${_this.locale}, defaultCurrency: ${_this.defaultCurrency}, birthDate: ${_this.birthDate}, notificationPrefs: ${_this.notificationPrefs}, avatarUrl: ${_this.avatarUrl}, avatarVersion: ${_this.avatarVersion}, invitation: ${_this.invitation}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email, String color, String timezone, String locale, String defaultCurrency, String? birthDate, NotificationPrefs notificationPrefs, String? avatarUrl, int avatarVersion, Invitation? invitation, DateTime createdAt, DateTime updatedAt
});


$NotificationPrefsCopyWith<$Res> get notificationPrefs;$InvitationCopyWith<$Res>? get invitation;

}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? color = null,Object? timezone = null,Object? locale = null,Object? defaultCurrency = null,Object? birthDate = freezed,Object? notificationPrefs = null,Object? avatarUrl = freezed,Object? avatarVersion = null,Object? invitation = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,defaultCurrency: null == defaultCurrency ? _self.defaultCurrency : defaultCurrency // ignore: cast_nullable_to_non_nullable
as String,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String?,notificationPrefs: null == notificationPrefs ? _self.notificationPrefs : notificationPrefs // ignore: cast_nullable_to_non_nullable
as NotificationPrefs,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,avatarVersion: null == avatarVersion ? _self.avatarVersion : avatarVersion // ignore: cast_nullable_to_non_nullable
as int,invitation: freezed == invitation ? _self.invitation : invitation // ignore: cast_nullable_to_non_nullable
as Invitation?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationPrefsCopyWith<$Res> get notificationPrefs {
  
  return $NotificationPrefsCopyWith<$Res>(_self.notificationPrefs, (value) {
    return _then(_self.copyWith(notificationPrefs: value));
  });
}/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InvitationCopyWith<$Res>? get invitation {
    if (_self.invitation == null) {
    return null;
  }

  return $InvitationCopyWith<$Res>(_self.invitation!, (value) {
    return _then(_self.copyWith(invitation: value));
  });
}
}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String color,  String timezone,  String locale,  String defaultCurrency,  String? birthDate,  NotificationPrefs notificationPrefs,  String? avatarUrl,  int avatarVersion,  Invitation? invitation,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.color,_that.timezone,_that.locale,_that.defaultCurrency,_that.birthDate,_that.notificationPrefs,_that.avatarUrl,_that.avatarVersion,_that.invitation,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String color,  String timezone,  String locale,  String defaultCurrency,  String? birthDate,  NotificationPrefs notificationPrefs,  String? avatarUrl,  int avatarVersion,  Invitation? invitation,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.name,_that.email,_that.color,_that.timezone,_that.locale,_that.defaultCurrency,_that.birthDate,_that.notificationPrefs,_that.avatarUrl,_that.avatarVersion,_that.invitation,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email,  String color,  String timezone,  String locale,  String defaultCurrency,  String? birthDate,  NotificationPrefs notificationPrefs,  String? avatarUrl,  int avatarVersion,  Invitation? invitation,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.color,_that.timezone,_that.locale,_that.defaultCurrency,_that.birthDate,_that.notificationPrefs,_that.avatarUrl,_that.avatarVersion,_that.invitation,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User extends User {
  const _User({required this.id, required this.name, required this.email, required this.color, required this.timezone, required this.locale, required this.defaultCurrency, this.birthDate, required this.notificationPrefs, this.avatarUrl, this.avatarVersion = 0, this.invitation, required this.createdAt, required this.updatedAt}): super._();
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  String id;
@override final  String name;
@override final  String email;
@override final  String color;
@override final  String timezone;
@override final  String locale;
@override final  String defaultCurrency;
/// `YYYY-MM-DD`, atau `--MM-DD` kalau tahun tidak diisi.
@override final  String? birthDate;
@override final  NotificationPrefs notificationPrefs;
@override final  String? avatarUrl;
@override@JsonKey() final  int avatarVersion;
/// Kode undangan yang masih berlaku, atau `null`.
@override final  Invitation? invitation;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.color, color) || other.color == color)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.defaultCurrency, defaultCurrency) || other.defaultCurrency == defaultCurrency)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.notificationPrefs, notificationPrefs) || other.notificationPrefs == notificationPrefs)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.avatarVersion, avatarVersion) || other.avatarVersion == avatarVersion)&&(identical(other.invitation, invitation) || other.invitation == invitation)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,email,color,timezone,locale,defaultCurrency,birthDate,notificationPrefs,avatarUrl,avatarVersion,invitation,createdAt,updatedAt);
}

@override
String toString() {
    return 'User(id: $id, name: $name, email: $email, color: $color, timezone: $timezone, locale: $locale, defaultCurrency: $defaultCurrency, birthDate: $birthDate, notificationPrefs: $notificationPrefs, avatarUrl: $avatarUrl, avatarVersion: $avatarVersion, invitation: $invitation, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email, String color, String timezone, String locale, String defaultCurrency, String? birthDate, NotificationPrefs notificationPrefs, String? avatarUrl, int avatarVersion, Invitation? invitation, DateTime createdAt, DateTime updatedAt
});


@override $NotificationPrefsCopyWith<$Res> get notificationPrefs;@override $InvitationCopyWith<$Res>? get invitation;

}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? color = null,Object? timezone = null,Object? locale = null,Object? defaultCurrency = null,Object? birthDate = freezed,Object? notificationPrefs = null,Object? avatarUrl = freezed,Object? avatarVersion = null,Object? invitation = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,defaultCurrency: null == defaultCurrency ? _self.defaultCurrency : defaultCurrency // ignore: cast_nullable_to_non_nullable
as String,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String?,notificationPrefs: null == notificationPrefs ? _self.notificationPrefs : notificationPrefs // ignore: cast_nullable_to_non_nullable
as NotificationPrefs,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,avatarVersion: null == avatarVersion ? _self.avatarVersion : avatarVersion // ignore: cast_nullable_to_non_nullable
as int,invitation: freezed == invitation ? _self.invitation : invitation // ignore: cast_nullable_to_non_nullable
as Invitation?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationPrefsCopyWith<$Res> get notificationPrefs {
  
  return $NotificationPrefsCopyWith<$Res>(_self.notificationPrefs, (value) {
    return _then(_self.copyWith(notificationPrefs: value));
  });
}/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InvitationCopyWith<$Res>? get invitation {
    if (_self.invitation == null) {
    return null;
  }

  return $InvitationCopyWith<$Res>(_self.invitation!, (value) {
    return _then(_self.copyWith(invitation: value));
  });
}
}


/// @nodoc
mixin _$NotificationPrefs {

 bool get taskReminders; bool get partnerActivity; bool get savingsActivity;/// Pengingat tanggal penting (v0.2). Bawaannya menyala, juga untuk akun yang
/// dibuat sebelum kunci ini ada.
 bool get specialDates;/// Pengingat perjalanan H-7 dan H-1 (v0.2). Bawaannya menyala.
 bool get tripReminders;/// Pengingat setor rutin per target (v0.2). Bawaannya menyala.
 bool get savingsReminders;
/// Create a copy of NotificationPrefs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPrefsCopyWith<NotificationPrefs> get copyWith => _$NotificationPrefsCopyWithImpl<NotificationPrefs>(this as NotificationPrefs, _$identity);

  /// Serializes this NotificationPrefs to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NotificationPrefs;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPrefs&&(identical(other.taskReminders, _this.taskReminders) || other.taskReminders == _this.taskReminders)&&(identical(other.partnerActivity, _this.partnerActivity) || other.partnerActivity == _this.partnerActivity)&&(identical(other.savingsActivity, _this.savingsActivity) || other.savingsActivity == _this.savingsActivity)&&(identical(other.specialDates, _this.specialDates) || other.specialDates == _this.specialDates)&&(identical(other.tripReminders, _this.tripReminders) || other.tripReminders == _this.tripReminders)&&(identical(other.savingsReminders, _this.savingsReminders) || other.savingsReminders == _this.savingsReminders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NotificationPrefs;
  return Object.hash(runtimeType,_this.taskReminders,_this.partnerActivity,_this.savingsActivity,_this.specialDates,_this.tripReminders,_this.savingsReminders);
}

@override
String toString() {
  final _this = this as NotificationPrefs;
  return 'NotificationPrefs(taskReminders: ${_this.taskReminders}, partnerActivity: ${_this.partnerActivity}, savingsActivity: ${_this.savingsActivity}, specialDates: ${_this.specialDates}, tripReminders: ${_this.tripReminders}, savingsReminders: ${_this.savingsReminders})';
}


}

/// @nodoc
abstract mixin class $NotificationPrefsCopyWith<$Res>  {
  factory $NotificationPrefsCopyWith(NotificationPrefs value, $Res Function(NotificationPrefs) _then) = _$NotificationPrefsCopyWithImpl;
@useResult
$Res call({
 bool taskReminders, bool partnerActivity, bool savingsActivity, bool specialDates, bool tripReminders, bool savingsReminders
});




}
/// @nodoc
class _$NotificationPrefsCopyWithImpl<$Res>
    implements $NotificationPrefsCopyWith<$Res> {
  _$NotificationPrefsCopyWithImpl(this._self, this._then);

  final NotificationPrefs _self;
  final $Res Function(NotificationPrefs) _then;

/// Create a copy of NotificationPrefs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taskReminders = null,Object? partnerActivity = null,Object? savingsActivity = null,Object? specialDates = null,Object? tripReminders = null,Object? savingsReminders = null,}) {
  return _then(NotificationPrefs(
taskReminders: null == taskReminders ? _self.taskReminders : taskReminders // ignore: cast_nullable_to_non_nullable
as bool,partnerActivity: null == partnerActivity ? _self.partnerActivity : partnerActivity // ignore: cast_nullable_to_non_nullable
as bool,savingsActivity: null == savingsActivity ? _self.savingsActivity : savingsActivity // ignore: cast_nullable_to_non_nullable
as bool,specialDates: null == specialDates ? _self.specialDates : specialDates // ignore: cast_nullable_to_non_nullable
as bool,tripReminders: null == tripReminders ? _self.tripReminders : tripReminders // ignore: cast_nullable_to_non_nullable
as bool,savingsReminders: null == savingsReminders ? _self.savingsReminders : savingsReminders // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationPrefs].
extension NotificationPrefsPatterns on NotificationPrefs {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPrefs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPrefs() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPrefs value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPrefs():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPrefs value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPrefs() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool taskReminders,  bool partnerActivity,  bool savingsActivity,  bool specialDates,  bool tripReminders,  bool savingsReminders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPrefs() when $default != null:
return $default(_that.taskReminders,_that.partnerActivity,_that.savingsActivity,_that.specialDates,_that.tripReminders,_that.savingsReminders);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool taskReminders,  bool partnerActivity,  bool savingsActivity,  bool specialDates,  bool tripReminders,  bool savingsReminders)  $default,) {final _that = this;
switch (_that) {
case _NotificationPrefs():
return $default(_that.taskReminders,_that.partnerActivity,_that.savingsActivity,_that.specialDates,_that.tripReminders,_that.savingsReminders);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool taskReminders,  bool partnerActivity,  bool savingsActivity,  bool specialDates,  bool tripReminders,  bool savingsReminders)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPrefs() when $default != null:
return $default(_that.taskReminders,_that.partnerActivity,_that.savingsActivity,_that.specialDates,_that.tripReminders,_that.savingsReminders);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationPrefs implements NotificationPrefs {
  const _NotificationPrefs({this.taskReminders = true, this.partnerActivity = true, this.savingsActivity = true, this.specialDates = true, this.tripReminders = true, this.savingsReminders = true});
  factory _NotificationPrefs.fromJson(Map<String, dynamic> json) => _$NotificationPrefsFromJson(json);

@override@JsonKey() final  bool taskReminders;
@override@JsonKey() final  bool partnerActivity;
@override@JsonKey() final  bool savingsActivity;
/// Pengingat tanggal penting (v0.2). Bawaannya menyala, juga untuk akun yang
/// dibuat sebelum kunci ini ada.
@override@JsonKey() final  bool specialDates;
/// Pengingat perjalanan H-7 dan H-1 (v0.2). Bawaannya menyala.
@override@JsonKey() final  bool tripReminders;
/// Pengingat setor rutin per target (v0.2). Bawaannya menyala.
@override@JsonKey() final  bool savingsReminders;

/// Create a copy of NotificationPrefs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPrefsCopyWith<_NotificationPrefs> get copyWith => __$NotificationPrefsCopyWithImpl<_NotificationPrefs>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationPrefsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPrefs&&(identical(other.taskReminders, taskReminders) || other.taskReminders == taskReminders)&&(identical(other.partnerActivity, partnerActivity) || other.partnerActivity == partnerActivity)&&(identical(other.savingsActivity, savingsActivity) || other.savingsActivity == savingsActivity)&&(identical(other.specialDates, specialDates) || other.specialDates == specialDates)&&(identical(other.tripReminders, tripReminders) || other.tripReminders == tripReminders)&&(identical(other.savingsReminders, savingsReminders) || other.savingsReminders == savingsReminders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,taskReminders,partnerActivity,savingsActivity,specialDates,tripReminders,savingsReminders);
}

@override
String toString() {
    return 'NotificationPrefs(taskReminders: $taskReminders, partnerActivity: $partnerActivity, savingsActivity: $savingsActivity, specialDates: $specialDates, tripReminders: $tripReminders, savingsReminders: $savingsReminders)';
}


}

/// @nodoc
abstract mixin class _$NotificationPrefsCopyWith<$Res> implements $NotificationPrefsCopyWith<$Res> {
  factory _$NotificationPrefsCopyWith(_NotificationPrefs value, $Res Function(_NotificationPrefs) _then) = __$NotificationPrefsCopyWithImpl;
@override @useResult
$Res call({
 bool taskReminders, bool partnerActivity, bool savingsActivity, bool specialDates, bool tripReminders, bool savingsReminders
});




}
/// @nodoc
class __$NotificationPrefsCopyWithImpl<$Res>
    implements _$NotificationPrefsCopyWith<$Res> {
  __$NotificationPrefsCopyWithImpl(this._self, this._then);

  final _NotificationPrefs _self;
  final $Res Function(_NotificationPrefs) _then;

/// Create a copy of NotificationPrefs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskReminders = null,Object? partnerActivity = null,Object? savingsActivity = null,Object? specialDates = null,Object? tripReminders = null,Object? savingsReminders = null,}) {
  return _then(_NotificationPrefs(
taskReminders: null == taskReminders ? _self.taskReminders : taskReminders // ignore: cast_nullable_to_non_nullable
as bool,partnerActivity: null == partnerActivity ? _self.partnerActivity : partnerActivity // ignore: cast_nullable_to_non_nullable
as bool,savingsActivity: null == savingsActivity ? _self.savingsActivity : savingsActivity // ignore: cast_nullable_to_non_nullable
as bool,specialDates: null == specialDates ? _self.specialDates : specialDates // ignore: cast_nullable_to_non_nullable
as bool,tripReminders: null == tripReminders ? _self.tripReminders : tripReminders // ignore: cast_nullable_to_non_nullable
as bool,savingsReminders: null == savingsReminders ? _self.savingsReminders : savingsReminders // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Invitation {

 String get code; DateTime get expiresAt;
/// Create a copy of Invitation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvitationCopyWith<Invitation> get copyWith => _$InvitationCopyWithImpl<Invitation>(this as Invitation, _$identity);

  /// Serializes this Invitation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Invitation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Invitation&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Invitation;
  return Object.hash(runtimeType,_this.code,_this.expiresAt);
}

@override
String toString() {
  final _this = this as Invitation;
  return 'Invitation(code: ${_this.code}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $InvitationCopyWith<$Res>  {
  factory $InvitationCopyWith(Invitation value, $Res Function(Invitation) _then) = _$InvitationCopyWithImpl;
@useResult
$Res call({
 String code, DateTime expiresAt
});




}
/// @nodoc
class _$InvitationCopyWithImpl<$Res>
    implements $InvitationCopyWith<$Res> {
  _$InvitationCopyWithImpl(this._self, this._then);

  final Invitation _self;
  final $Res Function(Invitation) _then;

/// Create a copy of Invitation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? expiresAt = null,}) {
  return _then(Invitation(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Invitation].
extension InvitationPatterns on Invitation {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Invitation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Invitation() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Invitation value)  $default,){
final _that = this;
switch (_that) {
case _Invitation():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Invitation value)?  $default,){
final _that = this;
switch (_that) {
case _Invitation() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Invitation() when $default != null:
return $default(_that.code,_that.expiresAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _Invitation():
return $default(_that.code,_that.expiresAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _Invitation() when $default != null:
return $default(_that.code,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Invitation extends Invitation {
  const _Invitation({required this.code, required this.expiresAt}): super._();
  factory _Invitation.fromJson(Map<String, dynamic> json) => _$InvitationFromJson(json);

@override final  String code;
@override final  DateTime expiresAt;

/// Create a copy of Invitation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvitationCopyWith<_Invitation> get copyWith => __$InvitationCopyWithImpl<_Invitation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvitationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Invitation&&(identical(other.code, code) || other.code == code)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,expiresAt);
}

@override
String toString() {
    return 'Invitation(code: $code, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$InvitationCopyWith<$Res> implements $InvitationCopyWith<$Res> {
  factory _$InvitationCopyWith(_Invitation value, $Res Function(_Invitation) _then) = __$InvitationCopyWithImpl;
@override @useResult
$Res call({
 String code, DateTime expiresAt
});




}
/// @nodoc
class __$InvitationCopyWithImpl<$Res>
    implements _$InvitationCopyWith<$Res> {
  __$InvitationCopyWithImpl(this._self, this._then);

  final _Invitation _self;
  final $Res Function(_Invitation) _then;

/// Create a copy of Invitation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? expiresAt = null,}) {
  return _then(_Invitation(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$AuthResult {

 String get token; User get user;
/// Create a copy of AuthResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthResultCopyWith<AuthResult> get copyWith => _$AuthResultCopyWithImpl<AuthResult>(this as AuthResult, _$identity);

  /// Serializes this AuthResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuthResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthResult&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.user, _this.user) || other.user == _this.user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuthResult;
  return Object.hash(runtimeType,_this.token,_this.user);
}

@override
String toString() {
  final _this = this as AuthResult;
  return 'AuthResult(token: ${_this.token}, user: ${_this.user})';
}


}

/// @nodoc
abstract mixin class $AuthResultCopyWith<$Res>  {
  factory $AuthResultCopyWith(AuthResult value, $Res Function(AuthResult) _then) = _$AuthResultCopyWithImpl;
@useResult
$Res call({
 String token, User user
});


$UserCopyWith<$Res> get user;

}
/// @nodoc
class _$AuthResultCopyWithImpl<$Res>
    implements $AuthResultCopyWith<$Res> {
  _$AuthResultCopyWithImpl(this._self, this._then);

  final AuthResult _self;
  final $Res Function(AuthResult) _then;

/// Create a copy of AuthResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? user = null,}) {
  return _then(AuthResult(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,
  ));
}
/// Create a copy of AuthResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthResult].
extension AuthResultPatterns on AuthResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthResult value)  $default,){
final _that = this;
switch (_that) {
case _AuthResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthResult value)?  $default,){
final _that = this;
switch (_that) {
case _AuthResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  User user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthResult() when $default != null:
return $default(_that.token,_that.user);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  User user)  $default,) {final _that = this;
switch (_that) {
case _AuthResult():
return $default(_that.token,_that.user);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  User user)?  $default,) {final _that = this;
switch (_that) {
case _AuthResult() when $default != null:
return $default(_that.token,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthResult implements AuthResult {
  const _AuthResult({required this.token, required this.user});
  factory _AuthResult.fromJson(Map<String, dynamic> json) => _$AuthResultFromJson(json);

@override final  String token;
@override final  User user;

/// Create a copy of AuthResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthResultCopyWith<_AuthResult> get copyWith => __$AuthResultCopyWithImpl<_AuthResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthResult&&(identical(other.token, token) || other.token == token)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,token,user);
}

@override
String toString() {
    return 'AuthResult(token: $token, user: $user)';
}


}

/// @nodoc
abstract mixin class _$AuthResultCopyWith<$Res> implements $AuthResultCopyWith<$Res> {
  factory _$AuthResultCopyWith(_AuthResult value, $Res Function(_AuthResult) _then) = __$AuthResultCopyWithImpl;
@override @useResult
$Res call({
 String token, User user
});


@override $UserCopyWith<$Res> get user;

}
/// @nodoc
class __$AuthResultCopyWithImpl<$Res>
    implements _$AuthResultCopyWith<$Res> {
  __$AuthResultCopyWithImpl(this._self, this._then);

  final _AuthResult _self;
  final $Res Function(_AuthResult) _then;

/// Create a copy of AuthResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? user = null,}) {
  return _then(_AuthResult(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,
  ));
}

/// Create a copy of AuthResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
