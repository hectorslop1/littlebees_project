class ManagedParentUser {
  const ManagedParentUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.avatarUrl,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? avatarUrl;

  String get fullName => '$firstName $lastName'.trim();

  factory ManagedParentUser.fromJson(Map<String, dynamic> json) {
    return ManagedParentUser(
      id: json['id'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

class ParentChildOption {
  const ParentChildOption({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    this.groupName,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final String? groupName;

  String get fullName => '$firstName $lastName'.trim();

  factory ParentChildOption.fromJson(Map<String, dynamic> json) {
    final group = json['group'];
    return ParentChildOption(
      id: json['id'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      groupName:
          json['groupName'] as String? ??
          (group is Map<String, dynamic> ? group['name'] as String? : null),
    );
  }
}
