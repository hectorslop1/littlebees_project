import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_model.freezed.dart';
part 'photo_model.g.dart';

@freezed
class Photo with _$Photo {
  const factory Photo({
    required String id,
    required String url,
    required DateTime timestamp,
    String? caption,
    String? caregiverName,
    @Default(false) bool isLiked,
  }) = _Photo;

  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);
}
