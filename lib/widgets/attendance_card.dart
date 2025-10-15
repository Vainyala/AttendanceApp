// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../../models/attendance_model.dart';
// import '../../providers/regularisation_provider.dart';
// import '../../widgets/status_badge.dart';
//
// class AttendanceCard extends StatelessWidget {
//   final String date;
//   final String hours;
//   final String shortfall;
//   final String status;
//   final DateTime actualDate;
//   final List<AttendanceModel> dayRecords;
//   final VoidCallback onTap;
//
//   const AttendanceCard({
//     super.key,
//     required this.date,
//     required this.hours,
//     required this.shortfall,
//     required this.status,
//     required this.actualDate,
//     required this.dayRecords,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: _getBorderColor(status), width: 1.5),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         date,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         DateFormat('EEEE').format(actualDate),
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 StatusBadge(
//                   status: status,
//                   fontSize: 11,
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 6,
//                     horizontal: 12,
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(height: 24),
//             Row(
//               children: [
//                 _buildInfoChip(
//                   icon: Icons.access_time,
//                   label: 'Worked',
//                   value: '$hours hrs',
//                   color: Colors.blue,
//                 ),
//                 const SizedBox(width: 12),
//                 _buildInfoChip(
//                   icon: Icons.timer_off,
//                   label: 'Shortfall',
//                   value: shortfall,
//                   color: shortfall == '00:00' ? Colors.green : Colors.red,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             _buildProjectsList(context),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Icon(
//                   _getActionIcon(status),
//                   size: 14,
//                   color: _getBorderColor(status),
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   _getActionText(status),
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: _getBorderColor(status),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoChip({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//   }) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, size: 14, color: color),
//                 const SizedBox(width: 4),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProjectsList(BuildContext context) {
//     final provider = context.read<RegularisationProvider>();
//     final projectGroups = provider.getProjectGroups(dayRecords);
//
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.folder_outlined, size: 14, color: Colors.grey.shade600),
//               const SizedBox(width: 6),
//               Text(
//                 'Projects (${projectGroups.length})',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: projectGroups.entries.map((entry) {
//               return Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.blue.shade200),
//                 ),
//                 child: Text(
//                   entry.key,
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: Colors.blue.shade700,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Color _getBorderColor(String status) {
//     switch (status) {
//       case 'Apply':
//         return Colors.blue;
//       case 'Pending':
//         return Colors.orange;
//       case 'Rejected':
//         return Colors.red;
//       case 'Approved':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   IconData _getActionIcon(String status) {
//     switch (status) {
//       case 'Apply':
//         return Icons.edit;
//       case 'Pending':
//         return Icons.visibility;
//       case 'Rejected':
//         return Icons.edit;
//       case 'Approved':
//         return Icons.check_circle_outline;
//       default:
//         return Icons.info_outline;
//     }
//   }
//
//   String _getActionText(String status) {
//     switch (status) {
//       case 'Apply':
//         return 'Tap to apply for regularisation';
//       case 'Pending':
//         return 'Tap to view manager comments';
//       case 'Rejected':
//         return 'Tap to update and resubmit';
//       case 'Approved':
//         return 'Tap to view details';
//       default:
//         return 'Tap to view';
//     }
//   }
// }