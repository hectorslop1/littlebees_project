import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../domain/ai_chat_models.dart';

class AiAssistantRepository {
  AiAssistantRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  Future<List<AiChatSession>> getSessions() async {
    final response = await _apiClient.get<List<dynamic>>(Endpoints.aiSessions);
    return response
        .map(
          (item) =>
              AiChatSession.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<AiChatSession> createSession({String? title}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Endpoints.aiSessions,
      data: {
        if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
      },
    );
    return AiChatSession.fromJson(response);
  }

  Future<AiChatSession> getSession(String sessionId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Endpoints.aiSession(sessionId),
    );
    return AiChatSession.fromJson(response);
  }

  Future<void> deleteSession(String sessionId) async {
    await _apiClient.delete<dynamic>(Endpoints.aiSession(sessionId));
  }

  Future<AiChatMessage> sendMessage({
    required String sessionId,
    required String message,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Endpoints.aiChat(sessionId),
      data: {'message': message},
    );
    final rawMessage = Map<String, dynamic>.from(response['message'] as Map);
    return AiChatMessage.fromJson(rawMessage);
  }
}
