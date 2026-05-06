// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_station_database.dart';

// ignore_for_file: type=lint
class $WidgetStationsTable extends WidgetStations
    with TableInfo<$WidgetStationsTable, WidgetStationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WidgetStationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stationIdMeta = const VerificationMeta(
    'stationId',
  );
  @override
  late final GeneratedColumn<String> stationId = GeneratedColumn<String>(
    'station_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systemMeta = const VerificationMeta('system');
  @override
  late final GeneratedColumn<String> system = GeneratedColumn<String>(
    'system',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    stationId,
    system,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'widget_stations';
  @override
  VerificationContext validateIntegrity(
    Insertable<WidgetStationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('station_id')) {
      context.handle(
        _stationIdMeta,
        stationId.isAcceptableOrUnknown(data['station_id']!, _stationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stationIdMeta);
    }
    if (data.containsKey('system')) {
      context.handle(
        _systemMeta,
        system.isAcceptableOrUnknown(data['system']!, _systemMeta),
      );
    } else if (isInserting) {
      context.missing(_systemMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {name, system},
  ];
  @override
  WidgetStationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WidgetStationRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      stationId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}station_id'],
          )!,
      system:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}system'],
          )!,
      sortOrder:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sort_order'],
          )!,
    );
  }

  @override
  $WidgetStationsTable createAlias(String alias) {
    return $WidgetStationsTable(attachedDatabase, alias);
  }
}

