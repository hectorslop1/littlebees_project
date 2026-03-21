import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/message_model.dart';
import '../../auth/application/auth_provider.dart';
import '../data/conversations_repository.dart';
import '../domain/chat_contact.dart';

final conversationsRepositoryProvider = Provider<ConversationsRepository>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return ConversationsRepository(apiClient);
});

final conversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repository = ref.watch(conversationsRepositoryProvider);
  return repository.getConversations(currentUserId: user.id);
});

final conversationByIdProvider = FutureProvider.family<Conversation, String>((
  ref,
  id,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    throw Exception('User not authenticated');
  }
  final repository = ref.watch(conversationsRepositoryProvider);
  return repository.getConversationById(id, currentUserId: user.id);
});

final messagesProvider = FutureProvider.family<List<Message>, String>((
  ref,
  conversationId,
) async {
  final repository = ref.watch(conversationsRepositoryProvider);
  return repository.getMessages(conversationId);
});

final availableChatContactsProvider = FutureProvider<List<ChatContact>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repository = ref.watch(conversationsRepositoryProvider);
  return repository.getAvailableContacts();
});

class ConversationsNotifier
    extends StateNotifier<AsyncValue<List<Conversation>>> {
  ConversationsNotifier(this._repository, this._currentUserId)
    : super(const AsyncValue.loading()) {
    loadConversations();
  }

  final ConversationsRepository _repository;
  final String? _currentUserId;

  Future<void> loadConversations() async {
    state = const AsyncValue.loading();
    try {
      if (_currentUserId == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final conversations = await _repository.getConversations(
        currentUserId: _currentUserId,
      );
      state = AsyncValue.data(conversations);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadConversations();
  }

  Future<Conversation> createConversation({
    required String participantId,
    required String childId,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final conversation = await _repository.createConversation(
        participantId: participantId,
        childId: childId,
        currentUserId: _currentUserId,
      );

      state.whenData((conversations) {
        final withoutPrevious = conversations
            .where((item) => item.id != conversation.id)
            .toList();
        state = AsyncValue.data([conversation, ...withoutPrevious]);
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

  Future<void> deleteConversation(String conversationId) async {
    try {
      await _repository.deleteConversation(conversationId);

      state.whenData((conversations) {
        final updated = conversations
            .where((conversation) => conversation.id != conversationId)
            .toList();
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

final conversationsNotifierProvider =
    StateNotifierProvider<
      ConversationsNotifier,
      AsyncValue<List<Conversation>>
    >((ref) {
      final repository = ref.watch(conversationsRepositoryProvider);
      final user = ref.watch(currentUserProvider);
      return ConversationsNotifier(repository, user?.id);
    });
