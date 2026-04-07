// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_tickets_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MyTicketsState {

 List<Ticket> get tickets;
/// Create a copy of MyTicketsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyTicketsStateCopyWith<MyTicketsState> get copyWith => _$MyTicketsStateCopyWithImpl<MyTicketsState>(this as MyTicketsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyTicketsState&&const DeepCollectionEquality().equals(other.tickets, tickets));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tickets));

@override
String toString() {
  return 'MyTicketsState(tickets: $tickets)';
}


}

/// @nodoc
abstract mixin class $MyTicketsStateCopyWith<$Res>  {
  factory $MyTicketsStateCopyWith(MyTicketsState value, $Res Function(MyTicketsState) _then) = _$MyTicketsStateCopyWithImpl;
@useResult
$Res call({
 List<Ticket> tickets
});




}
/// @nodoc
class _$MyTicketsStateCopyWithImpl<$Res>
    implements $MyTicketsStateCopyWith<$Res> {
  _$MyTicketsStateCopyWithImpl(this._self, this._then);

  final MyTicketsState _self;
  final $Res Function(MyTicketsState) _then;

/// Create a copy of MyTicketsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tickets = null,}) {
  return _then(_self.copyWith(
tickets: null == tickets ? _self.tickets : tickets // ignore: cast_nullable_to_non_nullable
as List<Ticket>,
  ));
}

}


/// Adds pattern-matching-related methods to [MyTicketsState].
extension MyTicketsStatePatterns on MyTicketsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyTicketsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyTicketsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyTicketsState value)  $default,){
final _that = this;
switch (_that) {
case _MyTicketsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyTicketsState value)?  $default,){
final _that = this;
switch (_that) {
case _MyTicketsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Ticket> tickets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyTicketsState() when $default != null:
return $default(_that.tickets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Ticket> tickets)  $default,) {final _that = this;
switch (_that) {
case _MyTicketsState():
return $default(_that.tickets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Ticket> tickets)?  $default,) {final _that = this;
switch (_that) {
case _MyTicketsState() when $default != null:
return $default(_that.tickets);case _:
  return null;

}
}

}

/// @nodoc


class _MyTicketsState implements MyTicketsState {
  const _MyTicketsState({required final  List<Ticket> tickets}): _tickets = tickets;
  

 final  List<Ticket> _tickets;
@override List<Ticket> get tickets {
  if (_tickets is EqualUnmodifiableListView) return _tickets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tickets);
}


/// Create a copy of MyTicketsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyTicketsStateCopyWith<_MyTicketsState> get copyWith => __$MyTicketsStateCopyWithImpl<_MyTicketsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyTicketsState&&const DeepCollectionEquality().equals(other._tickets, _tickets));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tickets));

@override
String toString() {
  return 'MyTicketsState(tickets: $tickets)';
}


}

/// @nodoc
abstract mixin class _$MyTicketsStateCopyWith<$Res> implements $MyTicketsStateCopyWith<$Res> {
  factory _$MyTicketsStateCopyWith(_MyTicketsState value, $Res Function(_MyTicketsState) _then) = __$MyTicketsStateCopyWithImpl;
@override @useResult
$Res call({
 List<Ticket> tickets
});




}
/// @nodoc
class __$MyTicketsStateCopyWithImpl<$Res>
    implements _$MyTicketsStateCopyWith<$Res> {
  __$MyTicketsStateCopyWithImpl(this._self, this._then);

  final _MyTicketsState _self;
  final $Res Function(_MyTicketsState) _then;

/// Create a copy of MyTicketsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tickets = null,}) {
  return _then(_MyTicketsState(
tickets: null == tickets ? _self._tickets : tickets // ignore: cast_nullable_to_non_nullable
as List<Ticket>,
  ));
}


}

// dart format on
