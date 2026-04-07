import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../network/dio_client.dart';
import '../../features/timetable/data/datasource/tdx_tra_api_service.dart';

@module
abstract class AppModule {
  @lazySingleton
  Dio get dio => DioClient.create(
        tdxClientId: const String.fromEnvironment(
          'TDX_CLIENT_ID',
          defaultValue: '',
        ),
        tdxClientSecret: const String.fromEnvironment(
          'TDX_CLIENT_SECRET',
          defaultValue: '',
        ),
      );

  @lazySingleton
  TdxTraApiService tdxTraApiService(Dio dio) => TdxTraApiService(dio);
}