class WidgetStationRow extends DataClass
    implements Insertable<WidgetStationRow> {
  final int id;
  final String name;
  final String stationId;
  final String system;
  final int sortOrder;
  const WidgetStationRow({
    required this.id,
    required this.name,
    required this.stationId,
    required this.system,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['station_id'] = Variable<String>(stationId);
    map['system'] = Variable<String>(system);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  WidgetStationsCompanion toCompanion(bool nullToAbsent) {
    return WidgetStationsCompanion(
      id: Value(id),
      name: Value(name),
      stationId: Value(stationId),
      system: Value(system),
      sortOrder: Value(sortOrder),
    );
  }

  factory WidgetStationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WidgetStationRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      stationId: serializer.fromJson<String>(json['stationId']),
      system: serializer.fromJson<String>(json['system']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'stationId': serializer.toJson<String>(stationId),
      'system': serializer.toJson<String>(system),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  WidgetStationRow copyWith({
    int? id,
    String? name,
    String? stationId,
    String? system,
    int? sortOrder,
  }) => WidgetStationRow(
    id: id ?? this.id,
    name: name ?? this.name,
    stationId: stationId ?? this.stationId,
    system: system ?? this.system,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  WidgetStationRow copyWithCompanion(WidgetStationsCompanion data) {
    return WidgetStationRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      stationId: data.stationId.present ? data.stationId.value : this.stationId,
      system: data.system.present ? data.system.value : this.system,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WidgetStationRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stationId: $stationId, ')
          ..write('system: $system, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, stationId, system, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WidgetStationRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.stationId == this.stationId &&
          other.system == this.system &&
          other.sortOrder == this.sortOrder);
}

class WidgetStationsCompanion extends UpdateCompanion<WidgetStationRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> stationId;
  final Value<String> system;
  final Value<int> sortOrder;
  const WidgetStationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.stationId = const Value.absent(),
    this.system = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  WidgetStationsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String stationId,
    required String system,
    this.sortOrder = const Value.absent(),
  }) : name = Value(name),
       stationId = Value(stationId),
       system = Value(system);
  static Insertable<WidgetStationRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? stationId,
    Expression<String>? system,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (stationId != null) 'station_id': stationId,
      if (system != null) 'system': system,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  WidgetStationsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? stationId,
    Value<String>? system,
    Value<int>? sortOrder,
  }) {
    return WidgetStationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      stationId: stationId ?? this.stationId,
      system: system ?? this.system,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (stationId.present) {
      map['station_id'] = Variable<String>(stationId.value);
    }
    if (system.present) {
      map['system'] = Variable<String>(system.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WidgetStationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stationId: $stationId, ')
          ..write('system: $system, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

abstract class _$WidgetStationDatabase extends GeneratedDatabase {
  _$WidgetStationDatabase(QueryExecutor e) : super(e);
  $WidgetStationDatabaseManager get managers =>
      $WidgetStationDatabaseManager(this);
  late final $WidgetStationsTable widgetStations = $WidgetStationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [widgetStations];
}

typedef $$WidgetStationsTableCreateCompanionBuilder =
    WidgetStationsCompanion Function({
      Value<int> id,
      required String name,
      required String stationId,
      required String system,
      Value<int> sortOrder,
    });
typedef $$WidgetStationsTableUpdateCompanionBuilder =
    WidgetStationsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> stationId,
      Value<String> system,
      Value<int> sortOrder,
    });

class $$WidgetStationsTableFilterComposer
    extends Composer<_$WidgetStationDatabase, $WidgetStationsTable> {
  $$WidgetStationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stationId => $composableBuilder(
    column: $table.stationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get system => $composableBuilder(
    column: $table.system,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WidgetStationsTableOrderingComposer
    extends Composer<_$WidgetStationDatabase, $WidgetStationsTable> {
  $$WidgetStationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stationId => $composableBuilder(
    column: $table.stationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get system => $composableBuilder(
    column: $table.system,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WidgetStationsTableAnnotationComposer
    extends Composer<_$WidgetStationDatabase, $WidgetStationsTable> {
  $$WidgetStationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get stationId =>
      $composableBuilder(column: $table.stationId, builder: (column) => column);

  GeneratedColumn<String> get system =>
      $composableBuilder(column: $table.system, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$WidgetStationsTableTableManager
    extends
        RootTableManager<
          _$WidgetStationDatabase,
          $WidgetStationsTable,
          WidgetStationRow,
          $$WidgetStationsTableFilterComposer,
          $$WidgetStationsTableOrderingComposer,
          $$WidgetStationsTableAnnotationComposer,
          $$WidgetStationsTableCreateCompanionBuilder,
          $$WidgetStationsTableUpdateCompanionBuilder,
          (
            WidgetStationRow,
            BaseReferences<
              _$WidgetStationDatabase,
              $WidgetStationsTable,
              WidgetStationRow
            >,
          ),
          WidgetStationRow,
          PrefetchHooks Function()
        > {
  $$WidgetStationsTableTableManager(
    _$WidgetStationDatabase db,
    $WidgetStationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$WidgetStationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$WidgetStationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$WidgetStationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> stationId = const Value.absent(),
                Value<String> system = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => WidgetStationsCompanion(
                id: id,
                name: name,
                stationId: stationId,
                system: system,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String stationId,
                required String system,
                Value<int> sortOrder = const Value.absent(),
              }) => WidgetStationsCompanion.insert(
                id: id,
                name: name,
                stationId: stationId,
                system: system,
                sortOrder: sortOrder,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WidgetStationsTableProcessedTableManager =
    ProcessedTableManager<
      _$WidgetStationDatabase,
      $WidgetStationsTable,
      WidgetStationRow,
      $$WidgetStationsTableFilterComposer,
      $$WidgetStationsTableOrderingComposer,
      $$WidgetStationsTableAnnotationComposer,
      $$WidgetStationsTableCreateCompanionBuilder,
      $$WidgetStationsTableUpdateCompanionBuilder,
      (
        WidgetStationRow,
        BaseReferences<
          _$WidgetStationDatabase,
          $WidgetStationsTable,
          WidgetStationRow
        >,
      ),
      WidgetStationRow,
      PrefetchHooks Function()
    >;

class $WidgetStationDatabaseManager {
  final _$WidgetStationDatabase _db;
  $WidgetStationDatabaseManager(this._db);
  $$WidgetStationsTableTableManager get widgetStations =>
      $$WidgetStationsTableTableManager(_db, _db.widgetStations);
}
