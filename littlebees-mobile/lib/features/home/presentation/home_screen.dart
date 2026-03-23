import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/i18n/app_translations.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../routing/route_names.dart';
import '../../auth/application/auth_provider.dart';
import '../../messaging/application/conversations_provider.dart';
import '../application/home_providers.dart';
import 'director_home_screen.dart';
import 'teacher_home_screen.dart';
import 'widgets/ai_summary_card.dart';
import 'widgets/child_header.dart';
import 'widgets/home_shimmer.dart';
import 'widgets/status_card.dart';
import 'widgets/timeline_feed.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isDirector || authState.isAdmin) {
      return const DirectorHomeScreen();
    }

    if (authState.isTeacher) {
      return const TeacherHomeScreen();
    }

    final childrenAsync = ref.watch(myChildrenProvider);
    final currentChildId = ref.watch(currentChildIdProvider);

    return childrenAsync.when(
      data: (children) {
        if (children.isEmpty) {
          return _ParentHomeEmptyState(email: authState.user?.email ?? '');
        }

        final selectedId = currentChildId ?? children.first.id;
        if (currentChildId == null) {
          Future.microtask(
            () => ref.read(currentChildIdProvider.notifier).state = selectedId,
          );
        }

        return _ParentHomeContent(currentChildId: selectedId);
      },
      loading: () => const HomeShimmer(),
      error: (error, _) => _ParentHomeErrorState(
        message: '$error',
        onRetry: () => ref.refresh(myChildrenProvider),
      ),
    );
  }
}

class _ParentHomeContent extends ConsumerWidget {
  const _ParentHomeContent({required this.currentChildId});

