
import 'package:flutter/material.dart';

import '../../core/view_models/theme_view_model.dart';
import '../../view_models/attendanceviewmodels/attendance_analytics_view_model.dart';

class StatisticsCards extends StatelessWidget {
  final AttendanceAnalyticsViewModel viewModel;

  const StatisticsCards({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final stats = viewModel.analytics?.statistics ?? {};

    return Row(
      children: [
        _buildStatCard(
          'Attendance Rate',
          '${stats['attendanceRate']}%',
          Icons.trending_up_rounded,
          AppColors.success,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Avg. Hours',
          '${stats['avgHours']}h',
          Icons.access_time_rounded,
          AppColors.info,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Productivity',
          '${stats['productivity']}%',
          Icons.work_history_rounded,
          AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:flutter/material.dart';

// class StatisticsCards extends StatelessWidget {
//   final AttendanceAnalyticsViewModel viewModel;

//   const StatisticsCards({super.key, required this.viewModel});

//   @override
//   Widget build(BuildContext context) {
//     final stats = viewModel.analytics?.statistics ?? {};

//     return Row(
//       children: [
//         _buildStatCard(
//           'Attendance Rate',
//           '${stats['attendanceRate']}%',
//           Icons.trending_up_rounded,
//           AppColors.success,
//         ),
//         const SizedBox(width: 12),
//         _buildStatCard(
//           'Avg. Hours',
//           '${stats['avgHours']}h',
//           Icons.access_time_rounded,
//           AppColors.info,
//         ),
//         const SizedBox(width: 12),
//         _buildStatCard(
//           'Productivity',
//           '${stats['productivity']}%',
//           Icons.work_history_rounded,
//           AppColors.primary,
//         ),
//       ],
//     );
//   }

//   Widget _buildStatCard(
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.3)),
//         ),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, size: 16, color: color),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 10,
//                 color: AppColors.textSecondary,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
