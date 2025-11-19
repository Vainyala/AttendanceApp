// // widgets/project_analytics_screen.dart
// import 'package:attendanceapp/models/team_model.dart';
// import 'package:flutter/material.dart';
// import 'package:attendanceapp/models/project_model.dart';
// import 'package:attendanceapp/widgets/analytics/merged_graph.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';

// class ProjectAnalyticsScreen extends StatelessWidget {
//   final Project project;
//   final AttendanceAnalyticsViewModel attendanceViewModel;

//   const ProjectAnalyticsScreen({
//     super.key,
//     required this.project,
//     required this.attendanceViewModel,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: Text(
//           '${project.name} - Analytics',
//           style: const TextStyle(
//             fontWeight: FontWeight.w700,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: _getStatusColor(project.status),
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Project Summary Card
//             _buildProjectSummaryCard(),
//             const SizedBox(height: 20),
            
//             // Merged Graph for this project
//             MergedGraph(viewModel: attendanceViewModel),
            
//             const SizedBox(height: 20),
            
//             // Team Members Section
//             _buildTeamMembersSection(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProjectSummaryCard() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             _getStatusColor(project.status),
//             _getStatusColor(project.status).withOpacity(0.7),
//           ],
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     _getStatusText(project.status).toUpperCase(),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 12,
//                       letterSpacing: 1.5,
//                     ),
//                   ),
//                 ),
//                 const Spacer(),
//                 Text(
//                   '${project.teamSize} Members',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               project.name,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               project.description,
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.9),
//                 fontSize: 14,
//               ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 _buildMetricItem('Tasks', '${project.totalTasks}'),
//                 const SizedBox(width: 16),
//                 _buildMetricItem('Completed', '${project.completedTasks}'),
//                 const SizedBox(width: 16),
//                 _buildMetricItem(
//                   'Progress',
//                   '${((project.completedTasks / project.totalTasks) * 100).toStringAsFixed(1)}%',
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMetricItem(String label, String value) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           children: [
//             Text(
//               value,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.8),
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTeamMembersSection() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: Colors.white.withOpacity(0.05),
//         border: Border.all(color: Colors.white.withOpacity(0.2)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Team Members',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ...project.assignedTeam.map(
//               (member) => _buildTeamMemberRow(member),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTeamMemberRow(TeamMember member) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: _getStatusColor(project.status).withOpacity(0.2),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: _getStatusColor(project.status).withOpacity(0.4),
//               ),
//             ),
//             child: Center(
//               child: Text(
//                 _getInitials(member.name),
//                 style: TextStyle(
//                   color: _getStatusColor(project.status),
//                   fontWeight: FontWeight.w700,
//                   fontSize: 14,
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
//                   member.name,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Text(
//                   member.role,
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.7),
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper methods
//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'active':
//         return Colors.green;
//       case 'planning':
//         return Colors.blue;
//       case 'completed':
//         return Colors.purple;
//       case 'on-hold':
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }

//   String _getStatusText(String status) {
//     switch (status) {
//       case 'active':
//         return 'Active';
//       case 'planning':
//         return 'Planning';
//       case 'completed':
//         return 'Completed';
//       case 'on-hold':
//         return 'On Hold';
//       default:
//         return 'Unknown';
//     }
//   }

//   String _getInitials(String name) {
//     return name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();
//   }
// }