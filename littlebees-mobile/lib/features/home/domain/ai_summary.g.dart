// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AiSummaryImpl _$$AiSummaryImplFromJson(Map<String, dynamic> json) =>
    _$AiSummaryImpl(
      emoji: json['emoji'] as String,
      headline: json['headline'] as String,
      bullets: (json['bullets'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$$AiSummaryImplToJson(_$AiSummaryImpl instance) =>
    <String, dynamic>{
      'emoji': instance.emoji,
      'headline': instance.headline,
      'bullets': instance.bullets,
      'generatedAt': instance.generatedAt.toIso8601String(),
    };
