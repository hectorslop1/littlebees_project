import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/storage/secure_token_storage.dart';
import '../../../shared/models/auth_models.dart';

class AuthRepository {
  final ApiClient _api = ApiClient.instance;

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      Endpoints.login,
      data: LoginRequest(email: email, password: password).toJson(),
    );

    final loginResponse = LoginResponse.fromJson(data);

    await SecureTokenStorage.storeTokens(
      accessToken: loginResponse.accessToken,
      refreshToken: loginResponse.refreshToken,
    );

    return loginResponse;
  }

  Future<MeResponse> getMe() async {
    final data = await _api.get<Map<String, dynamic>>(Endpoints.me);
    return MeResponse.fromJson(data);
  }

  Future<UserInfo> updateMyProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
  }) async {
    final payload = <String, dynamic>{};
    if (firstName != null) payload['firstName'] = firstName;
    if (lastName != null) payload['lastName'] = lastName;
    if (phone != null) payload['phone'] = phone;
    if (avatarUrl != null) payload['avatarUrl'] = avatarUrl;

    await _api.patch<Map<String, dynamic>>(Endpoints.usersMe, data: payload);

    final me = await getMe();
    return me.user;
  }

  Future<void> logout() async {
    await SecureTokenStorage.clearTokens();
  }

  Future<bool> hasValidSession() async {
    final accessToken = await SecureTokenStorage.getAccessToken();
    final accessPayload = accessToken != null ? _parseJwt(accessToken) : null;

    if (accessPayload != null && !accessPayload.isExpired) {
      return true;
    }

    final refreshToken = await SecureTokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final refreshPayload = _parseJwt(refreshToken);
    if (refreshPayload == null || refreshPayload.isExpired) {
      await SecureTokenStorage.clearTokens();
      return false;
    }

    return refreshSession();
  }

  Future<UserInfo?> getUserFromToken() async {
    var token = await SecureTokenStorage.getAccessToken();
    var payload = token != null ? _parseJwt(token) : null;

    if (payload == null || payload.isExpired) {
      final refreshed = await refreshSession();
      if (!refreshed) {
        return null;
      }
      token = await SecureTokenStorage.getAccessToken();
      payload = token != null ? _parseJwt(token) : null;
    }

    if (token == null || token.isEmpty) return null;
    if (payload == null || payload.isExpired) return null;

    return UserInfo(
      id: payload.sub,
      email: '',
      firstName: '',
      lastName: '',
      role: payload.role,
      mfaEnabled: false,
    );
  }

  Future<bool> refreshSession() async {
    try {
      final refreshToken = await SecureTokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final response =
          await Dio(
            BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: AppConfig.connectTimeout,
              receiveTimeout: AppConfig.receiveTimeout,
            ),
          ).post<Map<String, dynamic>>(
            Endpoints.refresh,
            data: {'refreshToken': refreshToken},
          );

      final data = response.data;
      if (data == null) {
        return false;
      }

      await SecureTokenStorage.storeTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      return true;
    } catch (_) {
      await SecureTokenStorage.clearTokens();
      return false;
    }
  }

  JwtPayload? _parseJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      return JwtPayload.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
