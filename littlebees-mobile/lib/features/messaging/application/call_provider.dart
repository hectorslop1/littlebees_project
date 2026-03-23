import 'dart:async';

import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../../../core/api/socket_client.dart';
import '../../auth/application/auth_provider.dart';

class IncomingCallInvitation {
  const IncomingCallInvitation({
    required this.callId,
    required this.conversationId,
    required this.callType,
    required this.fromUserId,
    required this.fromName,
    this.fromAvatarUrl,
    this.fromRole,
  });

  final String callId;
  final String conversationId;
  final String callType;
  final String fromUserId;
  final String fromName;
  final String? fromAvatarUrl;
  final String? fromRole;
}

final incomingCallProvider = StateProvider<IncomingCallInvitation?>((ref) => null);
final activeCallIdProvider = StateProvider<String?>((ref) => null);

Future<void> _startIncomingCallAlert() async {
  FlutterRingtonePlayer().play(
    android: AndroidSounds.ringtone,
    ios: const IosSound(1003),
    looping: true,
    volume: 0.8,
    asAlarm: false,
  );

  if (await Vibration.hasVibrator()) {
    Vibration.vibrate(
      pattern: [0, 700, 500, 700],
      repeat: 0,
      intensities: [180, 255],
    );
  }
}

Future<void> _stopIncomingCallAlert() async {
  FlutterRingtonePlayer().stop();
  await Vibration.cancel();
}

final callSyncProvider = Provider<void>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return;
  }

  var disposed = false;

  void handleIncomingCall(dynamic data) {
    if (data is! Map) return;
    if (ref.read(activeCallIdProvider) != null) {
      return;
    }

    final payload = Map<String, dynamic>.from(data);
    final from = Map<String, dynamic>.from(payload['from'] as Map);

    ref.read(incomingCallProvider.notifier).state = IncomingCallInvitation(
      callId: payload['callId'] as String,
      conversationId: payload['conversationId'] as String,
      callType: payload['callType'] as String,
      fromUserId: from['userId'] as String,
      fromName:
          '${from['firstName'] as String? ?? ''} ${from['lastName'] as String? ?? ''}'
              .trim(),
      fromAvatarUrl: from['avatarUrl'] as String?,
      fromRole: from['role'] as String?,
    );
    unawaited(_startIncomingCallAlert());
  }

  void handleCallCompleted(dynamic data) {
    if (data is! Map) return;

    final payload = Map<String, dynamic>.from(data);
    final callId = payload['callId'] as String?;

    if (ref.read(incomingCallProvider)?.callId == callId) {
      ref.read(incomingCallProvider.notifier).state = null;
    }

    if (ref.read(activeCallIdProvider) == callId) {
      ref.read(activeCallIdProvider.notifier).state = null;
    }

    unawaited(_stopIncomingCallAlert());
  }

  Future<void>.microtask(() async {
    final socket = await SocketClient.connect();
    if (disposed) return;

    socket.off('incoming_call', handleIncomingCall);
    socket.off('call_declined', handleCallCompleted);
    socket.off('call_ended', handleCallCompleted);

    socket.on('incoming_call', handleIncomingCall);
    socket.on('call_declined', handleCallCompleted);
    socket.on('call_ended', handleCallCompleted);
  });

  ref.onDispose(() {
    disposed = true;
    unawaited(_stopIncomingCallAlert());
    SocketClient.getSocket().then((socket) {
      socket.off('incoming_call', handleIncomingCall);
      socket.off('call_declined', handleCallCompleted);
      socket.off('call_ended', handleCallCompleted);
    });
  });
});
