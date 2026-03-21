import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/message_model.dart';

class ConversationsRepository {
  final ApiClient _apiClient;

  ConversationsRepository(this._apiClient);

  Future<List<Conversation>> getConversations() async {
    try {
      final response = await _apiClient.get('/conversations');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Conversation.fromJson(json)).toList();
    } on DioException catch (e) {
      // If endpoint doesn't exist or returns error, return empty list
      // This prevents the app from crashing when conversations endpoint is not implemented
      if (e.response?.statusCode == 404 || e.response?.statusCode == 500) {
        return [];
      }
      throw _handleError(e);
    } catch (e) {
      // For any other error, return empty list to prevent crashes
      return [];
    }
  }

  Future<Conversation> getConversationById(String id) async {
    try {
      final response = await _apiClient.get('/conversations/$id');
      return Conversation.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Message>> getMessages(
    String conversationId, {
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final response = await _apiClient.get(
        '/conversations/$conversationId/messages',
        queryParameters: {'page': page, 'perPage': perPage},
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Message.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Conversation> createConversation(String participantId) async {
    try {
      final response = await _apiClient.post(
        '/conversations',
        data: {'participantId': participantId},
      );
      return Conversation.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markAsRead(String conversationId) async {
    try {
      await _apiClient.post('/conversations/$conversationId/read');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final message = e.response!.data['message'] ?? 'Unknown error';

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
