// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PhotoImpl _$$PhotoImplFromJson(Map<String, dynamic> json) => _$PhotoImpl(
  id: json['id'] as String,
  url: json['url'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  caption: json['caption'] as String?,
  caregiverName: json['caregiverName'] as String?,
  isLiked: json['isLiked'] as bool? ?? false,
);

Map<String, dynamic> _$$PhotoImplToJson(_$PhotoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'timestamp': instance.timestamp.toIso8601String(),
      'caption': instance.caption,
      'caregiverName': instance.caregiverName,
      'isLiked': instance.isLiked,
    };
