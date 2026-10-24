// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'memory_photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MemoryPhoto {

 String get id; String get memoryId; String get spaceId; String? get uploadedBy; double get position;/// Ukuran versi penuh, paling besar 2560 px di sisi terpanjang.
 int? get width; int? get height; DateTime? get takenAt;/// URL bertanda tangan yang berlaku 7 hari; kosong selama foto belum terunggah.
 String? get url; String? get thumbUrl; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of MemoryPhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemoryPhotoCopyWith<MemoryPhoto> get copyWith => _$MemoryPhotoCopyWithImpl<MemoryPhoto>(this as MemoryPhoto, _$identity);

  /// Serializes this MemoryPhoto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MemoryPhoto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemoryPhoto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.memoryId, _this.memoryId) || other.memoryId == _this.memoryId)&&(identical(other.spaceId, _this.spaceId) || other.spaceId == _this.spaceId)&&(identical(other.uploadedBy, _this.uploadedBy) || other.uploadedBy == _this.uploadedBy)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&(identical(other.takenAt, _this.takenAt) || other.takenAt == _this.takenAt)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.thumbUrl, _this.thumbUrl) || other.thumbUrl == _this.thumbUrl)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MemoryPhoto;
  return Object.hash(runtimeType,_this.id,_this.memoryId,_this.spaceId,_this.uploadedBy,_this.position,_this.width,_this.height,_this.takenAt,_this.url,_this.thumbUrl,_this.createdAt,_this.updatedAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as MemoryPhoto;
  return 'MemoryPhoto(id: ${_this.id}, memoryId: ${_this.memoryId}, spaceId: ${_this.spaceId}, uploadedBy: ${_this.uploadedBy}, position: ${_this.position}, width: ${_this.width}, height: ${_this.height}, takenAt: ${_this.takenAt}, url: ${_this.url}, thumbUrl: ${_this.thumbUrl}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $MemoryPhotoCopyWith<$Res>  {
  factory $MemoryPhotoCopyWith(MemoryPhoto value, $Res Function(MemoryPhoto) _then) = _$MemoryPhotoCopyWithImpl;
@useResult
$Res call({
 String id, String memoryId, String spaceId, String? uploadedBy, double position, int? width, int? height, DateTime? takenAt, String? url, String? thumbUrl, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$MemoryPhotoCopyWithImpl<$Res>
    implements $MemoryPhotoCopyWith<$Res> {
  _$MemoryPhotoCopyWithImpl(this._self, this._then);

  final MemoryPhoto _self;
  final $Res Function(MemoryPhoto) _then;

/// Create a copy of MemoryPhoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memoryId = null,Object? spaceId = null,Object? uploadedBy = freezed,Object? position = null,Object? width = freezed,Object? height = freezed,Object? takenAt = freezed,Object? url = freezed,Object? thumbUrl = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(MemoryPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memoryId: null == memoryId ? _self.memoryId : memoryId // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,uploadedBy: freezed == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as double,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,takenAt: freezed == takenAt ? _self.takenAt : takenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,thumbUrl: freezed == thumbUrl ? _self.thumbUrl : thumbUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MemoryPhoto].
extension MemoryPhotoPatterns on MemoryPhoto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemoryPhoto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemoryPhoto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemoryPhoto value)  $default,){
final _that = this;
switch (_that) {
case _MemoryPhoto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemoryPhoto value)?  $default,){
final _that = this;
switch (_that) {
case _MemoryPhoto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memoryId,  String spaceId,  String? uploadedBy,  double position,  int? width,  int? height,  DateTime? takenAt,  String? url,  String? thumbUrl,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemoryPhoto() when $default != null:
return $default(_that.id,_that.memoryId,_that.spaceId,_that.uploadedBy,_that.position,_that.width,_that.height,_that.takenAt,_that.url,_that.thumbUrl,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memoryId,  String spaceId,  String? uploadedBy,  double position,  int? width,  int? height,  DateTime? takenAt,  String? url,  String? thumbUrl,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _MemoryPhoto():
return $default(_that.id,_that.memoryId,_that.spaceId,_that.uploadedBy,_that.position,_that.width,_that.height,_that.takenAt,_that.url,_that.thumbUrl,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memoryId,  String spaceId,  String? uploadedBy,  double position,  int? width,  int? height,  DateTime? takenAt,  String? url,  String? thumbUrl,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _MemoryPhoto() when $default != null:
return $default(_that.id,_that.memoryId,_that.spaceId,_that.uploadedBy,_that.position,_that.width,_that.height,_that.takenAt,_that.url,_that.thumbUrl,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemoryPhoto extends MemoryPhoto {
  const _MemoryPhoto({required this.id, required this.memoryId, required this.spaceId, this.uploadedBy, required this.position, this.width, this.height, this.takenAt, this.url, this.thumbUrl, required this.createdAt, required this.updatedAt, this.deletedAt}): super._();
  factory _MemoryPhoto.fromJson(Map<String, dynamic> json) => _$MemoryPhotoFromJson(json);

@override final  String id;
@override final  String memoryId;
@override final  String spaceId;
@override final  String? uploadedBy;
@override final  double position;
/// Ukuran versi penuh, paling besar 2560 px di sisi terpanjang.
@override final  int? width;
@override final  int? height;
@override final  DateTime? takenAt;
/// URL bertanda tangan yang berlaku 7 hari; kosong selama foto belum terunggah.
@override final  String? url;
@override final  String? thumbUrl;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of MemoryPhoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemoryPhotoCopyWith<_MemoryPhoto> get copyWith => __$MemoryPhotoCopyWithImpl<_MemoryPhoto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemoryPhotoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemoryPhoto&&(identical(other.id, id) || other.id == id)&&(identical(other.memoryId, memoryId) || other.memoryId == memoryId)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.uploadedBy, uploadedBy) || other.uploadedBy == uploadedBy)&&(identical(other.position, position) || other.position == position)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.takenAt, takenAt) || other.takenAt == takenAt)&&(identical(other.url, url) || other.url == url)&&(identical(other.thumbUrl, thumbUrl) || other.thumbUrl == thumbUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,memoryId,spaceId,uploadedBy,position,width,height,takenAt,url,thumbUrl,createdAt,updatedAt,deletedAt);
}

@override
String toString() {
    return 'MemoryPhoto(id: $id, memoryId: $memoryId, spaceId: $spaceId, uploadedBy: $uploadedBy, position: $position, width: $width, height: $height, takenAt: $takenAt, url: $url, thumbUrl: $thumbUrl, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$MemoryPhotoCopyWith<$Res> implements $MemoryPhotoCopyWith<$Res> {
  factory _$MemoryPhotoCopyWith(_MemoryPhoto value, $Res Function(_MemoryPhoto) _then) = __$MemoryPhotoCopyWithImpl;
@override @useResult
$Res call({
 String id, String memoryId, String spaceId, String? uploadedBy, double position, int? width, int? height, DateTime? takenAt, String? url, String? thumbUrl, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$MemoryPhotoCopyWithImpl<$Res>
    implements _$MemoryPhotoCopyWith<$Res> {
  __$MemoryPhotoCopyWithImpl(this._self, this._then);

  final _MemoryPhoto _self;
  final $Res Function(_MemoryPhoto) _then;

/// Create a copy of MemoryPhoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memoryId = null,Object? spaceId = null,Object? uploadedBy = freezed,Object? position = null,Object? width = freezed,Object? height = freezed,Object? takenAt = freezed,Object? url = freezed,Object? thumbUrl = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_MemoryPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memoryId: null == memoryId ? _self.memoryId : memoryId // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,uploadedBy: freezed == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as double,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,takenAt: freezed == takenAt ? _self.takenAt : takenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,thumbUrl: freezed == thumbUrl ? _self.thumbUrl : thumbUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
