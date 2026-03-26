import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/reports_repository.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository();
});

final reportsSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(reportsRepositoryProvider);
  return repository.getReportsSummary();
});
