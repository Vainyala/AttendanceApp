import 'package:flutter/material.dart';
import 'package:attendanceapp/manager/view_models/employeeviewmodels/employee_details_view_model.dart';

class EmployeeAttendanceDownloadButton extends StatelessWidget {
  final EmployeeDetailsViewModel viewModel;

  const EmployeeAttendanceDownloadButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade600.withOpacity(0.8),
            Colors.blue.shade400.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade800.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _exportAttendance(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  viewModel.isLoading ? Icons.hourglass_top : Icons.table_chart,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  viewModel.isLoading ? 'EXPORTING...' : 'XSL',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exportAttendance(BuildContext context) async {
    if (viewModel.isLoading) return;

    try {
      // Show confirmation dialog
      final shouldExport = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Attendance Data'),
          content: Text(
            'Do you want to export attendance data for ${viewModel.employee?.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Export'),
            ),
          ],
        ),
      );

      if (shouldExport == true) {
        // Call the export method from ViewModel
        await viewModel.exportAttendanceData();

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Attendance data exported successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export attendance data: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:attendanceapp/models/attendance_model.dart';
// import 'package:attendanceapp/models/team_model.dart';
// import 'package:attendanceapp/view_models/employeeviewmodels/employee_details_view_model.dart';

// class EmployeeAttendanceDownloadButton extends StatelessWidget {
//   final EmployeeDetailsViewModel viewModel;
//   final VoidCallback? onDownloadComplete;
//   final VoidCallback? onDownloadError;

//   const EmployeeAttendanceDownloadButton({
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
//             Colors.blue.shade600.withOpacity(0.8),
//             Colors.blue.shade400.withOpacity(0.6),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.blue.shade800.withOpacity(0.4),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => _downloadEmployeeAttendanceData(context),
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.download_rounded, color: Colors.white, size: 20),
//                 const SizedBox(width: 8),
//                 Text(
//                   'EXPORT ATTENDANCE',
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

//   Future<void> _downloadEmployeeAttendanceData(BuildContext context) async {
//     final employee = viewModel.employee;
//     final attendanceRecords = viewModel.getSortedAttendanceRecords();

//     if (employee == null || attendanceRecords.isEmpty) {
//       _showErrorSnackBar(context, 'No employee data available to export');
//       onDownloadError?.call();
//       return;
//     }

//     try {
//       // Show loading indicator
//       _showLoadingDialog(context);

//       // Use viewModel methods to get data
//       final employeeInfo = viewModel.getEmployeeInfoForDownload();
//       final averages = viewModel.getAttendanceAverages();
//       final counts = viewModel.getAttendanceCounts();
//       final performanceMetrics = viewModel.getPerformanceMetrics();

//       // Generate CSV data using viewModel methods
//       final csvData = _generateEmployeeCSV(
//         employee,
//         employeeInfo,
//         attendanceRecords,
//         averages,
//         counts,
//         performanceMetrics,
//       );

//       // Convert to bytes
//       final bytes = utf8.encode(csvData);

//       // Create file name with employee name and timestamp
//       final fileName =
//           '${employee.name.replaceAll(' ', '_')}_Attendance_Report_${DateTime.now().millisecondsSinceEpoch}.csv';

//       // Download file with notification
//       await _downloadWithNotification(context, bytes, fileName, employee.name);

//       // Close loading dialog
//       if (Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }

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

//   String _generateEmployeeCSV(
//     TeamMember employee,
//     Map<String, dynamic> employeeInfo,
//     List<AttendanceRecord> records,
//     Map<String, double> averages,
//     Map<String, int> counts,
//     Map<String, dynamic> performanceMetrics,
//   ) {
//     final buffer = StringBuffer();

//     // Add header information
//     buffer.writeln('EMPLOYEE ATTENDANCE SUMMARY REPORT');
//     buffer.writeln('Generated on: ${DateTime.now().toString()}');
//     buffer.writeln();

