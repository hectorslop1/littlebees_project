import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_avatar.dart';
import '../../../design_system/widgets/lb_card.dart';
import '../../../design_system/widgets/compact_layout.dart';
import '../../../shared/enums/enums.dart';
import '../../../shared/models/child_model.dart';
import '../../auth/application/auth_provider.dart';
import '../../home/application/home_providers.dart';

class MyChildrenScreen extends ConsumerWidget {
  const MyChildrenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final childrenAsync = ref.watch(myChildrenProvider);
    final title = _screenTitle(user?.role);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(title), elevation: 0),
      body: SafeArea(
        child: childrenAsync.when(
          data: (children) {
            if (children.isEmpty) {
              return _ChildrenEmptyState(role: user?.role);
            }

            return RefreshIndicator(
              onRefresh: () => ref.refresh(myChildrenProvider.future),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  _MyChildrenHero(
                    role: user?.role,
                    children: children,
                  ),
                  const SizedBox(height: 16),
                  ...children.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DetailedChildCard(
                        child: entry.value,
                        onTap: () => context.push('/children/${entry.value.id}/profile'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ChildrenErrorState(
            message: '$error',
            onRetry: () => ref.refresh(myChildrenProvider),
          ),
        ),
      ),
    );
  }
}

class _MyChildrenHero extends StatelessWidget {
  const _MyChildrenHero({
    required this.role,
    required this.children,
  });

  final UserRole? role;
  final List<Child> children;

  @override
  Widget build(BuildContext context) {
    final activeGroups = children
        .map((child) => child.groupName)
        .whereType<String>()
        .toSet()
        .length;
    final activeProfiles =
        children.where((child) => child.status == 'active').length;

    return CompactHeroCard(
      eyebrow: role == UserRole.parent ? 'Vista familiar' : 'Vista escolar',
      title: role == UserRole.parent
          ? 'Tus hijos, siempre a la mano'
          : 'Perfiles asignados con contexto completo',
      subtitle: role == UserRole.parent
          ? 'Revisa grupo, edad y estado de cada hijo con una vista clara y cuidada.'
          : 'Consulta los perfiles vinculados y entra al detalle de cada alumno en segundos.',
      child: Row(
        children: [
          Expanded(
            child: CompactMetricTile(
              label: role == UserRole.parent ? 'Hijos' : 'Alumnos',
              value: '${children.length}',
              icon: LucideIcons.baby,
              accent: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CompactMetricTile(
              label: 'Activos',
              value: '$activeProfiles',
              icon: LucideIcons.badgeCheck,
              accent: AppColors.info,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CompactMetricTile(
              label: 'Grupos',
              value: '$activeGroups',
              icon: LucideIcons.users,
              accent: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailedChildCard extends StatelessWidget {
  const _DetailedChildCard({
    required this.child,
    required this.onTap,
  });

  final Child child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ageLabel = _formatExactAge(child.dateOfBirth);
    final palette = _paletteForGender(child.gender);

    return LBCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              palette.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  LBAvatar(
                    placeholder: child.firstName.isNotEmpty
                        ? child.firstName[0]
                        : 'N',
                    imageUrl: child.photoUrl,
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
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          child.groupName ?? 'Sin grupo asignado',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ChildInfoPill(
                      icon: LucideIcons.cake,
                      label: 'Edad',
                      value: ageLabel,
                      accent: palette.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ChildInfoPill(
                      icon: LucideIcons.activity,
                      label: 'Estado',
                      value: child.status == 'active' ? 'Activo' : child.status,
                      accent: palette.accent,
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

class _ChildInfoPill extends StatelessWidget {
  const _ChildInfoPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildrenEmptyState extends StatelessWidget {
  const _ChildrenEmptyState({required this.role});

  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LBCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.baby,
                size: 56,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                role == UserRole.parent
                    ? 'Aun no tienes hijos vinculados'
                    : 'Aun no hay alumnos asignados',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Cuando existan perfiles disponibles, apareceran aqui automaticamente.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildrenErrorState extends StatelessWidget {
  const _ChildrenErrorState({
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
        child: LBCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.alertCircle,
                size: 56,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'No fue posible cargar los perfiles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _screenTitle(UserRole? role) {
  if (role == UserRole.teacher) return 'Mis Alumnos';
  if (role == UserRole.parent) return 'Mis Hijos';
  return 'Perfiles';
}

String _formatExactAge(DateTime dob) {
  final months = DateTime.now().difference(dob).inDays ~/ 30;
  final years = months ~/ 12;
  final remainingMonths = months % 12;

  if (years > 0) {
    if (remainingMonths == 0) {
      return '$years ${years == 1 ? 'año' : 'años'}';
    }
    return '$years ${years == 1 ? 'año' : 'años'} $remainingMonths ${remainingMonths == 1 ? 'mes' : 'meses'}';
  }

  return '$months ${months == 1 ? 'mes' : 'meses'}';
}

_GenderPalette _paletteForGender(String gender) {
  final normalized = gender.toLowerCase();
  if (normalized == 'female' || normalized == 'femenino' || normalized == 'girl') {
    return const _GenderPalette(
      surface: Color(0xFFFBE8EF),
      accent: Color(0xFFD88CA6),
    );
  }

  return const _GenderPalette(
    surface: Color(0xFFE8F1FB),
    accent: Color(0xFF7FAED8),
  );
}

class _GenderPalette {
  const _GenderPalette({
    required this.surface,
    required this.accent,
  });

  final Color surface;
  final Color accent;
}
