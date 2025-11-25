import 'package:attendanceapp/manager/view_models/employeeviewmodels/employee_details_view_model.dart';
import 'package:flutter/material.dart';

class EmployeeProfileHeader extends StatelessWidget {
  final EmployeeDetailsViewModel viewModel;

  const EmployeeProfileHeader({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final employee = viewModel.employeeDetails!;
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? Colors.blue.shade800 : Colors.blue.shade100,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.blue.shade600 : Colors.blue.shade200,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _getInitials(employee.name),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Employee Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                _buildInfoRow(
                  Icons.badge_rounded,
                  '(' + employee.employeeId + ')',
                  isDark,
                ),
                const SizedBox(height: 4),
                Text(
                  employee.position,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                // Text(
                //   employee.id,
                //   style: TextStyle(
                //     fontSize: 14,
                //     color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),

                // Contact Info
                _buildInfoRow(Icons.phone, employee.contactInfo.phone, isDark),
                _buildInfoRow(Icons.email_rounded, employee.email, isDark),

                _buildInfoRow(
                  Icons.business_rounded,
                  employee.department,
                  isDark,
                ),

                const SizedBox(height: 8),

                // Quick Stats
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      _buildQuickStat(
                        'Joined',
                        _formatJoinDate(employee.joinDate),
                        isDark,
                      ),
                      // const SizedBox(width: 16),
                      // _buildQuickStat(
                      //   'Attendance',
                      //   '${summary['percentage']}%',
                      //   isDark,
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return parts[0][0];
  }

  String _formatJoinDate(DateTime joinDate) {
    return '${joinDate.day}/${joinDate.month}/${joinDate.year}';
  }
}

// import 'package:attendanceapp/view_models/employeeviewmodels/employee_details_view_model.dart';
// import 'package:flutter/material.dart';

// class EmployeeProfileHeader extends StatelessWidget {
//   final EmployeeDetailsViewModel viewModel;

//   const EmployeeProfileHeader({super.key, required this.viewModel});

//   @override
//   Widget build(BuildContext context) {
//     final employee = viewModel.employeeDetails!;
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
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Profile Avatar
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: Colors.blue.shade100,
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.blue.shade200, width: 2),
//             ),
//             child: Center(
//               child: Text(
//                 _getInitials(employee.name),
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.blue.shade700,
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(width: 16),

//           // Employee Information
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   employee.name,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   employee.position,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.blue.shade600,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 8),

//                 // Contact Info
//                 _buildInfoRow(Icons.email_rounded, employee.email),
//                 _buildInfoRow(Icons.phone, employee.contactInfo.phone),
//                 _buildInfoRow(Icons.business_rounded, employee.department),
//                 _buildInfoRow(Icons.badge_rounded, employee.employeeId),

//                 const SizedBox(height: 8),

//                 // Quick Stats
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade50,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Row(
//                     children: [
//                       _buildQuickStat(
//                         'Joined',
//                         _formatJoinDate(employee.joinDate),
//                       ),
//                       const SizedBox(width: 16),
//                       _buildQuickStat(
//                         'Attendance',
//                         '${summary['percentage']}%',
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         children: [
//           Icon(icon, size: 14, color: Colors.grey.shade600),
//           const SizedBox(width: 6),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickStat(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 10,
//             color: Colors.grey.shade500,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey.shade800,
//           ),
//         ),
//       ],
//     );
//   }

//   String _getInitials(String name) {
//     final parts = name.split(' ');
//     if (parts.length >= 2) {
//       return '${parts[0][0]}${parts[1][0]}';
//     }
//     return parts[0][0];
//   }

//   String _formatJoinDate(DateTime joinDate) {
//     return '${joinDate.day}/${joinDate.month}/${joinDate.year}';
//   }
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/employeeviewmodels/employee_details_view_model.dart';
// import 'package:flutter/material.dart';

// class EmployeeProfileHeader extends StatelessWidget {
//   final EmployeeDetailsViewModel viewModel;

//   const EmployeeProfileHeader({super.key, required this.viewModel});

//   @override
//   Widget build(BuildContext context) {
//     final employee = viewModel.employeeDetails!;
//     final summary = viewModel.getAttendanceSummary();

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 // Profile Image
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: AppColors.primary.withOpacity(0.3),
//                       width: 2,
//                     ),
//                   ),
//                   child: Icon(
//                     Icons.person_rounded,
//                     size: 40,
//                     color: AppColors.primary,
//                   ),
//                 ),
//                 const SizedBox(width: 16),

//                 // Employee Info
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         employee.name,
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.textPrimary,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         employee.position,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: AppColors.primary,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       Text(
//                         employee.department,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.email_rounded,
//                             size: 14,
//                             color: AppColors.textSecondary,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             employee.email,
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: AppColors.textSecondary,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),
//             const Divider(),
//             const SizedBox(height: 12),

//             // Quick Stats
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildStatItem('Employee ID', employee.employeeId),
//                 _buildStatItem('Join Date', _formatJoinDate(employee.joinDate)),
//                 _buildStatItem('Attendance', '${summary['percentage']}%'),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatItem(String label, String value) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
//         ),
//       ],
//     );
//   }

//   String _formatJoinDate(DateTime joinDate) {
//     return '${joinDate.day}/${joinDate.month}/${joinDate.year}';
//   }
// }
