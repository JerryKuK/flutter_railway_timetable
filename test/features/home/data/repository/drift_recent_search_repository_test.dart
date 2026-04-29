import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_railway_timetable/core/database/app_database.dart';
import 'package:flutter_railway_timetable/features/home/data/repository/drift_recent_search_repository.dart';
import 'package:flutter_railway_timetable/features/home/domain/entity/recent_search.dart';

void main() {
  late AppDatabase db;
  late DriftRecentSearchRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftRecentSearchRepository(db);
  });

  tearDown(() async => db.close());

  group('getRecentSearches', () {
    test('returns empty list initially', () async {
      final results = await repo.getRecentSearches();
      expect(results, isEmpty);
    });

    test('returns saved search after saveSearch', () async {
      await repo.saveSearch(const RecentSearch(
        departureStation: '台北',
        arrivalStation: '高雄',
        departureStationId: '1000',
        arrivalStationId: '3300',
        railwayType: 'tra',
      ));
      final results = await repo.getRecentSearches();
      expect(results.length, 1);
      expect(results.first.departureStation, '台北');
      expect(results.first.arrivalStation, '高雄');
      expect(results.first.railwayType, 'tra');
    });

    test('returns newest entry first', () async {
      await repo.saveSearch(const RecentSearch(
        departureStation: '台北', arrivalStation: '高雄',
        departureStationId: '1000', arrivalStationId: '3300',
        railwayType: 'tra',
      ));
      await repo.saveSearch(const RecentSearch(
        departureStation: '松山', arrivalStation: '板橋',
        departureStationId: '1020', arrivalStationId: '2000',
        railwayType: 'tra',
      ));
      final results = await repo.getRecentSearches();
      expect(results.first.departureStation, '松山');
    });
  });

  group('saveSearch', () {
    test('deduplicates same route for same railwayType', () async {
      const search = RecentSearch(
        departureStation: '台北', arrivalStation: '高雄',
        departureStationId: '1000', arrivalStationId: '3300',
        railwayType: 'tra',
      );
      await repo.saveSearch(search);
      await repo.saveSearch(search);
      final results = await repo.getRecentSearches();
      expect(results.length, 1);
    });

    test('does not deduplicate same route for different railwayType', () async {
      await repo.saveSearch(const RecentSearch(
        departureStation: '台北', arrivalStation: '高雄',
        departureStationId: '1000', arrivalStationId: '3300',
        railwayType: 'tra',
      ));
      await repo.saveSearch(const RecentSearch(
        departureStation: '台北', arrivalStation: '高雄',
        departureStationId: '1000', arrivalStationId: '3300',
        railwayType: 'hsr',
      ));
      final results = await repo.getRecentSearches();
      expect(results.length, 2);
    });

    test('keeps at most 5 entries per railway type', () async {
      for (int i = 1; i <= 6; i++) {
        await repo.saveSearch(RecentSearch(
          departureStation: '站$i',
          arrivalStation: '目的$i',
          departureStationId: '${1000 + i}',
          arrivalStationId: '${2000 + i}',
          railwayType: 'tra',
        ));
      }
      final traResults = await repo.getRecentSearches();
      final traOnly = traResults.where((s) => s.railwayType == 'tra').toList();
      expect(traOnly.length, 5);
    });
  });

  group('clearByRailwayType', () {
    test('removes only entries with specified railwayType', () async {
      await repo.saveSearch(const RecentSearch(
        departureStation: '台北', arrivalStation: '高雄',
        departureStationId: '1000', arrivalStationId: '3300',
        railwayType: 'tra',
      ));
      await repo.saveSearch(const RecentSearch(
        departureStation: '南港', arrivalStation: '左營',
        departureStationId: '0990', arrivalStationId: '9900',
        railwayType: 'hsr',
      ));

      await repo.clearByRailwayType('tra');

      final results = await repo.getRecentSearches();
      expect(results.length, 1);
      expect(results.first.railwayType, 'hsr');
    });

    test('does not affect entries of other railwayType', () async {
      await repo.saveSearch(const RecentSearch(
        departureStation: '南港', arrivalStation: '左營',
        departureStationId: '0990', arrivalStationId: '9900',
        railwayType: 'hsr',
      ));

      await repo.clearByRailwayType('tra');

      final results = await repo.getRecentSearches();
      expect(results.length, 1);
    });
  });

  group('getLastStationSelection', () {
    test('returns null when no data for railwayType', () async {
      final result = await repo.getLastStationSelection('tra');
      expect(result, isNull);
    });

    test('returns saved selection after saveLastStationSelection', () async {
      await repo.saveLastStationSelection(
        railwayType: 'tra',
        departureStation: '松山',
        departureStationId: '1020',
        arrivalStation: '板橋',
        arrivalStationId: '2000',
      );
      final result = await repo.getLastStationSelection('tra');
      expect(result, isNotNull);
      expect(result!['departureStation'], '松山');
      expect(result['departureStationId'], '1020');
      expect(result['arrivalStation'], '板橋');
      expect(result['arrivalStationId'], '2000');
    });
  });

  group('saveLastStationSelection', () {
    test('upserts when called twice for the same railwayType', () async {
      await repo.saveLastStationSelection(
        railwayType: 'tra',
        departureStation: '台北',
        departureStationId: '1000',
        arrivalStation: '高雄',
        arrivalStationId: '3300',
      );
      await repo.saveLastStationSelection(
        railwayType: 'tra',
        departureStation: '松山',
        departureStationId: '1020',
        arrivalStation: '板橋',
        arrivalStationId: '2000',
      );
      final result = await repo.getLastStationSelection('tra');
      expect(result!['departureStation'], '松山');
    });

    test('stores TRA and HSR selections independently', () async {
      await repo.saveLastStationSelection(
        railwayType: 'tra',
        departureStation: '台北', departureStationId: '1000',
        arrivalStation: '高雄', arrivalStationId: '3300',
      );
      await repo.saveLastStationSelection(
        railwayType: 'hsr',
        departureStation: '南港', departureStationId: '0990',
        arrivalStation: '左營', arrivalStationId: '9900',
      );

      final tra = await repo.getLastStationSelection('tra');
      final hsr = await repo.getLastStationSelection('hsr');

      expect(tra!['departureStation'], '台北');
      expect(hsr!['departureStation'], '南港');
    });
  });
}
