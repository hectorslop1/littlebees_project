import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import 'lb_button.dart';

class LBErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final bool showRetry;

  const LBErrorState({
    super.key,
    this.title = 'Oops! Something went wrong',
    this.message = 'We couldn\'t load this content. Please try again.',
    this.onRetry,
    this.showRetry = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(25),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                LucideIcons.alertCircle,
                size: 40,
                color: AppColors.error,
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                )
                .shake(duration: 500.ms, delay: 300.ms, hz: 4),
            
            const SizedBox(height: 16),
            
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
            
            const SizedBox(height: 8),
            
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 200.ms)
                .slideY(begin: 0.2, end: 0, duration: 500.ms),
            
            if (showRetry) ...[
              const SizedBox(height: 20),
              LBButton(
                text: 'Try Again',
                onPressed: onRetry ?? () {},
                icon: const Icon(
                  LucideIcons.refreshCw,
                  size: 20,
                  color: AppColors.textOnPrimary,
                ),
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
