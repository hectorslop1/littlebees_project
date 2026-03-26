import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_card.dart';
import '../../../routing/route_names.dart';
import '../../../shared/enums/enums.dart';
import '../../../shared/models/excuse_model.dart';
import '../../auth/application/auth_provider.dart';
import '../application/excuses_provider.dart';

class ExcusesListScreen extends ConsumerStatefulWidget {
  const ExcusesListScreen({super.key});

  @override
  ConsumerState<ExcusesListScreen> createState() => _ExcusesListScreenState();
}

class _ExcusesListScreenState extends ConsumerState<ExcusesListScreen> {
  ExcuseStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final filters = ExcusesFilters(status: _selectedStatus);
    final excusesAsync = ref.watch(excusesListProvider(filters));
    final canCreate = authState.isParent;
    final canReview = authState.isDirector || authState.isAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Justificantes'),
        actions: [
          if (canCreate)
            TextButton.icon(
              onPressed: () => context.pushNamed(RouteNames.excuseCreate),
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Nuevo'),
            ),
        ],
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => context.pushNamed(RouteNames.excuseCreate),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(LucideIcons.filePlus2),
              label: const Text('Crear'),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _HeroHeader(
                title: canReview
                    ? 'Pendientes que requieren revisión'
                    : authState.isTeacher
                    ? 'Avisos y justificantes de tus alumnos'
                    : 'Solicitudes y estado de tus justificantes',
                subtitle: canReview
                    ? 'Aprueba, rechaza y mantén informadas a familias y maestras.'
                    : authState.isTeacher
                    ? 'Aquí verás faltas, citas y avisos que impactan la operación del aula.'
                    : 'Da seguimiento al estatus de cada justificante sin perder contexto.',
                userName: user?.firstName ?? 'Familia',
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                children: [
                  _FilterChip(
                    label: 'Todos',
                    selected: _selectedStatus == null,
                    onTap: () => setState(() => _selectedStatus = null),
                  ),
                  const SizedBox(width: 10),
                  _FilterChip(
                    label: 'Pendientes',
                    selected: _selectedStatus == ExcuseStatus.pending,
                    onTap: () =>
                        setState(() => _selectedStatus = ExcuseStatus.pending),
                  ),
                  const SizedBox(width: 10),
                  _FilterChip(
                    label: 'Aprobados',
                    selected: _selectedStatus == ExcuseStatus.approved,
                    onTap: () =>
                        setState(() => _selectedStatus = ExcuseStatus.approved),
                  ),
                  const SizedBox(width: 10),
                  _FilterChip(
                    label: 'Rechazados',
                    selected: _selectedStatus == ExcuseStatus.rejected,
                    onTap: () =>
                        setState(() => _selectedStatus = ExcuseStatus.rejected),
                  ),
                ],
              ),
            ),
            Expanded(
              child: excusesAsync.when(
                data: (excuses) {
                  if (excuses.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(excusesListProvider(filters));
                        await ref.read(excusesListProvider(filters).future);
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        children: const [_EmptyState()],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(excusesListProvider(filters));
                      await ref.read(excusesListProvider(filters).future);
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: excuses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final excuse = excuses[index];
                        return _ExcuseCard(
                          excuse: excuse,
                          onTap: () => context.pushNamed(
                            RouteNames.excuseDetail,
                            pathParameters: {'excuseId': excuse.id},
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _ErrorState(
                  message: '$error',
                  onRetry: () => ref.invalidate(excusesListProvider(filters)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.title,
    required this.subtitle,
    required this.userName,
  });

  final String title;
  final String subtitle;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF7ECCE), Color(0xFFFFFFFF), Color(0xFFEFF5F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Centro de avisos',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Hola, $userName',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              height: 1.05,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ExcuseCard extends StatelessWidget {
  const _ExcuseCard({
    required this.excuse,
    required this.onTap,
  });

  final Excuse excuse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (excuse.status) {
      ExcuseStatus.pending => AppColors.warning,
      ExcuseStatus.approved => AppColors.success,
      ExcuseStatus.rejected => AppColors.error,
    };
    final icon = switch (excuse.status) {
      ExcuseStatus.pending => LucideIcons.clock3,
      ExcuseStatus.approved => LucideIcons.badgeCheck,
      ExcuseStatus.rejected => LucideIcons.xCircle,
    };
    final dateLabel = DateFormat('dd MMM', 'es_MX').format(excuse.date.toLocal());

    return LBCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        excuse.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        excuse.statusLabel,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  excuse.childName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  excuse.description?.isNotEmpty == true
                      ? excuse.description!
                      : excuse.typeLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      LucideIcons.calendarDays,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      LucideIcons.user,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        excuse.submittedByName.isNotEmpty
                            ? excuse.submittedByName
                            : 'Familia',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
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
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.fileSearch2,
              size: 38,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No hay justificantes para mostrar',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Cuando se cree o reciba un justificante, aparecerá aquí con su estado actualizado.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
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
              LucideIcons.alertTriangle,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'No fue posible cargar justificantes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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
