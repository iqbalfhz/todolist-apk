// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exchange_rates.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExchangeRates {

/// Selalu `EUR`.
 String get base;/// Tanggal kurs dari ECB (`YYYY-MM-DD`); di akhir pekan tetap hari kerja terakhir.
 String get date;/// Waktu terakhir server berhasil mengambil kurs.
 DateTime get fetchedAt;/// Banyaknya satuan utama tiap mata uang untuk 1 [base], sebagai teks desimal persis dari
/// ECB, misalnya `"20341.45"` untuk IDR.
 Map<String, String> get rates;
/// Create a copy of ExchangeRates
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExchangeRatesCopyWith<ExchangeRates> get copyWith => _$ExchangeRatesCopyWithImpl<ExchangeRates>(this as ExchangeRates, _$identity);

  /// Serializes this ExchangeRates to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExchangeRates;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExchangeRates&&(identical(other.base, _this.base) || other.base == _this.base)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.fetchedAt, _this.fetchedAt) || other.fetchedAt == _this.fetchedAt)&&const DeepCollectionEquality().equals(other.rates, _this.rates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExchangeRates;
  return Object.hash(runtimeType,_this.base,_this.date,_this.fetchedAt,const DeepCollectionEquality().hash(_this.rates));
}

@override
String toString() {
  final _this = this as ExchangeRates;
  return 'ExchangeRates(base: ${_this.base}, date: ${_this.date}, fetchedAt: ${_this.fetchedAt}, rates: ${_this.rates})';
}


}

/// @nodoc
abstract mixin class $ExchangeRatesCopyWith<$Res>  {
  factory $ExchangeRatesCopyWith(ExchangeRates value, $Res Function(ExchangeRates) _then) = _$ExchangeRatesCopyWithImpl;
@useResult
$Res call({
 String base, String date, DateTime fetchedAt, Map<String, String> rates
});




}
/// @nodoc
class _$ExchangeRatesCopyWithImpl<$Res>
    implements $ExchangeRatesCopyWith<$Res> {
  _$ExchangeRatesCopyWithImpl(this._self, this._then);

  final ExchangeRates _self;
  final $Res Function(ExchangeRates) _then;

/// Create a copy of ExchangeRates
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? base = null,Object? date = null,Object? fetchedAt = null,Object? rates = null,}) {
  return _then(ExchangeRates(
base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,rates: null == rates ? _self.rates : rates // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExchangeRates].
extension ExchangeRatesPatterns on ExchangeRates {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExchangeRates value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExchangeRates() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExchangeRates value)  $default,){
final _that = this;
switch (_that) {
case _ExchangeRates():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExchangeRates value)?  $default,){
final _that = this;
switch (_that) {
case _ExchangeRates() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String base,  String date,  DateTime fetchedAt,  Map<String, String> rates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExchangeRates() when $default != null:
return $default(_that.base,_that.date,_that.fetchedAt,_that.rates);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String base,  String date,  DateTime fetchedAt,  Map<String, String> rates)  $default,) {final _that = this;
switch (_that) {
case _ExchangeRates():
return $default(_that.base,_that.date,_that.fetchedAt,_that.rates);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String base,  String date,  DateTime fetchedAt,  Map<String, String> rates)?  $default,) {final _that = this;
switch (_that) {
case _ExchangeRates() when $default != null:
return $default(_that.base,_that.date,_that.fetchedAt,_that.rates);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExchangeRates extends ExchangeRates {
  const _ExchangeRates({required this.base, required this.date, required this.fetchedAt, required  Map<String, String> rates}): _rates = rates,super._();
  factory _ExchangeRates.fromJson(Map<String, dynamic> json) => _$ExchangeRatesFromJson(json);

/// Selalu `EUR`.
@override final  String base;
/// Tanggal kurs dari ECB (`YYYY-MM-DD`); di akhir pekan tetap hari kerja terakhir.
@override final  String date;
/// Waktu terakhir server berhasil mengambil kurs.
@override final  DateTime fetchedAt;
/// Banyaknya satuan utama tiap mata uang untuk 1 [base], sebagai teks desimal persis dari
/// ECB, misalnya `"20341.45"` untuk IDR.
 final  Map<String, String> _rates;
/// Banyaknya satuan utama tiap mata uang untuk 1 [base], sebagai teks desimal persis dari
/// ECB, misalnya `"20341.45"` untuk IDR.
@override Map<String, String> get rates {
  if (_rates is EqualUnmodifiableMapView) return _rates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rates);
}


/// Create a copy of ExchangeRates
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExchangeRatesCopyWith<_ExchangeRates> get copyWith => __$ExchangeRatesCopyWithImpl<_ExchangeRates>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExchangeRatesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExchangeRates&&(identical(other.base, base) || other.base == base)&&(identical(other.date, date) || other.date == date)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt)&&const DeepCollectionEquality().equals(other.rates, _rates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,base,date,fetchedAt,const DeepCollectionEquality().hash(_rates));
}

@override
String toString() {
    return 'ExchangeRates(base: $base, date: $date, fetchedAt: $fetchedAt, rates: $rates)';
}


}

/// @nodoc
abstract mixin class _$ExchangeRatesCopyWith<$Res> implements $ExchangeRatesCopyWith<$Res> {
  factory _$ExchangeRatesCopyWith(_ExchangeRates value, $Res Function(_ExchangeRates) _then) = __$ExchangeRatesCopyWithImpl;
@override @useResult
$Res call({
 String base, String date, DateTime fetchedAt, Map<String, String> rates
});




}
/// @nodoc
class __$ExchangeRatesCopyWithImpl<$Res>
    implements _$ExchangeRatesCopyWith<$Res> {
  __$ExchangeRatesCopyWithImpl(this._self, this._then);

  final _ExchangeRates _self;
  final $Res Function(_ExchangeRates) _then;

/// Create a copy of ExchangeRates
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? base = null,Object? date = null,Object? fetchedAt = null,Object? rates = null,}) {
  return _then(_ExchangeRates(
base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,rates: null == rates ? _self._rates : rates // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
