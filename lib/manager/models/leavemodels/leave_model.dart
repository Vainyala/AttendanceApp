// models/leavemodels/leave_model.dart
import 'package:flutter/foundation.dart';

enum LeaveType {
  casual,
  sick,
  earned,
  maternity,
  paternity,
  compensatory,
  unpaid,
  emergency,
}

enum LeaveStatus {
  pending,
  approved,
  rejected,
  cancelled,
  query, // Added query status
}

class LeaveApplication {
  final int? id;
  final String employeeId;
  final String employeeName;
  final String employeeRole;
  final String employeeEmail;
  final String employeePhone;
  final String employeePhoto;
  final String projectName; // Changed from 'project' to match database
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays; // Added totalDays
  final String reason;
  final LeaveStatus status;
  final String?
  managerRemarks; // Changed from managerComments to match database
  final String? approvedBy;
  final DateTime appliedDate;
  final DateTime? approvedDate;
  final List<String> supportingDocs;
  final String contactNumber;
  final String handoverPersonName;
  final String handoverPersonEmail;
  final String handoverPersonPhone;
  final String handoverPersonPhoto;

  LeaveApplication({
    this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeeRole,
    required this.employeeEmail,
    required this.employeePhone,
    required this.employeePhoto,
    required this.projectName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    this.status = LeaveStatus.pending,
    this.managerRemarks,
    this.approvedBy,
    required this.appliedDate,
    this.approvedDate,
    this.supportingDocs = const [],
    required this.contactNumber,
    required this.handoverPersonName,
    required this.handoverPersonEmail,
    required this.handoverPersonPhone,
    required this.handoverPersonPhoto,
  });

  // Helper getters for convenience
  bool get isPending => status == LeaveStatus.pending;
  bool get isApproved => status == LeaveStatus.approved;
  bool get isRejected => status == LeaveStatus.rejected;
  bool get isQuery => status == LeaveStatus.query;

  String get duration {
    final difference = endDate.difference(startDate).inDays + 1;
    return '$difference day${difference > 1 ? 's' : ''}';
  }

  String get formattedDates {
    return '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}';
  }

  String get appliedDateTime {
    return '${appliedDate.day}/${appliedDate.month}/${appliedDate.year} at ${appliedDate.hour}:${appliedDate.minute.toString().padLeft(2, '0')}';
  }

  bool get isCurrentMonth {
    final now = DateTime.now();
    return appliedDate.month == now.month && appliedDate.year == now.year;
  }

  String get leaveTypeString {
    switch (leaveType) {
      case LeaveType.casual:
        return 'Casual Leave';
      case LeaveType.sick:
        return 'Sick Leave';
      case LeaveType.earned:
        return 'Earned Leave';
      case LeaveType.maternity:
        return 'Maternity Leave';
      case LeaveType.paternity:
        return 'Paternity Leave';
      case LeaveType.compensatory:
        return 'Compensatory Leave';
      case LeaveType.unpaid:
        return 'Unpaid Leave';
      case LeaveType.emergency:
        return 'Emergency Leave';
    }
  }

