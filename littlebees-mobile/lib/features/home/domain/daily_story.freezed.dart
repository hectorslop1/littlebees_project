// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_story.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DailyStory _$DailyStoryFromJson(Map<String, dynamic> json) {
  return _DailyStory.fromJson(json);
}

/// @nodoc
mixin _$DailyStory {
  DateTime get date => throw _privateConstructorUsedError;
  Child get child => throw _privateConstructorUsedError;
  ChildStatus get status => throw _privateConstructorUsedError;
  List<TimelineEvent> get events => throw _privateConstructorUsedError;
  AiSummary? get aiSummary => throw _privateConstructorUsedError;

  /// Serializes this DailyStory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyStory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyStoryCopyWith<DailyStory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyStoryCopyWith<$Res> {
  factory $DailyStoryCopyWith(
    DailyStory value,
    $Res Function(DailyStory) then,
  ) = _$DailyStoryCopyWithImpl<$Res, DailyStory>;
  @useResult
  $Res call({
    DateTime date,
    Child child,
    ChildStatus status,
    List<TimelineEvent> events,
    AiSummary? aiSummary,
  });

  $ChildCopyWith<$Res> get child;
  $ChildStatusCopyWith<$Res> get status;
  $AiSummaryCopyWith<$Res>? get aiSummary;
}

/// @nodoc
class _$DailyStoryCopyWithImpl<$Res, $Val extends DailyStory>
    implements $DailyStoryCopyWith<$Res> {
  _$DailyStoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyStory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? child = null,
    Object? status = null,
    Object? events = null,
    Object? aiSummary = freezed,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            child: null == child
                ? _value.child
                : child // ignore: cast_nullable_to_non_nullable
                      as Child,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ChildStatus,
            events: null == events
                ? _value.events
                : events // ignore: cast_nullable_to_non_nullable
                      as List<TimelineEvent>,
            aiSummary: freezed == aiSummary
                ? _value.aiSummary
                : aiSummary // ignore: cast_nullable_to_non_nullable
                      as AiSummary?,
          )
          as $Val,
    );
  }

  /// Create a copy of DailyStory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChildCopyWith<$Res> get child {
    return $ChildCopyWith<$Res>(_value.child, (value) {
      return _then(_value.copyWith(child: value) as $Val);
    });
  }

  /// Create a copy of DailyStory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChildStatusCopyWith<$Res> get status {
    return $ChildStatusCopyWith<$Res>(_value.status, (value) {
      return _then(_value.copyWith(status: value) as $Val);
    });
  }

  /// Create a copy of DailyStory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AiSummaryCopyWith<$Res>? get aiSummary {
    if (_value.aiSummary == null) {
      return null;
    }

    return $AiSummaryCopyWith<$Res>(_value.aiSummary!, (value) {
      return _then(_value.copyWith(aiSummary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DailyStoryImplCopyWith<$Res>
    implements $DailyStoryCopyWith<$Res> {
  factory _$$DailyStoryImplCopyWith(
    _$DailyStoryImpl value,
    $Res Function(_$DailyStoryImpl) then,
  ) = __$$DailyStoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime date,
    Child child,
    ChildStatus status,
    List<TimelineEvent> events,
    AiSummary? aiSummary,
  });

  @override
  $ChildCopyWith<$Res> get child;
  @override
  $ChildStatusCopyWith<$Res> get status;
  @override
  $AiSummaryCopyWith<$Res>? get aiSummary;
}

/// @nodoc
class __$$DailyStoryImplCopyWithImpl<$Res>
    extends _$DailyStoryCopyWithImpl<$Res, _$DailyStoryImpl>
    implements _$$DailyStoryImplCopyWith<$Res> {
  __$$DailyStoryImplCopyWithImpl(
    _$DailyStoryImpl _value,
    $Res Function(_$DailyStoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyStory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? child = null,
    Object? status = null,
    Object? events = null,
    Object? aiSummary = freezed,
  }) {
    return _then(
      _$DailyStoryImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        child: null == child
            ? _value.child
            : child // ignore: cast_nullable_to_non_nullable
                  as Child,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ChildStatus,
        events: null == events
            ? _value._events
            : events // ignore: cast_nullable_to_non_nullable
                  as List<TimelineEvent>,
        aiSummary: freezed == aiSummary
            ? _value.aiSummary
            : aiSummary // ignore: cast_nullable_to_non_nullable
                  as AiSummary?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyStoryImpl implements _DailyStory {
  const _$DailyStoryImpl({
    required this.date,
    required this.child,
    required this.status,
    required final List<TimelineEvent> events,
    this.aiSummary,
  }) : _events = events;

  factory _$DailyStoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyStoryImplFromJson(json);

  @override
  final DateTime date;
  @override
  final Child child;
  @override
  final ChildStatus status;
  final List<TimelineEvent> _events;
  @override
  List<TimelineEvent> get events {
    if (_events is EqualUnmodifiableListView) return _events;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_events);
  }

  @override
  final AiSummary? aiSummary;

  @override
  String toString() {
    return 'DailyStory(date: $date, child: $child, status: $status, events: $events, aiSummary: $aiSummary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyStoryImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.child, child) || other.child == child) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._events, _events) &&
            (identical(other.aiSummary, aiSummary) ||
                other.aiSummary == aiSummary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    child,
    status,
    const DeepCollectionEquality().hash(_events),
    aiSummary,
  );

  /// Create a copy of DailyStory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyStoryImplCopyWith<_$DailyStoryImpl> get copyWith =>
      __$$DailyStoryImplCopyWithImpl<_$DailyStoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyStoryImplToJson(this);
  }
}

abstract class _DailyStory implements DailyStory {
  const factory _DailyStory({
    required final DateTime date,
    required final Child child,
    required final ChildStatus status,
    required final List<TimelineEvent> events,
    final AiSummary? aiSummary,
  }) = _$DailyStoryImpl;

  factory _DailyStory.fromJson(Map<String, dynamic> json) =
      _$DailyStoryImpl.fromJson;

  @override
  DateTime get date;
  @override
  Child get child;
  @override
  ChildStatus get status;
  @override
  List<TimelineEvent> get events;
  @override
  AiSummary? get aiSummary;

  /// Create a copy of DailyStory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyStoryImplCopyWith<_$DailyStoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
