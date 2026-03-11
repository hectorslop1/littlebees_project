// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      childId: json['childId'] as String,
      childName: json['childName'] as String?,
      concept: json['concept'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
      dueDate: DateTime.parse(json['dueDate'] as String),
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      paymentMethod: json['paymentMethod'] as String?,
      gatewayTransactionId: json['gatewayTransactionId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PaymentImplToJson(_$PaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'childId': instance.childId,
      'childName': instance.childName,
      'concept': instance.concept,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'dueDate': instance.dueDate.toIso8601String(),
      'paidAt': instance.paidAt?.toIso8601String(),
      'paymentMethod': instance.paymentMethod,
      'gatewayTransactionId': instance.gatewayTransactionId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.paid: 'paid',
  PaymentStatus.overdue: 'overdue',
  PaymentStatus.cancelled: 'cancelled',
};
