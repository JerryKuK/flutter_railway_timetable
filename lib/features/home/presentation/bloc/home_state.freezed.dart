// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeState {

 String get departureStation; String get departureStationId; String get arrivalStation; String get arrivalStationId; String get date; String get time; List<RecentSearch> get recentSearches; bool get navigateToTimetable; List<Station> get stations; bool get isLoadingStations; String? get stationsError;
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateCopyWith<HomeState> get copyWith => _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState&&(identical(other.departureStation, departureStation) || other.departureStation == departureStation)&&(identical(other.departureStationId, departureStationId) || other.departureStationId == departureStationId)&&(identical(other.arrivalStation, arrivalStation) || other.arrivalStation == arrivalStation)&&(identical(other.arrivalStationId, arrivalStationId) || other.arrivalStationId == arrivalStationId)&&(identical(other.date, date) || other.date == date)&&(identical(other.time, time) || other.time == time)&&const DeepCollectionEquality().equals(other.recentSearches, recentSearches)&&(identical(other.navigateToTimetable, navigateToTimetable) || other.navigateToTimetable == navigateToTimetable)&&const DeepCollectionEquality().equals(other.stations, stations)&&(identical(other.isLoadingStations, isLoadingStations) || other.isLoadingStations == isLoadingStations)&&(identical(other.stationsError, stationsError) || other.stationsError == stationsError));
}


@override
int get hashCode => Object.hash(runtimeType,departureStation,departureStationId,arrivalStation,arrivalStationId,date,time,const DeepCollectionEquality().hash(recentSearches),navigateToTimetable,const DeepCollectionEquality().hash(stations),isLoadingStations,stationsError);

@override
String toString() {
  return 'HomeState(departureStation: $departureStation, departureStationId: $departureStationId, arrivalStation: $arrivalStation, arrivalStationId: $arrivalStationId, date: $date, time: $time, recentSearches: $recentSearches, navigateToTimetable: $navigateToTimetable, stations: $stations, isLoadingStations: $isLoadingStations, stationsError: $stationsError)';
}


}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res>  {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) = _$HomeStateCopyWithImpl;
@useResult
$Res call({
 String departureStation, String departureStationId, String arrivalStation, String arrivalStationId, String date, String time, List<RecentSearch> recentSearches, bool navigateToTimetable, List<Station> stations, bool isLoadingStations, String? stationsError
});




}
/// @nodoc
class _$HomeStateCopyWithImpl<$Res>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? departureStation = null,Object? departureStationId = null,Object? arrivalStation = null,Object? arrivalStationId = null,Object? date = null,Object? time = null,Object? recentSearches = null,Object? navigateToTimetable = null,Object? stations = null,Object? isLoadingStations = null,Object? stationsError = freezed,}) {
  return _then(_self.copyWith(
departureStation: null == departureStation ? _self.departureStation : departureStation // ignore: cast_nullable_to_non_nullable
as String,departureStationId: null == departureStationId ? _self.departureStationId : departureStationId // ignore: cast_nullable_to_non_nullable
as String,arrivalStation: null == arrivalStation ? _self.arrivalStation : arrivalStation // ignore: cast_nullable_to_non_nullable
as String,arrivalStationId: null == arrivalStationId ? _self.arrivalStationId : arrivalStationId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,recentSearches: null == recentSearches ? _self.recentSearches : recentSearches // ignore: cast_nullable_to_non_nullable
as List<RecentSearch>,navigateToTimetable: null == navigateToTimetable ? _self.navigateToTimetable : navigateToTimetable // ignore: cast_nullable_to_non_nullable
as bool,stations: null == stations ? _self.stations : stations // ignore: cast_nullable_to_non_nullable
as List<Station>,isLoadingStations: null == isLoadingStations ? _self.isLoadingStations : isLoadingStations // ignore: cast_nullable_to_non_nullable
as bool,stationsError: freezed == stationsError ? _self.stationsError : stationsError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeState value)  $default,){
final _that = this;
switch (_that) {
case _HomeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String departureStation,  String departureStationId,  String arrivalStation,  String arrivalStationId,  String date,  String time,  List<RecentSearch> recentSearches,  bool navigateToTimetable,  List<Station> stations,  bool isLoadingStations,  String? stationsError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.departureStation,_that.departureStationId,_that.arrivalStation,_that.arrivalStationId,_that.date,_that.time,_that.recentSearches,_that.navigateToTimetable,_that.stations,_that.isLoadingStations,_that.stationsError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String departureStation,  String departureStationId,  String arrivalStation,  String arrivalStationId,  String date,  String time,  List<RecentSearch> recentSearches,  bool navigateToTimetable,  List<Station> stations,  bool isLoadingStations,  String? stationsError)  $default,) {final _that = this;
switch (_that) {
case _HomeState():
return $default(_that.departureStation,_that.departureStationId,_that.arrivalStation,_that.arrivalStationId,_that.date,_that.time,_that.recentSearches,_that.navigateToTimetable,_that.stations,_that.isLoadingStations,_that.stationsError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String departureStation,  String departureStationId,  String arrivalStation,  String arrivalStationId,  String date,  String time,  List<RecentSearch> recentSearches,  bool navigateToTimetable,  List<Station> stations,  bool isLoadingStations,  String? stationsError)?  $default,) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.departureStation,_that.departureStationId,_that.arrivalStation,_that.arrivalStationId,_that.date,_that.time,_that.recentSearches,_that.navigateToTimetable,_that.stations,_that.isLoadingStations,_that.stationsError);case _:
  return null;

}
}

}

