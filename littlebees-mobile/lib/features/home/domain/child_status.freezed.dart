// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChildStatus _$ChildStatusFromJson(Map<String, dynamic> json) {
  return _ChildStatus.fromJson(json);
}

/// @nodoc
mixin _$ChildStatus {
  ChildPresenceStatus get status => throw _privateConstructorUsedError;
  DateTime? get lastStatusChange => throw _privateConstructorUsedError;
  String? get checkedInBy => throw _privateConstructorUsedError;
  String? get checkedOutBy => throw _privateConstructorUsedError;

  /// Serializes this ChildStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChildStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChildStatusCopyWith<ChildStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChildStatusCopyWith<$Res> {
  factory $ChildStatusCopyWith(
    ChildStatus value,
    $Res Function(ChildStatus) then,
  ) = _$ChildStatusCopyWithImpl<$Res, ChildStatus>;
  @useResult
  $Res call({
    ChildPresenceStatus status,
    DateTime? lastStatusChange,
    String? checkedInBy,
    String? checkedOutBy,
  });
}

/// @nodoc
class _$ChildStatusCopyWithImpl<$Res, $Val extends ChildStatus>
    implements $ChildStatusCopyWith<$Res> {
  _$ChildStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChildStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? lastStatusChange = freezed,
    Object? checkedInBy = freezed,
    Object? checkedOutBy = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ChildPresenceStatus,
            lastStatusChange: freezed == lastStatusChange
                ? _value.lastStatusChange
                : lastStatusChange // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            checkedInBy: freezed == checkedInBy
                ? _value.checkedInBy
                : checkedInBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            checkedOutBy: freezed == checkedOutBy
                ? _value.checkedOutBy
                : checkedOutBy // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChildStatusImplCopyWith<$Res>
    implements $ChildStatusCopyWith<$Res> {
  factory _$$ChildStatusImplCopyWith(
    _$ChildStatusImpl value,
    $Res Function(_$ChildStatusImpl) then,
  ) = __$$ChildStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ChildPresenceStatus status,
    DateTime? lastStatusChange,
    String? checkedInBy,
    String? checkedOutBy,
  });
}

/// @nodoc
class __$$ChildStatusImplCopyWithImpl<$Res>
    extends _$ChildStatusCopyWithImpl<$Res, _$ChildStatusImpl>
    implements _$$ChildStatusImplCopyWith<$Res> {
  __$$ChildStatusImplCopyWithImpl(
    _$ChildStatusImpl _value,
    $Res Function(_$ChildStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChildStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? lastStatusChange = freezed,
    Object? checkedInBy = freezed,
    Object? checkedOutBy = freezed,
  }) {
    return _then(
      _$ChildStatusImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ChildPresenceStatus,
        lastStatusChange: freezed == lastStatusChange
            ? _value.lastStatusChange
            : lastStatusChange // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        checkedInBy: freezed == checkedInBy
            ? _value.checkedInBy
            : checkedInBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        checkedOutBy: freezed == checkedOutBy
            ? _value.checkedOutBy
            : checkedOutBy // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChildStatusImpl implements _ChildStatus {
  const _$ChildStatusImpl({
    required this.status,
    required this.lastStatusChange,
    this.checkedInBy,
    this.checkedOutBy,
  });

  factory _$ChildStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChildStatusImplFromJson(json);

  @override
  final ChildPresenceStatus status;
  @override
  final DateTime? lastStatusChange;
  @override
  final String? checkedInBy;
  @override
  final String? checkedOutBy;

  @override
  String toString() {
    return 'ChildStatus(status: $status, lastStatusChange: $lastStatusChange, checkedInBy: $checkedInBy, checkedOutBy: $checkedOutBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChildStatusImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.lastStatusChange, lastStatusChange) ||
                other.lastStatusChange == lastStatusChange) &&
            (identical(other.checkedInBy, checkedInBy) ||
                other.checkedInBy == checkedInBy) &&
            (identical(other.checkedOutBy, checkedOutBy) ||
                other.checkedOutBy == checkedOutBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    lastStatusChange,
    checkedInBy,
    checkedOutBy,
  );

  /// Create a copy of ChildStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChildStatusImplCopyWith<_$ChildStatusImpl> get copyWith =>
      __$$ChildStatusImplCopyWithImpl<_$ChildStatusImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChildStatusImplToJson(this);
  }
}

abstract class _ChildStatus implements ChildStatus {
  const factory _ChildStatus({
    required final ChildPresenceStatus status,
    required final DateTime? lastStatusChange,
    final String? checkedInBy,
    final String? checkedOutBy,
  }) = _$ChildStatusImpl;

  factory _ChildStatus.fromJson(Map<String, dynamic> json) =
      _$ChildStatusImpl.fromJson;

  @override
  ChildPresenceStatus get status;
  @override
  DateTime? get lastStatusChange;
  @override
  String? get checkedInBy;
  @override
  String? get checkedOutBy;

  /// Create a copy of ChildStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChildStatusImplCopyWith<_$ChildStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
