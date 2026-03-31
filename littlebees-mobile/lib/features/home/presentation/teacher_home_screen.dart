import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/i18n/app_translations.dart';
import '../../../core/utils/date_utils.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_loading_state.dart';
import '../../../design_system/widgets/compact_layout.dart';
import '../../../design_system/widgets/date_selection_sheet.dart';
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
    final selectedDate = ref.watch(selectedDashboardDateProvider);
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
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                children: [
                  _TeacherTopBar(
                    name: authState.user?.firstName ?? 'Maestra',
                    selectedDate: selectedDate,
                    unreadMessages: unreadMessages,
                    onDateTap: () async {
                      final pickedDate = await showDateSelectionSheet(
                        context: context,
                        initialDate: selectedDate,
                      );
                      if (pickedDate != null) {
                        ref.read(selectedDashboardDateProvider.notifier).state =
                            pickedDate;
                      }
                    },
                    onNotificationsTap: () => context.push('/notifications'),
                    onMessagesTap: () => context.push('/messages'),
                  ),
                  const SizedBox(height: 12),
                  CompactHeroCard(
                    eyebrow: 'Panel del aula',
                    eyebrowIcon: LucideIcons.sparkles,
                    title: 'Tu salon, organizado y al dia',
                    subtitle: groups.isEmpty
                        ? 'Cuando tengas grupos asignados, aqui veras un resumen rapido para ${_teacherDateReference(selectedDate, context)}.'
                        : 'Revisa la asistencia y actividad de ${_teacherDateReference(selectedDate, context)} sin perder contexto.',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CompactMetricTile(
                                icon: LucideIcons.layoutGrid,
                                value: '${groups.length}',
                                label: 'Grupos',
                                accent: AppColors.primary,
                                onTap: () => context.push('/groups'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CompactMetricTile(
                                icon: LucideIcons.baby,
                                value: '$totalStudents',
                                label: tr.tr('students'),
                                accent: AppColors.secondary,
                                onTap: () => context.push('/groups'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: CompactMetricTile(
                                icon: LucideIcons.userCheck,
                                value: '$presentCount',
                                label: 'Presentes',
                                accent: AppColors.success,
                                onTap: () => context.push('/activity'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CompactMetricTile(
                                icon: LucideIcons.fileCheck2,
                                value: '$pendingExcuses',
                                label: 'Justificantes',
                                accent: AppColors.warning,
                                onTap: () => context.push('/excuses'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _TeacherActionCard(
                          icon: LucideIcons.plusSquare,
                          title: 'Registrar',
                          subtitle: todayActivities > 0
                              ? '$todayActivities registros en ${_teacherDateLabel(selectedDate, context)}'
                              : 'Sin actividades en ${_teacherDateLabel(selectedDate, context)}',
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
                  const SizedBox(height: 10),
                  _TeacherActionCard(
                    icon: LucideIcons.clipboardCheck,
                    title: 'Asistencia',
                    subtitle: isToday(selectedDate)
                        ? 'Abre la lista completa y registra quienes llegaron hoy.'
                        : 'Consulta la asistencia registrada para ${_teacherDateLabel(selectedDate, context)}.',
                    accent: AppColors.success,
                    onTap: () => context.push('/attendance'),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr.tr('myGroups'),
                        style: const TextStyle(
                          fontSize: 18,
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
                  const SizedBox(height: 10),
                  if (groups.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
          loading: () => const LBLoadingState(layout: LBLoadingLayout.home),
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
    required this.selectedDate,
    required this.unreadMessages,
    required this.onDateTap,
    required this.onNotificationsTap,
    required this.onMessagesTap,
  });

  final String name;
  final DateTime selectedDate;
  final int unreadMessages;
  final Future<void> Function() onDateTap;
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Gestiona grupos, mensajes y actividad de ${_teacherDateReference(selectedDate, context)}.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _TeacherDateButton(selectedDate: selectedDate, onTap: onDateTap),
        const SizedBox(width: 10),
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

class _TeacherDateButton extends StatelessWidget {
  const _TeacherDateButton({required this.selectedDate, required this.onTap});

  final DateTime selectedDate;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final label = formatShortDateLabel(
      selectedDate,
      locale: locale,
      uppercaseToday: true,
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minWidth: 76, minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                LucideIcons.calendarDays,
                color: AppColors.textPrimary,
                size: 16,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
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
      borderRadius: BorderRadius.circular(16),
      elevation: highlighted ? 4 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 44,
          height: 44,
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
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
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
                        fontSize: 10,
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
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accent.withAlpha(24),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accent, size: 16),
                  ),
                  const SizedBox(height: 12),
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
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.users,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
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

String _teacherDateLabel(DateTime selectedDate, BuildContext context) {
  return formatShortDateLabel(
    selectedDate,
    locale: Localizations.localeOf(context).toLanguageTag(),
    uppercaseToday: true,
  );
}

String _teacherDateReference(DateTime selectedDate, BuildContext context) {
  if (isToday(selectedDate)) {
    return 'hoy';
  }

  return formatShortDateLabel(
    selectedDate,
    locale: Localizations.localeOf(context).toLanguageTag(),
  );
}
