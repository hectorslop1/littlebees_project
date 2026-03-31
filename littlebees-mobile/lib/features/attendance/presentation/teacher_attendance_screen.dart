import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_avatar.dart';
import '../../../shared/enums/enums.dart';
import '../../../shared/models/attendance_model.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../home/application/home_providers.dart';

class TeacherAttendanceScreen extends ConsumerStatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  ConsumerState<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState
    extends ConsumerState<TeacherAttendanceScreen> {
  String? _selectedGroupId;
  final Set<String> _updatingChildIds = <String>{};

  Future<void> _markAttendance(
    Child child,
    AttendanceStatus status,
  ) async {
    if (_updatingChildIds.contains(child.id)) return;

    setState(() {
      _updatingChildIds.add(child.id);
    });

    final repository = ref.read(attendanceRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final isPresent = status == AttendanceStatus.present;

    try {
      await repository.markAttendance(
        childId: child.id,
        status: status,
        method: isPresent ? 'teacher_manual' : 'teacher_absence',
        observations: isPresent ? null : 'No llego a clase',
      );

      ref.invalidate(todayRoleAttendanceProvider);
      ref.invalidate(teacherDashboardProvider);

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isPresent
                ? 'Asistencia confirmada para ${child.firstName}'
                : 'Ausencia registrada para ${child.firstName}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('No fue posible guardar asistencia: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingChildIds.remove(child.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(myChildrenProvider);
    final attendanceAsync = ref.watch(todayRoleAttendanceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      appBar: AppBar(
        title: const Text('Asistencia de hoy'),
        elevation: 0,
      ),
      body: childrenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _AttendanceErrorState(
          message: 'No fue posible cargar alumnos: $error',
          onRetry: () => ref.invalidate(myChildrenProvider),
        ),
        data: (children) {
          return attendanceAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _AttendanceErrorState(
              message: 'No fue posible cargar asistencia: $error',
              onRetry: () => ref.invalidate(todayRoleAttendanceProvider),
            ),
            data: (attendance) {
              final attendanceByChild = {
                for (final record in attendance) record.childId: record,
              };
              final groups = _buildGroupFilters(children);
              final filteredChildren = _selectedGroupId == null
                  ? children
                  : children
                      .where((child) => child.groupId == _selectedGroupId)
                      .toList();
              final presentCount = attendanceByChild.values
                  .where(
                    (record) =>
                        record.checkInAt != null ||
                        record.status == AttendanceStatus.present ||
                        record.status == AttendanceStatus.late_,
                  )
                  .length;
              final absentCount = attendanceByChild.values
                  .where((record) => record.status == AttendanceStatus.absent)
                  .length;

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(myChildrenProvider);
                  ref.invalidate(todayRoleAttendanceProvider);
                  ref.invalidate(teacherDashboardProvider);
                  await Future.wait([
                    ref.read(myChildrenProvider.future),
                    ref.read(todayRoleAttendanceProvider.future),
                  ]);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                  children: [
                    _AttendanceSummaryCard(
                      totalChildren: children.length,
                      presentCount: presentCount,
                      absentCount: absentCount,
                    ),
                    const SizedBox(height: 12),
                    if (groups.isNotEmpty) ...[
                      const Text(
                        'Filtrar por grupo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: groups.length + 1,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _GroupFilterChip(
                                label: 'Todos',
                                selected: _selectedGroupId == null,
                                onTap: () {
                                  setState(() {
                                    _selectedGroupId = null;
                                  });
                                },
                              );
                            }

                            final group = groups[index - 1];
                            return _GroupFilterChip(
                              label: group.$2,
                              selected: _selectedGroupId == group.$1,
                              onTap: () {
                                setState(() {
                                  _selectedGroupId = group.$1;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (filteredChildren.isEmpty)
                      const _EmptyAttendanceState()
                    else
                      ...filteredChildren.map(
                        (child) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _AttendanceChildCard(
                            child: child,
                            record: attendanceByChild[child.id],
                            isUpdating: _updatingChildIds.contains(child.id),
                            onMarkPresent: () => _markAttendance(
                              child,
                              AttendanceStatus.present,
                            ),
                            onMarkAbsent: () => _markAttendance(
                              child,
                              AttendanceStatus.absent,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<(String, String)> _buildGroupFilters(List<Child> children) {
    final groups = <(String, String)>[];
    final seen = <String>{};

    for (final child in children) {
      final groupId = child.groupId;
      if (groupId == null || groupId.isEmpty || seen.contains(groupId)) {
        continue;
      }

      seen.add(groupId);
      groups.add((groupId, child.groupName?.trim().isNotEmpty == true
          ? child.groupName!.trim()
          : 'Sin grupo'));
    }

    groups.sort((left, right) => left.$2.compareTo(right.$2));
    return groups;
  }
}

class _AttendanceSummaryCard extends StatelessWidget {
  const _AttendanceSummaryCard({
    required this.totalChildren,
    required this.presentCount,
    required this.absentCount,
  });

  final int totalChildren;
  final int presentCount;
  final int absentCount;

  @override
  Widget build(BuildContext context) {
    final pendingCount = (totalChildren - presentCount - absentCount).clamp(
      0,
      totalChildren,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8EBC8), Color(0xFFEAF2FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(190),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Lista docente',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Confirma llegadas y ausencias del salón',
            style: TextStyle(
              fontSize: 20,
              height: 1.08,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Cada registro se guarda en la base de datos y actualiza la tarjeta del padre.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: 'Presentes',
                  value: '$presentCount',
                  color: AppColors.success,
                  tint: AppColors.success.withValues(alpha: 0.14),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryMetric(
                  label: 'Ausentes',
                  value: '$absentCount',
                  color: AppColors.warning,
                  tint: AppColors.warning.withValues(alpha: 0.16),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryMetric(
                  label: 'Pendientes',
                  value: '$pendingCount',
                  color: AppColors.info,
                  tint: AppColors.info.withValues(alpha: 0.14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.tint,
  });

  final String label;
  final String value;
  final Color color;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(210),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: tint,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupFilterChip extends StatelessWidget {
  const _GroupFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _AttendanceChildCard extends StatelessWidget {
  const _AttendanceChildCard({
    required this.child,
    required this.record,
    required this.isUpdating,
    required this.onMarkPresent,
    required this.onMarkAbsent,
  });

  final Child child;
  final AttendanceRecord? record;
  final bool isUpdating;
  final VoidCallback onMarkPresent;
  final VoidCallback onMarkAbsent;

  @override
  Widget build(BuildContext context) {
    final hasConfirmedArrival =
        record?.checkInAt != null ||
        record?.status == AttendanceStatus.present ||
        record?.status == AttendanceStatus.late_;
    final isAbsent = record?.status == AttendanceStatus.absent;
    final canMarkPresent = !isUpdating && !hasConfirmedArrival;
    final canMarkAbsent = !isUpdating && !hasConfirmedArrival && !isAbsent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(7),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              LBAvatar(
                imageUrl: child.photoUrl,
                placeholder: child.firstName,
                size: LBAvatarSize.normal,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${child.firstName} ${child.lastName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      child.groupName?.trim().isNotEmpty == true
                          ? child.groupName!.trim()
                          : 'Sin grupo asignado',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _AttendanceStatusBadge(record: record),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _InfoBlock(
                    icon: LucideIcons.clock3,
                    label: 'Hora',
                    value: _buildTimeLabel(context, record),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoBlock(
                    icon: LucideIcons.user,
                    label: 'Registrado por',
                    value: _buildRegisteredByLabel(record),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: canMarkAbsent ? onMarkAbsent : null,
                  icon: const Icon(LucideIcons.calendarX2, size: 18),
                  label: const Text('No llegó'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    side: BorderSide(
                      color: canMarkAbsent
                          ? AppColors.warning.withValues(alpha: 0.35)
                          : AppColors.border,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: canMarkPresent ? onMarkPresent : null,
                  icon: isUpdating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(LucideIcons.badgeCheck, size: 18),
                  label: Text(
                    hasConfirmedArrival ? 'Confirmado' : 'Llegó',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: hasConfirmedArrival
                        ? AppColors.success.withValues(alpha: 0.65)
                        : AppColors.border,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildTimeLabel(BuildContext context, AttendanceRecord? record) {
    final referenceTime =
        record?.checkInAt ?? record?.checkOutAt ?? record?.updatedAt;
    if (referenceTime == null) {
      return 'Sin hora';
    }

    return TimeOfDay.fromDateTime(referenceTime).format(context);
  }

  String _buildRegisteredByLabel(AttendanceRecord? record) {
    final registeredBy = record?.checkInBy?.trim();
    if (registeredBy != null && registeredBy.isNotEmpty) {
      return registeredBy;
    }

    if (record?.status == AttendanceStatus.absent) {
      return 'Pendiente';
    }

    return 'Sin registro';
  }
}

class _AttendanceStatusBadge extends StatelessWidget {
  const _AttendanceStatusBadge({required this.record});

  final AttendanceRecord? record;

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground) = switch (record?.status) {
      AttendanceStatus.present || AttendanceStatus.late_ => (
          'Presente',
          AppColors.success.withValues(alpha: 0.14),
          AppColors.success,
        ),
      AttendanceStatus.absent => (
          'Ausente',
          AppColors.warning.withValues(alpha: 0.16),
          AppColors.warning,
        ),
      AttendanceStatus.excused => (
          'Justificado',
          AppColors.info.withValues(alpha: 0.16),
          AppColors.info,
        ),
      null => (
          'Pendiente',
          AppColors.primary.withValues(alpha: 0.12),
          AppColors.primary,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAttendanceState extends StatelessWidget {
  const _EmptyAttendanceState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(
            LucideIcons.users,
            size: 46,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 12),
          Text(
            'No hay alumnos para este filtro.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceErrorState extends StatelessWidget {
  const _AttendanceErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 52,
              color: AppColors.error,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
