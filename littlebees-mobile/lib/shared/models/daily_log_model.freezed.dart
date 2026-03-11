// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_log_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DailyLogEntry _$DailyLogEntryFromJson(Map<String, dynamic> json) {
  return _DailyLogEntry.fromJson(json);
}

/// @nodoc
mixin _$DailyLogEntry {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get childId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  LogType get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get time => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  String? get recordedBy => throw _privateConstructorUsedError;
  String? get recordedByName => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this DailyLogEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyLogEntryCopyWith<DailyLogEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyLogEntryCopyWith<$Res> {
  factory $DailyLogEntryCopyWith(
    DailyLogEntry value,
    $Res Function(DailyLogEntry) then,
  ) = _$DailyLogEntryCopyWithImpl<$Res, DailyLogEntry>;
  @useResult
  $Res call({
    String id,
    String tenantId,
    String childId,
    DateTime date,
    LogType type,
    String title,
    String? description,
    String? time,
    Map<String, dynamic>? metadata,
    String? recordedBy,
    String? recordedByName,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$DailyLogEntryCopyWithImpl<$Res, $Val extends DailyLogEntry>
    implements $DailyLogEntryCopyWith<$Res> {
  _$DailyLogEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? childId = null,
    Object? date = null,
    Object? type = null,
    Object? title = null,
    Object? description = freezed,
    Object? time = freezed,
    Object? metadata = freezed,
    Object? recordedBy = freezed,
    Object? recordedByName = freezed,
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
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as LogType,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            time: freezed == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            recordedBy: freezed == recordedBy
                ? _value.recordedBy
                : recordedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            recordedByName: freezed == recordedByName
                ? _value.recordedByName
                : recordedByName // ignore: cast_nullable_to_non_nullable
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
abstract class _$$DailyLogEntryImplCopyWith<$Res>
    implements $DailyLogEntryCopyWith<$Res> {
  factory _$$DailyLogEntryImplCopyWith(
    _$DailyLogEntryImpl value,
    $Res Function(_$DailyLogEntryImpl) then,
  ) = __$$DailyLogEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String tenantId,
    String childId,
    DateTime date,
    LogType type,
    String title,
    String? description,
    String? time,
    Map<String, dynamic>? metadata,
    String? recordedBy,
    String? recordedByName,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$DailyLogEntryImplCopyWithImpl<$Res>
    extends _$DailyLogEntryCopyWithImpl<$Res, _$DailyLogEntryImpl>
    implements _$$DailyLogEntryImplCopyWith<$Res> {
  __$$DailyLogEntryImplCopyWithImpl(
    _$DailyLogEntryImpl _value,
    $Res Function(_$DailyLogEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? childId = null,
    Object? date = null,
    Object? type = null,
    Object? title = null,
    Object? description = freezed,
    Object? time = freezed,
    Object? metadata = freezed,
    Object? recordedBy = freezed,
    Object? recordedByName = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$DailyLogEntryImpl(
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
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as LogType,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        time: freezed == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        recordedBy: freezed == recordedBy
            ? _value.recordedBy
            : recordedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        recordedByName: freezed == recordedByName
            ? _value.recordedByName
            : recordedByName // ignore: cast_nullable_to_non_nullable
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
class _$DailyLogEntryImpl implements _DailyLogEntry {
  const _$DailyLogEntryImpl({
    required this.id,
    required this.tenantId,
    required this.childId,
    required this.date,
    required this.type,
    required this.title,
    this.description,
    this.time,
    final Map<String, dynamic>? metadata,
    this.recordedBy,
    this.recordedByName,
    required this.createdAt,
    required this.updatedAt,
  }) : _metadata = metadata;

  factory _$DailyLogEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyLogEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String childId;
  @override
  final DateTime date;
  @override
  final LogType type;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String? time;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? recordedBy;
  @override
  final String? recordedByName;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'DailyLogEntry(id: $id, tenantId: $tenantId, childId: $childId, date: $date, type: $type, title: $title, description: $description, time: $time, metadata: $metadata, recordedBy: $recordedBy, recordedByName: $recordedByName, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyLogEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.time, time) || other.time == time) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.recordedBy, recordedBy) ||
                other.recordedBy == recordedBy) &&
            (identical(other.recordedByName, recordedByName) ||
                other.recordedByName == recordedByName) &&
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
    type,
    title,
    description,
    time,
    const DeepCollectionEquality().hash(_metadata),
    recordedBy,
    recordedByName,
    createdAt,
    updatedAt,
  );

  /// Create a copy of DailyLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyLogEntryImplCopyWith<_$DailyLogEntryImpl> get copyWith =>
      __$$DailyLogEntryImplCopyWithImpl<_$DailyLogEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyLogEntryImplToJson(this);
  }
}

abstract class _DailyLogEntry implements DailyLogEntry {
  const factory _DailyLogEntry({
    required final String id,
    required final String tenantId,
    required final String childId,
    required final DateTime date,
    required final LogType type,
    required final String title,
    final String? description,
    final String? time,
    final Map<String, dynamic>? metadata,
    final String? recordedBy,
    final String? recordedByName,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$DailyLogEntryImpl;

  factory _DailyLogEntry.fromJson(Map<String, dynamic> json) =
      _$DailyLogEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get childId;
  @override
  DateTime get date;
  @override
  LogType get type;
  @override
  String get title;
  @override
  String? get description;
  @override
  String? get time;
  @override
  Map<String, dynamic>? get metadata;
  @override
  String? get recordedBy;
  @override
  String? get recordedByName;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of DailyLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyLogEntryImplCopyWith<_$DailyLogEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
