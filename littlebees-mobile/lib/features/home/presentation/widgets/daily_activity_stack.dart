import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../design_system/theme/app_colors.dart';
import '../../domain/timeline_event.dart';

class DailyActivityStack extends StatefulWidget {
  const DailyActivityStack({super.key, required this.events});

  final List<TimelineEvent> events;

  @override
  State<DailyActivityStack> createState() => _DailyActivityStackState();
}

class _DailyActivityStackState extends State<DailyActivityStack> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final previewEvents = widget.events.take(3).toList();

    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: SizedBox(
              height: _expanded ? 0 : 172,
              child: Stack(
                children: [
                  for (var i = previewEvents.length - 1; i >= 0; i--)
                    Positioned(
                      left: i * 8,
                      right: 0,
                      top: i * 10,
                      child: Opacity(
                        opacity: 1 - (i * 0.18),
                        child: _ActivityPreviewCard(
                          event: previewEvents[i],
                          compact: i != 0,
                        ),
                      ),
                    ),
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(220),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${widget.events.length} actividad${widget.events.length == 1 ? '' : 'es'}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _expanded
                                ? LucideIcons.chevronUp
                                : LucideIcons.chevronDown,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Column(
              children: widget.events
                  .map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ActivityPreviewCard(event: event),
                    ),
                  )
                  .toList(),
            ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.05, end: 0),
        ],
      ),
    );
  }
}

class _ActivityPreviewCard extends StatelessWidget {
  const _ActivityPreviewCard({required this.event, this.compact = false});

  final TimelineEvent event;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = _accentForType(event.type);
    final photoUrl = event.photoUrls?.isNotEmpty == true
        ? event.photoUrls!.first
        : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 16 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 44 : 52,
            height: compact ? 44 : 52,
            decoration: BoxDecoration(
              color: color.withAlpha(24),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Icon(_iconForType(event.type), color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 16 : 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatTime(event.timestamp),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if ((event.description ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    event.description!,
                    maxLines: compact ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
                if (photoUrl != null && !compact) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      photoUrl,
                      height: 146,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconForType(TimelineEventType type) {
  switch (type) {
    case TimelineEventType.meal:
      return LucideIcons.utensils;
    case TimelineEventType.nap:
      return LucideIcons.moon;
    case TimelineEventType.activity:
      return LucideIcons.sparkles;
    case TimelineEventType.checkIn:
      return LucideIcons.badgeCheck;
    case TimelineEventType.checkOut:
      return LucideIcons.logOut;
    case TimelineEventType.note:
      return LucideIcons.fileText;
    case TimelineEventType.photo:
      return LucideIcons.camera;
    case TimelineEventType.medication:
      return LucideIcons.pill;
    case TimelineEventType.milestone:
      return LucideIcons.star;
  }
}

Color _accentForType(TimelineEventType type) {
  switch (type) {
    case TimelineEventType.meal:
      return AppColors.warning;
    case TimelineEventType.nap:
      return AppColors.info;
    case TimelineEventType.checkIn:
    case TimelineEventType.checkOut:
      return AppColors.success;
    case TimelineEventType.photo:
    case TimelineEventType.activity:
      return AppColors.primary;
    case TimelineEventType.note:
    case TimelineEventType.medication:
    case TimelineEventType.milestone:
      return AppColors.secondary;
  }
}

String _formatTime(DateTime timestamp) {
  final local = timestamp.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final suffix = local.hour >= 12 ? 'pm' : 'am';
  return '$hour:$minute$suffix';
}
