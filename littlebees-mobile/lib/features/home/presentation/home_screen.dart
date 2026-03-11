import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../design_system/theme/app_colors.dart';
import '../application/home_providers.dart';
import 'widgets/home_shimmer.dart';
import 'widgets/child_header.dart';
import 'widgets/status_card.dart';
import 'widgets/ai_summary_card.dart';
import 'widgets/timeline_feed.dart';
import '../../../../core/i18n/app_translations.dart';
import '../../../routing/route_names.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final childrenAsync = ref.watch(myChildrenProvider);

    // Auto-select first child if none selected
    final currentChildId = ref.watch(currentChildIdProvider);

    return childrenAsync.when(
      data: (children) {
        if (children.isEmpty) {
          return Scaffold(
            body: SafeArea(child: Center(child: Text('No children found'))),
          );
        }

        // Auto-select first child
        final selectedId = currentChildId ?? children.first.id;
        if (currentChildId == null) {
          Future.microtask(
            () => ref.read(currentChildIdProvider.notifier).state = selectedId,
          );
        }

        return _buildHomeContent(context, ref, selectedId, tr);
      },
      loading: () => const HomeShimmer(),
      error: (error, stack) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error loading children: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(myChildrenProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent(
    BuildContext context,
    WidgetRef ref,
    String currentChildId,
    dynamic tr,
  ) {
    // Watch daily story for the currently selected child
    final dailyStoryAsync = ref.watch(dailyStoryProvider(currentChildId));

    return Scaffold(
      body: SafeArea(
        child: dailyStoryAsync.when(
          data: (dailyStory) {
            return RefreshIndicator(
              onRefresh: () =>
                  ref.refresh(dailyStoryProvider(currentChildId).future),
              child: CustomScrollView(
                key: ValueKey(
                  currentChildId,
                ), // Force rebuild when child changes
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    floating: true,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(50),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              LucideIcons.messageCircle,
                              color: AppColors.textOnPrimary,
                              size: 20,
                            ),
                            onPressed: () =>
                                context.pushNamed(RouteNames.messages),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          ChildHeader(childNode: dailyStory.child)
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(
                                begin: 0.1,
                                duration: 400.ms,
                                curve: Curves.easeOutQuad,
                              ),
                          const SizedBox(height: 24),
                          StatusCard(status: dailyStory.status)
                              .animate()
                              .fadeIn(delay: 50.ms, duration: 400.ms)
                              .slideY(
                                begin: 0.1,
                                duration: 400.ms,
                                curve: Curves.easeOutQuad,
                              ),
                          if (dailyStory.aiSummary != null) ...[
                            const SizedBox(height: 16),
                            AiSummaryCard(summary: dailyStory.aiSummary!)
                                .animate()
                                .fadeIn(delay: 100.ms, duration: 400.ms)
                                .slideY(
                                  begin: 0.1,
                                  duration: 400.ms,
                                  curve: Curves.easeOutQuad,
                                ),
                          ],
                          const SizedBox(height: 32),
                          Text(
                            tr.tr('todaySummary'),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ).animate().fadeIn(delay: 150.ms),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    sliver: TimelineFeed(events: dailyStory.events),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            );
          },
          loading: () => const HomeShimmer(),
          error: (error, stack) {
            print('HOME ERROR: $error'); // Debug logging
            return Scaffold(
              body: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error loading home: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(
                          dailyStoryProvider(currentChildId).future,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
