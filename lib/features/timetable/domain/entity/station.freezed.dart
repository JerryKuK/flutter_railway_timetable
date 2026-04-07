// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'station.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Station {

 String get stationId; String get stationName;
/// Create a copy of Station
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StationCopyWith<Station> get copyWith => _$StationCopyWithImpl<Station>(this as Station, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Station&&(identical(other.stationId, stationId) || other.stationId == stationId)&&(identical(other.stationName, stationName) || other.stationName == stationName));
}


@override
int get hashCode => Object.hash(runtimeType,stationId,stationName);

@override
String toString() {
  return 'Station(stationId: $stationId, stationName: $stationName)';
}


}

/// @nodoc
abstract mixin class $StationCopyWith<$Res>  {
  factory $StationCopyWith(Station value, $Res Function(Station) _then) = _$StationCopyWithImpl;
@useResult
$Res call({
 String stationId, String stationName
});




}
/// @nodoc
class _$StationCopyWithImpl<$Res>
    implements $StationCopyWith<$Res> {
  _$StationCopyWithImpl(this._self, this._then);

  final Station _self;
  final $Res Function(Station) _then;

/// Create a copy of Station
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stationId = null,Object? stationName = null,}) {
  return _then(_self.copyWith(
stationId: null == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String,stationName: null == stationName ? _self.stationName : stationName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Station].
extension StationPatterns on Station {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Station value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Station() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Station value)  $default,){
final _that = this;
switch (_that) {
case _Station():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Station value)?  $default,){
final _that = this;
switch (_that) {
case _Station() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String stationId,  String stationName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Station() when $default != null:
return $default(_that.stationId,_that.stationName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String stationId,  String stationName)  $default,) {final _that = this;
switch (_that) {
case _Station():
return $default(_that.stationId,_that.stationName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String stationId,  String stationName)?  $default,) {final _that = this;
switch (_that) {
case _Station() when $default != null:
return $default(_that.stationId,_that.stationName);case _:
  return null;

}
}

}

/// @nodoc


class _Station implements Station {
  const _Station({required this.stationId, required this.stationName});
  

@override final  String stationId;
@override final  String stationName;

/// Create a copy of Station
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StationCopyWith<_Station> get copyWith => __$StationCopyWithImpl<_Station>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Station&&(identical(other.stationId, stationId) || other.stationId == stationId)&&(identical(other.stationName, stationName) || other.stationName == stationName));
}


@override
int get hashCode => Object.hash(runtimeType,stationId,stationName);

@override
String toString() {
  return 'Station(stationId: $stationId, stationName: $stationName)';
}


}

/// @nodoc
abstract mixin class _$StationCopyWith<$Res> implements $StationCopyWith<$Res> {
  factory _$StationCopyWith(_Station value, $Res Function(_Station) _then) = __$StationCopyWithImpl;
@override @useResult
$Res call({
 String stationId, String stationName
});




}
/// @nodoc
class __$StationCopyWithImpl<$Res>
    implements _$StationCopyWith<$Res> {
  __$StationCopyWithImpl(this._self, this._then);

  final _Station _self;
  final $Res Function(_Station) _then;

/// Create a copy of Station
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stationId = null,Object? stationName = null,}) {
  return _then(_Station(
stationId: null == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String,stationName: null == stationName ? _self.stationName : stationName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
