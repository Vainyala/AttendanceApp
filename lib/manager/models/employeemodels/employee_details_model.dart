import '../attendance_model.dart'; // Import existing AttendanceRecord


class EmployeeDetails {
  final String id;
  final String name;
  final String email;
  final String position;
  final String department;
  final String profileImage;
  final DateTime joinDate;
  final String employeeId;
  final ContactInfo contactInfo;
  final List<AttendanceRecord> attendanceHistory;
  final PerformanceMetrics performance;

  EmployeeDetails({
    required this.id,
    required this.name,
    required this.email,
    required this.position,
    required this.department,
    required this.profileImage,
    required this.joinDate,
    required this.employeeId,
    required this.contactInfo,
    required this.attendanceHistory,
    required this.performance,
  });

  int get totalWorkingDays => attendanceHistory.length;
  int get presentDays =>
      attendanceHistory.where((record) => record.status == 'present').length;
  int get absentDays =>
      attendanceHistory.where((record) => record.status == 'absent').length;
  int get lateDays =>
      attendanceHistory.where((record) => record.status == 'late').length;
  double get attendancePercentage =>
      totalWorkingDays > 0 ? (presentDays / totalWorkingDays) * 100 : 0.0;
}

class ContactInfo {
  final String phone;
  final String emergencyContact;
  final String address;

  ContactInfo({
    required this.phone,
    required this.emergencyContact,
    required this.address,
  });
}

class PerformanceMetrics {
  final double productivityScore;
  final double punctualityScore;
  final int completedTasks;
  final int pendingTasks;

  PerformanceMetrics({
    required this.productivityScore,
    required this.punctualityScore,
    required this.completedTasks,
    required this.pendingTasks,
  });
}
