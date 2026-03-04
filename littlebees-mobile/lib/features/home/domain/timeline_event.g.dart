// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealDetailsImpl _$$MealDetailsImplFromJson(Map<String, dynamic> json) =>
    _$MealDetailsImpl(
      mealType: $enumDecode(_$MealTypeEnumMap, json['mealType']),
      amount: $enumDecode(_$MealConsumptionEnumMap, json['amount']),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$MealDetailsImplToJson(_$MealDetailsImpl instance) =>
    <String, dynamic>{
      'mealType': _$MealTypeEnumMap[instance.mealType]!,
      'amount': _$MealConsumptionEnumMap[instance.amount]!,
      'notes': instance.notes,
    };

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.lunch: 'lunch',
  MealType.snack: 'snack',
};

const _$MealConsumptionEnumMap = {
  MealConsumption.all: 'all',
  MealConsumption.most: 'most',
  MealConsumption.some: 'some',
  MealConsumption.none: 'none',
};

_$NapDetailsImpl _$$NapDetailsImplFromJson(Map<String, dynamic> json) =>
    _$NapDetailsImpl(
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      quality: $enumDecode(_$NapQualityEnumMap, json['quality']),
    );

Map<String, dynamic> _$$NapDetailsImplToJson(_$NapDetailsImpl instance) =>
    <String, dynamic>{
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'quality': _$NapQualityEnumMap[instance.quality]!,
    };

const _$NapQualityEnumMap = {
  NapQuality.great: 'great',
  NapQuality.good: 'good',
  NapQuality.restless: 'restless',
  NapQuality.didNotSleep: 'didNotSleep',
};

_$TimelineEventImpl _$$TimelineEventImplFromJson(Map<String, dynamic> json) =>
    _$TimelineEventImpl(
      id: json['id'] as String,
      type: $enumDecode(_$TimelineEventTypeEnumMap, json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      caregiverName: json['caregiverName'] as String?,
      caregiverAvatarUrl: json['caregiverAvatarUrl'] as String?,
      photoUrls: (json['photoUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      mealDetails: json['mealDetails'] == null
          ? null
          : MealDetails.fromJson(json['mealDetails'] as Map<String, dynamic>),
      napDetails: json['napDetails'] == null
          ? null
          : NapDetails.fromJson(json['napDetails'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$TimelineEventImplToJson(_$TimelineEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$TimelineEventTypeEnumMap[instance.type]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'title': instance.title,
      'description': instance.description,
      'caregiverName': instance.caregiverName,
      'caregiverAvatarUrl': instance.caregiverAvatarUrl,
      'photoUrls': instance.photoUrls,
      'mealDetails': instance.mealDetails,
      'napDetails': instance.napDetails,
    };

const _$TimelineEventTypeEnumMap = {
  TimelineEventType.checkIn: 'checkIn',
  TimelineEventType.checkOut: 'checkOut',
  TimelineEventType.meal: 'meal',
  TimelineEventType.nap: 'nap',
  TimelineEventType.photo: 'photo',
  TimelineEventType.note: 'note',
  TimelineEventType.activity: 'activity',
  TimelineEventType.medication: 'medication',
  TimelineEventType.milestone: 'milestone',
};
