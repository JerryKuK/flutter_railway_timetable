import 'package:freezed_annotation/freezed_annotation.dart';

part 'train.freezed.dart';

@freezed
abstract class Train with _$Train {
  const factory Train({
    required String trainNo,
    required String trainTypeName,
    required String departureTime,
    required String arrivalTime,
    required String travelTime,
    required int fare,
  }) = _Train;
}
