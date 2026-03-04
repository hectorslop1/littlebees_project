// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Photo _$PhotoFromJson(Map<String, dynamic> json) {
  return _Photo.fromJson(json);
}

/// @nodoc
mixin _$Photo {
  String get id => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get caption => throw _privateConstructorUsedError;
  String? get caregiverName => throw _privateConstructorUsedError;
  bool get isLiked => throw _privateConstructorUsedError;

  /// Serializes this Photo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoCopyWith<Photo> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoCopyWith<$Res> {
  factory $PhotoCopyWith(Photo value, $Res Function(Photo) then) =
      _$PhotoCopyWithImpl<$Res, Photo>;
  @useResult
  $Res call({
    String id,
    String url,
    DateTime timestamp,
    String? caption,
    String? caregiverName,
    bool isLiked,
  });
}

/// @nodoc
class _$PhotoCopyWithImpl<$Res, $Val extends Photo>
    implements $PhotoCopyWith<$Res> {
  _$PhotoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? timestamp = null,
    Object? caption = freezed,
    Object? caregiverName = freezed,
    Object? isLiked = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            caption: freezed == caption
                ? _value.caption
                : caption // ignore: cast_nullable_to_non_nullable
                      as String?,
            caregiverName: freezed == caregiverName
                ? _value.caregiverName
                : caregiverName // ignore: cast_nullable_to_non_nullable
                      as String?,
            isLiked: null == isLiked
                ? _value.isLiked
                : isLiked // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PhotoImplCopyWith<$Res> implements $PhotoCopyWith<$Res> {
  factory _$$PhotoImplCopyWith(
    _$PhotoImpl value,
    $Res Function(_$PhotoImpl) then,
  ) = __$$PhotoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String url,
    DateTime timestamp,
    String? caption,
    String? caregiverName,
    bool isLiked,
  });
}

/// @nodoc
class __$$PhotoImplCopyWithImpl<$Res>
    extends _$PhotoCopyWithImpl<$Res, _$PhotoImpl>
    implements _$$PhotoImplCopyWith<$Res> {
  __$$PhotoImplCopyWithImpl(
    _$PhotoImpl _value,
    $Res Function(_$PhotoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? timestamp = null,
    Object? caption = freezed,
    Object? caregiverName = freezed,
    Object? isLiked = null,
  }) {
    return _then(
      _$PhotoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        caption: freezed == caption
            ? _value.caption
            : caption // ignore: cast_nullable_to_non_nullable
                  as String?,
        caregiverName: freezed == caregiverName
            ? _value.caregiverName
            : caregiverName // ignore: cast_nullable_to_non_nullable
                  as String?,
        isLiked: null == isLiked
            ? _value.isLiked
            : isLiked // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PhotoImpl implements _Photo {
  const _$PhotoImpl({
    required this.id,
    required this.url,
    required this.timestamp,
    this.caption,
    this.caregiverName,
    this.isLiked = false,
  });

  factory _$PhotoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhotoImplFromJson(json);

  @override
  final String id;
  @override
  final String url;
  @override
  final DateTime timestamp;
  @override
  final String? caption;
  @override
  final String? caregiverName;
  @override
  @JsonKey()
  final bool isLiked;

  @override
  String toString() {
    return 'Photo(id: $id, url: $url, timestamp: $timestamp, caption: $caption, caregiverName: $caregiverName, isLiked: $isLiked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.caregiverName, caregiverName) ||
                other.caregiverName == caregiverName) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    url,
    timestamp,
    caption,
    caregiverName,
    isLiked,
  );

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoImplCopyWith<_$PhotoImpl> get copyWith =>
      __$$PhotoImplCopyWithImpl<_$PhotoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhotoImplToJson(this);
  }
}

abstract class _Photo implements Photo {
  const factory _Photo({
    required final String id,
    required final String url,
    required final DateTime timestamp,
    final String? caption,
    final String? caregiverName,
    final bool isLiked,
  }) = _$PhotoImpl;

  factory _Photo.fromJson(Map<String, dynamic> json) = _$PhotoImpl.fromJson;

  @override
  String get id;
  @override
  String get url;
  @override
  DateTime get timestamp;
  @override
  String? get caption;
  @override
  String? get caregiverName;
  @override
  bool get isLiked;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoImplCopyWith<_$PhotoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
