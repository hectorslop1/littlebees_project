// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttendanceRecordImpl _$$AttendanceRecordImplFromJson(
  Map<String, dynamic> json,
) => _$AttendanceRecordImpl(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  childId: json['childId'] as String,
  date: DateTime.parse(json['date'] as String),
  checkInAt: json['checkInAt'] == null
      ? null
      : DateTime.parse(json['checkInAt'] as String),
  checkOutAt: json['checkOutAt'] == null
      ? null
      : DateTime.parse(json['checkOutAt'] as String),
  checkInBy: json['checkInBy'] as String?,
  checkOutBy: json['checkOutBy'] as String?,
  checkInMethod: json['checkInMethod'] as String?,
  status: $enumDecode(_$AttendanceStatusEnumMap, json['status']),
  observations: json['observations'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$AttendanceRecordImplToJson(
  _$AttendanceRecordImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  'childId': instance.childId,
  'date': instance.date.toIso8601String(),
  'checkInAt': instance.checkInAt?.toIso8601String(),
  'checkOutAt': instance.checkOutAt?.toIso8601String(),
  'checkInBy': instance.checkInBy,
  'checkOutBy': instance.checkOutBy,
  'checkInMethod': instance.checkInMethod,
  'status': _$AttendanceStatusEnumMap[instance.status]!,
  'observations': instance.observations,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.present: 'present',
  AttendanceStatus.absent: 'absent',
  AttendanceStatus.late_: 'late_',
  AttendanceStatus.excused: 'excused',
};
