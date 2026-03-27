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
      final response = await _api.get<dynamic>(Endpoints.children);

      // Handle both response formats: direct list or object with data property
      List items;
      if (response is List) {
        items = response;
      } else if (response is Map<String, dynamic>) {
        items = response['data'] as List? ?? [];
      } else {
        items = [];
      }

      return items.map((json) {
        return Child(
          id: json['id'],
          tenantId: json['tenantId'] ?? '',
          firstName: json['firstName'],
          lastName: json['lastName'],
          dateOfBirth: DateTime.parse(json['dateOfBirth']),
          gender: json['gender'] ?? 'male',
          photoUrl: json['photoUrl'],
          groupId: json['groupId'],
          groupName:
              json['groupName'] ??
              ((json['group'] is Map<String, dynamic>)
                  ? json['group']['name'] as String?
                  : null),
          enrollmentDate: json['enrollmentDate'] != null
              ? DateTime.parse(json['enrollmentDate'])
              : null,
          status: json['status'] ?? 'active',
          qrCodeHash: json['qrCodeHash'],
          allergies: json['allergies'] != null
              ? List<String>.from(json['allergies'])
              : null,
          conditions: json['conditions'] != null
              ? List<String>.from(json['conditions'])
              : null,
          medications: json['medications'] != null
              ? List<String>.from(json['medications'])
              : null,
          bloodType: json['bloodType'],
          authorizedPickups: null,
          createdAt: json['createdAt'] != null
              ? DateTime.parse(json['createdAt']).toLocal()
              : DateTime.now(),
          updatedAt: json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt']).toLocal()
              : DateTime.now(),
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
        tenantId: childJson['tenantId'] ?? '',
        firstName: childJson['firstName'],
        lastName: childJson['lastName'],
        dateOfBirth: DateTime.parse(childJson['dateOfBirth']),
        gender: childJson['gender'] ?? 'male',
        photoUrl: childJson['photoUrl'],
        groupId: childJson['groupId'],
        groupName:
            childJson['groupName'] ??
            ((childJson['group'] is Map<String, dynamic>)
                ? childJson['group']['name'] as String?
                : null),
        enrollmentDate: childJson['enrollmentDate'] != null
            ? DateTime.parse(childJson['enrollmentDate'])
            : null,
        status: childJson['status'] ?? 'active',
        qrCodeHash: childJson['qrCodeHash'],
        allergies: childJson['allergies'] != null
            ? List<String>.from(childJson['allergies'])
            : null,
        conditions: childJson['conditions'] != null
            ? List<String>.from(childJson['conditions'])
            : null,
        medications: childJson['medications'] != null
            ? List<String>.from(childJson['medications'])
            : null,
        bloodType: childJson['bloodType'],
        authorizedPickups: null,
        createdAt: childJson['createdAt'] != null
            ? DateTime.parse(childJson['createdAt']).toLocal()
            : DateTime.now(),
        updatedAt: childJson['updatedAt'] != null
            ? DateTime.parse(childJson['updatedAt']).toLocal()
            : DateTime.now(),
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
              ? DateTime.parse(record['checkInAt']).toLocal()
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
      final requestedLocalDay = DateTime(date.year, date.month, date.day);
      final events =
          logEntries
              .map(
                (json) => _parseTimelineEvent(Map<String, dynamic>.from(json)),
              )
              .where((event) {
                final local = event.timestamp.toLocal();
                final eventDay = DateTime(local.year, local.month, local.day);
                return eventDay == requestedLocalDay;
              })
              .toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

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
    final metadata = json['metadata'] as Map<String, dynamic>?;
    final rawPhotoUrls = metadata?['photoUrls'] as List?;
    final photoUrls = rawPhotoUrls
        ?.map((url) => url?.toString())
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toList();
    final singlePhotoUrl = metadata?['photoUrl']?.toString();
    final resolvedPhotoUrls = [
      ...?photoUrls,
      if (singlePhotoUrl != null && singlePhotoUrl.isNotEmpty) singlePhotoUrl,
    ];
    final caregiverName = json['recordedByName'] as String?;

    MealDetails? mealDetails;
    if (json['type'] == 'meal' && metadata != null) {
      mealDetails = MealDetails(
        mealType: _parseMealType(
          metadata['foodEaten'] ?? metadata['food'] ?? '',
        ),
        amount: MealConsumption.some,
        notes: metadata['notes'] ?? json['description'],
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
      timestamp: DateTime.parse(
        (json['createdAt'] ?? json['date']) as String,
      ).toLocal(),
      title: json['title'],
      description: json['description'],
      caregiverName: caregiverName,
      caregiverAvatarUrl: null,
      photoUrls: resolvedPhotoUrls.isEmpty ? null : resolvedPhotoUrls,
      mealDetails: mealDetails,
      napDetails: napDetails,
    );
  }

  TimelineEventType _parseEventType(String type) {
    switch (type) {
      case 'check_in':
        return TimelineEventType.checkIn;
      case 'check_out':
        return TimelineEventType.checkOut;
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
