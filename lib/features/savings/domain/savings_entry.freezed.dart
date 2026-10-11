// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'savings_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavingsEntry {

 String get id; String get savingsGoalId; String get spaceId;/// Akun yang mencatat; diisi server.
 String? get userId; String get type; int get amount;/// `YYYY-MM-DD`, tanggal setor menurut HP.
 String get entryDate; String? get note; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SavingsEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavingsEntryCopyWith<SavingsEntry> get copyWith => _$SavingsEntryCopyWithImpl<SavingsEntry>(this as SavingsEntry, _$identity);

  /// Serializes this SavingsEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SavingsEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavingsEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.savingsGoalId, _this.savingsGoalId) || other.savingsGoalId == _this.savingsGoalId)&&(identical(other.spaceId, _this.spaceId) || other.spaceId == _this.spaceId)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.entryDate, _this.entryDate) || other.entryDate == _this.entryDate)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SavingsEntry;
  return Object.hash(runtimeType,_this.id,_this.savingsGoalId,_this.spaceId,_this.userId,_this.type,_this.amount,_this.entryDate,_this.note,_this.createdAt,_this.updatedAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as SavingsEntry;
  return 'SavingsEntry(id: ${_this.id}, savingsGoalId: ${_this.savingsGoalId}, spaceId: ${_this.spaceId}, userId: ${_this.userId}, type: ${_this.type}, amount: ${_this.amount}, entryDate: ${_this.entryDate}, note: ${_this.note}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $SavingsEntryCopyWith<$Res>  {
  factory $SavingsEntryCopyWith(SavingsEntry value, $Res Function(SavingsEntry) _then) = _$SavingsEntryCopyWithImpl;
@useResult
$Res call({
 String id, String savingsGoalId, String spaceId, String? userId, String type, int amount, String entryDate, String? note, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SavingsEntryCopyWithImpl<$Res>
    implements $SavingsEntryCopyWith<$Res> {
  _$SavingsEntryCopyWithImpl(this._self, this._then);

  final SavingsEntry _self;
  final $Res Function(SavingsEntry) _then;

/// Create a copy of SavingsEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? savingsGoalId = null,Object? spaceId = null,Object? userId = freezed,Object? type = null,Object? amount = null,Object? entryDate = null,Object? note = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(SavingsEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,savingsGoalId: null == savingsGoalId ? _self.savingsGoalId : savingsGoalId // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,entryDate: null == entryDate ? _self.entryDate : entryDate // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SavingsEntry].
extension SavingsEntryPatterns on SavingsEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavingsEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavingsEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavingsEntry value)  $default,){
final _that = this;
switch (_that) {
case _SavingsEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavingsEntry value)?  $default,){
final _that = this;
switch (_that) {
case _SavingsEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String savingsGoalId,  String spaceId,  String? userId,  String type,  int amount,  String entryDate,  String? note,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavingsEntry() when $default != null:
return $default(_that.id,_that.savingsGoalId,_that.spaceId,_that.userId,_that.type,_that.amount,_that.entryDate,_that.note,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String savingsGoalId,  String spaceId,  String? userId,  String type,  int amount,  String entryDate,  String? note,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SavingsEntry():
return $default(_that.id,_that.savingsGoalId,_that.spaceId,_that.userId,_that.type,_that.amount,_that.entryDate,_that.note,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String savingsGoalId,  String spaceId,  String? userId,  String type,  int amount,  String entryDate,  String? note,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SavingsEntry() when $default != null:
return $default(_that.id,_that.savingsGoalId,_that.spaceId,_that.userId,_that.type,_that.amount,_that.entryDate,_that.note,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavingsEntry implements SavingsEntry {
  const _SavingsEntry({required this.id, required this.savingsGoalId, required this.spaceId, this.userId, this.type = 'deposit', required this.amount, required this.entryDate, this.note, required this.createdAt, required this.updatedAt, this.deletedAt});
  factory _SavingsEntry.fromJson(Map<String, dynamic> json) => _$SavingsEntryFromJson(json);

@override final  String id;
@override final  String savingsGoalId;
@override final  String spaceId;
/// Akun yang mencatat; diisi server.
@override final  String? userId;
@override@JsonKey() final  String type;
@override final  int amount;
/// `YYYY-MM-DD`, tanggal setor menurut HP.
@override final  String entryDate;
@override final  String? note;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SavingsEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavingsEntryCopyWith<_SavingsEntry> get copyWith => __$SavingsEntryCopyWithImpl<_SavingsEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavingsEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavingsEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.savingsGoalId, savingsGoalId) || other.savingsGoalId == savingsGoalId)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.entryDate, entryDate) || other.entryDate == entryDate)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,savingsGoalId,spaceId,userId,type,amount,entryDate,note,createdAt,updatedAt,deletedAt);
}

@override
String toString() {
    return 'SavingsEntry(id: $id, savingsGoalId: $savingsGoalId, spaceId: $spaceId, userId: $userId, type: $type, amount: $amount, entryDate: $entryDate, note: $note, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SavingsEntryCopyWith<$Res> implements $SavingsEntryCopyWith<$Res> {
  factory _$SavingsEntryCopyWith(_SavingsEntry value, $Res Function(_SavingsEntry) _then) = __$SavingsEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String savingsGoalId, String spaceId, String? userId, String type, int amount, String entryDate, String? note, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SavingsEntryCopyWithImpl<$Res>
    implements _$SavingsEntryCopyWith<$Res> {
  __$SavingsEntryCopyWithImpl(this._self, this._then);

  final _SavingsEntry _self;
  final $Res Function(_SavingsEntry) _then;

/// Create a copy of SavingsEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? savingsGoalId = null,Object? spaceId = null,Object? userId = freezed,Object? type = null,Object? amount = null,Object? entryDate = null,Object? note = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SavingsEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,savingsGoalId: null == savingsGoalId ? _self.savingsGoalId : savingsGoalId // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,entryDate: null == entryDate ? _self.entryDate : entryDate // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
