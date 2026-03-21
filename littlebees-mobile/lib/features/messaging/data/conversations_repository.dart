import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../domain/chat_contact.dart';
import '../../../shared/models/message_model.dart';

class ConversationsRepository {
  final ApiClient _apiClient;

  ConversationsRepository(this._apiClient);

  Future<List<Conversation>> getConversations({
    required String currentUserId,
  }) async {
    try {
      final response = await _apiClient.get<dynamic>(Endpoints.conversations);
      final items = _extractList(response);
      return items
          .map((item) => _parseConversation(item, currentUserId))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 500) {
        return [];
      }
      throw _handleError(e);
    }
  }

  Future<Conversation> getConversationById(
    String id, {
    required String currentUserId,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${Endpoints.conversations}/$id',
      );
      return _parseConversation(response, currentUserId);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Message>> getMessages(
    String conversationId, {
    int limit = 50,
  }) async {
    try {
      final response = await _apiClient.get<dynamic>(
        Endpoints.messages(conversationId),
        queryParameters: {'limit': limit},
      );
      final items = _extractList(response);
      return items.map(_parseMessage).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ChatContact>> getAvailableContacts() async {
    try {
      final response = await _apiClient.get<dynamic>(Endpoints.chatContacts);
      final items = _extractList(response);
      return items.map(ChatContact.fromJson).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception(
          'El backend actual no tiene disponible /chat/contacts. Necesita desplegarse la nueva API.',
        );
      }
      throw _handleError(e);
    }
  }

  Future<Conversation> createConversation({
    required String participantId,
    required String childId,
    required String currentUserId,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        Endpoints.conversations,
        data: {
          'childId': childId,
          'participantIds': [participantId],
        },
      );

      return _parseConversation(response, currentUserId);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markAsRead(String conversationId) async {
    try {
      await _apiClient.patch('${Endpoints.conversations}/$conversationId/read');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await _apiClient.delete('${Endpoints.conversations}/$conversationId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  List<Map<String, dynamic>> _extractList(dynamic response) {
    if (response is List) {
      return response
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }

    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List) {
        return data
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
    }

    return [];
  }

  Conversation _parseConversation(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    final participants = (json['participants'] as List? ?? [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    final otherParticipant = participants
        .cast<Map<String, dynamic>?>()
        .firstWhere(
          (participant) => participant?['userId'] != currentUserId,
          orElse: () => participants.isNotEmpty ? participants.first : null,
        );

    final firstName = otherParticipant?['firstName'] as String? ?? '';
    final lastName = otherParticipant?['lastName'] as String? ?? '';
    final displayName = [
      firstName,
      lastName,
    ].where((value) => value.isNotEmpty).join(' ').trim();

    final lastMessageJson = json['lastMessage'];
    final lastMessage = lastMessageJson is Map
        ? _parseMessage(Map<String, dynamic>.from(lastMessageJson))
        : null;

    return Conversation(
      id: json['id'] as String,
      participantId: otherParticipant?['userId'] as String? ?? '',
      participantName: displayName.isNotEmpty
          ? displayName
          : (json['childName'] as String? ?? 'Conversacion'),
      participantAvatarUrl: otherParticipant?['avatarUrl'] as String?,
      participantRole: otherParticipant?['role'] as String?,
      lastMessage: lastMessage,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      lastMessageAt:
          lastMessage?.createdAt ??
          (json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'] as String)
              : null),
    );
  }

  Message _parseMessage(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String? ?? 'Usuario',
      senderAvatarUrl: json['senderAvatarUrl'] as String?,
      content: json['content'] as String? ?? '',
      attachmentUrl: json['attachmentUrl'] as String?,
      attachmentType: json['messageType'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: null,
      isRead: false,
      isDeleted: json['deletedAt'] != null,
    );
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final responseData = e.response!.data;
      final message = responseData is Map<String, dynamic>
          ? (responseData['message'] ?? 'Unknown error')
          : 'Unknown error';

      switch (statusCode) {
        case 401:
          return Exception('Unauthorized: Please login again');
        case 404:
          return Exception('Conversation not found');
        case 500:
          return Exception('Server error: $message');
        default:
          return Exception('Error: $message');
      }
    }
    return Exception('Network error: ${e.message}');
  }
}
