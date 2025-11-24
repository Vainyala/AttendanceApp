import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_saver/file_saver.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:attendanceapp/manager/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
import 'package:attendanceapp/manager/models/team_model.dart';

class TeamAttendanceExcelDownloadButton extends StatelessWidget {
  final AttendanceAnalyticsViewModel viewModel;
  final VoidCallback? onDownloadComplete;
  final VoidCallback? onDownloadError;

  const TeamAttendanceExcelDownloadButton({
    super.key,
    required this.viewModel,
    this.onDownloadComplete,
    this.onDownloadError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        // gradient: LinearGradient(
        //   colors: [Colors.green.shade600, Colors.green.shade400],
        // ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade800.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _downloadTeamAttendanceExcel(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.download_rounded, color: Colors.white, size: 20),
                // const SizedBox(width: 8),
                // Text(
                //   'EXPORT TEAM DATA',
                //   style: TextStyle(
                //     fontSize: 14,
                //     fontWeight: FontWeight.w800,
                //     color: Colors.white,
                //     letterSpacing: 0.8,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadTeamAttendanceExcel(BuildContext context) async {
    try {
      // Show loading dialog
      _showLoadingDialog(context);

      // Get team data
      final teamMembers = viewModel.teamMembers;
      if (teamMembers.isEmpty) {
        _hideLoadingDialog(context);
        _showErrorSnackBar(context, 'No team members found');
        onDownloadError?.call();
        return;
      }

      // Generate comprehensive team attendance data
      final csvData = await _generateTeamAttendanceCSV(teamMembers);

      // Convert to bytes
      final listToCsvConverter = ListToCsvConverter();
      final csvString = listToCsvConverter.convert(csvData);
      final bytes = utf8.encode(csvString);

      // Create file name
      final now = DateTime.now();
      final fileName =
          'Team_Attendance_Report_${DateFormat('MMM_yyyy').format(now)}.csv';

      // Save file - FIXED: Removed 'ext' parameter
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        mimeType: MimeType.csv,
      );

      // Hide loading dialog
      _hideLoadingDialog(context);

      // Show success message
      _showSuccessSnackBar(
        context,
        'Team attendance report downloaded successfully!',
      );

      onDownloadComplete?.call();
    } catch (e) {
      _hideLoadingDialog(context);
      _showErrorSnackBar(context, 'Failed to download: ${e.toString()}');
      onDownloadError?.call();
    }
  }

