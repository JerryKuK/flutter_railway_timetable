// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HomeEvent()';
}


}

/// @nodoc
class $HomeEventCopyWith<$Res>  {
$HomeEventCopyWith(HomeEvent _, $Res Function(HomeEvent) __);
}


/// Adds pattern-matching-related methods to [HomeEvent].
extension HomeEventPatterns on HomeEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SwapStations value)?  swapStations,TResult Function( UpdateDate value)?  updateDate,TResult Function( UpdateTime value)?  updateTime,TResult Function( Search value)?  search,TResult Function( ClearHistory value)?  clearHistory,TResult Function( SelectRecentSearch value)?  selectRecentSearch,TResult Function( LoadRecentSearches value)?  loadRecentSearches,TResult Function( LoadStations value)?  loadStations,TResult Function( SelectDepartureStation value)?  selectDepartureStation,TResult Function( SelectArrivalStation value)?  selectArrivalStation,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SwapStations() when swapStations != null:
return swapStations(_that);case UpdateDate() when updateDate != null:
return updateDate(_that);case UpdateTime() when updateTime != null:
return updateTime(_that);case Search() when search != null:
return search(_that);case ClearHistory() when clearHistory != null:
return clearHistory(_that);case SelectRecentSearch() when selectRecentSearch != null:
return selectRecentSearch(_that);case LoadRecentSearches() when loadRecentSearches != null:
return loadRecentSearches(_that);case LoadStations() when loadStations != null:
return loadStations(_that);case SelectDepartureStation() when selectDepartureStation != null:
return selectDepartureStation(_that);case SelectArrivalStation() when selectArrivalStation != null:
return selectArrivalStation(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SwapStations value)  swapStations,required TResult Function( UpdateDate value)  updateDate,required TResult Function( UpdateTime value)  updateTime,required TResult Function( Search value)  search,required TResult Function( ClearHistory value)  clearHistory,required TResult Function( SelectRecentSearch value)  selectRecentSearch,required TResult Function( LoadRecentSearches value)  loadRecentSearches,required TResult Function( LoadStations value)  loadStations,required TResult Function( SelectDepartureStation value)  selectDepartureStation,required TResult Function( SelectArrivalStation value)  selectArrivalStation,}){
final _that = this;
switch (_that) {
case SwapStations():
return swapStations(_that);case UpdateDate():
return updateDate(_that);case UpdateTime():
return updateTime(_that);case Search():
return search(_that);case ClearHistory():
return clearHistory(_that);case SelectRecentSearch():
return selectRecentSearch(_that);case LoadRecentSearches():
return loadRecentSearches(_that);case LoadStations():
return loadStations(_that);case SelectDepartureStation():
return selectDepartureStation(_that);case SelectArrivalStation():
return selectArrivalStation(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SwapStations value)?  swapStations,TResult? Function( UpdateDate value)?  updateDate,TResult? Function( UpdateTime value)?  updateTime,TResult? Function( Search value)?  search,TResult? Function( ClearHistory value)?  clearHistory,TResult? Function( SelectRecentSearch value)?  selectRecentSearch,TResult? Function( LoadRecentSearches value)?  loadRecentSearches,TResult? Function( LoadStations value)?  loadStations,TResult? Function( SelectDepartureStation value)?  selectDepartureStation,TResult? Function( SelectArrivalStation value)?  selectArrivalStation,}){
final _that = this;
switch (_that) {
case SwapStations() when swapStations != null:
return swapStations(_that);case UpdateDate() when updateDate != null:
return updateDate(_that);case UpdateTime() when updateTime != null:
return updateTime(_that);case Search() when search != null:
return search(_that);case ClearHistory() when clearHistory != null:
return clearHistory(_that);case SelectRecentSearch() when selectRecentSearch != null:
return selectRecentSearch(_that);case LoadRecentSearches() when loadRecentSearches != null:
return loadRecentSearches(_that);case LoadStations() when loadStations != null:
return loadStations(_that);case SelectDepartureStation() when selectDepartureStation != null:
return selectDepartureStation(_that);case SelectArrivalStation() when selectArrivalStation != null:
return selectArrivalStation(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  swapStations,TResult Function( String date)?  updateDate,TResult Function( String time)?  updateTime,TResult Function()?  search,TResult Function()?  clearHistory,TResult Function( RecentSearch search)?  selectRecentSearch,TResult Function()?  loadRecentSearches,TResult Function()?  loadStations,TResult Function( Station station)?  selectDepartureStation,TResult Function( Station station)?  selectArrivalStation,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SwapStations() when swapStations != null:
return swapStations();case UpdateDate() when updateDate != null:
return updateDate(_that.date);case UpdateTime() when updateTime != null:
return updateTime(_that.time);case Search() when search != null:
return search();case ClearHistory() when clearHistory != null:
return clearHistory();case SelectRecentSearch() when selectRecentSearch != null:
return selectRecentSearch(_that.search);case LoadRecentSearches() when loadRecentSearches != null:
return loadRecentSearches();case LoadStations() when loadStations != null:
return loadStations();case SelectDepartureStation() when selectDepartureStation != null:
return selectDepartureStation(_that.station);case SelectArrivalStation() when selectArrivalStation != null:
return selectArrivalStation(_that.station);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  swapStations,required TResult Function( String date)  updateDate,required TResult Function( String time)  updateTime,required TResult Function()  search,required TResult Function()  clearHistory,required TResult Function( RecentSearch search)  selectRecentSearch,required TResult Function()  loadRecentSearches,required TResult Function()  loadStations,required TResult Function( Station station)  selectDepartureStation,required TResult Function( Station station)  selectArrivalStation,}) {final _that = this;
switch (_that) {
case SwapStations():
return swapStations();case UpdateDate():
return updateDate(_that.date);case UpdateTime():
return updateTime(_that.time);case Search():
return search();case ClearHistory():
return clearHistory();case SelectRecentSearch():
return selectRecentSearch(_that.search);case LoadRecentSearches():
return loadRecentSearches();case LoadStations():
return loadStations();case SelectDepartureStation():
return selectDepartureStation(_that.station);case SelectArrivalStation():
return selectArrivalStation(_that.station);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  swapStations,TResult? Function( String date)?  updateDate,TResult? Function( String time)?  updateTime,TResult? Function()?  search,TResult? Function()?  clearHistory,TResult? Function( RecentSearch search)?  selectRecentSearch,TResult? Function()?  loadRecentSearches,TResult? Function()?  loadStations,TResult? Function( Station station)?  selectDepartureStation,TResult? Function( Station station)?  selectArrivalStation,}) {final _that = this;
switch (_that) {
case SwapStations() when swapStations != null:
return swapStations();case UpdateDate() when updateDate != null:
return updateDate(_that.date);case UpdateTime() when updateTime != null:
return updateTime(_that.time);case Search() when search != null:
return search();case ClearHistory() when clearHistory != null:
return clearHistory();case SelectRecentSearch() when selectRecentSearch != null:
return selectRecentSearch(_that.search);case LoadRecentSearches() when loadRecentSearches != null:
return loadRecentSearches();case LoadStations() when loadStations != null:
return loadStations();case SelectDepartureStation() when selectDepartureStation != null:
return selectDepartureStation(_that.station);case SelectArrivalStation() when selectArrivalStation != null:
return selectArrivalStation(_that.station);case _:
  return null;

}
}

}

