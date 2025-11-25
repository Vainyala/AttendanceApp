// import 'package:AttendanceApp/core/view_models/theme_view_model.dart';
// import 'package:AttendanceApp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:flutter/material.dart';

// class InsightsSection extends StatelessWidget {
//   final AttendanceAnalyticsViewModel viewModel;

//   const InsightsSection({super.key, required this.viewModel});

//   @override
//   Widget build(BuildContext context) {
//     final insights = viewModel.getInsights();

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               '📊 Performance Insights',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             const SizedBox(height: 12),
//             ...insights.map(
//               (insight) => Padding(
//                 padding: const EdgeInsets.only(bottom: 8),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Icon(
//                       _getInsightIcon(insight.type),
//                       color: _getInsightColor(insight.type),
//                       size: 16,
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         insight.text,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   IconData _getInsightIcon(String type) {
//     switch (type) {
//       case 'positive':
//         return Icons.trending_up_rounded;
//       case 'warning':
//         return Icons.warning_amber_rounded;
//       default:
//         return Icons.info_rounded;
//     }
//   }

//   Color _getInsightColor(String type) {
//     switch (type) {
//       case 'positive':
//         return AppColors.success;
//       case 'warning':
//         return AppColors.warning;
//       default:
//         return AppColors.info;
//     }
//   }
// }
