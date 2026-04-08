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

  const TdxTrainInfoDto({this.trainNo = '', this.trainTypeName});

  factory TdxTrainInfoDto.fromJson(Map<String, dynamic> json) =>
      _$TdxTrainInfoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TdxTrainInfoDtoToJson(this);
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
