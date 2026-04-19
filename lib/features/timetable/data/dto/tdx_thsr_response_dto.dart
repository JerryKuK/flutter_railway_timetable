import 'package:json_annotation/json_annotation.dart';

part 'tdx_thsr_response_dto.g.dart';

// ── THSR Station DTO ───────────────────────────────────────────────────────

@JsonSerializable()
class TdxThsrStationDto {
  @JsonKey(name: 'StationID')
  final String stationId;
  @JsonKey(name: 'StationName')
  final TdxThsrMultilingualName? stationName;

  const TdxThsrStationDto({this.stationId = '', this.stationName});

  factory TdxThsrStationDto.fromJson(Map<String, dynamic> json) =>
      _$TdxThsrStationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TdxThsrStationDtoToJson(this);
}

@JsonSerializable()
class TdxThsrMultilingualName {
  @JsonKey(name: 'Zh_tw')
  final String zhTw;
  @JsonKey(name: 'En')
  final String en;

  const TdxThsrMultilingualName({this.zhTw = '', this.en = ''});

  factory TdxThsrMultilingualName.fromJson(Map<String, dynamic> json) =>
      _$TdxThsrMultilingualNameFromJson(json);

  Map<String, dynamic> toJson() => _$TdxThsrMultilingualNameToJson(this);
}

// ── THSR DailyTimetable OD v2 DTO ─────────────────────────────────────────

@JsonSerializable()
class TdxThsrDailyTrainDto {
  @JsonKey(name: 'TrainNo')
  final String trainNo;
  @JsonKey(name: 'TrainTypeName')
  final TdxThsrMultilingualName? trainTypeName;
  @JsonKey(name: 'OriginStopTime')
  final TdxThsrStopTimeDto? originStopTime;
  @JsonKey(name: 'DestinationStopTime')
  final TdxThsrStopTimeDto? destinationStopTime;

  const TdxThsrDailyTrainDto({
    this.trainNo = '',
    this.trainTypeName,
    this.originStopTime,
    this.destinationStopTime,
  });

  factory TdxThsrDailyTrainDto.fromJson(Map<String, dynamic> json) =>
      _$TdxThsrDailyTrainDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TdxThsrDailyTrainDtoToJson(this);
}

@JsonSerializable()
class TdxThsrStopTimeDto {
  @JsonKey(name: 'DepartureTime')
  final String departureTime;
  @JsonKey(name: 'ArrivalTime')
  final String arrivalTime;

  const TdxThsrStopTimeDto({this.departureTime = '', this.arrivalTime = ''});

  factory TdxThsrStopTimeDto.fromJson(Map<String, dynamic> json) =>
      _$TdxThsrStopTimeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TdxThsrStopTimeDtoToJson(this);
}

// ── THSR ODFare DTO ────────────────────────────────────────────────────────

@JsonSerializable()
class TdxThsrODFareItemDto {
  @JsonKey(name: 'OriginStationID')
  final String originStationId;
  @JsonKey(name: 'DestinationStationID')
  final String destinationStationId;
  @JsonKey(name: 'Fares')
  final List<TdxThsrFareDto> fares;

  const TdxThsrODFareItemDto({
    this.originStationId = '',
    this.destinationStationId = '',
    this.fares = const [],
  });

  factory TdxThsrODFareItemDto.fromJson(Map<String, dynamic> json) =>
      _$TdxThsrODFareItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TdxThsrODFareItemDtoToJson(this);
}

/// THSR ticket fare:
/// TicketType 1=成人, 8=孩童
/// FareClass 1=全票, 9=優惠
/// CabinClass 1=對號座, 2=商務座, 3=自由座
@JsonSerializable()
class TdxThsrFareDto {
  @JsonKey(name: 'TicketType')
  final int ticketType;
  @JsonKey(name: 'FareClass')
  final int fareClass;
  @JsonKey(name: 'CabinClass')
  final int cabinClass;
  @JsonKey(name: 'Price')
  final int price;

  const TdxThsrFareDto({
    this.ticketType = 0,
    this.fareClass = 0,
    this.cabinClass = 0,
    this.price = 0,
  });

  factory TdxThsrFareDto.fromJson(Map<String, dynamic> json) =>
      _$TdxThsrFareDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TdxThsrFareDtoToJson(this);
}
