import 'package:freezed_annotation/freezed_annotation.dart';

part 'station.freezed.dart';

@freezed
abstract class Station with _$Station {
  const factory Station({
    required String stationId,
    required String stationName,
  }) = _Station;
}
