import 'package:flutter/material.dart';
import '../../domain/timeline_event.dart';
import 'timeline_item.dart';

class TimelineFeed extends StatelessWidget {
  final List<TimelineEvent> events;

  const TimelineFeed({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final event = events[index];
          final isLast = index == events.length - 1;
          return TimelineItem(
            event: event,
            isLast: isLast,
            index: index,
          );
        },
        childCount: events.length,
      ),
    );
  }
}
