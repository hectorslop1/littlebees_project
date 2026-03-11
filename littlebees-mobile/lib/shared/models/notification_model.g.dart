// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNotificationImpl _$$AppNotificationImplFromJson(
  Map<String, dynamic> json,
) => _$AppNotificationImpl(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  userId: json['userId'] as String,
  type: json['type'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  data: json['data'] as Map<String, dynamic>?,
  read: json['read'] as bool,
  sentAt: DateTime.parse(json['sentAt'] as String),
  readAt: json['readAt'] == null
      ? null
      : DateTime.parse(json['readAt'] as String),
  channel: json['channel'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$AppNotificationImplToJson(
  _$AppNotificationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  'userId': instance.userId,
  'type': instance.type,
  'title': instance.title,
  'body': instance.body,
  'data': instance.data,
  'read': instance.read,
  'sentAt': instance.sentAt.toIso8601String(),
  'readAt': instance.readAt?.toIso8601String(),
  'channel': instance.channel,
  'createdAt': instance.createdAt.toIso8601String(),
};
