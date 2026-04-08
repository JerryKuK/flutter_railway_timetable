import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../features/timetable/domain/entity/station.dart';
import '../../domain/entity/recent_search.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default('台北') String departureStation,
    @Default('1020') String departureStationId,
    @Default('高雄') String arrivalStation,
    @Default('3300') String arrivalStationId,
    required String date,
    required String time,
    @Default([]) List<RecentSearch> recentSearches,
    @Default(false) bool navigateToTimetable,
    @Default([]) List<Station> stations,
    @Default(false) bool isLoadingStations,
    String? stationsError,
  }) = _HomeState;
}
