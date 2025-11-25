// import 'package:AttendanceApp/models/attendancemodels/attendance_analytics_model.dart';
// import 'package:flutter/material.dart';
// import 'package:AttendanceApp/core/view_models/theme_view_model.dart';
// import 'package:AttendanceApp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';

// class SimpleBarGraph extends StatelessWidget {
//   final AttendanceAnalyticsViewModel viewModel;

//   const SimpleBarGraph({super.key, required this.viewModel});

//   @override
//   Widget build(BuildContext context) {
//     final analytics = viewModel.analytics;
//     if (analytics == null) return const SizedBox();

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '${viewModel.getPeriodDisplayName(viewModel.selectedPeriod)} Overview',
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//             ),
//             const SizedBox(height: 16),
//             _buildSimpleBars(analytics),
//             const SizedBox(height: 16),
//             _buildLegend(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSimpleBars(AttendanceAnalytics analytics) {
//     final graphData = analytics.graphData;
//     final labels = analytics.labels;

//     return SizedBox(
//       height: 200,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: labels.asMap().entries.map((entry) {
//           final index = entry.key;
//           final present = graphData['present']?[index] ?? 0;
//           final late = graphData['late']?[index] ?? 0;
//           final absent = graphData['absent']?[index] ?? 0;

//           return _buildBarColumn(entry.value, present, late, absent);
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildBarColumn(
//     String label,
//     double present,
//     double late,
//     double absent,
//   ) {
//     final maxHeight = 150.0;
//     final maxValue = present + late + absent;
//     final scale = maxValue > 0 ? maxHeight / maxValue : 0;

//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         Container(
//           width: 30,
//           height: (present + late + absent) * scale,
//           child: Column(
//             children: [
//               // Present (top)
//               if (present > 0)
//                 Expanded(
//                   flex: present.round(),
//                   child: Container(color: AppColors.success),
//                 ),
//               // Late (middle)
//               if (late > 0)
//                 Expanded(
//                   flex: late.round(),
//                   child: Container(color: AppColors.warning),
//                 ),
//               // Absent (bottom)
//               if (absent > 0)
//                 Expanded(
//                   flex: absent.round(),
//                   child: Container(color: AppColors.error),
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(label, style: const TextStyle(fontSize: 12)),
//       ],
//     );
//   }

//   Widget _buildLegend() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _buildLegendItem('Present', AppColors.success),
//         const SizedBox(width: 16),
//         _buildLegendItem('Late', AppColors.warning),
//         const SizedBox(width: 16),
//         _buildLegendItem('Absent', AppColors.error),
//       ],
//     );
//   }

//   Widget _buildLegendItem(String text, Color color) {
//     return Row(
//       children: [
//         Container(width: 12, height: 12, color: color),
//         const SizedBox(width: 4),
//         Text(text, style: const TextStyle(fontSize: 12)),
//       ],
//     );
//   }
// }
