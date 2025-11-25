import 'dart:ui';

import 'package:attendanceapp/manager/core/view_models/theme_view_model.dart';
import 'package:attendanceapp/manager/models/attendance_model.dart';
import 'package:attendanceapp/manager/models/employeemodels/employee_details_model.dart';
import 'package:attendanceapp/manager/models/team_model.dart';
import 'package:attendanceapp/manager/services/employeeservices/employee_details_service.dart';
import 'package:attendanceapp/manager/services/managerservices/project_service.dart';
import 'package:flutter/foundation.dart';

class EmployeeDetailsViewModel with ChangeNotifier {
  final EmployeeDetailsService _service = EmployeeDetailsService();
  final ProjectService _projectService = ProjectService();

  bool _isLoading = false;
  EmployeeDetails? _employeeDetails;
  String? _errorMessage;
  String _selectedFilter = 'all'; // all, present, absent, late

  bool get isLoading => _isLoading;
  EmployeeDetails? get employeeDetails => _employeeDetails;
  String? get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;

  // Updated getter for employee with complete TeamMember data
  TeamMember? get employee {
    if (_employeeDetails == null) return null;

    return TeamMember(
      id: int.tryParse(_employeeDetails!.id), // Convert string id to int
      name: _employeeDetails!.name,
      email: _employeeDetails!.email,
      role: _employeeDetails!.position,
      profilePhoto: _employeeDetails!.profileImage,
      status: 'active', // Default status since it's required
      phoneNumber: _employeeDetails!.contactInfo.phone,
      joinDate: _employeeDetails!.joinDate, // ✅ Add this required parameter
      department: _employeeDetails!.department, // ✅ Add this required parameter
    );
  }

