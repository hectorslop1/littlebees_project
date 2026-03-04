// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AuthorizedPickup _$AuthorizedPickupFromJson(Map<String, dynamic> json) {
  return _AuthorizedPickup.fromJson(json);
}

/// @nodoc
mixin _$AuthorizedPickup {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get relation => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;

  /// Serializes this AuthorizedPickup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthorizedPickup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthorizedPickupCopyWith<AuthorizedPickup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthorizedPickupCopyWith<$Res> {
  factory $AuthorizedPickupCopyWith(
    AuthorizedPickup value,
    $Res Function(AuthorizedPickup) then,
  ) = _$AuthorizedPickupCopyWithImpl<$Res, AuthorizedPickup>;
  @useResult
  $Res call({
    String id,
    String name,
    String relation,
    String? photoUrl,
    String phone,
  });
}

/// @nodoc
class _$AuthorizedPickupCopyWithImpl<$Res, $Val extends AuthorizedPickup>
    implements $AuthorizedPickupCopyWith<$Res> {
  _$AuthorizedPickupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthorizedPickup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? relation = null,
    Object? photoUrl = freezed,
    Object? phone = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            relation: null == relation
                ? _value.relation
                : relation // ignore: cast_nullable_to_non_nullable
                      as String,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuthorizedPickupImplCopyWith<$Res>
    implements $AuthorizedPickupCopyWith<$Res> {
  factory _$$AuthorizedPickupImplCopyWith(
    _$AuthorizedPickupImpl value,
    $Res Function(_$AuthorizedPickupImpl) then,
  ) = __$$AuthorizedPickupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String relation,
    String? photoUrl,
    String phone,
  });
}

/// @nodoc
class __$$AuthorizedPickupImplCopyWithImpl<$Res>
    extends _$AuthorizedPickupCopyWithImpl<$Res, _$AuthorizedPickupImpl>
    implements _$$AuthorizedPickupImplCopyWith<$Res> {
  __$$AuthorizedPickupImplCopyWithImpl(
    _$AuthorizedPickupImpl _value,
    $Res Function(_$AuthorizedPickupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthorizedPickup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? relation = null,
    Object? photoUrl = freezed,
    Object? phone = null,
  }) {
    return _then(
      _$AuthorizedPickupImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        relation: null == relation
            ? _value.relation
            : relation // ignore: cast_nullable_to_non_nullable
                  as String,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthorizedPickupImpl implements _AuthorizedPickup {
  const _$AuthorizedPickupImpl({
    required this.id,
    required this.name,
    required this.relation,
    required this.photoUrl,
    required this.phone,
  });

  factory _$AuthorizedPickupImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthorizedPickupImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String relation;
  @override
  final String? photoUrl;
  @override
  final String phone;

  @override
  String toString() {
    return 'AuthorizedPickup(id: $id, name: $name, relation: $relation, photoUrl: $photoUrl, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthorizedPickupImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.relation, relation) ||
                other.relation == relation) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.phone, phone) || other.phone == phone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, relation, photoUrl, phone);

  /// Create a copy of AuthorizedPickup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthorizedPickupImplCopyWith<_$AuthorizedPickupImpl> get copyWith =>
      __$$AuthorizedPickupImplCopyWithImpl<_$AuthorizedPickupImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthorizedPickupImplToJson(this);
  }
}

abstract class _AuthorizedPickup implements AuthorizedPickup {
  const factory _AuthorizedPickup({
    required final String id,
    required final String name,
    required final String relation,
    required final String? photoUrl,
    required final String phone,
  }) = _$AuthorizedPickupImpl;

  factory _AuthorizedPickup.fromJson(Map<String, dynamic> json) =
      _$AuthorizedPickupImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get relation;
  @override
  String? get photoUrl;
  @override
  String get phone;

  /// Create a copy of AuthorizedPickup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthorizedPickupImplCopyWith<_$AuthorizedPickupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Child _$ChildFromJson(Map<String, dynamic> json) {
  return _Child.fromJson(json);
}

/// @nodoc
mixin _$Child {
  String get id => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String get classroomId => throw _privateConstructorUsedError;
  String get classroomName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  DateTime get dateOfBirth => throw _privateConstructorUsedError;
  List<String> get allergies => throw _privateConstructorUsedError;
  List<AuthorizedPickup> get authorizedPickups =>
      throw _privateConstructorUsedError;

  /// Serializes this Child to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Child
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChildCopyWith<Child> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChildCopyWith<$Res> {
  factory $ChildCopyWith(Child value, $Res Function(Child) then) =
      _$ChildCopyWithImpl<$Res, Child>;
  @useResult
  $Res call({
    String id,
    String firstName,
    String lastName,
    String classroomId,
    String classroomName,
    String? avatarUrl,
    DateTime dateOfBirth,
    List<String> allergies,
    List<AuthorizedPickup> authorizedPickups,
  });
}

/// @nodoc
class _$ChildCopyWithImpl<$Res, $Val extends Child>
    implements $ChildCopyWith<$Res> {
  _$ChildCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Child
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? classroomId = null,
    Object? classroomName = null,
    Object? avatarUrl = freezed,
    Object? dateOfBirth = null,
    Object? allergies = null,
    Object? authorizedPickups = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            firstName: null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String,
            lastName: null == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String,
            classroomId: null == classroomId
                ? _value.classroomId
                : classroomId // ignore: cast_nullable_to_non_nullable
                      as String,
            classroomName: null == classroomName
                ? _value.classroomName
                : classroomName // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateOfBirth: null == dateOfBirth
                ? _value.dateOfBirth
                : dateOfBirth // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            allergies: null == allergies
                ? _value.allergies
                : allergies // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            authorizedPickups: null == authorizedPickups
                ? _value.authorizedPickups
                : authorizedPickups // ignore: cast_nullable_to_non_nullable
                      as List<AuthorizedPickup>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChildImplCopyWith<$Res> implements $ChildCopyWith<$Res> {
  factory _$$ChildImplCopyWith(
    _$ChildImpl value,
    $Res Function(_$ChildImpl) then,
  ) = __$$ChildImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String firstName,
    String lastName,
    String classroomId,
    String classroomName,
    String? avatarUrl,
    DateTime dateOfBirth,
    List<String> allergies,
    List<AuthorizedPickup> authorizedPickups,
  });
}

