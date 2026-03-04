import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/ai_summary.dart';
import '../../../../design_system/widgets/lb_card.dart';
import '../../../../design_system/theme/app_colors.dart';

class AiSummaryCard extends StatelessWidget {
  final AiSummary summary;

  const AiSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return LBCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(summary.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  summary.headline,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.auto_awesome, color: AppColors.primaryLight, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          ...summary.bullets.map((bullet) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                Expanded(
                  child: Text(
                    bullet,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutQuad);
  }
}