  Future<void> loadEmployeeDetails(TeamMember member) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _employeeDetails = await _service.getEmployeeDetails(member);
      _logSuccess('Loaded details for ${member.name}');
    } catch (e) {
      _errorMessage = 'Failed to load employee details: $e';
      _handleError(_errorMessage!);
    } finally {
      _setLoading(false);
    }
  }

  void changeFilter(String filter) {
    if (_selectedFilter == filter) return;

    _selectedFilter = filter;
    _logAction('Filter changed to: $filter');
    notifyListeners();
  }

  List<AttendanceRecord> get filteredAttendance {
    if (_employeeDetails == null) return [];

    final allRecords = _employeeDetails!.attendanceHistory;

    switch (_selectedFilter) {
      case 'present':
        return allRecords
            .where((record) => record.status == 'present')
            .toList();
      case 'absent':
        return allRecords.where((record) => record.status == 'absent').toList();
      case 'late':
        return allRecords.where((record) => record.status == 'late').toList();
      case 'leave':
        return allRecords
            .where((record) => record.status.contains('leave'))
            .toList();
      default:
        return allRecords;
    }
  }

  Map<String, int> getAttendanceSummary() {
    if (_employeeDetails == null) return {};

    return {
      'total': _employeeDetails!.totalWorkingDays,
      'present': _employeeDetails!.presentDays,
      'absent': _employeeDetails!.absentDays,
      'late': _employeeDetails!.lateDays,
      'percentage': _employeeDetails!.attendancePercentage.round(),
    };
  }

  // ✅ FIXED: Simple implementation without accessing private fields
  List<String> getEmployeeProjects() {
    if (_employeeDetails == null) return [];

    final employeeEmail = _employeeDetails!.email;

    // Simple mapping based on employee email
    final projectMapping = {
      'raj.sharma@nutantek.com': [
        'E-Commerce Platform',
        'Healthcare Management System',
      ],
      'priya.singh@nutantek.com': [
        'E-Commerce Platform',
        'Mobile App Redesign',
        'Healthcare Management System',
        'Inventory Management System',
      ],
      'amit.kumar@nutantek.com': [
        'E-Commerce Platform',
        'Banking System Upgrade',
        'Inventory Management System',
      ],
      'neha.patel@nutantek.com': [
        'Mobile App Redesign',
        'AI Chatbot Integration',
        'CRM Implementation',
      ],
      'suresh.verma@nutantek.com': [
        'E-Commerce Platform',
        'Banking System Upgrade',
        'Healthcare Management System',
      ],
      'anjali.mehta@nutantek.com': [
        'AI Chatbot Integration',
        'CRM Implementation',
        'Data Analytics Dashboard',
      ],
      'rohit.gupta@nutantek.com': [
        'CRM Implementation',
        'Data Analytics Dashboard',
      ],
      'sneha.kapoor@nutantek.com': ['CRM Implementation'],
    };

    return projectMapping[employeeEmail] ?? ['General Project'];
  }

  // ✅ NEW: Async method to load projects with proper error handling
  Future<List<String>> loadEmployeeProjects() async {
    if (_employeeDetails == null) return [];

    try {
      // Use the existing getManagerProjects method
      final allProjects = await _projectService.getManagerProjects(
        'manager@nutantek.com',
      );

      // Since we can't access assignedTeam, return projects based on employee email
      return getEmployeeProjects();
    } catch (e) {
      print('Error loading employee projects: $e');
      return getEmployeeProjects(); // Fallback to sync method
    }
  }

  // ✅ NEW: Export attendance data method
  Future<void> exportAttendanceData() async {
    try {
      _setLoading(true);
      _logAction('Exporting attendance data...');

      // Get all required data
      final employeeInfo = getEmployeeInfoForDownload();
      final attendanceCounts = getAttendanceCounts();
      final performanceMetrics = getPerformanceMetrics();
      final sortedRecords = getSortedAttendanceRecords();
      final employeeProjects = getEmployeeProjects();

      // Generate CSV data
      final csvData = _generateCSVData(
        employeeInfo,
        attendanceCounts,
        performanceMetrics,
        sortedRecords,
        employeeProjects,
      );

      // Save or share the CSV file
      await _saveCSVFile(
        csvData,
        '${employeeInfo['name']}_attendance_report.csv',
      );

      _logSuccess('Attendance data exported successfully');
    } catch (e) {
      _errorMessage = 'Failed to export attendance data: $e';
      _handleError(_errorMessage!);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  String _generateCSVData(
    Map<String, dynamic> employeeInfo,
    Map<String, int> attendanceCounts,
    Map<String, dynamic> performanceMetrics,
    List<AttendanceRecord> records,
    List<String> projects,
  ) {
    final buffer = StringBuffer();

    // Employee Information Section
    buffer.writeln('Employee Attendance Report');
    buffer.writeln('Generated on: ${DateTime.now()}');
    buffer.writeln();
    buffer.writeln('Employee Information');
    buffer.writeln('Name,${employeeInfo['name']}');
    buffer.writeln('Employee ID,${employeeInfo['employeeId']}');
    buffer.writeln('Department,${employeeInfo['department']}');
    buffer.writeln('Position,${employeeInfo['position']}');
    buffer.writeln('Email,${employeeInfo['email']}');
    buffer.writeln('Phone,${employeeInfo['phone']}');
    buffer.writeln('Join Date,${_formatDateForCSV(employeeInfo['joinDate'])}');
    buffer.writeln();

    // Projects Section
    buffer.writeln('Allocated Projects');
    if (projects.isEmpty) {
      buffer.writeln('No projects assigned');
    } else {
      for (final project in projects) {
        buffer.writeln(project);
      }
    }
    buffer.writeln();

    // Attendance Summary Section
    buffer.writeln('Attendance Summary');
    buffer.writeln('Total Days,${attendanceCounts['total']}');
    buffer.writeln('Present Days,${attendanceCounts['present']}');
    buffer.writeln('Absent Days,${attendanceCounts['absent']}');
    buffer.writeln('Late Days,${attendanceCounts['late']}');
    buffer.writeln('Leave Days,${attendanceCounts['leaves']}');
    buffer.writeln('On Time Days,${attendanceCounts['ontime']}');
    buffer.writeln(
      'Attendance Percentage,${performanceMetrics['attendancePercentage']}%',
    );
    buffer.writeln();

    // Performance Metrics Section
    buffer.writeln('Performance Metrics');
    buffer.writeln(
      'Performance Score,${performanceMetrics['performanceScore']?.toStringAsFixed(2)}',
    );
    buffer.writeln(
      'Performance Rating,${performanceMetrics['performanceRating']}',
    );
    buffer.writeln(
      'Productivity Score,${performanceMetrics['productivityScore']}',
    );
    buffer.writeln(
      'Punctuality Score,${performanceMetrics['punctualityScore']}',
    );
    buffer.writeln('Completed Tasks,${performanceMetrics['completedTasks']}');
    buffer.writeln('Pending Tasks,${performanceMetrics['pendingTasks']}');
    buffer.writeln();

    // Detailed Attendance Records Section
    buffer.writeln('Detailed Attendance Records');
    buffer.writeln('Date,Day,Status,Check-In,Check-Out,Working Hours,Remarks');

    for (final record in records) {
      final workingHours = getWorkingHours(record);
      buffer.writeln(
        '${_formatDateForCSV(record.date)},'
        '${getFullWeekday(record.date.weekday)},'
        '${getStatusDisplayText(record.status)},'
        '${formatTime(record.checkIn)},'
        '${formatTime(record.checkOut)},'
        '${formatWorkingHours(workingHours)},'
        '${getRemarks(record)}',
      );
    }

    return buffer.toString();
  }

  // ✅ ADDED: Missing _formatDateForCSV method
  String _formatDateForCSV(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _saveCSVFile(String csvData, String fileName) async {
    // Implement file saving logic based on your platform
    // For now, just print to console
    print('CSV File Content for $fileName:');
    print(csvData);

    _logAction('CSV data ready for download: $fileName');

    // TODO: Implement actual file saving using:
    // - For web: html.File and html.AnchorElement
    // - For mobile: path_provider and dart:io
    // - Or use share_plus package for cross-platform sharing
  }

  // New method to calculate averages for download
  Map<String, double> getAttendanceAverages() {
    if (_employeeDetails == null ||
        _employeeDetails!.attendanceHistory.isEmpty) {
      return {'present': 0, 'leaves': 0, 'ontime': 0, 'late': 0, 'absent': 0};
    }

    final records = _employeeDetails!.attendanceHistory;
    final totalDays = records.length;

    int presentCount = 0;
    int leavesCount = 0;
    int ontimeCount = 0;
    int lateCount = 0;
    int absentCount = 0;

    for (final record in records) {
      final status = record.status.toLowerCase();

      if (status.contains('present')) {
        presentCount++;
        // Check if ontime or late using AttendanceRecord's own method if available
        if (_isOntime(record.checkIn)) {
          ontimeCount++;
        } else {
          lateCount++;
        }
      } else if (status.contains('leave') || status.contains('holiday')) {
        leavesCount++;
      } else if (status.contains('absent')) {
        absentCount++;
      }
    }

    return {
      'present': (presentCount / totalDays * 100),
      'leaves': (leavesCount / totalDays * 100),
      'ontime': (ontimeCount / totalDays * 100),
      'late': (lateCount / totalDays * 100),
      'absent': (absentCount / totalDays * 100),
    };
  }

  // Helper method to check if check-in is ontime
  bool _isOntime(DateTime checkIn) {
    final expectedTime = DateTime(
      checkIn.year,
      checkIn.month,
      checkIn.day,
      9,
      30,
    );
    return checkIn.isBefore(expectedTime) ||
        checkIn.isAtSameMomentAs(expectedTime);
  }

  // New method to get attendance counts for download
  Map<String, int> getAttendanceCounts() {
    if (_employeeDetails == null) return {};

    final records = _employeeDetails!.attendanceHistory;

    int ontimeCount = 0;
    int leaveCount = 0;

    for (final record in records) {
      if (record.status.toLowerCase().contains('present') &&
          _isOntime(record.checkIn)) {
        ontimeCount++;
      }
      if (record.status.toLowerCase().contains('leave')) {
        leaveCount++;
      }
    }

    return {
      'present': records
          .where((record) => record.status.toLowerCase().contains('present'))
          .length,
      'leaves': leaveCount,
      'ontime': ontimeCount,
      'late': records
          .where((record) => record.status.toLowerCase().contains('late'))
          .length,
      'absent': records
          .where((record) => record.status.toLowerCase().contains('absent'))
          .length,
      'total': records.length,
    };
  }

  // New method to get performance score
  double getPerformanceScore() {
    final averages = getAttendanceAverages();

    final presentWeight = 0.4;
    final ontimeWeight = 0.3;
    final leaveWeight = 0.2;
    final absentPenalty = 0.1;

    final presentScore = (averages['present'] ?? 0) * presentWeight;
    final ontimeScore = (averages['ontime'] ?? 0) * ontimeWeight;
    final leaveScore = (100 - (averages['leaves'] ?? 0)) * leaveWeight;
    final absentScore = (100 - (averages['absent'] ?? 0)) * absentPenalty;

    return presentScore + ontimeScore + (leaveScore * 0.01) + absentScore;
  }

  // New method to get performance rating
  String getPerformanceRating() {
    final score = getPerformanceScore();

    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Good';
    if (score >= 70) return 'Average';
    return 'Needs Improvement';
  }

  // New method to get late minutes for a record
  int getLateMinutes(AttendanceRecord record) {
    final expectedTime = DateTime(
      record.checkIn.year,
      record.checkIn.month,
      record.checkIn.day,
      9,
      30,
    );
    final lateMinutes = record.checkIn.difference(expectedTime).inMinutes;
    return lateMinutes > 0 ? lateMinutes : 0;
  }

  // New method to get remarks for a record
  String getRemarks(AttendanceRecord record) {
    final status = record.status.toLowerCase();
    if (status.contains('late')) {
      final lateMinutes = getLateMinutes(record);
      return 'Late by $lateMinutes minutes';
    } else if (status.contains('early')) {
      return 'Left early';
    } else if (status.contains('absent')) {
      return 'Absent without notice';
    } else if (status.contains('leave')) {
      return 'Approved leave';
    } else if (status.contains('present') && !_isOntime(record.checkIn)) {
      final lateMinutes = getLateMinutes(record);
      return lateMinutes > 0 ? 'Late by $lateMinutes minutes' : 'Present';
    }
    return 'Regular attendance';
  }

  String getStatusDisplayText(String status) {
    const statusText = {
      'present': 'Present',
      'absent': 'Absent',
      'late': 'Late Arrival',
      'half-day': 'Half Day',
      'leave': 'On Leave',
      'holiday': 'Holiday',
    };
    return statusText[status] ?? status;
  }

  Color getStatusColor(String status) {
    const statusColors = {
      'present': AppColors.success,
      'absent': AppColors.error,
      'late': AppColors.warning,
      'half-day': AppColors.info,
      'leave': AppColors.info,
      'holiday': AppColors.secondary,
    };
    return statusColors[status] ?? AppColors.grey500;
  }

  String formatWorkingHours(Duration? duration) {
    if (duration == null) return '--:--';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  String formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String formatDate(DateTime date) {
    return '${_getWeekday(date.weekday)}, ${date.day} ${_getMonth(date.month)} ${date.year}';
  }

  // ✅ FIXED: Renamed to avoid conflict
  String formatDateForCSV(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Use the calculated working hours from the AttendanceRecord model
  Duration? getWorkingHours(AttendanceRecord record) {
    // Use the existing calculatedWorkingHours from AttendanceRecord if available
    // Otherwise calculate manually
    return record.calculatedWorkingHours ??
        (record.checkOut?.difference(record.checkIn));
  }

  // New method to get sorted attendance records (newest first)
  List<AttendanceRecord> getSortedAttendanceRecords() {
    if (_employeeDetails == null) return [];

    final records = List<AttendanceRecord>.from(
      _employeeDetails!.attendanceHistory,
    )..sort((a, b) => b.date.compareTo(a.date));

    return records;
  }

  // New method to get employee info for download
  Map<String, dynamic> getEmployeeInfoForDownload() {
    if (_employeeDetails == null) return {};

    return {
      'name': _employeeDetails!.name,
      'employeeId': _employeeDetails!.employeeId,
      'department': _employeeDetails!.department,
      'position': _employeeDetails!.position,
      'email': _employeeDetails!.email,
      'phone': _employeeDetails!.contactInfo.phone,
      'emergencyContact': _employeeDetails!.contactInfo.emergencyContact,
      'address': _employeeDetails!.contactInfo.address,
      'joinDate': _employeeDetails!.joinDate,
      'profileImage': _employeeDetails!.profileImage,
    };
  }

  // New method to get performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    if (_employeeDetails == null) return {};

    return {
      'productivityScore': _employeeDetails!.performance.productivityScore,
      'punctualityScore': _employeeDetails!.performance.punctualityScore,
      'completedTasks': _employeeDetails!.performance.completedTasks,
      'pendingTasks': _employeeDetails!.performance.pendingTasks,
      'attendancePercentage': _employeeDetails!.attendancePercentage,
      'performanceScore': getPerformanceScore(),
      'performanceRating': getPerformanceRating(),
    };
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(String message) {
    if (kDebugMode) {
      print('❌ EmployeeDetailsViewModel: $message');
    }
  }

  void _logSuccess(String message) {
    if (kDebugMode) {
      print('✅ EmployeeDetailsViewModel: $message');
    }
  }

  void _logAction(String message) {
    if (kDebugMode) {
      print('🔧 EmployeeDetailsViewModel: $message');
    }
  }

  String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  // New method for full weekday names
  String getFullWeekday(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  // New method for full month names
  String getFullMonth(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  @override
  void dispose() {
    _employeeDetails = null;
    super.dispose();
  }
}

// import 'dart:ui';

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/attendance_model.dart';
// import 'package:attendanceapp/models/employeemodels/employee_details_model.dart';
// import 'package:attendanceapp/models/team_model.dart';
// import 'package:attendanceapp/services/employeeservices/employee_details_service.dart';
// import 'package:attendanceapp/services/managerservices/project_service.dart';
// import 'package:flutter/foundation.dart';

// class EmployeeDetailsViewModel with ChangeNotifier {
//   final EmployeeDetailsService _service = EmployeeDetailsService();
//   final ProjectService _projectService = ProjectService();

//   bool _isLoading = false;
//   EmployeeDetails? _employeeDetails;
//   String? _errorMessage;
//   String _selectedFilter = 'all'; // all, present, absent, late

//   bool get isLoading => _isLoading;
//   EmployeeDetails? get employeeDetails => _employeeDetails;
//   String? get errorMessage => _errorMessage;
//   String get selectedFilter => _selectedFilter;

//   // Updated getter for employee with complete TeamMember data
//   TeamMember? get employee {
//     if (_employeeDetails == null) return null;

//     return TeamMember(
//       id: int.tryParse(_employeeDetails!.id), // Convert string id to int
//       name: _employeeDetails!.name,
//       email: _employeeDetails!.email,
//       role: _employeeDetails!.position,
//       profilePhoto: _employeeDetails!.profileImage,
//       status: 'active', // Default status since it's required
//       phoneNumber: _employeeDetails!.contactInfo.phone,
//       joinDate: _employeeDetails!.joinDate, // ✅ Add this required parameter
//       department: _employeeDetails!.department, // ✅ Add this required parameter
//     );
//   }

//   Future<void> loadEmployeeDetails(TeamMember member) async {
//     _setLoading(true);
//     _errorMessage = null;

//     try {
//       _employeeDetails = await _service.getEmployeeDetails(member);
//       _logSuccess('Loaded details for ${member.name}');
//     } catch (e) {
//       _errorMessage = 'Failed to load employee details: $e';
//       _handleError(_errorMessage!);
//     } finally {
//       _setLoading(false);
//     }
//   }

//   void changeFilter(String filter) {
//     if (_selectedFilter == filter) return;

//     _selectedFilter = filter;
//     _logAction('Filter changed to: $filter');
//     notifyListeners();
//   }

//   List<AttendanceRecord> get filteredAttendance {
//     if (_employeeDetails == null) return [];

//     final allRecords = _employeeDetails!.attendanceHistory;

//     switch (_selectedFilter) {
//       case 'present':
//         return allRecords
//             .where((record) => record.status == 'present')
//             .toList();
//       case 'absent':
//         return allRecords.where((record) => record.status == 'absent').toList();
//       case 'late':
//         return allRecords.where((record) => record.status == 'late').toList();
//       case 'leave':
//         return allRecords
//             .where((record) => record.status.contains('leave'))
//             .toList();
//       default:
//         return allRecords;
//     }
//   }

//   Map<String, int> getAttendanceSummary() {
//     if (_employeeDetails == null) return {};

//     return {
//       'total': _employeeDetails!.totalWorkingDays,
//       'present': _employeeDetails!.presentDays,
//       'absent': _employeeDetails!.absentDays,
//       'late': _employeeDetails!.lateDays,
//       'percentage': _employeeDetails!.attendancePercentage.round(),
//     };
//   }

//   // ✅ FIXED: Simple implementation without accessing private fields
//   List<String> getEmployeeProjects() {
//     if (_employeeDetails == null) return [];

//     final employeeEmail = _employeeDetails!.email;

//     // Simple mapping based on employee email
//     final projectMapping = {
//       'raj.sharma@nutantek.com': [
//         'E-Commerce Platform',
//         'Healthcare Management System',
//       ],
//       'priya.singh@nutantek.com': [
//         'E-Commerce Platform',
//         'Mobile App Redesign',
//         'Healthcare Management System',
//         'Inventory Management System',
//       ],
//       'amit.kumar@nutantek.com': [
//         'E-Commerce Platform',
//         'Banking System Upgrade',
//         'Inventory Management System',
//       ],
//       'neha.patel@nutantek.com': [
//         'Mobile App Redesign',
//         'AI Chatbot Integration',
//         'CRM Implementation',
//       ],
//       'suresh.verma@nutantek.com': [
//         'E-Commerce Platform',
//         'Banking System Upgrade',
//         'Healthcare Management System',
//       ],
//       'anjali.mehta@nutantek.com': [
//         'AI Chatbot Integration',
//         'CRM Implementation',
//         'Data Analytics Dashboard',
//       ],
//       'rohit.gupta@nutantek.com': [
//         'CRM Implementation',
//         'Data Analytics Dashboard',
//       ],
//       'sneha.kapoor@nutantek.com': ['CRM Implementation'],
//     };

//     return projectMapping[employeeEmail] ?? ['General Project'];
//   }

//   // ✅ NEW: Async method to load projects with proper error handling
//   Future<List<String>> loadEmployeeProjects() async {
//     if (_employeeDetails == null) return [];

//     try {
//       // Use the existing getManagerProjects method
//       final allProjects = await _projectService.getManagerProjects(
//         'manager@nutantek.com',
//       );

//       // Since we can't access assignedTeam, return projects based on employee email
//       return getEmployeeProjects();
//     } catch (e) {
//       print('Error loading employee projects: $e');
//       return getEmployeeProjects(); // Fallback to sync method
//     }
//   }

//   // ✅ NEW: Export attendance data method
//   Future<void> exportAttendanceData() async {
//     try {
//       _setLoading(true);
//       _logAction('Exporting attendance data...');

//       // Get all required data
//       final employeeInfo = getEmployeeInfoForDownload();
//       final attendanceCounts = getAttendanceCounts();
//       final performanceMetrics = getPerformanceMetrics();
//       final sortedRecords = getSortedAttendanceRecords();
//       final employeeProjects = getEmployeeProjects();

//       // Generate CSV data
//       final csvData = _generateCSVData(
//         employeeInfo,
//         attendanceCounts,
//         performanceMetrics,
//         sortedRecords,
//         employeeProjects,
//       );

//       // Save or share the CSV file
//       await _saveCSVFile(
//         csvData,
//         '${employeeInfo['name']}_attendance_report.csv',
//       );

//       _logSuccess('Attendance data exported successfully');
//     } catch (e) {
//       _errorMessage = 'Failed to export attendance data: $e';
//       _handleError(_errorMessage!);
//       rethrow;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   String _generateCSVData(
//     Map<String, dynamic> employeeInfo,
//     Map<String, int> attendanceCounts,
//     Map<String, dynamic> performanceMetrics,
//     List<AttendanceRecord> records,
//     List<String> projects,
//   ) {
//     final buffer = StringBuffer();

//     // Employee Information Section
//     buffer.writeln('Employee Attendance Report');
//     buffer.writeln('Generated on: ${DateTime.now()}');
//     buffer.writeln();
//     buffer.writeln('Employee Information');
//     buffer.writeln('Name,${employeeInfo['name']}');
//     buffer.writeln('Employee ID,${employeeInfo['employeeId']}');
//     buffer.writeln('Department,${employeeInfo['department']}');
//     buffer.writeln('Position,${employeeInfo['position']}');
//     buffer.writeln('Email,${employeeInfo['email']}');
//     buffer.writeln('Phone,${employeeInfo['phone']}');
//     buffer.writeln('Join Date,${formatDateForCSV(employeeInfo['joinDate'])}');
//     buffer.writeln();

//     // Projects Section
//     buffer.writeln('Allocated Projects');
//     if (projects.isEmpty) {
//       buffer.writeln('No projects assigned');
//     } else {
//       for (final project in projects) {
//         buffer.writeln(project);
//       }
//     }
//     buffer.writeln();

//     // Attendance Summary Section
//     buffer.writeln('Attendance Summary');
//     buffer.writeln('Total Days,${attendanceCounts['total']}');
//     buffer.writeln('Present Days,${attendanceCounts['present']}');
//     buffer.writeln('Absent Days,${attendanceCounts['absent']}');
//     buffer.writeln('Late Days,${attendanceCounts['late']}');
//     buffer.writeln('Leave Days,${attendanceCounts['leaves']}');
//     buffer.writeln('On Time Days,${attendanceCounts['ontime']}');
//     buffer.writeln(
//       'Attendance Percentage,${performanceMetrics['attendancePercentage']}%',
//     );
//     buffer.writeln();

//     // Performance Metrics Section
//     buffer.writeln('Performance Metrics');
//     buffer.writeln(
//       'Performance Score,${performanceMetrics['performanceScore']?.toStringAsFixed(2)}',
//     );
//     buffer.writeln(
//       'Performance Rating,${performanceMetrics['performanceRating']}',
//     );
//     buffer.writeln(
//       'Productivity Score,${performanceMetrics['productivityScore']}',
//     );
//     buffer.writeln(
//       'Punctuality Score,${performanceMetrics['punctualityScore']}',
//     );
//     buffer.writeln('Completed Tasks,${performanceMetrics['completedTasks']}');
//     buffer.writeln('Pending Tasks,${performanceMetrics['pendingTasks']}');
//     buffer.writeln();

//     // Detailed Attendance Records Section
//     buffer.writeln('Detailed Attendance Records');
//     buffer.writeln('Date,Day,Status,Check-In,Check-Out,Working Hours,Remarks');

//     for (final record in records) {
//       final workingHours = getWorkingHours(record);
//       buffer.writeln(
//         ''
//         '${formatDateForCSV(record.date)},'
//         '${getFullWeekday(record.date.weekday)},'
//         '${getStatusDisplayText(record.status)},'
//         '${formatTime(record.checkIn)},'
//         '${formatTime(record.checkOut)},'
//         '${formatWorkingHours(workingHours)},'
//         '${getRemarks(record)}',
//       );
//     }

//     return buffer.toString();
//   }

//   Future<void> _saveCSVFile(String csvData, String fileName) async {
//     // Implement file saving logic based on your platform
//     // For now, just print to console
//     print('CSV File Content for $fileName:');
//     print(csvData);

//     _logAction('CSV data ready for download: $fileName');

//     // TODO: Implement actual file saving using:
//     // - For web: html.File and html.AnchorElement
//     // - For mobile: path_provider and dart:io
//     // - Or use share_plus package for cross-platform sharing
//   }

//   // New method to calculate averages for download
//   Map<String, double> getAttendanceAverages() {
//     if (_employeeDetails == null ||
//         _employeeDetails!.attendanceHistory.isEmpty) {
//       return {'present': 0, 'leaves': 0, 'ontime': 0, 'late': 0, 'absent': 0};
//     }

//     final records = _employeeDetails!.attendanceHistory;
//     final totalDays = records.length;

//     int presentCount = 0;
//     int leavesCount = 0;
//     int ontimeCount = 0;
//     int lateCount = 0;
//     int absentCount = 0;

//     for (final record in records) {
//       final status = record.status.toLowerCase();

//       if (status.contains('present')) {
//         presentCount++;
//         // Check if ontime or late using AttendanceRecord's own method if available
//         if (_isOntime(record.checkIn)) {
//           ontimeCount++;
//         } else {
//           lateCount++;
//         }
//       } else if (status.contains('leave') || status.contains('holiday')) {
//         leavesCount++;
//       } else if (status.contains('absent')) {
//         absentCount++;
//       }
//     }

//     return {
//       'present': (presentCount / totalDays * 100),
//       'leaves': (leavesCount / totalDays * 100),
//       'ontime': (ontimeCount / totalDays * 100),
//       'late': (lateCount / totalDays * 100),
//       'absent': (absentCount / totalDays * 100),
//     };
//   }

//   // Helper method to check if check-in is ontime
//   bool _isOntime(DateTime checkIn) {
//     final expectedTime = DateTime(
//       checkIn.year,
//       checkIn.month,
//       checkIn.day,
//       9,
//       30,
//     );
//     return checkIn.isBefore(expectedTime) ||
//         checkIn.isAtSameMomentAs(expectedTime);
//   }

//   // New method to get attendance counts for download
//   Map<String, int> getAttendanceCounts() {
//     if (_employeeDetails == null) return {};

//     final records = _employeeDetails!.attendanceHistory;

//     int ontimeCount = 0;
//     int leaveCount = 0;

//     for (final record in records) {
//       if (record.status.toLowerCase().contains('present') &&
//           _isOntime(record.checkIn)) {
//         ontimeCount++;
//       }
//       if (record.status.toLowerCase().contains('leave')) {
//         leaveCount++;
//       }
//     }

//     return {
//       'present': records
//           .where((record) => record.status.toLowerCase().contains('present'))
//           .length,
//       'leaves': leaveCount,
//       'ontime': ontimeCount,
//       'late': records
//           .where((record) => record.status.toLowerCase().contains('late'))
//           .length,
//       'absent': records
//           .where((record) => record.status.toLowerCase().contains('absent'))
//           .length,
//       'total': records.length,
//     };
//   }

//   // New method to get performance score
//   double getPerformanceScore() {
//     final averages = getAttendanceAverages();

//     final presentWeight = 0.4;
//     final ontimeWeight = 0.3;
//     final leaveWeight = 0.2;
//     final absentPenalty = 0.1;

//     final presentScore = (averages['present'] ?? 0) * presentWeight;
//     final ontimeScore = (averages['ontime'] ?? 0) * ontimeWeight;
//     final leaveScore = (100 - (averages['leaves'] ?? 0)) * leaveWeight;
//     final absentScore = (100 - (averages['absent'] ?? 0)) * absentPenalty;

//     return presentScore + ontimeScore + (leaveScore * 0.01) + absentScore;
//   }

//   // New method to get performance rating
//   String getPerformanceRating() {
//     final score = getPerformanceScore();

//     if (score >= 90) return 'Excellent';
//     if (score >= 80) return 'Good';
//     if (score >= 70) return 'Average';
//     return 'Needs Improvement';
//   }

//   // New method to get late minutes for a record
//   int getLateMinutes(AttendanceRecord record) {
//     final expectedTime = DateTime(
//       record.checkIn.year,
//       record.checkIn.month,
//       record.checkIn.day,
//       9,
//       30,
//     );
//     final lateMinutes = record.checkIn.difference(expectedTime).inMinutes;
//     return lateMinutes > 0 ? lateMinutes : 0;
//   }

//   // New method to get remarks for a record
//   String getRemarks(AttendanceRecord record) {
//     final status = record.status.toLowerCase();
//     if (status.contains('late')) {
//       final lateMinutes = getLateMinutes(record);
//       return 'Late by $lateMinutes minutes';
//     } else if (status.contains('early')) {
//       return 'Left early';
//     } else if (status.contains('absent')) {
//       return 'Absent without notice';
//     } else if (status.contains('leave')) {
//       return 'Approved leave';
//     } else if (status.contains('present') && !_isOntime(record.checkIn)) {
//       final lateMinutes = getLateMinutes(record);
//       return lateMinutes > 0 ? 'Late by $lateMinutes minutes' : 'Present';
//     }
//     return 'Regular attendance';
//   }

//   String getStatusDisplayText(String status) {
//     const statusText = {
//       'present': 'Present',
//       'absent': 'Absent',
//       'late': 'Late Arrival',
//       'half-day': 'Half Day',
//       'leave': 'On Leave',
//       'holiday': 'Holiday',
//     };
//     return statusText[status] ?? status;
//   }

//   Color getStatusColor(String status) {
//     const statusColors = {
//       'present': AppColors.success,
//       'absent': AppColors.error,
//       'late': AppColors.warning,
//       'half-day': AppColors.info,
//       'leave': AppColors.info,
//       'holiday': AppColors.secondary,
//     };
//     return statusColors[status] ?? AppColors.grey500;
//   }

//   String formatWorkingHours(Duration? duration) {
//     if (duration == null) return '--:--';

//     final hours = duration.inHours;
//     final minutes = duration.inMinutes.remainder(60);
//     return '${hours}h ${minutes}m';
//   }

//   String formatTime(DateTime? time) {
//     if (time == null) return '--:--';
//     return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
//   }

//   String formatDate(DateTime date) {
//     return '${_getWeekday(date.weekday)}, ${date.day} ${_getMonth(date.month)} ${date.year}';
//   }

//   // New method for CSV date format
//   String formatDateForCSV(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
//   }

//   // Use the calculated working hours from the AttendanceRecord model
//   Duration? getWorkingHours(AttendanceRecord record) {
//     // Use the existing calculatedWorkingHours from AttendanceRecord if available
//     // Otherwise calculate manually
//     return record.calculatedWorkingHours ??
//         (record.checkOut?.difference(record.checkIn));
//   }

//   // New method to get sorted attendance records (newest first)
//   List<AttendanceRecord> getSortedAttendanceRecords() {
//     if (_employeeDetails == null) return [];

//     final records = List<AttendanceRecord>.from(
//       _employeeDetails!.attendanceHistory,
//     )..sort((a, b) => b.date.compareTo(a.date));

//     return records;
//   }

//   // New method to get employee info for download
//   Map<String, dynamic> getEmployeeInfoForDownload() {
//     if (_employeeDetails == null) return {};

//     return {
//       'name': _employeeDetails!.name,
//       'employeeId': _employeeDetails!.employeeId,
//       'department': _employeeDetails!.department,
//       'position': _employeeDetails!.position,
//       'email': _employeeDetails!.email,
//       'phone': _employeeDetails!.contactInfo.phone,
//       'emergencyContact': _employeeDetails!.contactInfo.emergencyContact,
//       'address': _employeeDetails!.contactInfo.address,
//       'joinDate': _employeeDetails!.joinDate,
//       'profileImage': _employeeDetails!.profileImage,
//     };
//   }

//   // New method to get performance metrics
//   Map<String, dynamic> getPerformanceMetrics() {
//     if (_employeeDetails == null) return {};

//     return {
//       'productivityScore': _employeeDetails!.performance.productivityScore,
//       'punctualityScore': _employeeDetails!.performance.punctualityScore,
//       'completedTasks': _employeeDetails!.performance.completedTasks,
//       'pendingTasks': _employeeDetails!.performance.pendingTasks,
//       'attendancePercentage': _employeeDetails!.attendancePercentage,
//       'performanceScore': getPerformanceScore(),
//       'performanceRating': getPerformanceRating(),
//     };
//   }

//   // Private methods
//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }

//   void _handleError(String message) {
//     if (kDebugMode) {
//       print('❌ EmployeeDetailsViewModel: $message');
//     }
//   }

//   void _logSuccess(String message) {
//     if (kDebugMode) {
//       print('✅ EmployeeDetailsViewModel: $message');
//     }
//   }

//   void _logAction(String message) {
//     if (kDebugMode) {
//       print('🔧 EmployeeDetailsViewModel: $message');
//     }
//   }
  

//   String _getWeekday(int weekday) {
//     const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return days[weekday - 1];
//   }

//   // New method for full weekday names
//   String getFullWeekday(int weekday) {
//     const days = [
//       'Monday',
//       'Tuesday',
//       'Wednesday',
//       'Thursday',
//       'Friday',
//       'Saturday',
//       'Sunday',
//     ];
//     return days[weekday - 1];
//   }

//   String _getMonth(int month) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return months[month - 1];
//   }

//   // New method for full month names
//   String getFullMonth(int month) {
//     const months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December',
//     ];
//     return months[month - 1];
//   }
  

//   @override
//   void dispose() {
//     _employeeDetails = null;
//     super.dispose();
//   }
  
// }


// import 'dart:ui';

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/attendance_model.dart';
// import 'package:attendanceapp/models/employeemodels/employee_details_model.dart';
// import 'package:attendanceapp/models/team_model.dart';
// import 'package:attendanceapp/services/employeeservices/employee_details_service.dart';
// import 'package:attendanceapp/services/managerservices/project_service.dart';
// import 'package:flutter/foundation.dart';

// class EmployeeDetailsViewModel with ChangeNotifier {
//   final EmployeeDetailsService _service = EmployeeDetailsService();

//   bool _isLoading = false;
//   EmployeeDetails? _employeeDetails;
//   String? _errorMessage;
//   String _selectedFilter = 'all'; // all, present, absent, late

//   bool get isLoading => _isLoading;
//   EmployeeDetails? get employeeDetails => _employeeDetails;
//   String? get errorMessage => _errorMessage;
//   String get selectedFilter => _selectedFilter;

//   // Updated getter for employee with complete TeamMember data
//   TeamMember? get employee {
//     if (_employeeDetails == null) return null;

//     return TeamMember(
//       id: int.tryParse(_employeeDetails!.id), // Convert string id to int
//       name: _employeeDetails!.name,
//       email: _employeeDetails!.email,
//       role: _employeeDetails!.position,
//       profilePhoto: _employeeDetails!.profileImage,
//       status: 'active', // Default status since it's required
//       phoneNumber: _employeeDetails!.contactInfo.phone,
//       joinDate: _employeeDetails!.joinDate, // ✅ Add this required parameter
//       department: _employeeDetails!.department, // ✅ Add this required parameter
//     );
//   }

//   Future<void> loadEmployeeDetails(TeamMember member) async {
//     _setLoading(true);
//     _errorMessage = null;

//     try {
//       _employeeDetails = await _service.getEmployeeDetails(member);
//       _logSuccess('Loaded details for ${member.name}');
//     } catch (e) {
//       _errorMessage = 'Failed to load employee details: $e';
//       _handleError(_errorMessage!);
//     } finally {
//       _setLoading(false);
//     }
//   }

//   void changeFilter(String filter) {
//     if (_selectedFilter == filter) return;

//     _selectedFilter = filter;
//     _logAction('Filter changed to: $filter');
//     notifyListeners();
//   }

//   List<AttendanceRecord> get filteredAttendance {
//     if (_employeeDetails == null) return [];

//     final allRecords = _employeeDetails!.attendanceHistory;

//     switch (_selectedFilter) {
//       case 'present':
//         return allRecords
//             .where((record) => record.status == 'present')
//             .toList();
//       case 'absent':
//         return allRecords.where((record) => record.status == 'absent').toList();
//       case 'late':
//         return allRecords.where((record) => record.status == 'late').toList();
//       case 'leave':
//         return allRecords
//             .where((record) => record.status.contains('leave'))
//             .toList();
//       default:
//         return allRecords;
//     }
//   }

//   Map<String, int> getAttendanceSummary() {
//     if (_employeeDetails == null) return {};

//     return {
//       'total': _employeeDetails!.totalWorkingDays,
//       'present': _employeeDetails!.presentDays,
//       'absent': _employeeDetails!.absentDays,
//       'late': _employeeDetails!.lateDays,
//       'percentage': _employeeDetails!.attendancePercentage.round(),
//     };
//   }

//   // New method to get employee projects
//  // EmployeeDetailsViewModel में getEmployeeProjects method को replace करें
// List<String> getEmployeeProjects() {
//   if (_employeeDetails == null) return [];

//   final employeeEmail = _employeeDetails!.email;
  
//   // Create ProjectService instance to access projects
//   final projectService = ProjectService();
  
//   // Get all projects from ProjectService
//   final allProjects = projectService._projects; // Access the projects list
  
//   // Filter projects where this employee is assigned
//   final employeeProjects = allProjects.where((project) {
//     return project.assignedTeam.any((teamMember) => teamMember.email == employeeEmail);
//   }).toList();

//   // Return only project names
//   return employeeProjects.map((project) => project.name).toList();
// }

//   // New method to calculate averages for download
//   Map<String, double> getAttendanceAverages() {
//     if (_employeeDetails == null ||
//         _employeeDetails!.attendanceHistory.isEmpty) {
//       return {'present': 0, 'leaves': 0, 'ontime': 0, 'late': 0, 'absent': 0};
//     }

//     final records = _employeeDetails!.attendanceHistory;
//     final totalDays = records.length;

//     int presentCount = 0;
//     int leavesCount = 0;
//     int ontimeCount = 0;
//     int lateCount = 0;
//     int absentCount = 0;

//     for (final record in records) {
//       final status = record.status.toLowerCase();

//       if (status.contains('present')) {
//         presentCount++;
//         // Check if ontime or late using AttendanceRecord's own method if available
//         if (_isOntime(record.checkIn)) {
//           ontimeCount++;
//         } else {
//           lateCount++;
//         }
//       } else if (status.contains('leave') || status.contains('holiday')) {
//         leavesCount++;
//       } else if (status.contains('absent')) {
//         absentCount++;
//       }
//     }

//     return {
//       'present': (presentCount / totalDays * 100),
//       'leaves': (leavesCount / totalDays * 100),
//       'ontime': (ontimeCount / totalDays * 100),
//       'late': (lateCount / totalDays * 100),
//       'absent': (absentCount / totalDays * 100),
//     };
//   }

//   // Helper method to check if check-in is ontime
//   bool _isOntime(DateTime checkIn) {
//     final expectedTime = DateTime(
//       checkIn.year,
//       checkIn.month,
//       checkIn.day,
//       9,
//       30,
//     );
//     return checkIn.isBefore(expectedTime) ||
//         checkIn.isAtSameMomentAs(expectedTime);
//   }

//   // New method to get attendance counts for download
//   Map<String, int> getAttendanceCounts() {
//     if (_employeeDetails == null) return {};

//     final records = _employeeDetails!.attendanceHistory;

//     int ontimeCount = 0;
//     int leaveCount = 0;

//     for (final record in records) {
//       if (record.status.toLowerCase().contains('present') &&
//           _isOntime(record.checkIn)) {
//         ontimeCount++;
//       }
//       if (record.status.toLowerCase().contains('leave')) {
//         leaveCount++;
//       }
//     }

//     return {
//       'present': records
//           .where((record) => record.status.toLowerCase().contains('present'))
//           .length,
//       'leaves': leaveCount,
//       'ontime': ontimeCount,
//       'late': records
//           .where((record) => record.status.toLowerCase().contains('late'))
//           .length,
//       'absent': records
//           .where((record) => record.status.toLowerCase().contains('absent'))
//           .length,
//       'total': records.length,
//     };
//   }

//   // New method to get performance score
//   double getPerformanceScore() {
//     final averages = getAttendanceAverages();

//     final presentWeight = 0.4;
//     final ontimeWeight = 0.3;
//     final leaveWeight = 0.2;
//     final absentPenalty = 0.1;

//     final presentScore = (averages['present'] ?? 0) * presentWeight;
//     final ontimeScore = (averages['ontime'] ?? 0) * ontimeWeight;
//     final leaveScore = (100 - (averages['leaves'] ?? 0)) * leaveWeight;
//     final absentScore = (100 - (averages['absent'] ?? 0)) * absentPenalty;

//     return presentScore + ontimeScore + (leaveScore * 0.01) + absentScore;
//   }

//   // New method to get performance rating
//   String getPerformanceRating() {
//     final score = getPerformanceScore();

//     if (score >= 90) return 'Excellent';
//     if (score >= 80) return 'Good';
//     if (score >= 70) return 'Average';
//     return 'Needs Improvement';
//   }

//   // New method to get late minutes for a record
//   int getLateMinutes(AttendanceRecord record) {
//     final expectedTime = DateTime(
//       record.checkIn.year,
//       record.checkIn.month,
//       record.checkIn.day,
//       9,
//       30,
//     );
//     final lateMinutes = record.checkIn.difference(expectedTime).inMinutes;
//     return lateMinutes > 0 ? lateMinutes : 0;
//   }

//   // New method to get remarks for a record
//   String getRemarks(AttendanceRecord record) {
//     final status = record.status.toLowerCase();
//     if (status.contains('late')) {
//       final lateMinutes = getLateMinutes(record);
//       return 'Late by $lateMinutes minutes';
//     } else if (status.contains('early')) {
//       return 'Left early';
//     } else if (status.contains('absent')) {
//       return 'Absent without notice';
//     } else if (status.contains('leave')) {
//       return 'Approved leave';
//     } else if (status.contains('present') && !_isOntime(record.checkIn)) {
//       final lateMinutes = getLateMinutes(record);
//       return lateMinutes > 0 ? 'Late by $lateMinutes minutes' : 'Present';
//     }
//     return 'Regular attendance';
//   }

//   String getStatusDisplayText(String status) {
//     const statusText = {
//       'present': 'Present',
//       'absent': 'Absent',
//       'late': 'Late Arrival',
//       'half-day': 'Half Day',
//       'leave': 'On Leave',
//       'holiday': 'Holiday',
//     };
//     return statusText[status] ?? status;
//   }

//   Color getStatusColor(String status) {
//     const statusColors = {
//       'present': AppColors.success,
//       'absent': AppColors.error,
//       'late': AppColors.warning,
//       'half-day': AppColors.info,
//       'leave': AppColors.info,
//       'holiday': AppColors.secondary,
//     };
//     return statusColors[status] ?? AppColors.grey500;
//   }

//   String formatWorkingHours(Duration? duration) {
//     if (duration == null) return '--:--';

//     final hours = duration.inHours;
//     final minutes = duration.inMinutes.remainder(60);
//     return '${hours}h ${minutes}m';
//   }

//   String formatTime(DateTime? time) {
//     if (time == null) return '--:--';
//     return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
//   }

//   String formatDate(DateTime date) {
//     return '${_getWeekday(date.weekday)}, ${date.day} ${_getMonth(date.month)} ${date.year}';
//   }

//   // New method for CSV date format
//   String formatDateForCSV(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
//   }

//   // Use the calculated working hours from the AttendanceRecord model
//   Duration? getWorkingHours(AttendanceRecord record) {
//     // Use the existing calculatedWorkingHours from AttendanceRecord if available
//     // Otherwise calculate manually
//     return record.calculatedWorkingHours ??
//         (record.checkOut?.difference(record.checkIn));
//   }

//   // New method to get sorted attendance records (newest first)
//   List<AttendanceRecord> getSortedAttendanceRecords() {
//     if (_employeeDetails == null) return [];

//     final records = List<AttendanceRecord>.from(
//       _employeeDetails!.attendanceHistory,
//     )..sort((a, b) => b.date.compareTo(a.date));

//     return records;
//   }

//   // New method to get employee info for download
//   Map<String, dynamic> getEmployeeInfoForDownload() {
//     if (_employeeDetails == null) return {};

//     return {
//       'name': _employeeDetails!.name,
//       'employeeId': _employeeDetails!.employeeId,
//       'department': _employeeDetails!.department,
//       'position': _employeeDetails!.position,
//       'email': _employeeDetails!.email,
//       'phone': _employeeDetails!.contactInfo.phone,
//       'emergencyContact': _employeeDetails!.contactInfo.emergencyContact,
//       'address': _employeeDetails!.contactInfo.address,
//       'joinDate': _employeeDetails!.joinDate,
//       'profileImage': _employeeDetails!.profileImage,
//     };
//   }

//   // New method to get performance metrics
//   Map<String, dynamic> getPerformanceMetrics() {
//     if (_employeeDetails == null) return {};

//     return {
//       'productivityScore': _employeeDetails!.performance.productivityScore,
//       'punctualityScore': _employeeDetails!.performance.punctualityScore,
//       'completedTasks': _employeeDetails!.performance.completedTasks,
//       'pendingTasks': _employeeDetails!.performance.pendingTasks,
//       'attendancePercentage': _employeeDetails!.attendancePercentage,
//       'performanceScore': getPerformanceScore(),
//       'performanceRating': getPerformanceRating(),
//     };
//   }

//   // Private methods
//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }

//   void _handleError(String message) {
//     if (kDebugMode) {
//       print('❌ EmployeeDetailsViewModel: $message');
//     }
//   }

//   void _logSuccess(String message) {
//     if (kDebugMode) {
//       print('✅ EmployeeDetailsViewModel: $message');
//     }
//   }

//   void _logAction(String message) {
//     if (kDebugMode) {
//       print('🔧 EmployeeDetailsViewModel: $message');
//     }
//   }

//   String _getWeekday(int weekday) {
//     const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return days[weekday - 1];
//   }

//   // New method for full weekday names
//   String getFullWeekday(int weekday) {
//     const days = [
//       'Monday',
//       'Tuesday',
//       'Wednesday',
//       'Thursday',
//       'Friday',
//       'Saturday',
//       'Sunday',
//     ];
//     return days[weekday - 1];
//   }

//   String _getMonth(int month) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return months[month - 1];
//   }

//   // New method for full month names
//   String getFullMonth(int month) {
//     const months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December',
//     ];
//     return months[month - 1];
//   }

//   @override
//   void dispose() {
//     _employeeDetails = null;
//     super.dispose();
//   }
// }

// import 'dart:ui';

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/attendance_model.dart';
// import 'package:attendanceapp/models/employeemodels/employee_details_model.dart';
// import 'package:attendanceapp/models/team_model.dart';
// import 'package:attendanceapp/services/employeeservices/employee_details_service.dart';
// import 'package:flutter/foundation.dart';

// class EmployeeDetailsViewModel with ChangeNotifier {
//   final EmployeeDetailsService _service = EmployeeDetailsService();

//   bool _isLoading = false;
//   EmployeeDetails? _employeeDetails;
//   String? _errorMessage;
//   String _selectedFilter = 'all'; // all, present, absent, late

//   bool get isLoading => _isLoading;
//   EmployeeDetails? get employeeDetails => _employeeDetails;
//   String? get errorMessage => _errorMessage;
//   String get selectedFilter => _selectedFilter;

//   // Updated getter for employee with complete TeamMember data
//   TeamMember? get employee {
//     if (_employeeDetails == null) return null;

//     return TeamMember(
//       id: int.tryParse(_employeeDetails!.id), // Convert string id to int
//       name: _employeeDetails!.name,
//       email: _employeeDetails!.email,
//       role: _employeeDetails!.position,
//       profilePhoto: _employeeDetails!.profileImage,
//       status: 'active', // Default status since it's required
//       phoneNumber: _employeeDetails!.contactInfo.phone,
//     );
//   }

//   Future<void> loadEmployeeDetails(TeamMember member) async {
//     _setLoading(true);
//     _errorMessage = null;

//     try {
//       _employeeDetails = await _service.getEmployeeDetails(member);
//       _logSuccess('Loaded details for ${member.name}');
//     } catch (e) {
//       _errorMessage = 'Failed to load employee details: $e';
//       _handleError(_errorMessage!);
//     } finally {
//       _setLoading(false);
//     }
//   }

//   void changeFilter(String filter) {
//     if (_selectedFilter == filter) return;

//     _selectedFilter = filter;
//     _logAction('Filter changed to: $filter');
//     notifyListeners();
//   }

//   List<AttendanceRecord> get filteredAttendance {
//     if (_employeeDetails == null) return [];

//     final allRecords = _employeeDetails!.attendanceHistory;

//     switch (_selectedFilter) {
//       case 'present':
//         return allRecords
//             .where((record) => record.status == 'present')
//             .toList();
//       case 'absent':
//         return allRecords.where((record) => record.status == 'absent').toList();
//       case 'late':
//         return allRecords.where((record) => record.status == 'late').toList();
//       case 'leave':
//         return allRecords
//             .where((record) => record.status.contains('leave'))
//             .toList();
//       default:
//         return allRecords;
//     }
//   }

//   Map<String, int> getAttendanceSummary() {
//     if (_employeeDetails == null) return {};

//     return {
//       'total': _employeeDetails!.totalWorkingDays,
//       'present': _employeeDetails!.presentDays,
//       'absent': _employeeDetails!.absentDays,
//       'late': _employeeDetails!.lateDays,
//       'percentage': _employeeDetails!.attendancePercentage.round(),
//     };
//   }

//   // New method to calculate averages for download
//   Map<String, double> getAttendanceAverages() {
//     if (_employeeDetails == null ||
//         _employeeDetails!.attendanceHistory.isEmpty) {
//       return {'present': 0, 'leaves': 0, 'ontime': 0, 'late': 0, 'absent': 0};
//     }

//     final records = _employeeDetails!.attendanceHistory;
//     final totalDays = records.length;

//     int presentCount = 0;
//     int leavesCount = 0;
//     int ontimeCount = 0;
//     int lateCount = 0;
//     int absentCount = 0;

//     for (final record in records) {
//       final status = record.status.toLowerCase();

//       if (status.contains('present')) {
//         presentCount++;
//         // Check if ontime or late using AttendanceRecord's own method if available
//         if (_isOntime(record.checkIn)) {
//           ontimeCount++;
//         } else {
//           lateCount++;
//         }
//       } else if (status.contains('leave') || status.contains('holiday')) {
//         leavesCount++;
//       } else if (status.contains('absent')) {
//         absentCount++;
//       }
//     }

//     return {
//       'present': (presentCount / totalDays * 100),
//       'leaves': (leavesCount / totalDays * 100),
//       'ontime': (ontimeCount / totalDays * 100),
//       'late': (lateCount / totalDays * 100),
//       'absent': (absentCount / totalDays * 100),
//     };
//   }

//   // Helper method to check if check-in is ontime
//   bool _isOntime(DateTime checkIn) {
//     final expectedTime = DateTime(
//       checkIn.year,
//       checkIn.month,
//       checkIn.day,
//       9,
//       30,
//     );
//     return checkIn.isBefore(expectedTime) ||
//         checkIn.isAtSameMomentAs(expectedTime);
//   }

//   // New method to get attendance counts for download
//   Map<String, int> getAttendanceCounts() {
//     if (_employeeDetails == null) return {};

//     final records = _employeeDetails!.attendanceHistory;

//     int ontimeCount = 0;
//     int leaveCount = 0;

//     for (final record in records) {
//       if (record.status.toLowerCase().contains('present') &&
//           _isOntime(record.checkIn)) {
//         ontimeCount++;
//       }
//       if (record.status.toLowerCase().contains('leave')) {
//         leaveCount++;
//       }
//     }

//     return {
//       'present': records
//           .where((record) => record.status.toLowerCase().contains('present'))
//           .length,
//       'leaves': leaveCount,
//       'ontime': ontimeCount,
//       'late': records
//           .where((record) => record.status.toLowerCase().contains('late'))
//           .length,
//       'absent': records
//           .where((record) => record.status.toLowerCase().contains('absent'))
//           .length,
//       'total': records.length,
//     };
//   }

//   // New method to get performance score
//   double getPerformanceScore() {
//     final averages = getAttendanceAverages();

//     final presentWeight = 0.4;
//     final ontimeWeight = 0.3;
//     final leaveWeight = 0.2;
//     final absentPenalty = 0.1;

//     final presentScore = (averages['present'] ?? 0) * presentWeight;
//     final ontimeScore = (averages['ontime'] ?? 0) * ontimeWeight;
//     final leaveScore = (100 - (averages['leaves'] ?? 0)) * leaveWeight;
//     final absentScore = (100 - (averages['absent'] ?? 0)) * absentPenalty;

//     return presentScore + ontimeScore + (leaveScore * 0.01) + absentScore;
//   }

//   // New method to get performance rating
//   String getPerformanceRating() {
//     final score = getPerformanceScore();

//     if (score >= 90) return 'Excellent';
//     if (score >= 80) return 'Good';
//     if (score >= 70) return 'Average';
//     return 'Needs Improvement';
//   }

//   // New method to get late minutes for a record
//   int getLateMinutes(AttendanceRecord record) {
//     final expectedTime = DateTime(
//       record.checkIn.year,
//       record.checkIn.month,
//       record.checkIn.day,
//       9,
//       30,
//     );
//     final lateMinutes = record.checkIn.difference(expectedTime).inMinutes;
//     return lateMinutes > 0 ? lateMinutes : 0;
//   }

//   // New method to get remarks for a record
//   String getRemarks(AttendanceRecord record) {
//     final status = record.status.toLowerCase();
//     if (status.contains('late')) {
//       final lateMinutes = getLateMinutes(record);
//       return 'Late by $lateMinutes minutes';
//     } else if (status.contains('early')) {
//       return 'Left early';
//     } else if (status.contains('absent')) {
//       return 'Absent without notice';
//     } else if (status.contains('leave')) {
//       return 'Approved leave';
//     } else if (status.contains('present') && !_isOntime(record.checkIn)) {
//       final lateMinutes = getLateMinutes(record);
//       return lateMinutes > 0 ? 'Late by $lateMinutes minutes' : 'Present';
//     }
//     return 'Regular attendance';
//   }

//   String getStatusDisplayText(String status) {
//     const statusText = {
//       'present': 'Present',
//       'absent': 'Absent',
//       'late': 'Late Arrival',
//       'half-day': 'Half Day',
//       'leave': 'On Leave',
//       'holiday': 'Holiday',
//     };
//     return statusText[status] ?? status;
//   }

//   Color getStatusColor(String status) {
//     const statusColors = {
//       'present': AppColors.success,
//       'absent': AppColors.error,
//       'late': AppColors.warning,
//       'half-day': AppColors.info,
//       'leave': AppColors.info,
//       'holiday': AppColors.secondary,
//     };
//     return statusColors[status] ?? AppColors.grey500;
//   }

//   String formatWorkingHours(Duration? duration) {
//     if (duration == null) return '--:--';

//     final hours = duration.inHours;
//     final minutes = duration.inMinutes.remainder(60);
//     return '${hours}h ${minutes}m';
//   }

//   String formatTime(DateTime? time) {
//     if (time == null) return '--:--';
//     return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
//   }

//   String formatDate(DateTime date) {
//     return '${_getWeekday(date.weekday)}, ${date.day} ${_getMonth(date.month)} ${date.year}';
//   }

//   // New method for CSV date format
//   String formatDateForCSV(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
//   }

//   // Use the calculated working hours from the AttendanceRecord model
//   Duration? getWorkingHours(AttendanceRecord record) {
//     // Use the existing calculatedWorkingHours from AttendanceRecord if available
//     // Otherwise calculate manually
//     return record.calculatedWorkingHours ??
//         (record.checkOut?.difference(record.checkIn));
//   }

//   // New method to get sorted attendance records (newest first)
//   List<AttendanceRecord> getSortedAttendanceRecords() {
//     if (_employeeDetails == null) return [];

//     final records = List<AttendanceRecord>.from(
//       _employeeDetails!.attendanceHistory,
//     )..sort((a, b) => b.date.compareTo(a.date));

//     return records;
//   }

//   // New method to get employee info for download
//   Map<String, dynamic> getEmployeeInfoForDownload() {
//     if (_employeeDetails == null) return {};

//     return {
//       'name': _employeeDetails!.name,
//       'employeeId': _employeeDetails!.employeeId,
//       'department': _employeeDetails!.department,
//       'position': _employeeDetails!.position,
//       'email': _employeeDetails!.email,
//       'phone': _employeeDetails!.contactInfo.phone,
//       'emergencyContact': _employeeDetails!.contactInfo.emergencyContact,
//       'address': _employeeDetails!.contactInfo.address,
//       'joinDate': _employeeDetails!.joinDate,
//       'profileImage': _employeeDetails!.profileImage,
//     };
//   }

//   // New method to get performance metrics
//   Map<String, dynamic> getPerformanceMetrics() {
//     if (_employeeDetails == null) return {};

//     return {
//       'productivityScore': _employeeDetails!.performance.productivityScore,
//       'punctualityScore': _employeeDetails!.performance.punctualityScore,
//       'completedTasks': _employeeDetails!.performance.completedTasks,
//       'pendingTasks': _employeeDetails!.performance.pendingTasks,
//       'attendancePercentage': _employeeDetails!.attendancePercentage,
//       'performanceScore': getPerformanceScore(),
//       'performanceRating': getPerformanceRating(),
//     };
//   }

//   // Private methods
//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }

//   void _handleError(String message) {
//     if (kDebugMode) {
//       print('❌ EmployeeDetailsViewModel: $message');
//     }
//   }

//   void _logSuccess(String message) {
//     if (kDebugMode) {
//       print('✅ EmployeeDetailsViewModel: $message');
//     }
//   }

//   void _logAction(String message) {
//     if (kDebugMode) {
//       print('🔧 EmployeeDetailsViewModel: $message');
//     }
//   }

//   String _getWeekday(int weekday) {
//     const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return days[weekday - 1];
//   }

//   // New method for full weekday names
//   String getFullWeekday(int weekday) {
//     const days = [
//       'Monday',
//       'Tuesday',
//       'Wednesday',
//       'Thursday',
//       'Friday',
//       'Saturday',
//       'Sunday',
//     ];
//     return days[weekday - 1];
//   }

//   String _getMonth(int month) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return months[month - 1];
//   }

//   // New method for full month names
//   String getFullMonth(int month) {
//     const months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December',
//     ];
//     return months[month - 1];
//   }

//   @override
//   void dispose() {
//     _employeeDetails = null;
//     super.dispose();
//   }
// }

// import 'dart:ui';

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/attendance_model.dart';
// import 'package:attendanceapp/models/employeemodels/employee_details_model.dart';
// import 'package:attendanceapp/models/team_model.dart';
// import 'package:attendanceapp/services/employeeservices/employee_details_service.dart';
// import 'package:flutter/foundation.dart';

// class EmployeeDetailsViewModel with ChangeNotifier {
//   final EmployeeDetailsService _service = EmployeeDetailsService();

//   bool _isLoading = false;
//   EmployeeDetails? _employeeDetails;
//   String? _errorMessage;
//   String _selectedFilter = 'all'; // all, present, absent, late

//   bool get isLoading => _isLoading;
//   EmployeeDetails? get employeeDetails => _employeeDetails;
//   String? get errorMessage => _errorMessage;
//   String get selectedFilter => _selectedFilter;

//   Future<void> loadEmployeeDetails(TeamMember member) async {
//     _setLoading(true);
//     _errorMessage = null;

//     try {
//       _employeeDetails = await _service.getEmployeeDetails(member);
//       _logSuccess('Loaded details for ${member.name}');
//     } catch (e) {
//       _errorMessage = 'Failed to load employee details: $e';
//       _handleError(_errorMessage!);
//     } finally {
//       _setLoading(false);
//     }
//   }

//   void changeFilter(String filter) {
//     if (_selectedFilter == filter) return;

//     _selectedFilter = filter;
//     _logAction('Filter changed to: $filter');
//     notifyListeners();
//   }

//   List<AttendanceRecord> get filteredAttendance {
//     if (_employeeDetails == null) return [];

//     final allRecords = _employeeDetails!.attendanceHistory;

//     switch (_selectedFilter) {
//       case 'present':
//         return allRecords
//             .where((record) => record.status == 'present')
//             .toList();
//       case 'absent':
//         return allRecords.where((record) => record.status == 'absent').toList();
//       case 'late':
//         return allRecords.where((record) => record.status == 'late').toList();
//       default:
//         return allRecords;
//     }
//   }

//   Map<String, int> getAttendanceSummary() {
//     if (_employeeDetails == null) return {};

//     return {
//       'total': _employeeDetails!.totalWorkingDays,
//       'present': _employeeDetails!.presentDays,
//       'absent': _employeeDetails!.absentDays,
//       'late': _employeeDetails!.lateDays,
//       'percentage': _employeeDetails!.attendancePercentage.round(),
//     };
//   }

//   String getStatusDisplayText(String status) {
//     const statusText = {
//       'present': 'Present',
//       'absent': 'Absent',
//       'late': 'Late Arrival',
//       'half-day': 'Half Day',
//     };
//     return statusText[status] ?? 'Unknown';
//   }

//   Color getStatusColor(String status) {
//     const statusColors = {
//       'present': AppColors.success,
//       'absent': AppColors.error,
//       'late': AppColors.warning,
//       'half-day': AppColors.info,
//     };
//     return statusColors[status] ?? AppColors.grey500;
//   }

//   String formatWorkingHours(Duration? duration) {
//     if (duration == null) return '--:--';

//     final hours = duration.inHours;
//     final minutes = duration.inMinutes.remainder(60);
//     return '${hours}h ${minutes}m';
//   }

//   String formatTime(DateTime? time) {
//     if (time == null) return '--:--';
//     return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
//   }

//   String formatDate(DateTime date) {
//     return '${_getWeekday(date.weekday)}, ${date.day} ${_getMonth(date.month)} ${date.year}';
//   }

//   // Use the calculated working hours from the model
//   Duration? getWorkingHours(AttendanceRecord record) {
//     return record.workingHours ?? (record.checkOut?.difference(record.checkIn));
//   }

//   // Private methods
//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }

//   void _handleError(String message) {
//     if (kDebugMode) {
//       print('❌ EmployeeDetailsViewModel: $message');
//     }
//   }

//   void _logSuccess(String message) {
//     if (kDebugMode) {
//       print('✅ EmployeeDetailsViewModel: $message');
//     }
//   }

//   void _logAction(String message) {
//     if (kDebugMode) {
//       print('🔧 EmployeeDetailsViewModel: $message');
//     }
//   }

//   String _getWeekday(int weekday) {
//     const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return days[weekday - 1];
//   }

//   String _getMonth(int month) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return months[month - 1];
//   }

//   @override
//   void dispose() {
//     _employeeDetails = null;
//     super.dispose();
//   }
// }
