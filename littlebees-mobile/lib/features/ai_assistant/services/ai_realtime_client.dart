import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../data/ai_voice_repository.dart';
import '../domain/ai_voice_models.dart';

enum AiVoiceRealtimeEventType {
  status,
  transcriptSlot,
  transcriptPartial,
  transcriptFinal,
  localLevel,
  remoteLevel,
  error,
}

class AiVoiceRealtimeEvent {
  const AiVoiceRealtimeEvent({
    required this.type,
    this.status,
    this.itemId,
    this.role,
    this.text,
    this.level,
    this.message,
  });

  final AiVoiceRealtimeEventType type;
  final AiVoiceSessionStatus? status;
  final String? itemId;
  final String? role;
  final String? text;
  final double? level;
  final String? message;
}

class AiRealtimeClient {
  AiRealtimeClient({required AiVoiceRepository repository})
    : _repository = repository;

  final AiVoiceRepository _repository;
  final StreamController<AiVoiceRealtimeEvent> _eventsController =
      StreamController<AiVoiceRealtimeEvent>.broadcast();

  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;
  MediaStream? _localStream;
  MediaStreamTrack? _localAudioTrack;
  MediaStreamTrack? _remoteAudioTrack;
  Timer? _statsTimer;
  bool _isDisposed = false;
  bool _rendererInitialized = false;
  bool _isMicRequestedEnabled = true;
  bool _isAssistantSpeaking = false;
  bool _speakerphoneRequested = true;
  bool _hasActiveUserSpeech = false;
  DateTime? _ignoreUserAudioUntil;
  double _lastLocalLevel = 0;
  double _lastRemoteLevel = 0;
  String? _activeUserItemId;
  final Set<String> _requestedResponseItemIds = <String>{};

  final RTCVideoRenderer remoteAudioRenderer = RTCVideoRenderer();

  Stream<AiVoiceRealtimeEvent> get events => _eventsController.stream;

