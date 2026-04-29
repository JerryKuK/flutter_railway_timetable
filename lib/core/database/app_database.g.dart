// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RecentSearchesTable extends RecentSearches
    with TableInfo<$RecentSearchesTable, RecentSearchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentSearchesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _departureStationMeta = const VerificationMeta(
    'departureStation',
  );
  @override
  late final GeneratedColumn<String> departureStation = GeneratedColumn<String>(
    'departure_station',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arrivalStationMeta = const VerificationMeta(
    'arrivalStation',
  );
  @override
  late final GeneratedColumn<String> arrivalStation = GeneratedColumn<String>(
    'arrival_station',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _departureStationIdMeta =
      const VerificationMeta('departureStationId');
  @override
  late final GeneratedColumn<String> departureStationId =
      GeneratedColumn<String>(
        'departure_station_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _arrivalStationIdMeta = const VerificationMeta(
    'arrivalStationId',
  );
  @override
  late final GeneratedColumn<String> arrivalStationId = GeneratedColumn<String>(
    'arrival_station_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _railwayTypeMeta = const VerificationMeta(
    'railwayType',
  );
  @override
  late final GeneratedColumn<String> railwayType = GeneratedColumn<String>(
    'railway_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('tra'),
  );
  static const VerificationMeta _searchedAtMeta = const VerificationMeta(
    'searchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> searchedAt = GeneratedColumn<DateTime>(
    'searched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    departureStation,
    arrivalStation,
    departureStationId,
    arrivalStationId,
    railwayType,
    searchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_searches';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentSearchRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('departure_station')) {
      context.handle(
        _departureStationMeta,
        departureStation.isAcceptableOrUnknown(
          data['departure_station']!,
          _departureStationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departureStationMeta);
    }
    if (data.containsKey('arrival_station')) {
      context.handle(
        _arrivalStationMeta,
        arrivalStation.isAcceptableOrUnknown(
          data['arrival_station']!,
          _arrivalStationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_arrivalStationMeta);
    }
    if (data.containsKey('departure_station_id')) {
      context.handle(
        _departureStationIdMeta,
        departureStationId.isAcceptableOrUnknown(
          data['departure_station_id']!,
          _departureStationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departureStationIdMeta);
    }
    if (data.containsKey('arrival_station_id')) {
      context.handle(
        _arrivalStationIdMeta,
        arrivalStationId.isAcceptableOrUnknown(
          data['arrival_station_id']!,
          _arrivalStationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_arrivalStationIdMeta);
    }
    if (data.containsKey('railway_type')) {
      context.handle(
        _railwayTypeMeta,
        railwayType.isAcceptableOrUnknown(
          data['railway_type']!,
          _railwayTypeMeta,
        ),
      );
    }
    if (data.containsKey('searched_at')) {
      context.handle(
        _searchedAtMeta,
        searchedAt.isAcceptableOrUnknown(data['searched_at']!, _searchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_searchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecentSearchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentSearchRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      departureStation:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}departure_station'],
          )!,
      arrivalStation:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}arrival_station'],
          )!,
      departureStationId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}departure_station_id'],
          )!,
      arrivalStationId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}arrival_station_id'],
          )!,
      railwayType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}railway_type'],
          )!,
      searchedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}searched_at'],
          )!,
    );
  }

  @override
  $RecentSearchesTable createAlias(String alias) {
    return $RecentSearchesTable(attachedDatabase, alias);
  }
}

