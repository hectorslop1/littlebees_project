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
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  classroomId: json['classroomId'] as String,
  classroomName: json['classroomName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
  allergies: (json['allergies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  authorizedPickups: (json['authorizedPickups'] as List<dynamic>)
      .map((e) => AuthorizedPickup.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$ChildImplToJson(_$ChildImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'classroomId': instance.classroomId,
      'classroomName': instance.classroomName,
      'avatarUrl': instance.avatarUrl,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'allergies': instance.allergies,
      'authorizedPickups': instance.authorizedPickups,
    };