/// @nodoc
class __$$ChildImplCopyWithImpl<$Res>
    extends _$ChildCopyWithImpl<$Res, _$ChildImpl>
    implements _$$ChildImplCopyWith<$Res> {
  __$$ChildImplCopyWithImpl(
    _$ChildImpl _value,
    $Res Function(_$ChildImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Child
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? classroomId = null,
    Object? classroomName = null,
    Object? avatarUrl = freezed,
    Object? dateOfBirth = null,
    Object? allergies = null,
    Object? authorizedPickups = null,
  }) {
    return _then(
      _$ChildImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        firstName: null == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String,
        lastName: null == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String,
        classroomId: null == classroomId
            ? _value.classroomId
            : classroomId // ignore: cast_nullable_to_non_nullable
                  as String,
        classroomName: null == classroomName
            ? _value.classroomName
            : classroomName // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateOfBirth: null == dateOfBirth
            ? _value.dateOfBirth
            : dateOfBirth // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        allergies: null == allergies
            ? _value._allergies
            : allergies // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        authorizedPickups: null == authorizedPickups
            ? _value._authorizedPickups
            : authorizedPickups // ignore: cast_nullable_to_non_nullable
                  as List<AuthorizedPickup>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChildImpl implements _Child {
  const _$ChildImpl({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.classroomId,
    required this.classroomName,
    required this.avatarUrl,
    required this.dateOfBirth,
    required final List<String> allergies,
    required final List<AuthorizedPickup> authorizedPickups,
  }) : _allergies = allergies,
       _authorizedPickups = authorizedPickups;

  factory _$ChildImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChildImplFromJson(json);

  @override
  final String id;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String classroomId;
  @override
  final String classroomName;
  @override
  final String? avatarUrl;
  @override
  final DateTime dateOfBirth;
  final List<String> _allergies;
  @override
  List<String> get allergies {
    if (_allergies is EqualUnmodifiableListView) return _allergies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allergies);
  }

  final List<AuthorizedPickup> _authorizedPickups;
  @override
  List<AuthorizedPickup> get authorizedPickups {
    if (_authorizedPickups is EqualUnmodifiableListView)
      return _authorizedPickups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_authorizedPickups);
  }

  @override
  String toString() {
    return 'Child(id: $id, firstName: $firstName, lastName: $lastName, classroomId: $classroomId, classroomName: $classroomName, avatarUrl: $avatarUrl, dateOfBirth: $dateOfBirth, allergies: $allergies, authorizedPickups: $authorizedPickups)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChildImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.classroomId, classroomId) ||
                other.classroomId == classroomId) &&
            (identical(other.classroomName, classroomName) ||
                other.classroomName == classroomName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            const DeepCollectionEquality().equals(
              other._allergies,
              _allergies,
            ) &&
            const DeepCollectionEquality().equals(
              other._authorizedPickups,
              _authorizedPickups,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    firstName,
    lastName,
    classroomId,
    classroomName,
    avatarUrl,
    dateOfBirth,
    const DeepCollectionEquality().hash(_allergies),
    const DeepCollectionEquality().hash(_authorizedPickups),
  );

  /// Create a copy of Child
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChildImplCopyWith<_$ChildImpl> get copyWith =>
      __$$ChildImplCopyWithImpl<_$ChildImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChildImplToJson(this);
  }
}

abstract class _Child implements Child {
  const factory _Child({
    required final String id,
    required final String firstName,
    required final String lastName,
    required final String classroomId,
    required final String classroomName,
    required final String? avatarUrl,
    required final DateTime dateOfBirth,
    required final List<String> allergies,
    required final List<AuthorizedPickup> authorizedPickups,
  }) = _$ChildImpl;

  factory _Child.fromJson(Map<String, dynamic> json) = _$ChildImpl.fromJson;

  @override
  String get id;
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  String get classroomId;
  @override
  String get classroomName;
  @override
  String? get avatarUrl;
  @override
  DateTime get dateOfBirth;
  @override
  List<String> get allergies;
  @override
  List<AuthorizedPickup> get authorizedPickups;

  /// Create a copy of Child
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChildImplCopyWith<_$ChildImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
