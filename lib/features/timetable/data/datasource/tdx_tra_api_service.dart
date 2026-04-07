import 'package:dio/dio.dart';
import '../dto/train_timetable_dto.dart';

class TdxTraApiService {
  final Dio _dio;

  TdxTraApiService(this._dio);

  Future<List<TrainTimetableDto>> getDailyTimetable(
    String origin,
    String destination,
    String trainDate,
  ) async {
    final response = await _dio.get<List>(
      'https://tdx.transportdata.tw/api/basic/v2/Rail/TRA/DailyTrainTimetable/OD/$origin/$destination/$trainDate',
      queryParameters: {'\$format': 'JSON'},
    );
    if (response.data == null) return [];
    return response.data!
        .map((e) => TrainTimetableDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<StationDto>> getStations() async {
    final response = await _dio.get<List>(
      'https://tdx.transportdata.tw/api/basic/v2/Rail/TRA/Station',
      queryParameters: {'\$format': 'JSON'},
    );
    if (response.data == null) return [];
    return response.data!
        .map((e) => StationDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
