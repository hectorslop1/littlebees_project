// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupImpl _$$GroupImplFromJson(Map<String, dynamic> json) => _$GroupImpl(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  name: json['name'] as String,
  ageRangeMin: (json['ageRangeMin'] as num).toInt(),
  ageRangeMax: (json['ageRangeMax'] as num).toInt(),
  capacity: (json['capacity'] as num).toInt(),
  color: json['color'] as String,
  academicYear: json['academicYear'] as String,
  teacherId: json['teacherId'] as String?,
  teacherName: json['teacherName'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$GroupImplToJson(_$GroupImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'name': instance.name,
      'ageRangeMin': instance.ageRangeMin,
      'ageRangeMax': instance.ageRangeMax,
      'capacity': instance.capacity,
      'color': instance.color,
      'academicYear': instance.academicYear,
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
