import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/widgets/lb_avatar.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../design_system/widgets/lb_empty_state.dart';
import '../../../design_system/widgets/lb_error_state.dart';
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

  final List<Map<String, dynamic>> _callHistory = [
    {
      'type': 'video',
      'direction': 'outgoing',
      'duration': '5:32',
      'time': 'Today, 10:30 AM',
      'answered': true,
    },
    {
      'type': 'voice',
      'direction': 'incoming',
      'duration': '2:15',
      'time': 'Yesterday, 3:45 PM',
      'answered': true,
    },
    {
      'type': 'voice',
      'direction': 'incoming',
      'duration': null,
      'time': 'Mar 1, 11:20 AM',
      'answered': false,
    },
  ];

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice call feature coming soon'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _makeVideoCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video call feature coming soon'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
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
    final tr = ref.watch(translationsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: 28),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            const LBAvatar(
              placeholder: 'P',
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
                  error: (_, __) => const SizedBox.shrink(),
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
                ? _buildCallHistory()
                : messagesAsync.when(
                    data: (messages) => messages.isEmpty
                        ? LBEmptyState(
                            icon: LucideIcons.messageSquare,
                            title: tr.tr('noMessages'),
                            message: tr.tr('noMessagesMsg'),
                          )
                        : _buildMessagesList(messages),
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

  Widget _buildMessagesList(List messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isMe = msg.senderId == 'currentUserId';
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

  Widget _buildCallHistory() {
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
                'Call History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _callHistory.length,
            itemBuilder: (context, index) {
              final call = _callHistory[index];
              final isVideo = call['type'] == 'video';
              final isIncoming = call['direction'] == 'incoming';
              final wasAnswered = call['answered'];

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
                                    isIncoming ? 'Incoming' : 'Outgoing',
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
                                      '(Missed)',
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
                                call['time'],
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (call['duration'] != null)
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
                              call['duration'],
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
