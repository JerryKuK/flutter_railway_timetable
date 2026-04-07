import 'package:injectable/injectable.dart';
import '../../domain/entity/station.dart';
import '../../domain/entity/train.dart';
import '../../domain/repository/timetable_repository.dart';
import '../datasource/tdx_tra_api_service.dart';

@LazySingleton(as: TimetableRepository)
class TimetableRepositoryImpl implements TimetableRepository {
  final TdxTraApiService _apiService;
  List<Station>? _cachedStations;

  TimetableRepositoryImpl(this._apiService);

  @override
  Future<List<Train>> getDailyTimetable({
    required String origin,
    required String destination,
    required String date,
  }) async {
    final dtos = await _apiService.getDailyTimetable(origin, destination, date);
    return dtos
        .map(
          (dto) => Train(
            trainNo: dto.trainNo,
            trainTypeName: dto.trainTypeName,
            departureTime: dto.departureTime,
            arrivalTime: dto.arrivalTime,
            travelTime: dto.travelTime,
            fare: dto.fare,
          ),
        )
        .toList();
  }

  @override
  Future<List<Station>> getStations() async {
    if (_cachedStations != null) return _cachedStations!;
    final dtos = await _apiService.getStations();
    _cachedStations = dtos
        .map((dto) => Station(
              stationId: dto.stationId,
              stationName: dto.stationName,
            ))
        .toList();
    return _cachedStations!;
  }
}
