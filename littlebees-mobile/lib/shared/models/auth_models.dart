import '../enums/enums.dart';

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final UserInfo user;
  final TenantInfo tenant;
  final bool? mfaRequired;
  final String? tempToken;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.tenant,
    this.mfaRequired,
    this.tempToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
      tenant: TenantInfo.fromJson(json['tenant'] as Map<String, dynamic>),
      mfaRequired: json['mfaRequired'] as bool?,
      tempToken: json['tempToken'] as String?,
    );
  }
}

class UserInfo {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? avatarUrl;
  final UserRole role;
  final bool mfaEnabled;

  const UserInfo({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.avatarUrl,
    required this.role,
    required this.mfaEnabled,
  });

  String get fullName => '$firstName $lastName';

  UserInfo copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    bool? mfaEnabled,
  }) {
    return UserInfo(
      id: id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      mfaEnabled: mfaEnabled ?? this.mfaEnabled,
    );
  }

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: UserRole.fromString(json['role'] as String),
      mfaEnabled: json['mfaEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'role': role.value,
        'mfaEnabled': mfaEnabled,
      };
}

class TenantInfo {
  final String id;
  final String name;
  final String slug;
  final String? logoUrl;

  const TenantInfo({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
  });

  factory TenantInfo.fromJson(Map<String, dynamic> json) {
    return TenantInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      logoUrl: json['logoUrl'] as String?,
    );
  }
}

class MeResponse {
  final UserInfo user;
  final TenantInfo tenant;

  const MeResponse({required this.user, required this.tenant});

  factory MeResponse.fromJson(Map<String, dynamic> json) {
    return MeResponse(
      user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
      tenant: TenantInfo.fromJson(json['tenant'] as Map<String, dynamic>),
    );
  }
}

class JwtPayload {
  final String sub;
  final String tid;
  final UserRole role;
  final int iat;
  final int exp;

  const JwtPayload({
    required this.sub,
    required this.tid,
    required this.role,
    required this.iat,
    required this.exp,
  });

  bool get isExpired => DateTime.now().millisecondsSinceEpoch > exp * 1000;

  factory JwtPayload.fromJson(Map<String, dynamic> json) {
    return JwtPayload(
      sub: json['sub'] as String,
      tid: json['tid'] as String,
      role: UserRole.fromString(json['role'] as String),
      iat: json['iat'] as int,
      exp: json['exp'] as int,
    );
  }
}
