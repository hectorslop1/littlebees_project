import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    SocketClient.getSocket().then((socket) {
      socket.off('incoming_call', handleIncomingCall);
      socket.off('call_declined', handleCallCompleted);
      socket.off('call_ended', handleCallCompleted);
    });
  });
});
