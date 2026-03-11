// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Group _$GroupFromJson(Map<String, dynamic> json) {
  return _Group.fromJson(json);
}

/// @nodoc
mixin _$Group {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get ageRangeMin => throw _privateConstructorUsedError;
  int get ageRangeMax => throw _privateConstructorUsedError;
  int get capacity => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  String get academicYear => throw _privateConstructorUsedError;
  String? get teacherId => throw _privateConstructorUsedError;
  String? get teacherName => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Group to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupCopyWith<Group> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupCopyWith<$Res> {
  factory $GroupCopyWith(Group value, $Res Function(Group) then) =
      _$GroupCopyWithImpl<$Res, Group>;
  @useResult
  $Res call({
    String id,
    String tenantId,
    String name,
    int ageRangeMin,
    int ageRangeMax,
    int capacity,
    String color,
    String academicYear,
    String? teacherId,
    String? teacherName,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$GroupCopyWithImpl<$Res, $Val extends Group>
    implements $GroupCopyWith<$Res> {
  _$GroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? name = null,
    Object? ageRangeMin = null,
    Object? ageRangeMax = null,
    Object? capacity = null,
    Object? color = null,
    Object? academicYear = null,
    Object? teacherId = freezed,
    Object? teacherName = freezed,
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
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            ageRangeMin: null == ageRangeMin
                ? _value.ageRangeMin
                : ageRangeMin // ignore: cast_nullable_to_non_nullable
                      as int,
            ageRangeMax: null == ageRangeMax
                ? _value.ageRangeMax
                : ageRangeMax // ignore: cast_nullable_to_non_nullable
                      as int,
            capacity: null == capacity
                ? _value.capacity
                : capacity // ignore: cast_nullable_to_non_nullable
                      as int,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String,
            academicYear: null == academicYear
                ? _value.academicYear
                : academicYear // ignore: cast_nullable_to_non_nullable
                      as String,
            teacherId: freezed == teacherId
                ? _value.teacherId
                : teacherId // ignore: cast_nullable_to_non_nullable
                      as String?,
            teacherName: freezed == teacherName
                ? _value.teacherName
                : teacherName // ignore: cast_nullable_to_non_nullable
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
abstract class _$$GroupImplCopyWith<$Res> implements $GroupCopyWith<$Res> {
  factory _$$GroupImplCopyWith(
    _$GroupImpl value,
    $Res Function(_$GroupImpl) then,
  ) = __$$GroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String tenantId,
    String name,
    int ageRangeMin,
    int ageRangeMax,
    int capacity,
    String color,
    String academicYear,
    String? teacherId,
    String? teacherName,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$GroupImplCopyWithImpl<$Res>
    extends _$GroupCopyWithImpl<$Res, _$GroupImpl>
    implements _$$GroupImplCopyWith<$Res> {
  __$$GroupImplCopyWithImpl(
    _$GroupImpl _value,
    $Res Function(_$GroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? name = null,
    Object? ageRangeMin = null,
    Object? ageRangeMax = null,
    Object? capacity = null,
    Object? color = null,
    Object? academicYear = null,
    Object? teacherId = freezed,
    Object? teacherName = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$GroupImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        ageRangeMin: null == ageRangeMin
            ? _value.ageRangeMin
            : ageRangeMin // ignore: cast_nullable_to_non_nullable
                  as int,
        ageRangeMax: null == ageRangeMax
            ? _value.ageRangeMax
            : ageRangeMax // ignore: cast_nullable_to_non_nullable
                  as int,
        capacity: null == capacity
            ? _value.capacity
            : capacity // ignore: cast_nullable_to_non_nullable
                  as int,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String,
        academicYear: null == academicYear
            ? _value.academicYear
            : academicYear // ignore: cast_nullable_to_non_nullable
                  as String,
        teacherId: freezed == teacherId
            ? _value.teacherId
            : teacherId // ignore: cast_nullable_to_non_nullable
                  as String?,
        teacherName: freezed == teacherName
            ? _value.teacherName
            : teacherName // ignore: cast_nullable_to_non_nullable
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
class _$GroupImpl implements _Group {
  const _$GroupImpl({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.ageRangeMin,
    required this.ageRangeMax,
    required this.capacity,
    required this.color,
    required this.academicYear,
    this.teacherId,
    this.teacherName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$GroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String name;
  @override
  final int ageRangeMin;
  @override
  final int ageRangeMax;
  @override
  final int capacity;
  @override
  final String color;
  @override
  final String academicYear;
  @override
  final String? teacherId;
  @override
  final String? teacherName;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Group(id: $id, tenantId: $tenantId, name: $name, ageRangeMin: $ageRangeMin, ageRangeMax: $ageRangeMax, capacity: $capacity, color: $color, academicYear: $academicYear, teacherId: $teacherId, teacherName: $teacherName, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.ageRangeMin, ageRangeMin) ||
                other.ageRangeMin == ageRangeMin) &&
            (identical(other.ageRangeMax, ageRangeMax) ||
                other.ageRangeMax == ageRangeMax) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.academicYear, academicYear) ||
                other.academicYear == academicYear) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.teacherName, teacherName) ||
                other.teacherName == teacherName) &&
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
    name,
    ageRangeMin,
    ageRangeMax,
    capacity,
    color,
    academicYear,
    teacherId,
    teacherName,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupImplCopyWith<_$GroupImpl> get copyWith =>
      __$$GroupImplCopyWithImpl<_$GroupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupImplToJson(this);
  }
}

abstract class _Group implements Group {
  const factory _Group({
    required final String id,
    required final String tenantId,
    required final String name,
    required final int ageRangeMin,
    required final int ageRangeMax,
    required final int capacity,
    required final String color,
    required final String academicYear,
    final String? teacherId,
    final String? teacherName,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$GroupImpl;

  factory _Group.fromJson(Map<String, dynamic> json) = _$GroupImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get name;
  @override
  int get ageRangeMin;
  @override
  int get ageRangeMax;
  @override
  int get capacity;
  @override
  String get color;
  @override
  String get academicYear;
  @override
  String? get teacherId;
  @override
  String? get teacherName;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupImplCopyWith<_$GroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
