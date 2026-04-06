import '../domain/ai_chat_models.dart';
import '../domain/ai_voice_models.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';

class AiVoiceRepository {
  AiVoiceRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  Future<AiVoiceCallResponse> createVoiceCall({
    required String sessionId,
    required String sdp,
    required String voicePresetId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Endpoints.aiVoiceCall(sessionId),
      data: {'sdp': sdp, 'voicePresetId': voicePresetId},
    );
    return AiVoiceCallResponse.fromJson(response);
  }

  Future<AiChatSession> finalizeVoiceSession({
    required String sessionId,
    required List<AiVoiceTranscriptTurn> turns,
    required String voicePresetId,
    required int durationMs,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Endpoints.aiVoiceFinalize(sessionId),
      data: {
        'turns': turns
            .where((turn) => turn.isFinal && turn.content.trim().isNotEmpty)
            .map((turn) => {'role': turn.role, 'content': turn.content.trim()})
            .toList(),
        'voicePresetId': voicePresetId,
        'durationMs': durationMs,
      },
    );
    return AiChatSession.fromJson(response);
  }
}
