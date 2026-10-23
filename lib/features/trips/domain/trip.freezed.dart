// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Trip {

 String get id; String get spaceId; String get title; String? get destination;/// `YYYY-MM-DD`; kosong berarti tanggalnya belum pasti.
 String? get startDate;/// `YYYY-MM-DD`, tidak lebih awal dari [startDate]; kosong berarti perjalanannya sehari.
 String? get endDate; String? get notes;/// Target tabungan di ruang yang sama; dikosongkan server kalau targetnya dihapus.
 String? get savingsGoalId; String? get createdBy; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TripCopyWith<Trip> get copyWith => _$TripCopyWithImpl<Trip>(this as Trip, _$identity);

  /// Serializes this Trip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Trip;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Trip&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.spaceId, _this.spaceId) || other.spaceId == _this.spaceId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.destination, _this.destination) || other.destination == _this.destination)&&(identical(other.startDate, _this.startDate) || other.startDate == _this.startDate)&&(identical(other.endDate, _this.endDate) || other.endDate == _this.endDate)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.savingsGoalId, _this.savingsGoalId) || other.savingsGoalId == _this.savingsGoalId)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Trip;
  return Object.hash(runtimeType,_this.id,_this.spaceId,_this.title,_this.destination,_this.startDate,_this.endDate,_this.notes,_this.savingsGoalId,_this.createdBy,_this.createdAt,_this.updatedAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as Trip;
  return 'Trip(id: ${_this.id}, spaceId: ${_this.spaceId}, title: ${_this.title}, destination: ${_this.destination}, startDate: ${_this.startDate}, endDate: ${_this.endDate}, notes: ${_this.notes}, savingsGoalId: ${_this.savingsGoalId}, createdBy: ${_this.createdBy}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $TripCopyWith<$Res>  {
  factory $TripCopyWith(Trip value, $Res Function(Trip) _then) = _$TripCopyWithImpl;
@useResult
$Res call({
 String id, String spaceId, String title, String? destination, String? startDate, String? endDate, String? notes, String? savingsGoalId, String? createdBy, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$TripCopyWithImpl<$Res>
    implements $TripCopyWith<$Res> {
  _$TripCopyWithImpl(this._self, this._then);

  final Trip _self;
  final $Res Function(Trip) _then;

/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? spaceId = null,Object? title = null,Object? destination = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? notes = freezed,Object? savingsGoalId = freezed,Object? createdBy = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(Trip(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,savingsGoalId: freezed == savingsGoalId ? _self.savingsGoalId : savingsGoalId // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Trip].
extension TripPatterns on Trip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Trip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Trip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Trip value)  $default,){
final _that = this;
switch (_that) {
case _Trip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Trip value)?  $default,){
final _that = this;
switch (_that) {
case _Trip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String spaceId,  String title,  String? destination,  String? startDate,  String? endDate,  String? notes,  String? savingsGoalId,  String? createdBy,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Trip() when $default != null:
return $default(_that.id,_that.spaceId,_that.title,_that.destination,_that.startDate,_that.endDate,_that.notes,_that.savingsGoalId,_that.createdBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String spaceId,  String title,  String? destination,  String? startDate,  String? endDate,  String? notes,  String? savingsGoalId,  String? createdBy,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Trip():
return $default(_that.id,_that.spaceId,_that.title,_that.destination,_that.startDate,_that.endDate,_that.notes,_that.savingsGoalId,_that.createdBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String spaceId,  String title,  String? destination,  String? startDate,  String? endDate,  String? notes,  String? savingsGoalId,  String? createdBy,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Trip() when $default != null:
return $default(_that.id,_that.spaceId,_that.title,_that.destination,_that.startDate,_that.endDate,_that.notes,_that.savingsGoalId,_that.createdBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Trip extends Trip {
  const _Trip({required this.id, required this.spaceId, required this.title, this.destination, this.startDate, this.endDate, this.notes, this.savingsGoalId, this.createdBy, required this.createdAt, required this.updatedAt, this.deletedAt}): super._();
  factory _Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);

@override final  String id;
@override final  String spaceId;
@override final  String title;
@override final  String? destination;
/// `YYYY-MM-DD`; kosong berarti tanggalnya belum pasti.
@override final  String? startDate;
/// `YYYY-MM-DD`, tidak lebih awal dari [startDate]; kosong berarti perjalanannya sehari.
@override final  String? endDate;
@override final  String? notes;
/// Target tabungan di ruang yang sama; dikosongkan server kalau targetnya dihapus.
@override final  String? savingsGoalId;
@override final  String? createdBy;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TripCopyWith<_Trip> get copyWith => __$TripCopyWithImpl<_Trip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TripToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Trip&&(identical(other.id, id) || other.id == id)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.title, title) || other.title == title)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.savingsGoalId, savingsGoalId) || other.savingsGoalId == savingsGoalId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,spaceId,title,destination,startDate,endDate,notes,savingsGoalId,createdBy,createdAt,updatedAt,deletedAt);
}

@override
String toString() {
    return 'Trip(id: $id, spaceId: $spaceId, title: $title, destination: $destination, startDate: $startDate, endDate: $endDate, notes: $notes, savingsGoalId: $savingsGoalId, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$TripCopyWith<$Res> implements $TripCopyWith<$Res> {
  factory _$TripCopyWith(_Trip value, $Res Function(_Trip) _then) = __$TripCopyWithImpl;
@override @useResult
$Res call({
 String id, String spaceId, String title, String? destination, String? startDate, String? endDate, String? notes, String? savingsGoalId, String? createdBy, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$TripCopyWithImpl<$Res>
    implements _$TripCopyWith<$Res> {
  __$TripCopyWithImpl(this._self, this._then);

  final _Trip _self;
  final $Res Function(_Trip) _then;

/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? spaceId = null,Object? title = null,Object? destination = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? notes = freezed,Object? savingsGoalId = freezed,Object? createdBy = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_Trip(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,savingsGoalId: freezed == savingsGoalId ? _self.savingsGoalId : savingsGoalId // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
