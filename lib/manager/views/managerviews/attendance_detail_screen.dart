import 'package:AttendanceApp/manager/core/view_models/theme_view_model.dart';
import 'package:AttendanceApp/manager/models/projectmodels/project_models.dart';
import 'package:AttendanceApp/manager/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
import 'package:AttendanceApp/manager/view_models/managerviewmodels/manager_dashboard_view_model.dart';
import 'package:AttendanceApp/manager/view_models/projectviewmodels/project_view_model.dart';
import 'package:AttendanceApp/manager/views/managerviews/projectmodeview/project_detail_screen.dart';
import 'package:AttendanceApp/manager/widgets/analytics/graph_toggle.dart';
import 'package:AttendanceApp/manager/widgets/analytics/horizontalAttendanceStats.dart';
import 'package:AttendanceApp/manager/widgets/analytics/individualmodeanalytics/individual_graphs.dart';
import 'package:AttendanceApp/manager/widgets/analytics/merged_graph.dart';
import 'package:AttendanceApp/manager/widgets/analytics/period_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AttendanceDetailScreen extends StatefulWidget {
  const AttendanceDetailScreen({super.key});

  @override
  _AttendanceDetailScreenState createState() => _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
  int _currentGraphView = 0; // 0 = Merged, 1 = Individual, 2 = Project

  @override
  void initState() {
    super.initState();
    _initializeAnalytics();
    _initializeProjects();
  }

  void _initializeAnalytics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardViewModel = Provider.of<ManagerDashboardViewModel>(
        context,
        listen: false,
      );
      final analyticsViewModel = Provider.of<AttendanceAnalyticsViewModel>(
        context,
        listen: false,
      );

      final teamMembers = dashboardViewModel.dashboard?.teamMembers ?? [];
      analyticsViewModel.initializeAnalytics(teamMembers);
    });
  }

  void _initializeProjects() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projectViewModel = Provider.of<ProjectViewModel>(
        context,
        listen: false,
      );
      projectViewModel.loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);
    final isDarkMode = theme.isDarkMode;
    final viewModel = Provider.of<AttendanceAnalyticsViewModel>(context);

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: viewModel.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            )
          : _buildContent(viewModel, isDarkMode),
    );
  }

  Widget _buildContent(
    AttendanceAnalyticsViewModel viewModel,
    bool isDarkMode,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(isDarkMode),
          const SizedBox(height: 20),
          PeriodSelector(viewModel: viewModel),
          const SizedBox(height: 20),
          HorizontalAttendanceStats(
            totalEmployees: 50,
            presentCount: 35,
            leaveCount: 5,
            absentCount: 10,
            onTimeCount: 30,
            lateCount: 5,
          ),
          const SizedBox(height: 20),
          GraphToggle(
            viewModel: viewModel,
            onViewChanged: (viewIndex) {
              setState(() {
                _currentGraphView = viewIndex;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildGraphSection(viewModel, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            'Attendance Analytics',
            style: TextStyle(
              color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.refresh_rounded,
            color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
            size: 20,
          ),
          onPressed: _refreshData,
        ),
      ],
    );
  }

  Widget _buildGraphSection(
    AttendanceAnalyticsViewModel viewModel,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDarkMode ? AppColors.surfaceDark : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildCurrentGraph(viewModel, isDarkMode),
    );
  }

  Widget _buildCurrentGraph(
    AttendanceAnalyticsViewModel viewModel,
    bool isDarkMode,
  ) {
    switch (_currentGraphView) {
      case 0:
        return MergedGraph(viewModel: viewModel);
      case 1:
        return IndividualGraphs(
          viewModel: viewModel,
          projectViewModel: Provider.of<ProjectViewModel>(
            context,
            listen: false,
          ),
        );
      case 2:
        return _buildProjectSection(isDarkMode);
      default:
        return MergedGraph(viewModel: viewModel);
    }
  }

  Widget _buildProjectSection(bool isDarkMode) {
    return Consumer<ProjectViewModel>(
      builder: (context, projectViewModel, child) {
        final projects = projectViewModel.projects;

        if (projects.isEmpty) {
          return _buildProjectGraphPlaceholder(isDarkMode);
        }

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Projects (${projects.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode
                      ? AppColors.textInverse
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projects.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildProjectCard(
                    projects[index],
                    projectViewModel,
                    isDarkMode,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectCard(
    Project project,
    ProjectViewModel viewModel,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDarkMode ? AppColors.grey800 : AppColors.grey50,
        border: Border.all(
          color: isDarkMode ? AppColors.grey700 : AppColors.grey200,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            _navigateToProjectDetail(project);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode
                                  ? AppColors.textInverse
                                  : AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            project.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? AppColors.grey400
                                  : AppColors.textSecondary,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildProjectStatusBadge(
                      project.status,
                      viewModel,
                      isDarkMode,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode
                                ? AppColors.grey400
                                : AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${project.progress.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getProjectStatusColor(project.status),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: project.progress / 100,
                      backgroundColor: isDarkMode
                          ? AppColors.grey700
                          : AppColors.grey300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProjectStatusColor(project.status),
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Project Metrics
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildProjectMetric(
                      Icons.people_rounded,
                      '${project.assignedTeam.length}',
                      'Team',
                      isDarkMode,
                    ),
                    _buildProjectMetric(
                      Icons.assignment_rounded,
                      '${project.tasks.length}',
                      'Tasks',
                      isDarkMode,
                    ),
                    _buildProjectMetric(
                      Icons.calendar_today_rounded,
                      '${_calculateDaysRemaining(project)}',
                      'Days Left',
                      isDarkMode,
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

  Widget _buildProjectStatusBadge(
    String status,
    ProjectViewModel viewModel,
    bool isDarkMode,
  ) {
    final color = _getProjectStatusColor(status);
    final text = status.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(isDarkMode ? 0.4 : 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildProjectMetric(
    IconData icon,
    String value,
    String label,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDarkMode ? AppColors.grey400 : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getProjectStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'completed':
        return AppColors.primary;
      case 'planning':
        return AppColors.warning;
      case 'on-hold':
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }

  Widget _buildProjectGraphPlaceholder(bool isDarkMode) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(isDarkMode ? 0.1 : 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.work_outline_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Projects Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first project to get started',
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

  void _navigateToProjectDetail(Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen(project: project),
      ),
    );
  }

  void _refreshData() {
    final dashboardViewModel = Provider.of<ManagerDashboardViewModel>(
      context,
      listen: false,
    );
    final projectViewModel = Provider.of<ProjectViewModel>(
      context,
      listen: false,
    );

    final teamMembers = dashboardViewModel.dashboard?.teamMembers ?? [];
    if (teamMembers.isNotEmpty) {
      final analyticsViewModel = Provider.of<AttendanceAnalyticsViewModel>(
        context,
        listen: false,
      );
      analyticsViewModel.initializeAnalytics(teamMembers);
    }

    projectViewModel.loadProjects();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatMonth(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  DateTime _getFirstDayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  int _getWeekNumber(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final daysDiff = date.difference(firstDay).inDays;
    return ((daysDiff + firstDay.weekday) / 7).ceil();
  }

  bool _isSameWeek(DateTime a, DateTime b) {
    final aStart = _getFirstDayOfWeek(a);
    final bStart = _getFirstDayOfWeek(b);
    return aStart.year == bStart.year &&
        aStart.month == bStart.month &&
        aStart.day == bStart.day;
  }

  int _calculateDaysRemaining(Project project) {
    final now = DateTime.now();
    if (now.isAfter(project.endDate)) return 0;
    return project.endDate.difference(now).inDays;
  }
}

// import 'package:AttendanceApp/core/view_models/theme_view_model.dart';
// import 'package:AttendanceApp/models/projectmodels/project_models.dart';
// import 'package:AttendanceApp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:AttendanceApp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:AttendanceApp/view_models/projectviewmodels/project_view_model.dart';
// import 'package:AttendanceApp/views/managerviews/projectmodeview/project_detail_screen.dart';
// import 'package:AttendanceApp/widgets/analytics/graph_toggle.dart';
// import 'package:AttendanceApp/widgets/analytics/horizontalAttendanceStats.dart';
// import 'package:AttendanceApp/widgets/analytics/individualmodeanalytics/individual_graphs.dart';
// import 'package:AttendanceApp/widgets/analytics/merged_graph.dart';
// import 'package:AttendanceApp/widgets/analytics/period_selector.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';

// class AttendanceDetailScreen extends StatefulWidget {
//   const AttendanceDetailScreen({super.key});

//   @override
//   _AttendanceDetailScreenState createState() => _AttendanceDetailScreenState();
// }

// class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
//   int _currentGraphView = 0; // 0 = Merged, 1 = Individual, 2 = Project

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnalytics();
//     _initializeProjects();
//   }

//   void _initializeAnalytics() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final dashboardViewModel = Provider.of<ManagerDashboardViewModel>(
//         context,
//         listen: false,
//       );
//       final analyticsViewModel = Provider.of<AttendanceAnalyticsViewModel>(
//         context,
//         listen: false,
//       );

//       final teamMembers = dashboardViewModel.dashboard?.teamMembers ?? [];
//       analyticsViewModel.initializeAnalytics(teamMembers);
//     });
//   }

//   void _initializeProjects() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final projectViewModel = Provider.of<ProjectViewModel>(
//         context,
//         listen: false,
//       );
//       projectViewModel.loadProjects();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);
//     final viewModel = Provider.of<AttendanceAnalyticsViewModel>(context);

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: viewModel.isLoading
//           ? const Center(
//               child: CircularProgressIndicator(
//                 color: Colors.cyan,
//                 strokeWidth: 3,
//               ),
//             )
//           : _buildContent(viewModel),
//     );
//   }

//   Widget _buildContent(AttendanceAnalyticsViewModel viewModel) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           _buildHeader(),
//           const SizedBox(height: 20),
//           PeriodSelector(viewModel: viewModel),
//           const SizedBox(height: 20),
//           HorizontalAttendanceStats(
//             totalEmployees: 50,
//             presentCount: 35,
//             leaveCount: 5,
//             absentCount: 10,
//             onTimeCount: 30,
//             lateCount: 5,
//           ),
//           const SizedBox(height: 20),
//           GraphToggle(
//             viewModel: viewModel,
//             onViewChanged: (viewIndex) {
//               setState(() {
//                 _currentGraphView = viewIndex;
//               });
//             },
//           ),
//           const SizedBox(height: 20),
//           _buildGraphSection(viewModel),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       children: [
//         IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_rounded,
//             color: Colors.white,
//             size: 20,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         const SizedBox(width: 16),
//         const Expanded(
//           child: Text(
//             'Attendance Analytics',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//         ),
//         IconButton(
//           icon: const Icon(
//             Icons.refresh_rounded,
//             color: Colors.white,
//             size: 20,
//           ),
//           onPressed: _refreshData,
//         ),
//       ],
//     );
//   }

//   Widget _buildGraphSection(AttendanceAnalyticsViewModel viewModel) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.white.withOpacity(0.05),
//       ),
//       child: _buildCurrentGraph(viewModel),
//     );
//   }

//   Widget _buildCurrentGraph(AttendanceAnalyticsViewModel viewModel) {
//     switch (_currentGraphView) {
//       case 0:
//         return MergedGraph(viewModel: viewModel);
//       case 1:
//         return IndividualGraphs(
//           viewModel: viewModel,
//           projectViewModel: Provider.of<ProjectViewModel>(
//             context,
//             listen: false,
//           ),
//         );
//       case 2:
//         return _buildProjectSection();
//       default:
//         return MergedGraph(viewModel: viewModel);
//     }
//   }

//   Widget _buildProjectSection() {
//     return Consumer<ProjectViewModel>(
//       builder: (context, projectViewModel, child) {
//         final projects = projectViewModel.projects;

//         if (projects.isEmpty) {
//           return _buildProjectGraphPlaceholder();
//         }

//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Active Projects (${projects.length})',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: projects.length,
//                 itemBuilder: (context, index) {
//                   return _buildProjectCard(projects[index], projectViewModel);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProjectCard(Project project, ProjectViewModel viewModel) {
//     return Card(
//       elevation: 2,
//       color: Colors.white.withOpacity(0.05),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: InkWell(
//         onTap: () {
//           _navigateToProjectDetail(project);
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       project.name,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   _buildProjectStatusBadge(project.status, viewModel),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 project.description,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.white.withOpacity(0.7),
//                   height: 1.4,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 12),
//               // Progress Bar
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Progress',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.white.withOpacity(0.6),
//                         ),
//                       ),
//                       Text(
//                         '${project.progress.toStringAsFixed(1)}%',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   LinearProgressIndicator(
//                     value: project.progress / 100,
//                     backgroundColor: Colors.white.withOpacity(0.2),
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       _getProjectStatusColor(project.status),
//                     ),
//                     minHeight: 6,
//                     borderRadius: BorderRadius.circular(3),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               // Project Details
//               Row(
//                 children: [
//                   _buildProjectDetailItem(
//                     Icons.people_rounded,
//                     '${project.teamSize} members',
//                   ),
//                   const SizedBox(width: 12),
//                   _buildProjectDetailItem(
//                     Icons.assignment_rounded,
//                     '${project.completedTasks}/${project.totalTasks} tasks',
//                   ),
//                   const SizedBox(width: 12),
//                   _buildProjectDetailItem(
//                     Icons.calendar_today_rounded,
//                     '${project.daysRemaining} days left',
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProjectStatusBadge(String status, ProjectViewModel viewModel) {
//     final color = _getProjectStatusColor(status);
//     final text = status.toUpperCase();

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

//   Widget _buildProjectDetailItem(IconData icon, String text) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 14, color: Colors.white.withOpacity(0.6)),
//         const SizedBox(width: 4),
//         Text(
//           text,
//           style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6)),
//         ),
//       ],
//     );
//   }

//   Color _getProjectStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'active':
//         return Colors.green;
//       case 'completed':
//         return Colors.blue;
//       case 'planning':
//         return Colors.orange;
//       case 'on-hold':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   Widget _buildProjectGraphPlaceholder() {
//     return Container(
//       height: 400,
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.work_outline_rounded,
//             size: 64,
//             color: Colors.purple.shade400.withOpacity(0.7),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No Projects Found',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: Colors.white.withOpacity(0.9),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Create your first project to get started',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.white.withOpacity(0.6),
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   void _navigateToProjectDetail(Project project) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProjectDetailScreen(project: project),
//       ),
//     );
//   }

//   void _refreshData() {
//     final dashboardViewModel = Provider.of<ManagerDashboardViewModel>(
//       context,
//       listen: false,
//     );
//     final projectViewModel = Provider.of<ProjectViewModel>(
//       context,
//       listen: false,
//     );

//     final teamMembers = dashboardViewModel.dashboard?.teamMembers ?? [];
//     if (teamMembers.isNotEmpty) {
//       final analyticsViewModel = Provider.of<AttendanceAnalyticsViewModel>(
//         context,
//         listen: false,
//       );
//       analyticsViewModel.initializeAnalytics(teamMembers);
//     }

//     projectViewModel.loadProjects();
//   }

//   String _formatDate(DateTime date) {
//     return DateFormat('dd MMM yyyy').format(date);
//   }

//   String _formatMonth(DateTime date) {
//     return DateFormat('MMMM yyyy').format(date);
//   }

//   DateTime _getFirstDayOfWeek(DateTime date) {
//     return date.subtract(Duration(days: date.weekday - 1));
//   }

//   int _getWeekNumber(DateTime date) {
//     final firstDay = DateTime(date.year, 1, 1);
//     final daysDiff = date.difference(firstDay).inDays;
//     return ((daysDiff + firstDay.weekday) / 7).ceil();
//   }

//   bool _isSameWeek(DateTime a, DateTime b) {
//     final aStart = _getFirstDayOfWeek(a);
//     final bStart = _getFirstDayOfWeek(b);
//     return aStart.year == bStart.year &&
//         aStart.month == bStart.month &&
//         aStart.day == bStart.day;
//   }
// }

// import 'package:AttendanceApp/core/view_models/theme_view_model.dart';
// import 'package:AttendanceApp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:AttendanceApp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:AttendanceApp/widgets/analytics/graph_toggle.dart';
// import 'package:AttendanceApp/widgets/analytics/horizontalAttendanceStats.dart';
// import 'package:AttendanceApp/widgets/analytics/individual_graphs.dart';
// import 'package:AttendanceApp/widgets/analytics/merged_graph.dart';
// import 'package:AttendanceApp/widgets/analytics/period_selector.dart';
// import 'package:AttendanceApp/widgets/analytics/statistics_cards.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';

// class AttendanceDetailScreen extends StatefulWidget {
//   const AttendanceDetailScreen({super.key});

//   @override
//   _AttendanceDetailScreenState createState() => _AttendanceDetailScreenState();
// }

// class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
//   int _currentGraphView = 0; // 0 = Merged, 1 = Individual, 2 = Project

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnalytics();
//   }

//   void _initializeAnalytics() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final dashboardViewModel = Provider.of<ManagerDashboardViewModel>(
//         context,
//         listen: false,
//       );
//       final analyticsViewModel = Provider.of<AttendanceAnalyticsViewModel>(
//         context,
//         listen: false,
//       );

//       final teamMembers = dashboardViewModel.dashboard?.teamMembers ?? [];
//       analyticsViewModel.initializeAnalytics(teamMembers);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);
//     final viewModel = Provider.of<AttendanceAnalyticsViewModel>(context);

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: viewModel.isLoading
//           ? const Center(
//               child: CircularProgressIndicator(
//                 color: Colors.cyan,
//                 strokeWidth: 3,
//               ),
//             )
//           : _buildContent(viewModel),
//     );
//   }

//   Widget _buildContent(AttendanceAnalyticsViewModel viewModel) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           _buildHeader(),
//           const SizedBox(height: 20),
//           PeriodSelector(viewModel: viewModel),
//           const SizedBox(height: 20),
//           HorizontalAttendanceStats(
//             totalEmployees: 50,
//             presentCount: 35,
//             leaveCount: 5,
//             absentCount: 10,
//             onTimeCount: 30,
//             lateCount: 5,
//           ),
//           const SizedBox(height: 20),
//           GraphToggle(
//             viewModel: viewModel,
//             onViewChanged: (viewIndex) {
//               setState(() {
//                 _currentGraphView = viewIndex;
//               });
//             },
//           ),
//           const SizedBox(height: 20),
//           _buildGraphSection(viewModel),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       children: [
//         IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_rounded,
//             color: Colors.white,
//             size: 20,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         const SizedBox(width: 16),
//         const Expanded(
//           child: Text(
//             'Attendance Analytics',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//         ),
//         IconButton(
//           icon: const Icon(
//             Icons.refresh_rounded,
//             color: Colors.white,
//             size: 20,
//           ),
//           onPressed: _refreshData,
//         ),
//       ],
//     );
//   }

//   Widget _buildGraphSection(AttendanceAnalyticsViewModel viewModel) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.white.withOpacity(0.05),
//       ),
//       child: _buildCurrentGraph(viewModel),
//     );
//   }

//   Widget _buildCurrentGraph(AttendanceAnalyticsViewModel viewModel) {
//     switch (_currentGraphView) {
//       case 0:
//         return MergedGraph(viewModel: viewModel);
//       case 1:
//         return IndividualGraphs(viewModel: viewModel);
//       case 2:
//         return _buildProjectGraphPlaceholder();
//       default:
//         return MergedGraph(viewModel: viewModel);
//     }
//   }

//   Widget _buildProjectGraphPlaceholder() {
//     return Container(
//       height: 400,
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.pie_chart_rounded,
//             size: 64,
//             color: Colors.purple.shade400.withOpacity(0.7),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Project Analytics',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: Colors.white.withOpacity(0.9),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Project analytics will be displayed here',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.white.withOpacity(0.6),
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.purple.shade400.withOpacity(0.3),
//                   Colors.pink.shade400.withOpacity(0.2),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: Colors.purple.shade400.withOpacity(0.4),
//               ),
//             ),
//             child: Text(
//               'Coming Soon',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.purple.shade300,
//                 letterSpacing: 0.8,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _refreshData() {
//     final dashboardViewModel = Provider.of<ManagerDashboardViewModel>(
//       context,
//       listen: false,
//     );
//     final teamMembers = dashboardViewModel.dashboard?.teamMembers ?? [];
//     if (teamMembers.isNotEmpty) {
//       final analyticsViewModel = Provider.of<AttendanceAnalyticsViewModel>(
//         context,
//         listen: false,
//       );
//       analyticsViewModel.initializeAnalytics(teamMembers);
//     }
//   }

//   // Keep all your existing date formatting and utility methods
//   String _formatDate(DateTime date) {
//     return DateFormat('dd MMM yyyy').format(date);
//   }

//   String _formatMonth(DateTime date) {
//     return DateFormat('MMMM yyyy').format(date);
//   }

//   DateTime _getFirstDayOfWeek(DateTime date) {
//     return date.subtract(Duration(days: date.weekday - 1));
//   }

//   int _getWeekNumber(DateTime date) {
//     final firstDay = DateTime(date.year, 1, 1);
//     final daysDiff = date.difference(firstDay).inDays;
//     return ((daysDiff + firstDay.weekday) / 7).ceil();
//   }

//   bool _isSameWeek(DateTime a, DateTime b) {
//     final aStart = _getFirstDayOfWeek(a);
//     final bStart = _getFirstDayOfWeek(b);
//     return aStart.year == bStart.year &&
//         aStart.month == bStart.month &&
//         aStart.day == bStart.day;
//   }
// }

// import 'package:AttendanceApp/core/view_models/theme_view_model.dart';
// import 'package:AttendanceApp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:AttendanceApp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:AttendanceApp/widgets/analytics/graph_toggle.dart';
// import 'package:AttendanceApp/widgets/analytics/horizontalAttendanceStats.dart';
// import 'package:AttendanceApp/widgets/analytics/individual_graphs.dart';
// import 'package:AttendanceApp/widgets/analytics/merged_graph.dart';
// import 'package:AttendanceApp/widgets/analytics/period_selector.dart';
// import 'package:AttendanceApp/widgets/analytics/statistics_cards.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';

// class AttendanceDetailScreen extends StatefulWidget {
//   const AttendanceDetailScreen({super.key});

//   @override
//   _AttendanceDetailScreenState createState() => _AttendanceDetailScreenState();
// }

// class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _initializeAnalytics();
//   }

//   void _initializeAnalytics() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final dashboardViewModel = Provider.of<ManagerDashboardViewModel>(
//         context,
//         listen: false,
//       );
//       final analyticsViewModel = Provider.of<AttendanceAnalyticsViewModel>(
//         context,
//         listen: false,
//       );

//       final teamMembers = dashboardViewModel.dashboard?.teamMembers ?? [];
//       analyticsViewModel.initializeAnalytics(teamMembers);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);
//     final viewModel = Provider.of<AttendanceAnalyticsViewModel>(context);

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: viewModel.isLoading
//           ? const Center(
//               child: CircularProgressIndicator(
//                 color: Colors.cyan,
//                 strokeWidth: 3,
//               ),
//             )
//           : _buildContent(viewModel),
//     );
//   }

//   Widget _buildContent(AttendanceAnalyticsViewModel viewModel) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           _buildHeader(),
//           const SizedBox(height: 20),
//           PeriodSelector(viewModel: viewModel),
//           const SizedBox(height: 20),
//           HorizontalAttendanceStats(
//             totalEmployees: 50,
//             presentCount: 35,
//             leaveCount: 5,
//             absentCount: 10,
//             onTimeCount: 30,
//             lateCount: 5,
//           ),
//           const SizedBox(height: 20),
//           GraphToggle(viewModel: viewModel),
//           const SizedBox(height: 20),
//           _buildGraphSection(viewModel),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       children: [
//         IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_rounded,
//             color: Colors.white,
//             size: 20,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         const SizedBox(width: 16),
//         const Expanded(
//           child: Text(
//             'Attendance Matrix',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//         ),
//         IconButton(
//           icon: const Icon(
//             Icons.refresh_rounded,
//             color: Colors.white,
//             size: 20,
//           ),
//           onPressed: _refreshData,
//         ),
//       ],
//     );
//   }

//   Widget _buildGraphSection(AttendanceAnalyticsViewModel viewModel) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.white.withOpacity(0.05),
//       ),
//       child: viewModel.showIndividualGraphs
//           ? IndividualGraphs(viewModel: viewModel)
//           : MergedGraph(viewModel: viewModel),
//     );
//   }

//   void _refreshData() {
//     final dashboardViewModel = Provider.of<ManagerDashboardViewModel>(
//       context,
//       listen: false,
//     );
//     final teamMembers = dashboardViewModel.dashboard?.teamMembers ?? [];
//     if (teamMembers.isNotEmpty) {
//       final analyticsViewModel = Provider.of<AttendanceAnalyticsViewModel>(
//         context,
//         listen: false,
//       );
//       analyticsViewModel.initializeAnalytics(teamMembers);
//     }
//   }

//   // Keep all your existing date formatting and utility methods
//   String _formatDate(DateTime date) {
//     return DateFormat('dd MMM yyyy').format(date);
//   }

//   String _formatMonth(DateTime date) {
//     return DateFormat('MMMM yyyy').format(date);
//   }

//   DateTime _getFirstDayOfWeek(DateTime date) {
//     return date.subtract(Duration(days: date.weekday - 1));
//   }

//   int _getWeekNumber(DateTime date) {
//     final firstDay = DateTime(date.year, 1, 1);
//     final daysDiff = date.difference(firstDay).inDays;
//     return ((daysDiff + firstDay.weekday) / 7).ceil();
//   }

//   bool _isSameWeek(DateTime a, DateTime b) {
//     final aStart = _getFirstDayOfWeek(a);
//     final bStart = _getFirstDayOfWeek(b);
//     return aStart.year == bStart.year &&
//         aStart.month == bStart.month &&
//         aStart.day == bStart.day;
//   }
// }

// import 'package:AttendanceApp/core/view_models/theme_view_model.dart';
// import 'package:AttendanceApp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:AttendanceApp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:AttendanceApp/widgets/analytics/graph_toggle.dart';
// import 'package:AttendanceApp/widgets/analytics/horizontalAttendanceStats.dart';
// import 'package:AttendanceApp/widgets/analytics/individual_graphs.dart';
// import 'package:AttendanceApp/widgets/analytics/merged_graph.dart';
// import 'package:AttendanceApp/widgets/analytics/period_selector.dart';
// import 'package:AttendanceApp/widgets/analytics/statistics_cards.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';

// class AttendanceDetailScreen extends StatefulWidget {
//   const AttendanceDetailScreen({super.key});

//   @override
//   _AttendanceDetailScreenState createState() => _AttendanceDetailScreenState();
// }

// class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _initializeAnalytics();
//   }

//   void _initializeAnalytics() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final dashboardViewModel = Provider.of<ManagerDashboardViewModel>(
//         context,
//         listen: false,
//       );
//       final analyticsViewModel = Provider.of<AttendanceAnalyticsViewModel>(
//         context,
//         listen: false,
//       );

//       final teamMembers = dashboardViewModel.dashboard?.teamMembers ?? [];
//       analyticsViewModel.initializeAnalytics(teamMembers);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);
//     final viewModel = Provider.of<AttendanceAnalyticsViewModel>(context);

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: RadialGradient(
//             center: Alignment.topLeft,
//             radius: 2.0,
//             colors: [
//               Colors.blue.shade900.withOpacity(0.3),
//               Colors.purple.shade800.withOpacity(0.2),
//               Colors.black,
//             ],
//             stops: const [0.0, 0.5, 1.0],
//           ),
//         ),
//         child: viewModel.isLoading
//             ? const Center(
//                 child: CircularProgressIndicator(
//                   color: Colors.cyan,
//                   strokeWidth: 3,
//                 ),
//               )
//             : _buildQuantumContent(viewModel),
//       ),
//     );
//   }

//   // Widget _buildQuantumContent(AttendanceAnalyticsViewModel viewModel) {
//   //   return SingleChildScrollView(
//   //     padding: const EdgeInsets.all(16),
//   //     child: Column(
//   //       children: [
//   //         // Quantum Header
//   //         _buildQuantumHeader(),
//   //         const SizedBox(height: 20),

//   //         // Period Selector with Calendar Integration
//   //         Container(
//   //           decoration: BoxDecoration(
//   //             borderRadius: BorderRadius.circular(20),
//   //             gradient: LinearGradient(
//   //               begin: Alignment.topLeft,
//   //               end: Alignment.bottomRight,
//   //               colors: [
//   //                 Colors.blue.shade900.withOpacity(0.8),
//   //                 Colors.purple.shade800.withOpacity(0.7),
//   //               ],
//   //             ),
//   //             boxShadow: [
//   //               BoxShadow(
//   //                 color: Colors.blue.shade700.withOpacity(0.4),
//   //                 blurRadius: 20,
//   //                 offset: const Offset(0, 8),
//   //               ),
//   //             ],
//   //             border: Border.all(
//   //               color: Colors.white.withOpacity(0.2),
//   //               width: 1.5,
//   //             ),
//   //           ),
//   //           child: ClipRRect(
//   //             borderRadius: BorderRadius.circular(20),
//   //             child: PeriodSelector(viewModel: viewModel),
//   //           ),
//   //         ),
//   //         const SizedBox(height: 20),

//   //         // Statistics Cards
//   //         StatisticsCards(viewModel: viewModel),
//   //         const SizedBox(height: 24),

//   //         // Graph Toggle (Individual vs Team View)
//   //         Container(
//   //           // decoration: BoxDecoration(
//   //           //   borderRadius: BorderRadius.circular(16),
//   //           //   gradient: LinearGradient(
//   //           //     begin: Alignment.topLeft,
//   //           //     end: Alignment.bottomRight,
//   //           //     colors: [
//   //           //       Colors.white.withOpacity(0.15),
//   //           //       Colors.white.withOpacity(0.05),
//   //           //     ],
//   //           //   ),
//   //           //   border: Border.all(
//   //           //     color: Colors.white.withOpacity(0.2),
//   //           //     width: 1.5,
//   //           //   ),
//   //           // ),
//   //           child: ClipRRect(
//   //             borderRadius: BorderRadius.circular(16),
//   //             child: GraphToggle(viewModel: viewModel),
//   //           ),
//   //         ),
//   //         const SizedBox(height: 20),

//   //         // Graph Section (changes based on toggle)
//   //         _buildQuantumGraphSection(viewModel),

//   //         // Quantum Date Info Banner
//   //         //_buildQuantumDateInfoBanner(viewModel),
//   //       ],
//   //     ),
//   //   );
//   // }

//   Widget _buildQuantumContent(AttendanceAnalyticsViewModel viewModel) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Quantum Header
//           _buildQuantumHeader(),
//           const SizedBox(height: 20),

//           // Period Selector with Calendar Integration
//           Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.blue.shade900.withOpacity(0.8),
//                   Colors.purple.shade800.withOpacity(0.7),
//                 ],
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.blue.shade700.withOpacity(0.4),
//                   blurRadius: 20,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.2),
//                 width: 1.5,
//               ),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: PeriodSelector(viewModel: viewModel),
//             ),
//           ),
//           const SizedBox(height: 20),

//           // Statistics Cards
//           // StatisticsCards(viewModel: viewModel),
//           // const SizedBox(height: 20),

//           // ✅ YAHAN ADD KAREN HorizontalAttendanceStats
//           HorizontalAttendanceStats(
//             totalEmployees: 50, // Apne data ke according change karen
//             presentCount: 35,
//             leaveCount: 5,
//             absentCount: 10,
//             onTimeCount: 30,
//             lateCount: 5,
//           ),
//           const SizedBox(height: 20),

//           // Graph Toggle (Individual vs Team View)
//           Container(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: GraphToggle(viewModel: viewModel),
//             ),
//           ),
//           const SizedBox(height: 20),

//           // Graph Section (changes based on toggle)
//           _buildQuantumGraphSection(viewModel),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuantumHeader() {
//     return Container(
//       // padding: const EdgeInsets.all(20),
//       // decoration: BoxDecoration(
//       //   borderRadius: BorderRadius.circular(20),
//       //   gradient: LinearGradient(
//       //     begin: Alignment.topLeft,
//       //     end: Alignment.bottomRight,
//       //     colors: [
//       //       Colors.blue.shade900.withOpacity(0.9),
//       //       Colors.purple.shade800.withOpacity(0.8),
//       //     ],
//       //   ),
//       // boxShadow: [
//       //   BoxShadow(
//       //     color: Colors.blue.shade700.withOpacity(0.4),
//       //     blurRadius: 25,
//       //     offset: const Offset(0, 10),
//       //   ),
//       // ],
//       // border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//       // ),
//       child: Row(
//         children: [
//           // Back Button
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 1.5,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: IconButton(
//               icon: Icon(
//                 Icons.arrow_back_ios_rounded,
//                 color: Colors.white,
//                 size: 20,
//               ),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//           const SizedBox(width: 16),

//           // Title
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Text(
//                 //   'QUANTUM ANALYTICS',
//                 //   style: TextStyle(
//                 //     color: Colors.white.withOpacity(0.9),
//                 //     fontSize: 14,
//                 //     fontWeight: FontWeight.w800,
//                 //     letterSpacing: 1.5,
//                 //   ),
//                 // ),
//                 // const SizedBox(height: 4),
//                 Text(
//                   'Attendance Matrix',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: 0.8,
//                   ),
//                   //textAlign: Center,
//                 ),
//               ],
//             ),
//           ),

//           // Refresh Button
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 1.5,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: IconButton(
//               icon: Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
//               onPressed: () {
//                 final dashboardViewModel =
//                     Provider.of<ManagerDashboardViewModel>(
//                       context,
//                       listen: false,
//                     );
//                 final teamMembers =
//                     dashboardViewModel.dashboard?.teamMembers ?? [];
//                 if (teamMembers.isNotEmpty) {
//                   final analyticsViewModel =
//                       Provider.of<AttendanceAnalyticsViewModel>(
//                         context,
//                         listen: false,
//                       );
//                   analyticsViewModel.initializeAnalytics(teamMembers);
//                 }
//               },
//               tooltip: 'Refresh Analytics',
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuantumGraphSection(AttendanceAnalyticsViewModel viewModel) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.white.withOpacity(0.15),
//             Colors.white.withOpacity(0.05),
//           ],
//         ),
//         border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 15,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: viewModel.showIndividualGraphs
//             ? IndividualGraphs(viewModel: viewModel)
//             : MergedGraph(viewModel: viewModel),
//       ),
//     );
//   }

//   Widget _buildQuantumDateInfoBanner(AttendanceAnalyticsViewModel viewModel) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(top: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.cyan.shade400.withOpacity(0.2),
//             Colors.blue.shade400.withOpacity(0.1),
//           ],
//         ),
//         border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.cyan.shade400.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 1.5,
//               ),
//             ),
//             child: Icon(
//               Icons.calendar_today_rounded,
//               size: 18,
//               color: Colors.cyan.shade300,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               _getQuantumDateRangeInfo(viewModel),
//               style: TextStyle(
//                 fontSize: 13,
//                 color: Colors.white.withOpacity(0.9),
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: () => _showQuickDateSelector(context, viewModel),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Colors.cyan.shade400.withOpacity(0.3),
//                     Colors.blue.shade400.withOpacity(0.2),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.3),
//                   width: 1.5,
//                 ),
//               ),
//               child: Text(
//                 'TIME TRAVEL',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: 0.8,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getQuantumDateRangeInfo(AttendanceAnalyticsViewModel viewModel) {
//     final selectedDate = viewModel.selectedDate;
//     final period = viewModel.selectedPeriod;

//     switch (period) {
//       case 'daily':
//         return 'TIME-SPACE CONTINUUM: ${_formatDate(selectedDate)}';
//       case 'weekly':
//         final weekStart = _getFirstDayOfWeek(selectedDate);
//         final weekEnd = weekStart.add(const Duration(days: 6));
//         return 'WEEK ${_getWeekNumber(selectedDate)} MATRIX: ${_formatDate(weekStart)} - ${_formatDate(weekEnd)}';
//       case 'monthly':
//         return 'MONTHLY QUANTUM DATA: ${_formatMonth(selectedDate)}';
//       case 'quarterly':
//         final quarter = ((selectedDate.month - 1) ~/ 3) + 1;
//         return 'QUARTERLY ANALYSIS: Q$quarter ${selectedDate.year}';
//       default:
//         return 'QUANTUM ATTENDANCE MATRIX';
//     }
//   }

//   String _formatDate(DateTime date) {
//     return DateFormat('dd MMM yyyy').format(date);
//   }

//   String _formatMonth(DateTime date) {
//     return DateFormat('MMMM yyyy').format(date);
//   }

//   DateTime _getFirstDayOfWeek(DateTime date) {
//     return date.subtract(Duration(days: date.weekday - 1));
//   }

//   int _getWeekNumber(DateTime date) {
//     final firstDay = DateTime(date.year, 1, 1);
//     final daysDiff = date.difference(firstDay).inDays;
//     return ((daysDiff + firstDay.weekday) / 7).ceil();
//   }

//   void _showQuickDateSelector(
//     BuildContext context,
//     AttendanceAnalyticsViewModel viewModel,
//   ) {
//     final period = viewModel.selectedPeriod;

//     switch (period) {
//       case 'daily':
//         _showQuantumDatePicker(context, viewModel);
//         break;
//       case 'weekly':
//         _showQuantumWeekPicker(context, viewModel);
//         break;
//       case 'monthly':
//         _showQuantumMonthPicker(context, viewModel);
//         break;
//       case 'quarterly':
//         _showQuantumQuarterPicker(context, viewModel);
//         break;
//     }
//   }

//   void _showQuantumDatePicker(
//     BuildContext context,
//     AttendanceAnalyticsViewModel viewModel,
//   ) {
//     showDatePicker(
//       context: context,
//       initialDate: viewModel.selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.dark(
//               primary: Colors.cyan.shade400,
//               onPrimary: Colors.black,
//               surface: Colors.grey.shade900,
//               onSurface: Colors.white,
//             ),
//             dialogBackgroundColor: Colors.grey.shade900,
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: Colors.cyan.shade400,
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     ).then((selectedDate) {
//       if (selectedDate != null) {
//         viewModel.changePeriod('daily', selectedDate: selectedDate);
//       }
//     });
//   }

//   void _showQuantumWeekPicker(
//     BuildContext context,
//     AttendanceAnalyticsViewModel viewModel,
//   ) {
//     final now = viewModel.selectedDate;
//     final firstDayOfWeek = _getFirstDayOfWeek(now);

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.6,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.blue.shade900.withOpacity(0.95),
//               Colors.purple.shade800.withOpacity(0.9),
//             ],
//           ),
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'SELECT TIME PERIOD',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.3),
//                         width: 1.5,
//                       ),
//                     ),
//                     child: IconButton(
//                       icon: Icon(
//                         Icons.close_rounded,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: 52,
//                 itemBuilder: (context, index) {
//                   final weekStart = firstDayOfWeek.add(
//                     Duration(days: index * 7),
//                   );
//                   final weekEnd = weekStart.add(const Duration(days: 6));
//                   final isCurrentWeek = _isSameWeek(weekStart, now);

//                   return Container(
//                     margin: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       gradient: isCurrentWeek
//                           ? LinearGradient(
//                               colors: [
//                                 Colors.cyan.shade400.withOpacity(0.3),
//                                 Colors.blue.shade400.withOpacity(0.2),
//                               ],
//                             )
//                           : LinearGradient(
//                               colors: [
//                                 Colors.white.withOpacity(0.1),
//                                 Colors.white.withOpacity(0.05),
//                               ],
//                             ),
//                       border: Border.all(
//                         color: isCurrentWeek
//                             ? Colors.cyan.shade400.withOpacity(0.4)
//                             : Colors.white.withOpacity(0.2),
//                         width: 1.5,
//                       ),
//                     ),
//                     child: ListTile(
//                       leading: Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: isCurrentWeek
//                               ? Colors.cyan.shade400.withOpacity(0.2)
//                               : Colors.transparent,
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: isCurrentWeek
//                                 ? Colors.cyan.shade400
//                                 : Colors.transparent,
//                           ),
//                         ),
//                         child: Center(
//                           child: Text(
//                             '${index + 1}',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w800,
//                               color: isCurrentWeek
//                                   ? Colors.cyan.shade400
//                                   : Colors.white.withOpacity(0.7),
//                             ),
//                           ),
//                         ),
//                       ),
//                       title: Text(
//                         'WEEK ${index + 1}',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       subtitle: Text(
//                         '${_formatDate(weekStart)} - ${_formatDate(weekEnd)}',
//                         style: TextStyle(color: Colors.white.withOpacity(0.7)),
//                       ),
//                       trailing: isCurrentWeek
//                           ? Icon(
//                               Icons.check_circle_rounded,
//                               color: Colors.cyan.shade400,
//                             )
//                           : null,
//                       onTap: () {
//                         viewModel.changePeriod(
//                           'weekly',
//                           selectedDate: weekStart,
//                         );
//                         Navigator.pop(context);
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showQuantumMonthPicker(
//     BuildContext context,
//     AttendanceAnalyticsViewModel viewModel,
//   ) {
//     final now = viewModel.selectedDate;
//     final currentYear = now.year;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: 400,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.blue.shade900.withOpacity(0.95),
//               Colors.purple.shade800.withOpacity(0.9),
//             ],
//           ),
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           children: [
//             // Quantum Header
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'SELECT YEAR',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.3),
//                         width: 1.5,
//                       ),
//                     ),
//                     child: IconButton(
//                       icon: Icon(
//                         Icons.close_rounded,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Custom Year List
//             Expanded(
//               child: ListView.builder(
//                 itemCount: 11, // 2020 to 2030
//                 itemBuilder: (context, index) {
//                   final year = 2020 + index;
//                   final isSelected = year == currentYear;

//                   return Container(
//                     margin: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       gradient: isSelected
//                           ? LinearGradient(
//                               colors: [
//                                 Colors.cyan.shade400.withOpacity(0.3),
//                                 Colors.blue.shade400.withOpacity(0.2),
//                               ],
//                             )
//                           : LinearGradient(
//                               colors: [
//                                 Colors.white.withOpacity(0.1),
//                                 Colors.white.withOpacity(0.05),
//                               ],
//                             ),
//                       border: Border.all(
//                         color: isSelected
//                             ? Colors.cyan.shade400.withOpacity(0.4)
//                             : Colors.white.withOpacity(0.2),
//                         width: 1.5,
//                       ),
//                     ),
//                     child: ListTile(
//                       leading: Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? Colors.cyan.shade400.withOpacity(0.2)
//                               : Colors.transparent,
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: isSelected
//                                 ? Colors.cyan.shade400
//                                 : Colors.transparent,
//                           ),
//                         ),
//                         child: Center(
//                           child: Text(
//                             '${year.toString().substring(2)}',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w800,
//                               color: isSelected
//                                   ? Colors.cyan.shade400
//                                   : Colors.white.withOpacity(0.7),
//                             ),
//                           ),
//                         ),
//                       ),
//                       title: Text(
//                         'YEAR $year',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       subtitle: Text(
//                         'Complete annual data',
//                         style: TextStyle(color: Colors.white.withOpacity(0.7)),
//                       ),
//                       trailing: isSelected
//                           ? Icon(
//                               Icons.check_circle_rounded,
//                               color: Colors.cyan.shade400,
//                             )
//                           : null,
//                       onTap: () {
//                         final selectedDate = DateTime(year, now.month);
//                         viewModel.changePeriod(
//                           'monthly',
//                           selectedDate: selectedDate,
//                         );
//                         Navigator.pop(context);
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showQuantumQuarterPicker(
//     BuildContext context,
//     AttendanceAnalyticsViewModel viewModel,
//   ) {
//     final now = viewModel.selectedDate;
//     final currentQuarter = ((now.month - 1) ~/ 3) + 1;
//     final currentYear = now.year;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: 300,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.blue.shade900.withOpacity(0.95),
//               Colors.purple.shade800.withOpacity(0.9),
//             ],
//           ),
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'SELECT QUARTER',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.3),
//                         width: 1.5,
//                       ),
//                     ),
//                     child: IconButton(
//                       icon: Icon(
//                         Icons.close_rounded,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: ListView(
//                 children: [
//                   _buildQuantumQuarterOption(
//                     context,
//                     1,
//                     'Q1 (Jan - Mar)',
//                     currentQuarter,
//                     currentYear,
//                     viewModel,
//                   ),
//                   _buildQuantumQuarterOption(
//                     context,
//                     2,
//                     'Q2 (Apr - Jun)',
//                     currentQuarter,
//                     currentYear,
//                     viewModel,
//                   ),
//                   _buildQuantumQuarterOption(
//                     context,
//                     3,
//                     'Q3 (Jul - Sep)',
//                     currentQuarter,
//                     currentYear,
//                     viewModel,
//                   ),
//                   _buildQuantumQuarterOption(
//                     context,
//                     4,
//                     'Q4 (Oct - Dec)',
//                     currentQuarter,
//                     currentYear,
//                     viewModel,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuantumQuarterOption(
//     BuildContext context,
//     int quarter,
//     String label,
//     int currentQuarter,
//     int year,
//     AttendanceAnalyticsViewModel viewModel,
//   ) {
//     final isSelected = currentQuarter == quarter;

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         gradient: isSelected
//             ? LinearGradient(
//                 colors: [
//                   Colors.cyan.shade400.withOpacity(0.3),
//                   Colors.blue.shade400.withOpacity(0.2),
//                 ],
//               )
//             : LinearGradient(
//                 colors: [
//                   Colors.white.withOpacity(0.1),
//                   Colors.white.withOpacity(0.05),
//                 ],
//               ),
//         border: Border.all(
//           color: isSelected
//               ? Colors.cyan.shade400.withOpacity(0.4)
//               : Colors.white.withOpacity(0.2),
//           width: 1.5,
//         ),
//       ),
//       child: ListTile(
//         leading: Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? Colors.cyan.shade400.withOpacity(0.2)
//                 : Colors.transparent,
//             shape: BoxShape.circle,
//             border: Border.all(
//               color: isSelected ? Colors.cyan.shade400 : Colors.transparent,
//             ),
//           ),
//           child: Center(
//             child: Text(
//               'Q$quarter',
//               style: TextStyle(
//                 fontWeight: FontWeight.w800,
//                 color: isSelected
//                     ? Colors.cyan.shade400
//                     : Colors.white.withOpacity(0.7),
//               ),
//             ),
//           ),
//         ),
//         title: Text(
//           label,
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//         ),
//         subtitle: Text(
//           '$year',
//           style: TextStyle(color: Colors.white.withOpacity(0.7)),
//         ),
//         trailing: isSelected
//             ? Icon(Icons.check_circle_rounded, color: Colors.cyan.shade400)
//             : null,
//         onTap: () {
//           final quarterMonth = (quarter - 1) * 3 + 1;
//           final selectedDate = DateTime(year, quarterMonth);
//           viewModel.changePeriod('quarterly', selectedDate: selectedDate);
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }

//   bool _isSameWeek(DateTime a, DateTime b) {
//     final aStart = _getFirstDayOfWeek(a);
//     final bStart = _getFirstDayOfWeek(b);
//     return aStart.year == bStart.year &&
//         aStart.month == bStart.month &&
//         aStart.day == bStart.day;
//   }
// }

// import 'package:AttendanceApp/core/view_models/theme_view_model.dart';
// import 'package:AttendanceApp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:AttendanceApp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:AttendanceApp/widgets/analytics/graph_toggle.dart';
// import 'package:AttendanceApp/widgets/analytics/individual_graphs.dart';
// import 'package:AttendanceApp/widgets/analytics/merged_graph.dart';
// import 'package:AttendanceApp/widgets/analytics/period_selector.dart';
// import 'package:AttendanceApp/widgets/analytics/statistics_cards.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';

// class AttendanceDetailScreen extends StatefulWidget {
//   const AttendanceDetailScreen({super.key});

//   @override
//   _AttendanceDetailScreenState createState() => _AttendanceDetailScreenState();
// }

// class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _initializeAnalytics();
//   }

//   void _initializeAnalytics() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final dashboardViewModel = Provider.of<ManagerDashboardViewModel>(
//         context,
//         listen: false,
//       );
//       final analyticsViewModel = Provider.of<AttendanceAnalyticsViewModel>(
//         context,
//         listen: false,
//       );

//       final teamMembers = dashboardViewModel.dashboard?.teamMembers ?? [];
//       analyticsViewModel.initializeAnalytics(teamMembers);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);
//     final viewModel = Provider.of<AttendanceAnalyticsViewModel>(context);

//     return Scaffold(
//       backgroundColor: theme.themeMode == ThemeMode.dark
//           ? AppColors.backgroundDark
//           : AppColors.backgroundLight,
//       appBar: AppBar(
//         title: const Text('Attendance Analytics'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_rounded),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           // Add refresh button
//           IconButton(
//             icon: const Icon(Icons.refresh_rounded),
//             onPressed: () {
//               final dashboardViewModel = Provider.of<ManagerDashboardViewModel>(
//                 context,
//                 listen: false,
//               );
//               final teamMembers =
//                   dashboardViewModel.dashboard?.teamMembers ?? [];
//               if (teamMembers.isNotEmpty) {
//                 viewModel.initializeAnalytics(teamMembers);
//               }
//             },
//             tooltip: 'Refresh Analytics',
//           ),
//         ],
//       ),
//       body: viewModel.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _buildContent(viewModel),
//     );
//   }

//   Widget _buildContent(AttendanceAnalyticsViewModel viewModel) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Period Selector with Calendar Integration
//           PeriodSelector(viewModel: viewModel),
//           const SizedBox(height: 16),

//           // Graph Toggle (Individual vs Team View)
//           GraphToggle(viewModel: viewModel),
//           const SizedBox(height: 20),

//           // Statistics Cards
//           StatisticsCards(viewModel: viewModel),
//           const SizedBox(height: 24),

//           // Graph Section (changes based on toggle)
//           _buildGraphSection(viewModel),

//           // Date Info Banner
//           _buildDateInfoBanner(viewModel),
//         ],
//       ),
//     );
//   }

//   Widget _buildGraphSection(AttendanceAnalyticsViewModel viewModel) {
//     return viewModel.showIndividualGraphs
//         ? IndividualGraphs(viewModel: viewModel)
//         : MergedGraph(viewModel: viewModel);
//   }

//   Widget _buildDateInfoBanner(AttendanceAnalyticsViewModel viewModel) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(top: 16),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: AppColors.primary.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.primary.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             Icons.calendar_today_rounded,
//             size: 16,
//             color: AppColors.primary,
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               _getDateRangeInfo(viewModel),
//               style: TextStyle(
//                 fontSize: 12,
//                 color: AppColors.textSecondary,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: () => _showQuickDateSelector(context, viewModel),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 'Change',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: AppColors.primary,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getDateRangeInfo(AttendanceAnalyticsViewModel viewModel) {
//     final selectedDate = viewModel.selectedDate;
//     final period = viewModel.selectedPeriod;

//     switch (period) {
//       case 'daily':
//         return 'Viewing data for ${_formatDate(selectedDate)}';
//       case 'weekly':
//         final weekStart = _getFirstDayOfWeek(selectedDate);
//         final weekEnd = weekStart.add(const Duration(days: 6));
//         return 'Week ${_getWeekNumber(selectedDate)}: ${_formatDate(weekStart)} - ${_formatDate(weekEnd)}';
//       case 'monthly':
//         return 'Viewing ${_formatMonth(selectedDate)}';
//       case 'quarterly':
//         final quarter = ((selectedDate.month - 1) ~/ 3) + 1;
//         return 'Viewing Q$quarter ${selectedDate.year}';
//       default:
//         return 'Viewing attendance data';
//     }
//   }

//   String _formatDate(DateTime date) {
//     return DateFormat('dd MMM yyyy').format(date);
//   }

//   String _formatMonth(DateTime date) {
//     return DateFormat('MMMM yyyy').format(date);
//   }

//   DateTime _getFirstDayOfWeek(DateTime date) {
//     return date.subtract(Duration(days: date.weekday - 1));
//   }

//   int _getWeekNumber(DateTime date) {
//     final firstDay = DateTime(date.year, 1, 1);
//     final daysDiff = date.difference(firstDay).inDays;
//     return ((daysDiff + firstDay.weekday) / 7).ceil();
//   }

//   void _showQuickDateSelector(
//     BuildContext context,
//     AttendanceAnalyticsViewModel viewModel,
//   ) {
//     final period = viewModel.selectedPeriod;

//     switch (period) {
//       case 'daily':
//         _showQuickDatePicker(context, viewModel);
//         break;
//       case 'weekly':
//         _showQuickWeekPicker(context, viewModel);
//         break;
//       case 'monthly':
//         _showQuickMonthPicker(context, viewModel);
//         break;
//       case 'quarterly':
//         _showQuickQuarterPicker(context, viewModel);
//         break;
//     }
//   }

//   void _showQuickDatePicker(
//     BuildContext context,
//     AttendanceAnalyticsViewModel viewModel,
//   ) {
//     showDatePicker(
//       context: context,
//       initialDate: viewModel.selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: AppColors.primary,
//               onPrimary: Colors.white,
//               onSurface: AppColors.textPrimary,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(foregroundColor: AppColors.primary),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     ).then((selectedDate) {
//       if (selectedDate != null) {
//         viewModel.changePeriod('daily', selectedDate: selectedDate);
//       }
//     });
//   }

//   void _showQuickWeekPicker(
//     BuildContext context,
//     AttendanceAnalyticsViewModel viewModel,
//   ) {
//     final now = viewModel.selectedDate;
//     final firstDayOfWeek = _getFirstDayOfWeek(now);

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.6,
//         decoration: BoxDecoration(
//           color: Theme.of(context).canvasColor,
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(16),
//             topRight: Radius.circular(16),
//           ),
//         ),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Select Week',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close_rounded),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: 52,
//                 itemBuilder: (context, index) {
//                   final weekStart = firstDayOfWeek.add(
//                     Duration(days: index * 7),
//                   );
//                   final weekEnd = weekStart.add(const Duration(days: 6));
//                   final isCurrentWeek = _isSameWeek(weekStart, now);

//                   return ListTile(
//                     leading: Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: isCurrentWeek
//                             ? AppColors.primary.withOpacity(0.1)
//                             : Colors.transparent,
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: isCurrentWeek
//                               ? AppColors.primary
//                               : Colors.transparent,
//                         ),
//                       ),
//                       child: Center(
//                         child: Text(
//                           '${index + 1}',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             color: isCurrentWeek
//                                 ? AppColors.primary
//                                 : AppColors.textSecondary,
//                           ),
//                         ),
//                       ),
//                     ),
//                     title: Text('Week ${index + 1}'),
//                     subtitle: Text(
//                       '${_formatDate(weekStart)} - ${_formatDate(weekEnd)}',
//                     ),
//                     trailing: isCurrentWeek
//                         ? Icon(
//                             Icons.check_circle_rounded,
//                             color: AppColors.primary,
//                           )
//                         : null,
//                     onTap: () {
//                       viewModel.changePeriod('weekly', selectedDate: weekStart);
//                       Navigator.pop(context);
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showQuickMonthPicker(
//     BuildContext context,
//     AttendanceAnalyticsViewModel viewModel,
//   ) {
//     final now = viewModel.selectedDate;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: 400,
//         decoration: BoxDecoration(
//           color: Theme.of(context).canvasColor,
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(16),
//             topRight: Radius.circular(16),
//           ),
//         ),
//         child: YearPicker(
//           firstDate: DateTime(2020),
//           lastDate: DateTime(2030),
//           selectedDate: DateTime(now.year, now.month),
//           onChanged: (DateTime dateTime) {
//             viewModel.changePeriod('monthly', selectedDate: dateTime);
//             Navigator.pop(context);
//           },
//         ),
//       ),
//     );
//   }

//   void _showQuickQuarterPicker(
//     BuildContext context,
//     AttendanceAnalyticsViewModel viewModel,
//   ) {
//     final now = viewModel.selectedDate;
//     final currentQuarter = ((now.month - 1) ~/ 3) + 1;
//     final currentYear = now.year;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: 300,
//         decoration: BoxDecoration(
//           color: Theme.of(context).canvasColor,
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(16),
//             topRight: Radius.circular(16),
//           ),
//         ),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Select Quarter',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close_rounded),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: ListView(
//                 children: [
//                   _buildQuarterOption(
//                     context,
//                     1,
//                     'Q1 (Jan - Mar)',
//                     currentQuarter,
//                     currentYear,
//                     viewModel,
//                   ),
//                   _buildQuarterOption(
//                     context,
//                     2,
//                     'Q2 (Apr - Jun)',
//                     currentQuarter,
//                     currentYear,
//                     viewModel,
//                   ),
//                   _buildQuarterOption(
//                     context,
//                     3,
//                     'Q3 (Jul - Sep)',
//                     currentQuarter,
//                     currentYear,
//                     viewModel,
//                   ),
//                   _buildQuarterOption(
//                     context,
//                     4,
//                     'Q4 (Oct - Dec)',
//                     currentQuarter,
//                     currentYear,
//                     viewModel,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuarterOption(
//     BuildContext context,
//     int quarter,
//     String label,
//     int currentQuarter,
//     int year,
//     AttendanceAnalyticsViewModel viewModel,
//   ) {
//     final isSelected = currentQuarter == quarter;

//     return ListTile(
//       leading: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: isSelected
//               ? AppColors.primary.withOpacity(0.1)
//               : Colors.transparent,
//           shape: BoxShape.circle,
//           border: Border.all(
//             color: isSelected ? AppColors.primary : Colors.transparent,
//           ),
//         ),
//         child: Center(
//           child: Text(
//             'Q$quarter',
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               color: isSelected ? AppColors.primary : AppColors.textSecondary,
//             ),
//           ),
//         ),
//       ),
//       title: Text(label),
//       subtitle: Text('$year'),
//       trailing: isSelected
//           ? Icon(Icons.check_circle_rounded, color: AppColors.primary)
//           : null,
//       onTap: () {
//         final quarterMonth = (quarter - 1) * 3 + 1;
//         final selectedDate = DateTime(year, quarterMonth);
//         viewModel.changePeriod('quarterly', selectedDate: selectedDate);
//         Navigator.pop(context);
//       },
//     );
//   }

//   bool _isSameWeek(DateTime a, DateTime b) {
//     final aStart = _getFirstDayOfWeek(a);
//     final bStart = _getFirstDayOfWeek(b);
//     return aStart.year == bStart.year &&
//         aStart.month == bStart.month &&
//         aStart.day == bStart.day;
//   }
// }

// import 'package:AttendanceApp/core/view_models/theme_view_model.dart';
// import 'package:AttendanceApp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:AttendanceApp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:AttendanceApp/widgets/analytics/graph_toggle.dart';
// import 'package:AttendanceApp/widgets/analytics/individual_graphs.dart';
// import 'package:AttendanceApp/widgets/analytics/merged_graph.dart';
// import 'package:AttendanceApp/widgets/analytics/performance_summary.dart';
// import 'package:AttendanceApp/widgets/analytics/period_selector.dart';
// import 'package:AttendanceApp/widgets/analytics/statistics_cards.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class AttendanceDetailScreen extends StatefulWidget {
//   const AttendanceDetailScreen({super.key});

//   @override
//   _AttendanceDetailScreenState createState() => _AttendanceDetailScreenState();
// }

// class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _initializeAnalytics();
//   }

//   void _initializeAnalytics() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final dashboardViewModel = Provider.of<ManagerDashboardViewModel>(
//         context,
//         listen: false,
//       );
//       final analyticsViewModel = Provider.of<AttendanceAnalyticsViewModel>(
//         context,
//         listen: false,
//       );

//       final teamMembers = dashboardViewModel.dashboard?.teamMembers ?? [];
//       analyticsViewModel.initializeAnalytics(teamMembers);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);
//     final viewModel = Provider.of<AttendanceAnalyticsViewModel>(context);

//     return Scaffold(
//       backgroundColor: theme.themeMode == ThemeMode.dark
//           ? AppColors.backgroundDark
//           : AppColors.backgroundLight,
//       appBar: AppBar(
//         title: const Text('Attendance Analytics'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_rounded),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: viewModel.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _buildContent(viewModel),
//     );
//   }

//   Widget _buildContent(AttendanceAnalyticsViewModel viewModel) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           PeriodSelector(viewModel: viewModel),
//           const SizedBox(height: 16),
//           GraphToggle(viewModel: viewModel),
//           const SizedBox(height: 20),
//           StatisticsCards(viewModel: viewModel),
//           const SizedBox(height: 24),
//           _buildGraphSection(viewModel),
//           // const SizedBox(height: 20),
//           // InsightsSection(viewModel: viewModel),
//           const SizedBox(height: 20),
//           PerformanceSummary(viewModel: viewModel),
//         ],
//       ),
//     );
//   }

//   Widget _buildGraphSection(AttendanceAnalyticsViewModel viewModel) {
//     return viewModel.showIndividualGraphs
//         ? IndividualGraphs(viewModel: viewModel)
//         : MergedGraph(viewModel: viewModel);
//   }
// }

// import 'package:AttendanceApp/core/view_models/theme_view_model.dart';
// import 'package:AttendanceApp/models/team_model.dart';
// import 'package:AttendanceApp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class AttendanceDetailScreen extends StatefulWidget {
//   const AttendanceDetailScreen({super.key});

//   @override
//   _AttendanceDetailScreenState createState() => _AttendanceDetailScreenState();
// }

// class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
//   bool _showIndividualGraphs = false;
//   String _selectedPeriod = 'daily'; // daily, weekly, monthly, yearly
//   final List<String> _periods = ['daily', 'weekly', 'monthly', 'yearly'];

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);
//     final viewModel = Provider.of<ManagerDashboardViewModel>(context);

//     return Scaffold(
//       backgroundColor: theme.themeMode == ThemeMode.dark
//           ? AppColors.backgroundDark
//           : AppColors.backgroundLight,
//       appBar: AppBar(
//         title: const Text('Attendance Analytics'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_rounded),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(
//               _showIndividualGraphs
//                   ? Icons.merge_type_rounded
//                   : Icons.person_outline_rounded,
//               color: AppColors.primary,
//             ),
//             onPressed: () {
//               setState(() {
//                 _showIndividualGraphs = !_showIndividualGraphs;
//               });
//             },
//           ),
//         ],
//       ),
//       body: viewModel.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _buildAttendanceContent(viewModel),
//     );
//   }

//   Widget _buildAttendanceContent(ManagerDashboardViewModel viewModel) {
//     final teamMembers = viewModel.dashboard?.teamMembers ?? [];
//     final attendanceData = _generateAttendanceData(
//       teamMembers,
//       _selectedPeriod,
//     );

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Period Selector
//           _buildPeriodSelector(),

//           const SizedBox(height: 16),

//           // Graph Type Toggle
//           _buildGraphTypeToggle(),

//           const SizedBox(height: 20),

//           // Statistics Cards
//           _buildStatisticsCards(attendanceData, teamMembers),

//           const SizedBox(height: 24),

//           // Graph Section
//           _showIndividualGraphs
//               ? _buildIndividualGraphs(attendanceData, teamMembers)
//               : _buildMergedGraph(attendanceData, teamMembers),

//           const SizedBox(height: 20),

//           // Insights Section
//           _buildInsightsSection(attendanceData, teamMembers),

//           const SizedBox(height: 20),

//           // Attendance Summary
//           _buildAttendanceSummary(viewModel),
//         ],
//       ),
//     );
//   }

//   Widget _buildPeriodSelector() {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: AppColors.grey100,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: _periods.map((period) {
//           final isSelected = _selectedPeriod == period;
//           return Expanded(
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _selectedPeriod = period;
//                 });
//               },
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 decoration: BoxDecoration(
//                   color: isSelected ? AppColors.primary : Colors.transparent,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   _getPeriodDisplayName(period),
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: isSelected
//                         ? AppColors.white
//                         : AppColors.textSecondary,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   String _getPeriodDisplayName(String period) {
//     switch (period) {
//       case 'daily':
//         return 'Daily';
//       case 'weekly':
//         return 'Weekly';
//       case 'monthly':
//         return 'Monthly';
//       case 'yearly':
//         return 'Yearly';
//       default:
//         return 'Daily';
//     }
//   }

//   Widget _buildGraphTypeToggle() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: AppColors.primary.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             _showIndividualGraphs ? 'Individual View' : 'Team Overview',
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: AppColors.primary,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   _showIndividualGraphs
//                       ? Icons.people_alt_rounded
//                       : Icons.person_rounded,
//                   color: AppColors.white,
//                   size: 16,
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   _showIndividualGraphs ? 'Team View' : 'Individual',
//                   style: const TextStyle(
//                     color: AppColors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatisticsCards(
//     Map<String, dynamic> attendanceData,
//     List<TeamMember> teamMembers,
//   ) {
//     final stats = _calculateStatistics(attendanceData, teamMembers);

//     return Row(
//       children: [
//         Expanded(
//           child: _buildStatCard(
//             'Attendance Rate',
//             '${stats['attendanceRate']}%',
//             Icons.trending_up_rounded,
//             AppColors.success,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _buildStatCard(
//             'Avg. Hours',
//             '${stats['avgHours']}h',
//             Icons.access_time_rounded,
//             AppColors.info,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _buildStatCard(
//             'Productivity',
//             '${stats['productivity']}%',
//             Icons.work_history_rounded,
//             AppColors.primary,
//           ),
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
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.2),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, size: 16, color: color),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 10,
//               color: AppColors.textSecondary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMergedGraph(
//     Map<String, dynamic> attendanceData,
//     List<TeamMember> teamMembers,
//   ) {
//     final graphData = attendanceData['graphData'] as Map<String, List<double>>;
//     final labels = _getGraphLabels();

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   '${_getPeriodDisplayName(_selectedPeriod)} Attendance Overview',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     '${teamMembers.length} Members',
//                     style: const TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _getGraphSubtitle(),
//               style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
//             ),
//             const SizedBox(height: 20),

//             // Graph Container
//             Container(
//               height: 200,
//               child: _buildMergedGraphContent(graphData, labels),
//             ),

//             const SizedBox(height: 16),

//             // Legend
//             _buildGraphLegend(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMergedGraphContent(
//     Map<String, List<double>> graphData,
//     List<String> labels,
//   ) {
//     return Stack(
//       children: [
//         // Grid Lines
//         _buildGraphGrid(),

//         // Bars for different metrics
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: labels.asMap().entries.map((entry) {
//             final index = entry.key;
//             final label = entry.value;

//             final presentData = graphData['present']?[index] ?? 0;
//             final lateData = graphData['late']?[index] ?? 0;
//             final absentData = graphData['absent']?[index] ?? 0;

//             final totalHeight = presentData + lateData + absentData;
//             final maxValue = graphData.values
//                 .expand((e) => e)
//                 .reduce((a, b) => a > b ? a : b);
//             final scaleFactor = maxValue > 0 ? 150 / maxValue : 0;

//             return Column(
//               children: [
//                 // Values on top
//                 Text(
//                   totalHeight.toInt().toString(),
//                   style: const TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 4),

//                 // Stacked Bar
//                 Container(
//                   width: 25,
//                   height: totalHeight * scaleFactor,
//                   child: Stack(
//                     children: [
//                       // Absent (Red)
//                       if (absentData > 0)
//                         Container(
//                           height: absentData * scaleFactor,
//                           decoration: BoxDecoration(
//                             color: AppColors.error,
//                             borderRadius: const BorderRadius.vertical(
//                               top: Radius.circular(4),
//                             ),
//                           ),
//                         ),
//                       // Late (Orange)
//                       if (lateData > 0)
//                         Positioned(
//                           bottom: absentData * scaleFactor,
//                           child: Container(
//                             width: 25,
//                             height: lateData * scaleFactor,
//                             decoration: BoxDecoration(color: AppColors.warning),
//                           ),
//                         ),
//                       // Present (Green)
//                       if (presentData > 0)
//                         Positioned(
//                           bottom: (absentData + lateData) * scaleFactor,
//                           child: Container(
//                             width: 25,
//                             height: presentData * scaleFactor,
//                             decoration: BoxDecoration(
//                               color: AppColors.success,
//                               borderRadius: const BorderRadius.vertical(
//                                 bottom: Radius.circular(4),
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 8),

//                 // Label
//                 SizedBox(
//                   width: 40,
//                   child: Text(
//                     label,
//                     style: const TextStyle(
//                       fontSize: 10,
//                       color: AppColors.textSecondary,
//                     ),
//                     textAlign: TextAlign.center,
//                     maxLines: 2,
//                   ),
//                 ),
//               ],
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildIndividualGraphs(
//     Map<String, dynamic> attendanceData,
//     List<TeamMember> teamMembers,
//   ) {
//     final individualData =
//         attendanceData['individualData'] as Map<String, Map<String, double>>;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Individual Performance - ${_getPeriodDisplayName(_selectedPeriod)}',
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'Detailed view of each team member\'s attendance pattern',
//           style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
//         ),
//         const SizedBox(height: 16),

//         ...teamMembers.map((member) {
//           final memberData = individualData[member.email] ?? {};
//           final attendanceRate = memberData['attendanceRate'] ?? 0;
//           final avgHours = memberData['avgHours'] ?? 0;
//           final productivity = memberData['productivity'] ?? 0;

//           return Card(
//             margin: const EdgeInsets.only(bottom: 12),
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Member Info
//                   Row(
//                     children: [
//                       Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: _getPerformanceColor(
//                             attendanceRate,
//                           ).withOpacity(0.1),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.person_rounded,
//                           size: 20,
//                           color: _getPerformanceColor(attendanceRate),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               member.name,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 color: AppColors.textPrimary,
//                               ),
//                             ),
//                             Text(
//                               member.role,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: AppColors.textSecondary,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(
//                             '${attendanceRate.toStringAsFixed(1)}%',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: _getPerformanceColor(attendanceRate),
//                             ),
//                           ),
//                           Text(
//                             'Attendance',
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: AppColors.textSecondary,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 12),

//                   // Performance Metrics
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildMiniMetric(
//                         'Hours',
//                         '${avgHours.toStringAsFixed(1)}h',
//                         Icons.access_time_rounded,
//                       ),
//                       _buildMiniMetric(
//                         'Productivity',
//                         '${productivity.toStringAsFixed(0)}%',
//                         Icons.work_rounded,
//                       ),
//                       _buildMiniMetric(
//                         'Present',
//                         '${(attendanceRate / 100 * 20).toInt()}/20',
//                         Icons.check_circle_rounded,
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 8),

//                   // Performance Bar
//                   LinearProgressIndicator(
//                     value: attendanceRate / 100,
//                     backgroundColor: AppColors.grey300,
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       _getPerformanceColor(attendanceRate),
//                     ),
//                     minHeight: 6,
//                     borderRadius: BorderRadius.circular(3),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }

//   Widget _buildMiniMetric(String label, String value, IconData icon) {
//     return Column(
//       children: [
//         Icon(icon, size: 16, color: AppColors.primary),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
//         ),
//         Text(
//           label,
//           style: const TextStyle(fontSize: 8, color: AppColors.textSecondary),
//         ),
//       ],
//     );
//   }

//   Widget _buildGraphGrid() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: List.generate(5, (index) {
//         return Container(height: 1, color: AppColors.grey300.withOpacity(0.5));
//       }),
//     );
//   }

//   Widget _buildGraphLegend() {
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
//         Container(
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//         const SizedBox(width: 4),
//         Text(
//           text,
//           style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
//         ),
//       ],
//     );
//   }

//   Widget _buildInsightsSection(
//     Map<String, dynamic> attendanceData,
//     List<TeamMember> teamMembers,
//   ) {
//     final insights = _generateInsights(attendanceData, teamMembers);

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
//             ...insights
//                 .map(
//                   (insight) => Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Icon(
//                           insight['type'] == 'positive'
//                               ? Icons.trending_up_rounded
//                               : insight['type'] == 'warning'
//                               ? Icons.warning_amber_rounded
//                               : Icons.info_rounded,
//                           color: insight['type'] == 'positive'
//                               ? AppColors.success
//                               : insight['type'] == 'warning'
//                               ? AppColors.warning
//                               : AppColors.info,
//                           size: 16,
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             insight['text'],
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: AppColors.textSecondary,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//                 .toList(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAttendanceSummary(ManagerDashboardViewModel viewModel) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Recent Activity',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 _buildSummaryItem('Total Working Days', '22', 'Target: 20'),
//                 _buildSummaryItem('Average Hours/Day', '8.5', 'Target: 9.0'),
//                 _buildSummaryItem('On-time Arrival', '85%', 'Good'),
//                 _buildSummaryItem('Productivity Score', '78%', 'Improving'),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSummaryItem(String title, String value, String subtitle) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//               Text(
//                 subtitle,
//                 style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Data Generation Methods
//   Map<String, dynamic> _generateAttendanceData(
//     List<TeamMember> teamMembers,
//     String period,
//   ) {
//     // This would typically come from your database
//     // For demo, generating realistic sample data

//     final now = DateTime.now();
//     Map<String, List<double>> graphData = {
//       'present': [],
//       'late': [],
//       'absent': [],
//     };

//     Map<String, Map<String, double>> individualData = {};

//     // Generate data based on period
//     List<String> labels = _getGraphLabels();

//     for (final label in labels) {
//       graphData['present']!.add(
//         (teamMembers.length * 0.7).toDouble(),
//       ); // 70% present
//       graphData['late']!.add((teamMembers.length * 0.2).toDouble()); // 20% late
//       graphData['absent']!.add(
//         (teamMembers.length * 0.1).toDouble(),
//       ); // 10% absent
//     }

//     // Generate individual data
//     for (final member in teamMembers) {
//       individualData[member.email] = {
//         'attendanceRate': (70 + member.email.hashCode % 30)
//             .toDouble(), // 70-99%
//         'avgHours': 7.5 + (member.email.hashCode % 15) / 10, // 7.5-9.0 hours
//         'productivity': 75.0 + (member.email.hashCode % 20), // 75-95%
//       };
//     }

//     return {
//       'graphData': graphData,
//       'individualData': individualData,
//       'period': period,
//     };
//   }

//   List<String> _getGraphLabels() {
//     switch (_selectedPeriod) {
//       case 'daily':
//         return ['9AM', '11AM', '1PM', '3PM', '5PM', '7PM'];
//       case 'weekly':
//         return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
//       case 'monthly':
//         return ['Week1', 'Week2', 'Week3', 'Week4', 'Week5'];
//       case 'yearly':
//         return [
//           'Jan',
//           'Feb',
//           'Mar',
//           'Apr',
//           'May',
//           'Jun',
//           'Jul',
//           'Aug',
//           'Sep',
//           'Oct',
//           'Nov',
//           'Dec',
//         ];
//       default:
//         return ['9AM', '11AM', '1PM', '3PM', '5PM', '7PM'];
//     }
//   }

//   String _getGraphSubtitle() {
//     switch (_selectedPeriod) {
//       case 'daily':
//         return 'Today\'s attendance pattern across 9 working hours';
//       case 'weekly':
//         return 'This week\'s attendance trend (Monday to Saturday)';
//       case 'monthly':
//         return 'Monthly attendance overview (4-5 weeks)';
//       case 'yearly':
//         return 'Yearly attendance performance by month';
//       default:
//         return 'Attendance overview';
//     }
//   }

//   Map<String, dynamic> _calculateStatistics(
//     Map<String, dynamic> attendanceData,
//     List<TeamMember> teamMembers,
//   ) {
//     final individualData =
//         attendanceData['individualData'] as Map<String, Map<String, double>>;

//     double totalAttendance = 0;
//     double totalHours = 0;
//     double totalProductivity = 0;

//     individualData.forEach((email, data) {
//       totalAttendance += data['attendanceRate'] ?? 0;
//       totalHours += data['avgHours'] ?? 0;
//       totalProductivity += data['productivity'] ?? 0;
//     });

//     final count = teamMembers.length;

//     return {
//       'attendanceRate': (totalAttendance / count).round(),
//       'avgHours': (totalHours / count).toStringAsFixed(1),
//       'productivity': (totalProductivity / count).round(),
//     };
//   }

//   List<Map<String, String>> _generateInsights(
//     Map<String, dynamic> attendanceData,
//     List<TeamMember> teamMembers,
//   ) {
//     final stats = _calculateStatistics(attendanceData, teamMembers);

//     return [
//       {
//         'text':
//             'Team attendance rate is ${stats['attendanceRate']}%, above company average of 85%',
//         'type': 'positive',
//       },
//       {
//         'text': 'Average working hours: ${stats['avgHours']}h/day (Target: 9h)',
//         'type': 'info',
//       },
//       {
//         'text':
//             '${stats['productivity']}% productivity score needs improvement',
//         'type': 'warning',
//       },
//       {
//         'text':
//             'Best performance time: 10AM-12PM, Consider optimizing schedules',
//         'type': 'info',
//       },
//     ];
//   }

//   Color _getPerformanceColor(double rate) {
//     if (rate >= 90) return AppColors.success;
//     if (rate >= 75) return AppColors.warning;
//     return AppColors.error;
//   }
// }
