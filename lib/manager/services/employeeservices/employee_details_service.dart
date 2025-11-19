

import '../../models/attendance_model.dart';
import '../../models/employeemodels/employee_details_model.dart';
import '../../models/team_model.dart';

class EmployeeDetailsService {
  Future<EmployeeDetails> getEmployeeDetails(TeamMember member) async {
    return EmployeeDetails(
      id: member.email.hashCode.toString(),
      name: member.name,
      email: member.email,
      position: _getPositionFromRole(member.role),
      department: _getDepartmentFromRole(member.role),
      profileImage: '',
      joinDate: DateTime.now().subtract(const Duration(days: 365)),
      employeeId: 'NT${member.email.hashCode.toString().substring(0, 6)}',
      contactInfo: ContactInfo(
        phone: '+91 ${_generatePhoneNumber()}',
        emergencyContact: '+91 ${_generatePhoneNumber()}',
        address: 'Sector 62, Noida, Uttar Pradesh 201309',
      ),
      attendanceHistory: _generateAttendanceHistory(member.email),
      performance: PerformanceMetrics(
        productivityScore: 85.0 + (member.email.hashCode % 15),
        punctualityScore: 90.0 + (member.email.hashCode % 10),
        completedTasks: 45 + (member.email.hashCode % 20),
        pendingTasks: 5 + (member.email.hashCode % 10),
      ),
    );
  }

  List<AttendanceRecord> _generateAttendanceHistory(String userId) {
    final List<AttendanceRecord> history = [];
    final now = DateTime.now();

    // Generate last 30 days attendance
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: 29 - i));
      final isWeekend =
          date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

      if (!isWeekend) {
        final status = _getRandomStatus();
        final (checkIn, checkOut, workingHours) = _generateCheckTimes(
          status,
          date,
        );

        history.add(
          AttendanceRecord(
            userId: userId,
            checkIn: checkIn,
            checkOut: checkOut,
            location: 'Office',
            status: status,
            date: date, // Add date field
            workingHours: workingHours, // Add working hours
            notes: status == 'late' ? 'Traffic delay' : null,
          ),
        );
      }
    }

    return history;
  }

  (DateTime, DateTime?, Duration?) _generateCheckTimes(
    String status,
    DateTime date,
  ) {
    if (status == 'absent') {
      return (
        DateTime(date.year, date.month, date.day, 0, 0), // Default check-in
        null,
        null,
      );
    }

    final checkIn = DateTime(
      date.year,
      date.month,
      date.day,
      9 + (status == 'late' ? 1 : 0), // Late by 1 hour
      30 + (status == 'late' ? 15 : 0), // Additional 15 minutes for late
    );

    final checkOut = DateTime(
      date.year,
      date.month,
      date.day,
      18, // 6 PM
      30, // 30 minutes
    );

    final workingHours = checkOut.difference(checkIn);

    return (checkIn, checkOut, workingHours);
  }

  String _getRandomStatus() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final options = [
      'present',
      'present',
      'present',
      'present',
      'late',
      'absent',
    ];
    return options[random % options.length];
  }

  String _getPositionFromRole(String role) {
    const positions = {
      'Senior Developer': 'Senior Software Engineer',
      'UI/UX Designer': 'Product Designer',
      'QA Engineer': 'Quality Assurance Engineer',
      'Team Lead': 'Technical Lead',
      'HR': 'HR Manager',
      'Finance': 'Finance Manager',
    };
    return positions[role] ?? 'Team Member';
  }

  String _getDepartmentFromRole(String role) {
    const departments = {
      'Senior Developer': 'Engineering',
      'UI/UX Designer': 'Design',
      'QA Engineer': 'Quality Assurance',
      'Team Lead': 'Engineering',
      'HR': 'Human Resources',
      'Finance': 'Finance',
    };
    return departments[role] ?? 'Operations';
  }

  String _generatePhoneNumber() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return '9${(random % 900000000 + 100000000).toString()}';
  }
}
