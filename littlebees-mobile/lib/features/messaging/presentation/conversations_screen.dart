import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/widgets/lb_avatar.dart';
import '../../../../design_system/widgets/lb_card.dart';
import '../../../../core/i18n/app_translations.dart';
import '../../../../design_system/widgets/lb_empty_state.dart';
import '../application/messaging_providers.dart';
import 'package:intl/intl.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(tr.tr('messages'))),
      body: SafeArea(
        child: conversationsAsync.when(
          data: (conversations) {
            if (conversations.isEmpty) {
              return LBEmptyState(
                icon: LucideIcons.messageSquare,
                title: 'No Messages Yet',
                message: 'Your conversations with caregivers will appear here.',
              );
            }

            return RefreshIndicator(
              onRefresh: () => ref.refresh(conversationsProvider.future),
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  return _buildConversationItem(context, conversation, index);
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error loading conversations: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(conversationsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationItem(BuildContext context, conversation, int index) {
    final otherParticipant = conversation.participants.isNotEmpty
        ? conversation.participants.first
        : null;
    final participantName = otherParticipant != null
        ? '${otherParticipant.firstName} ${otherParticipant.lastName}'
        : 'Unknown';
    final lastMessage = conversation.lastMessage;
    final unreadCount = conversation.unreadCount ?? 0;
    return GestureDetector(
          onTap: () => context.push('/messages/${conversation.id}'),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: LBCard(
              child: Row(
                children: [
                  LBAvatar(
                    placeholder:
                        otherParticipant?.firstName.substring(0, 1) ?? 'U',
                    imageUrl: otherParticipant?.avatarUrl,
                    showStatusDot: true,
                    statusColor: AppColors.success,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              participantName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (lastMessage != null)
                              Text(
                                _formatTime(lastMessage.createdAt),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: unreadCount > 0
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                      fontWeight: unreadCount > 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                lastMessage?.content ?? 'No messages yet',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: unreadCount > 0
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary,
                                      fontWeight: unreadCount > 0
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (index * 50).ms, duration: 300.ms)
        .slideY(begin: 0.1);
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(dateTime);
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}
