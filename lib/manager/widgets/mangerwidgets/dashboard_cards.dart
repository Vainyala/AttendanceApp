import 'package:attendanceapp/manager/core/view_models/theme_view_model.dart';
import 'package:attendanceapp/manager/models/managermodels/manager_dashboard_model.dart';
import 'package:attendanceapp/manager/models/projectmodels/project_models.dart';
import 'package:attendanceapp/manager/view_models/managerviewmodels/manager_dashboard_view_model.dart';
import 'package:attendanceapp/manager/view_models/projectviewmodels/project_view_model.dart';
import 'package:attendanceapp/manager/views/managerviews/projectmodeview/ProjectDetailListScreens.dart';
import 'package:attendanceapp/manager/views/managerviews/attendance_detail_screen.dart';
import 'package:attendanceapp/manager/views/managerviews/employee_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardCardsSection extends StatefulWidget {
  const DashboardCardsSection({super.key});

  @override
  State<DashboardCardsSection> createState() => _DashboardCardsSectionState();
}

class _DashboardCardsSectionState extends State<DashboardCardsSection> {
  @override
  void initState() {
    super.initState();
    // Initialize project data when widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projectViewModel = Provider.of<ProjectViewModel>(
        context,
        listen: false,
      );
      projectViewModel.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ManagerDashboardViewModel>(context);
    final stats = viewModel.stats;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (stats == null) {
      return Center(
        child: CircularProgressIndicator(
          color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isPortrait = constraints.maxHeight > constraints.maxWidth;
        final crossAxisCount = isPortrait ? 2 : 4;
        final childAspectRatio = isPortrait ? 1.4 : 1.2;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Stats Cards - Responsive Design
                // _buildPremiumStatsRow(stats, constraints, isDark),
                // const SizedBox(height: 24),

                // Project Details Cards - Responsive Row
                _buildProjectsSection(context, isDark),
                const SizedBox(height: 5),

                // Quick Actions - Responsive Grid
                _buildPremiumQuickActions(
                  context,
                  viewModel,
                  crossAxisCount,
                  childAspectRatio,
                  isDark,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumStatsRow(
    DashboardStats stats,
    BoxConstraints constraints,
    bool isDark,
  ) {
    final isPortrait = constraints.maxHeight > constraints.maxWidth;
    final spacing = isPortrait ? 8.0 : 16.0;

    // ✅ SAFE Percentage Calculation with validation
    final totalTeamMembers = stats.totalTeamMembers;
    final overallPresentValue = stats.overallPresent;

    int overallPresentPercentage;

    if (totalTeamMembers <= 0) {
      overallPresentPercentage = 0;
    } else if (overallPresentValue > totalTeamMembers) {
      overallPresentPercentage = 100;
    } else {
      overallPresentPercentage = (overallPresentValue / totalTeamMembers * 100)
          .round();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.blue.shade900 : Colors.blue.shade700,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPremiumStatItem(
            'Team',
            stats.totalTeamMembers,
            Icons.people_alt_rounded,
            isDark,
          ),
          SizedBox(width: spacing),
          _buildPremiumStatItem(
            'Present',
            stats.presentToday,
            Icons.verified_user_rounded,
            isDark,
          ),
          SizedBox(width: spacing),
          _buildPremiumStatItem(
            'Absent',
            stats.absentToday,
            Icons.person_off_rounded,
            isDark,
          ),
          SizedBox(width: spacing),
          _buildPremiumStatItem(
            'Leaves',
            stats.pendingLeaves,
            Icons.beach_access_rounded,
            isDark,
          ),
          SizedBox(width: spacing),
          // ✅ Safe percentage display
          _buildPremiumStatItem(
            'OverAll Present',
            overallPresentPercentage,
            Icons.trending_up_rounded,
            isDark,
            isPercentage: true,
          ),
        ],
      ),
    );
  }

  // ✅ UPDATED METHOD with isPercentage parameter
  Widget _buildPremiumStatItem(
    String label,
    int value,
    IconData icon,
    bool isDark, {
    bool isPercentage = false,
  }) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              isPercentage ? '$value%' : value.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumQuickActions(
    BuildContext context,
    ManagerDashboardViewModel viewModel,
    int crossAxisCount,
    double childAspectRatio,
    bool isDark,
  ) {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            _buildPremiumActionCard(
              'Attendance',
              '',
              Icons.assignment_turned_in_rounded,
              isDark ? Colors.blue.shade800 : Colors.blue.shade700,
              () => _navigateToAttendanceDetails(context),
              isDark,
            ),
            _buildPremiumActionCard(
              'Employees',
              '',
              Icons.people_alt_rounded,
              isDark ? Colors.orange.shade800 : Colors.orange.shade700,
              () => _navigateToEmployeeDetails(context, viewModel),
              isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.4 : 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsSection(BuildContext context, bool isDark) {
    return Consumer<ProjectViewModel>(
      builder: (context, projectViewModel, child) {
        final projects = projectViewModel.projects;

        if (projectViewModel.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
            ),
          );
        }

        if (projects.isEmpty) {
          return _buildEmptyProjectsState(isDark);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mapped Project',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: projects
                    .map(
                      (project) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildProjectCard(
                          context,
                          project,
                          projectViewModel,
                          isDark,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    Project project,
    ProjectViewModel projectViewModel,
    bool isDark,
  ) {
    final statusColor = projectViewModel.getStatusColor(project.status);

    return Container(
      width: 240,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: statusColor,
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(isDark ? 0.4 : 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _navigateToProjectDetail(context, project),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row - Icon and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.work_history_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.2)
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getShortStatus(
                          projectViewModel.getStatusText(project.status),
                        ),
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                // Project Name
                Text(
                  _truncateText(project.name, 25),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Client Name
                Text(
                  _truncateText(project.client, 25),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Bottom info - Team and Days
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${project.teamSize} members',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      '${project.daysRemaining}d left',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for text truncation
  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  String _getShortStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'ACT';
      case 'planning':
        return 'PLN';
      case 'completed':
        return 'COM';
      case 'on-hold':
        return 'HLD';
      default:
        return status.substring(0, 3).toUpperCase();
    }
  }

  Widget _buildEmptyProjectsState(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Projects',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.grey.shade800,
            ),
          ),
        ),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.work_outline,
                  size: 40,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  'No projects available',
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToProjectDetail(BuildContext context, Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailListScreens(project: project),
      ),
    );
  }

  void _navigateToAllProjects(BuildContext context) {
    // You can create a separate screen for all projects
    // Navigator.push(context, MaterialPageRoute(builder: (context) => AllProjectsScreen()));
  }

  void _navigateToAttendanceDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AttendanceDetailScreen()),
    );
  }

  void _navigateToEmployeeDetails(
    BuildContext context,
    ManagerDashboardViewModel viewModel,
  ) {
    final teamMembers = viewModel.dashboard?.teamMembers ?? [];
    if (teamMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No team members available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmployeeListScreen()),
    );
  }
}

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/managermodels/manager_dashboard_model.dart';
// import 'package:attendanceapp/models/projectmodels/project_models.dart';
// import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:attendanceapp/view_models/projectviewmodels/project_view_model.dart';
// import 'package:attendanceapp/views/managerviews/projectmodeview/ProjectDetailListScreens.dart';
// import 'package:attendanceapp/views/managerviews/attendance_detail_screen.dart';
// import 'package:attendanceapp/views/managerviews/employee_list_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class DashboardCardsSection extends StatefulWidget {
//   const DashboardCardsSection({super.key});

//   @override
//   State<DashboardCardsSection> createState() => _DashboardCardsSectionState();
// }

// class _DashboardCardsSectionState extends State<DashboardCardsSection> {
//   @override
//   void initState() {
//     super.initState();
//     // Initialize project data when widget loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final projectViewModel = Provider.of<ProjectViewModel>(
//         context,
//         listen: false,
//       );
//       projectViewModel.initialize();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = Provider.of<ManagerDashboardViewModel>(context);
//     final stats = viewModel.stats;

//     if (stats == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final isPortrait = constraints.maxHeight > constraints.maxWidth;
//         final crossAxisCount = isPortrait ? 2 : 4;
//         final childAspectRatio = isPortrait ? 1.4 : 1.2;

//         return SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // Stats Cards - Responsive Design
//                 // _buildPremiumStatsRow(stats, constraints),
//                 // const SizedBox(height: 24),

//                 // Project Details Cards - Responsive Row
//                 _buildProjectsSection(context),
//                 const SizedBox(height: 5),

//                 // Quick Actions - Responsive Grid
//                 _buildPremiumQuickActions(
//                   context,
//                   viewModel,
//                   crossAxisCount,
//                   childAspectRatio,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildPremiumStatsRow(
//     DashboardStats stats,
//     BoxConstraints constraints,
//   ) {
//     final isPortrait = constraints.maxHeight > constraints.maxWidth;
//     final spacing = isPortrait ? 8.0 : 16.0;

//     // ✅ SAFE Percentage Calculation with validation
//     final totalTeamMembers = stats.totalTeamMembers;
//     final overallPresentValue = stats.overallPresent;

//     int overallPresentPercentage;

//     if (totalTeamMembers <= 0) {
//       overallPresentPercentage = 0;
//     } else if (overallPresentValue > totalTeamMembers) {
//       overallPresentPercentage = 100;
//     } else {
//       overallPresentPercentage = (overallPresentValue / totalTeamMembers * 100)
//           .round();
//     }

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.primary,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildPremiumStatItem(
//             'Team',
//             stats.totalTeamMembers,
//             Icons.people_alt_rounded,
//           ),
//           SizedBox(width: spacing),
//           _buildPremiumStatItem(
//             'Present',
//             stats.presentToday,
//             Icons.verified_user_rounded,
//           ),
//           SizedBox(width: spacing),
//           _buildPremiumStatItem(
//             'Absent',
//             stats.absentToday,
//             Icons.person_off_rounded,
//           ),
//           SizedBox(width: spacing),
//           _buildPremiumStatItem(
//             'Leaves',
//             stats.pendingLeaves,
//             Icons.beach_access_rounded,
//           ),
//           SizedBox(width: spacing),
//           // ✅ Safe percentage display
//           _buildPremiumStatItem(
//             'OverAll Present',
//             overallPresentPercentage,
//             Icons.trending_up_rounded,
//             isPercentage: true,
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ UPDATED METHOD with isPercentage parameter
//   Widget _buildPremiumStatItem(
//     String label,
//     int value,
//     IconData icon, {
//     bool isPercentage = false,
//   }) {
//     return Flexible(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, size: 20, color: Colors.white),
//           ),
//           const SizedBox(height: 8),
//           FittedBox(
//             child: Text(
//               isPercentage ? '$value%' : value.toString(),
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           const SizedBox(height: 4),
//           FittedBox(
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.white.withOpacity(0.9),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPremiumQuickActions(
//     BuildContext context,
//     ManagerDashboardViewModel viewModel,
//     int crossAxisCount,
//     double childAspectRatio,
//   ) {
//     return Column(
//       children: [
//         GridView.count(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           crossAxisCount: crossAxisCount,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//           childAspectRatio: childAspectRatio,
//           children: [
//             _buildPremiumActionCard(
//               'Attendance',
//               '',
//               Icons.assignment_turned_in_rounded,
//               AppColors.primary,
//               () => _navigateToAttendanceDetails(context),
//             ),
//             _buildPremiumActionCard(
//               'Employees',
//               '',
//               Icons.people_alt_rounded,
//               AppColors.warning,
//               () => _navigateToEmployeeDetails(context, viewModel),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildPremiumActionCard(
//     String title,
//     String subtitle,
//     IconData icon,
//     Color color,
//     VoidCallback onTap,
//   ) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: color,
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(12),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(12),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(icon, color: Colors.white, size: 20),
//                 ),
//                 Flexible(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       FittedBox(
//                         child: Text(
//                           title,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Flexible(
//                         child: Text(
//                           subtitle,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.white.withOpacity(0.9),
//                             fontWeight: FontWeight.w500,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProjectsSection(BuildContext context) {
//     return Consumer<ProjectViewModel>(
//       builder: (context, projectViewModel, child) {
//         final projects = projectViewModel.projects;

//         if (projectViewModel.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (projects.isEmpty) {
//           return _buildEmptyProjectsState();
//         }

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Mapped Project',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.white,
//               ),
//             ),
//             SizedBox(
//               height: 100,
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 children: projects
//                     .map(
//                       (project) => Padding(
//                         padding: const EdgeInsets.only(right: 8),
//                         child: _buildProjectCard(
//                           context,
//                           project,
//                           projectViewModel,
//                         ),
//                       ),
//                     )
//                     .toList(),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildProjectCard(
//     BuildContext context,
//     Project project,
//     ProjectViewModel projectViewModel,
//   ) {
//     return Container(
//       width: 240,
//       height: 160,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: projectViewModel.getStatusColor(project.status),
//         boxShadow: [
//           BoxShadow(
//             color: projectViewModel
//                 .getStatusColor(project.status)
//                 .withOpacity(0.3),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(12),
//         child: InkWell(
//           onTap: () => _navigateToProjectDetail(context, project),
//           borderRadius: BorderRadius.circular(12),
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Top row - Icon and Status
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(4),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: const Icon(
//                         Icons.work_history_rounded,
//                         color: Colors.white,
//                         size: 14,
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 6,
//                         vertical: 2,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.3),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         _getShortStatus(
//                           projectViewModel.getStatusText(project.status),
//                         ),
//                         style: const TextStyle(
//                           fontSize: 8,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 // Project Name
//                 Text(
//                   _truncateText(project.name, 25),
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),

//                 // Client Name
//                 Text(
//                   _truncateText(project.client, 25),
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: Colors.white.withOpacity(0.9),
//                     fontWeight: FontWeight.w500,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),

//                 // Bottom info - Team and Days
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '${project.teamSize} members',
//                       style: TextStyle(
//                         fontSize: 9,
//                         color: Colors.white.withOpacity(0.8),
//                       ),
//                     ),
//                     Text(
//                       '${project.daysRemaining}d left',
//                       style: TextStyle(
//                         fontSize: 9,
//                         color: Colors.white.withOpacity(0.8),
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper methods for text truncation
//   String _truncateText(String text, int maxLength) {
//     if (text.length <= maxLength) return text;
//     return '${text.substring(0, maxLength)}...';
//   }

//   String _getShortStatus(String status) {
//     switch (status.toLowerCase()) {
//       case 'active':
//         return 'ACT';
//       case 'planning':
//         return 'PLN';
//       case 'completed':
//         return 'COM';
//       case 'on-hold':
//         return 'HLD';
//       default:
//         return status.substring(0, 3).toUpperCase();
//     }
//   }

//   Widget _buildEmptyProjectsState() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.symmetric(vertical: 16),
//           child: Text(
//             'Projects',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         Container(
//           height: 120,
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.white.withOpacity(0.2)),
//           ),
//           child: const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.work_outline, size: 40, color: Colors.white54),
//                 SizedBox(height: 8),
//                 Text(
//                   'No projects available',
//                   style: TextStyle(color: Colors.white54, fontSize: 16),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _navigateToProjectDetail(BuildContext context, Project project) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProjectDetailListScreens(project: project),
//       ),
//     );
//   }

//   void _navigateToAllProjects(BuildContext context) {
//     // You can create a separate screen for all projects
//     // Navigator.push(context, MaterialPageRoute(builder: (context) => AllProjectsScreen()));
//   }

//   void _navigateToAttendanceDetails(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const AttendanceDetailScreen()),
//     );
//   }

//   void _navigateToEmployeeDetails(
//     BuildContext context,
//     ManagerDashboardViewModel viewModel,
//   ) {
//     final teamMembers = viewModel.dashboard?.teamMembers ?? [];
//     if (teamMembers.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No team members available'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const EmployeeListScreen()),
//     );
//   }
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/managermodels/manager_dashboard_model.dart';
// import 'package:attendanceapp/models/projectmodels/project_models.dart';
// import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:attendanceapp/view_models/projectviewmodels/project_view_model.dart';
// import 'package:attendanceapp/views/managerviews/ProjectDetailScreens.dart';
// import 'package:attendanceapp/views/managerviews/attendance_detail_screen.dart';
// import 'package:attendanceapp/views/managerviews/employee_list_screen.dart';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class DashboardCardsSection extends StatefulWidget {
//   const DashboardCardsSection({super.key});

//   @override
//   State<DashboardCardsSection> createState() => _DashboardCardsSectionState();
// }

// class _DashboardCardsSectionState extends State<DashboardCardsSection> {
//   @override
//   void initState() {
//     super.initState();
//     // Initialize project data when widget loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final projectViewModel = Provider.of<ProjectViewModel>(
//         context,
//         listen: false,
//       );
//       projectViewModel.initialize();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = Provider.of<ManagerDashboardViewModel>(context);
//     final stats = viewModel.stats;

//     if (stats == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final isPortrait = constraints.maxHeight > constraints.maxWidth;
//         final crossAxisCount = isPortrait ? 2 : 4;
//         final childAspectRatio = isPortrait ? 1.4 : 1.2;

//         return SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // Stats Cards - Responsive Design
//                 // _buildPremiumStatsRow(stats, constraints),
//                 // const SizedBox(height: 24),

//                 // Project Details Cards - Responsive Row
//                 _buildProjectsSection(context),
//                 const SizedBox(height: 30),

//                 // Quick Actions - Responsive Grid
//                 _buildPremiumQuickActions(
//                   context,
//                   viewModel,
//                   crossAxisCount,
//                   childAspectRatio,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildPremiumStatsRow(
//     DashboardStats stats,
//     BoxConstraints constraints,
//   ) {
//     final isPortrait = constraints.maxHeight > constraints.maxWidth;
//     final spacing = isPortrait ? 8.0 : 16.0;

//     // ✅ DEBUG: Let's check what values we're getting
//     print('🔍 DEBUG STATS:');
//     print('Total Team Members: ${stats.totalTeamMembers}');
//     print('Overall Present: ${stats.overallPresent}');
//     print('Present Today: ${stats.presentToday}');
//     print('Absent Today: ${stats.absentToday}');

//     // ✅ SAFE Percentage Calculation with validation
//     final totalTeamMembers = stats.totalTeamMembers;
//     final overallPresentValue = stats.overallPresent;

//     int overallPresentPercentage;

//     if (totalTeamMembers <= 0) {
//       overallPresentPercentage = 0;
//     } else if (overallPresentValue > totalTeamMembers) {
//       // ✅ If overallPresent is greater than total members, cap at 100%
//       print(
//         '⚠️ WARNING: overallPresent ($overallPresentValue) > totalTeamMembers ($totalTeamMembers)',
//       );
//       overallPresentPercentage = 100;
//     } else {
//       overallPresentPercentage = (overallPresentValue / totalTeamMembers * 100)
//           .round();
//     }

//     print('📊 Calculated Percentage: $overallPresentPercentage%');

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.primary.withOpacity(0.8),
//             AppColors.secondary.withOpacity(0.6),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildPremiumStatItem(
//             'Team',
//             stats.totalTeamMembers,
//             Icons.people_alt_rounded,
//           ),
//           SizedBox(width: spacing),
//           _buildPremiumStatItem(
//             'Present',
//             stats.presentToday,
//             Icons.verified_user_rounded,
//           ),
//           SizedBox(width: spacing),
//           _buildPremiumStatItem(
//             'Absent',
//             stats.absentToday,
//             Icons.person_off_rounded,
//           ),
//           SizedBox(width: spacing),
//           _buildPremiumStatItem(
//             'Leaves',
//             stats.pendingLeaves,
//             Icons.beach_access_rounded,
//           ),
//           SizedBox(width: spacing),
//           // ✅ Safe percentage display
//           _buildPremiumStatItem(
//             'OverAll Present',
//             overallPresentPercentage,
//             Icons.trending_up_rounded,
//             isPercentage: true, // ✅ This parameter now exists
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ UPDATED METHOD with isPercentage parameter
//   Widget _buildPremiumStatItem(
//     String label,
//     int value,
//     IconData icon, {
//     bool isPercentage = false, // ✅ Add this optional parameter
//   }) {
//     return Flexible(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 2,
//               ),
//             ),
//             child: Icon(icon, size: 22, color: Colors.white),
//           ),
//           const SizedBox(height: 12),
//           FittedBox(
//             child: Text(
//               isPercentage
//                   ? '$value%'
//                   : value.toString(), // ✅ Conditional display
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w800,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           const SizedBox(height: 4),
//           FittedBox(
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.white.withOpacity(0.9),
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget _buildPremiumStatItem(String label, int value, IconData icon) {
//   //   return Flexible(
//   //     child: Column(
//   //       mainAxisSize: MainAxisSize.min,
//   //       children: [
//   //         Container(
//   //           padding: const EdgeInsets.all(12),
//   //           decoration: BoxDecoration(
//   //             color: Colors.white.withOpacity(0.2),
//   //             shape: BoxShape.circle,
//   //             border: Border.all(
//   //               color: Colors.white.withOpacity(0.3),
//   //               width: 2,
//   //             ),
//   //           ),
//   //           child: Icon(icon, size: 22, color: Colors.white),
//   //         ),
//   //         const SizedBox(height: 12),
//   //         FittedBox(
//   //           child: Text(
//   //             value.toString(),
//   //             style: const TextStyle(
//   //               fontSize: 20,
//   //               fontWeight: FontWeight.w800,
//   //               color: Colors.white,
//   //             ),
//   //           ),
//   //         ),
//   //         const SizedBox(height: 4),
//   //         FittedBox(
//   //           child: Text(
//   //             label,
//   //             style: TextStyle(
//   //               fontSize: 12,
//   //               color: Colors.white.withOpacity(0.9),
//   //               fontWeight: FontWeight.w600,
//   //             ),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   Widget _buildPremiumQuickActions(
//     BuildContext context,
//     ManagerDashboardViewModel viewModel,
//     int crossAxisCount,
//     double childAspectRatio,
//   ) {
//     return Column(
//       children: [
//         GridView.count(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           crossAxisCount: crossAxisCount,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//           childAspectRatio: childAspectRatio,
//           children: [
//             _buildPremiumActionCard(
//               'Attendance',
//               '',
//               Icons.assignment_turned_in_rounded,
//               Colors.blue.shade600,
//               () => _navigateToAttendanceDetails(context),
//             ),
//             _buildPremiumActionCard(
//               'Employees',
//               '',
//               Icons.people_alt_rounded,
//               Colors.green.shade600,
//               () => _navigateToEmployeeDetails(context, viewModel),
//             ),
//             // _buildPremiumActionCard(
//             //   'Projects',
//             //   'Active projects',
//             //   Icons.work_history_rounded,
//             //   Colors.orange.shade600,
//             //   () => _navigateToAllProjects(context),
//             // ),
//             // _buildPremiumActionCard(
//             //   'Reports',
//             //   'Generate reports',
//             //   Icons.analytics_rounded,
//             //   Colors.purple.shade600,
//             //   () {},
//             // ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildPremiumActionCard(
//     String title,
//     String subtitle,
//     IconData icon,
//     Color color,
//     VoidCallback onTap,
//   ) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(16),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(16),
//           splashColor: Colors.white.withOpacity(0.2),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.white.withOpacity(0.3)),
//                   ),
//                   child: Icon(icon, color: Colors.white, size: 24),
//                 ),
//                 Flexible(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       FittedBox(
//                         child: Text(
//                           title,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Flexible(
//                         child: Text(
//                           subtitle,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.white.withOpacity(0.9),
//                             fontWeight: FontWeight.w500,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Widget _buildProjectsSection(BuildContext context) {
//   //   return Consumer<ProjectViewModel>(
//   //     builder: (context, projectViewModel, child) {
//   //       final projects = projectViewModel.projects;

//   //       if (projectViewModel.isLoading) {
//   //         return const Center(child: CircularProgressIndicator());
//   //       }

//   //       if (projects.isEmpty) {
//   //         return _buildEmptyProjectsState();
//   //       }

//   //       return Column(
//   //         crossAxisAlignment: CrossAxisAlignment.start,
//   //         children: [
//   //           const Padding(
//   //             padding: EdgeInsets.symmetric(vertical: 16),
//   //             child: Text(
//   //               'Active Projects',
//   //               style: TextStyle(
//   //                 fontSize: 20,
//   //                 fontWeight: FontWeight.w700,
//   //                 color: AppColors.textPrimary,
//   //               ),
//   //             ),
//   //           ),
//   //           SizedBox(
//   //             height: 140,
//   //             child: ListView(
//   //               scrollDirection: Axis.horizontal,
//   //               children: projects
//   //                   .map(
//   //                     (project) => Padding(
//   //                       padding: const EdgeInsets.only(right: 12),
//   //                       child: _buildProjectCard(
//   //                         context,
//   //                         project,
//   //                         projectViewModel,
//   //                       ),
//   //                     ),
//   //                   )
//   //                   .toList(),
//   //             ),
//   //           ),
//   //         ],
//   //       );
//   //     },
//   //   );
//   // }

//   Widget _buildProjectsSection(BuildContext context) {
//     return Consumer<ProjectViewModel>(
//       builder: (context, projectViewModel, child) {
//         final projects = projectViewModel.projects;

//         if (projectViewModel.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (projects.isEmpty) {
//           return _buildEmptyProjectsState();
//         }

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 12),
//               child: Text(
//                 'Mapped Project',
//                 style: TextStyle(
//                   fontSize: 18, // Slightly smaller
//                   fontWeight: FontWeight.w700,
//                   color: Color.fromARGB(255, 255, 255, 255),
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 100, // Fixed height
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 children: projects
//                     .map(
//                       (project) => Padding(
//                         padding: const EdgeInsets.only(right: 8),
//                         child: _buildProjectCard(
//                           context,
//                           project,
//                           projectViewModel,
//                         ),
//                       ),
//                     )
//                     .toList(),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Widget _buildProjectCard(
//   //   BuildContext context,
//   //   Project project,
//   //   ProjectViewModel projectViewModel,
//   // ) {
//   //   return Container(
//   //     width: 220,
//   //     decoration: BoxDecoration(
//   //       borderRadius: BorderRadius.circular(16),
//   //       gradient: LinearGradient(
//   //         begin: Alignment.topLeft,
//   //         end: Alignment.bottomRight,
//   //         colors: [
//   //           projectViewModel.getStatusColor(project.status).withOpacity(0.9),
//   //           projectViewModel.getStatusColor(project.status).withOpacity(0.7),
//   //         ],
//   //       ),
//   //       boxShadow: [
//   //         BoxShadow(
//   //           color: projectViewModel
//   //               .getStatusColor(project.status)
//   //               .withOpacity(0.3),
//   //           blurRadius: 12,
//   //           offset: const Offset(0, 6),
//   //         ),
//   //       ],
//   //     ),
//   //     child: Material(
//   //       color: Colors.transparent,
//   //       borderRadius: BorderRadius.circular(16),
//   //       child: InkWell(
//   //         onTap: () => _navigateToProjectDetail(context, project),
//   //         borderRadius: BorderRadius.circular(16),
//   //         splashColor: Colors.white.withOpacity(0.2),
//   //         child: Padding(
//   //           padding: const EdgeInsets.all(16),
//   //           child: Column(
//   //             crossAxisAlignment: CrossAxisAlignment.start,
//   //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //             children: [
//   //               Row(
//   //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                 children: [
//   //                   Container(
//   //                     padding: const EdgeInsets.all(8),
//   //                     decoration: BoxDecoration(
//   //                       color: Colors.white.withOpacity(0.2),
//   //                       borderRadius: BorderRadius.circular(12),
//   //                       border: Border.all(
//   //                         color: Colors.white.withOpacity(0.3),
//   //                       ),
//   //                     ),
//   //                     child: const Icon(
//   //                       Icons.work_history_rounded,
//   //                       color: Colors.white,
//   //                       size: 20,
//   //                     ),
//   //                   ),
//   //                   Container(
//   //                     padding: const EdgeInsets.symmetric(
//   //                       horizontal: 8,
//   //                       vertical: 4,
//   //                     ),
//   //                     decoration: BoxDecoration(
//   //                       color: Colors.white.withOpacity(0.3),
//   //                       borderRadius: BorderRadius.circular(12),
//   //                     ),
//   //                     child: Text(
//   //                       projectViewModel
//   //                           .getStatusText(project.status)
//   //                           .toUpperCase(),
//   //                       style: const TextStyle(
//   //                         fontSize: 10,
//   //                         fontWeight: FontWeight.w700,
//   //                         color: Colors.white,
//   //                       ),
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //               Column(
//   //                 crossAxisAlignment: CrossAxisAlignment.start,
//   //                 children: [
//   //                   Text(
//   //                     project.name,
//   //                     style: const TextStyle(
//   //                       fontSize: 14,
//   //                       fontWeight: FontWeight.w700,
//   //                       color: Colors.white,
//   //                     ),
//   //                     maxLines: 1,
//   //                     overflow: TextOverflow.ellipsis,
//   //                   ),
//   //                   const SizedBox(height: 4),
//   //                   Text(
//   //                     project.client,
//   //                     style: TextStyle(
//   //                       fontSize: 11,
//   //                       color: Colors.white.withOpacity(0.9),
//   //                       fontWeight: FontWeight.w500,
//   //                     ),
//   //                     maxLines: 1,
//   //                     overflow: TextOverflow.ellipsis,
//   //                   ),
//   //                   const SizedBox(height: 8),
//   //                   Row(
//   //                     children: [
//   //                       Expanded(
//   //                         child: LinearProgressIndicator(
//   //                           value: project.progress / 100,
//   //                           backgroundColor: Colors.white.withOpacity(0.3),
//   //                           valueColor: AlwaysStoppedAnimation<Color>(
//   //                             Colors.white.withOpacity(0.8),
//   //                           ),
//   //                           borderRadius: BorderRadius.circular(10),
//   //                         ),
//   //                       ),
//   //                       const SizedBox(width: 8),
//   //                       Text(
//   //                         '${project.progress.toInt()}%',
//   //                         style: const TextStyle(
//   //                           fontSize: 12,
//   //                           fontWeight: FontWeight.w700,
//   //                           color: Colors.white,
//   //                         ),
//   //                       ),
//   //                     ],
//   //                   ),
//   //                   const SizedBox(height: 4),
//   //                   Row(
//   //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                     children: [
//   //                       Text(
//   //                         '${project.teamSize} members',
//   //                         style: TextStyle(
//   //                           fontSize: 10,
//   //                           color: Colors.white.withOpacity(0.8),
//   //                         ),
//   //                       ),
//   //                       Text(
//   //                         '${project.daysRemaining}d left',
//   //                         style: TextStyle(
//   //                           fontSize: 10,
//   //                           color: Colors.white.withOpacity(0.8),
//   //                           fontWeight: FontWeight.w600,
//   //                         ),
//   //                       ),
//   //                     ],
//   //                   ),
//   //                 ],
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }

//   Widget _buildProjectCard(
//     BuildContext context,
//     Project project,
//     ProjectViewModel projectViewModel,
//   ) {
//     return Container(
//       width: 240, // Further reduced width
//       height: 140, // Fixed height instead of constraints
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12), // Smaller radius
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             projectViewModel.getStatusColor(project.status).withOpacity(0.9),
//             projectViewModel.getStatusColor(project.status).withOpacity(0.7),
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: projectViewModel
//                 .getStatusColor(project.status)
//                 .withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(12),
//         child: InkWell(
//           onTap: () => _navigateToProjectDetail(context, project),
//           borderRadius: BorderRadius.circular(12),
//           splashColor: Colors.white.withOpacity(0.2),
//           child: Padding(
//             padding: const EdgeInsets.all(8), // Minimal padding
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Top row - Icon and Status
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(3), // Very small padding
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: const Icon(
//                         Icons.work_history_rounded,
//                         color: Colors.white,
//                         size: 14, // Smaller icon
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 4,
//                         vertical: 1,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.3),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         _getShortStatus(
//                           projectViewModel.getStatusText(project.status),
//                         ),
//                         style: const TextStyle(
//                           fontSize: 8, // Very small font
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 // Project Name - Single line
//                 Text(
//                   _truncateText(project.name, 30),
//                   style: const TextStyle(
//                     fontSize: 12, // Smaller font
//                     fontWeight: FontWeight.w700,
//                     color: Colors.white,
//                     height: 1.2,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),

//                 // Client Name - Single line
//                 Text(
//                   _truncateText(project.client, 30),
//                   style: TextStyle(
//                     fontSize: 8, // Smaller font
//                     color: Colors.white.withOpacity(0.9),
//                     fontWeight: FontWeight.w500,
//                     height: 1.1,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),

//                 // Progress bar and percentage
//                 // Row(
//                 //   children: [
//                 //     Expanded(
//                 //       child: LinearProgressIndicator(
//                 //         value: project.progress / 100,
//                 //         backgroundColor: Colors.white.withOpacity(0.2),
//                 //         valueColor: AlwaysStoppedAnimation<Color>(
//                 //           Colors.white.withOpacity(0.8),
//                 //         ),
//                 //         borderRadius: BorderRadius.circular(2),
//                 //         minHeight: 3, // Very thin
//                 //       ),
//                 //     ),
//                 //     const SizedBox(width: 4),
//                 //     Text(
//                 //       '${project.progress.toInt()}%',
//                 //       style: const TextStyle(
//                 //         fontSize: 8, // Smaller font
//                 //         fontWeight: FontWeight.w700,
//                 //         color: Colors.white,
//                 //       ),
//                 //     ),
//                 //   ],
//                 // ),

//                 // Bottom info - Team and Days
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '${project.teamSize}',
//                       style: TextStyle(
//                         fontSize: 9, // Very small font
//                         color: Colors.white.withOpacity(0.8),
//                       ),
//                     ),
//                     Text(
//                       '${project.daysRemaining}d',
//                       style: TextStyle(
//                         fontSize: 9, // Very small font
//                         color: Colors.white.withOpacity(0.8),
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper methods for text truncation
//   String _truncateText(String text, int maxLength) {
//     if (text.length <= maxLength) return text;
//     return '${text.substring(0, maxLength)}...';
//   }

//   String _getShortStatus(String status) {
//     switch (status.toLowerCase()) {
//       case 'active':
//         return 'ACT';
//       case 'planning':
//         return 'PLN';
//       case 'completed':
//         return 'COM';
//       case 'on-hold':
//         return 'HLD';
//       default:
//         return status.substring(0, 3).toUpperCase();
//     }
//   }

//   Widget _buildEmptyProjectsState() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.symmetric(vertical: 16),
//           child: Text(
//             'Projects',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//               color: AppColors.textPrimary,
//             ),
//           ),
//         ),
//         Container(
//           height: 120,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.work_outline, size: 40, color: Colors.grey),
//                 SizedBox(height: 8),
//                 Text(
//                   'No projects available',
//                   style: TextStyle(color: Colors.grey, fontSize: 16),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _navigateToProjectDetail(BuildContext context, Project project) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProjectDetailScreen(project: project),
//       ),
//     );
//   }

//   void _navigateToAllProjects(BuildContext context) {
//     // You can create a separate screen for all projects
//     // Navigator.push(context, MaterialPageRoute(builder: (context) => AllProjectsScreen()));
//   }

//   void _navigateToAttendanceDetails(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const AttendanceDetailScreen()),
//     );
//   }

//   void _navigateToEmployeeDetails(
//     BuildContext context,
//     ManagerDashboardViewModel viewModel,
//   ) {
//     final teamMembers = viewModel.dashboard?.teamMembers ?? [];
//     if (teamMembers.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No team members available'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const EmployeeListScreen()),
//     );
//   }
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/managermodels/manager_dashboard_model.dart';
// import 'package:attendanceapp/models/projectmodels/project_models.dart';
// import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:attendanceapp/view_models/projectviewmodels/project_view_model.dart';
// import 'package:attendanceapp/views/managerviews/ProjectDetailScreens.dart';
// import 'package:attendanceapp/views/managerviews/attendance_detail_screen.dart';
// import 'package:attendanceapp/views/managerviews/employee_list_screen.dart';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class DashboardCardsSection extends StatelessWidget {
//   const DashboardCardsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = Provider.of<ManagerDashboardViewModel>(context);
//     final stats = viewModel.stats;

//     if (stats == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final isPortrait = constraints.maxHeight > constraints.maxWidth;
//         final crossAxisCount = isPortrait ? 2 : 4;
//         final childAspectRatio = isPortrait ? 1.4 : 1.2;

//         return SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // Stats Cards - Responsive Design
//                 _buildPremiumStatsRow(stats, constraints),
//                 const SizedBox(height: 24),

//                 // Quick Actions - Responsive Grid
//                 _buildPremiumQuickActions(
//                   context,
//                   viewModel,
//                   crossAxisCount,
//                   childAspectRatio,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildPremiumStatsRow(
//     DashboardStats stats,
//     BoxConstraints constraints,
//   ) {
//     final isPortrait = constraints.maxHeight > constraints.maxWidth;
//     final itemCount = 5;
//     final spacing = isPortrait ? 8.0 : 16.0;

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.primary.withOpacity(0.8),
//             AppColors.secondary.withOpacity(0.6),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildPremiumStatItem(
//             'Team',
//             stats.totalTeamMembers,
//             Icons.people_alt_rounded,
//           ),
//           SizedBox(width: spacing),
//           _buildPremiumStatItem(
//             'Present',
//             stats.presentToday,
//             Icons.verified_user_rounded,
//           ),
//           SizedBox(width: spacing),
//           _buildPremiumStatItem(
//             'Absent',
//             stats.absentToday,
//             Icons.person_off_rounded,
//           ),
//           SizedBox(width: spacing),
//           _buildPremiumStatItem(
//             'Leaves',
//             stats.pendingLeaves,
//             Icons.beach_access_rounded,
//           ),
//           SizedBox(width: spacing),
//           _buildPremiumStatItem(
//             'OverAll Present',
//             stats.overallPresent,
//             Icons.trending_up_rounded,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPremiumStatItem(String label, int value, IconData icon) {
//     return Flexible(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 2,
//               ),
//             ),
//             child: Icon(icon, size: 22, color: Colors.white),
//           ),
//           const SizedBox(height: 12),
//           FittedBox(
//             child: Text(
//               value.toString(),
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w800,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           const SizedBox(height: 4),
//           FittedBox(
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.white.withOpacity(0.9),
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPremiumQuickActions(
//     BuildContext context,
//     ManagerDashboardViewModel viewModel,
//     int crossAxisCount,
//     double childAspectRatio,
//   ) {
//     return Column(
//       children: [
//         GridView.count(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           crossAxisCount: crossAxisCount,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//           childAspectRatio: childAspectRatio,
//           children: [
//             _buildPremiumActionCard(
//               'Attendance',
//               '',
//               Icons.assignment_turned_in_rounded,
//               Colors.blue.shade600,
//               () => _navigateToAttendanceDetails(context),
//             ),
//             _buildPremiumActionCard(
//               'Employees',
//               '',
//               Icons.people_alt_rounded,
//               Colors.green.shade600,
//               () => _navigateToEmployeeDetails(context, viewModel),
//             ),
//             _buildPremiumActionCard(
//               'Projects',
//               'Active projects',
//               Icons.work_history_rounded,
//               Colors.orange.shade600,
//               () {}, // You can keep this or remove it since we have the horizontal section
//             ),
//             _buildPremiumActionCard(
//               'Reports',
//               'Generate reports',
//               Icons.analytics_rounded,
//               Colors.purple.shade600,
//               () {},
//             ),
//           ],
//         ),

//         // Add projects section below the grid
//         const SizedBox(height: 24),
//         _buildProjectsSection(context),
//       ],
//     );
//   }

//   Widget _buildPremiumActionCard(
//     String title,
//     String subtitle,
//     IconData icon,
//     Color color,
//     VoidCallback onTap,
//   ) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(16),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(16),
//           splashColor: Colors.white.withOpacity(0.2),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.white.withOpacity(0.3)),
//                   ),
//                   child: Icon(icon, color: Colors.white, size: 24),
//                 ),
//                 Flexible(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       FittedBox(
//                         fit: BoxFit.scaleDown,
//                         child: Text(
//                           title,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Flexible(
//                         child: Text(
//                           subtitle,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.white.withOpacity(0.9),
//                             fontWeight: FontWeight.w500,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProjectsSection(BuildContext context) {
//     final projectViewModel = Provider.of<ProjectViewModel>(
//       context,
//       listen: true,
//     );
//     final projects = projectViewModel.projects;

//     if (projectViewModel.isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (projects.isEmpty) {
//       return _buildEmptyProjectsState();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.symmetric(vertical: 16),
//           child: Text(
//             'Active Projects',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//               color: AppColors.textPrimary,
//             ),
//           ),
//         ),

//         // Horizontal scrollable projects row
//         SizedBox(
//           height: 140,
//           child: ListView(
//             scrollDirection: Axis.horizontal,
//             children: projects
//                 .map(
//                   (project) => Padding(
//                     padding: const EdgeInsets.only(right: 12),
//                     child: _buildProjectCard(
//                       context,
//                       project,
//                       projectViewModel,
//                     ),
//                   ),
//                 )
//                 .toList(),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildProjectCard(
//     BuildContext context,
//     Project project,
//     ProjectViewModel projectViewModel,
//   ) {
//     return Container(
//       width: 220,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             projectViewModel.getStatusColor(project.status).withOpacity(0.9),
//             projectViewModel.getStatusColor(project.status).withOpacity(0.7),
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: projectViewModel
//                 .getStatusColor(project.status)
//                 .withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(16),
//         child: InkWell(
//           onTap: () => _navigateToProjectDetail(context, project),
//           borderRadius: BorderRadius.circular(16),
//           splashColor: Colors.white.withOpacity(0.2),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.3),
//                         ),
//                       ),
//                       child: const Icon(
//                         Icons.work_history_rounded,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.3),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         projectViewModel
//                             .getStatusText(project.status)
//                             .toUpperCase(),
//                         style: const TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       project.name,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       project.client,
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: Colors.white.withOpacity(0.9),
//                         fontWeight: FontWeight.w500,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: LinearProgressIndicator(
//                             value: project.progress / 100,
//                             backgroundColor: Colors.white.withOpacity(0.3),
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               Colors.white.withOpacity(0.8),
//                             ),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           '${project.progress.toInt()}%',
//                           style: const TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           '${project.teamSize} members',
//                           style: TextStyle(
//                             fontSize: 10,
//                             color: Colors.white.withOpacity(0.8),
//                           ),
//                         ),
//                         Text(
//                           '${project.daysRemaining}d left',
//                           style: TextStyle(
//                             fontSize: 10,
//                             color: Colors.white.withOpacity(0.8),
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyProjectsState() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.symmetric(vertical: 16),
//           child: Text(
//             'Projects',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//               color: AppColors.textPrimary,
//             ),
//           ),
//         ),
//         Container(
//           height: 120,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.work_outline, size: 40, color: Colors.grey),
//                 SizedBox(height: 8),
//                 Text(
//                   'No projects available',
//                   style: TextStyle(color: Colors.grey, fontSize: 16),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _navigateToProjectDetail(BuildContext context, Project project) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProjectDetailScreen(project: project),
//       ),
//     );
//   }

//   void _navigateToAttendanceDetails(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const AttendanceDetailScreen()),
//     );
//   }

//   void _navigateToEmployeeDetails(
//     BuildContext context,
//     ManagerDashboardViewModel viewModel,
//   ) {
//     final teamMembers = viewModel.dashboard?.teamMembers ?? [];

//     if (teamMembers.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No team members available'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const EmployeeListScreen()),
//     );
//   }
// }

/* *********************************************************************************************************** */
/* *********************************************************************************************************** */

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/managermodels/manager_dashboard_model.dart';
// import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:attendanceapp/views/managerviews/attendance_detail_screen.dart';
// import 'package:attendanceapp/views/managerviews/employee_list_screen.dart';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class DashboardCardsSection extends StatelessWidget {
//   const DashboardCardsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = Provider.of<ManagerDashboardViewModel>(context);
//     final stats = viewModel.stats;

//     if (stats == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final isPortrait = constraints.maxHeight > constraints.maxWidth;
//         final crossAxisCount = isPortrait ? 2 : 4;
//         final childAspectRatio = isPortrait ? 1.4 : 1.2;

//         return SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // Stats Cards - Responsive Design
//                 _buildPremiumStatsRow(stats, constraints),
//                 const SizedBox(height: 24),

//                 // Quick Actions - Responsive Grid
//                 _buildPremiumQuickActions(
//                   context,
//                   viewModel,
//                   crossAxisCount,
//                   childAspectRatio,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildPremiumStatsRow(
//     DashboardStats stats,
//     BoxConstraints constraints,
//   ) {
//     final isPortrait = constraints.maxHeight > constraints.maxWidth;
//     final itemCount = 4;
//     final spacing = isPortrait ? 8.0 : 16.0;

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.primary.withOpacity(0.8),
//             AppColors.secondary.withOpacity(0.6),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildPremiumStatItem(
//             'Team',
//             stats.totalTeamMembers,
//             Icons.people_alt_rounded,
//           ),
//           SizedBox(width: spacing),
//           _buildPremiumStatItem(
//             'Present',
//             stats.presentToday,
//             Icons.verified_user_rounded,
//           ),
//           SizedBox(width: spacing),
//           _buildPremiumStatItem(
//             'Absent',
//             stats.absentToday,
//             Icons.person_off_rounded,
//           ),
//           SizedBox(width: spacing),
//           _buildPremiumStatItem(
//             'Leaves',
//             stats.pendingLeaves,
//             Icons.beach_access_rounded,
//           ),
//           SizedBox(width: spacing),
//           _buildPremiumStatItem(
//             'OverAll Present',
//             stats.overallPresent,
//             Icons.trending_up_rounded,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPremiumStatItem(String label, int value, IconData icon) {
//     return Flexible(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 2,
//               ),
//             ),
//             child: Icon(icon, size: 22, color: Colors.white),
//           ),
//           const SizedBox(height: 12),
//           FittedBox(
//             child: Text(
//               value.toString(),
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w800,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           const SizedBox(height: 4),
//           FittedBox(
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.white.withOpacity(0.9),
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPremiumQuickActions(
//     BuildContext context,
//     ManagerDashboardViewModel viewModel,
//     int crossAxisCount,
//     double childAspectRatio,
//   ) {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: crossAxisCount,
//       crossAxisSpacing: 16,
//       mainAxisSpacing: 16,
//       childAspectRatio: childAspectRatio,
//       children: [
//         _buildPremiumActionCard(
//           'Attendance',
//           '',
//           Icons.assignment_turned_in_rounded,
//           Colors.blue.shade600,
//           () => _navigateToAttendanceDetails(context),
//         ),
//         _buildPremiumActionCard(
//           'Employees',
//           '',
//           Icons.people_alt_rounded,
//           Colors.green.shade600,
//           () => _navigateToEmployeeDetails(context, viewModel),
//         ),
//         // _buildPremiumActionCard(
//         //   'Projects',
//         //   'Active projects',
//         //   Icons.work_history_rounded,
//         //   Colors.orange.shade600,
//         //   () => _navigateToProjectDetails(context),
//         // ),
//         // _buildPremiumActionCard(
//         //   'Reports',
//         //   'Generate reports',
//         //   Icons.analytics_rounded,
//         //   Colors.purple.shade600,
//         //   () {},
//         // ),
//       ],
//     );
//   }

//   Widget _buildPremiumActionCard(
//     String title,
//     String subtitle,
//     IconData icon,
//     Color color,
//     VoidCallback onTap,
//   ) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(16),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(16),
//           splashColor: Colors.white.withOpacity(0.2),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.white.withOpacity(0.3)),
//                   ),
//                   child: Icon(icon, color: Colors.white, size: 24),
//                 ),
//                 Flexible(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       FittedBox(
//                         fit: BoxFit.scaleDown,
//                         child: Text(
//                           title,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Flexible(
//                         child: Text(
//                           subtitle,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.white.withOpacity(0.9),
//                             fontWeight: FontWeight.w500,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _navigateToAttendanceDetails(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const AttendanceDetailScreen()),
//     );
//   }

//   void _navigateToEmployeeDetails(
//     BuildContext context,
//     ManagerDashboardViewModel viewModel,
//   ) {
//     final teamMembers = viewModel.dashboard?.teamMembers ?? [];

//     if (teamMembers.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No team members available'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const EmployeeListScreen()),
//     );
//   }

//   void _navigateToProjectDetails(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const ProjectDetailsScreen()),
//     );
//   }
// }

/* *********************************************************************************************************** */
/* *********************************************************************************************************** */

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/managermodels/manager_dashboard_model.dart';
// import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:attendanceapp/views/managerviews/attendance_detail_screen.dart';
// import 'package:attendanceapp/views/managerviews/employee_list_screen.dart';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class DashboardCardsSection extends StatelessWidget {
//   const DashboardCardsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = Provider.of<ManagerDashboardViewModel>(context);
//     final stats = viewModel.stats;

//     if (stats == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         children: [
//           // Feature Cards
//           Expanded(
//             child: GridView(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 childAspectRatio: 1.2,
//               ),
//               children: [
//                 _buildFeatureCard(
//                   title: 'Attendance Details',
//                   subtitle: 'Team attendance records',
//                   icon: Icons.assignment_turned_in_rounded,
//                   color: AppColors.primary,
//                   onTap: () => _navigateToAttendanceDetails(context),
//                 ),
//                 _buildFeatureCard(
//                   title: 'Employee Details',
//                   subtitle: 'Team member information',
//                   icon: Icons.people_alt_rounded,
//                   color: AppColors.secondary,
//                   onTap: () => _navigateToEmployeeDetails(context, viewModel),
//                 ),
//                 _buildFeatureCard(
//                   title: 'Project Details',
//                   subtitle: 'Active projects overview',
//                   icon: Icons.work_rounded,
//                   color: AppColors.success,
//                   onTap: () => _navigateToProjectDetails(context),
//                 ),
//                 _buildFeatureCard(
//                   title: 'Reports',
//                   subtitle: 'Generate team reports',
//                   icon: Icons.analytics_rounded,
//                   color: AppColors.info,
//                   onTap: () {},
//                 ),
//               ],
//             ),
//           ),
//           // Stats Overview
//           const SizedBox(height: 20),
//           _buildStatsOverview(stats),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsOverview(DashboardStats stats) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.primary.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColors.primary.withOpacity(0.1)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildStatItem('Team', stats.totalTeamMembers, Icons.people_rounded),
//           _buildStatItem(
//             'Present',
//             stats.presentToday,
//             Icons.check_circle_rounded,
//           ),
//           _buildStatItem('Projects', stats.activeProjects, Icons.work_rounded),
//           _buildStatItem(
//             'Leaves',
//             stats.pendingLeaves,
//             Icons.beach_access_rounded,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem(String label, int value, IconData icon) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: AppColors.primary.withOpacity(0.1),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, size: 20, color: AppColors.primary),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value.toString(),
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
//         ),
//       ],
//     );
//   }

//   Widget _buildFeatureCard({
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(icon, color: color, size: 24),
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _navigateToAttendanceDetails(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const AttendanceDetailScreen()),
//     );
//   }

//   // In your DashboardCardsSection, update the _navigateToEmployeeDetails method:
//   void _navigateToEmployeeDetails(
//     BuildContext context,
//     ManagerDashboardViewModel viewModel,
//   ) {
//     final teamMembers = viewModel.dashboard?.teamMembers ?? [];

//     if (teamMembers.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No team members available'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const EmployeeListScreen()),
//     );
//   }

//   void _navigateToProjectDetails(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const ProjectDetailsScreen()),
//     );
//   }
// }
