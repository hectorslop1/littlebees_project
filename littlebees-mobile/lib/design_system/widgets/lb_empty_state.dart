import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import 'lb_button.dart';

class LBEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const LBEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Icon(icon, size: 56, color: AppColors.textTertiary),
                )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                ),

            const SizedBox(height: 24),

            Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(duration: 500.ms, delay: 100.ms)
                .slideY(begin: 0.2, end: 0, duration: 500.ms),

            const SizedBox(height: 12),

            Text(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(duration: 500.ms, delay: 200.ms)
                .slideY(begin: 0.2, end: 0, duration: 500.ms),

            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 32),
              LBButton(
                    text: actionText!,
                    onPressed: onAction,
                    variant: LBButtonVariant.outline,
                    isFullWidth: false,
                  )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms)
                  .slideY(begin: 0.2, end: 0, duration: 500.ms),
            ],
          ],
        ),
      ),
    );
  }
}
