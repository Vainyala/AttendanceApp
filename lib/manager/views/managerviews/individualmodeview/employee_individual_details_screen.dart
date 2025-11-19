import 'package:AttendanceApp/manager/models/team_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/view_models/theme_view_model.dart';
import '../../../view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
import '../../../view_models/employeeviewmodels/employee_details_view_model.dart';
import '../../../widgets/analytics/individualmodeanalytics/EmployeeAttendanceDownloadButton.dart';
import '../../../widgets/analytics/period_selector.dart';
import '../../../widgets/employee/attendance_history_list.dart';

class EmployeeIndividualDetailsScreen extends StatefulWidget {
  final TeamMember employee;

  const EmployeeIndividualDetailsScreen({super.key, required this.employee});

  @override
  State<EmployeeIndividualDetailsScreen> createState() =>
      _EmployeeIndividualDetailsScreenState();
}

class _EmployeeIndividualDetailsScreenState
    extends State<EmployeeIndividualDetailsScreen> {
  late EmployeeDetailsViewModel _viewModel;
  late AttendanceAnalyticsViewModel _analyticsViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EmployeeDetailsViewModel();
    _analyticsViewModel = AttendanceAnalyticsViewModel();
    _loadEmployeeData();
  }

  void _loadEmployeeData() async {
    await _viewModel.loadEmployeeDetails(widget.employee);
    // Initialize analytics for this single employee
    await _analyticsViewModel.initializeAnalytics([widget.employee]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _viewModel),
        ChangeNotifierProvider.value(value: _analyticsViewModel),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            _buildPeriodSelector(),
            _buildEmployeeProfile(context),
            _buildAttendanceSection(context),
            //_buildProjectsSection(context),
            _buildAttendanceHistory(context),
          ],
        ),
      ),
    );
  }

  // Add Period Selector using your existing widget
  SliverToBoxAdapter _buildPeriodSelector() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Consumer<AttendanceAnalyticsViewModel>(
          builder: (context, analyticsViewModel, child) {
            return PeriodSelector(viewModel: analyticsViewModel);
          },
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      elevation: 1,
      pinned: true,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.employee.name,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.grey.shade800,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.blue.shade900, Colors.purple.shade900]
                  : [Colors.blue.shade50, Colors.purple.shade50],
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? Colors.white : Colors.grey.shade700,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Consumer<EmployeeDetailsViewModel>(
          builder: (context, viewModel, child) {
            return EmployeeAttendanceDownloadButton(viewModel: viewModel);
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // Update employee profile to show period-based title
  SliverToBoxAdapter _buildEmployeeProfile(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: Consumer<AttendanceAnalyticsViewModel>(
        builder: (context, analyticsViewModel, child) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.white,
              borderRadius: BorderRadius.circular(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period-based title
                Text(
                  _getPeriodTitle(analyticsViewModel.selectedPeriod),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                // Period display text
                Text(
                  _getPeriodDisplayText(
                    analyticsViewModel.selectedPeriod,
                    analyticsViewModel.selectedDate,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Photo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? Colors.blue.shade800
                            : Colors.blue.shade100,
                        border: Border.all(
                          color: isDark
                              ? Colors.blue.shade600
                              : Colors.blue.shade200,
                          width: 3,
                        ),
                      ),
                      child: widget.employee.profilePhoto != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                widget.employee.profilePhoto!,
                              ),
                              radius: 40,
                            )
                          : Center(
                              child: Text(
                                widget.employee.name
                                    .split(' ')
                                    .map((n) => n[0])
                                    .join(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.blue.shade700,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.employee.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.employee.role,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.blue.shade300
                                  : Colors.blue.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            context,
                            Icons.email_rounded,
                            widget.employee.email,
                          ),
                          _buildInfoRow(
                            context,
                            Icons.phone_rounded,
                            widget.employee.phoneNumber,
                          ),
                          _buildInfoRow(
                            context,
                            Icons.circle_rounded,
                            'Status: ${widget.employee.status}',
                            color: _getStatusColor(widget.employee.status),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper methods for period-based display
  String _getPeriodTitle(String period) {
    switch (period) {
      case 'daily':
        return "Daily Employee Detail";
      case 'weekly':
        return "Weekly Employee Detail";
      case 'monthly':
        return "Monthly Employee Detail";
      case 'quarterly':
        return "Quarterly Employee Detail";
      default:
        return "Employee Detail";
    }
  }

  String _getPeriodDisplayText(String period, DateTime selectedDate) {
    switch (period) {
      case 'daily':
        return _formatDate(selectedDate);
      case 'weekly':
        return _getWeekDisplayText(selectedDate);
      case 'monthly':
        return _getMonthlyDisplayText(selectedDate);
      case 'quarterly':
        return _getQuarterlyDisplayText(selectedDate);
      default:
        return _formatDate(selectedDate);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  String _getWeekDisplayText(DateTime date) {
    final weekNumber = _getWeekNumber(date);
    final monthName = _getMonthName(date.month);
    return "$monthName Week $weekNumber";
  }

  String _getMonthlyDisplayText(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);
    return "From: ${_formatDate(firstDay)} To: ${_formatDate(lastDay)}";
  }

  String _getQuarterlyDisplayText(DateTime date) {
    final quarter = ((date.month - 1) ~/ 3).floor();
    final startMonth = (quarter * 3) + 1;
    final endMonth = startMonth + 2;

    final startMonthName = _getMonthName(startMonth);
    final endMonthName = _getMonthName(endMonth);

    return "From: $startMonthName To: $endMonthName";
  }

  int _getWeekNumber(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final daysDiff = date.difference(firstDay).inDays;
    return ((daysDiff + firstDay.weekday) / 7).ceil();
  }

  String _getMonthName(int month) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  // Update attendance section to use period-based data
  SliverToBoxAdapter _buildAttendanceSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: Consumer2<EmployeeDetailsViewModel, AttendanceAnalyticsViewModel>(
        builder: (context, viewModel, analyticsViewModel, child) {
          // Get period-based attendance data
          final periodData = analyticsViewModel.getPeriodAttendanceData(
            widget.employee.email,
          );
          final summary = _getAttendanceSummary(periodData);

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.white,
              borderRadius: BorderRadius.circular(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${analyticsViewModel.getPeriodDisplayName(analyticsViewModel.selectedPeriod)} Attendance Overview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.blue.shade800
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${summary['percentage'] ?? 0}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Attendance Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      context,
                      'Present',
                      summary['present'] ?? 0,
                      Colors.green,
                    ),
                    _buildStatCard(
                      context,
                      'Absent',
                      summary['absent'] ?? 0,
                      Colors.red,
                    ),
                    _buildStatCard(
                      context,
                      'Late',
                      summary['late'] ?? 0,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      context,
                      'Leave',
                      summary['leave'] ?? 0,
                      Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Total Days Row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Total Days: ${summary['total'] ?? 0}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper method to calculate attendance summary from period data
  Map<String, int> _getAttendanceSummary(Map<String, dynamic> periodData) {
    final present = periodData['present'] ?? 0;
    final absent = periodData['absent'] ?? 0;
    final leave = periodData['leave'] ?? 0;
    final late = periodData['late'] ?? 0;
    final total = present + absent + leave + late;

    final percentage = total > 0 ? ((present / total) * 100).round() : 0;

    return {
      'present': present,
      'absent': absent,
      'late': late,
      'leave': leave,
      'total': total,
      'percentage': percentage,
    };
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    int value,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.2 : 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(isDark ? 0.4 : 0.3)),
          ),
          child: Text(
            value.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildProjectsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: Consumer<EmployeeDetailsViewModel>(
        builder: (context, viewModel, child) {
          final projects = viewModel.getEmployeeProjects();

          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.white,
              borderRadius: BorderRadius.circular(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Allocated Projects',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.purple.shade800
                            : Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${projects.length} Projects',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white : Colors.purple.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (projects.isEmpty)
                  _buildEmptyState(
                    context,
                    '${viewModel.employee?.name ?? 'Employee'} is not assigned to any projects',
                    Icons.work_off_rounded,
                  )
                else
                  Column(
                    children: projects
                        .map((project) => _buildProjectItem(context, project))
                        .toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectItem(BuildContext context, String project) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade700 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.work_rounded,
            size: 16,
            color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              project,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? Colors.green.shade800 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Active',
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white : Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildAttendanceHistory(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<AttendanceAnalyticsViewModel>(
              builder: (context, analyticsViewModel, child) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${analyticsViewModel.getPeriodDisplayName(analyticsViewModel.selectedPeriod)} Attendance History',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.grey.shade800,
                    ),
                  ),
                );
              },
            ),
            AttendanceHistoryList(viewModel: _viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String text, {
    Color? color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color:
                color ?? (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color:
                    color ??
                    (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'on leave':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _analyticsViewModel.dispose();
    super.dispose();
  }
}

// import 'package:attendanceapp/widgets/analytics/individualmodeanalytics/EmployeeAttendanceDownloadButton.dart';
// import 'package:attendanceapp/widgets/employee/attendance_history_list.dart';
// import 'package:flutter/material.dart';
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/team_model.dart';
// import 'package:attendanceapp/view_models/employeeviewmodels/employee_details_view_model.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:attendanceapp/widgets/analytics/period_selector.dart';
// import 'package:provider/provider.dart';

// class EmployeeIndividualDetailsScreen extends StatefulWidget {
//   final TeamMember employee;

//   const EmployeeIndividualDetailsScreen({super.key, required this.employee});

//   @override
//   State<EmployeeIndividualDetailsScreen> createState() =>
//       _EmployeeIndividualDetailsScreenState();
// }

// class _EmployeeIndividualDetailsScreenState
//     extends State<EmployeeIndividualDetailsScreen> {
//   late EmployeeDetailsViewModel _viewModel;
//   late AttendanceAnalyticsViewModel _analyticsViewModel;

//   @override
//   void initState() {
//     super.initState();
//     _viewModel = EmployeeDetailsViewModel();
//     _analyticsViewModel = AttendanceAnalyticsViewModel();
//     _loadEmployeeData();
//   }

//   void _loadEmployeeData() async {
//     await _viewModel.loadEmployeeDetails(widget.employee);
//     // Initialize analytics for this single employee
//     await _analyticsViewModel.initializeAnalytics([widget.employee]);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider.value(value: _viewModel),
//         ChangeNotifierProvider.value(value: _analyticsViewModel),
//       ],
//       child: Scaffold(
//         backgroundColor: Colors.grey.shade50,
//         body: CustomScrollView(
//           slivers: [
//             _buildAppBar(),
//             _buildPeriodSelector(),
//             _buildEmployeeProfile(),
//             _buildAttendanceSection(),
//             //_buildProjectsSection(),
//             _buildAttendanceHistory(),
//           ],
//         ),
//       ),
//     );
//   }

//   // Add Period Selector using your existing widget
//   SliverToBoxAdapter _buildPeriodSelector() {
//     return SliverToBoxAdapter(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         child: Consumer<AttendanceAnalyticsViewModel>(
//           builder: (context, analyticsViewModel, child) {
//             return PeriodSelector(viewModel: analyticsViewModel);
//           },
//         ),
//       ),
//     );
//   }

//   SliverAppBar _buildAppBar() {
//     return SliverAppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       pinned: true,
//       expandedHeight: 120,
//       flexibleSpace: FlexibleSpaceBar(
//         title: Text(
//           widget.employee.name,
//           style: TextStyle(
//             color: Colors.grey.shade800,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Colors.blue.shade50, Colors.purple.shade50],
//             ),
//           ),
//         ),
//       ),
//       leading: IconButton(
//         icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
//         onPressed: () => Navigator.pop(context),
//       ),
//       actions: [
//         Consumer<EmployeeDetailsViewModel>(
//           builder: (context, viewModel, child) {
//             return EmployeeAttendanceDownloadButton(viewModel: viewModel);
//           },
//         ),
//         const SizedBox(width: 8),
//       ],
//     );
//   }

//   // Update employee profile to show period-based title
//   SliverToBoxAdapter _buildEmployeeProfile() {
//     return SliverToBoxAdapter(
//       child: Consumer<AttendanceAnalyticsViewModel>(
//         builder: (context, analyticsViewModel, child) {
//           return Container(
//             margin: const EdgeInsets.all(16),
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Period-based title
//                 Text(
//                   _getPeriodTitle(analyticsViewModel.selectedPeriod),
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey.shade800,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 // Period display text
//                 Text(
//                   _getPeriodDisplayText(
//                     analyticsViewModel.selectedPeriod,
//                     analyticsViewModel.selectedDate,
//                   ),
//                   style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Profile Photo
//                     Container(
//                       width: 80,
//                       height: 80,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.blue.shade100,
//                         border: Border.all(
//                           color: Colors.blue.shade200,
//                           width: 3,
//                         ),
//                       ),
//                       child: widget.employee.profilePhoto != null
//                           ? CircleAvatar(
//                               backgroundImage: NetworkImage(
//                                 widget.employee.profilePhoto!,
//                               ),
//                               radius: 40,
//                             )
//                           : Center(
//                               child: Text(
//                                 widget.employee.name
//                                     .split(' ')
//                                     .map((n) => n[0])
//                                     .join(),
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.blue.shade700,
//                                 ),
//                               ),
//                             ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.employee.name,
//                             style: const TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             widget.employee.role,
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.blue.shade600,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           _buildInfoRow(
//                             Icons.email_rounded,
//                             widget.employee.email,
//                           ),
//                           _buildInfoRow(
//                             Icons.phone_rounded,
//                             widget.employee.phoneNumber,
//                           ),
//                           _buildInfoRow(
//                             Icons.circle_rounded,
//                             'Status: ${widget.employee.status}',
//                             color: _getStatusColor(widget.employee.status),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // Helper methods for period-based display
//   String _getPeriodTitle(String period) {
//     switch (period) {
//       case 'daily':
//         return "Daily Employee Detail";
//       case 'weekly':
//         return "Weekly Employee Detail";
//       case 'monthly':
//         return "Monthly Employee Detail";
//       case 'quarterly':
//         return "Quarterly Employee Detail";
//       default:
//         return "Employee Detail";
//     }
//   }

//   String _getPeriodDisplayText(String period, DateTime selectedDate) {
//     switch (period) {
//       case 'daily':
//         return _formatDate(selectedDate);
//       case 'weekly':
//         return _getWeekDisplayText(selectedDate);
//       case 'monthly':
//         return _getMonthlyDisplayText(selectedDate);
//       case 'quarterly':
//         return _getQuarterlyDisplayText(selectedDate);
//       default:
//         return _formatDate(selectedDate);
//     }
//   }

//   String _formatDate(DateTime date) {
//     return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
//   }

//   String _getWeekDisplayText(DateTime date) {
//     final weekNumber = _getWeekNumber(date);
//     final monthName = _getMonthName(date.month);
//     return "$monthName Week $weekNumber";
//   }

//   String _getMonthlyDisplayText(DateTime date) {
//     final firstDay = DateTime(date.year, date.month, 1);
//     final lastDay = DateTime(date.year, date.month + 1, 0);
//     return "From: ${_formatDate(firstDay)} To: ${_formatDate(lastDay)}";
//   }

//   String _getQuarterlyDisplayText(DateTime date) {
//     final quarter = ((date.month - 1) ~/ 3).floor();
//     final startMonth = (quarter * 3) + 1;
//     final endMonth = startMonth + 2;

//     final startMonthName = _getMonthName(startMonth);
//     final endMonthName = _getMonthName(endMonth);

//     return "From: $startMonthName To: $endMonthName";
//   }

//   int _getWeekNumber(DateTime date) {
//     final firstDay = DateTime(date.year, 1, 1);
//     final daysDiff = date.difference(firstDay).inDays;
//     return ((daysDiff + firstDay.weekday) / 7).ceil();
//   }

//   String _getMonthName(int month) {
//     final months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December',
//     ];
//     return months[month - 1];
//   }

//   // Update attendance section to use period-based data
//   SliverToBoxAdapter _buildAttendanceSection() {
//     return SliverToBoxAdapter(
//       child: Consumer2<EmployeeDetailsViewModel, AttendanceAnalyticsViewModel>(
//         builder: (context, viewModel, analyticsViewModel, child) {
//           // Get period-based attendance data
//           final periodData = analyticsViewModel.getPeriodAttendanceData(
//             widget.employee.email,
//           );
//           final summary = _getAttendanceSummary(periodData);

//           return Container(
//             margin: const EdgeInsets.symmetric(horizontal: 16),
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '${analyticsViewModel.getPeriodDisplayName(analyticsViewModel.selectedPeriod)} Attendance Overview',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey.shade800,
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         '${summary['percentage'] ?? 0}%',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.blue.shade700,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 // Attendance Stats
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildStatCard(
//                       'Present',
//                       summary['present'] ?? 0,
//                       Colors.green,
//                     ),
//                     _buildStatCard(
//                       'Absent',
//                       summary['absent'] ?? 0,
//                       Colors.red,
//                     ),
//                     _buildStatCard('Late', summary['late'] ?? 0, Colors.orange),
//                     _buildStatCard('Leave', summary['leave'] ?? 0, Colors.blue),
//                   ],
//                 ),
//                 const SizedBox(height: 8),

//                 // Total Days Row
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: AppColors.accentLight,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.calendar_today,
//                         size: 16,
//                         color: Colors.grey.shade600,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         'Total Days: ${summary['total'] ?? 0}',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey.shade700,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // Helper method to calculate attendance summary from period data
//   Map<String, int> _getAttendanceSummary(Map<String, dynamic> periodData) {
//     final present = periodData['present'] ?? 0;
//     final absent = periodData['absent'] ?? 0;
//     final leave = periodData['leave'] ?? 0;
//     final late = periodData['late'] ?? 0;
//     final total = present + absent + leave + late;

//     final percentage = total > 0 ? ((present / total) * 100).round() : 0;

//     return {
//       'present': present,
//       'absent': absent,
//       'late': late,
//       'leave': leave,
//       'total': total,
//       'percentage': percentage,
//     };
//   }

//   Widget _buildStatCard(String label, int value, Color color) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             shape: BoxShape.circle,
//             border: Border.all(color: color.withOpacity(0.3)),
//           ),
//           child: Text(
//             value.toString(),
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w700,
//               color: color,
//             ),
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 10,
//             color: Colors.grey.shade600,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   SliverToBoxAdapter _buildProjectsSection() {
//     return SliverToBoxAdapter(
//       child: Consumer<EmployeeDetailsViewModel>(
//         builder: (context, viewModel, child) {
//           final projects = viewModel.getEmployeeProjects();

//           return Container(
//             margin: const EdgeInsets.all(16),
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Allocated Projects',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey.shade800,
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.purple.shade50,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         '${projects.length} Projects',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.purple.shade700,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),

//                 if (projects.isEmpty)
//                   _buildEmptyState(
//                     '${viewModel.employee?.name ?? 'Employee'} is not assigned to any projects',
//                     Icons.work_off_rounded,
//                   )
//                 else
//                   Column(
//                     children: projects
//                         .map((project) => _buildProjectItem(project))
//                         .toList(),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildProjectItem(String project) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.work_rounded, size: 16, color: Colors.blue.shade600),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               project,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey.shade800,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//             decoration: BoxDecoration(
//               color: Colors.green.shade50,
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Text(
//               'Active',
//               style: TextStyle(
//                 fontSize: 10,
//                 color: Colors.green.shade700,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   SliverToBoxAdapter _buildAttendanceHistory() {
//     return SliverToBoxAdapter(
//       child: Container(
//         margin: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Consumer<AttendanceAnalyticsViewModel>(
//               builder: (context, analyticsViewModel, child) {
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 12),
//                   child: Text(
//                     '${analyticsViewModel.getPeriodDisplayName(analyticsViewModel.selectedPeriod)} Attendance History',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey.shade800,
//                     ),
//                   ),
//                 );
//               },
//             ),
//             AttendanceHistoryList(viewModel: _viewModel),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         children: [
//           Icon(icon, size: 14, color: color ?? Colors.grey.shade600),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: color ?? Colors.grey.shade600,
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'active':
//         return Colors.green;
//       case 'inactive':
//         return Colors.red;
//       case 'on leave':
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }

//   Widget _buildEmptyState(String message, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           Icon(icon, size: 40, color: Colors.grey.shade400),
//           const SizedBox(height: 8),
//           Text(
//             message,
//             style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _viewModel.dispose();
//     _analyticsViewModel.dispose();
//     super.dispose();
//   }
// }

// import 'package:attendanceapp/widgets/analytics/individualmodeanalytics/EmployeeAttendanceDownloadButton.dart';
// import 'package:attendanceapp/widgets/employee/attendance_history_list.dart';
// import 'package:flutter/material.dart';
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/team_model.dart';
// import 'package:attendanceapp/view_models/employeeviewmodels/employee_details_view_model.dart';
// import 'package:provider/provider.dart';

// class EmployeeIndividualDetailsScreen extends StatefulWidget {
//   final TeamMember employee;

//   const EmployeeIndividualDetailsScreen({super.key, required this.employee});

//   @override
//   State<EmployeeIndividualDetailsScreen> createState() =>
//       _EmployeeIndividualDetailsScreenState();
// }

// class _EmployeeIndividualDetailsScreenState
//     extends State<EmployeeIndividualDetailsScreen> {
//   late EmployeeDetailsViewModel _viewModel;

//   @override
//   void initState() {
//     super.initState();
//     _viewModel = EmployeeDetailsViewModel();
//     _loadEmployeeData();
//   }

//   void _loadEmployeeData() async {
//     await _viewModel.loadEmployeeDetails(widget.employee);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider.value(
//       value: _viewModel,
//       child: Scaffold(
//         backgroundColor: Colors.grey.shade50,
//         body: CustomScrollView(
//           slivers: [
//             _buildAppBar(),
//             _buildEmployeeProfile(),
//             _buildAttendanceSection(),
//             _buildProjectsSection(),
//             _buildAttendanceHistory(),
//           ],
//         ),
//       ),
//     );
//   }

//   SliverAppBar _buildAppBar() {
//     return SliverAppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       pinned: true,
//       expandedHeight: 120,
//       flexibleSpace: FlexibleSpaceBar(
//         title: Text(
//           'Employee Details',
//           style: TextStyle(
//             color: Colors.grey.shade800,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Colors.blue.shade50, Colors.purple.shade50],
//             ),
//           ),
//         ),
//       ),
//       leading: IconButton(
//         icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
//         onPressed: () => Navigator.pop(context),
//       ),
//       actions: [
//         Consumer<EmployeeDetailsViewModel>(
//           builder: (context, viewModel, child) {
//             return EmployeeAttendanceDownloadButton(viewModel: viewModel);
//           },
//         ),
//         const SizedBox(width: 8),
//       ],
//     );
//   }

//   SliverToBoxAdapter _buildEmployeeProfile() {
//     return SliverToBoxAdapter(
//       child: Container(
//         margin: const EdgeInsets.all(16),
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Profile Photo
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.blue.shade100,
//                 border: Border.all(color: Colors.blue.shade200, width: 3),
//               ),
//               child: widget.employee.profilePhoto != null
//                   ? CircleAvatar(
//                       backgroundImage: NetworkImage(
//                         widget.employee.profilePhoto!,
//                       ),
//                       radius: 40,
//                     )
//                   : Center(
//                       child: Text(
//                         widget.employee.name.split(' ').map((n) => n[0]).join(),
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.blue.shade700,
//                         ),
//                       ),
//                     ),
//             ),
//             const SizedBox(width: 16),

//             // Employee Information
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.employee.name,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     widget.employee.role,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.blue.shade600,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 8),

//                   // Contact Information
//                   _buildInfoRow(Icons.email_rounded, widget.employee.email),
//                   _buildInfoRow(
//                     Icons.phone_rounded,
//                     widget.employee.phoneNumber,
//                   ),
//                   _buildInfoRow(
//                     Icons.circle_rounded,
//                     'Status: ${widget.employee.status}',
//                     color: _getStatusColor(widget.employee.status),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         children: [
//           Icon(icon, size: 14, color: color ?? Colors.grey.shade600),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: color ?? Colors.grey.shade600,
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'active':
//         return Colors.green;
//       case 'inactive':
//         return Colors.red;
//       case 'on leave':
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }

//   // SliverToBoxAdapter _buildAttendanceSection() {
//   //   return SliverToBoxAdapter(
//   //     child: Consumer<EmployeeDetailsViewModel>(
//   //       builder: (context, viewModel, child) {
//   //         final summary = viewModel.getAttendanceSummary();

//   //         return Container(
//   //           margin: const EdgeInsets.symmetric(horizontal: 16),
//   //           padding: const EdgeInsets.all(20),
//   //           decoration: BoxDecoration(
//   //             color: Colors.white,
//   //             borderRadius: BorderRadius.circular(16),
//   //             boxShadow: [
//   //               BoxShadow(
//   //                 color: Colors.black.withOpacity(0.05),
//   //                 blurRadius: 8,
//   //                 offset: const Offset(0, 2),
//   //               ),
//   //             ],
//   //           ),
//   //           child: Column(
//   //             crossAxisAlignment: CrossAxisAlignment.start,
//   //             children: [
//   //               Row(
//   //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                 children: [
//   //                   Text(
//   //                     'Attendance Overview',
//   //                     style: TextStyle(
//   //                       fontSize: 16,
//   //                       fontWeight: FontWeight.w600,
//   //                       color: Colors.grey.shade800,
//   //                     ),
//   //                   ),
//   //                   Container(
//   //                     padding: const EdgeInsets.symmetric(
//   //                       horizontal: 12,
//   //                       vertical: 6,
//   //                     ),
//   //                     decoration: BoxDecoration(
//   //                       color: Colors.blue.shade50,
//   //                       borderRadius: BorderRadius.circular(12),
//   //                     ),
//   //                     child: Text(
//   //                       '${summary['percentage'] ?? 0}%',
//   //                       style: TextStyle(
//   //                         fontSize: 14,
//   //                         fontWeight: FontWeight.w700,
//   //                         color: Colors.blue.shade700,
//   //                       ),
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //               const SizedBox(height: 16),

//   //               // Attendance Stats
//   //               Row(
//   //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//   //                 children: [
//   //                   _buildStatCard(
//   //                     'Present',
//   //                     summary['present'] ?? 0,
//   //                     Colors.green,
//   //                   ),
//   //                   _buildStatCard(
//   //                     'Leave', // ✅ ABSENT ADDED
//   //                     summary['leave'] ?? 0,
//   //                     Colors.red,
//   //                   ),
//   //                   _buildStatCard(
//   //                     'Absent',
//   //                     summary['absent'] ?? 0,
//   //                     Colors.red,
//   //                   ),
//   //                   _buildStatCard('Late', summary['late'] ?? 0, Colors.orange),
//   //                   _buildStatCard('Total', summary['total'] ?? 0, Colors.blue),
//   //                 ],
//   //               ),
//   //             ],
//   //           ),
//   //         );
//   //       },
//   //     ),
//   //   );
//   // }

//   SliverToBoxAdapter _buildAttendanceSection() {
//     return SliverToBoxAdapter(
//       child: Consumer<EmployeeDetailsViewModel>(
//         builder: (context, viewModel, child) {
//           final summary = viewModel.getAttendanceSummary();

//           return Container(
//             margin: const EdgeInsets.symmetric(horizontal: 16),
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Attendance Overview',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey.shade800,
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         '${summary['percentage'] ?? 0}%',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.blue.shade700,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 // Attendance Stats - ABSENT ADDED
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildStatCard(
//                       'Present',
//                       summary['present'] ?? 0,
//                       Colors.green,
//                     ),
//                     _buildStatCard(
//                       'Absent', // ✅ ABSENT ADDED
//                       summary['absent'] ?? 0,
//                       Colors.red,
//                     ),
//                     _buildStatCard('Late', summary['late'] ?? 0, Colors.orange),
//                     _buildStatCard('Leave', summary['leave'] ?? 0, Colors.blue),
//                   ],
//                 ),
//                 const SizedBox(height: 8),

//                 // Total Days Row
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: AppColors.accentLight,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.calendar_today,
//                         size: 16,
//                         color: Colors.grey.shade600,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         'Total Days: ${summary['total'] ?? 0}',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey.shade700,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildStatCard(String label, int value, Color color) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             shape: BoxShape.circle,
//             border: Border.all(color: color.withOpacity(0.3)),
//           ),
//           child: Text(
//             value.toString(),
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w700,
//               color: color,
//             ),
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 10,
//             color: Colors.grey.shade600,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   // SliverToBoxAdapter _buildProjectsSection() {
//   //   return SliverToBoxAdapter(
//   //     child: Consumer<EmployeeDetailsViewModel>(
//   //       builder: (context, viewModel, child) {
//   //         final employeeDetails = viewModel.employeeDetails;
//   //         final projects = employeeDetails?.allocatedProjects ?? [];

//   //         return Container(
//   //           margin: const EdgeInsets.all(16),
//   //           padding: const EdgeInsets.all(20),
//   //           decoration: BoxDecoration(
//   //             color: Colors.white,
//   //             borderRadius: BorderRadius.circular(16),
//   //             boxShadow: [
//   //               BoxShadow(
//   //                 color: Colors.black.withOpacity(0.05),
//   //                 blurRadius: 8,
//   //                 offset: const Offset(0, 2),
//   //               ),
//   //             ],
//   //           ),
//   //           child: Column(
//   //             crossAxisAlignment: CrossAxisAlignment.start,
//   //             children: [
//   //               Row(
//   //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                 children: [
//   //                   Text(
//   //                     'Allocated Projects',
//   //                     style: TextStyle(
//   //                       fontSize: 16,
//   //                       fontWeight: FontWeight.w600,
//   //                       color: Colors.grey.shade800,
//   //                     ),
//   //                   ),
//   //                   Container(
//   //                     padding: const EdgeInsets.symmetric(
//   //                       horizontal: 8,
//   //                       vertical: 4,
//   //                     ),
//   //                     decoration: BoxDecoration(
//   //                       color: Colors.purple.shade50,
//   //                       borderRadius: BorderRadius.circular(8),
//   //                     ),
//   //                     child: Text(
//   //                       '${projects.length} Projects',
//   //                       style: TextStyle(
//   //                         fontSize: 12,
//   //                         color: Colors.purple.shade700,
//   //                         fontWeight: FontWeight.w600,
//   //                       ),
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //               const SizedBox(height: 12),

//   //               if (projects.isEmpty)
//   //                 _buildEmptyState(
//   //                   'No projects allocated',
//   //                   Icons.work_off_rounded,
//   //                 )
//   //               else
//   //                 Column(
//   //                   children: projects
//   //                       .map((project) => _buildProjectItem(project))
//   //                       .toList(),
//   //                 ),
//   //             ],
//   //           ),
//   //         );
//   //       },
//   //     ),
//   //   );
//   // }

//   SliverToBoxAdapter _buildProjectsSection() {
//     return SliverToBoxAdapter(
//       child: Consumer<EmployeeDetailsViewModel>(
//         builder: (context, viewModel, child) {
//           // Use the existing getEmployeeProjects method from your ViewModel
//           final projects = viewModel.getEmployeeProjects();

//           return Container(
//             margin: const EdgeInsets.all(16),
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Allocated Projects',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey.shade800,
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.purple.shade50,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         '${projects.length} Projects',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.purple.shade700,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),

//                 if (projects.isEmpty)
//                   _buildEmptyState(
//                     '${viewModel.employee?.name ?? 'Employee'} is not assigned to any projects',
//                     Icons.work_off_rounded,
//                   )
//                 else
//                   Column(
//                     children: projects
//                         .map((project) => _buildProjectItem(project))
//                         .toList(),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildProjectItem(String project) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.work_rounded, size: 16, color: Colors.blue.shade600),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               project,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey.shade800,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//             decoration: BoxDecoration(
//               color: Colors.green.shade50,
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Text(
//               'Active',
//               style: TextStyle(
//                 fontSize: 10,
//                 color: Colors.green.shade700,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   SliverToBoxAdapter _buildAttendanceHistory() {
//     return SliverToBoxAdapter(
//       child: Consumer<EmployeeDetailsViewModel>(
//         builder: (context, viewModel, child) {
//           return Container(
//             margin: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 12),
//                   child: Text(
//                     'Attendance History',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey.shade800,
//                     ),
//                   ),
//                 ),
//                 AttendanceHistoryList(viewModel: viewModel),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildEmptyState(String message, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           Icon(icon, size: 40, color: Colors.grey.shade400),
//           const SizedBox(height: 8),
//           Text(
//             message,
//             style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _viewModel.dispose();
//     super.dispose();
//   }
// }
