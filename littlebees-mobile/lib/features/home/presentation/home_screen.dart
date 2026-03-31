import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/i18n/app_translations.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/compact_layout.dart';
import '../../../routing/route_names.dart';
import '../../auth/application/auth_provider.dart';
import '../../messaging/application/conversations_provider.dart';
import '../application/home_providers.dart';
import 'director_home_screen.dart';
import 'teacher_home_screen.dart';
import 'widgets/ai_summary_card.dart';
import 'widgets/child_header.dart';
import 'widgets/daily_activity_stack.dart';
import 'widgets/home_shimmer.dart';
import 'widgets/status_card.dart';

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

class _ParentHomeContent extends ConsumerStatefulWidget {
  const _ParentHomeContent({required this.currentChildId});

  final String currentChildId;

  @override
  ConsumerState<_ParentHomeContent> createState() => _ParentHomeContentState();
}

class _ParentHomeContentState extends ConsumerState<_ParentHomeContent>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(_refreshStory);
  }

  @override
  void didUpdateWidget(covariant _ParentHomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentChildId != widget.currentChildId) {
      Future.microtask(_refreshStory);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshStory();
    }
  }

  void _refreshStory() {
    ref.invalidate(dailyStoryProvider(widget.currentChildId));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final user = ref.watch(currentUserProvider);
    final tenant = ref.watch(currentTenantProvider);
    final dailyStoryAsync = ref.watch(
      dailyStoryProvider(widget.currentChildId),
    );
    final unreadMessages = ref.watch(unreadMessagesCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: dailyStoryAsync.when(
          data: (dailyStory) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(myChildrenProvider);
                ref.invalidate(dailyStoryProvider(widget.currentChildId));
                await ref.read(
                  dailyStoryProvider(widget.currentChildId).future,
                );
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                key: ValueKey(widget.currentChildId),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                          const SizedBox(height: 12),
                          ChildHeader(childNode: dailyStory.child)
                              .animate()
                              .fadeIn(delay: 40.ms, duration: 320.ms)
                              .slideY(begin: 0.08, duration: 320.ms),
                          const SizedBox(height: 10),
                          StatusCard(
                            status: dailyStory.status,
                          )
                              .animate()
                              .fadeIn(delay: 120.ms, duration: 320.ms)
                              .slideY(begin: 0.08, duration: 320.ms),
                          if (dailyStory.aiSummary != null) ...[
                            const SizedBox(height: 10),
                            AiSummaryCard(
                              summary: dailyStory.aiSummary!,
                            ).animate().fadeIn(delay: 160.ms, duration: 320.ms),
                          ],
                          const SizedBox(height: 14),
                          CompactSectionCard(
                            title: tr.tr('todaySummary'),
                            subtitle: dailyStory.events.isEmpty
                                ? 'Sin eventos por mostrar hoy.'
                                : '${dailyStory.events.length} eventos en orden cronologico.',
                            icon: LucideIcons.sparkles,
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${dailyStory.events.length} ${dailyStory.events.length == 1 ? 'evento' : 'eventos'}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            child: const SizedBox.shrink(),
                          ).animate().fadeIn(delay: 200.ms, duration: 320.ms),
                          const SizedBox(height: 8),
                          if (dailyStory.events.isEmpty)
                            const _EmptyTimelineState(),
                        ],
                      ),
                    ),
                  ),
                  if (dailyStory.events.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        child: ExpandableActivitySection(
                          events: dailyStory.events,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                ],
              ),
            );
          },
          loading: () => const HomeShimmer(),
          error: (error, _) => _ParentHomeErrorState(
            message: '$error',
            onRetry: () =>
                ref.refresh(dailyStoryProvider(widget.currentChildId)),
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
              const SizedBox(height: 4),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 28,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
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
        _RoundActionButton(icon: LucideIcons.bell, onTap: onNotificationsTap),
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
          width: 48,
          height: 48,
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
          Icon(LucideIcons.clock3, size: 36, color: AppColors.textTertiary),
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
            style: TextStyle(height: 1.5, color: AppColors.textSecondary),
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
  const _ParentHomeErrorState({required this.message, required this.onRetry});

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
