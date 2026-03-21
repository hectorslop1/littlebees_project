class ChatContact {
  const ChatContact({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.category,
    required this.childIds,
    required this.childNames,
    required this.groupIds,
    required this.groupNames,
    this.avatarUrl,
  });

  final String userId;
  final String firstName;
  final String lastName;
  final String role;
  final String category;
  final String? avatarUrl;
  final List<String> childIds;
  final List<String> childNames;
  final List<String> groupIds;
  final List<String> groupNames;

  String get displayName => '$firstName $lastName'.trim();

  factory ChatContact.fromJson(Map<String, dynamic> json) {
    return ChatContact(
      userId: json['userId'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      role: json['role'] as String? ?? 'teacher',
      category: json['category'] as String? ?? 'teachers',
      avatarUrl: json['avatarUrl'] as String?,
      childIds: List<String>.from(json['childIds'] as List? ?? const []),
      childNames: List<String>.from(json['childNames'] as List? ?? const []),
      groupIds: List<String>.from(json['groupIds'] as List? ?? const []),
      groupNames: List<String>.from(json['groupNames'] as List? ?? const []),
    );
  }
}
