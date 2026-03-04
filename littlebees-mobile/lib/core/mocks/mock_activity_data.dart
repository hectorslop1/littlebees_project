import '../../features/activity/domain/photo_model.dart';

class MockActivityData {
  static List<Photo> photos = [
    Photo(
      id: 'p1',
      url: 'https://picsum.photos/seed/littlebee1/500/500',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      caption: 'Art class!',
      caregiverName: 'Miss Patricia',
    ),
    Photo(
      id: 'p2',
      url: 'https://picsum.photos/seed/littlebee2/500/500',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      caption: 'Outdoor play time',
      caregiverName: 'Miss Patricia',
    ),
    Photo(
      id: 'p3',
      url: 'https://picsum.photos/seed/littlebee3/500/500',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      caption: 'Building tall towers',
      caregiverName: 'Miss Sarah',
    ),
    Photo(
      id: 'p4',
      url: 'https://picsum.photos/seed/littlebee4/500/500',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      caption: 'Reading circle',
      caregiverName: 'Miss Emily',
    ),
    Photo(
      id: 'p5',
      url: 'https://picsum.photos/seed/littlebee5/500/500',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      caption: 'Snack time fun',
      caregiverName: 'Mr. David',
    ),
  ];
}
