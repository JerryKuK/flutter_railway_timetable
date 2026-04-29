import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('RecentSearchRow')
class RecentSearches extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get departureStation => text()();
  TextColumn get arrivalStation => text()();
  TextColumn get departureStationId => text()();
  TextColumn get arrivalStationId => text()();
  TextColumn get railwayType => text().withDefault(const Constant('tra'))();
  DateTimeColumn get searchedAt => dateTime()();
}

@DataClassName('LastStationRow')
class LastStationSelections extends Table {
  TextColumn get railwayType => text()();
  TextColumn get departureStation => text()();
  TextColumn get arrivalStation => text()();
  TextColumn get departureStationId => text()();
  TextColumn get arrivalStationId => text()();

  @override
  Set<Column> get primaryKey => {railwayType};
}

@DriftDatabase(tables: [RecentSearches, LastStationSelections])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() =>
    driftDatabase(name: 'railway_timetable_db');
