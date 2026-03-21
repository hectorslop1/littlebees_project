class AppConfig {
  AppConfig._();

  // API base URL for the NestJS backend.
  // Override with --dart-define in each environment when needed.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://216.250.125.239:3002/api/v1',
  );

  // WebSocket base URL must not include the REST prefix.
  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'http://216.250.125.239:3002',
  );

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Token expiry (must match backend JWT config)
  static const Duration accessTokenExpiry = Duration(minutes: 15);
  static const Duration refreshTokenExpiry = Duration(days: 7);
}
