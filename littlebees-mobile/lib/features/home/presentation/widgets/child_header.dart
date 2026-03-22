import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../shared/models/child_model.dart';
import '../../../../design_system/widgets/lb_avatar.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../application/home_providers.dart';

class ChildHeader extends ConsumerWidget {
  const ChildHeader({super.key, required this.childNode});

  final Child childNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentChildId = ref.watch(currentChildIdProvider);
    final childrenAsync = ref.watch(myChildrenProvider);
    final palette = _paletteForGender(childNode.gender);

    final children = childrenAsync.when(
      data: (childrenList) => childrenList,
      loading: () => <Child>[],
      error: (_, _) => <Child>[],
    );

    return PopupMenuButton<String>(
      offset: const Offset(0, 72),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: AppColors.surface,
      elevation: 10,
      onSelected: (childId) {
        if (childId != currentChildId) {
          ref.read(currentChildIdProvider.notifier).state = childId;
        }
      },
      itemBuilder: (context) => children
          .map(
            (child) => PopupMenuItem<String>(
              value: child.id,
              child: Row(
                children: [
                  LBAvatar(
                    imageUrl: child.photoUrl,
                    placeholder: child.firstName.isNotEmpty
                        ? child.firstName[0]
                        : 'N',
                    size: LBAvatarSize.small,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${child.firstName} ${child.lastName}',
                      style: TextStyle(
                        fontWeight: child.id == currentChildId
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: child.id == currentChildId
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (child.id == currentChildId)
                    const Icon(
                      LucideIcons.badgeCheck,
                      size: 18,
                      color: AppColors.primary,
                    ),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [palette.surface, Colors.white, palette.surface.withAlpha(110)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: palette.chip,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${children.isEmpty ? 1 : children.indexWhere((child) => child.id == childNode.id) + 1} de ${children.isEmpty ? 1 : children.length}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  LucideIcons.chevronsUpDown,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                LBAvatar(
                  imageUrl: childNode.photoUrl,
                  placeholder: childNode.firstName.isNotEmpty
                      ? childNode.firstName[0]
                      : 'N',
                  size: LBAvatarSize.large,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${childNode.firstName} ${childNode.lastName}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoPill(
                            icon: LucideIcons.users,
                            label: childNode.groupName ?? 'Sin grupo',
                          ),
                          _InfoPill(
                            icon: LucideIcons.cake,
                            label: _formatExactAge(childNode.dateOfBirth),
                            accent: palette.accent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    this.accent = AppColors.textSecondary,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatExactAge(DateTime dob) {
  final months = DateTime.now().difference(dob).inDays ~/ 30;
  final years = months ~/ 12;
  final remainderMonths = months % 12;

  if (years > 0) {
    if (remainderMonths == 0) {
      return '$years año${years > 1 ? 's' : ''}';
    }
    return '$years año${years > 1 ? 's' : ''} $remainderMonths mes${remainderMonths > 1 ? 'es' : ''}';
  }

  return '$months mes${months == 1 ? '' : 'es'}';
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
