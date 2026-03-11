import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/conversation_model.dart';
import '../../../shared/repositories/conversations_repository.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../auth/application/auth_provider.dart';

final conversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final user = ref.watch(currentUserProvider);
  
  if (user == null) {
    throw Exception('User not authenticated');
  }

  final repository = ref.watch(conversationsRepositoryProvider);
  
  // Backend API automatically filters conversations based on user role:
  // - Parents see conversations related to their children
  // - Teachers see conversations for their assigned classrooms
  return await repository.getMyConversations();
});

final messagesProvider = FutureProvider.family<List<Message>, String>((
  ref,
  conversationId,
) async {
  final repository = ref.watch(conversationsRepositoryProvider);
  return await repository.getMessages(conversationId);
});

final sendMessageProvider = Provider<ConversationsRepository>((ref) {
  return ref.watch(conversationsRepositoryProvider);
});
