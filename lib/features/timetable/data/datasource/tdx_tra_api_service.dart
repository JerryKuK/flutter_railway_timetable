import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../dto/tdx_response_dto.dart';

part 'tdx_tra_api_service.g.dart';

@RestApi(baseUrl: 'https://tdx.transportdata.tw')
abstract class TdxTraApiService {
  factory TdxTraApiService(Dio dio, {String baseUrl}) = _TdxTraApiService;

  @GET('/api/basic/v3/Rail/TRA/DailyTrainTimetable/OD/{origin}/to/{destination}/{trainDate}')
  Future<TdxTimetableResponseDto> getDailyTimetable(
    @Path('origin') String origin,
    @Path('destination') String destination,
    @Path('trainDate') String trainDate, {
    @Query('\$format') String format = 'JSON',
  });

  @GET('/api/basic/v2/Rail/TRA/Station')
  Future<List<TdxStationDto>> getStations({
    @Query('\$format') String format = 'JSON',
    @Query('\$top') int top = 500,
  });
}
