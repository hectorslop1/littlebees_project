import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../shared/enums/enums.dart';
import '../../auth/application/auth_provider.dart';
import '../data/ai_assistant_repository.dart';
import '../domain/ai_chat_models.dart';

class AiAssistantState {
  const AiAssistantState({
    this.sessions = const [],
    this.messages = const [],
    this.activeSessionId,
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  final List<AiChatSession> sessions;
  final List<AiChatMessage> messages;
  final String? activeSessionId;
  final bool isLoading;
  final bool isSending;
  final String? error;

  AiChatSession? get activeSession =>
      sessions.cast<AiChatSession?>().firstWhere(
        (session) => session?.id == activeSessionId,
        orElse: () => null,
      );

  AiAssistantState copyWith({
    List<AiChatSession>? sessions,
    List<AiChatMessage>? messages,
    String? activeSessionId,
    bool clearActiveSessionId = false,
    bool? isLoading,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) {
    return AiAssistantState(
      sessions: sessions ?? this.sessions,
      messages: messages ?? this.messages,
      activeSessionId: clearActiveSessionId
          ? null
          : (activeSessionId ?? this.activeSessionId),
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AiAssistantNotifier extends StateNotifier<AiAssistantState> {
  AiAssistantNotifier(this._repository)
    : super(const AiAssistantState(isLoading: true)) {
    loadInitialState();
  }

  final AiAssistantRepository _repository;

  String _friendlyError(Object error, {required String fallback}) {
    final raw = error.toString();
    if (raw.contains('invalid_api_key') || raw.contains('Invalid API Key')) {
      return 'Beea no esta disponible en este momento porque la configuracion de IA del servidor necesita actualizarse.';
    }

    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString() ?? '';
        if (message.contains('invalid_api_key') ||
            message.contains('Invalid API Key')) {
          return 'Beea no esta disponible en este momento porque la configuracion de IA del servidor necesita actualizarse.';
        }
      }
    }

    return fallback;
  }

  Future<void> loadInitialState() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final sessions = await _repository.getSessions();
      if (sessions.isEmpty) {
        state = const AiAssistantState(isLoading: false);
        return;
      }
      state = AiAssistantState(sessions: sessions, isLoading: false);
    } catch (error) {
      state = AiAssistantState(
        isLoading: false,
        error: _friendlyError(
          error,
          fallback: 'No fue posible cargar el asistente',
        ),
      );
    }
  }

  Future<void> selectSession(String sessionId) async {
    if (state.activeSessionId == sessionId) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _repository.getSession(sessionId);
      state = state.copyWith(
        activeSessionId: sessionId,
        messages: session.messages,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'No fue posible abrir la conversación',
      );
    }
  }

  Future<void> reloadSession(String sessionId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _repository.getSession(sessionId);
      final sessions = [...state.sessions];
      final idx = sessions.indexWhere((item) => item.id == session.id);
      if (idx >= 0) {
        sessions[idx] = session;
      } else {
        sessions.insert(0, session);
      }

      state = state.copyWith(
        sessions: sessions,
        activeSessionId: sessionId,
        messages: session.messages,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'No fue posible actualizar la conversación',
      );
    }
  }

  Future<void> startSession({String? title}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _repository.createSession(title: title);
      state = state.copyWith(
        sessions: [session, ...state.sessions],
        activeSessionId: session.id,
        messages: const [],
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _friendlyError(
          error,
          fallback: 'No fue posible iniciar una conversación nueva',
        ),
      );
    }
  }

  Future<void> deleteSession(String sessionId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.deleteSession(sessionId);
      final remaining = state.sessions
          .where((item) => item.id != sessionId)
          .toList();
      state = AiAssistantState(
        sessions: remaining,
        activeSessionId: state.activeSessionId == sessionId
            ? null
            : state.activeSessionId,
        messages: state.activeSessionId == sessionId
            ? const []
            : state.messages,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'No fue posible eliminar la conversación',
      );
    }
  }

  Future<void> sendMessage(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;

    var sessionId = state.activeSessionId;
    if (sessionId == null) {
      await startSession(
        title: trimmed.length > 36 ? '${trimmed.substring(0, 36)}...' : trimmed,
      );
      sessionId = state.activeSessionId;
    }

    if (sessionId == null) return;

    final optimistic = AiChatMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      role: 'user',
      content: trimmed,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      isSending: true,
      clearError: true,
      messages: [...state.messages, optimistic],
    );

    try {
      final assistantReply = await _repository.sendMessage(
        sessionId: sessionId,
        message: trimmed,
      );
      final session = await _repository.getSession(sessionId);
      final sessions = [...state.sessions];
      final idx = sessions.indexWhere((item) => item.id == session.id);
      if (idx >= 0) {
        sessions[idx] = session;
      } else {
        sessions.insert(0, session);
      }

      state = state.copyWith(
        sessions: sessions,
        messages: [
          ...session.messages.where((item) => item.role != 'system'),
          if (!session.messages.any((item) => item.id == assistantReply.id))
            assistantReply,
        ],
        isSending: false,
      );
    } catch (error) {
      state = state.copyWith(
        isSending: false,
        error: _friendlyError(
          error,
          fallback: 'No fue posible obtener respuesta del asistente',
        ),
        messages: state.messages
            .where((item) => item.id != optimistic.id)
            .toList(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearActiveSession() {
    state = state.copyWith(
      clearActiveSessionId: true,
      messages: const [],
      clearError: true,
    );
  }
}

final aiAssistantRepositoryProvider = Provider<AiAssistantRepository>((ref) {
  return AiAssistantRepository();
});

final aiAssistantProvider =
    StateNotifierProvider<AiAssistantNotifier, AiAssistantState>((ref) {
      final repository = ref.watch(aiAssistantRepositoryProvider);
      return AiAssistantNotifier(repository);
    });

final aiAssistantWelcomeProvider = Provider<String>((ref) {
  final role = ref.watch(authProvider).role;
  switch (role) {
    case UserRole.parent:
      return 'Puedo ayudarte a entender el día de tu hijo, su progreso y recomendaciones educativas.';
    case UserRole.teacher:
      return 'Puedo apoyarte con actividades, resúmenes del aula y orientación pedagógica usando solo datos permitidos.';
    case UserRole.director:
    case UserRole.admin:
    case UserRole.superAdmin:
      return 'Puedo resumir operación escolar, pagos, justificantes y pendientes usando contexto real del sistema.';
    default:
      return 'Pregúntame lo que necesites sobre LittleBees.';
  }
});

final aiAssistantPromptHintProvider = Provider<String>((ref) {
  final role = ref.watch(authProvider).role;
  switch (role) {
    case UserRole.parent:
      return 'Pregunta sobre tu hijo, su día o recomendaciones en casa...';
    case UserRole.teacher:
      return 'Pregunta sobre tu grupo, actividades o apoyo pedagógico...';
    case UserRole.director:
    case UserRole.admin:
    case UserRole.superAdmin:
      return 'Pregunta sobre operación escolar, pagos o reportes...';
    default:
      return 'Escribe tu pregunta...';
  }
});
