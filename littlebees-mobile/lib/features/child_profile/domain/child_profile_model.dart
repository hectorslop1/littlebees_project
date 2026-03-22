import 'dart:io';

class ChildProfileMedicalInfo {
  const ChildProfileMedicalInfo({
    this.allergies = const [],
    this.conditions = const [],
    this.medications = const [],
    this.bloodType,
    this.importantNotes,
    this.doctorName,
    this.doctorPhone,
  });

  final List<String> allergies;
  final List<String> conditions;
  final List<String> medications;
  final String? bloodType;
  final String? importantNotes;
  final String? doctorName;
  final String? doctorPhone;

  factory ChildProfileMedicalInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ChildProfileMedicalInfo();

    return ChildProfileMedicalInfo(
      allergies: (json['allergies'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      conditions: (json['conditions'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      medications: (json['medications'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      bloodType: json['bloodType'] as String?,
      importantNotes: json['observations'] as String?,
      doctorName: json['doctorName'] as String?,
      doctorPhone: json['doctorPhone'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'allergies': allergies,
        'conditions': conditions,
        'medications': medications,
        'bloodType': _nullIfBlank(bloodType),
        'observations': _nullIfBlank(importantNotes),
        'doctorName': _nullIfBlank(doctorName),
        'doctorPhone': _nullIfBlank(doctorPhone),
      };

  ChildProfileMedicalInfo copyWith({
    List<String>? allergies,
    List<String>? conditions,
    List<String>? medications,
    String? bloodType,
    String? importantNotes,
    String? doctorName,
    String? doctorPhone,
  }) {
    return ChildProfileMedicalInfo(
      allergies: allergies ?? this.allergies,
      conditions: conditions ?? this.conditions,
      medications: medications ?? this.medications,
      bloodType: bloodType ?? this.bloodType,
      importantNotes: importantNotes ?? this.importantNotes,
      doctorName: doctorName ?? this.doctorName,
      doctorPhone: doctorPhone ?? this.doctorPhone,
    );
  }
}

class ChildPickupContact {
  const ChildPickupContact({
    this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    this.email,
    this.photoUrl,
    this.idPhotoUrl,
    this.localPhotoFile,
    this.localIdPhotoFile,
    this.priority = 1,
  });

  final String? id;
  final String name;
  final String relationship;
  final String phone;
  final String? email;
  final String? photoUrl;
  final String? idPhotoUrl;
  final File? localPhotoFile;
  final File? localIdPhotoFile;
  final int priority;

  factory ChildPickupContact.fromJson(Map<String, dynamic> json) {
    return ChildPickupContact(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      relationship: json['relationship'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      idPhotoUrl: json['idPhotoUrl'] as String?,
      priority: json['priority'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'relationship': relationship.trim(),
        'phone': phone.trim(),
        'email': _nullIfBlank(email),
        'photoUrl': _nullIfBlank(photoUrl),
        'idPhotoUrl': _nullIfBlank(idPhotoUrl),
        'priority': priority,
      };

  ChildPickupContact copyWith({
    String? id,
    String? name,
    String? relationship,
    String? phone,
    String? email,
    String? photoUrl,
    String? idPhotoUrl,
    File? localPhotoFile,
    File? localIdPhotoFile,
    int? priority,
  }) {
    return ChildPickupContact(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      idPhotoUrl: idPhotoUrl ?? this.idPhotoUrl,
      localPhotoFile: localPhotoFile ?? this.localPhotoFile,
      localIdPhotoFile: localIdPhotoFile ?? this.localIdPhotoFile,
      priority: priority ?? this.priority,
    );
  }
}

class ChildProfileModel {
  const ChildProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.photoUrl,
    this.groupId,
    this.groupName,
    this.enrollmentDate,
    required this.status,
    required this.age,
    this.medicalInfo = const ChildProfileMedicalInfo(),
    this.pickupContacts = const [],
  });

  final String id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String? photoUrl;
  final String? groupId;
  final String? groupName;
  final DateTime? enrollmentDate;
  final String status;
  final int age;
  final ChildProfileMedicalInfo medicalInfo;
  final List<ChildPickupContact> pickupContacts;

  String get fullName => '$firstName $lastName';

  factory ChildProfileModel.fromJson(Map<String, dynamic> json) {
    return ChildProfileModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String? ?? 'male',
      photoUrl: json['photoUrl'] as String?,
      groupId: json['groupId'] as String?,
      groupName: json['groupName'] as String?,
      enrollmentDate: json['enrollmentDate'] != null
          ? DateTime.parse(json['enrollmentDate'] as String)
          : null,
      status: json['status'] as String? ?? 'active',
      age: json['age'] as int? ?? 0,
      medicalInfo: ChildProfileMedicalInfo.fromJson(
        json['medicalInfo'] as Map<String, dynamic>?,
      ),
      pickupContacts: (json['emergencyContacts'] as List<dynamic>? ?? const [])
          .map((item) => ChildPickupContact.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  ChildProfileModel copyWith({
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? gender,
    String? photoUrl,
    String? groupId,
    String? groupName,
    DateTime? enrollmentDate,
    String? status,
    int? age,
    ChildProfileMedicalInfo? medicalInfo,
    List<ChildPickupContact>? pickupContacts,
  }) {
    return ChildProfileModel(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      status: status ?? this.status,
      age: age ?? this.age,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      pickupContacts: pickupContacts ?? this.pickupContacts,
    );
  }
}

String? _nullIfBlank(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
