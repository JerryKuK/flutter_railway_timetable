import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../env/env.dart';
import '../network/dio_client.dart';
import '../../features/timetable/data/datasource/tdx_tra_api_service.dart';
import '../../features/timetable/data/datasource/tdx_thsr_api_service.dart';

@module
abstract class AppModule {
  @lazySingleton
  Dio get dio => DioClient.create(
        tdxClientId: Env.tdxClientId,
        tdxClientSecret: Env.tdxClientSecret,
      );

  @lazySingleton
  TdxTraApiService tdxTraApiService(Dio dio) => TdxTraApiService(dio);

  @Named('thsr')
  @lazySingleton
  TdxThsrApiService tdxThsrApiService(Dio dio) => TdxThsrApiService(dio);
}
