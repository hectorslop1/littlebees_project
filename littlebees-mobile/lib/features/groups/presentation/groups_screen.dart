import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_loading_state.dart';
import '../../../design_system/widgets/compact_layout.dart';
import '../../../design_system/widgets/lb_card.dart';
import '../../../core/i18n/app_translations.dart';
import '../application/groups_provider.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(tr.tr('groups')), elevation: 0),
      body: SafeArea(
        child: groupsAsync.when(
          data: (groups) {
            if (groups.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.users,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tr.tr('noGroups'),
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            final totalCapacity = groups.fold<int>(
              0,
              (sum, group) => sum + group.currentCapacity,
            );
            final teacherCount = groups.fold<int>(
              0,
              (sum, group) => sum + (group.teacherNames?.length ?? 0),
            );

            return RefreshIndicator(
              onRefresh: () => ref.refresh(groupsProvider.future),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                children: [
                  CompactHeroCard(
                    eyebrow: 'Vista escolar',
                    title: 'Grupos organizados y listos para abrir',
                    subtitle:
                        'Consulta capacidad, maestras y edad del salón con menos scroll y mejor jerarquía visual.',
                    child: Row(
                      children: [
                        Expanded(
                          child: CompactMetricTile(
                            icon: LucideIcons.layoutGrid,
                            label: 'Grupos',
                            value: '${groups.length}',
                            accent: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CompactMetricTile(
                            icon: LucideIcons.baby,
                            label: tr.tr('students'),
                            value: '$totalCapacity',
                            accent: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CompactMetricTile(
                            icon: LucideIcons.userCheck,
                            label: tr.tr('teachers'),
                            value: '$teacherCount',
                            accent: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...groups.map((group) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LBCard(
                        onTap: () => context.push('/groups/${group.id}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    LucideIcons.users,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (group.friendlyName != null) ...[
                                        Text(
                                          group.friendlyName!,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          group.name,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ] else ...[
                                        Text(
                                          group.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 3),
                                      Text(
                                        '${group.ageRangeStart}-${group.ageRangeEnd} meses',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  LucideIcons.chevronRight,
                                  color: AppColors.textTertiary,
                                  size: 18,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(height: 1),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _buildStatItem(
                                  LucideIcons.baby,
                                  '${group.currentCapacity}/${group.maxCapacity}',
                                  tr.tr('students'),
                                ),
                                const SizedBox(width: 18),
                                _buildStatItem(
                                  LucideIcons.userCheck,
                                  group.teacherNames?.length.toString() ?? '0',
                                  tr.tr('teachers'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
          loading: () => const LBLoadingState(layout: LBLoadingLayout.cards),
          error: (error, stack) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.alertCircle,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: $error',
                    style: TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(groupsProvider),
                    child: Text(tr.tr('retry')),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
