// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyLogEntryImpl _$$DailyLogEntryImplFromJson(Map<String, dynamic> json) =>
    _$DailyLogEntryImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      childId: json['childId'] as String,
      date: DateTime.parse(json['date'] as String),
      type: $enumDecode(_$LogTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String?,
      time: json['time'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      recordedBy: json['recordedBy'] as String?,
      recordedByName: json['recordedByName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$DailyLogEntryImplToJson(_$DailyLogEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'childId': instance.childId,
      'date': instance.date.toIso8601String(),
      'type': _$LogTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'time': instance.time,
      'metadata': instance.metadata,
      'recordedBy': instance.recordedBy,
      'recordedByName': instance.recordedByName,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$LogTypeEnumMap = {
  LogType.meal: 'meal',
  LogType.nap: 'nap',
  LogType.activity: 'activity',
  LogType.diaper: 'diaper',
  LogType.medication: 'medication',
  LogType.observation: 'observation',
  LogType.incident: 'incident',
};
