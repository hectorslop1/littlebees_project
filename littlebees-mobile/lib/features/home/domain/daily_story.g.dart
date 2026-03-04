// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_story.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyStoryImpl _$$DailyStoryImplFromJson(Map<String, dynamic> json) =>
    _$DailyStoryImpl(
      date: DateTime.parse(json['date'] as String),
      child: Child.fromJson(json['child'] as Map<String, dynamic>),
      status: ChildStatus.fromJson(json['status'] as Map<String, dynamic>),
      events: (json['events'] as List<dynamic>)
          .map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      aiSummary: json['aiSummary'] == null
          ? null
          : AiSummary.fromJson(json['aiSummary'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DailyStoryImplToJson(_$DailyStoryImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'child': instance.child,
      'status': instance.status,
      'events': instance.events,
      'aiSummary': instance.aiSummary,
    };
