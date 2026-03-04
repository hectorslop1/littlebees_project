// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timeline_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MealDetails _$MealDetailsFromJson(Map<String, dynamic> json) {
  return _MealDetails.fromJson(json);
}

/// @nodoc
mixin _$MealDetails {
  MealType get mealType => throw _privateConstructorUsedError;
  MealConsumption get amount => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this MealDetails to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MealDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealDetailsCopyWith<MealDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealDetailsCopyWith<$Res> {
  factory $MealDetailsCopyWith(
    MealDetails value,
    $Res Function(MealDetails) then,
  ) = _$MealDetailsCopyWithImpl<$Res, MealDetails>;
  @useResult
  $Res call({MealType mealType, MealConsumption amount, String? notes});
}

/// @nodoc
class _$MealDetailsCopyWithImpl<$Res, $Val extends MealDetails>
    implements $MealDetailsCopyWith<$Res> {
  _$MealDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mealType = null,
    Object? amount = null,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            mealType: null == mealType
                ? _value.mealType
                : mealType // ignore: cast_nullable_to_non_nullable
                      as MealType,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as MealConsumption,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MealDetailsImplCopyWith<$Res>
    implements $MealDetailsCopyWith<$Res> {
  factory _$$MealDetailsImplCopyWith(
    _$MealDetailsImpl value,
    $Res Function(_$MealDetailsImpl) then,
  ) = __$$MealDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({MealType mealType, MealConsumption amount, String? notes});
}

/// @nodoc
class __$$MealDetailsImplCopyWithImpl<$Res>
    extends _$MealDetailsCopyWithImpl<$Res, _$MealDetailsImpl>
    implements _$$MealDetailsImplCopyWith<$Res> {
  __$$MealDetailsImplCopyWithImpl(
    _$MealDetailsImpl _value,
    $Res Function(_$MealDetailsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mealType = null,
    Object? amount = null,
    Object? notes = freezed,
  }) {
    return _then(
      _$MealDetailsImpl(
        mealType: null == mealType
            ? _value.mealType
            : mealType // ignore: cast_nullable_to_non_nullable
                  as MealType,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as MealConsumption,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MealDetailsImpl implements _MealDetails {
  const _$MealDetailsImpl({
    required this.mealType,
    required this.amount,
    this.notes,
  });

  factory _$MealDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealDetailsImplFromJson(json);

  @override
  final MealType mealType;
  @override
  final MealConsumption amount;
  @override
  final String? notes;

  @override
  String toString() {
    return 'MealDetails(mealType: $mealType, amount: $amount, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealDetailsImpl &&
            (identical(other.mealType, mealType) ||
                other.mealType == mealType) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, mealType, amount, notes);

  /// Create a copy of MealDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealDetailsImplCopyWith<_$MealDetailsImpl> get copyWith =>
      __$$MealDetailsImplCopyWithImpl<_$MealDetailsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MealDetailsImplToJson(this);
  }
}

abstract class _MealDetails implements MealDetails {
  const factory _MealDetails({
    required final MealType mealType,
    required final MealConsumption amount,
    final String? notes,
  }) = _$MealDetailsImpl;

  factory _MealDetails.fromJson(Map<String, dynamic> json) =
      _$MealDetailsImpl.fromJson;

  @override
  MealType get mealType;
  @override
  MealConsumption get amount;
  @override
  String? get notes;

  /// Create a copy of MealDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealDetailsImplCopyWith<_$MealDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NapDetails _$NapDetailsFromJson(Map<String, dynamic> json) {
  return _NapDetails.fromJson(json);
}

/// @nodoc
mixin _$NapDetails {
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  NapQuality get quality => throw _privateConstructorUsedError;

  /// Serializes this NapDetails to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NapDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NapDetailsCopyWith<NapDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NapDetailsCopyWith<$Res> {
  factory $NapDetailsCopyWith(
    NapDetails value,
    $Res Function(NapDetails) then,
  ) = _$NapDetailsCopyWithImpl<$Res, NapDetails>;
  @useResult
  $Res call({DateTime startTime, DateTime? endTime, NapQuality quality});
}

/// @nodoc
class _$NapDetailsCopyWithImpl<$Res, $Val extends NapDetails>
    implements $NapDetailsCopyWith<$Res> {
  _$NapDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NapDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startTime = null,
    Object? endTime = freezed,
    Object? quality = null,
  }) {
    return _then(
      _value.copyWith(
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: freezed == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            quality: null == quality
                ? _value.quality
                : quality // ignore: cast_nullable_to_non_nullable
                      as NapQuality,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NapDetailsImplCopyWith<$Res>
    implements $NapDetailsCopyWith<$Res> {
  factory _$$NapDetailsImplCopyWith(
    _$NapDetailsImpl value,
    $Res Function(_$NapDetailsImpl) then,
  ) = __$$NapDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime startTime, DateTime? endTime, NapQuality quality});
}

/// @nodoc
class __$$NapDetailsImplCopyWithImpl<$Res>
    extends _$NapDetailsCopyWithImpl<$Res, _$NapDetailsImpl>
    implements _$$NapDetailsImplCopyWith<$Res> {
  __$$NapDetailsImplCopyWithImpl(
    _$NapDetailsImpl _value,
    $Res Function(_$NapDetailsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NapDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startTime = null,
    Object? endTime = freezed,
    Object? quality = null,
  }) {
    return _then(
      _$NapDetailsImpl(
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: freezed == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        quality: null == quality
            ? _value.quality
            : quality // ignore: cast_nullable_to_non_nullable
                  as NapQuality,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NapDetailsImpl implements _NapDetails {
  const _$NapDetailsImpl({
    required this.startTime,
    this.endTime,
    required this.quality,
  });

  factory _$NapDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NapDetailsImplFromJson(json);

  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;
  @override
  final NapQuality quality;

  @override
  String toString() {
    return 'NapDetails(startTime: $startTime, endTime: $endTime, quality: $quality)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NapDetailsImpl &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.quality, quality) || other.quality == quality));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, startTime, endTime, quality);

  /// Create a copy of NapDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NapDetailsImplCopyWith<_$NapDetailsImpl> get copyWith =>
      __$$NapDetailsImplCopyWithImpl<_$NapDetailsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NapDetailsImplToJson(this);
  }
}

abstract class _NapDetails implements NapDetails {
  const factory _NapDetails({
    required final DateTime startTime,
    final DateTime? endTime,
    required final NapQuality quality,
  }) = _$NapDetailsImpl;

  factory _NapDetails.fromJson(Map<String, dynamic> json) =
      _$NapDetailsImpl.fromJson;

  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;
  @override
  NapQuality get quality;

  /// Create a copy of NapDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NapDetailsImplCopyWith<_$NapDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TimelineEvent _$TimelineEventFromJson(Map<String, dynamic> json) {
  return _TimelineEvent.fromJson(json);
}

/// @nodoc
mixin _$TimelineEvent {
  String get id => throw _privateConstructorUsedError;
  TimelineEventType get type => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get caregiverName => throw _privateConstructorUsedError;
  String? get caregiverAvatarUrl => throw _privateConstructorUsedError;
  List<String>? get photoUrls => throw _privateConstructorUsedError;
  MealDetails? get mealDetails => throw _privateConstructorUsedError;
  NapDetails? get napDetails => throw _privateConstructorUsedError;

  /// Serializes this TimelineEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimelineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimelineEventCopyWith<TimelineEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimelineEventCopyWith<$Res> {
  factory $TimelineEventCopyWith(
    TimelineEvent value,
    $Res Function(TimelineEvent) then,
  ) = _$TimelineEventCopyWithImpl<$Res, TimelineEvent>;
  @useResult
  $Res call({
    String id,
    TimelineEventType type,
    DateTime timestamp,
    String title,
    String? description,
    String? caregiverName,
    String? caregiverAvatarUrl,
    List<String>? photoUrls,
    MealDetails? mealDetails,
    NapDetails? napDetails,
  });

  $MealDetailsCopyWith<$Res>? get mealDetails;
  $NapDetailsCopyWith<$Res>? get napDetails;
}

/// @nodoc
class _$TimelineEventCopyWithImpl<$Res, $Val extends TimelineEvent>
    implements $TimelineEventCopyWith<$Res> {
  _$TimelineEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimelineEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? timestamp = null,
    Object? title = null,
    Object? description = freezed,
    Object? caregiverName = freezed,
    Object? caregiverAvatarUrl = freezed,
    Object? photoUrls = freezed,
    Object? mealDetails = freezed,
    Object? napDetails = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as TimelineEventType,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            caregiverName: freezed == caregiverName
                ? _value.caregiverName
                : caregiverName // ignore: cast_nullable_to_non_nullable
                      as String?,
            caregiverAvatarUrl: freezed == caregiverAvatarUrl
                ? _value.caregiverAvatarUrl
                : caregiverAvatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoUrls: freezed == photoUrls
                ? _value.photoUrls
                : photoUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            mealDetails: freezed == mealDetails
                ? _value.mealDetails
                : mealDetails // ignore: cast_nullable_to_non_nullable
                      as MealDetails?,
            napDetails: freezed == napDetails
                ? _value.napDetails
                : napDetails // ignore: cast_nullable_to_non_nullable
                      as NapDetails?,
          )
          as $Val,
    );
  }

  /// Create a copy of TimelineEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MealDetailsCopyWith<$Res>? get mealDetails {
    if (_value.mealDetails == null) {
      return null;
    }

    return $MealDetailsCopyWith<$Res>(_value.mealDetails!, (value) {
      return _then(_value.copyWith(mealDetails: value) as $Val);
    });
  }

  /// Create a copy of TimelineEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NapDetailsCopyWith<$Res>? get napDetails {
    if (_value.napDetails == null) {
      return null;
    }

    return $NapDetailsCopyWith<$Res>(_value.napDetails!, (value) {
      return _then(_value.copyWith(napDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TimelineEventImplCopyWith<$Res>
    implements $TimelineEventCopyWith<$Res> {
  factory _$$TimelineEventImplCopyWith(
    _$TimelineEventImpl value,
    $Res Function(_$TimelineEventImpl) then,
  ) = __$$TimelineEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    TimelineEventType type,
    DateTime timestamp,
    String title,
    String? description,
    String? caregiverName,
    String? caregiverAvatarUrl,
    List<String>? photoUrls,
    MealDetails? mealDetails,
    NapDetails? napDetails,
  });

  @override
  $MealDetailsCopyWith<$Res>? get mealDetails;
  @override
  $NapDetailsCopyWith<$Res>? get napDetails;
}

/// @nodoc
class __$$TimelineEventImplCopyWithImpl<$Res>
    extends _$TimelineEventCopyWithImpl<$Res, _$TimelineEventImpl>
    implements _$$TimelineEventImplCopyWith<$Res> {
  __$$TimelineEventImplCopyWithImpl(
    _$TimelineEventImpl _value,
    $Res Function(_$TimelineEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimelineEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? timestamp = null,
    Object? title = null,
    Object? description = freezed,
    Object? caregiverName = freezed,
    Object? caregiverAvatarUrl = freezed,
    Object? photoUrls = freezed,
    Object? mealDetails = freezed,
    Object? napDetails = freezed,
  }) {
    return _then(
      _$TimelineEventImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as TimelineEventType,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        caregiverName: freezed == caregiverName
            ? _value.caregiverName
            : caregiverName // ignore: cast_nullable_to_non_nullable
                  as String?,
        caregiverAvatarUrl: freezed == caregiverAvatarUrl
            ? _value.caregiverAvatarUrl
            : caregiverAvatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoUrls: freezed == photoUrls
            ? _value._photoUrls
            : photoUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        mealDetails: freezed == mealDetails
            ? _value.mealDetails
            : mealDetails // ignore: cast_nullable_to_non_nullable
                  as MealDetails?,
        napDetails: freezed == napDetails
            ? _value.napDetails
            : napDetails // ignore: cast_nullable_to_non_nullable
                  as NapDetails?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TimelineEventImpl implements _TimelineEvent {
  const _$TimelineEventImpl({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.title,
    this.description,
    this.caregiverName,
    this.caregiverAvatarUrl,
    final List<String>? photoUrls,
    this.mealDetails,
    this.napDetails,
  }) : _photoUrls = photoUrls;

  factory _$TimelineEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimelineEventImplFromJson(json);

  @override
  final String id;
  @override
  final TimelineEventType type;
  @override
  final DateTime timestamp;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String? caregiverName;
  @override
  final String? caregiverAvatarUrl;
  final List<String>? _photoUrls;
  @override
  List<String>? get photoUrls {
    final value = _photoUrls;
    if (value == null) return null;
    if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final MealDetails? mealDetails;
  @override
  final NapDetails? napDetails;

  @override
  String toString() {
    return 'TimelineEvent(id: $id, type: $type, timestamp: $timestamp, title: $title, description: $description, caregiverName: $caregiverName, caregiverAvatarUrl: $caregiverAvatarUrl, photoUrls: $photoUrls, mealDetails: $mealDetails, napDetails: $napDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimelineEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.caregiverName, caregiverName) ||
                other.caregiverName == caregiverName) &&
            (identical(other.caregiverAvatarUrl, caregiverAvatarUrl) ||
                other.caregiverAvatarUrl == caregiverAvatarUrl) &&
            const DeepCollectionEquality().equals(
              other._photoUrls,
              _photoUrls,
            ) &&
            (identical(other.mealDetails, mealDetails) ||
                other.mealDetails == mealDetails) &&
            (identical(other.napDetails, napDetails) ||
                other.napDetails == napDetails));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    timestamp,
    title,
    description,
    caregiverName,
    caregiverAvatarUrl,
    const DeepCollectionEquality().hash(_photoUrls),
    mealDetails,
    napDetails,
  );

  /// Create a copy of TimelineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimelineEventImplCopyWith<_$TimelineEventImpl> get copyWith =>
      __$$TimelineEventImplCopyWithImpl<_$TimelineEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimelineEventImplToJson(this);
  }
}

abstract class _TimelineEvent implements TimelineEvent {
  const factory _TimelineEvent({
    required final String id,
    required final TimelineEventType type,
    required final DateTime timestamp,
    required final String title,
    final String? description,
    final String? caregiverName,
    final String? caregiverAvatarUrl,
    final List<String>? photoUrls,
    final MealDetails? mealDetails,
    final NapDetails? napDetails,
  }) = _$TimelineEventImpl;

  factory _TimelineEvent.fromJson(Map<String, dynamic> json) =
      _$TimelineEventImpl.fromJson;

  @override
  String get id;
  @override
  TimelineEventType get type;
  @override
  DateTime get timestamp;
  @override
  String get title;
  @override
  String? get description;
  @override
  String? get caregiverName;
  @override
  String? get caregiverAvatarUrl;
  @override
  List<String>? get photoUrls;
  @override
  MealDetails? get mealDetails;
  @override
  NapDetails? get napDetails;

  /// Create a copy of TimelineEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimelineEventImplCopyWith<_$TimelineEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
