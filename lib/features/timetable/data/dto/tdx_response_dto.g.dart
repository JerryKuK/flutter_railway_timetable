// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tdx_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultilingualName _$MultilingualNameFromJson(Map<String, dynamic> json) =>
    MultilingualName(
      zhTw: json['Zh_tw'] as String? ?? '',
      en: json['En'] as String? ?? '',
    );

Map<String, dynamic> _$MultilingualNameToJson(MultilingualName instance) =>
    <String, dynamic>{'Zh_tw': instance.zhTw, 'En': instance.en};

TdxStationDto _$TdxStationDtoFromJson(Map<String, dynamic> json) =>
    TdxStationDto(
      stationId: json['StationID'] as String? ?? '',
      stationName: json['StationName'] == null
          ? null
          : MultilingualName.fromJson(
              json['StationName'] as Map<String, dynamic>),
      city: json['LocationCity'] as String?,
    );

Map<String, dynamic> _$TdxStationDtoToJson(TdxStationDto instance) =>
    <String, dynamic>{
      'StationID': instance.stationId,
      'StationName': instance.stationName,
      'LocationCity': instance.city,
    };

TdxTimetableResponseDto _$TdxTimetableResponseDtoFromJson(
        Map<String, dynamic> json) =>
    TdxTimetableResponseDto(
      trainTimetables: (json['TrainTimetables'] as List<dynamic>?)
              ?.map((e) =>
                  TdxTrainTimetableDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TdxTimetableResponseDtoToJson(
        TdxTimetableResponseDto instance) =>
    <String, dynamic>{
      'TrainTimetables': instance.trainTimetables,
    };

TdxTrainTimetableDto _$TdxTrainTimetableDtoFromJson(
        Map<String, dynamic> json) =>
    TdxTrainTimetableDto(
      trainInfo: json['TrainInfo'] == null
          ? null
          : TdxTrainInfoDto.fromJson(
              json['TrainInfo'] as Map<String, dynamic>),
      stopTimes: (json['StopTimes'] as List<dynamic>?)
              ?.map(
                  (e) => TdxStopTimeDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TdxTrainTimetableDtoToJson(
        TdxTrainTimetableDto instance) =>
    <String, dynamic>{
      'TrainInfo': instance.trainInfo,
      'StopTimes': instance.stopTimes,
    };

TdxTrainInfoDto _$TdxTrainInfoDtoFromJson(Map<String, dynamic> json) =>
    TdxTrainInfoDto(
      trainNo: json['TrainNo'] as String? ?? '',
      trainTypeName: json['TrainTypeName'] == null
          ? null
          : MultilingualName.fromJson(
              json['TrainTypeName'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TdxTrainInfoDtoToJson(TdxTrainInfoDto instance) =>
    <String, dynamic>{
      'TrainNo': instance.trainNo,
      'TrainTypeName': instance.trainTypeName,
    };

TdxStopTimeDto _$TdxStopTimeDtoFromJson(Map<String, dynamic> json) =>
    TdxStopTimeDto(
      stationId: json['StationID'] as String? ?? '',
      departureTime: json['DepartureTime'] as String? ?? '',
      arrivalTime: json['ArrivalTime'] as String? ?? '',
    );

Map<String, dynamic> _$TdxStopTimeDtoToJson(TdxStopTimeDto instance) =>
    <String, dynamic>{
      'StationID': instance.stationId,
      'DepartureTime': instance.departureTime,
      'ArrivalTime': instance.arrivalTime,
    };