/// @nodoc


class SwapStations implements HomeEvent {
  const SwapStations();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwapStations);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HomeEvent.swapStations()';
}


}




/// @nodoc


class UpdateDate implements HomeEvent {
  const UpdateDate(this.date);
  

 final  String date;

/// Create a copy of HomeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateDateCopyWith<UpdateDate> get copyWith => _$UpdateDateCopyWithImpl<UpdateDate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateDate&&(identical(other.date, date) || other.date == date));
}


@override
int get hashCode => Object.hash(runtimeType,date);

@override
String toString() {
  return 'HomeEvent.updateDate(date: $date)';
}


}

/// @nodoc
abstract mixin class $UpdateDateCopyWith<$Res> implements $HomeEventCopyWith<$Res> {
  factory $UpdateDateCopyWith(UpdateDate value, $Res Function(UpdateDate) _then) = _$UpdateDateCopyWithImpl;
@useResult
$Res call({
 String date
});




}
/// @nodoc
class _$UpdateDateCopyWithImpl<$Res>
    implements $UpdateDateCopyWith<$Res> {
  _$UpdateDateCopyWithImpl(this._self, this._then);

  final UpdateDate _self;
  final $Res Function(UpdateDate) _then;

/// Create a copy of HomeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? date = null,}) {
  return _then(UpdateDate(
null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UpdateTime implements HomeEvent {
  const UpdateTime(this.time);
  

 final  String time;

/// Create a copy of HomeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateTimeCopyWith<UpdateTime> get copyWith => _$UpdateTimeCopyWithImpl<UpdateTime>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateTime&&(identical(other.time, time) || other.time == time));
}


@override
int get hashCode => Object.hash(runtimeType,time);

@override
String toString() {
  return 'HomeEvent.updateTime(time: $time)';
}


}

/// @nodoc
abstract mixin class $UpdateTimeCopyWith<$Res> implements $HomeEventCopyWith<$Res> {
  factory $UpdateTimeCopyWith(UpdateTime value, $Res Function(UpdateTime) _then) = _$UpdateTimeCopyWithImpl;
@useResult
$Res call({
 String time
});




}
/// @nodoc
class _$UpdateTimeCopyWithImpl<$Res>
    implements $UpdateTimeCopyWith<$Res> {
  _$UpdateTimeCopyWithImpl(this._self, this._then);

  final UpdateTime _self;
  final $Res Function(UpdateTime) _then;

/// Create a copy of HomeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? time = null,}) {
  return _then(UpdateTime(
null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class Search implements HomeEvent {
  const Search();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Search);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HomeEvent.search()';
}


}




/// @nodoc


class ClearHistory implements HomeEvent {
  const ClearHistory();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClearHistory);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HomeEvent.clearHistory()';
}


}




/// @nodoc


class SelectRecentSearch implements HomeEvent {
  const SelectRecentSearch(this.search);
  

 final  RecentSearch search;

/// Create a copy of HomeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectRecentSearchCopyWith<SelectRecentSearch> get copyWith => _$SelectRecentSearchCopyWithImpl<SelectRecentSearch>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectRecentSearch&&(identical(other.search, search) || other.search == search));
}


@override
int get hashCode => Object.hash(runtimeType,search);

@override
String toString() {
  return 'HomeEvent.selectRecentSearch(search: $search)';
}


}

