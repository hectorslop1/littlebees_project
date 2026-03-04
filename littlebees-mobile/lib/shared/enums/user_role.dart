enum UserRole {
  superAdmin('super_admin'),
  director('director'),
  admin('admin'),
  teacher('teacher'),
  parent('parent');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRole.parent,
    );
  }

  bool get isStaff =>
      this == UserRole.director ||
      this == UserRole.admin ||
      this == UserRole.teacher ||
      this == UserRole.superAdmin;
}