  String get statusString {
    switch (status) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
      case LeaveStatus.cancelled:
        return 'Cancelled';
      case LeaveStatus.query:
        return 'Query';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'employee_role': employeeRole,
      'employee_email': employeeEmail,
      'employee_phone': employeePhone,
      'employee_photo': employeePhoto,
      'project_name': projectName,
      'leave_type': leaveType.toString().split('.').last,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate.millisecondsSinceEpoch,
      'total_days': totalDays,
      'reason': reason,
      'status': status.toString().split('.').last,
      'manager_remarks': managerRemarks,
      'approved_by': approvedBy,
      'applied_date': appliedDate.millisecondsSinceEpoch,
      'approved_date': approvedDate?.millisecondsSinceEpoch,
      'supporting_docs': supportingDocs.join(','),
      'contact_number': contactNumber,
      'handover_person_name': handoverPersonName,
      'handover_person_email': handoverPersonEmail,
      'handover_person_phone': handoverPersonPhone,
      'handover_person_photo': handoverPersonPhoto,
    };
  }

  // factory LeaveApplication.fromMap(Map<String, dynamic> map) {
  //   return LeaveApplication(
  //     id: map['id'],
  //     employeeId: map['employee_id'],
  //     employeeName: map['employee_name'],
  //     employeeRole: map['employee_role'],
  //     employeeEmail: map['employee_email'],
  //     employeePhone: map['employee_phone'],
  //     employeePhoto: map['employee_photo'] ?? '',
  //     projectName: map['project_name'],
  //     leaveType: _parseLeaveType(map['leave_type']),
  //     startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date']),
  //     endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date']),
  //     totalDays: map['total_days'],
  //     reason: map['reason'],
  //     status: _parseLeaveStatus(map['status']),
  //     managerRemarks: map['manager_remarks'],
  //     approvedBy: map['approved_by'],
  //     appliedDate: DateTime.fromMillisecondsSinceEpoch(map['applied_date']),
  //     approvedDate: map['approved_date'] != null
  //         ? DateTime.fromMillisecondsSinceEpoch(map['approved_date'])
  //         : null,
  //     supportingDocs: (map['supporting_docs'] as String?)?.split(',') ?? [],
  //     contactNumber: map['contact_number'],
  //     handoverPersonName: map['handover_person_name'],
  //     handoverPersonEmail: map['handover_person_email'],
  //     handoverPersonPhone: map['handover_person_phone'],
  //     handoverPersonPhoto: map['handover_person_photo'] ?? '',
  //   );
  // }

  // models/leavemodels/leave_model.dart

  factory LeaveApplication.fromMap(Map<String, dynamic> map) {
    print('🔍 Parsing map: $map'); // Debug line

    return LeaveApplication(
      id: map['id'],
      employeeId: map['employee_id']?.toString() ?? '',
      employeeName: map['employee_name']?.toString() ?? '',
      employeeRole: map['employee_role']?.toString() ?? '',
      employeeEmail: map['employee_email']?.toString() ?? '',
      employeePhone: map['employee_phone']?.toString() ?? '',
      employeePhoto: map['employee_photo']?.toString() ?? '',
      projectName: map['project_name']?.toString() ?? '',
      leaveType: _parseLeaveType(map['leave_type']?.toString() ?? 'casual'),
      startDate: DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(map['start_date']?.toString() ?? '0') ?? 0,
      ),
      endDate: DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(map['end_date']?.toString() ?? '0') ?? 0,
      ),
      totalDays:
          int.tryParse(map['total_days']?.toString() ?? '0') ??
          0, // YEH LINE FIX KARO
      reason: map['reason']?.toString() ?? '',
      status: _parseLeaveStatus(map['status']?.toString() ?? 'pending'),
      managerRemarks: map['manager_remarks']?.toString(),
      approvedBy: map['approved_by']?.toString(),
      appliedDate: DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(map['applied_date']?.toString() ?? '0') ?? 0,
      ),
      approvedDate: map['approved_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(map['approved_date']?.toString() ?? '0') ?? 0,
            )
          : null,
      supportingDocs: (map['supporting_docs']?.toString() ?? '').split(','),
      contactNumber: map['contact_number']?.toString() ?? '',
      handoverPersonName: map['handover_person_name']?.toString() ?? '',
      handoverPersonEmail: map['handover_person_email']?.toString() ?? '',
      handoverPersonPhone: map['handoverPerson_phone']?.toString() ?? '',
      handoverPersonPhoto: map['handover_person_photo']?.toString() ?? '',
    );
  }

  static LeaveType _parseLeaveType(String type) {
    switch (type) {
      case 'casual':
        return LeaveType.casual;
      case 'sick':
        return LeaveType.sick;
      case 'earned':
        return LeaveType.earned;
      case 'maternity':
        return LeaveType.maternity;
      case 'paternity':
        return LeaveType.paternity;
      case 'compensatory':
        return LeaveType.compensatory;
      case 'unpaid':
        return LeaveType.unpaid;
      case 'emergency':
        return LeaveType.emergency;
      default:
        return LeaveType.casual;
    }
  }

  static LeaveStatus _parseLeaveStatus(String status) {
    switch (status) {
      case 'pending':
        return LeaveStatus.pending;
      case 'approved':
        return LeaveStatus.approved;
      case 'rejected':
        return LeaveStatus.rejected;
      case 'cancelled':
        return LeaveStatus.cancelled;
      case 'query':
        return LeaveStatus.query;
      default:
        return LeaveStatus.pending;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaveApplication &&
        other.id == id &&
        other.employeeId == employeeId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    return Object.hash(id, employeeId, startDate, endDate);
  }

  @override
  String toString() {
    return 'LeaveApplication(id: $id, employee: $employeeName, type: $leaveType, status: $status)';
  }
}

// Additional classes for the leave system
class LeaveStats {
  final int totalRequests;
  final int pendingRequests;
  final int approvedRequests;
  final int rejectedRequests;
  final int currentMonthRequests;

  LeaveStats({
    required this.totalRequests,
    required this.pendingRequests,
    required this.approvedRequests,
    required this.rejectedRequests,
    required this.currentMonthRequests,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalRequests': totalRequests,
      'pendingRequests': pendingRequests,
      'approvedRequests': approvedRequests,
      'rejectedRequests': rejectedRequests,
      'currentMonthRequests': currentMonthRequests,
    };
  }