/// @nodoc
abstract mixin class $SelectRecentSearchCopyWith<$Res> implements $HomeEventCopyWith<$Res> {
  factory $SelectRecentSearchCopyWith(SelectRecentSearch value, $Res Function(SelectRecentSearch) _then) = _$SelectRecentSearchCopyWithImpl;
@useResult
$Res call({
 RecentSearch search
});


$RecentSearchCopyWith<$Res> get search;

}
/// @nodoc
class _$SelectRecentSearchCopyWithImpl<$Res>
    implements $SelectRecentSearchCopyWith<$Res> {
  _$SelectRecentSearchCopyWithImpl(this._self, this._then);

  final SelectRecentSearch _self;
  final $Res Function(SelectRecentSearch) _then;

/// Create a copy of HomeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? search = null,}) {
  return _then(SelectRecentSearch(
null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as RecentSearch,
  ));
}

/// Create a copy of HomeEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecentSearchCopyWith<$Res> get search {
  
  return $RecentSearchCopyWith<$Res>(_self.search, (value) {
    return _then(_self.copyWith(search: value));
  });
}
}

/// @nodoc


class LoadRecentSearches implements HomeEvent {
  const LoadRecentSearches();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadRecentSearches);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HomeEvent.loadRecentSearches()';
}


}




