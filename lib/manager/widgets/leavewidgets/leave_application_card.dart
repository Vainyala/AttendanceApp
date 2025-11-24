// widgets/leave_application_card.dart
import 'package:attendanceapp/manager/core/view_models/theme_view_model.dart';
import 'package:attendanceapp/manager/models/leavemodels/leave_model.dart';
import 'package:flutter/material.dart';

class LeaveApplicationCard extends StatelessWidget {
  final LeaveApplication application;
  final VoidCallback onTap;
  final bool isDarkMode;

  const LeaveApplicationCard({
    super.key,
    required this.application,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? AppColors.white : AppColors.textPrimary;
    final secondaryTextColor = isDarkMode
        ? AppColors.white.withOpacity(0.8)
        : AppColors.textSecondary;
    final backgroundColor = isDarkMode
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    final borderColor = isDarkMode ? AppColors.grey700 : AppColors.grey300;
    final iconColor = isDarkMode
        ? AppColors.white.withOpacity(0.7)
        : AppColors.grey600;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee Basic Info
              Row(
                children: [
                  // Profile Photo
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: _getColorFromName(
                      application.employeeName,
                    ),
                    child: application.employeePhoto.isNotEmpty
                        ? CircleAvatar(
                            radius: 23,
                            backgroundImage: NetworkImage(
                              application.employeePhoto,
                            ),
                          )
                        : Text(
                            _getInitials(application.employeeName),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.employeeName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        Text(
                          '${application.employeeRole} • ${application.projectName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                        Text(
                          '${application.employeeEmail} • ${application.employeePhone}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDarkMode
                                ? AppColors.grey500
                                : AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        application.status,
                      ).withOpacity(isDarkMode ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(
                          application.status,
                        ).withOpacity(isDarkMode ? 0.4 : 0.3),
                      ),
                    ),
                    child: Text(
                      application.statusString.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(application.status),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Leave Details
              Row(
                children: [
                  _buildInfoChip(
                    Icons.beach_access,
                    application.leaveTypeString,
                    isDarkMode,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.calendar_today,
                    application.duration,
                    isDarkMode,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Date Range
              Row(
                children: [
                  Icon(Icons.date_range, size: 16, color: iconColor),
                  const SizedBox(width: 4),
                  Text(
                    application.formattedDates,
                    style: TextStyle(fontSize: 12, color: secondaryTextColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Applied Date
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: iconColor),
                  const SizedBox(width: 4),
                  Text(
                    'Applied: ${application.appliedDateTime}',
                    style: TextStyle(fontSize: 12, color: secondaryTextColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Handover Person
              // Row(
              //   children: [
              //     Icon(Icons.person_outline, size: 16, color: iconColor),
              //     const SizedBox(width: 4),
              //     Text(
              //       'Handover to: ${application.handoverPersonName}',
              //       style: TextStyle(fontSize: 12, color: secondaryTextColor),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 8),

              // Total Days
              if (application.totalDays > 0)
                Row(
                  children: [
                    Icon(
                      Icons.format_list_numbered,
                      size: 16,
                      color: iconColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Total Days: ${application.totalDays}',
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                  ],
                ),
              if (application.totalDays > 0) const SizedBox(height: 8),

              // Reason (Truncated)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reason:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    application.reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: textColor),
                  ),
                ],
              ),

              // Manager Remarks (if available)
              if (application.managerRemarks != null &&
                  application.managerRemarks!.isNotEmpty &&
                  application.managerRemarks!.isEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Manager Remarks:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      application.managerRemarks!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDarkMode
                            ? AppColors.grey400
                            : AppColors.grey600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildInfoChip(IconData icon, String text, bool isDarkMode) {
  //   final chipColor = _getChipColor(application.status);

  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: chipColor.withOpacity(isDarkMode ? 0.15 : 0.1),
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(
  //         color: chipColor.withOpacity(isDarkMode ? 0.4 : 0.3),
  //         width: 1,
  //       ),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(icon, size: 12, color: chipColor),
  //         const SizedBox(width: 4),
  //         Text(
  //           text,
  //           style: TextStyle(
  //             fontSize: 11,
  //             color: chipColor,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildInfoChip(IconData icon, String text, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getChipColor(
          application.status,
        ).withOpacity(isDarkMode ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getChipColor(
            application.status,
          ).withOpacity(isDarkMode ? 0.4 : 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _getChipColor(application.status)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: _getChipColor(application.status),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.approved:
        return Colors.green;
      case LeaveStatus.rejected:
        return Colors.red;
      case LeaveStatus.query:
        return Colors.orange;
      case LeaveStatus.cancelled:
        return Colors.grey;
      case LeaveStatus.pending:
      default:
        return Colors.blue;
    }
  }

  Color _getChipColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.approved:
        return Colors.green;
      case LeaveStatus.rejected:
        return Colors.red;
      case LeaveStatus.query:
        return Colors.orange;
      case LeaveStatus.cancelled:
        return Colors.grey;
      case LeaveStatus.pending:
      default:
        return Colors.blue;
    }
  }

  Color _getColorFromName(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
    ];
    final index = name.length % colors.length;
    return colors[index];
  }

  String _getInitials(String name) {
    return name
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }
}

// // widgets/leave_application_card.dart
// import 'package:attendanceapp/manager/models/leavemodels/leave_model.dart';
// import 'package:flutter/material.dart';

// class LeaveApplicationCard extends StatelessWidget {
//   final LeaveApplication application;
//   final VoidCallback onTap;

//   const LeaveApplicationCard({
//     super.key,
//     required this.application,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       child: InkWell(
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Employee Basic Info
//               Row(
//                 children: [
//                   // Profile Photo
//                   CircleAvatar(
//                     radius: 25,
//                     backgroundColor: _getColorFromName(
//                       application.employeeName,
//                     ),
//                     child: application.employeePhoto.isNotEmpty
//                         ? CircleAvatar(
//                             radius: 23,
//                             backgroundImage: NetworkImage(
//                               application.employeePhoto,
//                             ),
//                           )
//                         : Text(
//                             _getInitials(application.employeeName),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           application.employeeName,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         Text(
//                           '${application.employeeRole} • ${application.projectName}', // Changed from project to projectName
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                         Text(
//                           '${application.employeeEmail} • ${application.employeePhone}',
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.grey.shade500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Status Badge
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: _getStatusColor(
//                         application.status,
//                       ).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       application.statusString
//                           .toUpperCase(), // Changed from status to statusString
//                       style: TextStyle(
//                         color: _getStatusColor(application.status),
//                         fontSize: 10,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),

//               // Leave Details
//               Row(
//                 children: [
//                   _buildInfoChip(
//                     Icons.beach_access,
//                     application.leaveTypeString,
//                   ), // Changed from leaveType to leaveTypeString
//                   const SizedBox(width: 8),
//                   _buildInfoChip(Icons.calendar_today, application.duration),
//                 ],
//               ),
//               const SizedBox(height: 8),

//               // Date Range
//               Row(
//                 children: [
//                   Icon(Icons.date_range, size: 16, color: Colors.grey.shade600),
//                   const SizedBox(width: 4),
//                   Text(
//                     application.formattedDates,
//                     style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),

//               // Applied Date
//               Row(
//                 children: [
//                   Icon(
//                     Icons.access_time,
//                     size: 16,
//                     color: Colors.grey.shade600,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     'Applied: ${application.appliedDateTime}',
//                     style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),

//               // Handover Person
//               Row(
//                 children: [
//                   Icon(
//                     Icons.person_outline,
//                     size: 16,
//                     color: Colors.grey.shade600,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     'Handover to: ${application.handoverPersonName}',
//                     style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),

//               // Total Days
//               if (application.totalDays > 0)
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.format_list_numbered,
//                       size: 16,
//                       color: Colors.grey.shade600,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Total Days: ${application.totalDays}',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               if (application.totalDays > 0) const SizedBox(height: 8),

//               // Reason (Truncated)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Reason:',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     application.reason,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(fontSize: 12),
//                   ),
//                 ],
//               ),

//               // Manager Remarks (if available)
//               if (application.managerRemarks != null &&
//                   application.managerRemarks!.isNotEmpty)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 8),
//                     Text(
//                       'Manager Remarks:',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey.shade700,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       application.managerRemarks!,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: Colors.grey.shade600,
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoChip(IconData icon, String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: _getChipColor(application.status).withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: _getChipColor(application.status).withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 12, color: _getChipColor(application.status)),
//           const SizedBox(width: 4),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 11,
//               color: _getChipColor(application.status),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getStatusColor(LeaveStatus status) {
//     switch (status) {
//       case LeaveStatus.approved:
//         return Colors.green;
//       case LeaveStatus.rejected:
//         return Colors.red;
//       case LeaveStatus.query:
//         return Colors.orange;
//       case LeaveStatus.cancelled:
//         return Colors.grey;
//       case LeaveStatus.pending:
//       default:
//         return Colors.blue;
//     }
//   }

//   Color _getChipColor(LeaveStatus status) {
//     switch (status) {
//       case LeaveStatus.approved:
//         return Colors.green;
//       case LeaveStatus.rejected:
//         return Colors.red;
//       case LeaveStatus.query:
//         return Colors.orange;
//       case LeaveStatus.cancelled:
//         return Colors.grey;
//       case LeaveStatus.pending:
//       default:
//         return Colors.blue;
//     }
//   }

//   Color _getColorFromName(String name) {
//     final colors = [
//       Colors.blue,
//       Colors.green,
//       Colors.orange,
//       Colors.purple,
//       Colors.red,
//       Colors.teal,
//       Colors.indigo,
//     ];
//     final index = name.length % colors.length;
//     return colors[index];
//   }

//   String _getInitials(String name) {
//     return name
//         .split(' ')
//         .map((e) => e.isNotEmpty ? e[0] : '')
//         .take(2)
//         .join()
//         .toUpperCase();
//   }
// }
