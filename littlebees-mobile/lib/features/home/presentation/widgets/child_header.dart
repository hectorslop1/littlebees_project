import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../shared/models/child_model.dart';
import '../../../../design_system/widgets/lb_avatar.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../application/home_providers.dart';

class ChildHeader extends ConsumerWidget {
  final Child childNode;

  const ChildHeader({super.key, required this.childNode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentChild = ref.watch(currentChildIdProvider);

    final children = [
      {
        'id': 'c1',
        'name': 'Emma',
        'initial': 'E',
        'imageUrl':
            'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=150&h=150&fit=crop',
      },
      {
        'id': 'c2',
        'name': 'Liam',
        'initial': 'L',
        'imageUrl': 'https://source.unsplash.com/yBuzsGe9p3k/150x150',
      },
    ];

    return PopupMenuButton<String>(
      offset: const Offset(0, 60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      shadowColor: AppColors.primary.withAlpha(50),
      onSelected: (String result) {
        if (result != currentChild) {
          ref.read(currentChildIdProvider.notifier).state = result;
        }
      },
      itemBuilder: (BuildContext context) => children
          .map(
            (child) => PopupMenuItem<String>(
              value: child['id'] as String,
              child: Row(
                children: [
                  LBAvatar(
                    imageUrl: child['imageUrl'],
                    placeholder: child['initial'] as String,
                    size: LBAvatarSize.small,
                    statusColor: child['id'] == currentChild
                        ? AppColors.primary
                        : Colors.transparent,
                    showStatusDot: child['id'] == currentChild,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    child['name'] as String,
                    style: TextStyle(
                      fontWeight: child['id'] == currentChild
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: child['id'] == currentChild
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            LBAvatar(
              imageUrl: childNode.avatarUrl,
              placeholder: childNode.firstName,
              size: LBAvatarSize.normal,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${childNode.firstName} ${childNode.lastName.substring(0, 1)}.',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        LucideIcons.chevronDown,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  Text(
                    '${childNode.classroomName} Class',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(LucideIcons.bell, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
