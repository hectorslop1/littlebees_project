class AppConfig {
  AppConfig._();

  // API Configuration — apunta al backend NestJS
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3002/api/v1',
  );

  // WebSocket Configuration
  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'http://localhost:3002',
  );

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Token expiry (must match backend JWT config)
  static const Duration accessTokenExpiry = Duration(minutes: 15);
  static const Duration refreshTokenExpiry = Duration(days: 7);
}
