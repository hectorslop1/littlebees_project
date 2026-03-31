import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_loading_state.dart';
import '../../../design_system/widgets/lb_avatar.dart';
import '../../../design_system/widgets/lb_card.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../shared/models/child_model.dart';
import '../../home/application/home_providers.dart';

class ChildrenListScreen extends ConsumerWidget {
  const ChildrenListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final childrenAsync = ref.watch(myChildrenProvider);

    return Scaffold(
      backgroundColor: context.appColor(AppColors.background),
      appBar: AppBar(title: Text(tr.tr('my_children')), elevation: 0),
      body: SafeArea(
        child: childrenAsync.when(
          data: (children) {
            if (children.isEmpty) {
              return _ChildrenEmptyState(message: tr.tr('noChildren'));
            }

            final activeGroups = children
                .map((child) => child.groupName)
                .whereType<String>()
                .toSet()
                .length;
            final activeProfiles = children
                .where((child) => child.status == 'active')
                .length;

            return RefreshIndicator(
              onRefresh: () => ref.refresh(myChildrenProvider.future),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                children: [
                  _ChildrenHero(
                    childrenCount: children.length,
                    activeProfiles: activeProfiles,
                    activeGroups: activeGroups,
                  ),
                  const SizedBox(height: 12),
                  ...children.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ChildSpotlightCard(
                        child: entry.value,
                        onTap: () =>
                            context.push('/children/${entry.value.id}/profile'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const LBLoadingState(layout: LBLoadingLayout.list),
          error: (error, stack) {
            return _ChildrenErrorState(
              message: '$error',
              onRetry: () => ref.refresh(myChildrenProvider),
            );
          },
        ),
      ),
    );
  }
}

class _ChildrenHero extends StatelessWidget {
  const _ChildrenHero({
    required this.childrenCount,
    required this.activeProfiles,
    required this.activeGroups,
  });

  final int childrenCount;
  final int activeProfiles;
  final int activeGroups;

  @override
  Widget build(BuildContext context) {
    final heroColors = context.isDark
        ? [
            context.appColor(AppColors.primarySurface),
            context.appColor(AppColors.surface),
            context.appColor(AppColors.secondarySurface),
          ]
        : [
            const Color(0xFFFAF4E5),
            const Color(0xFFFFFFFF),
            const Color(0xFFF0F5EF),
          ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: heroColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.appColor(AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(context.isDark ? 28 : 20),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: context.appColor(AppColors.primarySurface),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.sparkles,
                      size: 14,
                      color: context.appColor(AppColors.primary),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Seguimiento familiar',
                      style: TextStyle(
                        color: context.appColor(AppColors.primary),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Todo sobre tus hijos en un solo lugar',
            style: TextStyle(
              fontSize: 22,
              height: 1.08,
              fontWeight: FontWeight.w800,
              color: context.appColor(AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Consulta perfiles, grupos e informacion clave con una vista clara y elegante.',
            style: TextStyle(
              color: context.appColor(AppColors.textSecondary),
              height: 1.5,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: 'Hijos',
                  value: '$childrenCount',
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context
            .appColor(AppColors.surface)
            .withAlpha(context.isDark ? 255 : 220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColor(AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: context.appColor(AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.appColor(AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildSpotlightCard extends StatelessWidget {
  const _ChildSpotlightCard({required this.child, required this.onTap});

  final Child child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ageLabel = _formatExactAge(child.dateOfBirth);
    final palette = _paletteForGender(child.gender);
    final cardSurface = context.isDark
        ? context.appColor(AppColors.surfaceVariant)
        : palette.surface;

    return LBCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [context.appColor(AppColors.surface), cardSurface],
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
                          style: TextStyle(
                            color: context.appColor(AppColors.textSecondary),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    color: context.appColor(AppColors.textTertiary),
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
        color: context
            .appColor(AppColors.surface)
            .withAlpha(context.isDark ? 255 : 220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.isDark
              ? context.appColor(AppColors.border)
              : accent.withAlpha(60),
        ),
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
                  style: TextStyle(
                    fontSize: 11,
                    color: context.appColor(AppColors.textSecondary),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.appColor(AppColors.textPrimary),
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
  const _ChildrenEmptyState({required this.message});

  final String message;

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
              const Text(
                'Aun no hay perfiles visibles',
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
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildrenErrorState extends StatelessWidget {
  const _ChildrenErrorState({required this.message, required this.onRetry});

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
              FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ),
        ),
      ),
    );
  }
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
  if (normalized == 'female' ||
      normalized == 'femenino' ||
      normalized == 'girl') {
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
  const _GenderPalette({required this.surface, required this.accent});

  final Color surface;
  final Color accent;
}
