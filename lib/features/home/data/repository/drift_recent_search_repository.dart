import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entity/recent_search.dart';
import '../../domain/repository/recent_search_repository.dart';

@LazySingleton(as: RecentSearchRepository)
class DriftRecentSearchRepository implements RecentSearchRepository {
  static const _maxCount = 5;

  final AppDatabase _db;

  DriftRecentSearchRepository(this._db);

  @override
  Future<List<RecentSearch>> getRecentSearches() async {
    final rows = await (
      _db.select(_db.recentSearches)
        ..orderBy([
          (t) => OrderingTerm.desc(t.searchedAt),
          (t) => OrderingTerm.desc(t.id),
        ])
    ).get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<void> saveSearch(RecentSearch search) async {
    await _db.transaction(() async {
      await (_db.delete(_db.recentSearches)
            ..where(
              (t) =>
                  t.departureStationId.equals(search.departureStationId) &
                  t.arrivalStationId.equals(search.arrivalStationId) &
                  t.railwayType.equals(search.railwayType),
            ))
          .go();

      await _db.into(_db.recentSearches).insert(
            RecentSearchesCompanion.insert(
              departureStation: search.departureStation,
              arrivalStation: search.arrivalStation,
              departureStationId: search.departureStationId,
              arrivalStationId: search.arrivalStationId,
              railwayType: Value(search.railwayType),
              searchedAt: DateTime.now(),
            ),
          );

      final all = await (
        _db.select(_db.recentSearches)
          ..where((t) => t.railwayType.equals(search.railwayType))
          ..orderBy([
            (t) => OrderingTerm.desc(t.searchedAt),
            (t) => OrderingTerm.desc(t.id),
          ])
      ).get();

      if (all.length > _maxCount) {
        final toDelete = all.sublist(_maxCount).map((r) => r.id).toList();
        await (_db.delete(_db.recentSearches)
              ..where((t) => t.id.isIn(toDelete)))
            .go();
      }
    });
  }

  @override
  Future<void> clearByRailwayType(String railwayType) async {
    await (_db.delete(_db.recentSearches)
          ..where((t) => t.railwayType.equals(railwayType)))
        .go();
  }

  @override
  Future<Map<String, String>?> getLastStationSelection(
      String railwayType) async {
    final row = await (_db.select(_db.lastStationSelections)
          ..where((t) => t.railwayType.equals(railwayType)))
        .getSingleOrNull();
    if (row == null) return null;
    return {
      'departureStation': row.departureStation,
      'departureStationId': row.departureStationId,
      'arrivalStation': row.arrivalStation,
      'arrivalStationId': row.arrivalStationId,
    };
  }

  @override
  Future<void> saveLastStationSelection({
    required String railwayType,
    required String departureStation,
    required String departureStationId,
    required String arrivalStation,
    required String arrivalStationId,
  }) async {
    await _db.into(_db.lastStationSelections).insertOnConflictUpdate(
          LastStationSelectionsCompanion.insert(
            railwayType: railwayType,
            departureStation: departureStation,
            departureStationId: departureStationId,
            arrivalStation: arrivalStation,
            arrivalStationId: arrivalStationId,
          ),
        );
  }

  RecentSearch _toEntity(RecentSearchRow row) => RecentSearch(
        departureStation: row.departureStation,
        arrivalStation: row.arrivalStation,
        departureStationId: row.departureStationId,
        arrivalStationId: row.arrivalStationId,
        railwayType: row.railwayType,
      );
}
