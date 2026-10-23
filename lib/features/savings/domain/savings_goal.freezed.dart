// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'savings_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavingsGoal {

 String get id; String get spaceId; String get name; String? get emoji; int get targetAmount; String get currency;/// `YYYY-MM-DD`; dipakai untuk menghitung setoran per minggu yang dibutuhkan.
 String? get targetDate;/// Pengingat setor rutin (v0.2): `weekly`, `monthly`, atau `null` (tanpa pengingat).
 String? get reminderFrequency;/// 1–7 untuk mingguan (1 = Senin), 1–31 untuk bulanan.
 int? get reminderDay; DateTime? get achievedAt; DateTime? get archivedAt; String? get createdBy; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SavingsGoal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavingsGoalCopyWith<SavingsGoal> get copyWith => _$SavingsGoalCopyWithImpl<SavingsGoal>(this as SavingsGoal, _$identity);

  /// Serializes this SavingsGoal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SavingsGoal;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavingsGoal&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.spaceId, _this.spaceId) || other.spaceId == _this.spaceId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.emoji, _this.emoji) || other.emoji == _this.emoji)&&(identical(other.targetAmount, _this.targetAmount) || other.targetAmount == _this.targetAmount)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.targetDate, _this.targetDate) || other.targetDate == _this.targetDate)&&(identical(other.reminderFrequency, _this.reminderFrequency) || other.reminderFrequency == _this.reminderFrequency)&&(identical(other.reminderDay, _this.reminderDay) || other.reminderDay == _this.reminderDay)&&(identical(other.achievedAt, _this.achievedAt) || other.achievedAt == _this.achievedAt)&&(identical(other.archivedAt, _this.archivedAt) || other.archivedAt == _this.archivedAt)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SavingsGoal;
  return Object.hash(runtimeType,_this.id,_this.spaceId,_this.name,_this.emoji,_this.targetAmount,_this.currency,_this.targetDate,_this.reminderFrequency,_this.reminderDay,_this.achievedAt,_this.archivedAt,_this.createdBy,_this.createdAt,_this.updatedAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as SavingsGoal;
  return 'SavingsGoal(id: ${_this.id}, spaceId: ${_this.spaceId}, name: ${_this.name}, emoji: ${_this.emoji}, targetAmount: ${_this.targetAmount}, currency: ${_this.currency}, targetDate: ${_this.targetDate}, reminderFrequency: ${_this.reminderFrequency}, reminderDay: ${_this.reminderDay}, achievedAt: ${_this.achievedAt}, archivedAt: ${_this.archivedAt}, createdBy: ${_this.createdBy}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $SavingsGoalCopyWith<$Res>  {
  factory $SavingsGoalCopyWith(SavingsGoal value, $Res Function(SavingsGoal) _then) = _$SavingsGoalCopyWithImpl;
@useResult
$Res call({
 String id, String spaceId, String name, String? emoji, int targetAmount, String currency, String? targetDate, String? reminderFrequency, int? reminderDay, DateTime? achievedAt, DateTime? archivedAt, String? createdBy, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SavingsGoalCopyWithImpl<$Res>
    implements $SavingsGoalCopyWith<$Res> {
  _$SavingsGoalCopyWithImpl(this._self, this._then);

  final SavingsGoal _self;
  final $Res Function(SavingsGoal) _then;

/// Create a copy of SavingsGoal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? spaceId = null,Object? name = null,Object? emoji = freezed,Object? targetAmount = null,Object? currency = null,Object? targetDate = freezed,Object? reminderFrequency = freezed,Object? reminderDay = freezed,Object? achievedAt = freezed,Object? archivedAt = freezed,Object? createdBy = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(SavingsGoal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as String?,reminderFrequency: freezed == reminderFrequency ? _self.reminderFrequency : reminderFrequency // ignore: cast_nullable_to_non_nullable
as String?,reminderDay: freezed == reminderDay ? _self.reminderDay : reminderDay // ignore: cast_nullable_to_non_nullable
as int?,achievedAt: freezed == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SavingsGoal].
extension SavingsGoalPatterns on SavingsGoal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavingsGoal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavingsGoal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavingsGoal value)  $default,){
final _that = this;
switch (_that) {
case _SavingsGoal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavingsGoal value)?  $default,){
final _that = this;
switch (_that) {
case _SavingsGoal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String spaceId,  String name,  String? emoji,  int targetAmount,  String currency,  String? targetDate,  String? reminderFrequency,  int? reminderDay,  DateTime? achievedAt,  DateTime? archivedAt,  String? createdBy,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavingsGoal() when $default != null:
return $default(_that.id,_that.spaceId,_that.name,_that.emoji,_that.targetAmount,_that.currency,_that.targetDate,_that.reminderFrequency,_that.reminderDay,_that.achievedAt,_that.archivedAt,_that.createdBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String spaceId,  String name,  String? emoji,  int targetAmount,  String currency,  String? targetDate,  String? reminderFrequency,  int? reminderDay,  DateTime? achievedAt,  DateTime? archivedAt,  String? createdBy,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SavingsGoal():
return $default(_that.id,_that.spaceId,_that.name,_that.emoji,_that.targetAmount,_that.currency,_that.targetDate,_that.reminderFrequency,_that.reminderDay,_that.achievedAt,_that.archivedAt,_that.createdBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String spaceId,  String name,  String? emoji,  int targetAmount,  String currency,  String? targetDate,  String? reminderFrequency,  int? reminderDay,  DateTime? achievedAt,  DateTime? archivedAt,  String? createdBy,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SavingsGoal() when $default != null:
return $default(_that.id,_that.spaceId,_that.name,_that.emoji,_that.targetAmount,_that.currency,_that.targetDate,_that.reminderFrequency,_that.reminderDay,_that.achievedAt,_that.archivedAt,_that.createdBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavingsGoal extends SavingsGoal {
  const _SavingsGoal({required this.id, required this.spaceId, required this.name, this.emoji, required this.targetAmount, required this.currency, this.targetDate, this.reminderFrequency, this.reminderDay, this.achievedAt, this.archivedAt, this.createdBy, required this.createdAt, required this.updatedAt, this.deletedAt}): super._();
  factory _SavingsGoal.fromJson(Map<String, dynamic> json) => _$SavingsGoalFromJson(json);

@override final  String id;
@override final  String spaceId;
@override final  String name;
@override final  String? emoji;
@override final  int targetAmount;
@override final  String currency;
/// `YYYY-MM-DD`; dipakai untuk menghitung setoran per minggu yang dibutuhkan.
@override final  String? targetDate;
/// Pengingat setor rutin (v0.2): `weekly`, `monthly`, atau `null` (tanpa pengingat).
@override final  String? reminderFrequency;
/// 1–7 untuk mingguan (1 = Senin), 1–31 untuk bulanan.
@override final  int? reminderDay;
@override final  DateTime? achievedAt;
@override final  DateTime? archivedAt;
@override final  String? createdBy;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SavingsGoal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavingsGoalCopyWith<_SavingsGoal> get copyWith => __$SavingsGoalCopyWithImpl<_SavingsGoal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavingsGoalToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavingsGoal&&(identical(other.id, id) || other.id == id)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.reminderFrequency, reminderFrequency) || other.reminderFrequency == reminderFrequency)&&(identical(other.reminderDay, reminderDay) || other.reminderDay == reminderDay)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,spaceId,name,emoji,targetAmount,currency,targetDate,reminderFrequency,reminderDay,achievedAt,archivedAt,createdBy,createdAt,updatedAt,deletedAt);
}

@override
String toString() {
    return 'SavingsGoal(id: $id, spaceId: $spaceId, name: $name, emoji: $emoji, targetAmount: $targetAmount, currency: $currency, targetDate: $targetDate, reminderFrequency: $reminderFrequency, reminderDay: $reminderDay, achievedAt: $achievedAt, archivedAt: $archivedAt, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SavingsGoalCopyWith<$Res> implements $SavingsGoalCopyWith<$Res> {
  factory _$SavingsGoalCopyWith(_SavingsGoal value, $Res Function(_SavingsGoal) _then) = __$SavingsGoalCopyWithImpl;
@override @useResult
$Res call({
 String id, String spaceId, String name, String? emoji, int targetAmount, String currency, String? targetDate, String? reminderFrequency, int? reminderDay, DateTime? achievedAt, DateTime? archivedAt, String? createdBy, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SavingsGoalCopyWithImpl<$Res>
    implements _$SavingsGoalCopyWith<$Res> {
  __$SavingsGoalCopyWithImpl(this._self, this._then);

  final _SavingsGoal _self;
  final $Res Function(_SavingsGoal) _then;

/// Create a copy of SavingsGoal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? spaceId = null,Object? name = null,Object? emoji = freezed,Object? targetAmount = null,Object? currency = null,Object? targetDate = freezed,Object? reminderFrequency = freezed,Object? reminderDay = freezed,Object? achievedAt = freezed,Object? archivedAt = freezed,Object? createdBy = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SavingsGoal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as String?,reminderFrequency: freezed == reminderFrequency ? _self.reminderFrequency : reminderFrequency // ignore: cast_nullable_to_non_nullable
as String?,reminderDay: freezed == reminderDay ? _self.reminderDay : reminderDay // ignore: cast_nullable_to_non_nullable
as int?,achievedAt: freezed == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
