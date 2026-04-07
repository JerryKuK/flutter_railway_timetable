import '../entity/recent_search.dart';

abstract class RecentSearchRepository {
  Future<List<RecentSearch>> getRecentSearches();
  Future<void> saveSearch(RecentSearch search);
  Future<void> clearAll();
}
