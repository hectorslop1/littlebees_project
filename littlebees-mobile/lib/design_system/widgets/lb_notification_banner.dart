import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

enum LBNotificationType { info, success, warning, error }

class LBNotificationBanner extends StatelessWidget {
  final String title;
  final String? message;
  final LBNotificationType type;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final bool showDismiss;

  const LBNotificationBanner({
    super.key,
    required this.title,
    this.message,
    this.type = LBNotificationType.info,
    this.onTap,
    this.onDismiss,
    this.showDismiss = true,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: config.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: config.borderColor, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: config.iconBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(config.icon, size: 20, color: config.iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        if (message != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            message!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (showDismiss) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: onDismiss,
                      color: AppColors.textSecondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        )
        .animate()
        .slideY(begin: -1, end: 0, duration: 400.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 300.ms);
  }

  _NotificationConfig _getConfig() {
    switch (type) {
      case LBNotificationType.success:
        return _NotificationConfig(
          icon: LucideIcons.checkCircle,
          iconColor: AppColors.success,
          iconBackgroundColor: AppColors.success.withAlpha(25),
          backgroundColor: AppColors.surface,
          borderColor: AppColors.success.withAlpha(50),
        );
      case LBNotificationType.warning:
        return _NotificationConfig(
          icon: LucideIcons.alertTriangle,
          iconColor: AppColors.warning,
          iconBackgroundColor: AppColors.warning.withAlpha(25),
          backgroundColor: AppColors.surface,
          borderColor: AppColors.warning.withAlpha(50),
        );
      case LBNotificationType.error:
        return _NotificationConfig(
          icon: LucideIcons.alertCircle,
          iconColor: AppColors.error,
          iconBackgroundColor: AppColors.error.withAlpha(25),
          backgroundColor: AppColors.surface,
          borderColor: AppColors.error.withAlpha(50),
        );
      case LBNotificationType.info:
        return _NotificationConfig(
          icon: LucideIcons.info,
          iconColor: AppColors.info,
          iconBackgroundColor: AppColors.info.withAlpha(25),
          backgroundColor: AppColors.surface,
          borderColor: AppColors.info.withAlpha(50),
        );
    }
  }
}

class _NotificationConfig {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color backgroundColor;
  final Color borderColor;

  _NotificationConfig({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}