//     // Employee Information using viewModel data
//     buffer.writeln('EMPLOYEE INFORMATION');
//     buffer.writeln('Name: ${employee.name}');
//     buffer.writeln('Employee ID: ${employeeInfo['employeeId'] ?? 'N/A'}');
//     buffer.writeln('Department: ${employeeInfo['department'] ?? 'N/A'}');
//     buffer.writeln('Position: ${employeeInfo['position'] ?? employee.role}');
//     buffer.writeln('Email: ${employee.email}');
//     buffer.writeln('Phone: ${employee.phoneNumber}');
//     buffer.writeln(
//       'Join Date: ${employeeInfo['joinDate'] != null ? viewModel.formatDateForCSV(employeeInfo['joinDate']) : 'N/A'}',
//     );
//     buffer.writeln();

//     // Summary Statistics using viewModel calculated data
//     buffer.writeln('ATTENDANCE SUMMARY (${records.length} Days)');
//     buffer.writeln('Metric,Count,Percentage');
//     buffer.writeln(
//       'Present,${counts['present']},${averages['present']?.toStringAsFixed(1)}%',
//     );
//     buffer.writeln(
//       'Leaves,${counts['leaves']},${averages['leaves']?.toStringAsFixed(1)}%',
//     );
//     buffer.writeln(
//       'Ontime,${counts['ontime']},${averages['ontime']?.toStringAsFixed(1)}%',
//     );
//     buffer.writeln(
//       'Late,${counts['late']},${averages['late']?.toStringAsFixed(1)}%',
//     );
//     buffer.writeln(
//       'Absent,${counts['absent']},${averages['absent']?.toStringAsFixed(1)}%',
//     );
//     buffer.writeln('Total Working Days,${records.length},100%');
//     buffer.writeln();

//     // Performance Metrics
//     buffer.writeln('PERFORMANCE METRICS');
//     buffer.writeln(
//       'Productivity Score: ${performanceMetrics['productivityScore']?.toStringAsFixed(1) ?? 'N/A'}%',
//     );
//     buffer.writeln(
//       'Punctuality Score: ${performanceMetrics['punctualityScore']?.toStringAsFixed(1) ?? 'N/A'}%',
//     );
//     buffer.writeln(
//       'Completed Tasks: ${performanceMetrics['completedTasks'] ?? 'N/A'}',
//     );
//     buffer.writeln(
//       'Pending Tasks: ${performanceMetrics['pendingTasks'] ?? 'N/A'}',
//     );
//     buffer.writeln(
//       'Attendance Percentage: ${performanceMetrics['attendancePercentage']?.toStringAsFixed(1) ?? 'N/A'}%',
//     );
//     buffer.writeln(
//       'Overall Performance Score: ${performanceMetrics['performanceScore']?.toStringAsFixed(1) ?? 'N/A'}%',
//     );
//     buffer.writeln(
//       'Performance Rating: ${performanceMetrics['performanceRating'] ?? 'N/A'}',
//     );
//     buffer.writeln();

//     // Detailed Attendance Records using viewModel formatting methods
//     buffer.writeln('DETAILED ATTENDANCE HISTORY');
//     buffer.writeln(
//       'Date,Day,Status,Check In,Check Out,Working Hours,Late Minutes,Remarks',
//     );

//     for (final record in records) {
//       final workingHours = viewModel.getWorkingHours(record);
//       final hasWorkingHours =
//           workingHours != null && workingHours.inMinutes > 0;
//       final lateMinutes = viewModel.getLateMinutes(record);
//       final remarks = viewModel.getRemarks(record);

//       buffer.write('"${viewModel.formatDateForCSV(record.date)}",');
//       buffer.write('${viewModel.getFullWeekday(record.date.weekday)},');
//       buffer.write('${viewModel.getStatusDisplayText(record.status)},');
//       buffer.write('${viewModel.formatTime(record.checkIn)},');
//       buffer.write(
//         '${record.checkOut != null ? viewModel.formatTime(record.checkOut!) : "N/A"},',
//       );
//       buffer.write(
//         '${hasWorkingHours ? viewModel.formatWorkingHours(workingHours) : "N/A"},',
//       );
//       buffer.write('${lateMinutes > 0 ? lateMinutes : "0"},');
//       buffer.write('"$remarks"');
//       buffer.writeln();
//     }

