// // screens/project_detail_screen.dart
// import 'package:flutter/material.dart';
// import '../../utils/app_colors.dart';
// import 'package:fl_chart/fl_chart.dart';
//
// class ProjectDetailScreen extends StatelessWidget {
//   final Map<String, dynamic> project;
//
//   const ProjectDetailScreen({
//     Key? key,
//     required this.project,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.textHint.shade900,
//       appBar: AppBar(
//         backgroundColor: AppColors.textHint.shade900,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: AppColors.textLight),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           project['name'] ?? 'Project Details',
//           style: TextStyle(
//             color: AppColors.textLight,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildProjectHeader(),
//             SizedBox(height: 20),
//             _buildTeamWorkloadSection(),
//             SizedBox(height: 20),
//             _buildProjectStats(),
//             SizedBox(height: 20),
//             _buildTeamMembers(),
//             SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProjectHeader() {
//     return Container(
//       margin: EdgeInsets.all(16),
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.textHint.shade800,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             _getProjectDescription(project['name']),
//             style: TextStyle(
//               color: AppColors.textHint.shade300,
//               fontSize: 14,
//               height: 1.5,
//             ),
//           ),
//           SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Status',
//                       style: TextStyle(
//                         color: AppColors.textHint.shade500,
//                         fontSize: 12,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       project['status'] ?? 'ACTIVE',
//                       style: TextStyle(
//                         color: AppColors.success,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Priority',
//                       style: TextStyle(
//                         color: AppColors.textHint.shade500,
//                         fontSize: 12,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       'HIGH',
//                       style: TextStyle(
//                         color: AppColors.error,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _getProjectDescription(String? projectName) {
//     final descriptions = {
//       'E-Commerce Platform': 'Development of new e-commerce platform with modern features',
//       'Mobile App Redesign': 'Redesign of customer mobile application with new UI/UX',
//       'Banking System Upgrade': 'Modernization of legacy banking system with enhanced security',
//     };
//     return descriptions[projectName] ?? 'Project description not available';
//   }
//
//   Widget _buildTeamWorkloadSection() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16),
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.textHint.shade800,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Team Workload Distribution',
//             style: TextStyle(
//               color: AppColors.textLight,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'Task allocation across team members',
//             style: TextStyle(
//               color: AppColors.textHint.shade400,
//               fontSize: 12,
//             ),
//           ),
//           SizedBox(height: 20),
//           _buildWorkloadChart(),
//           SizedBox(height: 20),
//           _buildTeamTaskLegend(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildWorkloadChart() {
//     return Container(
//       height: 300,
//       child: LineChart(
//         LineChartData(
//           gridData: FlGridData(
//             show: true,
//             drawVerticalLine: false,
//             horizontalInterval: 2,
//             getDrawingHorizontalLine: (value) {
//               return FlLine(
//                 color: AppColors.textHint.shade700,
//                 strokeWidth: 1,
//               );
//             },
//           ),
//           titlesData: FlTitlesData(
//             show: true,
//             rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 getTitlesWidget: (value, meta) {
//                   const titles = ['RS', 'RS', 'PS', 'PS', 'AK'];
//                   if (value.toInt() >= 0 && value.toInt() < titles.length) {
//                     return Text(
//                       titles[value.toInt()],
//                       style: TextStyle(
//                         color: AppColors.textHint.shade400,
//                         fontSize: 12,
//                       ),
//                     );
//                   }
//                   return Text('');
//                 },
//               ),
//             ),
//             leftTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 interval: 2,
//                 getTitlesWidget: (value, meta) {
//                   return Text(
//                     value.toInt().toString(),
//                     style: TextStyle(
//                       color: AppColors.textHint.shade400,
//                       fontSize: 12,
//                     ),
//                   );
//                 },
//                 reservedSize: 30,
//               ),
//             ),
//           ),
//           borderData: FlBorderData(show: false),
//           minX: 0,
//           maxX: 4,
//           minY: 0,
//           maxY: 12,
//           lineBarsData: [
//             LineChartBarData(
//               spots: [
//                 FlSpot(0, 10),
//                 FlSpot(1, 9),
//                 FlSpot(2, 8),
//                 FlSpot(3, 9),
//                 FlSpot(4, 10),
//               ],
//               isCurved: true,
//               color: Colors.cyan,
//               barWidth: 3,
//               isStrokeCapRound: true,
//               dotData: FlDotData(show: false),
//               belowBarData: BarAreaData(
//                 show: true,
//                 color: Colors.cyan.withOpacity(0.3),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTeamTaskLegend() {
//     final teamMembers = project['teamMembers'] as List<String>? ??
//         ['Raj Kumar', 'Priya Singh', 'Amit Sharma'];
//
//     final taskData = [
//       {'name': teamMembers.isNotEmpty ? teamMembers[0].split(' ')[0] : 'Raj', 'tasks': 10, 'color': Colors.cyan},
//       {'name': teamMembers.length > 1 ? teamMembers[1].split(' ')[0] : 'Priya', 'tasks': 9, 'color': Colors.blue},
//       {'name': teamMembers.length > 2 ? teamMembers[2].split(' ')[0] : 'Amit', 'tasks': 9, 'color': AppColors.success},
//     ];
//
//     return Wrap(
//       spacing: 12,
//       runSpacing: 12,
//       children: taskData.map((member) {
//         return Container(
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: BoxDecoration(
//             color: AppColors.textHint.shade700,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: member['color'] as Color),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 8,
//                 height: 8,
//                 decoration: BoxDecoration(
//                   color: member['color'] as Color,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               SizedBox(width: 8),
//               Text(
//                 '${member['name']}: ${member['tasks']} tasks',
//                 style: TextStyle(
//                   color: AppColors.textLight,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
//
//   Widget _buildProjectStats() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children: [
//           Expanded(
//             child: _buildStatCard(
//               'Progress',
//               '${project['progress'] ?? 0}%',
//               Icons.trending_up,
//               AppColors.success,
//             ),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: _buildStatCard(
//               'Members',
//               '${project['members'] ?? 0}',
//               Icons.group,
//               Colors.blue,
//             ),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: _buildStatCard(
//               'Tasks',
//               '${project['tasks'] ?? 0}/${project['tasks'] ?? 0}',
//               Icons.task_alt,
//               Colors.orange,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatCard(String label, String value, IconData icon, Color color) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.textHint.shade800,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 24),
//           SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               color: AppColors.textLight,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               color: AppColors.textHint.shade400,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTeamMembers() {
//     final members = project['teamMembers'] as List<String>? ?? [];
//
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16),
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.textHint.shade800,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Team Members',
//             style: TextStyle(
//               color: AppColors.textLight,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 16),
//           ...members.map((member) => _buildMemberItem(member)).toList(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMemberItem(String name) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12),
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: AppColors.textHint.shade700,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             backgroundColor: Colors.blue,
//             child: Text(
//               name[0].toUpperCase(),
//               style: TextStyle(
//                 color: AppColors.textLight,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               name,
//               style: TextStyle(
//                 color: AppColors.textLight,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Icon(Icons.chevron_right, color: AppColors.textHint.shade400),
//         ],
//       ),
//     );
//   }
// }