import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/payment_model.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../auth/application/auth_provider.dart';

final paymentsProvider = FutureProvider<List<Payment>>((ref) async {
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    throw Exception('User not authenticated');
  }

  final repository = ref.watch(paymentsRepositoryProvider);

  // Backend API automatically filters payments based on user role:
  // - Parents see payments for their children only
  // - Teachers/Admins see all payments in their scope
  return await repository.getMyPayments();
});

final pendingPaymentsProvider = Provider<List<Payment>>((ref) {
  final paymentsAsync = ref.watch(paymentsProvider);

  return paymentsAsync.when(
    data: (payments) =>
        payments.where((p) => p.status.value == 'pending').toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});

final totalBalanceProvider = Provider<double>((ref) {
  final pending = ref.watch(pendingPaymentsProvider);
  return pending.fold(0.0, (sum, payment) => sum + payment.amount);
});
