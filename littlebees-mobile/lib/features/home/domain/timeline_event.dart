import 'package:freezed_annotation/freezed_annotation.dart';

part 'timeline_event.freezed.dart';
part 'timeline_event.g.dart';

enum TimelineEventType {
  checkIn,
  checkOut,
  meal,
  nap,
  photo,
  note,
  activity,
  medication,
  milestone,
}

enum MealType { breakfast, lunch, snack }
enum MealConsumption { all, most, some, none }
enum NapQuality { great, good, restless, didNotSleep }

@freezed
class MealDetails with _$MealDetails {
  const factory MealDetails({
    required MealType mealType,
    required MealConsumption amount,
    String? notes,
  }) = _MealDetails;

  factory MealDetails.fromJson(Map<String, dynamic> json) => _$MealDetailsFromJson(json);
}

@freezed
class NapDetails with _$NapDetails {
  const factory NapDetails({
    required DateTime startTime,
    DateTime? endTime,
    required NapQuality quality,
  }) = _NapDetails;

  factory NapDetails.fromJson(Map<String, dynamic> json) => _$NapDetailsFromJson(json);
}

@freezed
class TimelineEvent with _$TimelineEvent {
  const factory TimelineEvent({
    required String id,
    required TimelineEventType type,
    required DateTime timestamp,
    required String title,
    String? description,
    String? caregiverName,
    String? caregiverAvatarUrl,
    List<String>? photoUrls,
    MealDetails? mealDetails,
    NapDetails? napDetails,
  }) = _TimelineEvent;

  factory TimelineEvent.fromJson(Map<String, dynamic> json) => _$TimelineEventFromJson(json);
}
