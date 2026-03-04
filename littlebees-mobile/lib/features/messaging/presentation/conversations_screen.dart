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

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final hasConversations = true;

    return Scaffold(
      appBar: AppBar(title: Text(tr.tr('messages'))),
      body: SafeArea(
        child: hasConversations
            ? RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: _buildConversationsList(context),
                ),
              )
            : LBEmptyState(
                icon: LucideIcons.messageSquare,
                title: 'No Messages Yet',
                message: 'Your conversations with caregivers will appear here.',
              ),
      ),
    );
  }

  List<Widget> _buildConversationsList(BuildContext context) {
    return [
      GestureDetector(
        onTap: () => context.push('/messages/chat_1'),
        child: LBCard(
          child: Row(
            children: [
              const LBAvatar(
                placeholder: 'P',
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
                          'Ms. Patricia',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '2:30pm',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
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
                            "Emma had a great afternoon!",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
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
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
      const SizedBox(height: 16),
      GestureDetector(
        onTap: () => context.push('/messages/chat_2'),
        child: LBCard(
          child: Row(
            children: [
              const LBAvatar(
                placeholder: 'D',
                statusColor: AppColors.textTertiary,
                showStatusDot: true,
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
                          'Mr. David',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Yesterday',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "See you tomorrow!",
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 50.ms, duration: 300.ms).slideY(begin: 0.1),
    ];
  }
}
