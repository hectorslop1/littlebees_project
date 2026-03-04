// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChildStatusImpl _$$ChildStatusImplFromJson(Map<String, dynamic> json) =>
    _$ChildStatusImpl(
      status: $enumDecode(_$ChildPresenceStatusEnumMap, json['status']),
      lastStatusChange: json['lastStatusChange'] == null
          ? null
          : DateTime.parse(json['lastStatusChange'] as String),
      checkedInBy: json['checkedInBy'] as String?,
      checkedOutBy: json['checkedOutBy'] as String?,
    );

Map<String, dynamic> _$$ChildStatusImplToJson(_$ChildStatusImpl instance) =>
    <String, dynamic>{
      'status': _$ChildPresenceStatusEnumMap[instance.status]!,
      'lastStatusChange': instance.lastStatusChange?.toIso8601String(),
      'checkedInBy': instance.checkedInBy,
      'checkedOutBy': instance.checkedOutBy,
    };

const _$ChildPresenceStatusEnumMap = {
  ChildPresenceStatus.checkedIn: 'checkedIn',
  ChildPresenceStatus.checkedOut: 'checkedOut',
  ChildPresenceStatus.absent: 'absent',
  ChildPresenceStatus.expected: 'expected',
};