  Future<List<List<dynamic>>> _generateTeamAttendanceCSV(
    List<TeamMember> teamMembers,
  ) async {
    final List<List<dynamic>> csvData = [];

    // Add headers
    csvData.add(['TEAM ATTENDANCE REPORT', '', '', '', '', '', '', '', '', '']);

    csvData.add([
      'Generated Date',
      DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);

    csvData.add([
      'Total Team Members',
      teamMembers.length,
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);

    csvData.add([]); // Empty row

    // Add period information
    final period = viewModel.selectedPeriod;
    final periodDisplay = viewModel.getPeriodDisplayName(period);
    final periodDates = _getCurrentPeriodDateRange();

    csvData.add([
      'Report Period',
      periodDisplay,
      '',
      '',
      '',
      'Date Range',
      periodDates['start'] ?? '',
      'to',
      periodDates['end'] ?? '',
      '',
    ]);

    csvData.add([]); // Empty row

    // Main data headers
    csvData.add([
      'Employee ID',
      'Employee Name',
      'Role',
      'Department',
      'Email',
      'Phone',
      'Status',
      'Present Days',
      'Absent Days',
      'Leave Days',
      'Late Days',
      'Total Working Days',
      'Attendance Rate %',
      'Average Hours/Day',
      'Productivity Score %',
      'Last Check-in',
      'Last Check-out',
    ]);

    // Add individual employee data
    for (final member in teamMembers) {
      final Map<String, dynamic> attendanceData = viewModel
          .getPeriodAttendanceData(member.email);
      final individualData =
          viewModel.analytics?.individualData[member.email] ?? {};

      // FIXED: Convert num to int properly
      final present = _safeConvertToInt(attendanceData['present']);
      final absent = _safeConvertToInt(attendanceData['absent']);
      final leave = _safeConvertToInt(attendanceData['leave']);
      final late = _safeConvertToInt(attendanceData['late']);

      final totalDays = present + absent + leave + late;
      final attendanceRate = totalDays > 0 ? ((present / totalDays) * 100) : 0;

      csvData.add([
        member.id?.toString() ?? 'N/A',
        member.name,
        member.role,
        member.department ?? 'General',
        member.email,
        member.phoneNumber ?? 'N/A',
        member.status,
        present,
        absent,
        leave,
        late,
        totalDays,
        attendanceRate.toStringAsFixed(1),
        (individualData['avgHours'] ?? 0.0).toStringAsFixed(1),
        (individualData['productivity'] ?? 0.0).toStringAsFixed(1),
        attendanceData['checkin']?.toString() ?? 'N/A',
        attendanceData['checkout']?.toString() ?? 'N/A',
      ]);
    }

    csvData.add([]); // Empty row

    // Add summary statistics
    _addSummaryStatistics(csvData, teamMembers);

    // Add performance insights
    _addPerformanceInsights(csvData, teamMembers);

    return csvData;
  }

  // FIXED: Helper method to safely convert num to int
  int _safeConvertToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, String> _getCurrentPeriodDateRange() {
    final period = viewModel.selectedPeriod;
    final selectedDate = viewModel.selectedDate;
    final dateFormat = DateFormat('dd/MM/yyyy');

    switch (period) {
      case 'daily':
        final dateStr = dateFormat.format(selectedDate);
        return {'start': dateStr, 'end': dateStr};

      case 'weekly':
        final weekStart = viewModel.getFirstDayOfWeek(selectedDate);
        final weekEnd = weekStart.add(const Duration(days: 6));
        return {
          'start': dateFormat.format(weekStart),
          'end': dateFormat.format(weekEnd),
        };

      case 'monthly':
        final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
        final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);
        return {
          'start': dateFormat.format(firstDay),
          'end': dateFormat.format(lastDay),
        };

      case 'quarterly':
        final quarter = ((selectedDate.month - 1) ~/ 3) + 1;
        final startMonth = (quarter - 1) * 3 + 1;
        final endMonth = startMonth + 2;
        final firstDay = DateTime(selectedDate.year, startMonth, 1);
        final lastDay = DateTime(selectedDate.year, endMonth + 1, 0);
        return {
          'start': dateFormat.format(firstDay),
          'end': dateFormat.format(lastDay),
        };

      default:
        return {'start': '', 'end': ''};
    }
  }

  void _addSummaryStatistics(
    List<List<dynamic>> csvData,
    List<TeamMember> teamMembers,
  ) {
    int totalPresent = 0;
    int totalAbsent = 0;
    int totalLeave = 0;
    int totalLate = 0;
    double totalAttendanceRate = 0;
    double totalProductivity = 0;
    int activeMembers = 0;

    for (final member in teamMembers) {
      final Map<String, dynamic> attendanceData = viewModel
          .getPeriodAttendanceData(member.email);
      final individualData =
          viewModel.analytics?.individualData[member.email] ?? {};

      // FIXED: Use safe conversion
      totalPresent += _safeConvertToInt(attendanceData['present']);
      totalAbsent += _safeConvertToInt(attendanceData['absent']);
      totalLeave += _safeConvertToInt(attendanceData['leave']);
      totalLate += _safeConvertToInt(attendanceData['late']);

      final present = _safeConvertToInt(attendanceData['present']);
      final totalDays =
          present +
          _safeConvertToInt(attendanceData['absent']) +
          _safeConvertToInt(attendanceData['leave']) +
          _safeConvertToInt(attendanceData['late']);

      if (totalDays > 0) {
        totalAttendanceRate += (present / totalDays) * 100;
        activeMembers++;
      }

      totalProductivity += (individualData['productivity'] ?? 0).toDouble();
    }

    final avgAttendanceRate = activeMembers > 0
        ? totalAttendanceRate / activeMembers
        : 0;
    final avgProductivity = teamMembers.isNotEmpty
        ? totalProductivity / teamMembers.length
        : 0;

    csvData.add([
      'SUMMARY STATISTICS',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);
    csvData.add([
      'Metric',
      'Value',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);
    csvData.add([
      'Total Team Members',
      teamMembers.length,
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);
    csvData.add([
      'Total Present Days',
      totalPresent,
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);
    csvData.add([
      'Total Absent Days',
      totalAbsent,
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);
    csvData.add([
      'Total Leave Days',
      totalLeave,
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);
    csvData.add([
      'Total Late Days',
      totalLate,
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);
    csvData.add([
      'Average Attendance Rate',
      '${avgAttendanceRate.toStringAsFixed(1)}%',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);
    csvData.add([
      'Average Productivity',
      '${avgProductivity.toStringAsFixed(1)}%',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);

    csvData.add([]); // Empty row
  }

  void _addPerformanceInsights(
    List<List<dynamic>> csvData,
    List<TeamMember> teamMembers,
  ) {
    csvData.add([
      'PERFORMANCE INSIGHTS',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);

    // Calculate overall metrics
    double totalAttendance = 0;
    int membersWithData = 0;

    for (final member in teamMembers) {
      final Map<String, dynamic> attendanceData = viewModel
          .getPeriodAttendanceData(member.email);
      final present = _safeConvertToInt(attendanceData['present']);
      final totalDays =
          present +
          _safeConvertToInt(attendanceData['absent']) +
          _safeConvertToInt(attendanceData['leave']) +
          _safeConvertToInt(attendanceData['late']);

      if (totalDays > 0) {
        totalAttendance += (present / totalDays) * 100;
        membersWithData++;
      }
    }

    final overallAttendance = membersWithData > 0
        ? totalAttendance / membersWithData
        : 0;

    if (overallAttendance >= 90) {
      csvData.add([
        '• Excellent overall team attendance performance',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
      ]);
    } else if (overallAttendance >= 80) {
      csvData.add([
        '• Good team attendance meeting expectations',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
      ]);
    } else {
      csvData.add([
        '• Team attendance needs improvement',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
      ]);
    }

    // Count active vs inactive members
    final activeMembers = teamMembers
        .where((m) => m.status.toLowerCase() == 'active')
        .length;
    final inactiveMembers = teamMembers.length - activeMembers;

    csvData.add([
      '• Active Team Members: $activeMembers',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);
    if (inactiveMembers > 0) {
      csvData.add([
        '• Inactive Team Members: $inactiveMembers',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
      ]);
    }

    // Department breakdown
    final departments = <String, int>{};
    for (final member in teamMembers) {
      final dept = member.department ?? 'General';
      departments[dept] = (departments[dept] ?? 0) + 1;
    }

    csvData.add([
      '• Department Distribution:',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);
    departments.forEach((dept, count) {
      csvData.add([
        '  - $dept: $count members',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
      ]);
    });

    csvData.add([]); // Empty row
    csvData.add([
      'Report generated by AttendanceApp Analytics',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Generating Team Report',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Compiling attendance data for ${viewModel.teamMembers.length} team members...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _hideLoadingDialog(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:attendanceapp/models/attendancemodels/attendance_analytics_model.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';

// class DownloadExcelButton extends StatelessWidget {
//   final AttendanceAnalyticsViewModel viewModel;
//   final VoidCallback? onDownloadComplete;
//   final VoidCallback? onDownloadError;

//   const DownloadExcelButton({
//     super.key,
//     required this.viewModel,
//     this.onDownloadComplete,
//     this.onDownloadError,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.green.shade600.withOpacity(0.8),
//             Colors.green.shade400.withOpacity(0.6),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.green.shade800.withOpacity(0.4),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => _downloadLastMonthData(context),
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.download_rounded, color: Colors.white, size: 20),
//                 // const SizedBox(width: 8),
//                 // Text(
//                 //   'EXPORT LAST MONTH',
//                 //   style: TextStyle(
//                 //     fontSize: 14,
//                 //     fontWeight: FontWeight.w800,
//                 //     color: Colors.white,
//                 //     letterSpacing: 0.8,
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _downloadLastMonthData(BuildContext context) async {
//     final analytics = viewModel.analytics;
//     if (analytics == null) {
//       _showErrorSnackBar(context, 'No data available to export');
//       onDownloadError?.call();
//       return;
//     }

//     try {
//       // Show loading indicator
//       _showLoadingDialog(context);

//       // Get last month data with enhanced calculation
//       final lastMonthData = _getLastMonthData(analytics);

//       if (lastMonthData.isEmpty) {
//         if (Navigator.of(context).canPop()) {
//           Navigator.of(context).pop();
//         }
//         _showErrorSnackBar(context, 'No data available for last month');
//         onDownloadError?.call();
//         return;
//       }

//       // Generate enhanced CSV data
//       final csvData = _generateLastMonthCSV(lastMonthData);

//       // Convert to bytes
//       final bytes = utf8.encode(csvData);

//       // Create file name for last month with better format
//       final now = DateTime.now();
//       final lastMonth = DateTime(now.year, now.month - 1, 1);
//       final fileName =
//           'Team_Attendance_${_getMonthName(lastMonth.month)}_${lastMonth.year}.csv';

//       // Download file with enhanced notification
//       await _downloadWithNotification(context, bytes, fileName, lastMonth);

//       // Close loading dialog
//       if (Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }

//       // Show success message
//       _showSuccessSnackBar(context, fileName);

//       // Call completion callback
//       onDownloadComplete?.call();
//     } catch (e) {
//       // Close loading dialog if still open
//       if (Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }

//       _showErrorSnackBar(context, 'Failed to export data: $e');
//       onDownloadError?.call();
//     }
//   }

//   Map<String, Map<String, dynamic>> _getLastMonthData(
//     AttendanceAnalytics analytics,
//   ) {
//     final lastMonthData = <String, Map<String, dynamic>>{};
//     final now = DateTime.now();
//     final lastMonth = DateTime(now.year, now.month - 1, 1);
//     final firstDayLastMonth = lastMonth;
//     final lastDayLastMonth = DateTime(now.year, now.month, 0);

//     final graphData = analytics.graphData;
//     final labels = analytics.labels;
//     final teamMembers = viewModel.teamMembers;

//     for (int i = 0; i < labels.length; i++) {
//       final dateStr = labels[i];
//       final date = _parseDate(dateStr);

//       if (date != null &&
//           date.isAfter(firstDayLastMonth.subtract(const Duration(days: 1))) &&
//           date.isBefore(lastDayLastMonth.add(const Duration(days: 1)))) {
//         final present = graphData['present']?[i] ?? 0;
//         final late = graphData['late']?[i] ?? 0;
//         final absent = graphData['absent']?[i] ?? 0;

//         // Enhanced calculation with team member context
//         final ontime = present - late > 0 ? present - late : 0;
//         final leave = _calculateLeaveCount(
//           teamMembers.length,
//           present,
//           late,
//           absent,
//         );
//         final totalTeamMembers = teamMembers.length;
//         final presentPercentage = totalTeamMembers > 0
//             ? (present / totalTeamMembers * 100)
//             : 0;
//         final absentPercentage = totalTeamMembers > 0
//             ? (absent / totalTeamMembers * 100)
//             : 0;
//         final latePercentage = totalTeamMembers > 0
//             ? (late / totalTeamMembers * 100)
//             : 0;

//         lastMonthData[dateStr] = {
//           'date': dateStr,
//           'day': _getDayName(date.weekday),
//           'present': present,
//           'leave': leave,
//           'ontime': ontime,
//           'late': late,
//           'absent': absent,
//           'total_team_members': totalTeamMembers,
//           'present_percentage': presentPercentage,
//           'absent_percentage': absentPercentage,
//           'late_percentage': latePercentage,
//         };
//       }
//     }

//     return lastMonthData;
//   }

//   double _calculateLeaveCount(
//     int totalMembers,
//     double present,
//     double late,
//     double absent,
//   ) {
//     // Calculate leaves as remaining members after accounting for present, late, and absent
//     final accountedMembers = present + late + absent;
//     return (totalMembers - accountedMembers) > 0
//         ? (totalMembers - accountedMembers).toDouble()
//         : 0;
//   }

//   DateTime? _parseDate(String dateStr) {
//     try {
//       // Enhanced date parsing for multiple formats
//       if (dateStr.contains('-')) {
//         final parts = dateStr.split('-');
//         if (parts.length == 3) {
//           return DateTime(
//             int.parse(parts[0]),
//             int.parse(parts[1]),
//             int.parse(parts[2]),
//           );
//         } else if (parts.length == 2) {
//           // Handle formats like "15-Jan"
//           final now = DateTime.now();
//           final monthNames = {
//             'jan': 1,
//             'feb': 2,
//             'mar': 3,
//             'apr': 4,
//             'may': 5,
//             'jun': 6,
//             'jul': 7,
//             'aug': 8,
//             'sep': 9,
//             'oct': 10,
//             'nov': 11,
//             'dec': 12,
//           };
//           final month = monthNames[parts[1].toLowerCase()];
//           if (month != null) {
//             return DateTime(now.year, month, int.parse(parts[0]));
//           }
//         }
//       } else if (dateStr.contains('/')) {
//         final parts = dateStr.split('/');
//         if (parts.length == 3) {
//           return DateTime(
//             int.parse(parts[2]),
//             int.parse(parts[1]),
//             int.parse(parts[0]),
//           );
//         }
//       }
//       return null;
//     } catch (e) {
//       return null;
//     }
//   }

//   String _getDayName(int weekday) {
//     const days = {
//       1: 'Monday',
//       2: 'Tuesday',
//       3: 'Wednesday',
//       4: 'Thursday',
//       5: 'Friday',
//       6: 'Saturday',
//       7: 'Sunday',
//     };
//     return days[weekday] ?? 'Unknown';
//   }

//   String _getMonthName(int month) {
//     const months = {
//       1: 'January',
//       2: 'February',
//       3: 'March',
//       4: 'April',
//       5: 'May',
//       6: 'June',
//       7: 'July',
//       8: 'August',
//       9: 'September',
//       10: 'October',
//       11: 'November',
//       12: 'December',
//     };
//     return months[month] ?? 'Unknown';
//   }

//   String _generateLastMonthCSV(
//     Map<String, Map<String, dynamic>> lastMonthData,
//   ) {
//     final buffer = StringBuffer();
//     final now = DateTime.now();
//     final lastMonth = DateTime(now.year, now.month - 1, 1);
//     final teamMembers = viewModel.teamMembers;

//     // Enhanced header information
//     buffer.writeln(
//       'TEAM ATTENDANCE REPORT - ${_getMonthName(lastMonth.month)} ${lastMonth.year}',
//     );
//     buffer.writeln('Generated on: ${DateTime.now().toString()}');
//     buffer.writeln(
//       'Report Period: ${_getMonthName(lastMonth.month)} ${lastMonth.year}',
//     );
//     buffer.writeln('Total Team Members: ${teamMembers.length}');
//     buffer.writeln('Total Working Days: ${lastMonthData.length}');
//     buffer.writeln();

//     // Enhanced summary statistics
//     double totalPresent = 0;
//     double totalLeave = 0;
//     double totalOntime = 0;
//     double totalLate = 0;
//     double totalAbsent = 0;
//     int totalRecords = lastMonthData.length;

//     lastMonthData.forEach((date, data) {
//       totalPresent += data['present'] ?? 0;
//       totalLeave += data['leave'] ?? 0;
//       totalOntime += data['ontime'] ?? 0;
//       totalLate += data['late'] ?? 0;
//       totalAbsent += data['absent'] ?? 0;
//     });

//     final totalTeamMemberDays = teamMembers.length * totalRecords;
//     final averageDailyPresent = totalRecords > 0
//         ? totalPresent / totalRecords
//         : 0;
//     final averageDailyAbsent = totalRecords > 0
//         ? totalAbsent / totalRecords
//         : 0;

//     buffer.writeln('MONTHLY SUMMARY STATISTICS');
//     buffer.writeln('Total Present: ${totalPresent.toInt()}');
//     buffer.writeln('Total Leaves: ${totalLeave.toInt()}');
//     buffer.writeln('Total Ontime: ${totalOntime.toInt()}');
//     buffer.writeln('Total Late: ${totalLate.toInt()}');
//     buffer.writeln('Total Absent: ${totalAbsent.toInt()}');
//     buffer.writeln('Total Team Member Days: $totalTeamMemberDays');
//     buffer.writeln(
//       'Average Daily Present: ${averageDailyPresent.toStringAsFixed(1)}',
//     );
//     buffer.writeln(
//       'Average Daily Absent: ${averageDailyAbsent.toStringAsFixed(1)}',
//     );

//     if (totalTeamMemberDays > 0) {
//       buffer.writeln(
//         'Overall Present Rate: ${(totalPresent / totalTeamMemberDays * 100).toStringAsFixed(1)}%',
//       );
//       buffer.writeln(
//         'Overall Leave Rate: ${(totalLeave / totalTeamMemberDays * 100).toStringAsFixed(1)}%',
//       );
//       buffer.writeln(
//         'Overall Ontime Rate: ${(totalOntime / totalTeamMemberDays * 100).toStringAsFixed(1)}%',
//       );
//       buffer.writeln(
//         'Overall Late Rate: ${(totalLate / totalTeamMemberDays * 100).toStringAsFixed(1)}%',
//       );
//       buffer.writeln(
//         'Overall Absent Rate: ${(totalAbsent / totalTeamMemberDays * 100).toStringAsFixed(1)}%',
//       );
//     }
//     buffer.writeln();

//     // Enhanced data table header
//     buffer.writeln('DAILY ATTENDANCE BREAKDOWN');
//     buffer.writeln(
//       'Date,Day,Present,Leave,Ontime,Late,Absent,Total,Present %,Absent %,Late %',
//     );

//     // Sort dates chronologically
//     final sortedDates = lastMonthData.keys.toList()
//       ..sort((a, b) {
//         final dateA = _parseDate(a);
//         final dateB = _parseDate(b);
//         return dateA?.compareTo(dateB ?? DateTime.now()) ?? 0;
//       });

//     // Enhanced data rows
//     for (final dateStr in sortedDates) {
//       final data = lastMonthData[dateStr]!;
//       final present = data['present'] ?? 0;
//       final leave = data['leave'] ?? 0;
//       final ontime = data['ontime'] ?? 0;
//       final late = data['late'] ?? 0;
//       final absent = data['absent'] ?? 0;
//       final total = present + leave + late + absent;
//       final presentPercentage = data['present_percentage'] ?? 0;
//       final absentPercentage = data['absent_percentage'] ?? 0;
//       final latePercentage = data['late_percentage'] ?? 0;

//       buffer.write('"$dateStr",');
//       buffer.write('${data['day']},');
//       buffer.write('$present,');
//       buffer.write('$leave,');
//       buffer.write('$ontime,');
//       buffer.write('$late,');
//       buffer.write('$absent,');
//       buffer.write('$total,');
//       buffer.write('${presentPercentage.toStringAsFixed(1)}%,');
//       buffer.write('${absentPercentage.toStringAsFixed(1)}%,');
//       buffer.write('${latePercentage.toStringAsFixed(1)}%');
//       buffer.writeln();
//     }

//     // Enhanced team member list
//     if (teamMembers.isNotEmpty) {
//       buffer.writeln();
//       buffer.writeln('TEAM MEMBER DETAILS');
//       buffer.writeln('Name,Role,Email,Phone,Status');
//       for (final member in teamMembers) {
//         buffer.writeln(
//           '"${member.name}","${member.role}","${member.email}","${member.phoneNumber}","${member.status}"',
//         );
//       }
//     }

//     // Add performance insights
//     buffer.writeln();
//     buffer.writeln('PERFORMANCE INSIGHTS');
//     final overallAttendanceRate = totalTeamMemberDays > 0
//         ? (totalPresent / totalTeamMemberDays * 100)
//         : 0;

//     if (overallAttendanceRate >= 90) {
//       buffer.writeln('• Excellent team attendance performance');
//     } else if (overallAttendanceRate >= 80) {
//       buffer.writeln('• Good team attendance performance');
//     } else {
//       buffer.writeln('• Team attendance needs improvement');
//     }

//     if (totalLate / totalTeamMemberDays * 100 <= 5) {
//       buffer.writeln('• Excellent punctuality across team');
//     } else {
//       buffer.writeln('• Punctuality needs attention');
//     }

//     if (totalAbsent / totalTeamMemberDays * 100 <= 3) {
//       buffer.writeln('• Low absenteeism rate');
//     } else {
//       buffer.writeln('• High absenteeism rate detected');
//     }

//     return buffer.toString();
//   }

//   Future<void> _downloadWithNotification(
//     BuildContext context,
//     List<int> bytes,
//     String fileName,
//     DateTime lastMonth,
//   ) async {
//     // Show download started notification
//     _showDownloadNotification(
//       context,
//       fileName,
//       'Preparing ${_getMonthName(lastMonth.month)} attendance report...',
//     );

//     // Simulate download process with progress
//     for (int progress = 0; progress <= 100; progress += 20) {
//       await Future.delayed(const Duration(milliseconds: 200));
//     }

//     // Show file save dialog
//     _showFileSaveDialog(context, bytes, fileName, lastMonth);
//   }

//   void _showDownloadNotification(
//     BuildContext context,
//     String fileName,
//     String message,
//   ) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         backgroundColor: Colors.green.shade600,
//         content: Row(
//           children: [
//             CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//               strokeWidth: 2,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Exporting Report...',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                     ),
//                   ),
//                   Text(
//                     message,
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.9),
//                       fontSize: 12,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         duration: const Duration(seconds: 3),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   void _showFileSaveDialog(
//     BuildContext context,
//     List<int> bytes,
//     String fileName,
//     DateTime lastMonth,
//   ) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.black.withOpacity(0.95),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//           side: BorderSide(color: Colors.green.shade400, width: 1.5),
//         ),
//         title: Text(
//           'Team Report Ready!',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'File: $fileName',
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.8),
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Period: ${_getMonthName(lastMonth.month)} ${lastMonth.year}',
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.7),
//                 fontSize: 12,
//               ),
//             ),
//             Text(
//               'Team Members: ${viewModel.teamMembers.length}',
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.7),
//                 fontSize: 12,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'The comprehensive team attendance report has been generated and is ready for download.',
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.7),
//                 fontSize: 12,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.green.shade800.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.green.shade400),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.check_circle,
//                     color: Colors.green.shade400,
//                     size: 20,
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Report generated successfully',
//                       style: TextStyle(
//                         color: Colors.green.shade400,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text(
//               'CLOSE',
//               style: TextStyle(
//                 color: Colors.grey.shade400,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               _copyToClipboard(context, utf8.decode(bytes));
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green.shade600,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: Text(
//               'VIEW DATA',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _copyToClipboard(BuildContext context, String text) {
//     // For actual clipboard functionality:
//     // Clipboard.setData(ClipboardData(text: text));

//     _showSuccessSnackBar(context, 'Team attendance data copied to clipboard!');
//   }

//   void _showLoadingDialog(BuildContext context) {
//     final now = DateTime.now();
//     final lastMonth = DateTime(now.year, now.month - 1, 1);
//     final monthName = _getMonthName(lastMonth.month);

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.black.withOpacity(0.9),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//           side: BorderSide(color: Colors.green.shade400, width: 1.5),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
//               strokeWidth: 3,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Generating Team Report',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Analyzing $monthName ${lastMonth.year} team attendance data...',
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.7),
//                 fontSize: 12,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Team Members: ${viewModel.teamMembers.length}',
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.6),
//                 fontSize: 11,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showSuccessSnackBar(
//     BuildContext context, [
//     String message = 'Team attendance data exported successfully!',
//   ]) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         backgroundColor: Colors.green.shade600,
//         content: Row(
//           children: [
//             Icon(Icons.check_circle, color: Colors.white),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 message,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         duration: const Duration(seconds: 4),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   void _showErrorSnackBar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         backgroundColor: Colors.red.shade600,
//         content: Row(
//           children: [
//             Icon(Icons.error_outline, color: Colors.white),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 message,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         duration: const Duration(seconds: 4),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:attendanceapp/models/attendancemodels/attendance_analytics_model.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';

// class DownloadExcelButton extends StatelessWidget {
//   final AttendanceAnalyticsViewModel viewModel;
//   final VoidCallback? onDownloadComplete;
//   final VoidCallback? onDownloadError;

//   const DownloadExcelButton({
//     super.key,
//     required this.viewModel,
//     this.onDownloadComplete,
//     this.onDownloadError,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.green.shade600.withOpacity(0.8),
//             Colors.green.shade400.withOpacity(0.6),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.green.shade800.withOpacity(0.4),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => _downloadLastMonthData(context),
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.download_rounded, color: Colors.white, size: 20),
//                 const SizedBox(width: 8),
//                 Text(
//                   'EXPORT LAST MONTH',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w800,
//                     color: Colors.white,
//                     letterSpacing: 0.8,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _downloadLastMonthData(BuildContext context) async {
//     final analytics = viewModel.analytics;
//     if (analytics == null) {
//       _showErrorSnackBar(context, 'No data available to export');
//       onDownloadError?.call();
//       return;
//     }

//     try {
//       // Show loading indicator
//       _showLoadingDialog(context);

//       // Get last month data
//       final lastMonthData = _getLastMonthData(analytics);

//       if (lastMonthData.isEmpty) {
//         if (Navigator.of(context).canPop()) {
//           Navigator.of(context).pop();
//         }
//         _showErrorSnackBar(context, 'No data available for last month');
//         onDownloadError?.call();
//         return;
//       }

//       // Generate CSV data
//       final csvData = _generateLastMonthCSV(lastMonthData);

//       // Convert to bytes
//       final bytes = utf8.encode(csvData);

//       // Create file name for last month
//       final now = DateTime.now();
//       final lastMonth = DateTime(now.year, now.month - 1, 1);
//       final fileName =
//           'Attendance_LastMonth_${_getMonthName(lastMonth.month)}_${lastMonth.year}.csv';

//       // Download file
//       await _downloadFile(context, bytes, fileName);

//       // Close loading dialog
//       if (Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }

//       // Show success message
//       _showSuccessSnackBar(context, fileName);

//       // Call completion callback
//       onDownloadComplete?.call();
//     } catch (e) {
//       // Close loading dialog if still open
//       if (Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }

//       _showErrorSnackBar(context, 'Failed to export data: $e');
//       onDownloadError?.call();
//     }
//   }

//   Map<String, Map<String, dynamic>> _getLastMonthData(
//     AttendanceAnalytics analytics,
//   ) {
//     final lastMonthData = <String, Map<String, dynamic>>{};
//     final now = DateTime.now();
//     final lastMonth = DateTime(now.year, now.month - 1, 1);
//     final firstDayLastMonth = lastMonth;
//     final lastDayLastMonth = DateTime(now.year, now.month, 0);

//     final graphData = analytics.graphData;
//     final labels = analytics.labels;
//     final teamMembers = viewModel.teamMembers;

//     for (int i = 0; i < labels.length; i++) {
//       final dateStr = labels[i];
//       final date = _parseDate(dateStr);

//       if (date != null &&
//           date.isAfter(firstDayLastMonth.subtract(const Duration(days: 1))) &&
//           date.isBefore(lastDayLastMonth.add(const Duration(days: 1)))) {
//         final present = graphData['present']?[i] ?? 0;
//         final late = graphData['late']?[i] ?? 0;
//         final absent = graphData['absent']?[i] ?? 0;

//         // Calculate ontime (present - late)
//         final ontime = present - late > 0 ? present - late : 0;
//         // Leave data would come from your actual data model
//         final leave = 0.0; // Replace with actual leave data from your model

//         lastMonthData[dateStr] = {
//           'date': dateStr,
//           'day': _getDayName(date.weekday),
//           'present': present,
//           'leave': leave,
//           'ontime': ontime,
//           'late': late,
//           'absent': absent,
//         };
//       }
//     }

//     return lastMonthData;
//   }

//   DateTime? _parseDate(String dateStr) {
//     try {
//       // Adjust this based on your date format in labels
//       // Example formats: "2024-01-15", "15-Jan", "15/01/2024"
//       if (dateStr.contains('-')) {
//         final parts = dateStr.split('-');
//         if (parts.length == 3) {
//           return DateTime(
//             int.parse(parts[0]),
//             int.parse(parts[1]),
//             int.parse(parts[2]),
//           );
//         }
//       }
//       // Add more date parsing logic as needed for your specific format
//       return DateTime.now(); // fallback
//     } catch (e) {
//       return null;
//     }
//   }

//   String _getDayName(int weekday) {
//     switch (weekday) {
//       case 1:
//         return 'Monday';
//       case 2:
//         return 'Tuesday';
//       case 3:
//         return 'Wednesday';
//       case 4:
//         return 'Thursday';
//       case 5:
//         return 'Friday';
//       case 6:
//         return 'Saturday';
//       case 7:
//         return 'Sunday';
//       default:
//         return 'Unknown';
//     }
//   }

//   String _getMonthName(int month) {
//     switch (month) {
//       case 1:
//         return 'January';
//       case 2:
//         return 'February';
//       case 3:
//         return 'March';
//       case 4:
//         return 'April';
//       case 5:
//         return 'May';
//       case 6:
//         return 'June';
//       case 7:
//         return 'July';
//       case 8:
//         return 'August';
//       case 9:
//         return 'September';
//       case 10:
//         return 'October';
//       case 11:
//         return 'November';
//       case 12:
//         return 'December';
//       default:
//         return 'Unknown';
//     }
//   }

//   String _generateLastMonthCSV(
//     Map<String, Map<String, dynamic>> lastMonthData,
//   ) {
//     final buffer = StringBuffer();
//     final now = DateTime.now();
//     final lastMonth = DateTime(now.year, now.month - 1, 1);
//     final teamMembers = viewModel.teamMembers;

//     // Add header information
//     buffer.writeln('LAST MONTH ATTENDANCE REPORT');
//     buffer.writeln(
//       'Month: ${_getMonthName(lastMonth.month)} ${lastMonth.year}',
//     );
//     buffer.writeln('Generated on: ${DateTime.now().toString()}');
//     buffer.writeln('Total Team Members: ${teamMembers.length}');
//     buffer.writeln('Total Records: ${lastMonthData.length}');
//     buffer.writeln();

//     // Add summary statistics
//     double totalPresent = 0;
//     double totalLeave = 0;
//     double totalOntime = 0;
//     double totalLate = 0;
//     double totalAbsent = 0;

//     lastMonthData.forEach((date, data) {
//       totalPresent += data['present'] ?? 0;
//       totalLeave += data['leave'] ?? 0;
//       totalOntime += data['ontime'] ?? 0;
//       totalLate += data['late'] ?? 0;
//       totalAbsent += data['absent'] ?? 0;
//     });

//     final grandTotal = totalPresent + totalLeave + totalLate + totalAbsent;

//     buffer.writeln('MONTHLY SUMMARY');
//     buffer.writeln('Total Present: ${totalPresent.toInt()}');
//     buffer.writeln('Total Leave: ${totalLeave.toInt()}');
//     buffer.writeln('Total Ontime: ${totalOntime.toInt()}');
//     buffer.writeln('Total Late: ${totalLate.toInt()}');
//     buffer.writeln('Total Absent: ${totalAbsent.toInt()}');

//     if (grandTotal > 0) {
//       buffer.writeln(
//         'Present Rate: ${(totalPresent / grandTotal * 100).toStringAsFixed(1)}%',
//       );
//       buffer.writeln(
//         'Leave Rate: ${(totalLeave / grandTotal * 100).toStringAsFixed(1)}%',
//       );
//       buffer.writeln(
//         'Ontime Rate: ${(totalOntime / grandTotal * 100).toStringAsFixed(1)}%',
//       );
//       buffer.writeln(
//         'Late Rate: ${(totalLate / grandTotal * 100).toStringAsFixed(1)}%',
//       );
//       buffer.writeln(
//         'Absent Rate: ${(totalAbsent / grandTotal * 100).toStringAsFixed(1)}%',
//       );
//     }
//     buffer.writeln();

//     // Add data table header
//     buffer.writeln('DAILY ATTENDANCE DETAILS');
//     buffer.writeln('Date,Day,Present,Leave,Ontime,Late,Absent,Total,Present %');

//     // Sort dates chronologically
//     final sortedDates = lastMonthData.keys.toList()
//       ..sort((a, b) {
//         final dateA = _parseDate(a);
//         final dateB = _parseDate(b);
//         return dateA?.compareTo(dateB ?? DateTime.now()) ?? 0;
//       });

//     // Add data rows
//     for (final dateStr in sortedDates) {
//       final data = lastMonthData[dateStr]!;
//       final present = data['present'] ?? 0;
//       final leave = data['leave'] ?? 0;
//       final ontime = data['ontime'] ?? 0;
//       final late = data['late'] ?? 0;
//       final absent = data['absent'] ?? 0;
//       final total = present + leave + late + absent;
//       final presentPercentage = total > 0 ? (present / total * 100) : 0;

//       buffer.write('"$dateStr",');
//       buffer.write('${data['day']},');
//       buffer.write('$present,');
//       buffer.write('$leave,');
//       buffer.write('$ontime,');
//       buffer.write('$late,');
//       buffer.write('$absent,');
//       buffer.write('$total,');
//       buffer.write('${presentPercentage.toStringAsFixed(1)}%');
//       buffer.writeln();
//     }

//     // Add team member list
//     if (teamMembers.isNotEmpty) {
//       buffer.writeln();
//       buffer.writeln('TEAM MEMBERS');
//       buffer.writeln('Name,Role,Email');
//       for (final member in teamMembers) {
//         buffer.writeln('"${member.name}","${member.role}","${member.email}"');
//       }
//     }

//     return buffer.toString();
//   }

//   Future<void> _downloadFile(
//     BuildContext context,
//     List<int> bytes,
//     String fileName,
//   ) async {
//     // For web platform - uncomment if using web
//     /*
//     final blob = html.Blob([bytes], 'text/csv');
//     final url = html.Url.createObjectUrlFromBlob(blob);
//     final anchor = html.document.createElement('a') as html.AnchorElement
//       ..href = url
//       ..download = fileName
//       ..style.display = 'none';
//     html.document.body?.children.add(anchor);
//     anchor.click();
//     html.document.body?.children.remove(anchor);
//     html.Url.revokeObjectUrl(url);
//     */

//     // For mobile platforms using share_plus package
//     /*
//     await Share.shareXFiles(
//       [XFile.fromData(bytes, name: fileName, mimeType: 'text/csv')],
//       subject: 'Last Month Attendance Report',
//     );
//     */

//     // Simple approach - show data in dialog for copying
//     _showSaveInstructions(context, fileName, bytes);
//   }

//   void _showSaveInstructions(
//     BuildContext context,
//     String fileName,
//     List<int> bytes,
//   ) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.black.withOpacity(0.95),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//           side: BorderSide(color: Colors.green.shade400, width: 1.5),
//         ),
//         title: Text(
//           'Last Month Report Ready',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'File: $fileName',
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.8),
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Copy the CSV data below and save it as:',
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.7),
//                 fontSize: 12,
//               ),
//             ),
//             Text(
//               fileName,
//               style: TextStyle(
//                 color: Colors.green.shade400,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Container(
//               width: double.infinity,
//               height: 200,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade900,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey.shade700),
//               ),
//               child: SingleChildScrollView(
//                 child: SelectableText(
//                   utf8.decode(bytes),
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 10,
//                     fontFamily: 'Monospace',
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text(
//               'CLOSE',
//               style: TextStyle(
//                 color: Colors.grey.shade400,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               _copyToClipboard(context, utf8.decode(bytes));
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green.shade600,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: Text(
//               'COPY DATA',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _copyToClipboard(BuildContext context, String text) {
//     // For actual clipboard functionality, use:
//     // Clipboard.setData(ClipboardData(text: text));

//     _showSuccessSnackBar(context, 'Last month data copied to clipboard!');
//   }

//   void _showLoadingDialog(BuildContext context) {
//     final now = DateTime.now();
//     final lastMonth = DateTime(now.year, now.month - 1, 1);
//     final monthName = _getMonthName(lastMonth.month);

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.black.withOpacity(0.9),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//           side: BorderSide(color: Colors.green.shade400, width: 1.5),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
//               strokeWidth: 3,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Generating Last Month Report',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Processing $monthName ${lastMonth.year} data...',
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.7),
//                 fontSize: 12,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showSuccessSnackBar(
//     BuildContext context, [
//     String message = 'Last month data exported successfully!',
//   ]) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         backgroundColor: Colors.green.shade600,
//         content: Row(
//           children: [
//             Icon(Icons.check_circle, color: Colors.white),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 message,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         duration: const Duration(seconds: 4),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   void _showErrorSnackBar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         backgroundColor: Colors.red.shade600,
//         content: Row(
//           children: [
//             Icon(Icons.error_outline, color: Colors.white),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 message,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         duration: const Duration(seconds: 4),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
// }
