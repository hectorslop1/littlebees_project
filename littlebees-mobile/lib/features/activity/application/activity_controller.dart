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
  final authState = ref.watch(authProvider);
  final repository = ref.watch(dailyLogsRepositoryProvider);
  final childrenRepository = ref.watch(childrenRepositoryProvider);

  if (!authState.isAuthenticated) {
    return [];
  }

  final logs = authState.isParent
      ? await (() async {
          final children = await ref.watch(myChildrenProvider.future);
          if (children.isEmpty) {
            return <DailyLogEntry>[];
          }

          return repository.getDailyLogsForChildren(
            childIds: children.map((c) => c.id).toList(),
            date: DateTime.now(),
          );
        })()
      : await repository.getDailyLogsByDate(date: DateTime.now());

  for (final childId in logs.map((log) => log.childId).toSet()) {
    try {
      await childrenRepository.getChildById(childId);
    } catch (_) {
      // Ignore inaccessible child details; photos still render from log metadata.
    }
  }

  final photos = <Photo>[];
  for (final log in logs) {
    for (final url in _extractPhotoUrls(log.metadata)) {
      photos.add(
        Photo(
          id: '${log.id}_${photos.length}',
          url: url,
          timestamp: log.createdAt,
          caption: log.description ?? log.title,
          caregiverName: log.recordedByName ?? 'Teacher',
        ),
      );
    }
  }

  return photos..sort((a, b) => b.timestamp.compareTo(a.timestamp));
});

final activityFeedProvider = FutureProvider<List<ActivityFeedItem>>((
  ref,
) async {
  final authState = ref.watch(authProvider);
  final repository = ref.watch(dailyLogsRepositoryProvider);
  final childrenRepository = ref.watch(childrenRepositoryProvider);

  if (!authState.isAuthenticated) {
    return [];
  }

  final logs = authState.isParent
      ? await (() async {
          final children = await ref.watch(myChildrenProvider.future);
          if (children.isEmpty) {
            return <DailyLogEntry>[];
          }

          return repository.getDailyLogsForChildren(
            childIds: children.map((c) => c.id).toList(),
            date: DateTime.now(),
          );
        })()
      : await repository.getDailyLogsByDate(date: DateTime.now());

  final childIndex = <String, ({String name, String? photoUrl})>{};
  for (final childId in logs.map((log) => log.childId).toSet()) {
    try {
      final child = await childrenRepository.getChildById(childId);
      childIndex[childId] = (
        name: '${child.firstName} ${child.lastName}'.trim(),
        photoUrl: child.photoUrl,
      );
    } catch (_) {
      childIndex[childId] = (name: 'Alumno', photoUrl: null);
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

List<String> _extractPhotoUrls(Map<String, dynamic>? metadata) {
  if (metadata == null) {
    return const [];
  }

  final urls = <String>[];
  final rawPhotoUrls = metadata['photoUrls'];
  if (rawPhotoUrls is List) {
    urls.addAll(
      rawPhotoUrls
          .map((value) => value?.toString())
          .whereType<String>()
          .where((value) => value.isNotEmpty),
    );
  }

  final singlePhotoUrl = metadata['photoUrl']?.toString();
  if (singlePhotoUrl != null && singlePhotoUrl.isNotEmpty) {
    urls.add(singlePhotoUrl);
  }

  return urls;
}
