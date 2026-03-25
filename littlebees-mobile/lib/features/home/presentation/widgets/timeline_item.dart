import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_spacing.dart';
import '../../../../design_system/widgets/lb_card.dart';
import '../../domain/timeline_event.dart';
import 'timeline_connector.dart';

class TimelineItem extends StatelessWidget {
  final TimelineEvent event;
  final bool isLast;
  final int index;

  const TimelineItem({
    super.key,
    required this.event,
    this.isLast = false,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TimelineConnector(
                isLast: isLast,
                icon: _getIconForType(event.type),
                color: _getColorForType(event.type),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: _buildEventContent(context),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: (index * 50).ms, duration: 250.ms)
        .slideY(
          begin: 0.1,
          delay: (index * 50).ms,
          duration: 250.ms,
          curve: Curves.easeOutQuad,
        );
  }

  Widget _buildEventContent(BuildContext context) {
    bool hasContent =
        event.description != null ||
        event.photoUrls != null ||
        event.napDetails != null ||
        event.mealDetails != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              event.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              TimeOfDay.fromDateTime(event.timestamp).format(context),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        if (hasContent) const SizedBox(height: AppSpacing.sm),
        if (hasContent)
          LBCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.description != null) ...[
                  Text(
                    event.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (event.photoUrls != null ||
                      event.napDetails != null ||
                      event.mealDetails != null)
                    const SizedBox(height: AppSpacing.sm),
                ],

                if (event.photoUrls != null)
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: event.photoUrls!.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            event.photoUrls![i],
                            width: 160,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),

                if (event.type == TimelineEventType.nap &&
                    event.napDetails != null)
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.clock,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${TimeOfDay.fromDateTime(event.napDetails!.startTime).format(context)} - ${event.napDetails!.endTime != null ? TimeOfDay.fromDateTime(event.napDetails!.endTime!).format(context) : 'Now'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.napDetails!.quality.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                if (event.type == TimelineEventType.meal &&
                    event.mealDetails != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.utensils,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Amount: ${event.mealDetails!.amount.name}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      if (event.mealDetails!.notes != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          event.mealDetails!.notes!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }

  IconData _getIconForType(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.checkIn:
        return LucideIcons.logIn;
      case TimelineEventType.checkOut:
        return LucideIcons.logOut;
      case TimelineEventType.meal:
        return LucideIcons.utensils;
      case TimelineEventType.nap:
        return LucideIcons.moon;
      case TimelineEventType.photo:
        return LucideIcons.camera;
      case TimelineEventType.note:
        return LucideIcons.stickyNote;
      case TimelineEventType.activity:
        return LucideIcons.palette;
      case TimelineEventType.medication:
        return LucideIcons.pill;
      case TimelineEventType.milestone:
        return LucideIcons.star;
    }
  }

  Color _getColorForType(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.photo:
      case TimelineEventType.activity:
        return AppColors.primary;
      case TimelineEventType.checkIn:
      case TimelineEventType.checkOut:
        return AppColors.success;
      case TimelineEventType.nap:
      case TimelineEventType.note:
        return AppColors.info;
      case TimelineEventType.meal:
        return AppColors.warning;
      case TimelineEventType.medication:
      case TimelineEventType.milestone:
        return AppColors.secondary;
    }
  }
}
