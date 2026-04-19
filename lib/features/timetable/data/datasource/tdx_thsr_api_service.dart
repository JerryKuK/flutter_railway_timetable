import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../dto/tdx_thsr_response_dto.dart';

part 'tdx_thsr_api_service.g.dart';

@RestApi(baseUrl: 'https://tdx.transportdata.tw')
abstract class TdxThsrApiService {
  factory TdxThsrApiService(Dio dio, {String baseUrl}) = _TdxThsrApiService;

  @GET('/api/basic/v2/Rail/THSR/DailyTimetable/OD/{origin}/to/{destination}/{trainDate}')
  Future<List<TdxThsrDailyTrainDto>> getDailyTimetable(
    @Path('origin') String origin,
    @Path('destination') String destination,
    @Path('trainDate') String trainDate, {
    @Query('\$format') String format = 'JSON',
  });

  @GET('/api/basic/v2/Rail/THSR/Station')
  Future<List<TdxThsrStationDto>> getStations({
    @Query('\$format') String format = 'JSON',
  });

  @GET('/api/basic/v2/Rail/THSR/ODFare/{originStationId}/to/{destinationStationId}')
  Future<List<TdxThsrODFareItemDto>> getODFare(
    @Path('originStationId') String originStationId,
    @Path('destinationStationId') String destinationStationId, {
    @Query('\$format') String format = 'JSON',
  });
}
