import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/api/socket_client.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_avatar.dart';
import '../../auth/application/auth_provider.dart';
import '../application/call_provider.dart';

class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
    this.participantAvatarUrl,
    this.participantRole,
    required this.callType,
    required this.isOutgoing,
    this.callId,
  });

  final String conversationId;
  final String participantName;
  final String? participantAvatarUrl;
  final String? participantRole;
  final String callType;
  final bool isOutgoing;
  final String? callId;

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCPeerConnection? _peerConnection;
  Timer? _durationTimer;

  String? _callId;
  String _status = 'Conectando...';
  Duration _duration = Duration.zero;
  bool _micEnabled = true;
  bool _cameraEnabled = true;
  bool _frontCamera = true;
  bool _isEnding = false;
  bool _offerSent = false;
  bool _connected = false;
  bool _didCleanup = false;

  void Function(dynamic)? _callStartedHandler;
  void Function(dynamic)? _callAcceptedHandler;
  void Function(dynamic)? _callDeclinedHandler;
  void Function(dynamic)? _callEndedHandler;
  void Function(dynamic)? _offerHandler;
  void Function(dynamic)? _answerHandler;
  void Function(dynamic)? _iceCandidateHandler;

  bool get _isVideo => widget.callType == 'video';

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    _callId = widget.callId;

    if (_callId != null) {
      ref.read(activeCallIdProvider.notifier).state = _callId;
    }

    await _prepareLocalMedia();
    final socket = await SocketClient.connect();
    _registerSocketHandlers(socket);

    if (!mounted) return;

    if (widget.isOutgoing) {
      socket.emit('start_call', {
        'conversationId': widget.conversationId,
        'callType': widget.callType,
      });
      setState(() {
        _status = _isVideo ? 'Llamando por video...' : 'Llamando...';
      });
    } else {
      ref.read(incomingCallProvider.notifier).state = null;
      socket.emit('accept_call', {'callId': _callId});
      setState(() {
        _status = 'Conectando llamada...';
      });
    }
  }

  Future<void> _prepareLocalMedia() async {
    final mediaConstraints = {
      'audio': true,
      'video': _isVideo
          ? {
              'facingMode': 'user',
              'width': 1280,
              'height': 720,
              'frameRate': 30,
            }
          : false,
    };

    final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localStream = stream;
    _localRenderer.srcObject = stream;
    if (mounted) {
      setState(() {});
    }
  }

  Future<RTCPeerConnection> _ensurePeerConnection() async {
    if (_peerConnection != null) {
      return _peerConnection!;
    }

    final peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ],
      'sdpSemantics': 'unified-plan',
    });

    final stream = _localStream;
    if (stream != null) {
      for (final track in stream.getTracks()) {
        await peerConnection.addTrack(track, stream);
      }
    }

    peerConnection.onTrack = (event) {
      if (event.streams.isEmpty) return;
      _remoteStream = event.streams.first;
      _remoteRenderer.srcObject = _remoteStream;

      if (!_connected && mounted) {
        setState(() {
          _connected = true;
          _status = 'En llamada';
        });
        _startDuration();
      }
    };

    peerConnection.onIceCandidate = (candidate) {
      if (_callId == null || candidate.candidate == null) return;

      SocketClient.getSocket().then((socket) {
        socket.emit('webrtc_ice_candidate', {
          'callId': _callId,
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        });
      });
    };

    peerConnection.onConnectionState = (state) {
      if (!mounted) return;

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected &&
          !_connected) {
        setState(() {
          _connected = true;
          _status = 'En llamada';
        });
        _startDuration();
      }

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        _handleRemoteEnd();
      }
    };

    _peerConnection = peerConnection;
    return peerConnection;
  }

  void _registerSocketHandlers(dynamic socket) {
    _callStartedHandler = (data) {
      if (!widget.isOutgoing || data is! Map) return;

      final payload = Map<String, dynamic>.from(data);
      if (payload['conversationId'] != widget.conversationId) return;

      final callId = payload['callId'] as String?;
      if (callId == null) return;

      _callId = callId;
      ref.read(activeCallIdProvider.notifier).state = callId;
      if (mounted) {
        setState(() {
          _status = 'Esperando respuesta...';
        });
      }
    };

    _callAcceptedHandler = (data) async {
      if (data is! Map) return;

      final payload = Map<String, dynamic>.from(data);
      if (payload['callId'] != _callId) return;

      if (!widget.isOutgoing) {
        return;
      }

      if (_offerSent) return;
      _offerSent = true;

      final peerConnection = await _ensurePeerConnection();
      final offer = await peerConnection.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': _isVideo,
      });
      await peerConnection.setLocalDescription(offer);

      socket.emit('webrtc_offer', {
        'callId': _callId,
        'sdp': {
          'type': offer.type,
          'sdp': offer.sdp,
        },
      });

      if (mounted) {
        setState(() {
          _status = 'Conectando...';
        });
      }
    };

    _offerHandler = (data) async {
      if (data is! Map) return;

      final payload = Map<String, dynamic>.from(data);
      if (payload['callId'] != _callId || widget.isOutgoing) return;

      final sdp = Map<String, dynamic>.from(payload['sdp'] as Map);
      final peerConnection = await _ensurePeerConnection();
      await peerConnection.setRemoteDescription(
        RTCSessionDescription(
          sdp['sdp'] as String,
          sdp['type'] as String,
        ),
      );

      final answer = await peerConnection.createAnswer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': _isVideo,
      });
      await peerConnection.setLocalDescription(answer);

      socket.emit('webrtc_answer', {
        'callId': _callId,
        'sdp': {
          'type': answer.type,
          'sdp': answer.sdp,
        },
      });

      if (mounted) {
        setState(() {
          _status = 'Conectando...';
        });
      }
    };

    _answerHandler = (data) async {
      if (data is! Map) return;

      final payload = Map<String, dynamic>.from(data);
      if (payload['callId'] != _callId) return;

      final sdp = Map<String, dynamic>.from(payload['sdp'] as Map);
      final peerConnection = await _ensurePeerConnection();
      await peerConnection.setRemoteDescription(
        RTCSessionDescription(
          sdp['sdp'] as String,
          sdp['type'] as String,
        ),
      );
    };

    _iceCandidateHandler = (data) async {
      if (data is! Map) return;

      final payload = Map<String, dynamic>.from(data);
      if (payload['callId'] != _callId) return;

      final candidate = Map<String, dynamic>.from(payload['candidate'] as Map);
      final peerConnection = await _ensurePeerConnection();
      await peerConnection.addCandidate(
        RTCIceCandidate(
          candidate['candidate'] as String?,
          candidate['sdpMid'] as String?,
          candidate['sdpMLineIndex'] as int?,
        ),
      );
    };

    _callDeclinedHandler = (data) {
      if (data is! Map) return;

      final payload = Map<String, dynamic>.from(data);
      if (payload['callId'] != _callId) return;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La llamada fue rechazada')),
      );
      _handleRemoteEnd(popAfterCleanup: true);
    };

    _callEndedHandler = (data) {
      if (data is! Map) return;

      final payload = Map<String, dynamic>.from(data);
      if (payload['callId'] != _callId) return;
      _handleRemoteEnd(popAfterCleanup: true);
    };

    socket.on('call_started', _callStartedHandler!);
    socket.on('call_accepted', _callAcceptedHandler!);
    socket.on('call_declined', _callDeclinedHandler!);
    socket.on('call_ended', _callEndedHandler!);
    socket.on('webrtc_offer', _offerHandler!);
    socket.on('webrtc_answer', _answerHandler!);
    socket.on('webrtc_ice_candidate', _iceCandidateHandler!);
  }

  void _startDuration() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _duration += const Duration(seconds: 1);
      });
    });
  }

  Future<void> _toggleMic() async {
    final stream = _localStream;
    if (stream == null) return;

    for (final track in stream.getAudioTracks()) {
      track.enabled = !_micEnabled;
    }

    setState(() {
      _micEnabled = !_micEnabled;
    });
  }

  Future<void> _toggleCamera() async {
    if (!_isVideo) return;

    final stream = _localStream;
    if (stream == null) return;

    for (final track in stream.getVideoTracks()) {
      track.enabled = !_cameraEnabled;
    }

    setState(() {
      _cameraEnabled = !_cameraEnabled;
    });
  }

  Future<void> _switchCamera() async {
    if (!_isVideo) return;

    final stream = _localStream;
    if (stream == null) return;

    final videoTracks = stream.getVideoTracks();
    if (videoTracks.isEmpty) return;

    await Helper.switchCamera(videoTracks.first);
    setState(() {
      _frontCamera = !_frontCamera;
    });
  }

  Future<void> _endCall() async {
    if (_isEnding) return;
    _isEnding = true;

    if (_callId != null) {
      final socket = await SocketClient.getSocket();
      socket.emit('end_call', {'callId': _callId});
    }

    await _cleanup();
    if (mounted) {
      context.pop();
    }
  }

  Future<void> _handleRemoteEnd({bool popAfterCleanup = false}) async {
    if (_isEnding) return;
    _isEnding = true;
    await _cleanup();
    if (mounted && popAfterCleanup) {
      context.pop();
    }
  }

  Future<void> _cleanup() async {
    if (_didCleanup) return;
    _didCleanup = true;

    _durationTimer?.cancel();
    _durationTimer = null;

    ref.read(incomingCallProvider.notifier).state = null;
    ref.read(activeCallIdProvider.notifier).state = null;

    final socket = await SocketClient.getSocket();
    if (_callStartedHandler != null) {
      socket.off('call_started', _callStartedHandler);
    }
    if (_callAcceptedHandler != null) {
      socket.off('call_accepted', _callAcceptedHandler);
    }
    if (_callDeclinedHandler != null) {
      socket.off('call_declined', _callDeclinedHandler);
    }
    if (_callEndedHandler != null) {
      socket.off('call_ended', _callEndedHandler);
    }
    if (_offerHandler != null) {
      socket.off('webrtc_offer', _offerHandler);
    }
    if (_answerHandler != null) {
      socket.off('webrtc_answer', _answerHandler);
    }
    if (_iceCandidateHandler != null) {
      socket.off('webrtc_ice_candidate', _iceCandidateHandler);
    }

    await _peerConnection?.close();
    _peerConnection = null;

    await _localRenderer.dispose();
    await _remoteRenderer.dispose();

    final localStream = _localStream;
    if (localStream != null) {
      for (final track in localStream.getTracks()) {
        track.stop();
      }
      await localStream.dispose();
    }

    final remoteStream = _remoteStream;
    if (remoteStream != null) {
      for (final track in remoteStream.getTracks()) {
        track.stop();
      }
      await remoteStream.dispose();
    }
  }

  @override
  void dispose() {
    unawaited(_cleanup());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final title = _isVideo ? 'Videollamada' : 'Llamada';

    return Scaffold(
      backgroundColor: const Color(0xFF101214),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: _isVideo && _remoteStream != null
                  ? RTCVideoView(
                      _remoteRenderer,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    )
                  : _CallBackdrop(
                      participantName: widget.participantName,
                      participantAvatarUrl: widget.participantAvatarUrl,
                      participantRole: widget.participantRole,
                      isVideo: _isVideo,
                    ),
            ),
            Positioned(
              left: 24,
              right: 24,
              top: 18,
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.participantName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _connected
                        ? _formatDuration(_duration)
                        : _status,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (_isVideo && _localStream != null)
              Positioned(
                right: 20,
                top: 120,
                child: Container(
                  width: 110,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: RTCVideoView(
                    _localRenderer,
                    mirror: _frontCamera,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Column(
                children: [
                  if (currentUser != null && widget.participantRole != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Text(
                        '${currentUser.firstName} con ${widget.participantRole}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CallControlButton(
                        icon: _micEnabled ? LucideIcons.mic : LucideIcons.micOff,
                        label: _micEnabled ? 'Microfono' : 'Silenciado',
                        onTap: _toggleMic,
                      ),
                      const SizedBox(width: 16),
                      if (_isVideo) ...[
                        _CallControlButton(
                          icon: _cameraEnabled
                              ? LucideIcons.video
                              : LucideIcons.videoOff,
                          label: _cameraEnabled ? 'Camara' : 'Camara off',
                          onTap: _toggleCamera,
                        ),
                        const SizedBox(width: 16),
                        _CallControlButton(
                          icon: LucideIcons.refreshCcw,
                          label: 'Cambiar',
                          onTap: _switchCamera,
                        ),
                        const SizedBox(width: 16),
                      ],
                      _CallControlButton(
                        icon: LucideIcons.phoneOff,
                        label: 'Colgar',
                        backgroundColor: AppColors.error,
                        iconColor: Colors.white,
                        onTap: _endCall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

class _CallBackdrop extends StatelessWidget {
  const _CallBackdrop({
    required this.participantName,
    this.participantAvatarUrl,
    this.participantRole,
    required this.isVideo,
  });

  final String participantName;
  final String? participantAvatarUrl;
  final String? participantRole;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF18212A),
            Color(0xFF101214),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LBAvatar(
              placeholder: participantName.isNotEmpty ? participantName[0] : 'U',
              imageUrl: participantAvatarUrl,
              size: LBAvatarSize.large,
            ),
            const SizedBox(height: 18),
            Text(
              participantName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (participantRole != null && participantRole!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                participantRole!,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (!isVideo) ...[
              const SizedBox(height: 22),
              const Icon(
                LucideIcons.phoneCall,
                color: Colors.white30,
                size: 28,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CallControlButton extends StatelessWidget {
  const _CallControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor = const Color(0x1FFFFFFF),
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: backgroundColor,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 64,
              height: 64,
              child: Icon(icon, color: iconColor, size: 24),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
