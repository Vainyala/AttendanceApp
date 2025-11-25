// allocated_projects_list.dart
import 'package:attendanceapp/manager/core/view_models/theme_view_model.dart';
import 'package:attendanceapp/manager/models/projectmodels/project_models.dart';
import 'package:attendanceapp/manager/view_models/employeeviewmodels/employee_details_view_model.dart';
import 'package:flutter/material.dart';

class AllocatedProjectsList extends StatelessWidget {
  final EmployeeDetailsViewModel viewModel;

  const AllocatedProjectsList({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final projects = viewModel.allocatedProjects;

    if (projects.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Allocated Projects (${projects.length})',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: projects.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildProjectCard(projects[index], isDarkMode);
          },
        ),
      ],
    );
  }

  Widget _buildProjectCard(Project project, bool isDarkMode) {
    final statusColor = viewModel.getStatusColor(project.status);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.work_outline_rounded,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Project Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? AppColors.textInverse
                              : AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Text(
                      //   project.description,
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: isDarkMode
                      //         ? AppColors.grey400
                      //         : AppColors.textSecondary,
                      //     height: 1.4,
                      //   ),
                      //   maxLines: 2,
                      //   overflow: TextOverflow.ellipsis,
                      // ),
                    ],
                  ),
                ),

                // Status Badge
                // _buildStatusBadge(project.status, isDarkMode),
              ],
            ),

            const SizedBox(height: 16),

            // Progress Section
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Text(
            //           'Project Progress',
            //           style: TextStyle(
            //             fontSize: 12,
            //             fontWeight: FontWeight.w500,
            //             color: isDarkMode
            //                 ? AppColors.grey400
            //                 : AppColors.textSecondary,
            //           ),
            //         ),
            //         // Text(
            //         //   '${project.progress.toStringAsFixed(0)}%',
            //         //   style: TextStyle(
            //         //     fontSize: 12,
            //         //     fontWeight: FontWeight.w600,
            //         //     color: isDarkMode
            //         //         ? AppColors.textInverse
            //         //         : AppColors.textPrimary,
            //         //   ),
            //         // ),
            //       ],
            //     ),
            //     const SizedBox(height: 8),
            //     Container(
            //       height: 6,
            //       decoration: BoxDecoration(
            //         color: isDarkMode ? AppColors.grey700 : AppColors.grey200,
            //         borderRadius: BorderRadius.circular(3),
            //       ),
            //       child: Stack(
            //         children: [
            //           LayoutBuilder(
            //             builder: (context, constraints) {
            //               return AnimatedContainer(
            //                 duration: const Duration(milliseconds: 500),
            //                 width:
            //                     constraints.maxWidth * (project.progress / 100),
            //                 decoration: BoxDecoration(
            //                   color: statusColor,
            //                   borderRadius: BorderRadius.circular(3),
            //                 ),
            //               );
            //             },
            //           ),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),

            // const SizedBox(height: 16),

            // Project Metrics Grid
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.grey800.withOpacity(0.3)
                    : AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricItem(
                    Icons.people_alt_rounded,
                    '${project.teamSize}',
                    'Team',
                    isDarkMode,
                  ),
                  // _buildMetricItem(
                  //   Icons.check_circle_rounded,
                  //   '${project.completedTasks}/${project.totalTasks}',
                  //   'Tasks',
                  //   isDarkMode,
                  // ),
                  // _buildMetricItem(
                  //   Icons.calendar_month_rounded,
                  //   '${project.daysRemaining}',
                  //   'Days Left',
                  //   isDarkMode,
                  // ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Footer Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Priority
                Row(
                  children: [
                    Icon(
                      Icons.flag_rounded,
                      size: 14,
                      color: _getPriorityColor(project.priority, isDarkMode),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${project.priority} priority',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDarkMode
                            ? AppColors.grey400
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                // Client
                Row(
                  children: [
                    Icon(
                      Icons.business_rounded,
                      size: 14,
                      color: isDarkMode
                          ? AppColors.grey400
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      project.client,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDarkMode
                            ? AppColors.grey400
                            : AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isDarkMode) {
    final color = viewModel.getStatusColor(status);
    final text = viewModel.getStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    IconData icon,
    String value,
    String label,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isDarkMode ? AppColors.grey400 : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? AppColors.textInverse
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDarkMode ? AppColors.grey500 : AppColors.textDisabled,
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(String priority, bool isDarkMode) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.warning;
      case 'urgent':
        return AppColors.error;
      case 'medium':
        return AppColors.info;
      case 'low':
        return AppColors.success;
      default:
        return isDarkMode ? AppColors.grey400 : AppColors.textSecondary;
    }
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.grey800 : AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.work_outline_rounded,
              size: 28,
              color: isDarkMode ? AppColors.grey400 : AppColors.grey500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Projects Allocated',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This employee is not currently assigned to any projects',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppColors.grey400 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// // allocated_projects_list.dart
// import 'package:attendanceapp/manager/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/manager/models/projectmodels/project_models.dart';
// import 'package:attendanceapp/manager/view_models/employeeviewmodels/employee_details_view_model.dart';
// import 'package:flutter/material.dart';

// class AllocatedProjectsList extends StatelessWidget {
//   final EmployeeDetailsViewModel viewModel;

//   const AllocatedProjectsList({super.key, required this.viewModel});

//   @override
//   Widget build(BuildContext context) {
//     final projects = viewModel.allocatedProjects;

//     if (projects.isEmpty) {
//       return _buildEmptyState();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Allocated Projects (${projects.length})',
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 16),
//         ListView.separated(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: projects.length,
//           separatorBuilder: (context, index) => const SizedBox(height: 12),
//           itemBuilder: (context, index) {
//             return _buildProjectCard(projects[index]);
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildProjectCard(Project project) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Project Header with Name and Status
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     project.name,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                       color: AppColors.textPrimary,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 _buildStatusBadge(project.status),
//               ],
//             ),
//             const SizedBox(height: 8),

//             // Project Description
//             Text(
//               project.description,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: AppColors.textSecondary,
//                 height: 1.4,
//               ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 16),

//             // Progress Bar
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Progress',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                     Text(
//                       '${project.progress.toStringAsFixed(1)}%',
//                       style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 LinearProgressIndicator(
//                   value: project.progress / 100,
//                   backgroundColor: AppColors.grey300,
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     viewModel.getStatusColor(project.status),
//                   ),
//                   minHeight: 6,
//                   borderRadius: BorderRadius.circular(3),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             // Project Details - Using your Project model's computed properties
//             Row(
//               children: [
//                 _buildDetailItem(
//                   Icons.people_rounded,
//                   '${project.teamSize} members',
//                 ),
//                 const SizedBox(width: 16),
//                 _buildDetailItem(
//                   Icons.assignment_rounded,
//                   '${project.completedTasks}/${project.totalTasks} tasks',
//                 ),
//                 const SizedBox(width: 16),
//                 _buildDetailItem(
//                   Icons.calendar_today_rounded,
//                   '${project.daysRemaining} days left',
//                 ),
//               ],
//             ),

//             // Priority and Client Info (Optional - if you want to show)
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 _buildDetailItem(
//                   Icons.flag_rounded,
//                   '${project.priority} priority',
//                 ),
//                 const SizedBox(width: 16),
//                 _buildDetailItem(Icons.business_rounded, project.client),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusBadge(String status) {
//     final color = viewModel.getStatusColor(status);
//     final text = viewModel.getStatusText(status);

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.w600,
//           color: color,
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailItem(IconData icon, String text) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 14, color: AppColors.textSecondary),
//         const SizedBox(width: 4),
//         Text(
//           text,
//           style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
//         ),
//       ],
//     );
//   }

//   Widget _buildEmptyState() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         height: 120,
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.work_outline_rounded,
//               size: 32,
//               color: AppColors.grey400,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'No Projects Allocated',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'This employee is not assigned to any projects',
//               style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
