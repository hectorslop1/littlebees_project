import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String conversationId,
    required String senderId,
    required String senderName,
    String? senderAvatarUrl,
    required String content,
    String? attachmentUrl,
    String? attachmentType,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(false) bool isRead,
    @Default(false) bool isDeleted,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}

@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String participantId,
    required String participantName,
    String? participantAvatarUrl,
    String? participantRole,
    Message? lastMessage,
    @Default(0) int unreadCount,
    DateTime? lastMessageAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}
