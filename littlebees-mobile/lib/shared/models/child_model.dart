import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_model.freezed.dart';
part 'child_model.g.dart';

@freezed
class AuthorizedPickup with _$AuthorizedPickup {
  const factory AuthorizedPickup({
    required String id,
    required String name,
    required String relation,
    required String? photoUrl,
    required String phone,
  }) = _AuthorizedPickup;

  factory AuthorizedPickup.fromJson(Map<String, dynamic> json) => _$AuthorizedPickupFromJson(json);
}

@freezed
class Child with _$Child {
  const factory Child({
    required String id,
    required String firstName,
    required String lastName,
    required String classroomId,
    required String classroomName,
    required String? avatarUrl,
    required DateTime dateOfBirth,
    required List<String> allergies,
    required List<AuthorizedPickup> authorizedPickups,
  }) = _Child;

  factory Child.fromJson(Map<String, dynamic> json) => _$ChildFromJson(json);
}
