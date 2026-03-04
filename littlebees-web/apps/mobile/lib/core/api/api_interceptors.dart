import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final _storage = const FlutterSecureStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try to refresh the token
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken != null) {
        try {
          final dio = Dio();
          final response = await dio.post(
            '${err.requestOptions.baseUrl}/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          final newAccessToken = response.data['accessToken'];
          await _storage.write(key: 'access_token', value: newAccessToken);

          // Retry the original request
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryResponse = await dio.fetch(err.requestOptions);
          handler.resolve(retryResponse);
          return;
        } catch (_) {
          // Refresh failed, clear tokens
          await _storage.deleteAll();
        }
      }
    }
    handler.next(err);
  }
}
