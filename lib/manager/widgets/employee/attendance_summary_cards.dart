
import 'package:flutter/material.dart';

import '../../view_models/employeeviewmodels/employee_details_view_model.dart';

class AttendanceSummaryCards extends StatelessWidget {
  final EmployeeDetailsViewModel viewModel;

  const AttendanceSummaryCards({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final summary = viewModel.getAttendanceSummary();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                size: 18,
                color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Attendance Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Days',
                  summary['total']?.toString() ?? '0',
                  Icons.calendar_today_rounded,
                  Colors.blue,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Present',
                  summary['present']?.toString() ?? '0',
                  Icons.check_circle_rounded,
                  Colors.green,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Absent',
                  summary['absent']?.toString() ?? '0',
                  Icons.cancel_rounded,
                  Colors.red,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Late',
                  summary['late']?.toString() ?? '0',
                  Icons.access_time_rounded,
                  Colors.orange,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAttendancePercentageCard(summary['percentage'] ?? 0, isDark),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.1) : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? color.withOpacity(0.3) : color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendancePercentageCard(int percentage, bool isDark) {
    final color = _getPercentageColor(percentage);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.1) : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? color.withOpacity(0.3) : color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Rate',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getPercentageText(percentage),
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor(int percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 75) return Colors.orange;
    return Colors.red;
  }

  String _getPercentageText(int percentage) {
    if (percentage >= 90) return 'Excellent attendance';
    if (percentage >= 75) return 'Good attendance';
    return 'Needs improvement';
  }
}

// import 'package:attendanceapp/view_models/employeeviewmodels/employee_details_view_model.dart';
// import 'package:flutter/material.dart';

// class AttendanceSummaryCards extends StatelessWidget {
//   final EmployeeDetailsViewModel viewModel;

//   const AttendanceSummaryCards({super.key, required this.viewModel});

//   @override
//   Widget build(BuildContext context) {
//     final summary = viewModel.getAttendanceSummary();

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.analytics_rounded,
//                 size: 18,
//                 color: Colors.blue.shade600,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 'Attendance Summary',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey.shade800,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildSummaryCard(
//                   'Total Days',
//                   summary['total']?.toString() ?? '0',
//                   Icons.calendar_today_rounded,
//                   Colors.blue,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildSummaryCard(
//                   'Present',
//                   summary['present']?.toString() ?? '0',
//                   Icons.check_circle_rounded,
//                   Colors.green,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildSummaryCard(
//                   'Absent',
//                   summary['absent']?.toString() ?? '0',
//                   Icons.cancel_rounded,
//                   Colors.red,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildSummaryCard(
//                   'Late',
//                   summary['late']?.toString() ?? '0',
//                   Icons.access_time_rounded,
//                   Colors.orange,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           _buildAttendancePercentageCard(summary['percentage'] ?? 0),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryCard(
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.2)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 16, color: color),
//               const SizedBox(width: 4),
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: color,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAttendancePercentageCard(int percentage) {
//     final color = _getPercentageColor(percentage);

//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Text(
//                 '$percentage%',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w700,
//                   color: color,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Attendance Rate',
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey.shade800,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   _getPercentageText(percentage),
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: color,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getPercentageColor(int percentage) {
//     if (percentage >= 90) return Colors.green;
//     if (percentage >= 75) return Colors.orange;
//     return Colors.red;
//   }

//   String _getPercentageText(int percentage) {
//     if (percentage >= 90) return 'Excellent attendance';
//     if (percentage >= 75) return 'Good attendance';
//     return 'Needs improvement';
//   }
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/employeeviewmodels/employee_details_view_model.dart';
// import 'package:flutter/material.dart';

// class AttendanceSummaryCards extends StatelessWidget {
//   final EmployeeDetailsViewModel viewModel;

//   const AttendanceSummaryCards({super.key, required this.viewModel});

//   @override
//   Widget build(BuildContext context) {
//     final summary = viewModel.getAttendanceSummary();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Attendance Summary',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(
//               child: _buildSummaryCard(
//                 'Total Days',
//                 summary['total']?.toString() ?? '0',
//                 Icons.calendar_today_rounded,
//                 AppColors.primary,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _buildSummaryCard(
//                 'Present',
//                 summary['present']?.toString() ?? '0',
//                 Icons.check_circle_rounded,
//                 AppColors.success,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _buildSummaryCard(
//                 'Absent',
//                 summary['absent']?.toString() ?? '0',
//                 Icons.cancel_rounded,
//                 AppColors.error,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: _buildSummaryCard(
//                 'Late',
//                 summary['late']?.toString() ?? '0',
//                 Icons.access_time_rounded,
//                 AppColors.warning,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _buildAttendancePercentageCard(summary['percentage'] ?? 0),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildSummaryCard(
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, size: 20, color: color),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: AppColors.textSecondary,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAttendancePercentageCard(int percentage) {
//     final color = _getPercentageColor(percentage);

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 SizedBox(
//                   width: 50,
//                   height: 50,
//                   child: CircularProgressIndicator(
//                     value: percentage / 100,
//                     strokeWidth: 6,
//                     backgroundColor: AppColors.grey300,
//                     valueColor: AlwaysStoppedAnimation<Color>(color),
//                   ),
//                 ),
//                 Text(
//                   '$percentage%',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                     color: color,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Attendance',
//               style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color _getPercentageColor(int percentage) {
//     if (percentage >= 90) return AppColors.success;
//     if (percentage >= 75) return AppColors.warning;
//     return AppColors.error;
//   }
// }
