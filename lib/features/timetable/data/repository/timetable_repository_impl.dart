import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entity/station.dart';
import '../../domain/entity/train.dart';
import '../../domain/repository/timetable_repository.dart';
import '../datasource/tdx_tra_api_service.dart';
import '../dto/tdx_response_dto.dart';

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
      // 並行呼叫班次與票價 API（Future.wait 同時發出，不序列等待）
      final results = await Future.wait([
        _fetchODFareMap(origin, destination),
        _apiService.getDailyTimetable(origin, destination, date),
      ]);
      final fareMap = results[0] as Map<String, int>;
      final response = results[1] as TdxTimetableResponseDto;
      return response.trainTimetables.map((timetable) {
        // v3 OD 端點：StopTimes[0] = 出發站，StopTimes[last] = 到達站
        final originStop =
            timetable.stopTimes.isNotEmpty ? timetable.stopTimes.first : null;
        final destStop =
            timetable.stopTimes.length > 1 ? timetable.stopTimes.last : null;
        final depTime = originStop?.departureTime ?? '';
        final arrTime = destStop?.arrivalTime ?? '';
        final typeName = timetable.trainInfo?.trainTypeName?.zhTw ?? '';
        return Train(
          trainNo: timetable.trainInfo?.trainNo ?? '',
          trainTypeName: typeName,
          departureTime: depTime,
          arrivalTime: arrTime,
          travelTime: _computeTravelTime(depTime, arrTime),
          fare: fareMap[_trainTypeAbbr(typeName)] ?? 0,
        );
      }).toList();
    } on DioException catch (e) {
      // TDX OD 時刻表 API 在查無班次時回傳 404，視為空結果而非錯誤
      if (e.response?.statusCode == 404) return [];
      rethrow;
    }
  }

  /// 取得 OD 票價 Map（車種單字縮寫 → 成人全票金額）。
  /// key 為車種縮寫字元：自/莒/復/普（對應 TDX TicketType 的第二字）
  /// 若 API 失敗則回傳空 Map，不影響班次顯示。
  Future<Map<String, int>> _fetchODFareMap(
      String origin, String destination) async {
    try {
      final items = await _apiService.getODFare(origin, destination);
      if (items.isEmpty) return {};
      final fares = items.first.fares;
      // 只取成人票（TicketType 以「成」開頭），第二字為車種縮寫
      // 只取恰好兩字的成人全票（如「成自」），排除折扣票（如「成自折」三字）
      return {
        for (final f in fares)
          if (f.ticketType.length == 2 && f.ticketType.startsWith('成'))
            f.ticketType[1]: f.price,
      };
    } catch (_) {
      return {};
    }
  }

  /// 將列車種類名稱對應至 TDX ODFare TicketType 的車種縮寫字元。
  String _trainTypeAbbr(String typeName) {
    if (typeName.contains('自強') ||
        typeName.contains('太魯閣') ||
        typeName.contains('普悠瑪') ||
        typeName.contains('EMU') ||
        typeName.contains('TEMU')) return '自';
    if (typeName.contains('莒光')) return '莒';
    if (typeName.contains('復興')) return '復';
    if (typeName.contains('普快') ||
        typeName.contains('普通') ||
        typeName.contains('區間快') ||
        typeName.contains('區間')) return '普';
    return '';
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
