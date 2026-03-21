import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../shared/models/notification_model.dart';

class NotificationsRepository {
  NotificationsRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  Future<List<AppNotification>> getNotifications({
    bool? read,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Endpoints.notifications,
      queryParameters: {
        'page': page,
        'limit': limit,
        'read': read,
        if (type != null && type.isNotEmpty) 'type': type,
      },
    );

    final items = (response['data'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList();

    return items;
  }

  Future<Map<String, dynamic>> getUnreadCount() async {
    return _apiClient.get<Map<String, dynamic>>('${Endpoints.notifications}/count');
  }

  Future<void> markAsRead(String notificationId) async {
    await _apiClient.patch('${Endpoints.notifications}/$notificationId/read');
  }

  Future<void> markAllAsRead() async {
    await _apiClient.patch('${Endpoints.notifications}/read-all');
  }
}
