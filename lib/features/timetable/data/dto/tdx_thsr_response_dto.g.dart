// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tdx_thsr_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TdxThsrStationDto _$TdxThsrStationDtoFromJson(Map<String, dynamic> json) =>
    TdxThsrStationDto(
      stationId: json['StationID'] as String? ?? '',
      stationName:
          json['StationName'] == null
              ? null
              : TdxThsrMultilingualName.fromJson(
                json['StationName'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$TdxThsrStationDtoToJson(TdxThsrStationDto instance) =>
    <String, dynamic>{
      'StationID': instance.stationId,
      'StationName': instance.stationName,
    };

TdxThsrMultilingualName _$TdxThsrMultilingualNameFromJson(
  Map<String, dynamic> json,
) => TdxThsrMultilingualName(
  zhTw: json['Zh_tw'] as String? ?? '',
  en: json['En'] as String? ?? '',
);

Map<String, dynamic> _$TdxThsrMultilingualNameToJson(
  TdxThsrMultilingualName instance,
) => <String, dynamic>{'Zh_tw': instance.zhTw, 'En': instance.en};

TdxThsrDailyTrainDto _$TdxThsrDailyTrainDtoFromJson(
  Map<String, dynamic> json,
) => TdxThsrDailyTrainDto(
  trainNo: json['TrainNo'] as String? ?? '',
  trainTypeName:
      json['TrainTypeName'] == null
          ? null
          : TdxThsrMultilingualName.fromJson(
            json['TrainTypeName'] as Map<String, dynamic>,
          ),
  originStopTime:
      json['OriginStopTime'] == null
          ? null
          : TdxThsrStopTimeDto.fromJson(
            json['OriginStopTime'] as Map<String, dynamic>,
          ),
  destinationStopTime:
      json['DestinationStopTime'] == null
          ? null
          : TdxThsrStopTimeDto.fromJson(
            json['DestinationStopTime'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$TdxThsrDailyTrainDtoToJson(
  TdxThsrDailyTrainDto instance,
) => <String, dynamic>{
  'TrainNo': instance.trainNo,
  'TrainTypeName': instance.trainTypeName,
  'OriginStopTime': instance.originStopTime,
  'DestinationStopTime': instance.destinationStopTime,
};

TdxThsrStopTimeDto _$TdxThsrStopTimeDtoFromJson(Map<String, dynamic> json) =>
    TdxThsrStopTimeDto(
      departureTime: json['DepartureTime'] as String? ?? '',
      arrivalTime: json['ArrivalTime'] as String? ?? '',
    );

Map<String, dynamic> _$TdxThsrStopTimeDtoToJson(TdxThsrStopTimeDto instance) =>
    <String, dynamic>{
      'DepartureTime': instance.departureTime,
      'ArrivalTime': instance.arrivalTime,
    };

TdxThsrODFareItemDto _$TdxThsrODFareItemDtoFromJson(
  Map<String, dynamic> json,
) => TdxThsrODFareItemDto(
  originStationId: json['OriginStationID'] as String? ?? '',
  destinationStationId: json['DestinationStationID'] as String? ?? '',
  fares:
      (json['Fares'] as List<dynamic>?)
          ?.map((e) => TdxThsrFareDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$TdxThsrODFareItemDtoToJson(
  TdxThsrODFareItemDto instance,
) => <String, dynamic>{
  'OriginStationID': instance.originStationId,
  'DestinationStationID': instance.destinationStationId,
  'Fares': instance.fares,
};

TdxThsrFareDto _$TdxThsrFareDtoFromJson(Map<String, dynamic> json) =>
    TdxThsrFareDto(
      ticketType: (json['TicketType'] as num?)?.toInt() ?? 0,
      fareClass: (json['FareClass'] as num?)?.toInt() ?? 0,
      cabinClass: (json['CabinClass'] as num?)?.toInt() ?? 0,
      price: (json['Price'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TdxThsrFareDtoToJson(TdxThsrFareDto instance) =>
    <String, dynamic>{
      'TicketType': instance.ticketType,
      'FareClass': instance.fareClass,
      'CabinClass': instance.cabinClass,
      'Price': instance.price,
    };
