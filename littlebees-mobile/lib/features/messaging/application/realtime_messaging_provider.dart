import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/socket_client.dart';
import '../../../shared/models/message_model.dart';

final socketConnectionProvider = StreamProvider<bool>((ref) {
  return SocketClient.connectionStream;
});

class RealtimeMessagingNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  RealtimeMessagingNotifier(this.conversationId) : super(const AsyncValue.loading()) {
    _initialize();
  }

  final String conversationId;
  StreamSubscription? _messageSubscription;

  Future<void> _initialize() async {
    try {
      final socket = await SocketClient.connect();
      
      socket.emit('join_conversation', {'conversationId': conversationId});
      
      socket.on('message:new', (data) {
        final message = Message.fromJson(data as Map<String, dynamic>);
        state.whenData((messages) {
          state = AsyncValue.data([...messages, message]);
        });
      });

      socket.on('message:updated', (data) {
        final updatedMessage = Message.fromJson(data as Map<String, dynamic>);
        state.whenData((messages) {
          final updatedList = messages.map((msg) {
            return msg.id == updatedMessage.id ? updatedMessage : msg;
          }).toList();
          state = AsyncValue.data(updatedList);
        });
      });

      socket.on('message:deleted', (data) {
        final messageId = data['messageId'] as String;
        state.whenData((messages) {
          final filteredList = messages.where((msg) => msg.id != messageId).toList();
          state = AsyncValue.data(filteredList);
        });
      });

      socket.on('typing:start', (data) {
      });

      socket.on('typing:stop', (data) {
      });

    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> sendMessage(String content, {String? attachmentUrl}) async {
    try {
      final socket = await SocketClient.getSocket();
      
      socket.emit('message:send', {
        'conversationId': conversationId,
        'content': content,
        'attachmentUrl': attachmentUrl,
      });

    } catch (error) {
      rethrow;
    }
  }

  void startTyping() {
    SocketClient.getSocket().then((socket) {
      socket.emit('typing:start', {'conversationId': conversationId});
    });
  }

  void stopTyping() {
    SocketClient.getSocket().then((socket) {
      socket.emit('typing:stop', {'conversationId': conversationId});
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    SocketClient.getSocket().then((socket) {
      socket.emit('leave_conversation', {'conversationId': conversationId});
    });
    super.dispose();
  }
}

final realtimeMessagingProvider = StateNotifierProvider.family<
    RealtimeMessagingNotifier,
    AsyncValue<List<Message>>,
    String>((ref, conversationId) {
  return RealtimeMessagingNotifier(conversationId);
});

final typingStatusProvider = StreamProvider.family<Map<String, bool>, String>((ref, conversationId) {
  final controller = StreamController<Map<String, bool>>();
  final typingUsers = <String, bool>{};

  SocketClient.getSocket().then((socket) {
    socket.on('typing:start', (data) {
      final userId = data['userId'] as String;
      typingUsers[userId] = true;
      controller.add(Map.from(typingUsers));
    });

    socket.on('typing:stop', (data) {
      final userId = data['userId'] as String;
      typingUsers.remove(userId);
      controller.add(Map.from(typingUsers));
    });
  });

  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
});
