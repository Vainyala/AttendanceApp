// models/manager_regularisation_model.dart
import 'package:AttendanceApp/manager/models/regularisationmodels/regularisation_model.dart';

import 'package:flutter/material.dart';

class ManagerRegularisationRequest {
  final String id;
  final String userId;
  final String employeeId;
  final String employeeName;
  final String employeeEmail;
  final String employeeRole;
  final String employeePhoto;
  final String projectId;
  final String projectName;
  final DateTime date;
  final DateTime requestedDate;
  final DateTime? approvedDate;
  final RegularisationType type;
  final RegularisationStatus status;
  final String reason;
  final String? managerRemarks;
  final String? approvedBy;
  final List<String> supportingDocs;
  final TimeOfDay actualCheckIn;
  final TimeOfDay actualCheckOut;
  final TimeOfDay expectedCheckIn;
  final TimeOfDay expectedCheckOut;
  final Duration shortfallTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  ManagerRegularisationRequest({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmail,
    required this.employeeRole,
    required this.employeePhoto,
    required this.projectId,
    required this.projectName,
    required this.date,
    required this.requestedDate,
    this.approvedDate,
    required this.type,
    required this.status,
    required this.reason,
    this.managerRemarks,
    this.approvedBy,
    required this.supportingDocs,
    required this.actualCheckIn,
    required this.actualCheckOut,
    required this.expectedCheckIn,
    required this.expectedCheckOut,
    required this.shortfallTime,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'employee_role': employeeRole,
      'employee_photo': employeePhoto,
      'project_id': projectId,
      'project_name': projectName,
      'date': date.toIso8601String(),
      'requested_date': requestedDate.toIso8601String(),
      'approved_date': approvedDate?.toIso8601String(),
      'type': type.toString(),
      'status': status.toString(),
      'reason': reason,
      'manager_remarks': managerRemarks,
      'approved_by': approvedBy,
      'supporting_docs': supportingDocs,
      'actual_check_in': '${actualCheckIn.hour}:${actualCheckIn.minute}',
      'actual_check_out': '${actualCheckOut.hour}:${actualCheckOut.minute}',
      'expected_check_in': '${expectedCheckIn.hour}:${expectedCheckIn.minute}',
      'expected_check_out':
          '${expectedCheckOut.hour}:${expectedCheckOut.minute}',
      'shortfall_time': shortfallTime.inMinutes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ManagerRegularisationRequest.fromMap(Map<String, dynamic> map) {
    return ManagerRegularisationRequest(
      id: map['id'],
      userId: map['user_id'],
      employeeId: map['employee_id'],
      employeeName: map['employee_name'],
      employeeEmail: map['employee_email'],
      employeeRole: map['employee_role'],
      employeePhoto: map['employee_photo'],
      projectId: map['project_id'],
      projectName: map['project_name'],
      date: DateTime.parse(map['date']),
      requestedDate: DateTime.parse(map['requested_date']),
      approvedDate: map['approved_date'] != null
          ? DateTime.parse(map['approved_date'])
          : null,
      type: RegularisationType.values.firstWhere(
        (e) => e.toString() == map['type'],
      ),
      status: RegularisationStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
      ),
      reason: map['reason'],
      managerRemarks: map['manager_remarks'],
      approvedBy: map['approved_by'],
      supportingDocs: List<String>.from(map['supporting_docs'] ?? []),
      actualCheckIn: _parseTime(map['actual_check_in']),
      actualCheckOut: _parseTime(map['actual_check_out']),
      expectedCheckIn: _parseTime(map['expected_check_in']),
      expectedCheckOut: _parseTime(map['expected_check_out']),
      shortfallTime: Duration(minutes: map['shortfall_time'] ?? 0),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  static TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  ManagerRegularisationRequest copyWith({
    String? id,
    String? userId,
    String? employeeId,
    String? employeeName,
    String? employeeRole,
    String? employeePhoto,
    String? projectId,
    String? projectName,
    DateTime? date,
    DateTime? requestedDate,
    DateTime? approvedDate,
    RegularisationType? type,
    RegularisationStatus? status,
    String? reason,
    String? managerRemarks,
    String? approvedBy,
    List<String>? supportingDocs,
    TimeOfDay? actualCheckIn,
    TimeOfDay? actualCheckOut,
    TimeOfDay? expectedCheckIn,
    TimeOfDay? expectedCheckOut,
    Duration? shortfallTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ManagerRegularisationRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      employeeEmail: employeeEmail ?? this.employeeEmail,
      employeeRole: employeeRole ?? this.employeeRole,
      employeePhoto: employeePhoto ?? this.employeePhoto,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      date: date ?? this.date,
      requestedDate: requestedDate ?? this.requestedDate,
      approvedDate: approvedDate ?? this.approvedDate,
      type: type ?? this.type,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      managerRemarks: managerRemarks ?? this.managerRemarks,
      approvedBy: approvedBy ?? this.approvedBy,
      supportingDocs: supportingDocs ?? this.supportingDocs,
      actualCheckIn: actualCheckIn ?? this.actualCheckIn,
      actualCheckOut: actualCheckOut ?? this.actualCheckOut,
      expectedCheckIn: expectedCheckIn ?? this.expectedCheckIn,
      expectedCheckOut: expectedCheckOut ?? this.expectedCheckOut,
      shortfallTime: shortfallTime ?? this.shortfallTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == RegularisationStatus.pending;
  bool get isApproved => status == RegularisationStatus.approved;
  bool get isRejected => status == RegularisationStatus.rejected;

  String get formattedDate => '${date.day}/${date.month}/${date.year}';
  String get formattedShortfallTime {
    final hours = shortfallTime.inHours;
    final minutes = shortfallTime.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}

class ManagerRegularisationStats {
  final int totalRequests;
  final int pendingRequests;
  final int approvedRequests;
  final int rejectedRequests;
  final int currentMonthRequests;

  ManagerRegularisationStats({
    required this.totalRequests,
    required this.pendingRequests,
    required this.approvedRequests,
    required this.rejectedRequests,
    required this.currentMonthRequests,
  });

  Map<String, int> toMap() {
    return {
      'total': totalRequests,
      'pending': pendingRequests,
      'approved': approvedRequests,
      'rejected': rejectedRequests,
      'current_month': currentMonthRequests,
    };
  }
}
