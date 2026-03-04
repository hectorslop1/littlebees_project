import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../shared/models/child_model.dart';
import '../domain/daily_story.dart';
import '../domain/child_status.dart';
import '../domain/timeline_event.dart';
import '../domain/ai_summary.dart';

class RemoteHomeRepository {
  final ApiClient _api = ApiClient.instance;

  /// Get all children for the current logged-in parent (via NestJS API)
  Future<List<Child>> getMyChildren() async {
    try {
      final response = await _api.get<Map<String, dynamic>>(Endpoints.children);

      final items = response['data'] as List? ?? [];
      return items.map((json) {
        return Child(
          id: json['id'],
          firstName: json['firstName'],
          lastName: json['lastName'],
          classroomId: json['groupId'] ?? '',
          classroomName: json['groupName'] ?? '',
          avatarUrl: json['photoUrl'],
          dateOfBirth: DateTime.parse(json['dateOfBirth']),
          allergies: List<String>.from(json['allergies'] ?? []),
          authorizedPickups: [],
        );
      }).toList();
    } catch (e) {
      throw Exception('Error loading children: $e');
    }
  }

  /// Get daily story for a specific child and date (via NestJS API)
  Future<DailyStory> getDailyStory(String childId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];

      // Get child data
      final childJson = await _api.get<Map<String, dynamic>>(
        Endpoints.child(childId),
      );

      final child = Child(
        id: childJson['id'],
        firstName: childJson['firstName'],
        lastName: childJson['lastName'],
        classroomId: childJson['groupId'] ?? '',
        classroomName: childJson['groupName'] ?? '',
        avatarUrl: childJson['photoUrl'],
        dateOfBirth: DateTime.parse(childJson['dateOfBirth']),
        allergies: List<String>.from(childJson['allergies'] ?? []),
        authorizedPickups: [],
      );

      // Get attendance for the date
      final attendanceResponse = await _api.get<Map<String, dynamic>>(
        Endpoints.attendance,
        queryParameters: {'childId': childId, 'date': dateStr},
      );

      ChildStatus status;
      final attendanceData = attendanceResponse['data'] as List?;
      if (attendanceData != null && attendanceData.isNotEmpty) {
        final record = attendanceData.first;
        status = ChildStatus(
          status: _parsePresenceStatus(record['status']),
          lastStatusChange: record['checkInAt'] != null
              ? DateTime.parse(record['checkInAt'])
              : null,
          checkedInBy: record['checkInBy'],
          checkedOutBy: record['checkOutBy'],
        );
      } else {
        status = const ChildStatus(
          status: ChildPresenceStatus.expected,
          lastStatusChange: null,
        );
      }

      // Get daily log events
      final logsResponse = await _api.get<Map<String, dynamic>>(
        Endpoints.dailyLogs,
        queryParameters: {'childId': childId, 'date': dateStr},
      );

      final logEntries = (logsResponse['data'] as List? ?? []);
      final events = logEntries.map((json) {
        return _parseTimelineEvent(json);
      }).toList();

      // AI summary is not yet implemented in the API
      AiSummary? aiSummary;

      return DailyStory(
        date: date,
        child: child,
        status: status,
        events: events,
        aiSummary: aiSummary,
      );
    } catch (e) {
      throw Exception('Error loading daily story: $e');
    }
  }

  ChildPresenceStatus _parsePresenceStatus(String status) {
    switch (status) {
      case 'present':
        return ChildPresenceStatus.checkedIn;
      case 'absent':
        return ChildPresenceStatus.absent;
      case 'late':
        return ChildPresenceStatus.checkedIn;
      case 'excused':
        return ChildPresenceStatus.absent;
      default:
        return ChildPresenceStatus.expected;
    }
  }

  TimelineEvent _parseTimelineEvent(Map<String, dynamic> json) {
    String? caregiverName;

    MealDetails? mealDetails;
    final metadata = json['metadata'] as Map<String, dynamic>?;
    if (json['type'] == 'meal' && metadata != null) {
      mealDetails = MealDetails(
        mealType: _parseMealType(metadata['food'] ?? ''),
        amount: MealConsumption.some,
        notes: metadata['notes'],
      );
    }

    NapDetails? napDetails;
    if (json['type'] == 'nap' && metadata != null) {
      napDetails = NapDetails(
        startTime:
            DateTime.tryParse(metadata['startTime'] ?? '') ?? DateTime.now(),
        endTime: DateTime.tryParse(metadata['endTime'] ?? ''),
        quality: _parseNapQuality(metadata['quality'] ?? 'good'),
      );
    }

    return TimelineEvent(
      id: json['id'],
      type: _parseEventType(json['type']),
      timestamp: DateTime.parse(json['createdAt'] ?? json['date']),
      title: json['title'],
      description: json['description'],
      caregiverName: caregiverName,
      caregiverAvatarUrl: null,
      photoUrls: null,
      mealDetails: mealDetails,
      napDetails: napDetails,
    );
  }

  TimelineEventType _parseEventType(String type) {
    switch (type) {
      case 'meal':
        return TimelineEventType.meal;
      case 'nap':
        return TimelineEventType.nap;
      case 'activity':
        return TimelineEventType.activity;
      case 'medication':
        return TimelineEventType.medication;
      case 'observation':
        return TimelineEventType.note;
      case 'incident':
        return TimelineEventType.note;
      case 'diaper':
        return TimelineEventType.note;
      default:
        return TimelineEventType.note;
    }
  }

  MealType _parseMealType(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'snack':
        return MealType.snack;
      default:
        return MealType.lunch;
    }
  }

  NapQuality _parseNapQuality(String quality) {
    switch (quality) {
      case 'buena':
      case 'great':
        return NapQuality.great;
      case 'excelente':
      case 'good':
        return NapQuality.good;
      case 'regular':
      case 'restless':
        return NapQuality.restless;
      default:
        return NapQuality.good;
    }
  }
}
