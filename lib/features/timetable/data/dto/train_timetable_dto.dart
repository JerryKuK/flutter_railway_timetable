class TrainTimetableDto {
  final String trainNo;
  final String trainTypeName;
  final String departureTime;
  final String arrivalTime;
  final String travelTime;
  final int fare;

  const TrainTimetableDto({
    required this.trainNo,
    required this.trainTypeName,
    required this.departureTime,
    required this.arrivalTime,
    required this.travelTime,
    required this.fare,
  });

  factory TrainTimetableDto.fromJson(Map<String, dynamic> json) {
    return TrainTimetableDto(
      trainNo: json['TrainNo'] as String? ?? '',
      trainTypeName: (json['TrainTypeName'] as Map?)?.entries.first.value as String? ?? '',
      departureTime: json['DepartureTime'] as String? ?? '',
      arrivalTime: json['ArrivalTime'] as String? ?? '',
      travelTime: json['TravelTime'] as String? ?? '',
      fare: json['Fare'] as int? ?? 0,
    );
  }
}

class StationDto {
  final String stationId;
  final String stationName;

  const StationDto({required this.stationId, required this.stationName});

  factory StationDto.fromJson(Map<String, dynamic> json) {
    return StationDto(
      stationId: json['StationID'] as String? ?? '',
      stationName: (json['StationName'] as Map?)?.entries.first.value as String? ?? '',
    );
  }
}