  final String currentChildId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final user = ref.watch(currentUserProvider);
    final tenant = ref.watch(currentTenantProvider);
    final dailyStoryAsync = ref.watch(dailyStoryProvider(currentChildId));
    final unreadMessages = ref.watch(unreadMessagesCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: dailyStoryAsync.when(
          data: (dailyStory) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(myChildrenProvider);
                ref.invalidate(dailyStoryProvider(currentChildId));
                await ref.read(dailyStoryProvider(currentChildId).future);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                key: ValueKey(currentChildId),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HomeTopBar(
                            userName: user?.firstName ?? 'Familia',
                            tenantName: tenant?.name ?? 'LittleBees',
                            unreadMessages: unreadMessages,
                            onNotificationsTap: () =>
                                context.push('/notifications'),
                            onMessagesTap: () =>
                                context.pushNamed(RouteNames.messages),
                          ).animate().fadeIn(duration: 320.ms),
                          const SizedBox(height: 22),
                          ChildHeader(childNode: dailyStory.child)
                              .animate()
                              .fadeIn(delay: 40.ms, duration: 320.ms)
                              .slideY(begin: 0.08, duration: 320.ms),
                          const SizedBox(height: 18),
                          _QuickActionsStrip(
                            onChildrenTap: () =>
                                context.pushNamed(RouteNames.children),
                            onPaymentsTap: () =>
                                context.pushNamed(RouteNames.payments),
                            onMessagesTap: () =>
                                context.pushNamed(RouteNames.messages),
                            unreadMessages: unreadMessages,
                          ).animate().fadeIn(delay: 80.ms, duration: 320.ms),
                          const SizedBox(height: 18),
                          StatusCard(status: dailyStory.status)
                              .animate()
                              .fadeIn(delay: 120.ms, duration: 320.ms)
                              .slideY(begin: 0.08, duration: 320.ms),
                          if (dailyStory.aiSummary != null) ...[
                            const SizedBox(height: 18),
                            AiSummaryCard(summary: dailyStory.aiSummary!)
                                .animate()
                                .fadeIn(delay: 160.ms, duration: 320.ms),
                          ],
                          const SizedBox(height: 26),
                          _TodaySectionHeader(
                            title: tr.tr('todaySummary'),
                            eventsCount: dailyStory.events.length,
                          ).animate().fadeIn(delay: 200.ms, duration: 320.ms),
                          const SizedBox(height: 16),
                          if (dailyStory.events.isEmpty)
                            const _EmptyTimelineState(),
                        ],
                      ),
                    ),
                  ),
                  if (dailyStory.events.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                      sliver: TimelineFeed(events: dailyStory.events),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                ],
              ),
            );
          },
          loading: () => const HomeShimmer(),
          error: (error, _) => _ParentHomeErrorState(
            message: '$error',
            onRetry: () => ref.refresh(dailyStoryProvider(currentChildId)),
          ),
        ),
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({
    required this.userName,
    required this.tenantName,
    required this.unreadMessages,
    required this.onNotificationsTap,
    required this.onMessagesTap,
  });

  final String userName;
  final String tenantName;
  final int unreadMessages;
  final VoidCallback onNotificationsTap;
  final VoidCallback onMessagesTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greetingForTime(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 30,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tenantName,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _RoundActionButton(
          icon: LucideIcons.bell,
          onTap: onNotificationsTap,
        ),
        const SizedBox(width: 10),
        _RoundActionButton(
          icon: LucideIcons.messageCircle,
          onTap: onMessagesTap,
          highlighted: true,
          badgeCount: unreadMessages,
        ),
      ],
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.icon,
    required this.onTap,
    this.highlighted = false,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool highlighted;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: highlighted ? 4 : 0,
      shadowColor: highlighted ? AppColors.primary.withAlpha(70) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Icon(
                  icon,
                  color: highlighted
                      ? AppColors.textOnPrimary
                      : AppColors.textPrimary,
                  size: 20,
                ),
              ),
              if (badgeCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: _UnreadBadge(count: badgeCount),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsStrip extends StatelessWidget {
  const _QuickActionsStrip({
    required this.onChildrenTap,
    required this.onPaymentsTap,
    required this.onMessagesTap,
    required this.unreadMessages,
  });

  final VoidCallback onChildrenTap;
  final VoidCallback onPaymentsTap;
  final VoidCallback onMessagesTap;
  final int unreadMessages;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: LucideIcons.baby,
            title: 'Mis hijos',
            subtitle: 'Perfiles y grupos',
            accent: AppColors.secondary,
            onTap: onChildrenTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: LucideIcons.creditCard,
            title: 'Pagos',
            subtitle: 'Estado de cuenta',
            accent: AppColors.primary,
            onTap: onPaymentsTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: LucideIcons.messageCircle,
            title: 'Chat',
            subtitle: 'Mensajes activos',
            accent: AppColors.info,
            onTap: onMessagesTap,
            badgeCount: unreadMessages,
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accent.withAlpha(30),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, size: 18, color: accent),
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: _UnreadBadge(count: badgeCount),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : count.toString();
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _TodaySectionHeader extends StatelessWidget {
  const _TodaySectionHeader({
    required this.title,
    required this.eventsCount,
  });

  final String title;
  final int eventsCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text(
            '$eventsCount eventos',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyTimelineState extends StatelessWidget {
  const _EmptyTimelineState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(
            LucideIcons.clock3,
            size: 36,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 14),
          Text(
            'Aun no hay registros del dia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Cuando la escuela registre actividades, alimentos o siestas apareceran aqui.',
            style: TextStyle(
              height: 1.5,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ParentHomeEmptyState extends StatelessWidget {
  const _ParentHomeEmptyState({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      LucideIcons.baby,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Aun no hay hijos vinculados',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Cuando el colegio relacione tu cuenta, aqui veras asistencia, actividades, pagos y mensajes.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      email,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ParentHomeErrorState extends StatelessWidget {
  const _ParentHomeErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.alertCircle,
                    size: 42,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No fue posible cargar el inicio',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: onRetry,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _greetingForTime() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Buenos dias';
  if (hour < 19) return 'Buenas tardes';
  return 'Buenas noches';
}
