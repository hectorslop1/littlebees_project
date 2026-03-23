import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/widgets/lb_avatar.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../design_system/widgets/lb_empty_state.dart';
import '../../../design_system/widgets/lb_error_state.dart';
import '../../../shared/models/message_model.dart';
import '../../auth/application/auth_provider.dart';
import '../application/conversations_provider.dart';
import '../domain/call_log.dart';
import '../application/realtime_messaging_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String participantName;
  final String? participantAvatarUrl;
  final String? participantRole;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
    this.participantAvatarUrl,
    this.participantRole,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showCallHistory = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    Future.microtask(() {
      ref.read(activeConversationIdProvider.notifier).state =
          widget.conversationId;
      ref
          .read(conversationsNotifierProvider.notifier)
          .markAsRead(widget.conversationId);
    });
  }

  void _onTextChanged() {
    final text = _controller.text;
    if (text.isNotEmpty && !_isTyping) {
      setState(() => _isTyping = true);
      ref
          .read(realtimeMessagingProvider(widget.conversationId).notifier)
          .startTyping();
    } else if (text.isEmpty && _isTyping) {
      setState(() => _isTyping = false);
      ref
          .read(realtimeMessagingProvider(widget.conversationId).notifier)
          .stopTyping();
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final content = _controller.text.trim();
    _controller.clear();
    setState(() => _isTyping = false);

    try {
      await ref
          .read(realtimeMessagingProvider(widget.conversationId).notifier)
          .sendMessage(content);

      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _makeVoiceCall() {
    context.push(
      '/messages/${widget.conversationId}/call',
      extra: {
        'participantName': widget.participantName,
        'participantAvatarUrl': widget.participantAvatarUrl,
        'participantRole': widget.participantRole,
        'callType': 'voice',
        'isOutgoing': true,
      },
    );
  }

  void _makeVideoCall() {
    context.push(
      '/messages/${widget.conversationId}/call',
      extra: {
        'participantName': widget.participantName,
        'participantAvatarUrl': widget.participantAvatarUrl,
        'participantRole': widget.participantRole,
        'callType': 'video',
        'isOutgoing': true,
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      final period = dateTime.hour >= 12 ? 'pm' : 'am';
      return '${hour == 0 ? 12 : hour}:${dateTime.minute.toString().padLeft(2, '0')}$period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  void dispose() {
    final activeConversationId = ref.read(activeConversationIdProvider);
    if (activeConversationId == widget.conversationId) {
      ref.read(activeConversationIdProvider.notifier).state = null;
    }
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      realtimeMessagingProvider(widget.conversationId),
    );
    final connectionAsync = ref.watch(socketConnectionProvider);
    final currentUser = ref.watch(currentUserProvider);
    final tr = ref.watch(translationsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: 28),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            LBAvatar(
              placeholder: widget.participantName.isNotEmpty
                  ? widget.participantName.substring(0, 1)
                  : 'U',
              imageUrl: widget.participantAvatarUrl,
              size: LBAvatarSize.small,
              showStatusDot: true,
              statusColor: AppColors.success,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.participantName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                connectionAsync.when(
                  data: (isConnected) => Text(
                    isConnected ? 'Online' : 'Offline',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isConnected
                          ? AppColors.success
                          : AppColors.textTertiary,
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ),
        titleSpacing: 0,
        elevation: 0,
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
                icon: const Icon(LucideIcons.phone, size: 22),
                onPressed: _makeVoiceCall,
                tooltip: 'Voice call',
              )
              .animate()
              .fadeIn(duration: 300.ms, delay: 100.ms)
              .scale(begin: const Offset(0.8, 0.8)),
          IconButton(
                icon: const Icon(LucideIcons.video, size: 22),
                onPressed: _makeVideoCall,
                tooltip: 'Video call',
              )
              .animate()
              .fadeIn(duration: 300.ms, delay: 200.ms)
              .scale(begin: const Offset(0.8, 0.8)),
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.moreVertical, size: 22),
            onSelected: (value) {
              if (value == 'call_history') {
                setState(() {
                  _showCallHistory = !_showCallHistory;
                });
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'call_history',
                child: Row(
                  children: [
                    Icon(
                      _showCallHistory
                          ? LucideIcons.messageSquare
                          : LucideIcons.phoneCall,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(_showCallHistory ? 'Show messages' : 'Call history'),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _showCallHistory
                ? messagesAsync.when(
                    data: (messages) =>
                        _buildCallHistory(messages, currentUser?.id),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => LBErrorState(
                      title: tr.tr('errorLoadingData'),
                      message: error.toString(),
                      onRetry: () => ref.refresh(
                        realtimeMessagingProvider(widget.conversationId),
                      ),
                    ),
                  )
                : messagesAsync.when(
                    data: (messages) => messages.isEmpty
                        ? LBEmptyState(
                            icon: LucideIcons.messageSquare,
                            title: tr.tr('noMessages'),
                            message: tr.tr('noMessagesMsg'),
                          )
                        : _buildMessagesList(messages, currentUser?.id),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => LBErrorState(
                      title: tr.tr('errorLoadingData'),
                      message: error.toString(),
                      onRetry: () => ref.refresh(
                        realtimeMessagingProvider(widget.conversationId),
                      ),
                    ),
                  ),
          ),
          if (!_showCallHistory) _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<Message> messages, String? currentUserId) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isMe = msg.senderId == currentUserId;
        final callLog = parseCallLog(msg);

        if (callLog != null && currentUserId != null) {
          return _buildCallLogBubble(msg, callLog, currentUserId, isMe);
        }

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child:
              Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isMe
                            ? const Radius.circular(4)
                            : const Radius.circular(16),
                        bottomLeft: !isMe
                            ? const Radius.circular(4)
                            : const Radius.circular(16),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          msg.content,
                          style: TextStyle(
                            color: isMe
                                ? AppColors.textOnPrimary
                                : AppColors.textPrimary,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(msg.createdAt),
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe
                                    ? AppColors.textOnPrimary.withAlpha(180)
                                    : AppColors.textTertiary,
                              ),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 4),
                              Icon(
                                msg.isRead ? Icons.done_all : Icons.done,
                                size: 14,
                                color: msg.isRead
                                    ? AppColors.success.withAlpha(200)
                                    : AppColors.textOnPrimary.withAlpha(200),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 250.ms)
                  .slideX(begin: isMe ? 0.1 : -0.1, end: 0),
        );
      },
    );
  }

  Widget _buildCallLogBubble(
    Message message,
    ParsedCallLog callLog,
    String currentUserId,
    bool isMe,
  ) {
    final title = buildCallTitle(callLog, currentUserId);
    final subtitle = buildCallSubtitle(callLog);
    final isVideo = callLog.isVideo;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primarySurface : AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isMe ? AppColors.primaryLight : AppColors.divider,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: (isVideo ? AppColors.info : AppColors.primary)
                        .withAlpha(24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isVideo ? LucideIcons.video : LucideIcons.phoneCall,
                    color: isVideo ? AppColors.info : AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(message.createdAt),
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
          .animate()
          .fadeIn(duration: 250.ms)
          .slideX(begin: isMe ? 0.1 : -0.1, end: 0),
    );
  }

  Widget _buildCallHistory(List<Message> messages, String? currentUserId) {
    final callMessages = messages
        .where((message) => message.attachmentType == 'call_log')
        .toList()
        .reversed
        .toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                LucideIcons.phoneCall,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Historial de llamadas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),
        Expanded(
          child: callMessages.isEmpty
              ? const Center(
                  child: Text(
                    'Aun no hay llamadas registradas.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: callMessages.length,
            itemBuilder: (context, index) {
              final message = callMessages[index];
              final callLog = parseCallLog(message);
              if (callLog == null || currentUserId == null) {
                return const SizedBox.shrink();
              }

              final isIncoming = callLog.callerId != currentUserId;
              final wasAnswered = callLog.status == 'completed';
              final isVideo = callLog.isVideo;

              return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
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
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: wasAnswered
                                ? AppColors.primarySurface
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isVideo ? LucideIcons.video : LucideIcons.phone,
                            size: 20,
                            color: wasAnswered
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isIncoming
                                        ? LucideIcons.phoneIncoming
                                        : LucideIcons.phoneOutgoing,
                                    size: 14,
                                    color: wasAnswered
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isIncoming ? 'Entrante' : 'Saliente',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                  ),
                                  if (!wasAnswered) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      '(${buildCallSubtitle(callLog)})',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppColors.error),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'dd MMM, hh:mm a',
                                ).format(message.createdAt),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (callLog.durationSeconds > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              formatCallDuration(callLog.durationSeconds),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                  .slideX(begin: -0.1, end: 0);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              LucideIcons.camera,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
                onPressed: _sendMessage,
                icon: const Icon(LucideIcons.send, color: AppColors.primary),
              )
              .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
                target: _controller.text.isNotEmpty ? 1 : 0,
              )
              .scale(end: const Offset(1.1, 1.1), duration: 600.ms),
        ],
      ),
    );
  }
}
