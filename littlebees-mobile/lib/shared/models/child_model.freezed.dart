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
  String get tenantId => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  DateTime get dateOfBirth => throw _privateConstructorUsedError;
  String get gender => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  String? get groupId => throw _privateConstructorUsedError;
  String? get groupName => throw _privateConstructorUsedError;
  DateTime? get enrollmentDate => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get qrCodeHash => throw _privateConstructorUsedError;
  List<String>? get allergies => throw _privateConstructorUsedError;
  List<String>? get conditions => throw _privateConstructorUsedError;
  List<String>? get medications => throw _privateConstructorUsedError;
  String? get bloodType => throw _privateConstructorUsedError;
  List<AuthorizedPickup>? get authorizedPickups =>
      throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

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
    String tenantId,
    String firstName,
    String lastName,
    DateTime dateOfBirth,
    String gender,
    String? photoUrl,
    String? groupId,
    String? groupName,
    DateTime? enrollmentDate,
    String status,
    String? qrCodeHash,
    List<String>? allergies,
    List<String>? conditions,
    List<String>? medications,
    String? bloodType,
    List<AuthorizedPickup>? authorizedPickups,
    DateTime createdAt,
    DateTime updatedAt,
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
    Object? tenantId = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? dateOfBirth = null,
    Object? gender = null,
    Object? photoUrl = freezed,
    Object? groupId = freezed,
    Object? groupName = freezed,
    Object? enrollmentDate = freezed,
    Object? status = null,
    Object? qrCodeHash = freezed,
    Object? allergies = freezed,
    Object? conditions = freezed,
    Object? medications = freezed,
    Object? bloodType = freezed,
    Object? authorizedPickups = freezed,
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
            firstName: null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String,
            lastName: null == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String,
            dateOfBirth: null == dateOfBirth
                ? _value.dateOfBirth
                : dateOfBirth // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            gender: null == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            groupId: freezed == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                      as String?,
            groupName: freezed == groupName
                ? _value.groupName
                : groupName // ignore: cast_nullable_to_non_nullable
                      as String?,
            enrollmentDate: freezed == enrollmentDate
                ? _value.enrollmentDate
                : enrollmentDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            qrCodeHash: freezed == qrCodeHash
                ? _value.qrCodeHash
                : qrCodeHash // ignore: cast_nullable_to_non_nullable
                      as String?,
            allergies: freezed == allergies
                ? _value.allergies
                : allergies // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            conditions: freezed == conditions
                ? _value.conditions
                : conditions // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            medications: freezed == medications
                ? _value.medications
                : medications // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            bloodType: freezed == bloodType
                ? _value.bloodType
                : bloodType // ignore: cast_nullable_to_non_nullable
                      as String?,
            authorizedPickups: freezed == authorizedPickups
                ? _value.authorizedPickups
                : authorizedPickups // ignore: cast_nullable_to_non_nullable
                      as List<AuthorizedPickup>?,
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
abstract class _$$ChildImplCopyWith<$Res> implements $ChildCopyWith<$Res> {
  factory _$$ChildImplCopyWith(
    _$ChildImpl value,
    $Res Function(_$ChildImpl) then,
  ) = __$$ChildImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String tenantId,
    String firstName,
    String lastName,
    DateTime dateOfBirth,
    String gender,
    String? photoUrl,
    String? groupId,
    String? groupName,
    DateTime? enrollmentDate,
    String status,
    String? qrCodeHash,
    List<String>? allergies,
    List<String>? conditions,
    List<String>? medications,
    String? bloodType,
    List<AuthorizedPickup>? authorizedPickups,
    DateTime createdAt,
    DateTime updatedAt,
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
    Object? tenantId = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? dateOfBirth = null,
    Object? gender = null,
    Object? photoUrl = freezed,
    Object? groupId = freezed,
    Object? groupName = freezed,
    Object? enrollmentDate = freezed,
    Object? status = null,
    Object? qrCodeHash = freezed,
    Object? allergies = freezed,
    Object? conditions = freezed,
    Object? medications = freezed,
    Object? bloodType = freezed,
    Object? authorizedPickups = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ChildImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        firstName: null == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String,
        lastName: null == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String,
        dateOfBirth: null == dateOfBirth
            ? _value.dateOfBirth
            : dateOfBirth // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        gender: null == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        groupId: freezed == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as String?,
        groupName: freezed == groupName
            ? _value.groupName
            : groupName // ignore: cast_nullable_to_non_nullable
                  as String?,
        enrollmentDate: freezed == enrollmentDate
            ? _value.enrollmentDate
            : enrollmentDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        qrCodeHash: freezed == qrCodeHash
            ? _value.qrCodeHash
            : qrCodeHash // ignore: cast_nullable_to_non_nullable
                  as String?,
        allergies: freezed == allergies
            ? _value._allergies
            : allergies // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        conditions: freezed == conditions
            ? _value._conditions
            : conditions // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        medications: freezed == medications
            ? _value._medications
            : medications // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        bloodType: freezed == bloodType
            ? _value.bloodType
            : bloodType // ignore: cast_nullable_to_non_nullable
                  as String?,
        authorizedPickups: freezed == authorizedPickups
            ? _value._authorizedPickups
            : authorizedPickups // ignore: cast_nullable_to_non_nullable
                  as List<AuthorizedPickup>?,
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
class _$ChildImpl implements _Child {
  const _$ChildImpl({
    required this.id,
    required this.tenantId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.photoUrl,
    this.groupId,
    this.groupName,
    this.enrollmentDate,
    required this.status,
    this.qrCodeHash,
    final List<String>? allergies,
    final List<String>? conditions,
    final List<String>? medications,
    this.bloodType,
    final List<AuthorizedPickup>? authorizedPickups,
    required this.createdAt,
    required this.updatedAt,
  }) : _allergies = allergies,
       _conditions = conditions,
       _medications = medications,
       _authorizedPickups = authorizedPickups;

