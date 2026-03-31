import '../enums/enums.dart';

class Excuse {
  final String id;
  final String tenantId;
  final String childId;
  final String childName;
  final String submittedBy;
  final String submittedByName;
  final ExcuseType type;
  final String title;
  final String? description;
  final DateTime date;
  final ExcuseStatus status;
  final String? reviewedBy;
  final String? reviewedByName;
  final DateTime? reviewedAt;
  final String? reviewNotes;
  final List<String>? attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  Excuse({
    required this.id,
    required this.tenantId,
    required this.childId,
    required this.childName,
    required this.submittedBy,
    required this.submittedByName,
    required this.type,
    required this.title,
    this.description,
    required this.date,
    required this.status,
    this.reviewedBy,
    this.reviewedByName,
    this.reviewedAt,
    this.reviewNotes,
    this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Excuse.fromJson(Map<String, dynamic> json) {
    return Excuse(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      childId: json['childId'] as String,
      childName: json['childName'] as String? ?? '',
      submittedBy: json['submittedBy'] as String,
      submittedByName: json['submittedByName'] as String? ?? '',
      type: ExcuseType.fromString(json['type'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      status: ExcuseStatus.fromString(json['status'] as String),
      reviewedBy: json['reviewedBy'] as String?,
      reviewedByName: json['reviewedByName'] as String?,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      reviewNotes: json['reviewNotes'] as String?,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'] as List)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'childId': childId,
      'childName': childName,
      'submittedBy': submittedBy,
      'submittedByName': submittedByName,
      'type': type.value,
      'title': title,
      'description': description,
      'date': date.toIso8601String().split('T')[0],
      'status': status.value,
      'reviewedBy': reviewedBy,
      'reviewedByName': reviewedByName,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewNotes': reviewNotes,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isPending => status == ExcuseStatus.pending;
  bool get isApproved => status == ExcuseStatus.approved;
  bool get isRejected => status == ExcuseStatus.rejected;
  
  String get statusLabel {
    switch (status) {
      case ExcuseStatus.pending:
        return 'Pendiente';
      case ExcuseStatus.approved:
        return 'Aprobado';
      case ExcuseStatus.rejected:
        return 'Rechazado';
    }
  }
  
  String get typeLabel {
    switch (type) {
      case ExcuseType.sick:
        return 'Enfermedad';
      case ExcuseType.medical:
        return 'Cita médica';
      case ExcuseType.family:
        return 'Asunto familiar';
      case ExcuseType.travel:
        return 'Viaje';
      case ExcuseType.lateArrival:
        return 'Retardo';
      case ExcuseType.other:
        return 'Otro';
    }
  }
}
