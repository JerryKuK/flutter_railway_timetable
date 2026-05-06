import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_railway_timetable/features/widget_config/data/database/widget_station_database.dart';
import 'package:flutter_railway_timetable/features/widget_config/data/repository/widget_station_repository_impl.dart';

void main() {
  late WidgetStationDatabase db;
  late WidgetStationRepositoryImpl repo;

  setUp(() {
    db = WidgetStationDatabase.forTesting(NativeDatabase.memory());
    repo = WidgetStationRepositoryImpl(db);
  });

  tearDown(() async => db.close());

  // MARK: - tableExists

  group('tableExists', () {
    test('returns true after database is opened (Drift creates tables on open)', () async {
      final exists = await repo.tableExists();
      expect(exists, isTrue);
    });
  });

  // MARK: - initDefaultsIfNeeded

  group('initDefaultsIfNeeded', () {
    test('seeds 10 TR stations on first call', () async {
      await repo.initDefaultsIfNeeded();
      final tr = await repo.getStations('TR');
      expect(tr.length, 10);
    });

    test('seeds 10 HSR stations on first call', () async {
      await repo.initDefaultsIfNeeded();
      final hsr = await repo.getStations('HSR');
      expect(hsr.length, 10);
    });

    test('is idempotent — calling twice does not duplicate rows', () async {
      await repo.initDefaultsIfNeeded();
      await repo.initDefaultsIfNeeded();
      final tr = await repo.getStations('TR');
      expect(tr.length, 10);
    });

    test('TR default first station is 臺北', () async {
      await repo.initDefaultsIfNeeded();
      final tr = await repo.getStations('TR');
      expect(tr.first.name, '臺北');
      expect(tr.first.stationId, '1000');
    });

    test('HSR default first station is 南港', () async {
      await repo.initDefaultsIfNeeded();
      final hsr = await repo.getStations('HSR');
      expect(hsr.first.name, '南港');
      expect(hsr.first.stationId, '0990');
    });
  });

  // MARK: - getStations

  group('getStations', () {
    test('returns empty list when no stations seeded', () async {
      final result = await repo.getStations('TR');
      expect(result, isEmpty);
    });

    test('returns stations ordered by sortOrder', () async {
      await repo.initDefaultsIfNeeded();
      final tr = await repo.getStations('TR');
      final orders = tr.map((s) => s.sortOrder).toList();
      expect(orders, equals(List.generate(10, (i) => i)));
    });
  });

  // MARK: - setFront

  group('setFront', () {
    setUp(() async => repo.initDefaultsIfNeeded());

    test('promotes fromStation to index 0', () async {
      await repo.setFront(fromName: '高雄', fromId: '4400', toName: '板橋', toId: '1020', system: 'TR');
      final tr = await repo.getStations('TR');
      expect(tr[0].name, '高雄');
    });

    test('promotes toStation to index 1 when different from fromStation', () async {
      await repo.setFront(fromName: '高雄', fromId: '4400', toName: '板橋', toId: '1020', system: 'TR');
      final tr = await repo.getStations('TR');
      expect(tr[1].name, '板橋');
    });

    test('preserves total count at 10', () async {
      await repo.setFront(fromName: '高雄', fromId: '4400', toName: '板橋', toId: '1020', system: 'TR');
      final tr = await repo.getStations('TR');
      expect(tr.length, 10);
    });

    test('when fromStation equals toStation, index 1 is NOT toStation', () async {
      await repo.setFront(fromName: '臺北', fromId: '1000', toName: '臺北', toId: '1000', system: 'TR');
      final tr = await repo.getStations('TR');
      expect(tr[0].name, '臺北');
      expect(tr[1].name, isNot('臺北'));
    });

    test('does not affect HSR stations', () async {
      final hsrBefore = await repo.getStations('HSR');
      await repo.setFront(fromName: '高雄', fromId: '4400', toName: '板橋', toId: '1020', system: 'TR');
      final hsrAfter = await repo.getStations('HSR');
      expect(hsrAfter.map((s) => s.name).toList(), equals(hsrBefore.map((s) => s.name).toList()));
    });

    test('adds new station not previously in list', () async {
      await repo.setFront(fromName: '七堵', fromId: '0910', toName: '基隆', toId: '0900', system: 'TR');
      final tr = await repo.getStations('TR');
      expect(tr[0].name, '七堵');
      expect(tr[1].name, '基隆');
      expect(tr.length, 10);
    });
  });
}