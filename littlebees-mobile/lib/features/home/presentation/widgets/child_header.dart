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
    final currentChildId = ref.watch(currentChildIdProvider);
    final childrenAsync = ref.watch(myChildrenProvider);

    // Get the list of children from the provider
    final children = childrenAsync.when(
      data: (childrenList) => childrenList,
      loading: () => <Child>[],
      error: (_, __) => <Child>[],
    );

    return PopupMenuButton<String>(
      offset: const Offset(0, 60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      shadowColor: AppColors.primary.withAlpha(50),
      onSelected: (String childId) {
        if (childId != currentChildId) {
          ref.read(currentChildIdProvider.notifier).state = childId;
        }
      },
      itemBuilder: (BuildContext context) => children
          .map(
            (child) => PopupMenuItem<String>(
              value: child.id,
              child: Row(
                children: [
                  LBAvatar(
                    imageUrl: child.photoUrl,
                    placeholder: child.firstName.isNotEmpty
                        ? child.firstName[0]
                        : 'C',
                    size: LBAvatarSize.small,
                    statusColor: child.id == currentChildId
                        ? AppColors.primary
                        : Colors.transparent,
                    showStatusDot: child.id == currentChildId,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${child.firstName} ${child.lastName}',
                    style: TextStyle(
                      fontWeight: child.id == currentChildId
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: child.id == currentChildId
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
              imageUrl: childNode.photoUrl,
              placeholder: childNode.firstName.isNotEmpty
                  ? childNode.firstName[0]
                  : 'C',
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
                    '${childNode.groupName ?? "No Group"} Class',
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
