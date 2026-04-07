// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'train.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Train {

 String get trainNo; String get trainTypeName; String get departureTime; String get arrivalTime; String get travelTime; int get fare;
/// Create a copy of Train
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainCopyWith<Train> get copyWith => _$TrainCopyWithImpl<Train>(this as Train, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Train&&(identical(other.trainNo, trainNo) || other.trainNo == trainNo)&&(identical(other.trainTypeName, trainTypeName) || other.trainTypeName == trainTypeName)&&(identical(other.departureTime, departureTime) || other.departureTime == departureTime)&&(identical(other.arrivalTime, arrivalTime) || other.arrivalTime == arrivalTime)&&(identical(other.travelTime, travelTime) || other.travelTime == travelTime)&&(identical(other.fare, fare) || other.fare == fare));
}


@override
int get hashCode => Object.hash(runtimeType,trainNo,trainTypeName,departureTime,arrivalTime,travelTime,fare);

@override
String toString() {
  return 'Train(trainNo: $trainNo, trainTypeName: $trainTypeName, departureTime: $departureTime, arrivalTime: $arrivalTime, travelTime: $travelTime, fare: $fare)';
}


}

/// @nodoc
abstract mixin class $TrainCopyWith<$Res>  {
  factory $TrainCopyWith(Train value, $Res Function(Train) _then) = _$TrainCopyWithImpl;
@useResult
$Res call({
 String trainNo, String trainTypeName, String departureTime, String arrivalTime, String travelTime, int fare
});




}
/// @nodoc
class _$TrainCopyWithImpl<$Res>
    implements $TrainCopyWith<$Res> {
  _$TrainCopyWithImpl(this._self, this._then);

  final Train _self;
  final $Res Function(Train) _then;

/// Create a copy of Train
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trainNo = null,Object? trainTypeName = null,Object? departureTime = null,Object? arrivalTime = null,Object? travelTime = null,Object? fare = null,}) {
  return _then(_self.copyWith(
trainNo: null == trainNo ? _self.trainNo : trainNo // ignore: cast_nullable_to_non_nullable
as String,trainTypeName: null == trainTypeName ? _self.trainTypeName : trainTypeName // ignore: cast_nullable_to_non_nullable
as String,departureTime: null == departureTime ? _self.departureTime : departureTime // ignore: cast_nullable_to_non_nullable
as String,arrivalTime: null == arrivalTime ? _self.arrivalTime : arrivalTime // ignore: cast_nullable_to_non_nullable
as String,travelTime: null == travelTime ? _self.travelTime : travelTime // ignore: cast_nullable_to_non_nullable
as String,fare: null == fare ? _self.fare : fare // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Train].
extension TrainPatterns on Train {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Train value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Train() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Train value)  $default,){
final _that = this;
switch (_that) {
case _Train():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Train value)?  $default,){
final _that = this;
switch (_that) {
case _Train() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String trainNo,  String trainTypeName,  String departureTime,  String arrivalTime,  String travelTime,  int fare)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Train() when $default != null:
return $default(_that.trainNo,_that.trainTypeName,_that.departureTime,_that.arrivalTime,_that.travelTime,_that.fare);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String trainNo,  String trainTypeName,  String departureTime,  String arrivalTime,  String travelTime,  int fare)  $default,) {final _that = this;
switch (_that) {
case _Train():
return $default(_that.trainNo,_that.trainTypeName,_that.departureTime,_that.arrivalTime,_that.travelTime,_that.fare);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String trainNo,  String trainTypeName,  String departureTime,  String arrivalTime,  String travelTime,  int fare)?  $default,) {final _that = this;
switch (_that) {
case _Train() when $default != null:
return $default(_that.trainNo,_that.trainTypeName,_that.departureTime,_that.arrivalTime,_that.travelTime,_that.fare);case _:
  return null;

}
}

}

/// @nodoc


class _Train implements Train {
  const _Train({required this.trainNo, required this.trainTypeName, required this.departureTime, required this.arrivalTime, required this.travelTime, required this.fare});
  

@override final  String trainNo;
@override final  String trainTypeName;
@override final  String departureTime;
@override final  String arrivalTime;
@override final  String travelTime;
@override final  int fare;

/// Create a copy of Train
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainCopyWith<_Train> get copyWith => __$TrainCopyWithImpl<_Train>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Train&&(identical(other.trainNo, trainNo) || other.trainNo == trainNo)&&(identical(other.trainTypeName, trainTypeName) || other.trainTypeName == trainTypeName)&&(identical(other.departureTime, departureTime) || other.departureTime == departureTime)&&(identical(other.arrivalTime, arrivalTime) || other.arrivalTime == arrivalTime)&&(identical(other.travelTime, travelTime) || other.travelTime == travelTime)&&(identical(other.fare, fare) || other.fare == fare));
}


@override
int get hashCode => Object.hash(runtimeType,trainNo,trainTypeName,departureTime,arrivalTime,travelTime,fare);

@override
String toString() {
  return 'Train(trainNo: $trainNo, trainTypeName: $trainTypeName, departureTime: $departureTime, arrivalTime: $arrivalTime, travelTime: $travelTime, fare: $fare)';
}


}

/// @nodoc
abstract mixin class _$TrainCopyWith<$Res> implements $TrainCopyWith<$Res> {
  factory _$TrainCopyWith(_Train value, $Res Function(_Train) _then) = __$TrainCopyWithImpl;
@override @useResult
$Res call({
 String trainNo, String trainTypeName, String departureTime, String arrivalTime, String travelTime, int fare
});




}
/// @nodoc
class __$TrainCopyWithImpl<$Res>
    implements _$TrainCopyWith<$Res> {
  __$TrainCopyWithImpl(this._self, this._then);

  final _Train _self;
  final $Res Function(_Train) _then;

/// Create a copy of Train
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trainNo = null,Object? trainTypeName = null,Object? departureTime = null,Object? arrivalTime = null,Object? travelTime = null,Object? fare = null,}) {
  return _then(_Train(
trainNo: null == trainNo ? _self.trainNo : trainNo // ignore: cast_nullable_to_non_nullable
as String,trainTypeName: null == trainTypeName ? _self.trainTypeName : trainTypeName // ignore: cast_nullable_to_non_nullable
as String,departureTime: null == departureTime ? _self.departureTime : departureTime // ignore: cast_nullable_to_non_nullable
as String,arrivalTime: null == arrivalTime ? _self.arrivalTime : arrivalTime // ignore: cast_nullable_to_non_nullable
as String,travelTime: null == travelTime ? _self.travelTime : travelTime // ignore: cast_nullable_to_non_nullable
as String,fare: null == fare ? _self.fare : fare // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