/// @nodoc


class _HomeState implements HomeState {
  const _HomeState({this.departureStation = '台北', this.departureStationId = '1020', this.arrivalStation = '高雄', this.arrivalStationId = '3300', required this.date, required this.time, final  List<RecentSearch> recentSearches = const [], this.navigateToTimetable = false, final  List<Station> stations = const [], this.isLoadingStations = false, this.stationsError}): _recentSearches = recentSearches,_stations = stations;
  

@override@JsonKey() final  String departureStation;
@override@JsonKey() final  String departureStationId;
@override@JsonKey() final  String arrivalStation;
@override@JsonKey() final  String arrivalStationId;
@override final  String date;
@override final  String time;
 final  List<RecentSearch> _recentSearches;
@override@JsonKey() List<RecentSearch> get recentSearches {
  if (_recentSearches is EqualUnmodifiableListView) return _recentSearches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentSearches);
}

@override@JsonKey() final  bool navigateToTimetable;
 final  List<Station> _stations;
@override@JsonKey() List<Station> get stations {
  if (_stations is EqualUnmodifiableListView) return _stations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stations);
}

@override@JsonKey() final  bool isLoadingStations;
@override final  String? stationsError;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStateCopyWith<_HomeState> get copyWith => __$HomeStateCopyWithImpl<_HomeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeState&&(identical(other.departureStation, departureStation) || other.departureStation == departureStation)&&(identical(other.departureStationId, departureStationId) || other.departureStationId == departureStationId)&&(identical(other.arrivalStation, arrivalStation) || other.arrivalStation == arrivalStation)&&(identical(other.arrivalStationId, arrivalStationId) || other.arrivalStationId == arrivalStationId)&&(identical(other.date, date) || other.date == date)&&(identical(other.time, time) || other.time == time)&&const DeepCollectionEquality().equals(other._recentSearches, _recentSearches)&&(identical(other.navigateToTimetable, navigateToTimetable) || other.navigateToTimetable == navigateToTimetable)&&const DeepCollectionEquality().equals(other._stations, _stations)&&(identical(other.isLoadingStations, isLoadingStations) || other.isLoadingStations == isLoadingStations)&&(identical(other.stationsError, stationsError) || other.stationsError == stationsError));
}


@override
int get hashCode => Object.hash(runtimeType,departureStation,departureStationId,arrivalStation,arrivalStationId,date,time,const DeepCollectionEquality().hash(_recentSearches),navigateToTimetable,const DeepCollectionEquality().hash(_stations),isLoadingStations,stationsError);

@override
String toString() {
  return 'HomeState(departureStation: $departureStation, departureStationId: $departureStationId, arrivalStation: $arrivalStation, arrivalStationId: $arrivalStationId, date: $date, time: $time, recentSearches: $recentSearches, navigateToTimetable: $navigateToTimetable, stations: $stations, isLoadingStations: $isLoadingStations, stationsError: $stationsError)';
}


}

/// @nodoc
abstract mixin class _$HomeStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateCopyWith(_HomeState value, $Res Function(_HomeState) _then) = __$HomeStateCopyWithImpl;
@override @useResult
$Res call({
 String departureStation, String departureStationId, String arrivalStation, String arrivalStationId, String date, String time, List<RecentSearch> recentSearches, bool navigateToTimetable, List<Station> stations, bool isLoadingStations, String? stationsError
});




}
/// @nodoc
class __$HomeStateCopyWithImpl<$Res>
    implements _$HomeStateCopyWith<$Res> {
  __$HomeStateCopyWithImpl(this._self, this._then);

  final _HomeState _self;
  final $Res Function(_HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? departureStation = null,Object? departureStationId = null,Object? arrivalStation = null,Object? arrivalStationId = null,Object? date = null,Object? time = null,Object? recentSearches = null,Object? navigateToTimetable = null,Object? stations = null,Object? isLoadingStations = null,Object? stationsError = freezed,}) {
  return _then(_HomeState(
departureStation: null == departureStation ? _self.departureStation : departureStation // ignore: cast_nullable_to_non_nullable
as String,departureStationId: null == departureStationId ? _self.departureStationId : departureStationId // ignore: cast_nullable_to_non_nullable
as String,arrivalStation: null == arrivalStation ? _self.arrivalStation : arrivalStation // ignore: cast_nullable_to_non_nullable
as String,arrivalStationId: null == arrivalStationId ? _self.arrivalStationId : arrivalStationId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,recentSearches: null == recentSearches ? _self._recentSearches : recentSearches // ignore: cast_nullable_to_non_nullable
as List<RecentSearch>,navigateToTimetable: null == navigateToTimetable ? _self.navigateToTimetable : navigateToTimetable // ignore: cast_nullable_to_non_nullable
as bool,stations: null == stations ? _self._stations : stations // ignore: cast_nullable_to_non_nullable
as List<Station>,isLoadingStations: null == isLoadingStations ? _self.isLoadingStations : isLoadingStations // ignore: cast_nullable_to_non_nullable
as bool,stationsError: freezed == stationsError ? _self.stationsError : stationsError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
