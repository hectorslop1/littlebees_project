import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/photo_model.dart';
import '../../../core/mocks/mock_activity_data.dart';

final photosProvider = FutureProvider<List<Photo>>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 1));
  return MockActivityData.photos;
});
