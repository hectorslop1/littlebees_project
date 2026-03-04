// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AiSummary _$AiSummaryFromJson(Map<String, dynamic> json) {
  return _AiSummary.fromJson(json);
}

/// @nodoc
mixin _$AiSummary {
  String get emoji => throw _privateConstructorUsedError;
  String get headline => throw _privateConstructorUsedError;
  List<String> get bullets => throw _privateConstructorUsedError;
  DateTime get generatedAt => throw _privateConstructorUsedError;

  /// Serializes this AiSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiSummaryCopyWith<AiSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiSummaryCopyWith<$Res> {
  factory $AiSummaryCopyWith(AiSummary value, $Res Function(AiSummary) then) =
      _$AiSummaryCopyWithImpl<$Res, AiSummary>;
  @useResult
  $Res call({
    String emoji,
    String headline,
    List<String> bullets,
    DateTime generatedAt,
  });
}

/// @nodoc
class _$AiSummaryCopyWithImpl<$Res, $Val extends AiSummary>
    implements $AiSummaryCopyWith<$Res> {
  _$AiSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? emoji = null,
    Object? headline = null,
    Object? bullets = null,
    Object? generatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            emoji: null == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                      as String,
            headline: null == headline
                ? _value.headline
                : headline // ignore: cast_nullable_to_non_nullable
                      as String,
            bullets: null == bullets
                ? _value.bullets
                : bullets // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            generatedAt: null == generatedAt
                ? _value.generatedAt
                : generatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AiSummaryImplCopyWith<$Res>
    implements $AiSummaryCopyWith<$Res> {
  factory _$$AiSummaryImplCopyWith(
    _$AiSummaryImpl value,
    $Res Function(_$AiSummaryImpl) then,
  ) = __$$AiSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String emoji,
    String headline,
    List<String> bullets,
    DateTime generatedAt,
  });
}

/// @nodoc
class __$$AiSummaryImplCopyWithImpl<$Res>
    extends _$AiSummaryCopyWithImpl<$Res, _$AiSummaryImpl>
    implements _$$AiSummaryImplCopyWith<$Res> {
  __$$AiSummaryImplCopyWithImpl(
    _$AiSummaryImpl _value,
    $Res Function(_$AiSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AiSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? emoji = null,
    Object? headline = null,
    Object? bullets = null,
    Object? generatedAt = null,
  }) {
    return _then(
      _$AiSummaryImpl(
        emoji: null == emoji
            ? _value.emoji
            : emoji // ignore: cast_nullable_to_non_nullable
                  as String,
        headline: null == headline
            ? _value.headline
            : headline // ignore: cast_nullable_to_non_nullable
                  as String,
        bullets: null == bullets
            ? _value._bullets
            : bullets // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        generatedAt: null == generatedAt
            ? _value.generatedAt
            : generatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AiSummaryImpl implements _AiSummary {
  const _$AiSummaryImpl({
    required this.emoji,
    required this.headline,
    required final List<String> bullets,
    required this.generatedAt,
  }) : _bullets = bullets;

  factory _$AiSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiSummaryImplFromJson(json);

  @override
  final String emoji;
  @override
  final String headline;
  final List<String> _bullets;
  @override
  List<String> get bullets {
    if (_bullets is EqualUnmodifiableListView) return _bullets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bullets);
  }

  @override
  final DateTime generatedAt;

  @override
  String toString() {
    return 'AiSummary(emoji: $emoji, headline: $headline, bullets: $bullets, generatedAt: $generatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiSummaryImpl &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.headline, headline) ||
                other.headline == headline) &&
            const DeepCollectionEquality().equals(other._bullets, _bullets) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    emoji,
    headline,
    const DeepCollectionEquality().hash(_bullets),
    generatedAt,
  );

  /// Create a copy of AiSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiSummaryImplCopyWith<_$AiSummaryImpl> get copyWith =>
      __$$AiSummaryImplCopyWithImpl<_$AiSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiSummaryImplToJson(this);
  }
}

abstract class _AiSummary implements AiSummary {
  const factory _AiSummary({
    required final String emoji,
    required final String headline,
    required final List<String> bullets,
    required final DateTime generatedAt,
  }) = _$AiSummaryImpl;

  factory _AiSummary.fromJson(Map<String, dynamic> json) =
      _$AiSummaryImpl.fromJson;

  @override
  String get emoji;
  @override
  String get headline;
  @override
  List<String> get bullets;
  @override
  DateTime get generatedAt;

  /// Create a copy of AiSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiSummaryImplCopyWith<_$AiSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
