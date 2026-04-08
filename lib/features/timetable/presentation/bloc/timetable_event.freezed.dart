// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timetable_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TimetableEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimetableEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TimetableEvent()';
}


}

/// @nodoc
class $TimetableEventCopyWith<$Res>  {
$TimetableEventCopyWith(TimetableEvent _, $Res Function(TimetableEvent) __);
}


/// Adds pattern-matching-related methods to [TimetableEvent].
extension TimetableEventPatterns on TimetableEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LoadTimetable value)?  load,TResult Function( RetryTimetable value)?  retry,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LoadTimetable() when load != null:
return load(_that);case RetryTimetable() when retry != null:
return retry(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LoadTimetable value)  load,required TResult Function( RetryTimetable value)  retry,}){
final _that = this;
switch (_that) {
case LoadTimetable():
return load(_that);case RetryTimetable():
return retry(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LoadTimetable value)?  load,TResult? Function( RetryTimetable value)?  retry,}){
final _that = this;
switch (_that) {
case LoadTimetable() when load != null:
return load(_that);case RetryTimetable() when retry != null:
return retry(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String origin,  String destination,  String date,  String time)?  load,TResult Function()?  retry,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LoadTimetable() when load != null:
return load(_that.origin,_that.destination,_that.date,_that.time);case RetryTimetable() when retry != null:
return retry();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String origin,  String destination,  String date,  String time)  load,required TResult Function()  retry,}) {final _that = this;
switch (_that) {
case LoadTimetable():
return load(_that.origin,_that.destination,_that.date,_that.time);case RetryTimetable():
return retry();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String origin,  String destination,  String date,  String time)?  load,TResult? Function()?  retry,}) {final _that = this;
switch (_that) {
case LoadTimetable() when load != null:
return load(_that.origin,_that.destination,_that.date,_that.time);case RetryTimetable() when retry != null:
return retry();case _:
  return null;

}
}

}

/// @nodoc


class LoadTimetable implements TimetableEvent {
  const LoadTimetable({required this.origin, required this.destination, required this.date, this.time = ''});


 final  String origin;
 final  String destination;
 final  String date;
 final  String time;

/// Create a copy of TimetableEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadTimetableCopyWith<LoadTimetable> get copyWith => _$LoadTimetableCopyWithImpl<LoadTimetable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadTimetable&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.date, date) || other.date == date)&&(identical(other.time, time) || other.time == time));
}


@override
int get hashCode => Object.hash(runtimeType,origin,destination,date,time);

@override
String toString() {
  return 'TimetableEvent.load(origin: $origin, destination: $destination, date: $date, time: $time)';
}


}

/// @nodoc
abstract mixin class $LoadTimetableCopyWith<$Res> implements $TimetableEventCopyWith<$Res> {
  factory $LoadTimetableCopyWith(LoadTimetable value, $Res Function(LoadTimetable) _then) = _$LoadTimetableCopyWithImpl;
@useResult
$Res call({
 String origin, String destination, String date, String time
});




}
/// @nodoc
class _$LoadTimetableCopyWithImpl<$Res>
    implements $LoadTimetableCopyWith<$Res> {
  _$LoadTimetableCopyWithImpl(this._self, this._then);

  final LoadTimetable _self;
  final $Res Function(LoadTimetable) _then;

/// Create a copy of TimetableEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? origin = null,Object? destination = null,Object? date = null,Object? time = null,}) {
  return _then(LoadTimetable(
origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class RetryTimetable implements TimetableEvent {
  const RetryTimetable();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RetryTimetable);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TimetableEvent.retry()';
}


}




// dart format on