//     // Performance Analysis
//     buffer.writeln();
//     buffer.writeln('PERFORMANCE ANALYSIS');
//     buffer.writeln(
//       'Attendance Rate: ${(100 - (averages['absent'] ?? 0)).toStringAsFixed(1)}%',
//     );
//     buffer.writeln(
//       'Punctuality Rate: ${averages['ontime']?.toStringAsFixed(1)}%',
//     );
//     buffer.writeln(
//       'Leave Utilization: ${averages['leaves']?.toStringAsFixed(1)}%',
//     );
//     buffer.writeln(
//       'Late Arrival Rate: ${averages['late']?.toStringAsFixed(1)}%',
//     );

//     final overallScore =
//         performanceMetrics['performanceScore'] ??
//         _calculateOverallScore(averages);
//     buffer.writeln(
//       'Overall Performance Score: ${overallScore.toStringAsFixed(1)}%',
//     );

//     final rating =
//         performanceMetrics['performanceRating'] ??
//         _getPerformanceRating(overallScore);
//     buffer.writeln('Performance Rating: $rating');

//     // Additional Insights
//     buffer.writeln();
//     buffer.writeln('ADDITIONAL INSIGHTS');
//     if (averages['present']! >= 90) {
//       buffer.writeln('• Excellent attendance record');
//     } else if (averages['present']! >= 80) {
//       buffer.writeln('• Good attendance record');
//     } else {
//       buffer.writeln('• Attendance needs improvement');
//     }

//     if (averages['ontime']! >= 80) {
//       buffer.writeln('• High punctuality');
//     } else {
//       buffer.writeln('• Punctuality needs attention');
//     }

//     if (averages['leaves']! <= 10) {
//       buffer.writeln('• Optimal leave utilization');
//     } else {
//       buffer.writeln('• High leave utilization');
//     }

//     return buffer.toString();
//   }

//   double _calculateOverallScore(Map<String, double> averages) {
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

//   String _getPerformanceRating(double score) {
//     if (score >= 90) return 'Excellent';
//     if (score >= 80) return 'Good';
//     if (score >= 70) return 'Average';
//     return 'Needs Improvement';
//   }

//   Future<void> _downloadWithNotification(
//     BuildContext context,
//     List<int> bytes,
//     String fileName,
//     String employeeName,
//   ) async {
//     // Show download started notification
//     _showDownloadNotification(
//       context,
//       fileName,
//       'Downloading $employeeName attendance data...',
//     );

//     // Simulate download process with progress
//     for (int progress = 0; progress <= 100; progress += 20) {
//       await Future.delayed(const Duration(milliseconds: 200));
//       // Update progress notification (you can implement actual progress updates)
//     }

//     // Show file save dialog
//     _showFileSaveDialog(context, bytes, fileName, employeeName);
//   }

//   void _showDownloadNotification(
//     BuildContext context,
//     String fileName,
//     String message,
//   ) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         backgroundColor: Colors.blue.shade600,
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
//                     'Downloading...',
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
//     String employeeName,
//   ) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.black.withOpacity(0.95),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//           side: BorderSide(color: Colors.blue.shade400, width: 1.5),
//         ),
//         title: Text(
//           'Download Complete!',
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
//               'Employee: $employeeName',
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.7),
//                 fontSize: 12,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'The file has been saved to your device. You can find it in your Downloads folder.',
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
//                       'File saved successfully to local storage',
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
//               backgroundColor: Colors.blue.shade600,
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

//     _showSuccessSnackBar(context, 'Attendance data copied to clipboard!');
//   }

//   void _showLoadingDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.black.withOpacity(0.9),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//           side: BorderSide(color: Colors.blue.shade400, width: 1.5),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
//               strokeWidth: 3,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Generating Attendance Report',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Calculating averages and preparing export...',
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
//     String message = 'Attendance data exported successfully!',
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
