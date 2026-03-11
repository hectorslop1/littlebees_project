import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String tenantId,
    required String userId,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    required bool read,
    required DateTime sentAt,
    DateTime? readAt,
    required String channel,
    required DateTime createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
