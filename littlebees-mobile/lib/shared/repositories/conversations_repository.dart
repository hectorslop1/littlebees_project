import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../models/conversation_model.dart';

class ConversationsRepository {
  final ApiClient _api = ApiClient.instance;

  Future<List<Conversation>> getMyConversations() async {
    try {
      final response = await _api.get<dynamic>(Endpoints.conversations);

      List items;
      if (response is List) {
        items = response;
      } else if (response is Map<String, dynamic>) {
        items = response['data'] as List? ?? [];
      } else {
        items = [];
      }

      return items.map((json) => _parseConversation(json)).toList();
    } catch (e) {
      throw Exception('Error loading conversations: $e');
    }
  }

  Future<List<Message>> getMessages(String conversationId) async {
    try {
      final response = await _api.get<dynamic>(
        Endpoints.messages(conversationId),
      );

      List items;
      if (response is List) {
        items = response;
      } else if (response is Map<String, dynamic>) {
        items = response['data'] as List? ?? [];
      } else {
        items = [];
      }

      return items.map((json) => _parseMessage(json)).toList();
    } catch (e) {
      throw Exception('Error loading messages: $e');
    }
  }

  Future<Message> sendMessage({
    required String conversationId,
    required String content,
    String? attachmentUrl,
  }) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        Endpoints.messages(conversationId),
        data: {
          'content': content,
          'messageType': attachmentUrl != null ? 'image' : 'text',
          'attachmentUrl': attachmentUrl,
        },
      );
      return _parseMessage(response);
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  Conversation _parseConversation(Map<String, dynamic> json) {
    final participants = (json['participants'] as List? ?? [])
        .map((p) => ConversationParticipant(
              userId: p['userId'] as String,
              firstName: p['firstName'] as String? ?? '',
              lastName: p['lastName'] as String? ?? '',
              avatarUrl: p['avatarUrl'] as String?,
              joinedAt: DateTime.parse(p['joinedAt'] as String),
              lastReadAt: p['lastReadAt'] != null
                  ? DateTime.parse(p['lastReadAt'] as String)
                  : null,
            ))
        .toList();

    return Conversation(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      childId: json['childId'] as String?,
      childName: json['childName'] as String?,
      participants: participants,
      lastMessage: json['lastMessage'] != null
          ? _parseMessage(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Message _parseMessage(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String? ?? 'Unknown',
      senderAvatarUrl: json['senderAvatarUrl'] as String?,
      content: json['content'] as String,
      messageType: json['messageType'] as String? ?? 'text',
      attachmentUrl: json['attachmentUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
    );
  }
}
