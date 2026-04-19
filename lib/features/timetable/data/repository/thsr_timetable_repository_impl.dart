import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entity/station.dart';
import '../../domain/entity/train.dart';
import '../../domain/repository/thsr_timetable_repository.dart';
import '../datasource/tdx_thsr_api_service.dart';

@LazySingleton(as: ThsrTimetableRepository)
class ThsrTimetableRepositoryImpl implements ThsrTimetableRepository {
  final TdxThsrApiService _apiService;
  List<Station>? _cachedStations;

  ThsrTimetableRepositoryImpl(@Named('thsr') this._apiService);

  @override
  Future<List<Train>> getDailyTimetable({
    required String origin,
    required String destination,
    required String date,
  }) async {
    try {
      final results = await Future.wait([
        _fetchODFareMap(origin, destination),
        _apiService.getDailyTimetable(origin, destination, date),
      ]);
      final fareMap = results[0] as Map<String, int>;
      final trains = results[1] as List;

      return trains.map((t) {
        final dep = t.originStopTime?.departureTime ?? '';
        final arr = t.destinationStopTime?.arrivalTime ?? '';
        final typeName = t.trainTypeName?.zhTw ?? '高鐵';
        return Train(
          trainNo: t.trainNo,
          trainTypeName: typeName,
          departureTime: dep,
          arrivalTime: arr,
          travelTime: _computeTravelTime(dep, arr),
          fare: fareMap['standard'] ?? 0,
        );
      }).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      rethrow;
    }
  }

  /// 取得自由座成人票價（TicketType=1, FareClass=1, CabinClass=3）。
  /// 若 API 失敗則回傳空 Map，不影響班次顯示。
  Future<Map<String, int>> _fetchODFareMap(
      String origin, String destination) async {
    try {
      final items = await _apiService.getODFare(origin, destination);
      if (items.isEmpty) return {};
      final fares = items.first.fares;
      final fare = fares
          .where((f) =>
              f.ticketType == 1 && f.fareClass == 1 && f.cabinClass == 3)
          .firstOrNull;
      if (fare == null) return {};
      return {'standard': fare.price};
    } catch (_) {
      return {};
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
