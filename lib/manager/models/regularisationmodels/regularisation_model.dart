// models/regularisationmodels/regularisation_model.dart
import 'package:flutter/material.dart';

class RegularisationRequest {
  final String id;
  final String userId;
  final String projectId;
  final DateTime date;
  final DateTime requestedDate;
  final DateTime? approvedDate;
  final RegularisationType type;
  final RegularisationStatus status;
  final String reason;
  final String? remarks;
  final String? approvedBy;
  final List<String> supportingDocs;
  final DateTime createdAt;
  final DateTime updatedAt;

  RegularisationRequest({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.date,
    required this.requestedDate,
    this.approvedDate,
    required this.type,
    required this.status,
    required this.reason,
    this.remarks,
    this.approvedBy,
    required this.supportingDocs,
    required this.createdAt,
    required this.updatedAt,
  });

  // SQLite compatible methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'project_id': projectId,
      'date': date.toIso8601String(),
      'requested_date': requestedDate.toIso8601String(),
      'approved_date': approvedDate?.toIso8601String(),
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'reason': reason,
      'remarks': remarks,
      'approved_by': approvedBy,
      'supporting_docs': supportingDocs.join('|||'),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory RegularisationRequest.fromMap(Map<String, dynamic> map) {
    return RegularisationRequest(
      id: map['id'],
      userId: map['user_id'],
      projectId: map['project_id'],
      date: DateTime.parse(map['date']),
      requestedDate: DateTime.parse(map['requested_date']),
      approvedDate: map['approved_date'] != null
          ? DateTime.parse(map['approved_date'])
          : null,
      type: RegularisationType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => RegularisationType.fullDay,
      ),
      status: RegularisationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => RegularisationStatus.pending,
      ),
      reason: map['reason'],
      remarks: map['remarks'],
      approvedBy: map['approved_by'],
      supportingDocs: (map['supporting_docs'] as String)
          .split('|||')
          .where((doc) => doc.isNotEmpty)
          .toList(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // Copy with method
  RegularisationRequest copyWith({
    String? id,
    String? userId,
    String? projectId,
    DateTime? date,
    DateTime? requestedDate,
    DateTime? approvedDate,
    RegularisationType? type,
    RegularisationStatus? status,
    String? reason,
    String? remarks,
    String? approvedBy,
    List<String>? supportingDocs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RegularisationRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      date: date ?? this.date,
      requestedDate: requestedDate ?? this.requestedDate,
      approvedDate: approvedDate ?? this.approvedDate,
      type: type ?? this.type,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      remarks: remarks ?? this.remarks,
      approvedBy: approvedBy ?? this.approvedBy,
      supportingDocs: supportingDocs ?? this.supportingDocs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == RegularisationStatus.pending;
  bool get isApproved => status == RegularisationStatus.approved;
  bool get isRejected => status == RegularisationStatus.rejected;
  bool get isCancelled => status == RegularisationStatus.cancelled;

  String get formattedDate => '${date.day}/${date.month}/${date.year}';
  String get formattedRequestDate =>
      '${requestedDate.day}/${requestedDate.month}/${requestedDate.year}';

  String get displayType {
    switch (type) {
      case RegularisationType.checkIn:
        return 'Check-in Only';
      case RegularisationType.checkOut:
        return 'Check-out Only';
      case RegularisationType.fullDay:
        return 'Full Day';
      case RegularisationType.halfDay:
        return 'Half Day';
    }
  }

  String get displayStatus {
    switch (status) {
      case RegularisationStatus.pending:
        return 'Pending Approval';
      case RegularisationStatus.approved:
        return 'Approved';
      case RegularisationStatus.rejected:
        return 'Rejected';
      case RegularisationStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (status) {
      case RegularisationStatus.pending:
        return Colors.orange;
      case RegularisationStatus.approved:
        return Colors.green;
      case RegularisationStatus.rejected:
        return Colors.red;
      case RegularisationStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case RegularisationStatus.pending:
        return Icons.pending;
      case RegularisationStatus.approved:
        return Icons.check_circle;
      case RegularisationStatus.rejected:
        return Icons.cancel;
      case RegularisationStatus.cancelled:
        return Icons.block;
    }
  }
}

enum RegularisationType { checkIn, checkOut, fullDay, halfDay }

enum RegularisationStatus { pending, approved, rejected, cancelled }

class RegularisationFormData {
  String projectId = '';
  DateTime date = DateTime.now();
  RegularisationType type = RegularisationType.fullDay;
  String reason = '';
  TimeOfDay? checkInTime;
  TimeOfDay? checkOutTime;
  List<String> supportingDocs = [];

  RegularisationFormData();

  RegularisationFormData.copy(RegularisationFormData other) {
    projectId = other.projectId;
    date = other.date;
    type = other.type;
    reason = other.reason;
    checkInTime = other.checkInTime;
    checkOutTime = other.checkOutTime;
    supportingDocs = List.from(other.supportingDocs);
  }

  bool get isValid {
    return projectId.isNotEmpty &&
        reason.isNotEmpty &&
        reason.length >= 10; // Minimum reason length
  }

  String? validate() {
    if (projectId.isEmpty) return 'Please select a project';
    if (reason.isEmpty) return 'Please provide a reason';
    if (reason.length < 10) return 'Reason should be at least 10 characters';
    return null;
  }
}
