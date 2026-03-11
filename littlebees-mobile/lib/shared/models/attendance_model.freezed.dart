// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AttendanceRecord _$AttendanceRecordFromJson(Map<String, dynamic> json) {
  return _AttendanceRecord.fromJson(json);
}

/// @nodoc
mixin _$AttendanceRecord {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get childId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  DateTime? get checkInAt => throw _privateConstructorUsedError;
  DateTime? get checkOutAt => throw _privateConstructorUsedError;
  String? get checkInBy => throw _privateConstructorUsedError;
  String? get checkOutBy => throw _privateConstructorUsedError;
  String? get checkInMethod => throw _privateConstructorUsedError;
  AttendanceStatus get status => throw _privateConstructorUsedError;
  String? get observations => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AttendanceRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttendanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceRecordCopyWith<AttendanceRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceRecordCopyWith<$Res> {
  factory $AttendanceRecordCopyWith(
    AttendanceRecord value,
    $Res Function(AttendanceRecord) then,
  ) = _$AttendanceRecordCopyWithImpl<$Res, AttendanceRecord>;
  @useResult
  $Res call({
    String id,
    String tenantId,
    String childId,
    DateTime date,
    DateTime? checkInAt,
    DateTime? checkOutAt,
    String? checkInBy,
    String? checkOutBy,
    String? checkInMethod,
    AttendanceStatus status,
    String? observations,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$AttendanceRecordCopyWithImpl<$Res, $Val extends AttendanceRecord>
    implements $AttendanceRecordCopyWith<$Res> {
  _$AttendanceRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttendanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? childId = null,
    Object? date = null,
    Object? checkInAt = freezed,
    Object? checkOutAt = freezed,
    Object? checkInBy = freezed,
    Object? checkOutBy = freezed,
    Object? checkInMethod = freezed,
    Object? status = null,
    Object? observations = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            tenantId: null == tenantId
                ? _value.tenantId
                : tenantId // ignore: cast_nullable_to_non_nullable
                      as String,
            childId: null == childId
                ? _value.childId
                : childId // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            checkInAt: freezed == checkInAt
                ? _value.checkInAt
                : checkInAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            checkOutAt: freezed == checkOutAt
                ? _value.checkOutAt
                : checkOutAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            checkInBy: freezed == checkInBy
                ? _value.checkInBy
                : checkInBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            checkOutBy: freezed == checkOutBy
                ? _value.checkOutBy
                : checkOutBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            checkInMethod: freezed == checkInMethod
                ? _value.checkInMethod
                : checkInMethod // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as AttendanceStatus,
            observations: freezed == observations
                ? _value.observations
                : observations // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AttendanceRecordImplCopyWith<$Res>
    implements $AttendanceRecordCopyWith<$Res> {
  factory _$$AttendanceRecordImplCopyWith(
    _$AttendanceRecordImpl value,
    $Res Function(_$AttendanceRecordImpl) then,
  ) = __$$AttendanceRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String tenantId,
    String childId,
    DateTime date,
    DateTime? checkInAt,
    DateTime? checkOutAt,
    String? checkInBy,
    String? checkOutBy,
    String? checkInMethod,
    AttendanceStatus status,
    String? observations,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$AttendanceRecordImplCopyWithImpl<$Res>
    extends _$AttendanceRecordCopyWithImpl<$Res, _$AttendanceRecordImpl>
    implements _$$AttendanceRecordImplCopyWith<$Res> {
  __$$AttendanceRecordImplCopyWithImpl(
    _$AttendanceRecordImpl _value,
    $Res Function(_$AttendanceRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttendanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? childId = null,
    Object? date = null,
    Object? checkInAt = freezed,
    Object? checkOutAt = freezed,
    Object? checkInBy = freezed,
    Object? checkOutBy = freezed,
    Object? checkInMethod = freezed,
    Object? status = null,
    Object? observations = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$AttendanceRecordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        childId: null == childId
            ? _value.childId
            : childId // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        checkInAt: freezed == checkInAt
            ? _value.checkInAt
            : checkInAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        checkOutAt: freezed == checkOutAt
            ? _value.checkOutAt
            : checkOutAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        checkInBy: freezed == checkInBy
            ? _value.checkInBy
            : checkInBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        checkOutBy: freezed == checkOutBy
            ? _value.checkOutBy
            : checkOutBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        checkInMethod: freezed == checkInMethod
            ? _value.checkInMethod
            : checkInMethod // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as AttendanceStatus,
        observations: freezed == observations
            ? _value.observations
            : observations // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AttendanceRecordImpl implements _AttendanceRecord {
  const _$AttendanceRecordImpl({
    required this.id,
    required this.tenantId,
    required this.childId,
    required this.date,
    this.checkInAt,
    this.checkOutAt,
    this.checkInBy,
    this.checkOutBy,
    this.checkInMethod,
    required this.status,
    this.observations,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$AttendanceRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttendanceRecordImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String childId;
  @override
  final DateTime date;
  @override
  final DateTime? checkInAt;
  @override
  final DateTime? checkOutAt;
  @override
  final String? checkInBy;
  @override
  final String? checkOutBy;
  @override
  final String? checkInMethod;
  @override
  final AttendanceStatus status;
  @override
  final String? observations;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'AttendanceRecord(id: $id, tenantId: $tenantId, childId: $childId, date: $date, checkInAt: $checkInAt, checkOutAt: $checkOutAt, checkInBy: $checkInBy, checkOutBy: $checkOutBy, checkInMethod: $checkInMethod, status: $status, observations: $observations, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.checkInAt, checkInAt) ||
                other.checkInAt == checkInAt) &&
            (identical(other.checkOutAt, checkOutAt) ||
                other.checkOutAt == checkOutAt) &&
            (identical(other.checkInBy, checkInBy) ||
                other.checkInBy == checkInBy) &&
            (identical(other.checkOutBy, checkOutBy) ||
                other.checkOutBy == checkOutBy) &&
            (identical(other.checkInMethod, checkInMethod) ||
                other.checkInMethod == checkInMethod) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.observations, observations) ||
                other.observations == observations) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    tenantId,
    childId,
    date,
    checkInAt,
    checkOutAt,
    checkInBy,
    checkOutBy,
    checkInMethod,
    status,
    observations,
    createdAt,
    updatedAt,
  );

  /// Create a copy of AttendanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceRecordImplCopyWith<_$AttendanceRecordImpl> get copyWith =>
      __$$AttendanceRecordImplCopyWithImpl<_$AttendanceRecordImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AttendanceRecordImplToJson(this);
  }
}

abstract class _AttendanceRecord implements AttendanceRecord {
  const factory _AttendanceRecord({
    required final String id,
    required final String tenantId,
    required final String childId,
    required final DateTime date,
    final DateTime? checkInAt,
    final DateTime? checkOutAt,
    final String? checkInBy,
    final String? checkOutBy,
    final String? checkInMethod,
    required final AttendanceStatus status,
    final String? observations,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$AttendanceRecordImpl;

  factory _AttendanceRecord.fromJson(Map<String, dynamic> json) =
      _$AttendanceRecordImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get childId;
  @override
  DateTime get date;
  @override
  DateTime? get checkInAt;
  @override
  DateTime? get checkOutAt;
  @override
  String? get checkInBy;
  @override
  String? get checkOutBy;
  @override
  String? get checkInMethod;
  @override
  AttendanceStatus get status;
  @override
  String? get observations;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of AttendanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceRecordImplCopyWith<_$AttendanceRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
