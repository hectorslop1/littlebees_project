class AppConfig {
  AppConfig._();

  // API Configuration — apunta al backend NestJS
  // DESARROLLO: http://localhost:3002/api/v1 (incluye global prefix)
  // PRODUCCIÓN: Servidor IONOS desplegado
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://216.250.125.239:3002/api/v1', // ← Servidor IONOS
  );

  // WebSocket Configuration
  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'http://216.250.125.239:3002/api/v1', // ← Servidor IONOS
  );

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Token expiry (must match backend JWT config)
  static const Duration accessTokenExpiry = Duration(minutes: 15);
  static const Duration refreshTokenExpiry = Duration(days: 7);
}
