import 'package:freezed_annotation/freezed_annotation.dart';

part 'recent_search.freezed.dart';

@freezed
abstract class RecentSearch with _$RecentSearch {
  const factory RecentSearch({
    required String departureStation,
    required String arrivalStation,
    required String departureStationId,
    required String arrivalStationId,
    @Default('tra') String railwayType,
  }) = _RecentSearch;
}
