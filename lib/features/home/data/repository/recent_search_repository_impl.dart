import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entity/recent_search.dart';
import '../../domain/repository/recent_search_repository.dart';

@LazySingleton(as: RecentSearchRepository)
class SharedPreferencesRecentSearchRepository
    implements RecentSearchRepository {
  static const _key = 'recent_searches';
  static const _maxCount = 5;

  @override
  Future<List<RecentSearch>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList.map((json) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return RecentSearch(
        departureStation: map['departureStation'] as String,
        arrivalStation: map['arrivalStation'] as String,
        departureStationId: map['departureStationId'] as String,
        arrivalStationId: map['arrivalStationId'] as String,
        railwayType: map['railwayType'] as String? ?? 'tra',
      );
    }).toList();
  }

  @override
  Future<void> saveSearch(RecentSearch search) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getRecentSearches();
    final updated = [
      search,
      ...existing.where(
        (s) =>
            s.departureStationId != search.departureStationId ||
            s.arrivalStationId != search.arrivalStationId,
      ),
    ].take(_maxCount).toList();
    await prefs.setStringList(
      _key,
      updated
          .map((s) => jsonEncode({
                'departureStation': s.departureStation,
                'arrivalStation': s.arrivalStation,
                'departureStationId': s.departureStationId,
                'arrivalStationId': s.arrivalStationId,
                'railwayType': s.railwayType,
              }))
          .toList(),
    );
  }

  @override
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
