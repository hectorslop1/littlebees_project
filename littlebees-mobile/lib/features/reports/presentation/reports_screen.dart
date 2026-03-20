import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_card.dart';
import '../../../core/i18n/app_translations.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.tr('reports')),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              tr.tr('availableReports'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildReportCard(
              context,
              icon: LucideIcons.userCheck,
              title: tr.tr('attendanceReport'),
              description: tr.tr('attendanceReportDesc'),
              color: AppColors.primary,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr.tr('featureComingSoon')),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              context,
              icon: LucideIcons.activity,
              title: tr.tr('activitiesReport'),
              description: tr.tr('activitiesReportDesc'),
              color: Colors.green,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr.tr('featureComingSoon')),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              context,
              icon: LucideIcons.dollarSign,
              title: tr.tr('paymentsReport'),
              description: tr.tr('paymentsReportDesc'),
              color: Colors.orange,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr.tr('featureComingSoon')),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              context,
              icon: LucideIcons.users,
              title: tr.tr('enrollmentReport'),
              description: tr.tr('enrollmentReportDesc'),
              color: Colors.purple,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr.tr('featureComingSoon')),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return LBCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            LucideIcons.chevronRight,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
