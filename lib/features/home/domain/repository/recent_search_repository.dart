import '../entity/recent_search.dart';

abstract class RecentSearchRepository {
  Future<List<RecentSearch>> getRecentSearches();
  Future<void> saveSearch(RecentSearch search);
  Future<void> clearByRailwayType(String railwayType);
  Future<Map<String, String>?> getLastStationSelection(String railwayType);
  Future<void> saveLastStationSelection({
    required String railwayType,
    required String departureStation,
    required String departureStationId,
    required String arrivalStation,
    required String arrivalStationId,
  });
}
