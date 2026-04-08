import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('[Dio] $obj'),
      ));
    }

    return dio;
  }
}
