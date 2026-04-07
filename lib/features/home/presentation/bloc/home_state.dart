import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entity/recent_search.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default('台北車站') String departureStation,
    @Default('TPE') String departureStationId,
    @Default('高雄車站') String arrivalStation,
    @Default('KHH') String arrivalStationId,
    required String date,
    required String time,
    @Default([]) List<RecentSearch> recentSearches,
    @Default(false) bool navigateToTimetable,
  }) = _HomeState;
}
