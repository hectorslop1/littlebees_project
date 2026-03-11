import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/enums.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

@freezed
class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String tenantId,
    required String childId,
    String? childName,
    required String concept,
    required double amount,
    required String currency,
    required PaymentStatus status,
    required DateTime dueDate,
    DateTime? paidAt,
    String? paymentMethod,
    String? gatewayTransactionId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}
