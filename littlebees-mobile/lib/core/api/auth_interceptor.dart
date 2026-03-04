import 'dart:async';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/secure_token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;
  final List<_RetryRequest> _pendingRequests = [];

  AuthInterceptor(this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureTokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Don't retry refresh or login requests
    final path = err.requestOptions.path;
    if (path.contains('/auth/refresh') || path.contains('/auth/login')) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      // Queue the request to retry after refresh completes
      final completer = Completer<Response>();
      _pendingRequests.add(_RetryRequest(err.requestOptions, completer));
      try {
        final response = await completer.future;
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    _isRefreshing = true;

    try {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // Retry the original request with new token
        final newToken = await SecureTokenStorage.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final response = await _dio.fetch(err.requestOptions);

        // Retry all pending requests
        for (final pending in _pendingRequests) {
          pending.options.headers['Authorization'] = 'Bearer $newToken';
          try {
            final r = await _dio.fetch(pending.options);
            pending.completer.complete(r);
          } catch (e) {
            pending.completer.completeError(e);
          }
        }
        _pendingRequests.clear();

        return handler.resolve(response);
      } else {
        // Refresh failed — clear tokens, reject all pending
        await SecureTokenStorage.clearTokens();
        for (final pending in _pendingRequests) {
          pending.completer.completeError(err);
        }
        _pendingRequests.clear();
        return handler.next(err);
      }
    } catch (e) {
      await SecureTokenStorage.clearTokens();
      for (final pending in _pendingRequests) {
        pending.completer.completeError(e);
      }
      _pendingRequests.clear();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await SecureTokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final response = await Dio(BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
      )).post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        await SecureTokenStorage.storeTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

class _RetryRequest {
  final RequestOptions options;
  final Completer<Response> completer;

  _RetryRequest(this.options, this.completer);
}
