import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/socket_client.dart';
import '../../../shared/models/message_model.dart';
import '../data/conversations_repository.dart';
import 'conversations_provider.dart';

final socketConnectionProvider = StreamProvider<bool>((ref) {
  return SocketClient.connectionStream;
});

class RealtimeMessagingNotifier
    extends StateNotifier<AsyncValue<List<Message>>> {
  RealtimeMessagingNotifier(this.conversationId, this._repository)
    : super(const AsyncValue.loading()) {
    _initialize();
  }

  final String conversationId;
  final ConversationsRepository _repository;
  StreamSubscription? _messageSubscription;
  void Function(dynamic)? _newMessageHandler;
  void Function(dynamic)? _typingHandler;
  void Function(dynamic)? _stopTypingHandler;

  Future<void> _initialize() async {
    try {
      final initialMessages = await _repository.getMessages(conversationId);
      state = AsyncValue.data(initialMessages);

      final socket = await SocketClient.connect();
      socket.emit('join_conversation', {'conversationId': conversationId});
      socket.emit('mark_read', {'conversationId': conversationId});

      _newMessageHandler = (data) {
        final payload = Map<String, dynamic>.from(data as Map);
        final message = Message.fromJson(payload);
        if (message.conversationId != conversationId) return;

        state.whenData((messages) {
          final alreadyExists = messages.any(
            (existing) => existing.id == message.id,
          );
          if (alreadyExists) return;
          state = AsyncValue.data([...messages, message]);
        });
      };

      _typingHandler = (_) {};
      _stopTypingHandler = (_) {};

      socket.off('new_message', _newMessageHandler);
      socket.off('user_typing', _typingHandler);
      socket.off('user_stop_typing', _stopTypingHandler);

      socket.on('new_message', _newMessageHandler!);
      socket.on('user_typing', _typingHandler!);
      socket.on('user_stop_typing', _stopTypingHandler!);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> sendMessage(String content, {String? attachmentUrl}) async {
    try {
      final socket = await SocketClient.getSocket();
      socket.emit('send_message', {
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
      socket.emit('typing_start', {'conversationId': conversationId});
    });
  }

  void stopTyping() {
    SocketClient.getSocket().then((socket) {
      socket.emit('typing_stop', {'conversationId': conversationId});
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    SocketClient.getSocket().then((socket) {
      socket.emit('leave_conversation', {'conversationId': conversationId});
      if (_newMessageHandler != null) {
        socket.off('new_message', _newMessageHandler);
      }
      if (_typingHandler != null) {
        socket.off('user_typing', _typingHandler);
      }
      if (_stopTypingHandler != null) {
        socket.off('user_stop_typing', _stopTypingHandler);
      }
    });
    super.dispose();
  }
}

final realtimeMessagingProvider =
    StateNotifierProvider.family<
      RealtimeMessagingNotifier,
      AsyncValue<List<Message>>,
      String
    >((ref, conversationId) {
      final repository = ref.watch(conversationsRepositoryProvider);
      return RealtimeMessagingNotifier(conversationId, repository);
    });

final typingStatusProvider = StreamProvider.family<Map<String, bool>, String>((
  ref,
  conversationId,
) {
  final controller = StreamController<Map<String, bool>>();
  final typingUsers = <String, bool>{};

  SocketClient.getSocket().then((socket) {
    socket.off('user_typing');
    socket.off('user_stop_typing');

    socket.on('user_typing', (data) {
      final payload = Map<String, dynamic>.from(data as Map);
      if (payload['conversationId'] != conversationId) return;

      final userId = payload['userId'] as String;
      typingUsers[userId] = true;
      controller.add(Map.from(typingUsers));
    });

    socket.on('user_stop_typing', (data) {
      final payload = Map<String, dynamic>.from(data as Map);
      if (payload['conversationId'] != conversationId) return;

      final userId = payload['userId'] as String;
      typingUsers.remove(userId);
      controller.add(Map.from(typingUsers));
    });
  });

  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
});
