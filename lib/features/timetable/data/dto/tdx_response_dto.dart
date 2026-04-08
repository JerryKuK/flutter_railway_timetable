import 'package:json_annotation/json_annotation.dart';

part 'tdx_response_dto.g.dart';

@JsonSerializable()
class MultilingualName {
  @JsonKey(name: 'Zh_tw')
  final String zhTw;
  @JsonKey(name: 'En')
  final String en;

  const MultilingualName({this.zhTw = '', this.en = ''});

  factory MultilingualName.fromJson(Map<String, dynamic> json) =>
      _$MultilingualNameFromJson(json);

  Map<String, dynamic> toJson() => _$MultilingualNameToJson(this);
}

// ── Station API DTO ────────────────────────────────────────────────────────

@JsonSerializable()
class TdxStationDto {
  @JsonKey(name: 'StationID')
  final String stationId;
  @JsonKey(name: 'StationName')
  final MultilingualName? stationName;
  @JsonKey(name: 'LocationCity')
  final String? city;

  const TdxStationDto({
    this.stationId = '',
    this.stationName,
    this.city,
  });

  factory TdxStationDto.fromJson(Map<String, dynamic> json) =>
      _$TdxStationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TdxStationDtoToJson(this);
}

// ── DailyTrainTimetable OD v3 DTOs ────────────────────────────────────────

/// v3 OD API 外層包裝物件（含 TrainTimetables 陣列）
@JsonSerializable()
class TdxTimetableResponseDto {
  @JsonKey(name: 'TrainTimetables')
  final List<TdxTrainTimetableDto> trainTimetables;

  const TdxTimetableResponseDto({this.trainTimetables = const []});

  factory TdxTimetableResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TdxTimetableResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TdxTimetableResponseDtoToJson(this);
}

/// v3 單筆時刻表（TrainInfo + StopTimes）
@JsonSerializable()
class TdxTrainTimetableDto {
  @JsonKey(name: 'TrainInfo')
  final TdxTrainInfoDto? trainInfo;
  @JsonKey(name: 'StopTimes')
  final List<TdxStopTimeDto> stopTimes;

  const TdxTrainTimetableDto({
    this.trainInfo,
    this.stopTimes = const [],
  });

  factory TdxTrainTimetableDto.fromJson(Map<String, dynamic> json) =>
      _$TdxTrainTimetableDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TdxTrainTimetableDtoToJson(this);
}

/// v3 列車基本資訊（v2 稱 DailyTrainInfo）
@JsonSerializable()
class TdxTrainInfoDto {
  @JsonKey(name: 'TrainNo')
  final String trainNo;
  @JsonKey(name: 'TrainTypeName')
  final MultilingualName? trainTypeName;
  @JsonKey(name: 'TrainTypeID')
  final String? trainTypeId;

  const TdxTrainInfoDto({this.trainNo = '', this.trainTypeName, this.trainTypeId});

  factory TdxTrainInfoDto.fromJson(Map<String, dynamic> json) =>
      _$TdxTrainInfoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TdxTrainInfoDtoToJson(this);
}

// ── ODFare v2 DTOs ────────────────────────────────────────────────────────

/// v2 OD 票價項目（單一 OD 對的票價清單）
@JsonSerializable()
class TdxODFareItemDto {
  @JsonKey(name: 'OriginStationID')
  final String originStationId;
  @JsonKey(name: 'DestinationStationID')
  final String destinationStationId;
  @JsonKey(name: 'Fares')
  final List<TdxFareDto> fares;

  const TdxODFareItemDto({
    this.originStationId = '',
    this.destinationStationId = '',
    this.fares = const [],
  });

  factory TdxODFareItemDto.fromJson(Map<String, dynamic> json) =>
      _$TdxODFareItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TdxODFareItemDtoToJson(this);
}

/// 單筆票價資料（TDX ODFare v2 真實格式）
/// TicketType 為兩字中文碼：首字=票種（成/孩/愛孩），次字=車種（自/莒/復/普）
/// 例：「成自」= 成人自強票，「成莒」= 成人莒光票
@JsonSerializable()
class TdxFareDto {
  @JsonKey(name: 'TicketType')
  final String ticketType;
  @JsonKey(name: 'Price')
  final int price;

  const TdxFareDto({
    this.ticketType = '',
    this.price = 0,
  });

  factory TdxFareDto.fromJson(Map<String, dynamic> json) =>
      _$TdxFareDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TdxFareDtoToJson(this);
}

/// v3 停靠站時刻（OD 端點中 [0]=出發站，[last]=到達站）
@JsonSerializable()
class TdxStopTimeDto {
  @JsonKey(name: 'StationID')
  final String stationId;
  @JsonKey(name: 'DepartureTime')
  final String departureTime;
  @JsonKey(name: 'ArrivalTime')
  final String arrivalTime;

  const TdxStopTimeDto({
    this.stationId = '',
    this.departureTime = '',
    this.arrivalTime = '',
  });

  factory TdxStopTimeDto.fromJson(Map<String, dynamic> json) =>
      _$TdxStopTimeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TdxStopTimeDtoToJson(this);
}
