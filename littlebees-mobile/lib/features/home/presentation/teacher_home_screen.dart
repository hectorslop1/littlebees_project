import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/i18n/app_translations.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../auth/application/auth_provider.dart';
import '../application/home_providers.dart';
import '../../groups/application/groups_provider.dart';
import '../../messaging/application/conversations_provider.dart';

class TeacherHomeScreen extends ConsumerWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final authState = ref.watch(authProvider);
    final groupsAsync = ref.watch(groupsProvider);
    final unreadMessages = ref.watch(unreadMessagesCountProvider);
    final dashboardAsync = ref.watch(teacherDashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      body: SafeArea(
        child: groupsAsync.when(
          data: (groups) {
            final dashboard = dashboardAsync.valueOrNull;
            final totalStudents =
                dashboard?.studentsCount ??
                groups.fold<int>(
                  0,
                  (sum, group) => sum + group.currentCapacity,
                );
            final presentCount = dashboard?.presentCount ?? 0;
            final pendingExcuses = dashboard?.pendingExcusesCount ?? 0;
            final todayActivities = dashboard?.todayActivitiesCount ?? 0;

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(groupsProvider);
                ref.invalidate(teacherDashboardProvider);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                children: [
                  _TeacherTopBar(
                    name: authState.user?.firstName ?? 'Maestra',
                    unreadMessages: unreadMessages,
                    onNotificationsTap: () => context.push('/notifications'),
                    onMessagesTap: () => context.push('/messages'),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF8EBC8), Color(0xFFE8F0FB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(190),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.sparkles,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Panel del aula',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Tu salón, organizado y al día',
                          style: TextStyle(
                            fontSize: 28,
                            height: 1.05,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          groups.isEmpty
                              ? 'Cuando tengas grupos asignados, aquí verás un resumen rápido de tu jornada.'
                              : 'Revisa tus grupos, registra actividades y mantén a las familias informadas en tiempo real.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                icon: LucideIcons.layoutGrid,
                                value: '${groups.length}',
                                label: 'Grupos',
                                tint: AppColors.primarySurface,
                                iconColor: AppColors.primary,
                                onTap: () => context.push('/groups'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MetricCard(
                                icon: LucideIcons.baby,
                                value: '$totalStudents',
                                label: tr.tr('students'),
                                tint: AppColors.secondarySurface,
                                iconColor: AppColors.secondary,
                                onTap: () => context.push('/groups'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                icon: LucideIcons.userCheck,
                                value: '$presentCount',
                                label: 'Presentes',
                                tint: AppColors.success.withValues(alpha: 0.15),
                                iconColor: AppColors.success,
                                onTap: () => context.push('/activity'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MetricCard(
                                icon: LucideIcons.fileCheck2,
                                value: '$pendingExcuses',
                                label: 'Justificantes',
                                tint: AppColors.warning.withValues(alpha: 0.18),
                                iconColor: AppColors.warning,
                                onTap: () => context.push('/excuses'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _TeacherActionCard(
                          icon: LucideIcons.plusSquare,
                          title: 'Registrar',
                          subtitle: todayActivities > 0
                              ? '$todayActivities registros hoy'
                              : 'Crea la primera actividad del día',
                          accent: AppColors.primary,
                          onTap: () => context.push('/activity'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TeacherActionCard(
                          icon: LucideIcons.users,
                          title: 'Mis grupos',
                          subtitle: groups.isEmpty
                              ? 'Revisa tus salones asignados'
                              : 'Abre listas, alumnos y detalles',
                          accent: AppColors.secondary,
                          onTap: () => context.push('/groups'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _TeacherActionCard(
                    icon: LucideIcons.clipboardCheck,
                    title: 'Asistencia',
                    subtitle:
                        'Abre la lista completa de alumnos y registra si llegaron o no llegaron a clase.',
                    accent: AppColors.success,
                    onTap: () => context.push('/attendance'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr.tr('myGroups'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/groups'),
                        child: Text(tr.tr('seeAll')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (groups.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.users,
                            size: 52,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            tr.tr('noGroupsAssigned'),
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ...groups
                        .take(4)
                        .map(
                          (group) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _TeacherGroupCard(
                              title: group.displayName,
                              subtitle:
                                  '${group.currentCapacity} ${tr.tr('students')}',
                              onTap: () => context.push('/groups/${group.id}'),
                            ),
                          ),
                        ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.alertCircle,
                    size: 52,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No fue posible cargar el panel: $error',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.error),
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

class _TeacherTopBar extends StatelessWidget {
  const _TeacherTopBar({
    required this.name,
    required this.unreadMessages,
    required this.onNotificationsTap,
    required this.onMessagesTap,
  });

  final String name;
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
                'Hola, $name',
                style: const TextStyle(
                  fontSize: 30,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gestiona grupos, mensajes y actividad del día.',
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
        _TeacherRoundButton(icon: LucideIcons.bell, onTap: onNotificationsTap),
        const SizedBox(width: 10),
        _TeacherRoundButton(
          icon: LucideIcons.messageCircle,
          onTap: onMessagesTap,
          highlighted: true,
          badgeCount: unreadMessages,
        ),
      ],
    );
  }
}

class _TeacherRoundButton extends StatelessWidget {
  const _TeacherRoundButton({
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
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.tint,
    required this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color tint;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withAlpha(190),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherActionCard extends StatelessWidget {
  const _TeacherActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: accent.withAlpha(24),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: accent, size: 20),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherGroupCard extends StatelessWidget {
  const _TeacherGroupCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  LucideIcons.users,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
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
                  ],
                ),
              ),
              const Icon(
                LucideIcons.chevronRight,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
