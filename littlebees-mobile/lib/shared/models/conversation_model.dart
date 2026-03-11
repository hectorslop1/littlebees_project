import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_model.freezed.dart';
part 'conversation_model.g.dart';

@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String tenantId,
    String? childId,
    String? childName,
    required List<ConversationParticipant> participants,
    Message? lastMessage,
    int? unreadCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}

@freezed
class ConversationParticipant with _$ConversationParticipant {
  const factory ConversationParticipant({
    required String userId,
    required String firstName,
    required String lastName,
    String? avatarUrl,
    required DateTime joinedAt,
    DateTime? lastReadAt,
  }) = _ConversationParticipant;

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) =>
      _$ConversationParticipantFromJson(json);
}

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String tenantId,
    required String conversationId,
    required String senderId,
    required String senderName,
    String? senderAvatarUrl,
    required String content,
    required String messageType,
    String? attachmentUrl,
    required DateTime createdAt,
    DateTime? deletedAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
