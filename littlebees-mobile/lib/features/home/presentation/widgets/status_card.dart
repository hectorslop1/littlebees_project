import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../domain/child_status.dart';
import '../../../../design_system/widgets/lb_card.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../core/i18n/app_translations.dart';

class StatusCard extends ConsumerWidget {
  final ChildStatus status;

  const StatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final isCheckedIn = status.status == ChildPresenceStatus.checkedIn;
    
    return LBCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCheckedIn ? AppColors.success.withAlpha(26) : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCheckedIn ? LucideIcons.checkCircle2 : LucideIcons.home,
              color: isCheckedIn ? AppColors.success : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCheckedIn ? tr.tr('checkedIn') : tr.tr('checkedOut'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isCheckedIn ? AppColors.success : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (status.lastStatusChange != null)
                  Text(
                    isCheckedIn 
                        ? '${tr.tr('checkedIn')} ${TimeOfDay.fromDateTime(status.lastStatusChange!).format(context)} by ${status.checkedInBy}'
                        : '${tr.tr('checkedOut')} ${TimeOfDay.fromDateTime(status.lastStatusChange!).format(context)} by ${status.checkedOutBy}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
