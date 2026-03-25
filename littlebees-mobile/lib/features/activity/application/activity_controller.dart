import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/photo_model.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../home/application/home_providers.dart'
    hide childrenRepositoryProvider;
import '../../auth/application/auth_provider.dart';
import '../../../shared/models/daily_log_model.dart';

class ActivityFeedItem {
  final DailyLogEntry log;
  final String childName;
  final String? childPhotoUrl;

  const ActivityFeedItem({
    required this.log,
    required this.childName,
    this.childPhotoUrl,
  });
}

final photosProvider = FutureProvider<List<Photo>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final children = await ref.watch(myChildrenProvider.future);
  final repository = ref.watch(dailyLogsRepositoryProvider);

  if (user == null || children.isEmpty) {
    return [];
  }

  // Get daily logs with photos for all children
  final childIds = children.map((c) => c.id).toList();
  final date = DateTime.now();

  final logs = await repository.getDailyLogsForChildren(
    childIds: childIds,
    date: date,
  );

  // Filter logs that have photo metadata and convert to Photo objects
  final photos = <Photo>[];
  for (final log in logs) {
    if (log.metadata != null && log.metadata!['photoUrls'] != null) {
      final photoUrls = log.metadata!['photoUrls'] as List;
      for (final url in photoUrls) {
        photos.add(
          Photo(
            id: '${log.id}_${photos.length}',
            url: url as String,
            timestamp: log.createdAt,
            caption: log.description ?? log.title,
            caregiverName: log.recordedByName ?? 'Teacher',
          ),
        );
      }
    }
  }

  return photos;
});

final activityFeedProvider = FutureProvider<List<ActivityFeedItem>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  final children = await ref.watch(myChildrenProvider.future);
  final repository = ref.watch(dailyLogsRepositoryProvider);
  final childrenRepository = ref.watch(childrenRepositoryProvider);

  if (user == null || children.isEmpty) {
    return [];
  }

  final logs = await repository.getDailyLogsByDate(date: DateTime.now());
  final childIndex = {
    for (final child in children)
      child.id: (
        name: '${child.firstName} ${child.lastName}'.trim(),
        photoUrl: child.photoUrl,
      ),
  };

  final missingPhotoIds = childIndex.entries
      .where(
        (entry) =>
            entry.value.photoUrl == null || entry.value.photoUrl!.isEmpty,
      )
      .map((entry) => entry.key)
      .toSet();

  for (final childId in missingPhotoIds) {
    try {
      final child = await childrenRepository.getChildById(childId);
      childIndex[childId] = (
        name: '${child.firstName} ${child.lastName}'.trim(),
        photoUrl: child.photoUrl,
      );
    } catch (_) {
      // Keep the existing lightweight record if detailed lookup fails.
    }
  }

  return logs.where((log) => childIndex.containsKey(log.childId)).map((log) {
    final child = childIndex[log.childId]!;
    return ActivityFeedItem(
      log: log,
      childName: child.name,
      childPhotoUrl: child.photoUrl,
    );
  }).toList()..sort((a, b) => b.log.createdAt.compareTo(a.log.createdAt));
});
