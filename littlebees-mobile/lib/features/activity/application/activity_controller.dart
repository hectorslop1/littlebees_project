import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/photo_model.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../home/application/home_providers.dart';
import '../../auth/application/auth_provider.dart';

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