  factory _$ChildImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChildImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final DateTime dateOfBirth;
  @override
  final String gender;
  @override
  final String? photoUrl;
  @override
  final String? groupId;
  @override
  final String? groupName;
  @override
  final DateTime? enrollmentDate;
  @override
  final String status;
  @override
  final String? qrCodeHash;
  final List<String>? _allergies;
  @override
  List<String>? get allergies {
    final value = _allergies;
    if (value == null) return null;
    if (_allergies is EqualUnmodifiableListView) return _allergies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _conditions;
  @override
  List<String>? get conditions {
    final value = _conditions;
    if (value == null) return null;
    if (_conditions is EqualUnmodifiableListView) return _conditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _medications;
  @override
  List<String>? get medications {
    final value = _medications;
    if (value == null) return null;
    if (_medications is EqualUnmodifiableListView) return _medications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? bloodType;
  final List<AuthorizedPickup>? _authorizedPickups;
  @override
  List<AuthorizedPickup>? get authorizedPickups {
    final value = _authorizedPickups;
    if (value == null) return null;
    if (_authorizedPickups is EqualUnmodifiableListView)
      return _authorizedPickups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Child(id: $id, tenantId: $tenantId, firstName: $firstName, lastName: $lastName, dateOfBirth: $dateOfBirth, gender: $gender, photoUrl: $photoUrl, groupId: $groupId, groupName: $groupName, enrollmentDate: $enrollmentDate, status: $status, qrCodeHash: $qrCodeHash, allergies: $allergies, conditions: $conditions, medications: $medications, bloodType: $bloodType, authorizedPickups: $authorizedPickups, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChildImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.groupName, groupName) ||
                other.groupName == groupName) &&
            (identical(other.enrollmentDate, enrollmentDate) ||
                other.enrollmentDate == enrollmentDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.qrCodeHash, qrCodeHash) ||
                other.qrCodeHash == qrCodeHash) &&
            const DeepCollectionEquality().equals(
              other._allergies,
              _allergies,
            ) &&
            const DeepCollectionEquality().equals(
              other._conditions,
              _conditions,
            ) &&
            const DeepCollectionEquality().equals(
              other._medications,
              _medications,
            ) &&
            (identical(other.bloodType, bloodType) ||
                other.bloodType == bloodType) &&
            const DeepCollectionEquality().equals(
              other._authorizedPickups,
              _authorizedPickups,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    tenantId,
    firstName,
    lastName,
    dateOfBirth,
    gender,
    photoUrl,
    groupId,
    groupName,
    enrollmentDate,
    status,
    qrCodeHash,
    const DeepCollectionEquality().hash(_allergies),
    const DeepCollectionEquality().hash(_conditions),
    const DeepCollectionEquality().hash(_medications),
    bloodType,
    const DeepCollectionEquality().hash(_authorizedPickups),
    createdAt,
    updatedAt,
  ]);

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
    required final String tenantId,
    required final String firstName,
    required final String lastName,
    required final DateTime dateOfBirth,
    required final String gender,
    final String? photoUrl,
    final String? groupId,
    final String? groupName,
    final DateTime? enrollmentDate,
    required final String status,
    final String? qrCodeHash,
    final List<String>? allergies,
    final List<String>? conditions,
    final List<String>? medications,
    final String? bloodType,
    final List<AuthorizedPickup>? authorizedPickups,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$ChildImpl;

  factory _Child.fromJson(Map<String, dynamic> json) = _$ChildImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  DateTime get dateOfBirth;
  @override
  String get gender;
  @override
  String? get photoUrl;
  @override
  String? get groupId;
  @override
  String? get groupName;
  @override
  DateTime? get enrollmentDate;
  @override
  String get status;
  @override
  String? get qrCodeHash;
  @override
  List<String>? get allergies;
  @override
  List<String>? get conditions;
  @override
  List<String>? get medications;
  @override
  String? get bloodType;
  @override
  List<AuthorizedPickup>? get authorizedPickups;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Child
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChildImplCopyWith<_$ChildImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
