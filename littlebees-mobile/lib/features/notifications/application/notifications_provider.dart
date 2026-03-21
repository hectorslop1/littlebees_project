import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/notification_model.dart';
import '../data/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository();
});

final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final repository = ref.watch(notificationsRepositoryProvider);
  return repository.getNotifications(limit: 50);
});

final notificationUnreadCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(notificationsRepositoryProvider);
  final response = await repository.getUnreadCount();
  return response['unread'] as int? ?? 0;
});

final markNotificationReadProvider = Provider((ref) {
  return (String notificationId) async {
    final repository = ref.read(notificationsRepositoryProvider);
    await repository.markAsRead(notificationId);
    ref.invalidate(notificationsProvider);
    ref.invalidate(notificationUnreadCountProvider);
  };
});

final markAllNotificationsReadProvider = Provider((ref) {
  return () async {
    final repository = ref.read(notificationsRepositoryProvider);
    await repository.markAllAsRead();
    ref.invalidate(notificationsProvider);
    ref.invalidate(notificationUnreadCountProvider);
  };
});