class RecentSearchRow extends DataClass implements Insertable<RecentSearchRow> {
  final int id;
  final String departureStation;
  final String arrivalStation;
  final String departureStationId;
  final String arrivalStationId;
  final String railwayType;
  final DateTime searchedAt;
  const RecentSearchRow({
    required this.id,
    required this.departureStation,
    required this.arrivalStation,
    required this.departureStationId,
    required this.arrivalStationId,
    required this.railwayType,
    required this.searchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['departure_station'] = Variable<String>(departureStation);
    map['arrival_station'] = Variable<String>(arrivalStation);
    map['departure_station_id'] = Variable<String>(departureStationId);
    map['arrival_station_id'] = Variable<String>(arrivalStationId);
    map['railway_type'] = Variable<String>(railwayType);
    map['searched_at'] = Variable<DateTime>(searchedAt);
    return map;
  }

  RecentSearchesCompanion toCompanion(bool nullToAbsent) {
    return RecentSearchesCompanion(
      id: Value(id),
      departureStation: Value(departureStation),
      arrivalStation: Value(arrivalStation),
      departureStationId: Value(departureStationId),
      arrivalStationId: Value(arrivalStationId),
      railwayType: Value(railwayType),
      searchedAt: Value(searchedAt),
    );
  }

  factory RecentSearchRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentSearchRow(
      id: serializer.fromJson<int>(json['id']),
      departureStation: serializer.fromJson<String>(json['departureStation']),
      arrivalStation: serializer.fromJson<String>(json['arrivalStation']),
      departureStationId: serializer.fromJson<String>(
        json['departureStationId'],
      ),
      arrivalStationId: serializer.fromJson<String>(json['arrivalStationId']),
      railwayType: serializer.fromJson<String>(json['railwayType']),
      searchedAt: serializer.fromJson<DateTime>(json['searchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'departureStation': serializer.toJson<String>(departureStation),
      'arrivalStation': serializer.toJson<String>(arrivalStation),
      'departureStationId': serializer.toJson<String>(departureStationId),
      'arrivalStationId': serializer.toJson<String>(arrivalStationId),
      'railwayType': serializer.toJson<String>(railwayType),
      'searchedAt': serializer.toJson<DateTime>(searchedAt),
    };
  }

  RecentSearchRow copyWith({
    int? id,
    String? departureStation,
    String? arrivalStation,
    String? departureStationId,
    String? arrivalStationId,
    String? railwayType,
    DateTime? searchedAt,
  }) => RecentSearchRow(
    id: id ?? this.id,
    departureStation: departureStation ?? this.departureStation,
    arrivalStation: arrivalStation ?? this.arrivalStation,
    departureStationId: departureStationId ?? this.departureStationId,
    arrivalStationId: arrivalStationId ?? this.arrivalStationId,
    railwayType: railwayType ?? this.railwayType,
    searchedAt: searchedAt ?? this.searchedAt,
  );
  RecentSearchRow copyWithCompanion(RecentSearchesCompanion data) {
    return RecentSearchRow(
      id: data.id.present ? data.id.value : this.id,
      departureStation:
          data.departureStation.present
              ? data.departureStation.value
              : this.departureStation,
      arrivalStation:
          data.arrivalStation.present
              ? data.arrivalStation.value
              : this.arrivalStation,
      departureStationId:
          data.departureStationId.present
              ? data.departureStationId.value
              : this.departureStationId,
      arrivalStationId:
          data.arrivalStationId.present
              ? data.arrivalStationId.value
              : this.arrivalStationId,
      railwayType:
          data.railwayType.present ? data.railwayType.value : this.railwayType,
      searchedAt:
          data.searchedAt.present ? data.searchedAt.value : this.searchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearchRow(')
          ..write('id: $id, ')
          ..write('departureStation: $departureStation, ')
          ..write('arrivalStation: $arrivalStation, ')
          ..write('departureStationId: $departureStationId, ')
          ..write('arrivalStationId: $arrivalStationId, ')
          ..write('railwayType: $railwayType, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    departureStation,
    arrivalStation,
    departureStationId,
    arrivalStationId,
    railwayType,
    searchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentSearchRow &&
          other.id == this.id &&
          other.departureStation == this.departureStation &&
          other.arrivalStation == this.arrivalStation &&
          other.departureStationId == this.departureStationId &&
          other.arrivalStationId == this.arrivalStationId &&
          other.railwayType == this.railwayType &&
          other.searchedAt == this.searchedAt);
}

class RecentSearchesCompanion extends UpdateCompanion<RecentSearchRow> {
  final Value<int> id;
  final Value<String> departureStation;
  final Value<String> arrivalStation;
  final Value<String> departureStationId;
  final Value<String> arrivalStationId;
  final Value<String> railwayType;
  final Value<DateTime> searchedAt;
  const RecentSearchesCompanion({
    this.id = const Value.absent(),
    this.departureStation = const Value.absent(),
    this.arrivalStation = const Value.absent(),
    this.departureStationId = const Value.absent(),
    this.arrivalStationId = const Value.absent(),
    this.railwayType = const Value.absent(),
    this.searchedAt = const Value.absent(),
  });
  RecentSearchesCompanion.insert({
    this.id = const Value.absent(),
    required String departureStation,
    required String arrivalStation,
    required String departureStationId,
    required String arrivalStationId,
    this.railwayType = const Value.absent(),
    required DateTime searchedAt,
  }) : departureStation = Value(departureStation),
       arrivalStation = Value(arrivalStation),
       departureStationId = Value(departureStationId),
       arrivalStationId = Value(arrivalStationId),
       searchedAt = Value(searchedAt);
  static Insertable<RecentSearchRow> custom({
    Expression<int>? id,
    Expression<String>? departureStation,
    Expression<String>? arrivalStation,
    Expression<String>? departureStationId,
    Expression<String>? arrivalStationId,
    Expression<String>? railwayType,
    Expression<DateTime>? searchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (departureStation != null) 'departure_station': departureStation,
      if (arrivalStation != null) 'arrival_station': arrivalStation,
      if (departureStationId != null)
        'departure_station_id': departureStationId,
      if (arrivalStationId != null) 'arrival_station_id': arrivalStationId,
      if (railwayType != null) 'railway_type': railwayType,
      if (searchedAt != null) 'searched_at': searchedAt,
    });
  }

  RecentSearchesCompanion copyWith({
    Value<int>? id,
    Value<String>? departureStation,
    Value<String>? arrivalStation,
    Value<String>? departureStationId,
    Value<String>? arrivalStationId,
    Value<String>? railwayType,
    Value<DateTime>? searchedAt,
  }) {
    return RecentSearchesCompanion(
      id: id ?? this.id,
      departureStation: departureStation ?? this.departureStation,
      arrivalStation: arrivalStation ?? this.arrivalStation,
      departureStationId: departureStationId ?? this.departureStationId,
      arrivalStationId: arrivalStationId ?? this.arrivalStationId,
      railwayType: railwayType ?? this.railwayType,
      searchedAt: searchedAt ?? this.searchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (departureStation.present) {
      map['departure_station'] = Variable<String>(departureStation.value);
    }
    if (arrivalStation.present) {
      map['arrival_station'] = Variable<String>(arrivalStation.value);
    }
    if (departureStationId.present) {
      map['departure_station_id'] = Variable<String>(departureStationId.value);
    }
    if (arrivalStationId.present) {
      map['arrival_station_id'] = Variable<String>(arrivalStationId.value);
    }
    if (railwayType.present) {
      map['railway_type'] = Variable<String>(railwayType.value);
    }
    if (searchedAt.present) {
      map['searched_at'] = Variable<DateTime>(searchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearchesCompanion(')
          ..write('id: $id, ')
          ..write('departureStation: $departureStation, ')
          ..write('arrivalStation: $arrivalStation, ')
          ..write('departureStationId: $departureStationId, ')
          ..write('arrivalStationId: $arrivalStationId, ')
          ..write('railwayType: $railwayType, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }
}

class $LastStationSelectionsTable extends LastStationSelections
    with TableInfo<$LastStationSelectionsTable, LastStationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LastStationSelectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _railwayTypeMeta = const VerificationMeta(
    'railwayType',
  );
  @override
  late final GeneratedColumn<String> railwayType = GeneratedColumn<String>(
    'railway_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _departureStationMeta = const VerificationMeta(
    'departureStation',
  );
  @override
  late final GeneratedColumn<String> departureStation = GeneratedColumn<String>(
    'departure_station',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arrivalStationMeta = const VerificationMeta(
    'arrivalStation',
  );
  @override
  late final GeneratedColumn<String> arrivalStation = GeneratedColumn<String>(
    'arrival_station',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _departureStationIdMeta =
      const VerificationMeta('departureStationId');
  @override
  late final GeneratedColumn<String> departureStationId =
      GeneratedColumn<String>(
        'departure_station_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _arrivalStationIdMeta = const VerificationMeta(
    'arrivalStationId',
  );
  @override
  late final GeneratedColumn<String> arrivalStationId = GeneratedColumn<String>(
    'arrival_station_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    railwayType,
    departureStation,
    arrivalStation,
    departureStationId,
    arrivalStationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'last_station_selections';
  @override
  VerificationContext validateIntegrity(
    Insertable<LastStationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('railway_type')) {
      context.handle(
        _railwayTypeMeta,
        railwayType.isAcceptableOrUnknown(
          data['railway_type']!,
          _railwayTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_railwayTypeMeta);
    }
    if (data.containsKey('departure_station')) {
      context.handle(
        _departureStationMeta,
        departureStation.isAcceptableOrUnknown(
          data['departure_station']!,
          _departureStationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departureStationMeta);
    }
    if (data.containsKey('arrival_station')) {
      context.handle(
        _arrivalStationMeta,
        arrivalStation.isAcceptableOrUnknown(
          data['arrival_station']!,
          _arrivalStationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_arrivalStationMeta);
    }
    if (data.containsKey('departure_station_id')) {
      context.handle(
        _departureStationIdMeta,
        departureStationId.isAcceptableOrUnknown(
          data['departure_station_id']!,
          _departureStationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departureStationIdMeta);
    }
    if (data.containsKey('arrival_station_id')) {
      context.handle(
        _arrivalStationIdMeta,
        arrivalStationId.isAcceptableOrUnknown(
          data['arrival_station_id']!,
          _arrivalStationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_arrivalStationIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {railwayType};
  @override
  LastStationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LastStationRow(
      railwayType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}railway_type'],
          )!,
      departureStation:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}departure_station'],
          )!,
      arrivalStation:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}arrival_station'],
          )!,
      departureStationId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}departure_station_id'],
          )!,
      arrivalStationId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}arrival_station_id'],
          )!,
    );
  }

  @override
  $LastStationSelectionsTable createAlias(String alias) {
    return $LastStationSelectionsTable(attachedDatabase, alias);
  }
}

class LastStationRow extends DataClass implements Insertable<LastStationRow> {
  final String railwayType;
  final String departureStation;
  final String arrivalStation;
  final String departureStationId;
  final String arrivalStationId;
  const LastStationRow({
    required this.railwayType,
    required this.departureStation,
    required this.arrivalStation,
    required this.departureStationId,
    required this.arrivalStationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['railway_type'] = Variable<String>(railwayType);
    map['departure_station'] = Variable<String>(departureStation);
    map['arrival_station'] = Variable<String>(arrivalStation);
    map['departure_station_id'] = Variable<String>(departureStationId);
    map['arrival_station_id'] = Variable<String>(arrivalStationId);
    return map;
  }

  LastStationSelectionsCompanion toCompanion(bool nullToAbsent) {
    return LastStationSelectionsCompanion(
      railwayType: Value(railwayType),
      departureStation: Value(departureStation),
      arrivalStation: Value(arrivalStation),
      departureStationId: Value(departureStationId),
      arrivalStationId: Value(arrivalStationId),
    );
  }

  factory LastStationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LastStationRow(
      railwayType: serializer.fromJson<String>(json['railwayType']),
      departureStation: serializer.fromJson<String>(json['departureStation']),
      arrivalStation: serializer.fromJson<String>(json['arrivalStation']),
      departureStationId: serializer.fromJson<String>(
        json['departureStationId'],
      ),
      arrivalStationId: serializer.fromJson<String>(json['arrivalStationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'railwayType': serializer.toJson<String>(railwayType),
      'departureStation': serializer.toJson<String>(departureStation),
      'arrivalStation': serializer.toJson<String>(arrivalStation),
      'departureStationId': serializer.toJson<String>(departureStationId),
      'arrivalStationId': serializer.toJson<String>(arrivalStationId),
    };
  }

  LastStationRow copyWith({
    String? railwayType,
    String? departureStation,
    String? arrivalStation,
    String? departureStationId,
    String? arrivalStationId,
  }) => LastStationRow(
    railwayType: railwayType ?? this.railwayType,
    departureStation: departureStation ?? this.departureStation,
    arrivalStation: arrivalStation ?? this.arrivalStation,
    departureStationId: departureStationId ?? this.departureStationId,
    arrivalStationId: arrivalStationId ?? this.arrivalStationId,
  );
  LastStationRow copyWithCompanion(LastStationSelectionsCompanion data) {
    return LastStationRow(
      railwayType:
          data.railwayType.present ? data.railwayType.value : this.railwayType,
      departureStation:
          data.departureStation.present
              ? data.departureStation.value
              : this.departureStation,
      arrivalStation:
          data.arrivalStation.present
              ? data.arrivalStation.value
              : this.arrivalStation,
      departureStationId:
          data.departureStationId.present
              ? data.departureStationId.value
              : this.departureStationId,
      arrivalStationId:
          data.arrivalStationId.present
              ? data.arrivalStationId.value
              : this.arrivalStationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LastStationRow(')
          ..write('railwayType: $railwayType, ')
          ..write('departureStation: $departureStation, ')
          ..write('arrivalStation: $arrivalStation, ')
          ..write('departureStationId: $departureStationId, ')
          ..write('arrivalStationId: $arrivalStationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    railwayType,
    departureStation,
    arrivalStation,
    departureStationId,
    arrivalStationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LastStationRow &&
          other.railwayType == this.railwayType &&
          other.departureStation == this.departureStation &&
          other.arrivalStation == this.arrivalStation &&
          other.departureStationId == this.departureStationId &&
          other.arrivalStationId == this.arrivalStationId);
}

class LastStationSelectionsCompanion extends UpdateCompanion<LastStationRow> {
  final Value<String> railwayType;
  final Value<String> departureStation;
  final Value<String> arrivalStation;
  final Value<String> departureStationId;
  final Value<String> arrivalStationId;
  final Value<int> rowid;
  const LastStationSelectionsCompanion({
    this.railwayType = const Value.absent(),
    this.departureStation = const Value.absent(),
    this.arrivalStation = const Value.absent(),
    this.departureStationId = const Value.absent(),
    this.arrivalStationId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LastStationSelectionsCompanion.insert({
    required String railwayType,
    required String departureStation,
    required String arrivalStation,
    required String departureStationId,
    required String arrivalStationId,
    this.rowid = const Value.absent(),
  }) : railwayType = Value(railwayType),
       departureStation = Value(departureStation),
       arrivalStation = Value(arrivalStation),
       departureStationId = Value(departureStationId),
       arrivalStationId = Value(arrivalStationId);
  static Insertable<LastStationRow> custom({
    Expression<String>? railwayType,
    Expression<String>? departureStation,
    Expression<String>? arrivalStation,
    Expression<String>? departureStationId,
    Expression<String>? arrivalStationId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (railwayType != null) 'railway_type': railwayType,
      if (departureStation != null) 'departure_station': departureStation,
      if (arrivalStation != null) 'arrival_station': arrivalStation,
      if (departureStationId != null)
        'departure_station_id': departureStationId,
      if (arrivalStationId != null) 'arrival_station_id': arrivalStationId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LastStationSelectionsCompanion copyWith({
    Value<String>? railwayType,
    Value<String>? departureStation,
    Value<String>? arrivalStation,
    Value<String>? departureStationId,
    Value<String>? arrivalStationId,
    Value<int>? rowid,
  }) {
    return LastStationSelectionsCompanion(
      railwayType: railwayType ?? this.railwayType,
      departureStation: departureStation ?? this.departureStation,
      arrivalStation: arrivalStation ?? this.arrivalStation,
      departureStationId: departureStationId ?? this.departureStationId,
      arrivalStationId: arrivalStationId ?? this.arrivalStationId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (railwayType.present) {
      map['railway_type'] = Variable<String>(railwayType.value);
    }
    if (departureStation.present) {
      map['departure_station'] = Variable<String>(departureStation.value);
    }
    if (arrivalStation.present) {
      map['arrival_station'] = Variable<String>(arrivalStation.value);
    }
    if (departureStationId.present) {
      map['departure_station_id'] = Variable<String>(departureStationId.value);
    }
    if (arrivalStationId.present) {
      map['arrival_station_id'] = Variable<String>(arrivalStationId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LastStationSelectionsCompanion(')
          ..write('railwayType: $railwayType, ')
          ..write('departureStation: $departureStation, ')
          ..write('arrivalStation: $arrivalStation, ')
          ..write('departureStationId: $departureStationId, ')
          ..write('arrivalStationId: $arrivalStationId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecentSearchesTable recentSearches = $RecentSearchesTable(this);
  late final $LastStationSelectionsTable lastStationSelections =
      $LastStationSelectionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recentSearches,
    lastStationSelections,
  ];
}

typedef $$RecentSearchesTableCreateCompanionBuilder =
    RecentSearchesCompanion Function({
      Value<int> id,
      required String departureStation,
      required String arrivalStation,
      required String departureStationId,
      required String arrivalStationId,
      Value<String> railwayType,
      required DateTime searchedAt,
    });
typedef $$RecentSearchesTableUpdateCompanionBuilder =
    RecentSearchesCompanion Function({
      Value<int> id,
      Value<String> departureStation,
      Value<String> arrivalStation,
      Value<String> departureStationId,
      Value<String> arrivalStationId,
      Value<String> railwayType,
      Value<DateTime> searchedAt,
    });

class $$RecentSearchesTableFilterComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableFilterComposer({
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

  ColumnFilters<String> get departureStation => $composableBuilder(
    column: $table.departureStation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arrivalStation => $composableBuilder(
    column: $table.arrivalStation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get departureStationId => $composableBuilder(
    column: $table.departureStationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arrivalStationId => $composableBuilder(
    column: $table.arrivalStationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get railwayType => $composableBuilder(
    column: $table.railwayType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentSearchesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableOrderingComposer({
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

  ColumnOrderings<String> get departureStation => $composableBuilder(
    column: $table.departureStation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arrivalStation => $composableBuilder(
    column: $table.arrivalStation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get departureStationId => $composableBuilder(
    column: $table.departureStationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arrivalStationId => $composableBuilder(
    column: $table.arrivalStationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get railwayType => $composableBuilder(
    column: $table.railwayType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentSearchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get departureStation => $composableBuilder(
    column: $table.departureStation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get arrivalStation => $composableBuilder(
    column: $table.arrivalStation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get departureStationId => $composableBuilder(
    column: $table.departureStationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get arrivalStationId => $composableBuilder(
    column: $table.arrivalStationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get railwayType => $composableBuilder(
    column: $table.railwayType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => column,
  );
}

class $$RecentSearchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecentSearchesTable,
          RecentSearchRow,
          $$RecentSearchesTableFilterComposer,
          $$RecentSearchesTableOrderingComposer,
          $$RecentSearchesTableAnnotationComposer,
          $$RecentSearchesTableCreateCompanionBuilder,
          $$RecentSearchesTableUpdateCompanionBuilder,
          (
            RecentSearchRow,
            BaseReferences<
              _$AppDatabase,
              $RecentSearchesTable,
              RecentSearchRow
            >,
          ),
          RecentSearchRow,
          PrefetchHooks Function()
        > {
  $$RecentSearchesTableTableManager(
    _$AppDatabase db,
    $RecentSearchesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$RecentSearchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$RecentSearchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$RecentSearchesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> departureStation = const Value.absent(),
                Value<String> arrivalStation = const Value.absent(),
                Value<String> departureStationId = const Value.absent(),
                Value<String> arrivalStationId = const Value.absent(),
                Value<String> railwayType = const Value.absent(),
                Value<DateTime> searchedAt = const Value.absent(),
              }) => RecentSearchesCompanion(
                id: id,
                departureStation: departureStation,
                arrivalStation: arrivalStation,
                departureStationId: departureStationId,
                arrivalStationId: arrivalStationId,
                railwayType: railwayType,
                searchedAt: searchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String departureStation,
                required String arrivalStation,
                required String departureStationId,
                required String arrivalStationId,
                Value<String> railwayType = const Value.absent(),
                required DateTime searchedAt,
              }) => RecentSearchesCompanion.insert(
                id: id,
                departureStation: departureStation,
                arrivalStation: arrivalStation,
                departureStationId: departureStationId,
                arrivalStationId: arrivalStationId,
                railwayType: railwayType,
                searchedAt: searchedAt,
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

typedef $$RecentSearchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecentSearchesTable,
      RecentSearchRow,
      $$RecentSearchesTableFilterComposer,
      $$RecentSearchesTableOrderingComposer,
      $$RecentSearchesTableAnnotationComposer,
      $$RecentSearchesTableCreateCompanionBuilder,
      $$RecentSearchesTableUpdateCompanionBuilder,
      (
        RecentSearchRow,
        BaseReferences<_$AppDatabase, $RecentSearchesTable, RecentSearchRow>,
      ),
      RecentSearchRow,
      PrefetchHooks Function()
    >;
typedef $$LastStationSelectionsTableCreateCompanionBuilder =
    LastStationSelectionsCompanion Function({
      required String railwayType,
      required String departureStation,
      required String arrivalStation,
      required String departureStationId,
      required String arrivalStationId,
      Value<int> rowid,
    });
typedef $$LastStationSelectionsTableUpdateCompanionBuilder =
    LastStationSelectionsCompanion Function({
      Value<String> railwayType,
      Value<String> departureStation,
      Value<String> arrivalStation,
      Value<String> departureStationId,
      Value<String> arrivalStationId,
      Value<int> rowid,
    });

class $$LastStationSelectionsTableFilterComposer
    extends Composer<_$AppDatabase, $LastStationSelectionsTable> {
  $$LastStationSelectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get railwayType => $composableBuilder(
    column: $table.railwayType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get departureStation => $composableBuilder(
    column: $table.departureStation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arrivalStation => $composableBuilder(
    column: $table.arrivalStation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get departureStationId => $composableBuilder(
    column: $table.departureStationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arrivalStationId => $composableBuilder(
    column: $table.arrivalStationId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LastStationSelectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LastStationSelectionsTable> {
  $$LastStationSelectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get railwayType => $composableBuilder(
    column: $table.railwayType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get departureStation => $composableBuilder(
    column: $table.departureStation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arrivalStation => $composableBuilder(
    column: $table.arrivalStation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get departureStationId => $composableBuilder(
    column: $table.departureStationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arrivalStationId => $composableBuilder(
    column: $table.arrivalStationId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LastStationSelectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LastStationSelectionsTable> {
  $$LastStationSelectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get railwayType => $composableBuilder(
    column: $table.railwayType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get departureStation => $composableBuilder(
    column: $table.departureStation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get arrivalStation => $composableBuilder(
    column: $table.arrivalStation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get departureStationId => $composableBuilder(
    column: $table.departureStationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get arrivalStationId => $composableBuilder(
    column: $table.arrivalStationId,
    builder: (column) => column,
  );
}

class $$LastStationSelectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LastStationSelectionsTable,
          LastStationRow,
          $$LastStationSelectionsTableFilterComposer,
          $$LastStationSelectionsTableOrderingComposer,
          $$LastStationSelectionsTableAnnotationComposer,
          $$LastStationSelectionsTableCreateCompanionBuilder,
          $$LastStationSelectionsTableUpdateCompanionBuilder,
          (
            LastStationRow,
            BaseReferences<
              _$AppDatabase,
              $LastStationSelectionsTable,
              LastStationRow
            >,
          ),
          LastStationRow,
          PrefetchHooks Function()
        > {
  $$LastStationSelectionsTableTableManager(
    _$AppDatabase db,
    $LastStationSelectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LastStationSelectionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$LastStationSelectionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$LastStationSelectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> railwayType = const Value.absent(),
                Value<String> departureStation = const Value.absent(),
                Value<String> arrivalStation = const Value.absent(),
                Value<String> departureStationId = const Value.absent(),
                Value<String> arrivalStationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LastStationSelectionsCompanion(
                railwayType: railwayType,
                departureStation: departureStation,
                arrivalStation: arrivalStation,
                departureStationId: departureStationId,
                arrivalStationId: arrivalStationId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String railwayType,
                required String departureStation,
                required String arrivalStation,
                required String departureStationId,
                required String arrivalStationId,
                Value<int> rowid = const Value.absent(),
              }) => LastStationSelectionsCompanion.insert(
                railwayType: railwayType,
                departureStation: departureStation,
                arrivalStation: arrivalStation,
                departureStationId: departureStationId,
                arrivalStationId: arrivalStationId,
                rowid: rowid,
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

typedef $$LastStationSelectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LastStationSelectionsTable,
      LastStationRow,
      $$LastStationSelectionsTableFilterComposer,
      $$LastStationSelectionsTableOrderingComposer,
      $$LastStationSelectionsTableAnnotationComposer,
      $$LastStationSelectionsTableCreateCompanionBuilder,
      $$LastStationSelectionsTableUpdateCompanionBuilder,
      (
        LastStationRow,
        BaseReferences<
          _$AppDatabase,
          $LastStationSelectionsTable,
          LastStationRow
        >,
      ),
      LastStationRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecentSearchesTableTableManager get recentSearches =>
      $$RecentSearchesTableTableManager(_db, _db.recentSearches);
  $$LastStationSelectionsTableTableManager get lastStationSelections =>
      $$LastStationSelectionsTableTableManager(_db, _db.lastStationSelections);
}
