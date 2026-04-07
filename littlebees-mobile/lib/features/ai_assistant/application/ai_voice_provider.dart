import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../data/ai_voice_repository.dart';
import '../domain/ai_chat_models.dart';
import '../domain/ai_voice_models.dart';
import '../services/ai_realtime_client.dart';

class AiVoiceState {
  const AiVoiceState({
    this.status = AiVoiceSessionStatus.idle,
    this.presets = aiVoicePresets,
    this.selectedPresetId = 'calida',
    this.turns = const [],
    this.error,
    this.sessionId,
    this.isMicMuted = false,
    this.localLevel = 0,
    this.remoteLevel = 0,
  });

  final AiVoiceSessionStatus status;
  final List<AiVoicePreset> presets;
  final String selectedPresetId;
  final List<AiVoiceTranscriptTurn> turns;
  final String? error;
  final String? sessionId;
  final bool isMicMuted;
  final double localLevel;
  final double remoteLevel;

  AiVoicePreset get selectedPreset =>
      presets.firstWhere((preset) => preset.id == selectedPresetId);

  String get visibleTranscript {
    final latestContent = turns.reversed
        .map((turn) => turn.content.trim())
        .firstWhere((content) => content.isNotEmpty, orElse: () => '');

    if (latestContent.isEmpty) {
      return switch (status) {
        AiVoiceSessionStatus.connecting => 'Conectando a Beea...',
        AiVoiceSessionStatus.processing => 'Beea esta pensando...',
        AiVoiceSessionStatus.speaking => 'Beea esta respondiendo...',
        AiVoiceSessionStatus.listening => 'Te escucho...',
        AiVoiceSessionStatus.error =>
          error ?? 'No pudimos iniciar el modo voz.',
        _ => 'Inicia una conversacion de voz con Beea.',
      };
    }

    return latestContent;
  }

  AiVoiceState copyWith({
    AiVoiceSessionStatus? status,
    List<AiVoicePreset>? presets,
    String? selectedPresetId,
    List<AiVoiceTranscriptTurn>? turns,
    String? error,
    bool clearError = false,
    String? sessionId,
    bool clearSessionId = false,
    bool? isMicMuted,
    double? localLevel,
    double? remoteLevel,
  }) {
    return AiVoiceState(
      status: status ?? this.status,
      presets: presets ?? this.presets,
      selectedPresetId: selectedPresetId ?? this.selectedPresetId,
      turns: turns ?? this.turns,
      error: clearError ? null : (error ?? this.error),
      sessionId: clearSessionId ? null : (sessionId ?? this.sessionId),
      isMicMuted: isMicMuted ?? this.isMicMuted,
      localLevel: localLevel ?? this.localLevel,
      remoteLevel: remoteLevel ?? this.remoteLevel,
    );
  }
}

class AiVoiceNotifier extends StateNotifier<AiVoiceState> {
  AiVoiceNotifier(this._repository, this._realtimeClient)
    : super(const AiVoiceState());

  final AiVoiceRepository _repository;
  final AiRealtimeClient _realtimeClient;

  StreamSubscription<AiVoiceRealtimeEvent>? _eventsSubscription;
  DateTime? _startedAt;

  RTCVideoRenderer get remoteAudioRenderer =>
      _realtimeClient.remoteAudioRenderer;

