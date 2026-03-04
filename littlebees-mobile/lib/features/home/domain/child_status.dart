import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_status.freezed.dart';
part 'child_status.g.dart';

enum ChildPresenceStatus {
  checkedIn,    // At daycare
  checkedOut,   // Picked up
  absent,       // Not expected today
  expected,     // Expected but not yet arrived
}

@freezed
class ChildStatus with _$ChildStatus {
  const factory ChildStatus({
    required ChildPresenceStatus status,
    required DateTime? lastStatusChange,
    String? checkedInBy,
    String? checkedOutBy,
  }) = _ChildStatus;

  factory ChildStatus.fromJson(Map<String, dynamic> json) => _$ChildStatusFromJson(json);
}
