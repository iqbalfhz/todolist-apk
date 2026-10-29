// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'memory.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Memory {

 String get id; String get spaceId;/// Perjalanan asalnya; dikosongkan server kalau perjalanannya dihapus.
 String? get tripId; String get title; String? get placeName;/// Pin lokasi (v1.x), selalu berpasangan dengan [longitude]; dibulatkan ke 6 desimal.
 double? get latitude; double? get longitude;/// `YYYY-MM-DD`; tanggal kenangan di linimasa.
 String get visitedOn; String? get story; String? get createdBy; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of Memory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemoryCopyWith<Memory> get copyWith => _$MemoryCopyWithImpl<Memory>(this as Memory, _$identity);

  /// Serializes this Memory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Memory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Memory&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.spaceId, _this.spaceId) || other.spaceId == _this.spaceId)&&(identical(other.tripId, _this.tripId) || other.tripId == _this.tripId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.placeName, _this.placeName) || other.placeName == _this.placeName)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.visitedOn, _this.visitedOn) || other.visitedOn == _this.visitedOn)&&(identical(other.story, _this.story) || other.story == _this.story)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Memory;
  return Object.hash(runtimeType,_this.id,_this.spaceId,_this.tripId,_this.title,_this.placeName,_this.latitude,_this.longitude,_this.visitedOn,_this.story,_this.createdBy,_this.createdAt,_this.updatedAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as Memory;
  return 'Memory(id: ${_this.id}, spaceId: ${_this.spaceId}, tripId: ${_this.tripId}, title: ${_this.title}, placeName: ${_this.placeName}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, visitedOn: ${_this.visitedOn}, story: ${_this.story}, createdBy: ${_this.createdBy}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $MemoryCopyWith<$Res>  {
  factory $MemoryCopyWith(Memory value, $Res Function(Memory) _then) = _$MemoryCopyWithImpl;
@useResult
$Res call({
 String id, String spaceId, String? tripId, String title, String? placeName, double? latitude, double? longitude, String visitedOn, String? story, String? createdBy, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$MemoryCopyWithImpl<$Res>
    implements $MemoryCopyWith<$Res> {
  _$MemoryCopyWithImpl(this._self, this._then);

  final Memory _self;
  final $Res Function(Memory) _then;

/// Create a copy of Memory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? spaceId = null,Object? tripId = freezed,Object? title = null,Object? placeName = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? visitedOn = null,Object? story = freezed,Object? createdBy = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(Memory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,tripId: freezed == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,placeName: freezed == placeName ? _self.placeName : placeName // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,visitedOn: null == visitedOn ? _self.visitedOn : visitedOn // ignore: cast_nullable_to_non_nullable
as String,story: freezed == story ? _self.story : story // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Memory].
extension MemoryPatterns on Memory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Memory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Memory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Memory value)  $default,){
final _that = this;
switch (_that) {
case _Memory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Memory value)?  $default,){
final _that = this;
switch (_that) {
case _Memory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String spaceId,  String? tripId,  String title,  String? placeName,  double? latitude,  double? longitude,  String visitedOn,  String? story,  String? createdBy,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Memory() when $default != null:
return $default(_that.id,_that.spaceId,_that.tripId,_that.title,_that.placeName,_that.latitude,_that.longitude,_that.visitedOn,_that.story,_that.createdBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String spaceId,  String? tripId,  String title,  String? placeName,  double? latitude,  double? longitude,  String visitedOn,  String? story,  String? createdBy,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Memory():
return $default(_that.id,_that.spaceId,_that.tripId,_that.title,_that.placeName,_that.latitude,_that.longitude,_that.visitedOn,_that.story,_that.createdBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String spaceId,  String? tripId,  String title,  String? placeName,  double? latitude,  double? longitude,  String visitedOn,  String? story,  String? createdBy,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Memory() when $default != null:
return $default(_that.id,_that.spaceId,_that.tripId,_that.title,_that.placeName,_that.latitude,_that.longitude,_that.visitedOn,_that.story,_that.createdBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Memory implements Memory {
  const _Memory({required this.id, required this.spaceId, this.tripId, required this.title, this.placeName, this.latitude, this.longitude, required this.visitedOn, this.story, this.createdBy, required this.createdAt, required this.updatedAt, this.deletedAt});
  factory _Memory.fromJson(Map<String, dynamic> json) => _$MemoryFromJson(json);

@override final  String id;
@override final  String spaceId;
/// Perjalanan asalnya; dikosongkan server kalau perjalanannya dihapus.
@override final  String? tripId;
@override final  String title;
@override final  String? placeName;
/// Pin lokasi (v1.x), selalu berpasangan dengan [longitude]; dibulatkan ke 6 desimal.
@override final  double? latitude;
@override final  double? longitude;
/// `YYYY-MM-DD`; tanggal kenangan di linimasa.
@override final  String visitedOn;
@override final  String? story;
@override final  String? createdBy;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of Memory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemoryCopyWith<_Memory> get copyWith => __$MemoryCopyWithImpl<_Memory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemoryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Memory&&(identical(other.id, id) || other.id == id)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.title, title) || other.title == title)&&(identical(other.placeName, placeName) || other.placeName == placeName)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.visitedOn, visitedOn) || other.visitedOn == visitedOn)&&(identical(other.story, story) || other.story == story)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,spaceId,tripId,title,placeName,latitude,longitude,visitedOn,story,createdBy,createdAt,updatedAt,deletedAt);
}

@override
String toString() {
    return 'Memory(id: $id, spaceId: $spaceId, tripId: $tripId, title: $title, placeName: $placeName, latitude: $latitude, longitude: $longitude, visitedOn: $visitedOn, story: $story, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$MemoryCopyWith<$Res> implements $MemoryCopyWith<$Res> {
  factory _$MemoryCopyWith(_Memory value, $Res Function(_Memory) _then) = __$MemoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String spaceId, String? tripId, String title, String? placeName, double? latitude, double? longitude, String visitedOn, String? story, String? createdBy, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$MemoryCopyWithImpl<$Res>
    implements _$MemoryCopyWith<$Res> {
  __$MemoryCopyWithImpl(this._self, this._then);

  final _Memory _self;
  final $Res Function(_Memory) _then;

/// Create a copy of Memory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? spaceId = null,Object? tripId = freezed,Object? title = null,Object? placeName = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? visitedOn = null,Object? story = freezed,Object? createdBy = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_Memory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,tripId: freezed == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,placeName: freezed == placeName ? _self.placeName : placeName // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,visitedOn: null == visitedOn ? _self.visitedOn : visitedOn // ignore: cast_nullable_to_non_nullable
as String,story: freezed == story ? _self.story : story // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