/// @nodoc


class LoadStations implements HomeEvent {
  const LoadStations();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadStations);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HomeEvent.loadStations()';
}


}




/// @nodoc


class SelectDepartureStation implements HomeEvent {
  const SelectDepartureStation(this.station);
  

 final  Station station;

/// Create a copy of HomeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectDepartureStationCopyWith<SelectDepartureStation> get copyWith => _$SelectDepartureStationCopyWithImpl<SelectDepartureStation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectDepartureStation&&(identical(other.station, station) || other.station == station));
}


@override
int get hashCode => Object.hash(runtimeType,station);

@override
String toString() {
  return 'HomeEvent.selectDepartureStation(station: $station)';
}


}

/// @nodoc
abstract mixin class $SelectDepartureStationCopyWith<$Res> implements $HomeEventCopyWith<$Res> {
  factory $SelectDepartureStationCopyWith(SelectDepartureStation value, $Res Function(SelectDepartureStation) _then) = _$SelectDepartureStationCopyWithImpl;
@useResult
$Res call({
 Station station
});


$StationCopyWith<$Res> get station;

}
/// @nodoc
class _$SelectDepartureStationCopyWithImpl<$Res>
    implements $SelectDepartureStationCopyWith<$Res> {
  _$SelectDepartureStationCopyWithImpl(this._self, this._then);

  final SelectDepartureStation _self;
  final $Res Function(SelectDepartureStation) _then;

/// Create a copy of HomeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? station = null,}) {
  return _then(SelectDepartureStation(
null == station ? _self.station : station // ignore: cast_nullable_to_non_nullable
as Station,
  ));
}

/// Create a copy of HomeEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StationCopyWith<$Res> get station {
  
  return $StationCopyWith<$Res>(_self.station, (value) {
    return _then(_self.copyWith(station: value));
  });
}
}

/// @nodoc


class SelectArrivalStation implements HomeEvent {
  const SelectArrivalStation(this.station);
  

 final  Station station;

/// Create a copy of HomeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectArrivalStationCopyWith<SelectArrivalStation> get copyWith => _$SelectArrivalStationCopyWithImpl<SelectArrivalStation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectArrivalStation&&(identical(other.station, station) || other.station == station));
}


@override
int get hashCode => Object.hash(runtimeType,station);

@override
String toString() {
  return 'HomeEvent.selectArrivalStation(station: $station)';
}


}

/// @nodoc
abstract mixin class $SelectArrivalStationCopyWith<$Res> implements $HomeEventCopyWith<$Res> {
  factory $SelectArrivalStationCopyWith(SelectArrivalStation value, $Res Function(SelectArrivalStation) _then) = _$SelectArrivalStationCopyWithImpl;
@useResult
$Res call({
 Station station
});


$StationCopyWith<$Res> get station;

}
/// @nodoc
class _$SelectArrivalStationCopyWithImpl<$Res>
    implements $SelectArrivalStationCopyWith<$Res> {
  _$SelectArrivalStationCopyWithImpl(this._self, this._then);

  final SelectArrivalStation _self;
  final $Res Function(SelectArrivalStation) _then;

/// Create a copy of HomeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? station = null,}) {
  return _then(SelectArrivalStation(
null == station ? _self.station : station // ignore: cast_nullable_to_non_nullable
as Station,
  ));
}

/// Create a copy of HomeEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StationCopyWith<$Res> get station {
  
  return $StationCopyWith<$Res>(_self.station, (value) {
    return _then(_self.copyWith(station: value));
  });
}
}

// dart format on
