import 'package:dio/dio.dart';

class TdxAuthInterceptor extends Interceptor {
  final String clientId;
  final String clientSecret;

  String? _accessToken;
  DateTime? _tokenExpiry;

  TdxAuthInterceptor({required this.clientId, required this.clientSecret});

  static const _tokenUrl =
      'https://tdx.transportdata.tw/auth/realms/TDXConnect/protocol/openid-connect/token';

  bool get _isTokenValid =>
      _accessToken != null &&
      _tokenExpiry != null &&
      DateTime.now().isBefore(_tokenExpiry!);

  Future<void> _refreshToken() async {
    final dio = Dio();
    final response = await dio.post<Map<String, dynamic>>(
      _tokenUrl,
      data: {
        'grant_type': 'client_credentials',
        'client_id': clientId,
        'client_secret': clientSecret,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    _accessToken = response.data!['access_token'] as String;
    final expiresIn = response.data!['expires_in'] as int;
    _tokenExpiry =
        DateTime.now().add(Duration(seconds: expiresIn - 60));
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      if (!_isTokenValid) {
        await _refreshToken();
      }
      options.headers['Authorization'] = 'Bearer $_accessToken';
      handler.next(options);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: e,
          message: 'TDX 認證失敗：$e',
        ),
      );
    }
  }
}
