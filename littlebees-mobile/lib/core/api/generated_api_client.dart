/// Wrapper para el cliente API generado automáticamente
///
/// Este archivo proporciona una interfaz simplificada para usar el cliente
/// generado desde OpenAPI. Una vez que se genere el cliente, descomenta el código.
///
/// Para generar el cliente:
/// 1. Asegúrate de que el API esté corriendo: `pnpm dev:api`
/// 2. Genera el cliente: `pnpm generate:api-client`

// TODO: Descomentar después de generar el cliente
// import 'package:littlebees_mobile/generated/api/api.dart';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'auth_interceptor.dart';

/// Cliente API generado automáticamente desde OpenAPI
///
/// Uso:
/// ```dart
/// final api = GeneratedApiClient.instance;
///
/// // Login
/// final response = await api.auth.login(
///   loginDto: LoginDto(email: 'user@example.com', password: 'pass'),
/// );
///
/// // Obtener niños
/// final children = await api.children.getChildren();
/// ```
class GeneratedApiClient {
  static GeneratedApiClient? _instance;

  // TODO: Descomentar después de generar el cliente
  // late final KinderspaceApi _api;
  late final Dio _dio;

  GeneratedApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
      ),
    );

    // Agregar interceptor de autenticación
    _dio.interceptors.add(AuthInterceptor(_dio));

    // TODO: Descomentar después de generar el cliente
    // _api = KinderspaceApi(
    //   dio: _dio,
    //   basePathOverride: AppConfig.apiBaseUrl,
    // );
  }

  static GeneratedApiClient get instance {
    _instance ??= GeneratedApiClient._();
    return _instance!;
  }

  // TODO: Descomentar después de generar el cliente
  // Acceso a los diferentes APIs
  // AuthApi get auth => _api.getAuthApi();
  // ChildrenApi get children => _api.getChildrenApi();
  // AttendanceApi get attendance => _api.getAttendanceApi();
  // DailyLogsApi get dailyLogs => _api.getDailyLogsApi();
  // ChatApi get chat => _api.getChatApi();
  // PaymentsApi get payments => _api.getPaymentsApi();
  // NotificationsApi get notifications => _api.getNotificationsApi();
  // FilesApi get files => _api.getFilesApi();
  // DevelopmentApi get development => _api.getDevelopmentApi();

  /// Reiniciar el cliente (útil después de logout)
  static void reset() {
    _instance = null;
  }
}
