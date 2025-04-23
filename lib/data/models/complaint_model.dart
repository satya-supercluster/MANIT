class Complaint {
  final String id;
  final String complaintNumber;
  final String studentId;
  final String studentName;
  final String hostelNumber;
  final String roomNumber;
  final String complaintType;
  final String complaintSubType;
  final String description;
  final String dateReported;
  final List<String> attachments;
  final bool assigned;
  final String? assignedTo;
  final String? assignedBy;
  final String status;
  final bool processed;
  final String? processedBy;
  final String? processingFeedback;
  final bool resolved;
  final String? resolvedBy;
  final String? resolvingFeedback;
  final bool rejected;
  final String? rejectedBy;
  final String? rejectingFeedback;
  final bool isStudentFeedback;
  final String? studentFeedback;
  final String createdAt;

  Complaint({
    required this.id,
    required this.complaintNumber,
    required this.studentId,
    required this.studentName,
    required this.hostelNumber,
    required this.roomNumber,
    required this.complaintType,
    required this.complaintSubType,
    required this.description,
    required this.dateReported,
    this.attachments = const [],
    this.assigned = false,
    this.assignedTo,
    this.assignedBy,
    required this.status,
    this.processed = false,
    this.processedBy,
    this.processingFeedback,
    this.resolved = false,
    this.resolvedBy,
    this.resolvingFeedback,
    this.rejected = false,
    this.rejectedBy,
    this.rejectingFeedback,
    this.isStudentFeedback = false,
    this.studentFeedback,
    required this.createdAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['_id'] ?? '',
      complaintNumber: json['complaintNumber'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      hostelNumber: json['hostelNumber'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      complaintType: json['complaintType'] ?? '',
      complaintSubType: json['complaintSubType'] ?? '',
      description: json['description'] ?? '',
      dateReported: json['dateReported'] ?? '',
      attachments: List<String>.from(json['attachments'] ?? []),
      assigned: json['assigned'] ?? false,
      assignedTo: json['assignedTo']?.toString(),
      assignedBy: json['assignedBy']?.toString(),
      status: json['status'] ?? 'open',
      processed: json['processed'] ?? false,
      processedBy: json['processedBy']?.toString(),
      processingFeedback: json['processingFeedback'],
      resolved: json['resolved'] ?? false,
      resolvedBy: json['resolvedBy']?.toString(),
      resolvingFeedback: json['resolvingFeedback'],
      rejected: json['rejected'] ?? false,
      rejectedBy: json['rejectedBy']?.toString(),
      rejectingFeedback: json['rejectingFeedback'],
      isStudentFeedback: json['isStudentFeedback'] ?? false,
      studentFeedback: json['studentFeedback'],
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'complaintNumber': complaintNumber,
      'studentId': studentId,
      'studentName': studentName,
      'hostelNumber': hostelNumber,
      'roomNumber': roomNumber,
      'complaintType': complaintType,
      'complaintSubType': complaintSubType,
      'description': description,
      'dateReported': dateReported,
      'attachments': attachments,
      'assigned': assigned,
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
      'status': status,
      'processed': processed,
      'processedBy': processedBy,
      'processingFeedback': processingFeedback,
      'resolved': resolved,
      'resolvedBy': resolvedBy,
      'resolvingFeedback': resolvingFeedback,
      'rejected': rejected,
      'rejectedBy': rejectedBy,
      'rejectingFeedback': rejectingFeedback,
      'isStudentFeedback': isStudentFeedback,
      'studentFeedback': studentFeedback,
      'createdAt': createdAt,
    };
  }
}