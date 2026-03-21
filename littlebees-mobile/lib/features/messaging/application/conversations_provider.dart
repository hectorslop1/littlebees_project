import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/message_model.dart';
import '../data/conversations_repository.dart';

final conversationsRepositoryProvider = Provider<ConversationsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ConversationsRepository(apiClient);
});

final conversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final repository = ref.watch(conversationsRepositoryProvider);
  return repository.getConversations();
});

final conversationByIdProvider = FutureProvider.family<Conversation, String>((ref, id) async {
  final repository = ref.watch(conversationsRepositoryProvider);
  return repository.getConversationById(id);
});

final messagesProvider = FutureProvider.family<List<Message>, String>((ref, conversationId) async {
  final repository = ref.watch(conversationsRepositoryProvider);
  return repository.getMessages(conversationId);
});

class ConversationsNotifier extends StateNotifier<AsyncValue<List<Conversation>>> {
  ConversationsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadConversations();
  }

  final ConversationsRepository _repository;

  Future<void> loadConversations() async {
    state = const AsyncValue.loading();
    try {
      final conversations = await _repository.getConversations();
      state = AsyncValue.data(conversations);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadConversations();
  }

  Future<Conversation> createConversation(String participantId) async {
    try {
      final conversation = await _repository.createConversation(participantId);
      
      state.whenData((conversations) {
        state = AsyncValue.data([conversation, ...conversations]);
      });
      
      return conversation;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> markAsRead(String conversationId) async {
    try {
      await _repository.markAsRead(conversationId);
      
      state.whenData((conversations) {
        final updated = conversations.map((conv) {
          if (conv.id == conversationId) {
            return conv.copyWith(unreadCount: 0);
          }
          return conv;
        }).toList();
        state = AsyncValue.data(updated);
      });
    } catch (error) {
      rethrow;
    }
  }

  void updateLastMessage(String conversationId, Message message) {
    state.whenData((conversations) {
      final updated = conversations.map((conv) {
        if (conv.id == conversationId) {
          return conv.copyWith(
            lastMessage: message,
            lastMessageAt: message.createdAt,
            unreadCount: conv.unreadCount + 1,
          );
        }
        return conv;
      }).toList();
      
      updated.sort((a, b) {
        final aTime = a.lastMessageAt ?? DateTime(2000);
        final bTime = b.lastMessageAt ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });
      
      state = AsyncValue.data(updated);
    });
  }
}

final conversationsNotifierProvider = StateNotifierProvider<ConversationsNotifier, AsyncValue<List<Conversation>>>((ref) {
  final repository = ref.watch(conversationsRepositoryProvider);
  return ConversationsNotifier(repository);
});