  Future<void> connect({
    required String sessionId,
    required AiVoicePreset preset,
  }) async {
    _isDisposed = false;
    await _ensureRendererInitialized();
    await _cleanup();

    _emit(
      const AiVoiceRealtimeEvent(
        type: AiVoiceRealtimeEventType.status,
        status: AiVoiceSessionStatus.connecting,
      ),
    );

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': false,
    });
    final localTracks =
        _localStream?.getAudioTracks() ?? const <MediaStreamTrack>[];
    if (localTracks.isNotEmpty) {
      _localAudioTrack = localTracks.first;
      await _applyMicState();
    }
    await _setSpeakerphoneEnabled(true, forceRetries: true);

    _peerConnection = await createPeerConnection({
      'sdpSemantics': 'unified-plan',
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ],
    });

    final stream = _localStream;
    if (stream != null) {
      for (final track in stream.getTracks()) {
        await _peerConnection!.addTrack(track, stream);
      }
    }

    _peerConnection!.onTrack = (event) {
      if (event.track.kind == 'audio') {
        _remoteAudioTrack = event.track;
        unawaited(_setSpeakerphoneEnabled(true, forceRetries: true));
      }
      if (_rendererInitialized && event.streams.isNotEmpty) {
        remoteAudioRenderer.srcObject = event.streams.first;
      }
    };

    _peerConnection!.onConnectionState = (state) {
      if (_isDisposed) return;
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        unawaited(_setSpeakerphoneEnabled(true, forceRetries: true));
        _emit(
          const AiVoiceRealtimeEvent(
            type: AiVoiceRealtimeEventType.status,
            status: AiVoiceSessionStatus.listening,
          ),
        );
      }

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        _emit(
          const AiVoiceRealtimeEvent(
            type: AiVoiceRealtimeEventType.error,
            message: 'La conexion de voz se interrumpio.',
          ),
        );
      }
    };

    _dataChannel = await _peerConnection!.createDataChannel(
      'oai-events',
      RTCDataChannelInit()..ordered = true,
    );
    _dataChannel!.onDataChannelState = (state) {
      if (_isDisposed) return;
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        _emit(
          const AiVoiceRealtimeEvent(
            type: AiVoiceRealtimeEventType.status,
            status: AiVoiceSessionStatus.listening,
          ),
        );
      }
    };
    _dataChannel!.onMessage = (message) {
      _handleRealtimeMessage(message.text);
    };

    final offer = await _peerConnection!.createOffer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': false,
    });
    await _peerConnection!.setLocalDescription(offer);
    await _waitForIceGatheringComplete();

    final localDescription = await _peerConnection!.getLocalDescription();
    final answer = await _repository.createVoiceCall(
      sessionId: sessionId,
      sdp: localDescription?.sdp ?? offer.sdp ?? '',
      voicePresetId: preset.id,
    );

    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(answer.sdp, 'answer'),
    );
    await _setSpeakerphoneEnabled(true, forceRetries: true);

    _startStatsSampling();
  }

  Future<void> setMicEnabled(bool enabled) async {
    _isMicRequestedEnabled = enabled;
    await _applyMicState();
  }

  Future<void> close() async {
    _emit(
      const AiVoiceRealtimeEvent(
        type: AiVoiceRealtimeEventType.status,
        status: AiVoiceSessionStatus.ending,
      ),
    );
    await _cleanup();
    if (!_eventsController.isClosed) {
      _emit(
        const AiVoiceRealtimeEvent(
          type: AiVoiceRealtimeEventType.status,
          status: AiVoiceSessionStatus.ended,
        ),
      );
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await _cleanup();
    if (_rendererInitialized) {
      await remoteAudioRenderer.dispose();
      _rendererInitialized = false;
    }
    await _eventsController.close();
  }

  Future<void> _cleanup() async {
    _statsTimer?.cancel();
    _statsTimer = null;

    try {
      await _dataChannel?.close();
    } catch (_) {}
    _dataChannel = null;

    try {
      await _peerConnection?.close();
    } catch (_) {}
    _peerConnection = null;

    final tracks = _localStream?.getTracks() ?? const <MediaStreamTrack>[];
    for (final track in tracks) {
      track.stop();
    }
    await _localStream?.dispose();
    _localStream = null;
    _localAudioTrack = null;
    _remoteAudioTrack = null;
    _isAssistantSpeaking = false;
    _isMicRequestedEnabled = true;
    _speakerphoneRequested = true;
    _hasActiveUserSpeech = false;
    _ignoreUserAudioUntil = null;
    _lastLocalLevel = 0;
    _lastRemoteLevel = 0;
    _activeUserItemId = null;
    _requestedResponseItemIds.clear();
    try {
      await Helper.setSpeakerphoneOn(false);
    } catch (_) {}
    if (_rendererInitialized) {
      remoteAudioRenderer.srcObject = null;
    }
  }

  Future<void> _ensureRendererInitialized() async {
    if (_rendererInitialized) return;
    await remoteAudioRenderer.initialize();
    _rendererInitialized = true;
  }

  Future<void> _waitForIceGatheringComplete() async {
    final connection = _peerConnection;
    if (connection == null) return;
    if (connection.iceGatheringState ==
        RTCIceGatheringState.RTCIceGatheringStateComplete) {
      return;
    }

    final completer = Completer<void>();
    void Function(RTCIceGatheringState state)? listener;
    listener = (state) {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete &&
          !completer.isCompleted) {
        completer.complete();
      }
    };

    connection.onIceGatheringState = listener;
    await completer.future.timeout(
      const Duration(milliseconds: 1800),
      onTimeout: () {},
    );
  }

  void _handleRealtimeMessage(String rawMessage) {
    if (_isDisposed || rawMessage.isEmpty) return;

    dynamic decoded;
    try {
      decoded = jsonDecode(rawMessage);
    } catch (_) {
      return;
    }
    if (decoded is! Map<String, dynamic>) return;

    final type = decoded['type']?.toString() ?? '';
    switch (type) {
      case 'session.created':
      case 'session.updated':
        _emit(
          const AiVoiceRealtimeEvent(
            type: AiVoiceRealtimeEventType.status,
            status: AiVoiceSessionStatus.listening,
          ),
        );
        break;
      case 'input_audio_buffer.speech_started':
        if (!_shouldAcceptUserAudio()) {
          break;
        }
        _hasActiveUserSpeech = true;
        _activeUserItemId = null;
        _emit(
          const AiVoiceRealtimeEvent(
            type: AiVoiceRealtimeEventType.status,
            status: AiVoiceSessionStatus.listening,
          ),
        );
        break;
      case 'input_audio_buffer.speech_stopped':
        if (!_hasActiveUserSpeech || !_shouldAcceptUserAudio()) {
          break;
        }
        _emit(
          const AiVoiceRealtimeEvent(
            type: AiVoiceRealtimeEventType.status,
            status: AiVoiceSessionStatus.processing,
          ),
        );
        break;
      case 'input_audio_buffer.committed':
        if (!_hasActiveUserSpeech || !_shouldAcceptUserAudio()) {
          break;
        }
        _activeUserItemId =
            decoded['item_id']?.toString() ??
            'user-${DateTime.now().microsecondsSinceEpoch}';
        _emit(
          AiVoiceRealtimeEvent(
            type: AiVoiceRealtimeEventType.transcriptSlot,
            itemId: _activeUserItemId,
            role: 'user',
          ),
        );
        break;
      case 'response.output_audio.delta':
        _isAssistantSpeaking = true;
        unawaited(_applyMicState());
        unawaited(_setSpeakerphoneEnabled(true));
        _emit(
          const AiVoiceRealtimeEvent(
            type: AiVoiceRealtimeEventType.status,
            status: AiVoiceSessionStatus.speaking,
          ),
        );
        break;
      case 'response.created':
        _isAssistantSpeaking = true;
        _hasActiveUserSpeech = false;
        _activeUserItemId = null;
        _emit(
          const AiVoiceRealtimeEvent(
            type: AiVoiceRealtimeEventType.status,
            status: AiVoiceSessionStatus.speaking,
          ),
        );
        break;
      case 'response.output_audio.done':
        _isAssistantSpeaking = false;
        _ignoreUserAudioUntil = DateTime.now().add(
          const Duration(milliseconds: 2400),
        );
        unawaited(_restoreMicAfterSpeech());
        _emit(
          const AiVoiceRealtimeEvent(
            type: AiVoiceRealtimeEventType.status,
            status: AiVoiceSessionStatus.listening,
          ),
        );
        break;
      case 'response.done':
        break;
      case 'conversation.item.input_audio_transcription.delta':
        final itemId =
            decoded['item_id']?.toString() ??
            _activeUserItemId ??
            'user-${DateTime.now().microsecondsSinceEpoch}';
        if (!_shouldAcceptUserTranscript(itemId)) {
          break;
        }
        _emit(
          AiVoiceRealtimeEvent(
            type: AiVoiceRealtimeEventType.transcriptPartial,
            itemId: itemId,
            role: 'user',
            text: decoded['delta']?.toString() ?? '',
          ),
        );
        break;
      case 'conversation.item.input_audio_transcription.completed':
        final userItemId =
            decoded['item_id']?.toString() ??
            _activeUserItemId ??
            'user-${DateTime.now().microsecondsSinceEpoch}';
        if (!_shouldAcceptUserTranscript(userItemId)) {
          _hasActiveUserSpeech = false;
          _activeUserItemId = null;
          break;
        }
        final transcript = decoded['transcript']?.toString() ?? '';
        if (transcript.trim().isEmpty) {
          _hasActiveUserSpeech = false;
          _activeUserItemId = null;
          break;
        }
        _emit(
          AiVoiceRealtimeEvent(
            type: AiVoiceRealtimeEventType.transcriptFinal,
            itemId: userItemId,
            role: 'user',
            text: transcript,
          ),
        );
        _emit(
          const AiVoiceRealtimeEvent(
            type: AiVoiceRealtimeEventType.status,
            status: AiVoiceSessionStatus.processing,
          ),
        );
        _hasActiveUserSpeech = false;
        _activeUserItemId = null;
        _requestAssistantResponse(userItemId);
        break;
      case 'response.output_audio_transcript.delta':
        _isAssistantSpeaking = true;
        _emit(
          const AiVoiceRealtimeEvent(
            type: AiVoiceRealtimeEventType.status,
            status: AiVoiceSessionStatus.speaking,
          ),
        );
        _emit(
          AiVoiceRealtimeEvent(
            type: AiVoiceRealtimeEventType.transcriptPartial,
            itemId:
                decoded['item_id']?.toString() ??
                'assistant-${DateTime.now().microsecondsSinceEpoch}',
            role: 'assistant',
            text: decoded['delta']?.toString() ?? '',
          ),
        );
        break;
      case 'response.output_audio_transcript.done':
        _isAssistantSpeaking = true;
        _emit(
          AiVoiceRealtimeEvent(
            type: AiVoiceRealtimeEventType.transcriptFinal,
            itemId:
                decoded['item_id']?.toString() ??
                'assistant-${DateTime.now().microsecondsSinceEpoch}',
            role: 'assistant',
            text: decoded['transcript']?.toString() ?? '',
          ),
        );
        break;
      case 'error':
        _emit(
          AiVoiceRealtimeEvent(
            type: AiVoiceRealtimeEventType.error,
            message:
                decoded['error']?['message']?.toString() ??
                'Ocurrio un error en la sesion de voz.',
          ),
        );
        break;
    }
  }

  void _startStatsSampling() {
    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(const Duration(milliseconds: 120), (_) async {
      final connection = _peerConnection;
      if (connection == null || _isDisposed) return;

      try {
        if (_localAudioTrack != null) {
          final localStats = await connection.getStats(_localAudioTrack);
          _lastLocalLevel = _extractAudioLevel(localStats);
          _emit(
            AiVoiceRealtimeEvent(
              type: AiVoiceRealtimeEventType.localLevel,
              level: _lastLocalLevel,
            ),
          );
        }

        if (_remoteAudioTrack != null) {
          final remoteStats = await connection.getStats(_remoteAudioTrack);
          _lastRemoteLevel = _extractAudioLevel(remoteStats);
          _emit(
            AiVoiceRealtimeEvent(
              type: AiVoiceRealtimeEventType.remoteLevel,
              level: _lastRemoteLevel,
            ),
          );
        }
      } catch (_) {
        // Stats vary per platform; if unavailable the orb still animates by state.
      }
    });
  }

  double _extractAudioLevel(List<StatsReport> reports) {
    for (final report in reports) {
      final directLevel =
          _tryParseLevel(report.values['audioLevel']) ??
          _tryParseLevel(report.values['audio_level']) ??
          _tryParseLevel(report.values['level']);
      if (directLevel != null) {
        return directLevel.clamp(0.0, 1.0);
      }
    }

    for (final report in reports) {
      final energy = _tryParseLevel(report.values['totalAudioEnergy']);
      final duration = _tryParseLevel(report.values['totalSamplesDuration']);
      if (energy != null && duration != null && duration > 0) {
        return math.min(1, math.sqrt(energy / duration));
      }
    }

    return 0;
  }

  double? _tryParseLevel(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  void _emit(AiVoiceRealtimeEvent event) {
    if (!_eventsController.isClosed) {
      _eventsController.add(event);
    }
  }

  Future<void> _applyMicState() async {
    final track = _localAudioTrack;
    if (track == null) return;
    track.enabled = _isMicRequestedEnabled && !_isAssistantSpeaking;
  }

  Future<void> _restoreMicAfterSpeech() async {
    await Future<void>.delayed(const Duration(milliseconds: 2400));
    if (_isDisposed) return;
    await _applyMicState();
  }

  void _requestAssistantResponse(String itemId) {
    final channel = _dataChannel;
    if (channel == null) return;
    if (_requestedResponseItemIds.contains(itemId)) return;

    _requestedResponseItemIds.add(itemId);
    try {
      channel.send(
        RTCDataChannelMessage(
          jsonEncode({
            'type': 'response.create',
          }),
        ),
      );
    } catch (_) {
      _requestedResponseItemIds.remove(itemId);
      _emit(
        const AiVoiceRealtimeEvent(
          type: AiVoiceRealtimeEventType.error,
          message: 'No pudimos pedir la respuesta de Beea en esta sesion.',
        ),
      );
    }
  }

  bool _shouldIgnoreUserAudio() {
    if (_isAssistantSpeaking) {
      return true;
    }

    final ignoreUntil = _ignoreUserAudioUntil;
    if (ignoreUntil == null) {
      return false;
    }

    return DateTime.now().isBefore(ignoreUntil);
  }

  bool _shouldAcceptUserAudio() {
    if (_shouldIgnoreUserAudio()) {
      return false;
    }

    return !_isLikelyEchoInput();
  }

  bool _shouldAcceptUserTranscript(String itemId) {
    if (_shouldIgnoreUserAudio()) {
      return false;
    }

    if (_activeUserItemId != null && itemId == _activeUserItemId) {
      return true;
    }

    if (_hasActiveUserSpeech && !_isLikelyEchoInput()) {
      _activeUserItemId = itemId;
      return true;
    }

    return false;
  }

  bool _isLikelyEchoInput() {
    final remote = _lastRemoteLevel;
    final local = _lastLocalLevel;

    if (remote < 0.06) {
      return false;
    }

    return remote > (local * 1.35) && local < 0.18;
  }

  Future<void> _setSpeakerphoneEnabled(
    bool enabled, {
    bool forceRetries = false,
  }) async {
    _speakerphoneRequested = enabled;
    try {
      await Helper.setSpeakerphoneOn(enabled);
    } catch (_) {}

    if (!enabled || !forceRetries) return;

    for (final delay in const [250, 800, 1600]) {
      unawaited(
        Future<void>.delayed(Duration(milliseconds: delay), () async {
          if (_isDisposed || !_speakerphoneRequested) return;
          try {
            await Helper.setSpeakerphoneOn(true);
          } catch (_) {}
        }),
      );
    }
  }
}
