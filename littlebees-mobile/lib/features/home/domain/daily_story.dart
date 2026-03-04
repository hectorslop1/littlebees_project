import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/child_model.dart';
import 'child_status.dart';
import 'timeline_event.dart';
import 'ai_summary.dart';

part 'daily_story.freezed.dart';
part 'daily_story.g.dart';

@freezed
class DailyStory with _$DailyStory {
  const factory DailyStory({
    required DateTime date,
    required Child child,
    required ChildStatus status,
    required List<TimelineEvent> events,
    AiSummary? aiSummary,
  }) = _DailyStory;

  factory DailyStory.fromJson(Map<String, dynamic> json) => _$DailyStoryFromJson(json);
}
