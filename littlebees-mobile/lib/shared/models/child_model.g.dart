// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthorizedPickupImpl _$$AuthorizedPickupImplFromJson(
  Map<String, dynamic> json,
) => _$AuthorizedPickupImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  relation: json['relation'] as String,
  photoUrl: json['photoUrl'] as String?,
  phone: json['phone'] as String,
);

Map<String, dynamic> _$$AuthorizedPickupImplToJson(
  _$AuthorizedPickupImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'relation': instance.relation,
  'photoUrl': instance.photoUrl,
  'phone': instance.phone,
};

_$ChildImpl _$$ChildImplFromJson(Map<String, dynamic> json) => _$ChildImpl(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
  gender: json['gender'] as String,
  photoUrl: json['photoUrl'] as String?,
  groupId: json['groupId'] as String?,
  groupName: json['groupName'] as String?,
  enrollmentDate: json['enrollmentDate'] == null
      ? null
      : DateTime.parse(json['enrollmentDate'] as String),
  status: json['status'] as String,
  qrCodeHash: json['qrCodeHash'] as String?,
  allergies: (json['allergies'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  conditions: (json['conditions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  medications: (json['medications'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  bloodType: json['bloodType'] as String?,
  authorizedPickups: (json['authorizedPickups'] as List<dynamic>?)
      ?.map((e) => AuthorizedPickup.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$ChildImplToJson(_$ChildImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'gender': instance.gender,
      'photoUrl': instance.photoUrl,
      'groupId': instance.groupId,
      'groupName': instance.groupName,
      'enrollmentDate': instance.enrollmentDate?.toIso8601String(),
      'status': instance.status,
      'qrCodeHash': instance.qrCodeHash,
      'allergies': instance.allergies,
      'conditions': instance.conditions,
      'medications': instance.medications,
      'bloodType': instance.bloodType,
      'authorizedPickups': instance.authorizedPickups,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
