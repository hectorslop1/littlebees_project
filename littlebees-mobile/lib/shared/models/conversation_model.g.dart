// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationImpl _$$ConversationImplFromJson(Map<String, dynamic> json) =>
    _$ConversationImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      childId: json['childId'] as String?,
      childName: json['childName'] as String?,
      participants: (json['participants'] as List<dynamic>)
          .map(
            (e) => ConversationParticipant.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      lastMessage: json['lastMessage'] == null
          ? null
          : Message.fromJson(json['lastMessage'] as Map<String, dynamic>),
      unreadCount: (json['unreadCount'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ConversationImplToJson(_$ConversationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'childId': instance.childId,
      'childName': instance.childName,
      'participants': instance.participants,
      'lastMessage': instance.lastMessage,
      'unreadCount': instance.unreadCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$ConversationParticipantImpl _$$ConversationParticipantImplFromJson(
  Map<String, dynamic> json,
) => _$ConversationParticipantImpl(
  userId: json['userId'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  joinedAt: DateTime.parse(json['joinedAt'] as String),
  lastReadAt: json['lastReadAt'] == null
      ? null
      : DateTime.parse(json['lastReadAt'] as String),
);

Map<String, dynamic> _$$ConversationParticipantImplToJson(
  _$ConversationParticipantImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'avatarUrl': instance.avatarUrl,
  'joinedAt': instance.joinedAt.toIso8601String(),
  'lastReadAt': instance.lastReadAt?.toIso8601String(),
};

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderAvatarUrl: json['senderAvatarUrl'] as String?,
      content: json['content'] as String,
      messageType: json['messageType'] as String,
      attachmentUrl: json['attachmentUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'conversationId': instance.conversationId,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'senderAvatarUrl': instance.senderAvatarUrl,
      'content': instance.content,
      'messageType': instance.messageType,
      'attachmentUrl': instance.attachmentUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };
