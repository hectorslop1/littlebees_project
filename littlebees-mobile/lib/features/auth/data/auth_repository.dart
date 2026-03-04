import 'dart:convert';
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

  Future<void> logout() async {
    await SecureTokenStorage.clearTokens();
  }

  Future<bool> hasValidSession() async {
    final token = await SecureTokenStorage.getAccessToken();
    if (token == null || token.isEmpty) return false;

    final payload = _parseJwt(token);
    if (payload == null) return false;

    return !payload.isExpired;
  }

  Future<UserInfo?> getUserFromToken() async {
    final token = await SecureTokenStorage.getAccessToken();
    if (token == null || token.isEmpty) return null;

    final payload = _parseJwt(token);
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
