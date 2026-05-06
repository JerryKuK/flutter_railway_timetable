import 'package:drift/drift.dart';
import '../../domain/entity/widget_station.dart';
import '../../domain/repository/i_widget_station_repository.dart';
import '../../domain/usecase/update_widget_stations_use_case.dart';
import '../database/widget_station_database.dart';

// Must match PickerStationDefaults in PickerStation.swift exactly.
const _trDefaults = [
  ('臺北', '1000'), ('板橋', '1020'), ('桃園', '1080'), ('新竹', '1210'),
  ('臺中', '3300'), ('臺南', '4220'), ('高雄', '4400'), ('花蓮', '7000'),
  ('臺東', '6000'), ('基隆', '0900'),
];
const _hsrDefaults = [
  ('南港', '0990'), ('臺北', '1000'), ('板橋', '1010'), ('桃園', '1020'),
  ('新竹', '1030'), ('臺中', '1040'), ('嘉義', '1050'), ('臺南', '1060'),
  ('左營', '1070'), ('苗栗', '1035'),
];

class WidgetStationRepositoryImpl implements IWidgetStationRepository {
  final WidgetStationDatabase _db;

  WidgetStationRepositoryImpl(this._db);

  @override
  Future<bool> tableExists() async {
    final rows = await _db.customSelect(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='widget_stations'",
    ).get();
    return rows.isNotEmpty;
  }

  @override
  Future<List<WidgetStation>> getStations(String system) async {
    final rows = await (_db.select(_db.widgetStations)
          ..where((t) => t.system.equals(system))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return rows
        .map((r) => WidgetStation(
              name: r.name,
              stationId: r.stationId,
              system: r.system,
              sortOrder: r.sortOrder,
            ))
        .toList();
  }

  @override
  Future<void> initDefaultsIfNeeded() async {
    await _db.transaction(() async {
      for (final entry in [('TR', _trDefaults), ('HSR', _hsrDefaults)]) {
        final system = entry.$1;
        final defaults = entry.$2;
        final existing = await (_db.select(_db.widgetStations)
              ..where((t) => t.system.equals(system)))
            .get();
        if (existing.isNotEmpty) continue;
        for (var i = 0; i < defaults.length; i++) {
          await _db.into(_db.widgetStations).insert(
                WidgetStationsCompanion.insert(
                  name: defaults[i].$1,
                  stationId: defaults[i].$2,
                  system: system,
                  sortOrder: Value(i),
                ),
              );
        }
      }
    });
  }

  @override
  Future<void> setFront({
    required String fromName,
    required String fromId,
    required String toName,
    required String toId,
    required String system,
  }) async {
    await _db.transaction(() async {
      final existing = await (_db.select(_db.widgetStations)
            ..where((t) => t.system.equals(system))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

      // Build new order: from first, to second, then remaining (preserving old order)
      final newOrder = <(String name, String id)>[];
      newOrder.add((fromName, fromId));
      if (toName != fromName) newOrder.add((toName, toId));
      for (final s in existing) {
        if (s.name != fromName && s.name != toName) {
          newOrder.add((s.name, s.stationId));
        }
      }

      final trimmed = newOrder.take(UpdateWidgetStationsUseCase.maxStations).toList();

      // Delete all rows for this system, then reinsert in new order
      await (_db.delete(_db.widgetStations)
            ..where((t) => t.system.equals(system)))
          .go();

      for (var i = 0; i < trimmed.length; i++) {
        await _db.into(_db.widgetStations).insert(
          WidgetStationsCompanion.insert(
            name: trimmed[i].$1,
            stationId: trimmed[i].$2,
            system: system,
            sortOrder: Value(i),
          ),
        );
      }
    });
  }
}