  String _friendlyError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 404) {
        return 'Beea voz aun no esta disponible en el servidor configurado. Falta desplegar o reiniciar el backend con las rutas nuevas de voz.';
      }
      if (statusCode == 401 || statusCode == 403) {
        return 'La sesion no tiene permisos para abrir Beea voz. Vuelve a iniciar sesion e intentalo de nuevo.';
      }
      if (statusCode != null && statusCode >= 500) {
        return 'El servidor tuvo un problema al iniciar Beea voz. Revisa la configuracion de OpenAI y reinicia el backend.';
      }
    }

    final raw = error.toString();
    if (raw.contains('Call initialize before setting the stream')) {
      return 'No pudimos preparar el audio del dispositivo para Beea voz.';
    }

    return 'No fue posible iniciar la sesion de voz.';
  }

  Future<void> start(String sessionId) async {
    await _eventsSubscription?.cancel();
    state = state.copyWith(
      status: AiVoiceSessionStatus.connecting,
      sessionId: sessionId,
      turns: const [],
      localLevel: 0,
      remoteLevel: 0,
      isMicMuted: false,
      clearError: true,
    );
    _startedAt = DateTime.now();
    _eventsSubscription = _realtimeClient.events.listen(_handleRealtimeEvent);

    try {
      await _realtimeClient.connect(
        sessionId: sessionId,
        preset: state.selectedPreset,
      );
    } catch (error) {
      state = state.copyWith(
        status: AiVoiceSessionStatus.error,
        error: _friendlyError(error),
      );
    }
  }

  Future<void> toggleMic() async {
    final nextValue = !state.isMicMuted;
    await _realtimeClient.setMicEnabled(!nextValue);
    state = state.copyWith(isMicMuted: nextValue);
  }

  void selectPreset(String presetId) {
    state = state.copyWith(selectedPresetId: presetId);
  }

  Future<AiChatSession?> end({bool persistTranscript = true}) async {
    final sessionId = state.sessionId;
    final turns = state.turns
        .where((turn) => turn.isFinal && turn.content.trim().isNotEmpty)
        .toList();
    final durationMs = _startedAt == null
        ? 0
        : DateTime.now().difference(_startedAt!).inMilliseconds;

    state = state.copyWith(status: AiVoiceSessionStatus.ending);
    await _realtimeClient.close();
    await _eventsSubscription?.cancel();
    _eventsSubscription = null;

    AiChatSession? session;
    if (persistTranscript && sessionId != null && turns.isNotEmpty) {
      try {
        session = await _repository.finalizeVoiceSession(
          sessionId: sessionId,
          turns: turns,
          voicePresetId: state.selectedPreset.id,
          durationMs: durationMs,
        );
      } catch (error) {
        state = state.copyWith(
          status: AiVoiceSessionStatus.error,
          error:
              'La voz termino, pero no se pudo guardar la transcripcion en el servidor.',
        );
        return null;
      }
    }

    state = state.copyWith(
      status: AiVoiceSessionStatus.ended,
      clearError: true,
    );
    return session;
  }

  void reset() {
    state = state.copyWith(
      status: AiVoiceSessionStatus.idle,
      turns: const [],
      localLevel: 0,
      remoteLevel: 0,
      clearError: true,
      clearSessionId: true,
      isMicMuted: false,
    );
    _startedAt = null;
  }

  void _handleRealtimeEvent(AiVoiceRealtimeEvent event) {
    switch (event.type) {
      case AiVoiceRealtimeEventType.status:
        state = state.copyWith(status: event.status, clearError: true);
        break;
      case AiVoiceRealtimeEventType.transcriptSlot:
        _ensureTranscriptTurn(
          itemId: event.itemId ?? 'user-${DateTime.now().microsecondsSinceEpoch}',
          role: event.role ?? 'user',
        );
        break;
      case AiVoiceRealtimeEventType.transcriptPartial:
        _upsertTranscript(
          itemId: event.itemId ?? 'assistant-live',
          role: event.role ?? 'assistant',
          content: event.text ?? '',
          isFinal: false,
          append: true,
        );
        break;
      case AiVoiceRealtimeEventType.transcriptFinal:
        _upsertTranscript(
          itemId:
              event.itemId ??
              '${event.role ?? 'assistant'}-${DateTime.now().microsecondsSinceEpoch}',
          role: event.role ?? 'assistant',
          content: event.text ?? '',
          isFinal: true,
        );
        break;
      case AiVoiceRealtimeEventType.localLevel:
        state = state.copyWith(localLevel: event.level ?? 0);
        break;
      case AiVoiceRealtimeEventType.remoteLevel:
        state = state.copyWith(remoteLevel: event.level ?? 0);
        break;
      case AiVoiceRealtimeEventType.error:
        state = state.copyWith(
          status: AiVoiceSessionStatus.error,
          error: event.message ?? 'Ocurrio un error en la sesion de voz.',
        );
        break;
    }
  }

  void _upsertTranscript({
    required String itemId,
    required String role,
    required String content,
    required bool isFinal,
    bool append = false,
  }) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    final updatedTurns = [...state.turns];
    final index = updatedTurns.indexWhere((turn) => turn.itemId == itemId);
    final now = DateTime.now();

    if (index >= 0) {
      final current = updatedTurns[index];
      updatedTurns[index] = current.copyWith(
        content: append ? '${current.content}$content' : trimmed,
        isFinal: isFinal || current.isFinal,
        updatedAt: now,
      );
    } else {
      updatedTurns.add(
        AiVoiceTranscriptTurn(
          itemId: itemId,
          role: role,
          content: trimmed,
          isFinal: isFinal,
          updatedAt: now,
        ),
      );
    }

    state = state.copyWith(turns: updatedTurns);
  }

  void _ensureTranscriptTurn({
    required String itemId,
    required String role,
  }) {
    final updatedTurns = [...state.turns];
    final index = updatedTurns.indexWhere((turn) => turn.itemId == itemId);
    if (index >= 0) return;

    updatedTurns.add(
      AiVoiceTranscriptTurn(
        itemId: itemId,
        role: role,
        content: '',
        isFinal: false,
        updatedAt: DateTime.now(),
      ),
    );

    state = state.copyWith(turns: updatedTurns);
  }

  @override
  void dispose() {
    unawaited(_eventsSubscription?.cancel());
    unawaited(_realtimeClient.dispose());
    super.dispose();
  }
}

final aiVoiceRepositoryProvider = Provider<AiVoiceRepository>((ref) {
  return AiVoiceRepository();
});

final aiRealtimeClientProvider = Provider<AiRealtimeClient>((ref) {
  final repository = ref.watch(aiVoiceRepositoryProvider);
  return AiRealtimeClient(repository: repository);
});

final aiVoiceProvider = StateNotifierProvider<AiVoiceNotifier, AiVoiceState>((
  ref,
) {
  final repository = ref.watch(aiVoiceRepositoryProvider);
  final client = ref.watch(aiRealtimeClientProvider);
  return AiVoiceNotifier(repository, client);
});
