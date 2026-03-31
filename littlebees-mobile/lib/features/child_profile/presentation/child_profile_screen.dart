import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_avatar.dart';
import '../../../design_system/widgets/lb_card.dart';
import '../../home/application/home_providers.dart';
import '../application/child_profile_provider.dart';
import '../domain/child_profile_model.dart';
import 'edit_child_profile_screen.dart';

class ChildProfileScreen extends ConsumerWidget {
  const ChildProfileScreen({super.key, required this.childId});

  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(childProfileProvider(childId));

    return Scaffold(
      backgroundColor: context.appColor(AppColors.background),
      appBar: AppBar(
        title: childAsync.when(
          data: (child) => Text(child.fullName),
          loading: () => const Text('Perfil del niño'),
          error: (_, _) => const Text('Perfil del niño'),
        ),
        elevation: 0,
        actions: [
          childAsync.when(
            data: (child) => IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar perfil',
              onPressed: () async {
                final updated = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => EditChildProfileScreen(profile: child),
                  ),
                );

                if (updated == true) {
                  ref.invalidate(childProfileProvider(childId));
                  ref.invalidate(myChildrenProvider);
                  ref.invalidate(dailyStoryProvider(childId));
                }
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: childAsync.when(
          data: (child) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(childProfileProvider(childId));
              await ref.read(childProfileProvider(childId).future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              children: [
                _ProfileHero(child: child),
                const SizedBox(height: 12),
                _OverviewGrid(child: child),
                const SizedBox(height: 12),
                _MedicalSection(child: child),
                const SizedBox(height: 12),
                _AuthorizedPickupsSection(child: child),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ChildProfileErrorState(
            message: '$error',
            onRetry: () => ref.refresh(childProfileProvider(childId)),
          ),
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.child});

  final ChildProfileModel child;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteForGender(child.gender);
    final surfaceTint = context.isDark
        ? context.appColor(AppColors.surfaceVariant)
        : palette.surface;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            surfaceTint,
            context.appColor(AppColors.surface),
            context.isDark
                ? context.appColor(AppColors.surface)
                : palette.surface.withAlpha(110),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(context.isDark ? 28 : 20),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? context.appColor(AppColors.primarySurface)
                      : palette.chip,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Perfil editable',
                  style: TextStyle(
                    color: context.isDark
                        ? context.appColor(AppColors.primary)
                        : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: context.appColor(AppColors.surface).withAlpha(
                    context.isDark ? 255 : 220,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  child.status == 'active' ? 'Activo' : child.status,
                  style: TextStyle(
                    color: context.appColor(AppColors.textPrimary),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LBAvatar(
            imageUrl: child.photoUrl,
            placeholder: child.firstName.isNotEmpty ? child.firstName[0] : 'N',
            size: LBAvatarSize.large,
          ),
          const SizedBox(height: 12),
          Text(
            child.fullName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: context.appColor(AppColors.textPrimary),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroChip(
                icon: LucideIcons.cake,
                label: _formatExactAge(child.dateOfBirth),
                accent: palette.accent,
              ),
              _HeroChip(
                icon: child.gender == 'female'
                    ? LucideIcons.sparkles
                    : LucideIcons.shield,
                label: child.gender == 'female' ? 'Niña' : 'Niño',
                accent: palette.accent,
              ),
              _HeroChip(
                icon: LucideIcons.users,
                label: child.groupName ?? 'Sin grupo',
                accent: palette.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.appColor(AppColors.surface).withAlpha(
          context.isDark ? 255 : 220,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: context.isDark
              ? context.appColor(AppColors.border)
              : accent.withAlpha(45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: context.appColor(AppColors.textPrimary),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({required this.child});

  final ChildProfileModel child;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Edad',
        _formatExactAge(child.dateOfBirth),
        LucideIcons.cake,
        AppColors.primary,
      ),
      (
        'Grupo',
        child.groupName ?? 'Pendiente',
        LucideIcons.users,
        AppColors.secondary,
      ),
      (
        'Ingreso',
        child.enrollmentDate != null
            ? _formatShortDate(child.enrollmentDate!)
            : 'Sin fecha',
        LucideIcons.calendarDays,
        AppColors.info,
      ),
      (
        'Autorizados',
        '${child.pickupContacts.length}',
        LucideIcons.userCheck,
        AppColors.success,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.95,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return LBCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(item.$3, size: 16, color: item.$4),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.$1,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.appColor(AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.$2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.appColor(AppColors.textPrimary),
                ),
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}

class _MedicalSection extends StatelessWidget {
  const _MedicalSection({required this.child});

  final ChildProfileModel child;

  @override
  Widget build(BuildContext context) {
    final medical = child.medicalInfo;
    final hasMedicalData = medical.allergies.isNotEmpty ||
        medical.conditions.isNotEmpty ||
        medical.medications.isNotEmpty ||
        (medical.bloodType?.isNotEmpty ?? false) ||
        (medical.importantNotes?.isNotEmpty ?? false) ||
        (medical.doctorName?.isNotEmpty ?? false) ||
        (medical.doctorPhone?.isNotEmpty ?? false);

    return LBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.activity,
                color: context.appColor(AppColors.primary),
                size: 18,
              ),
              SizedBox(width: 10),
              Text(
                'Información médica y notas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasMedicalData)
            const _SectionEmptyState(
              icon: LucideIcons.heartPulse,
              title: 'Sin datos médicos cargados',
              subtitle:
                  'Los padres podrán guardar aquí alergias, medicamentos, notas importantes y datos del doctor.',
            )
          else ...[
            if (medical.importantNotes?.isNotEmpty ?? false)
              _MedicalListTile(
                icon: LucideIcons.stickyNote,
                title: 'Notas importantes',
                value: medical.importantNotes!,
                accent: AppColors.primary,
              ),
            if (medical.bloodType?.isNotEmpty ?? false) ...[
              if (medical.importantNotes?.isNotEmpty ?? false)
                const SizedBox(height: 12),
              _MedicalListTile(
                icon: LucideIcons.droplets,
                title: 'Tipo de sangre',
                value: medical.bloodType!,
                accent: AppColors.error,
              ),
            ],
            if ((medical.doctorName?.isNotEmpty ?? false) ||
                (medical.doctorPhone?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 12),
              _MedicalListTile(
                icon: LucideIcons.stethoscope,
                title: 'Doctor responsable',
                value: [
                  if (medical.doctorName?.isNotEmpty ?? false) medical.doctorName!,
                  if (medical.doctorPhone?.isNotEmpty ?? false) medical.doctorPhone!,
                ].join(' • '),
                accent: AppColors.info,
              ),
            ],
            if (medical.allergies.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ChipSection(
                title: 'Alergias',
                icon: LucideIcons.badgeAlert,
                accent: AppColors.error,
                items: medical.allergies,
              ),
            ],
            if (medical.conditions.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ChipSection(
                title: 'Condiciones',
                icon: LucideIcons.shieldAlert,
                accent: AppColors.warning,
                items: medical.conditions,
              ),
            ],
            if (medical.medications.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ChipSection(
                title: 'Medicamentos',
                icon: LucideIcons.pill,
                accent: AppColors.info,
                items: medical.medications,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _AuthorizedPickupsSection extends StatelessWidget {
  const _AuthorizedPickupsSection({required this.child});

  final ChildProfileModel child;

  @override
  Widget build(BuildContext context) {
    final pickups = child.pickupContacts;

    return LBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.userCheck, color: AppColors.primary, size: 18),
              SizedBox(width: 10),
              Text(
                'Personas autorizadas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (pickups.isEmpty)
            const _SectionEmptyState(
              icon: LucideIcons.users,
              title: 'Sin personas autorizadas registradas',
              subtitle:
                  'Cuando los padres agreguen responsables de recogida, se mostrarán aquí.',
            )
          else
            ...pickups.map(
              (pickup) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PickupTile(pickup: pickup),
              ),
            ),
        ],
      ),
    );
  }
}

class _PickupTile extends StatelessWidget {
  const _PickupTile({required this.pickup});

  final ChildPickupContact pickup;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appColor(AppColors.surfaceVariant),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          LBAvatar(
            imageUrl: pickup.photoUrl,
            placeholder: pickup.name.isNotEmpty ? pickup.name[0] : 'R',
            size: LBAvatarSize.small,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pickup.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.appColor(AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pickup.relationship} • ${pickup.phone}',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appColor(AppColors.textSecondary),
                  ),
                ),
                if (pickup.email?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
                  Text(
                    pickup.email!,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.appColor(AppColors.textSecondary),
                    ),
                  ),
                ],
                if (pickup.idPhotoUrl?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColor(AppColors.primarySurface),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'ID cargada',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: context.appColor(AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicalListTile extends StatelessWidget {
  const _MedicalListTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.isDark
            ? context.appColor(AppColors.surfaceVariant)
            : accent.withAlpha(16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.isDark
              ? context.appColor(AppColors.border)
              : accent.withAlpha(40),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.appColor(AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.appColor(AppColors.textPrimary),
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

class _ChipSection extends StatelessWidget {
  const _ChipSection({
    required this.title,
    required this.icon,
    required this.accent,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.isDark
            ? context.appColor(AppColors.surfaceVariant)
            : accent.withAlpha(12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.isDark
              ? context.appColor(AppColors.border)
              : accent.withAlpha(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: context.appColor(AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColor(AppColors.surface).withAlpha(
                        context.isDark ? 255 : 220,
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: context.appColor(AppColors.divider),
                      ),
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.appColor(AppColors.textPrimary),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SectionEmptyState extends StatelessWidget {
  const _SectionEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appColor(AppColors.surfaceVariant),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 30,
            color: context.appColor(AppColors.textTertiary),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.appColor(AppColors.textPrimary),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: context.appColor(AppColors.textSecondary),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ChildProfileErrorState extends StatelessWidget {
  const _ChildProfileErrorState({
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
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'No fue posible cargar el perfil',
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

String _formatShortDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

_GenderPalette _paletteForGender(String gender) {
  final normalized = gender.toLowerCase();
  if (normalized == 'female' || normalized == 'femenino' || normalized == 'girl') {
    return const _GenderPalette(
      surface: Color(0xFFFBE8EF),
      accent: Color(0xFFD88CA6),
      chip: Color(0xFFF5D7E3),
    );
  }

  return const _GenderPalette(
    surface: Color(0xFFE8F1FB),
    accent: Color(0xFF7FAED8),
    chip: Color(0xFFD8E7F8),
  );
}

class _GenderPalette {
  const _GenderPalette({
    required this.surface,
    required this.accent,
    required this.chip,
  });

  final Color surface;
  final Color accent;
  final Color chip;
}
