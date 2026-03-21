import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_avatar.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../design_system/widgets/lb_empty_state.dart';
import '../../../design_system/widgets/lb_error_state.dart';
import '../application/conversations_provider.dart';
import 'package:intl/intl.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final conversationsAsync = ref.watch(conversationsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.tr('messages')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(LucideIcons.messageSquarePlus),
              onPressed: () => context.push('/messages/new'),
              tooltip: 'Nueva conversación',
              iconSize: 24,
            ),
          ),
        ],
      ),
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
              onRefresh: () async {
                await ref
                    .read(conversationsNotifierProvider.notifier)
                    .refresh();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  return _buildConversationItem(
                    context,
                    ref,
                    conversation,
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => LBErrorState(
            title: tr.tr('errorLoadingData'),
            message: error.toString(),
            onRetry: () =>
                ref.read(conversationsNotifierProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationItem(
    BuildContext context,
    WidgetRef ref,
    conversation,
  ) {
    final lastMessage = conversation.lastMessage;
    final unreadCount = conversation.unreadCount;

    return Dismissible(
          key: ValueKey(conversation.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          secondaryBackground: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerRight,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(LucideIcons.trash2, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Eliminar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          dismissThresholds: const {
            DismissDirection.endToStart: 0.35,
          },
          confirmDismiss: (_) =>
              _confirmDeleteConversation(context, ref, conversation),
          child: GestureDetector(
            onLongPress: () {
              _showConversationActions(context, ref, conversation);
            },
            onTap: () {
              context.push(
                '/messages/${conversation.id}',
                extra: {
                  'participantName': conversation.participantName,
                  'participantAvatarUrl': conversation.participantAvatarUrl,
                  'participantRole': conversation.participantRole,
                },
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  LBAvatar(
                    placeholder: conversation.participantName.substring(0, 1),
                    imageUrl: conversation.participantAvatarUrl,
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
                            Expanded(
                              child: Text(
                                conversation.participantName,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => _showConversationActions(
                                context,
                                ref,
                                conversation,
                              ),
                              icon: const Icon(LucideIcons.moreVertical),
                              tooltip: 'Opciones del chat',
                              visualDensity: VisualDensity.compact,
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
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
        );
  }

  Future<bool> _confirmDeleteConversation(
    BuildContext context,
    WidgetRef ref,
    dynamic conversation,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar chat'),
        content: Text(
          'Se eliminará el chat con ${conversation.participantName} de tu lista. '
          'Esta acción no afectará a los demás participantes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return false;
    }

    try {
      await ref
          .read(conversationsNotifierProvider.notifier)
          .deleteConversation(conversation.id);
      return true;
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No fue posible eliminar el chat: $error')),
        );
      }
      return false;
    }
  }

  Future<void> _showConversationActions(
    BuildContext context,
    WidgetRef ref,
    dynamic conversation,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.trash2, color: AppColors.error),
              title: const Text('Eliminar chat'),
              subtitle: Text('Quitar conversación con ${conversation.participantName}'),
              onTap: () => Navigator.of(sheetContext).pop('delete'),
            ),
            ListTile(
              leading: const Icon(LucideIcons.x),
              title: const Text('Cancelar'),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );

    if (selected == 'delete' && context.mounted) {
      await _confirmDeleteConversation(context, ref, conversation);
    }
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
