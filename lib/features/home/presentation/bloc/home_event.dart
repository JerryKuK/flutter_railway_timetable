import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entity/recent_search.dart';

part 'home_event.freezed.dart';

@freezed
abstract class HomeEvent with _$HomeEvent {
  const factory HomeEvent.swapStations() = SwapStations;
  const factory HomeEvent.updateDate(String date) = UpdateDate;
  const factory HomeEvent.updateTime(String time) = UpdateTime;
  const factory HomeEvent.search() = Search;
  const factory HomeEvent.clearHistory() = ClearHistory;
  const factory HomeEvent.selectRecentSearch(RecentSearch search) =
      SelectRecentSearch;
  const factory HomeEvent.loadRecentSearches() = LoadRecentSearches;
}
