import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'widget_station_database.g.dart';

@DataClassName('WidgetStationRow')
class WidgetStations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get stationId => text()();
  TextColumn get system => text()();   // 'TR' or 'HSR'
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {name, system}
      ];
}

@DriftDatabase(tables: [WidgetStations])
class WidgetStationDatabase extends _$WidgetStationDatabase {
  WidgetStationDatabase(String dbPath)
      : super(
          NativeDatabase(
            File(dbPath),
            setup: (db) => db.execute('PRAGMA journal_mode=WAL'),
          ),
        );

  WidgetStationDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;
}
