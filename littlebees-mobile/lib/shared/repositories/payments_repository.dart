import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../models/payment_model.dart';
import '../enums/enums.dart';

class PaymentsRepository {
  final ApiClient _api = ApiClient.instance;

  Future<List<Payment>> getMyPayments() async {
    try {
      final response = await _api.get<dynamic>(Endpoints.payments);

      List items;
      if (response is List) {
        items = response;
      } else if (response is Map<String, dynamic>) {
        items = response['data'] as List? ?? [];
      } else {
        items = [];
      }

      return items.map((json) => _parsePayment(json)).toList();
    } catch (e) {
      throw Exception('Error loading payments: $e');
    }
  }

  Future<Payment> processPayment({
    required String paymentId,
    required String paymentMethod,
  }) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        Endpoints.pay(paymentId),
        data: {'paymentMethod': paymentMethod},
      );
      return _parsePayment(response);
    } catch (e) {
      throw Exception('Error processing payment: $e');
    }
  }

  Future<Payment> simulatePayment({
    required String paymentId,
    required String cardholderName,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
  }) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        Endpoints.simulatePay(paymentId),
        data: {
          'cardholderName': cardholderName,
          'cardNumber': cardNumber,
          'expiryMonth': expiryMonth,
          'expiryYear': expiryYear,
          'cvv': cvv,
        },
      );
      return _parsePayment(response);
    } catch (e) {
      throw Exception('Error processing simulated payment: $e');
    }
  }

  Payment _parsePayment(Map<String, dynamic> json) {
    final childJson = json['child'] as Map<String, dynamic>?;
    final childNameFromRelation = childJson == null
        ? null
        : [
            childJson['firstName'] as String? ?? '',
            childJson['lastName'] as String? ?? '',
          ].where((part) => part.isNotEmpty).join(' ').trim();

    return Payment(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      childId: json['childId'] as String,
      childName: (json['childName'] as String?) ?? childNameFromRelation,
      concept: json['concept'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      status: PaymentStatus.fromString(json['status'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String)
          : null,
      paymentMethod: json['paymentMethod'] as String?,
      gatewayTransactionId: json['gatewayTransactionId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
