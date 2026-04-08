import 'package:dio/dio.dart';
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
    try {
      final response =
          await _apiService.getDailyTimetable(origin, destination, date);
      return response.trainTimetables.map((timetable) {
        // v3 OD 端點：StopTimes[0] = 出發站，StopTimes[last] = 到達站
        final originStop =
            timetable.stopTimes.isNotEmpty ? timetable.stopTimes.first : null;
        final destStop =
            timetable.stopTimes.length > 1 ? timetable.stopTimes.last : null;
        final depTime = originStop?.departureTime ?? '';
        final arrTime = destStop?.arrivalTime ?? '';
        return Train(
          trainNo: timetable.trainInfo?.trainNo ?? '',
          trainTypeName: timetable.trainInfo?.trainTypeName?.zhTw ?? '',
          departureTime: depTime,
          arrivalTime: arrTime,
          travelTime: _computeTravelTime(depTime, arrTime),
          fare: 0,
        );
      }).toList();
    } on DioException catch (e) {
      // TDX OD 時刻表 API 在查無班次時回傳 404，視為空結果而非錯誤
      if (e.response?.statusCode == 404) return [];
      rethrow;
    }
  }

  @override
  Future<List<Station>> getStations() async {
    if (_cachedStations != null) return _cachedStations!;
    final dtos = await _apiService.getStations();
    _cachedStations = dtos
        .map((dto) => Station(
              stationId: dto.stationId,
              stationName: dto.stationName?.zhTw ?? dto.stationId,
              city: dto.city ?? '',
            ))
        .toList();
    return _cachedStations!;
  }

  String _computeTravelTime(String departure, String arrival) {
    if (departure.isEmpty || arrival.isEmpty) return '';
    try {
      final dep = _toMinutes(departure);
      final arr = _toMinutes(arrival);
      int diff = arr - dep;
      if (diff < 0) diff += 24 * 60;
      final h = diff ~/ 60;
      final m = diff % 60;
      return h > 0 ? '$h 時 ${m.toString().padLeft(2, '0')} 分' : '$m 分';
    } catch (_) {
      return '';
    }
  }

  int _toMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
