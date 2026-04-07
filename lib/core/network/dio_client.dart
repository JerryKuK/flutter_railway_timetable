import 'package:dio/dio.dart';
import 'tdx_auth_interceptor.dart';

class DioClient {
  static Dio create({
    required String tdxClientId,
    required String tdxClientSecret,
  }) {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      TdxAuthInterceptor(
        clientId: tdxClientId,
        clientSecret: tdxClientSecret,
      ),
    );

    return dio;
  }
}