  factory LeaveStats.fromMap(Map<String, dynamic> map) {
    return LeaveStats(
      totalRequests: map['totalRequests'],
      pendingRequests: map['pendingRequests'],
      approvedRequests: map['approvedRequests'],
      rejectedRequests: map['rejectedRequests'],
      currentMonthRequests: map['currentMonthRequests'],
    );
  }
}

enum LeaveFilter {
  all,
  pending,
  approved,
  rejected,
  query,
  team,
} //add team only not functionaly

class LeaveBalance {
  final int? id;
  final String employeeId;
  final LeaveType leaveType;
  final int totalDays;
  final int usedDays;
  final int year;

  LeaveBalance({
    this.id,
    required this.employeeId,
    required this.leaveType,
    required this.totalDays,
    required this.usedDays,
    required this.year,
  });

  int get availableDays => totalDays - usedDays;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'leaveType': leaveType.toString().split('.').last,
      'totalDays': totalDays,
      'usedDays': usedDays,
      'year': year,
    };
  }

  factory LeaveBalance.fromMap(Map<String, dynamic> map) {
    return LeaveBalance(
      id: map['id'],
      employeeId: map['employeeId'],
      leaveType: LeaveApplication._parseLeaveType(map['leaveType']),
      totalDays: map['totalDays'],
      usedDays: map['usedDays'],
      year: map['year'],
    );
  }
}

// // models/leave_application.dart
// class LeaveApplication {
//   final int? id;
//   final String employeeName;
//   final String employeeId;
//   final String employeeRole;
//   final String employeeEmail;
//   final String employeePhone;
//   final String employeePhoto;
//   final String project;
//   final String leaveType;
//   final DateTime startDate;
//   final DateTime endDate;
//   final String reason;
//   final String status; // 'pending', 'approved', 'rejected', 'query'
//   final DateTime appliedDate;
//   final String? managerComments;
//   final String handoverPersonName;
//   final String handoverPersonEmail;
//   final String handoverPersonPhone;
//   final String handoverPersonPhoto;

//   LeaveApplication({
//     this.id,
//     required this.employeeName,
//     required this.employeeId,
//     required this.employeeRole,
//     required this.employeeEmail,
//     required this.employeePhone,
//     required this.employeePhoto,
//     required this.project,
//     required this.leaveType,
//     required this.startDate,
//     required this.endDate,
//     required this.reason,
//     this.status = 'pending',
//     required this.appliedDate,
//     this.managerComments,
//     required this.handoverPersonName,
//     required this.handoverPersonEmail,
//     required this.handoverPersonPhone,
//     required this.handoverPersonPhoto,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'employeeName': employeeName,
//       'employeeId': employeeId,
//       'employeeRole': employeeRole,
//       'employeeEmail': employeeEmail,
//       'employeePhone': employeePhone,
//       'employeePhoto': employeePhoto,
//       'project': project,
//       'leaveType': leaveType,
//       'startDate': startDate.millisecondsSinceEpoch,
//       'endDate': endDate.millisecondsSinceEpoch,
//       'reason': reason,
//       'status': status,
//       'appliedDate': appliedDate.millisecondsSinceEpoch,
//       'managerComments': managerComments,
//       'handoverPersonName': handoverPersonName,
//       'handoverPersonEmail': handoverPersonEmail,
//       'handoverPersonPhone': handoverPersonPhone,
//       'handoverPersonPhoto': handoverPersonPhoto,
//     };
//   }

//   factory LeaveApplication.fromMap(Map<String, dynamic> map) {
//     return LeaveApplication(
//       id: map['id'],
//       employeeName: map['employeeName'],
//       employeeId: map['employeeId'],
//       employeeRole: map['employeeRole'],
//       employeeEmail: map['employeeEmail'],
//       employeePhone: map['employeePhone'],
//       employeePhoto: map['employeePhoto'],
//       project: map['project'],
//       leaveType: map['leaveType'],
//       startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
//       endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
//       reason: map['reason'],
//       status: map['status'],
//       appliedDate: DateTime.fromMillisecondsSinceEpoch(map['appliedDate']),
//       managerComments: map['managerComments'],
//       handoverPersonName: map['handoverPersonName'],
//       handoverPersonEmail: map['handoverPersonEmail'],
//       handoverPersonPhone: map['handoverPersonPhone'],
//       handoverPersonPhoto: map['handoverPersonPhoto'],
//     );
//   }

//   String get duration {
//     final difference = endDate.difference(startDate).inDays + 1;
//     return '$difference day${difference > 1 ? 's' : ''}';
//   }

//   String get formattedDates {
//     return '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}';
//   }

//   String get appliedDateTime {
//     return '${appliedDate.day}/${appliedDate.month}/${appliedDate.year} at ${appliedDate.hour}:${appliedDate.minute.toString().padLeft(2, '0')}';
//   }

//   bool get isCurrentMonth {
//     final now = DateTime.now();
//     return appliedDate.month == now.month && appliedDate.year == now.year;
//   }
// }
