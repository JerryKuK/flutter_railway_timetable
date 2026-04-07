// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timetable_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TimetableState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimetableState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TimetableState()';
}


}

/// @nodoc
class $TimetableStateCopyWith<$Res>  {
$TimetableStateCopyWith(TimetableState _, $Res Function(TimetableState) __);
}


/// Adds pattern-matching-related methods to [TimetableState].
extension TimetableStatePatterns on TimetableState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TimetableInitial value)?  initial,TResult Function( TimetableLoading value)?  loading,TResult Function( TimetableLoaded value)?  loaded,TResult Function( TimetableEmpty value)?  empty,TResult Function( TimetableError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TimetableInitial() when initial != null:
return initial(_that);case TimetableLoading() when loading != null:
return loading(_that);case TimetableLoaded() when loaded != null:
return loaded(_that);case TimetableEmpty() when empty != null:
return empty(_that);case TimetableError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TimetableInitial value)  initial,required TResult Function( TimetableLoading value)  loading,required TResult Function( TimetableLoaded value)  loaded,required TResult Function( TimetableEmpty value)  empty,required TResult Function( TimetableError value)  error,}){
final _that = this;
switch (_that) {
case TimetableInitial():
return initial(_that);case TimetableLoading():
return loading(_that);case TimetableLoaded():
return loaded(_that);case TimetableEmpty():
return empty(_that);case TimetableError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TimetableInitial value)?  initial,TResult? Function( TimetableLoading value)?  loading,TResult? Function( TimetableLoaded value)?  loaded,TResult? Function( TimetableEmpty value)?  empty,TResult? Function( TimetableError value)?  error,}){
final _that = this;
switch (_that) {
case TimetableInitial() when initial != null:
return initial(_that);case TimetableLoading() when loading != null:
return loading(_that);case TimetableLoaded() when loaded != null:
return loaded(_that);case TimetableEmpty() when empty != null:
return empty(_that);case TimetableError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<Train> trains)?  loaded,TResult Function()?  empty,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TimetableInitial() when initial != null:
return initial();case TimetableLoading() when loading != null:
return loading();case TimetableLoaded() when loaded != null:
return loaded(_that.trains);case TimetableEmpty() when empty != null:
return empty();case TimetableError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<Train> trains)  loaded,required TResult Function()  empty,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case TimetableInitial():
return initial();case TimetableLoading():
return loading();case TimetableLoaded():
return loaded(_that.trains);case TimetableEmpty():
return empty();case TimetableError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<Train> trains)?  loaded,TResult? Function()?  empty,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case TimetableInitial() when initial != null:
return initial();case TimetableLoading() when loading != null:
return loading();case TimetableLoaded() when loaded != null:
return loaded(_that.trains);case TimetableEmpty() when empty != null:
return empty();case TimetableError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class TimetableInitial implements TimetableState {
  const TimetableInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimetableInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TimetableState.initial()';
}


}




/// @nodoc


class TimetableLoading implements TimetableState {
  const TimetableLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimetableLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TimetableState.loading()';
}


}




/// @nodoc


class TimetableLoaded implements TimetableState {
  const TimetableLoaded(final  List<Train> trains): _trains = trains;
  

 final  List<Train> _trains;
 List<Train> get trains {
  if (_trains is EqualUnmodifiableListView) return _trains;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trains);
}


/// Create a copy of TimetableState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimetableLoadedCopyWith<TimetableLoaded> get copyWith => _$TimetableLoadedCopyWithImpl<TimetableLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimetableLoaded&&const DeepCollectionEquality().equals(other._trains, _trains));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_trains));

@override
String toString() {
  return 'TimetableState.loaded(trains: $trains)';
}


}

/// @nodoc
abstract mixin class $TimetableLoadedCopyWith<$Res> implements $TimetableStateCopyWith<$Res> {
  factory $TimetableLoadedCopyWith(TimetableLoaded value, $Res Function(TimetableLoaded) _then) = _$TimetableLoadedCopyWithImpl;
@useResult
$Res call({
 List<Train> trains
});




}
/// @nodoc
class _$TimetableLoadedCopyWithImpl<$Res>
    implements $TimetableLoadedCopyWith<$Res> {
  _$TimetableLoadedCopyWithImpl(this._self, this._then);

  final TimetableLoaded _self;
  final $Res Function(TimetableLoaded) _then;

/// Create a copy of TimetableState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? trains = null,}) {
  return _then(TimetableLoaded(
null == trains ? _self._trains : trains // ignore: cast_nullable_to_non_nullable
as List<Train>,
  ));
}


}

/// @nodoc


class TimetableEmpty implements TimetableState {
  const TimetableEmpty();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimetableEmpty);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TimetableState.empty()';
}


}




/// @nodoc


class TimetableError implements TimetableState {
  const TimetableError(this.message);
  

 final  String message;

/// Create a copy of TimetableState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimetableErrorCopyWith<TimetableError> get copyWith => _$TimetableErrorCopyWithImpl<TimetableError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimetableError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'TimetableState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $TimetableErrorCopyWith<$Res> implements $TimetableStateCopyWith<$Res> {
  factory $TimetableErrorCopyWith(TimetableError value, $Res Function(TimetableError) _then) = _$TimetableErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$TimetableErrorCopyWithImpl<$Res>
    implements $TimetableErrorCopyWith<$Res> {
  _$TimetableErrorCopyWithImpl(this._self, this._then);

  final TimetableError _self;
  final $Res Function(TimetableError) _then;

/// Create a copy of TimetableState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(TimetableError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
