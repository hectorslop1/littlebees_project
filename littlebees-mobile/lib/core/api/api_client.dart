import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'auth_interceptor.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(_dio),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[API] $obj'),
      ),
    ]);
  }

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Dio get dio => _dio;

  // --- Convenience methods (mirrors web api-client.ts) ---

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    if (fromJson != null) return fromJson(response.data);
    return response.data as T;
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await _dio.post(path, data: data);
    if (fromJson != null) return fromJson(response.data);
    return response.data as T;
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await _dio.patch(path, data: data);
    if (fromJson != null) return fromJson(response.data);
    return response.data as T;
  }

  Future<T> delete<T>(
    String path, {
    T Function(dynamic)? fromJson,
  }) async {
    final response = await _dio.delete(path);
    if (fromJson != null) return fromJson(response.data);
    return response.data as T;
  }

  Future<T> upload<T>(
    String path, {
    required FormData formData,
    T Function(dynamic)? fromJson,
    void Function(int, int)? onSendProgress,
  }) async {
    final response = await _dio.post(
      path,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
      onSendProgress: onSendProgress,
    );
    if (fromJson != null) return fromJson(response.data);
    return response.data as T;
  }
}
