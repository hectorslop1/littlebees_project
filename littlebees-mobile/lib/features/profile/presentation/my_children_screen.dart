import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_avatar.dart';
import '../../../design_system/widgets/lb_card.dart';
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
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                children: [
                  _MyChildrenHero(
                    role: user?.role,
                    children: children,
                  ),
                  const SizedBox(height: 20),
                  ...children.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF7F0DE), Color(0xFFFFFFFF), Color(0xFFF0F5EF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 28,
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
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              role == UserRole.parent ? 'Vista familiar' : 'Vista escolar',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            role == UserRole.parent
                ? 'Tus hijos, siempre a la mano'
                : 'Perfiles asignados con contexto completo',
            style: const TextStyle(
              fontSize: 28,
              height: 1.05,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            role == UserRole.parent
                ? 'Revisa grupo, edad y estado de cada hijo con una vista clara y cuidada.'
                : 'Consulta los perfiles vinculados y entra al detalle de cada alumno en segundos.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: role == UserRole.parent ? 'Hijos' : 'Alumnos',
                  value: '${children.length}',
                  icon: LucideIcons.baby,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroMetric(
                  label: 'Activos',
                  value: '$activeProfiles',
                  icon: LucideIcons.badgeCheck,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroMetric(
                  label: 'Grupos',
                  value: '$activeGroups',
                  icon: LucideIcons.users,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
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
          borderRadius: BorderRadius.circular(24),
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
          padding: const EdgeInsets.all(18),
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
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${child.firstName} ${child.lastName}',
                          style: const TextStyle(
                            fontSize: 18,
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
              const SizedBox(height: 18),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(18),
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
