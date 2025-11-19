
import 'package:flutter/material.dart';

import '../../models/employeemodels/employee_details_model.dart';
import '../../view_models/employeeviewmodels/employee_details_view_model.dart';

class PerformanceMetricsSection extends StatelessWidget {
  final EmployeeDetailsViewModel viewModel;

  const PerformanceMetricsSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final performance = viewModel.employeeDetails!.performance;
    final metrics = viewModel.getPerformanceMetrics();
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
                Icons.assessment_rounded,
                size: 18,
                color: isDark ? Colors.purple.shade300 : Colors.purple.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Performance Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.grey.shade800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRatingColor(metrics['performanceRating'] ?? ''),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  metrics['performanceRating'] ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Performance Metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Productivity',
                  '${performance.productivityScore.toStringAsFixed(1)}%',
                  Icons.work_rounded,
                  Colors.blue,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Punctuality',
                  '${performance.punctualityScore.toStringAsFixed(1)}%',
                  Icons.access_time_rounded,
                  Colors.green,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Task Progress
          _buildTaskProgress(performance, isDark),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? color.withOpacity(0.2)
                      : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
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

  Widget _buildTaskProgress(PerformanceMetrics performance, bool isDark) {
    final totalTasks = performance.completedTasks + performance.pendingTasks;
    final completionRate = totalTasks > 0
        ? (performance.completedTasks / totalTasks) * 100
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Task Progress',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.grey.shade800,
                ),
              ),
              Text(
                '${completionRate.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _getCompletionColor(completionRate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completionRate / 100,
            backgroundColor: isDark
                ? Colors.grey.shade700
                : Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getCompletionColor(completionRate),
            ),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTaskCount(
                'Completed',
                performance.completedTasks,
                Colors.green,
                isDark,
              ),
              _buildTaskCount(
                'Pending',
                performance.pendingTasks,
                Colors.orange,
                isDark,
              ),
              _buildTaskCount('Total', totalTasks, Colors.blue, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCount(String label, int count, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getRatingColor(String rating) {
    switch (rating.toLowerCase()) {
      case 'excellent':
        return Colors.green.shade600;
      case 'good':
        return Colors.blue.shade600;
      case 'average':
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getCompletionColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.blue;
    if (rate >= 40) return Colors.orange;
    return Colors.red;
  }
}

// import 'package:attendanceapp/models/employeemodels/employee_details_model.dart';
// import 'package:attendanceapp/view_models/employeeviewmodels/employee_details_view_model.dart';
// import 'package:flutter/material.dart';

// class PerformanceMetricsSection extends StatelessWidget {
//   final EmployeeDetailsViewModel viewModel;

//   const PerformanceMetricsSection({super.key, required this.viewModel});

//   @override
//   Widget build(BuildContext context) {
//     final performance = viewModel.employeeDetails!.performance;
//     final metrics = viewModel.getPerformanceMetrics();

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
//                 Icons.assessment_rounded,
//                 size: 18,
//                 color: Colors.purple.shade600,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 'Performance Overview',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey.shade800,
//                 ),
//               ),
//               const Spacer(),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: _getRatingColor(metrics['performanceRating'] ?? ''),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Text(
//                   metrics['performanceRating'] ?? 'N/A',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           // Main Performance Metrics
//           Row(
//             children: [
//               Expanded(
//                 child: _buildMetricCard(
//                   'Productivity',
//                   '${performance.productivityScore.toStringAsFixed(1)}%',
//                   Icons.work_rounded,
//                   Colors.blue,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildMetricCard(
//                   'Punctuality',
//                   '${performance.punctualityScore.toStringAsFixed(1)}%',
//                   Icons.access_time_rounded,
//                   Colors.green,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Task Progress
//           _buildTaskProgress(performance),
//         ],
//       ),
//     );
//   }

//   Widget _buildMetricCard(
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
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Icon(icon, size: 14, color: color),
//               ),
//               const Spacer(),
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 16,
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

//   Widget _buildTaskProgress(PerformanceMetrics performance) {
//     final totalTasks = performance.completedTasks + performance.pendingTasks;
//     final completionRate = totalTasks > 0
//         ? (performance.completedTasks / totalTasks) * 100
//         : 0.0;

//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Task Progress',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey.shade800,
//                 ),
//               ),
//               Text(
//                 '${completionRate.toStringAsFixed(0)}%',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w700,
//                   color: _getCompletionColor(completionRate),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           LinearProgressIndicator(
//             value: completionRate / 100,
//             backgroundColor: Colors.grey.shade300,
//             valueColor: AlwaysStoppedAnimation<Color>(
//               _getCompletionColor(completionRate),
//             ),
//             minHeight: 6,
//             borderRadius: BorderRadius.circular(3),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildTaskCount(
//                 'Completed',
//                 performance.completedTasks,
//                 Colors.green,
//               ),
//               _buildTaskCount(
//                 'Pending',
//                 performance.pendingTasks,
//                 Colors.orange,
//               ),
//               _buildTaskCount('Total', totalTasks, Colors.blue),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTaskCount(String label, int count, Color color) {
//     return Column(
//       children: [
//         Text(
//           count.toString(),
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w700,
//             color: color,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 10,
//             color: Colors.grey.shade600,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   Color _getRatingColor(String rating) {
//     switch (rating.toLowerCase()) {
//       case 'excellent':
//         return Colors.green.shade600;
//       case 'good':
//         return Colors.blue.shade600;
//       case 'average':
//         return Colors.orange.shade600;
//       default:
//         return Colors.grey.shade600;
//     }
//   }

//   Color _getCompletionColor(double rate) {
//     if (rate >= 80) return Colors.green;
//     if (rate >= 60) return Colors.blue;
//     if (rate >= 40) return Colors.orange;
//     return Colors.red;
//   }
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/employeemodels/employee_details_model.dart';
// import 'package:attendanceapp/view_models/employeeviewmodels/employee_details_view_model.dart';
// import 'package:flutter/material.dart';

// class PerformanceMetricsSection extends StatelessWidget {
//   final EmployeeDetailsViewModel viewModel;

//   const PerformanceMetricsSection({super.key, required this.viewModel});

//   @override
//   Widget build(BuildContext context) {
//     final performance = viewModel.employeeDetails!.performance;

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Performance Metrics',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Productivity Score
//             _buildMetricRow(
//               'Productivity Score',
//               '${performance.productivityScore.toStringAsFixed(1)}%',
//               performance.productivityScore,
//               Icons.work_history_rounded,
//               AppColors.primary,
//             ),
//             const SizedBox(height: 16),

//             // Punctuality Score
//             _buildMetricRow(
//               'Punctuality Score',
//               '${performance.punctualityScore.toStringAsFixed(1)}%',
//               performance.punctualityScore,
//               Icons.access_time_rounded,
//               AppColors.info,
//             ),
//             const SizedBox(height: 16),

//             // Tasks Progress
//             _buildTasksProgress(performance),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMetricRow(
//     String title,
//     String value,
//     double score,
//     IconData icon,
//     Color color,
//   ) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, size: 20, color: color),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                   color: color,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         _buildScoreIndicator(score),
//       ],
//     );
//   }

//   Widget _buildScoreIndicator(double score) {
//     final color = _getScoreColor(score);
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Text(
//         _getScoreText(score),
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: color,
//         ),
//       ),
//     );
//   }

//   Widget _buildTasksProgress(PerformanceMetrics performance) {
//     final totalTasks = performance.completedTasks + performance.pendingTasks;
//     final completionRate = totalTasks > 0
//         ? performance.completedTasks / totalTasks
//         : 0.0;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Task Completion',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '$completionRate%',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                       color: AppColors.success,
//                     ),
//                   ),
//                   Text(
//                     '${performance.completedTasks}/$totalTasks tasks',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               flex: 2,
//               child: LinearProgressIndicator(
//                 value: completionRate,
//                 backgroundColor: AppColors.grey300,
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   _getScoreColor(completionRate * 100),
//                 ),
//                 minHeight: 8,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             _buildTaskStat(
//               'Completed',
//               performance.completedTasks,
//               AppColors.success,
//             ),
//             _buildTaskStat(
//               'Pending',
//               performance.pendingTasks,
//               AppColors.warning,
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildTaskStat(String label, int count, Color color) {
//     return Column(
//       children: [
//         Text(
//           count.toString(),
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w700,
//             color: color,
//           ),
//         ),
//         Text(
//           label,
//           style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
//         ),
//       ],
//     );
//   }

//   Color _getScoreColor(double score) {
//     if (score >= 90) return AppColors.success;
//     if (score >= 75) return AppColors.warning;
//     return AppColors.error;
//   }

//   String _getScoreText(double score) {
//     if (score >= 90) return 'Excellent';
//     if (score >= 75) return 'Good';
//     if (score >= 60) return 'Average';
//     return 'Needs Improvement';
//   }
// }
