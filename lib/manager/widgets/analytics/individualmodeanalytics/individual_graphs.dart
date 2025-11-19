import 'package:AttendanceApp/manager/models/team_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
import '../../../view_models/projectviewmodels/project_view_model.dart';
import '../../../views/managerviews/individualmodeview/employee_individual_details_screen.dart';

class IndividualGraphs extends StatefulWidget {
  final AttendanceAnalyticsViewModel viewModel;
  final ProjectViewModel projectViewModel;

  const IndividualGraphs({
    super.key,
    required this.viewModel,
    required this.projectViewModel,
  });

  @override
  State<IndividualGraphs> createState() => _IndividualGraphsState();
}

class _IndividualGraphsState extends State<IndividualGraphs> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _nameSort = 'A-Z';
  String _projectSort = 'A-Z';
  int? _expandedEmployeeIndex;

  List<dynamic> get _filteredTeamMembers {
    List<dynamic> members = List.from(widget.viewModel.teamMembers);

    if (_searchQuery.isNotEmpty) {
      members = members
          .where(
            (member) =>
                member.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                member.role.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                member.email.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (_nameSort == 'A-Z') {
      members.sort((a, b) => a.name.compareTo(b.name));
    } else if (_nameSort == 'Z-A') {
      members.sort((a, b) => b.name.compareTo(a.name));
    }

    return members;
  }

  List<String> _getEmployeeProjects(String employeeEmail) {
    final allProjects = widget.projectViewModel.projects;
    final employeeProjects = <String>[];

    for (final project in allProjects) {
      final isAssigned = project.assignedTeam.any(
        (member) => member.email == employeeEmail,
      );
      if (isAssigned) {
        employeeProjects.add(project.name);
      }
    }

    return employeeProjects.isNotEmpty
        ? employeeProjects
        : ['No Projects Assigned'];
  }

  Map<String, dynamic> _getEmployeeAttendance(String employeeEmail) {
    return widget.viewModel.getPeriodAttendanceData(employeeEmail);
  }

  String _getCurrentStatus(Map<String, dynamic> attendance) {
    final present = attendance['present'] ?? 0;
    final absent = attendance['absent'] ?? 0;
    final leave = attendance['leave'] ?? 0;
    final late = attendance['late'] ?? 0;

    if (present > 0) return 'Present';
    if (late > 0) return 'Late';
    if (leave > 0) return 'Leave';
    if (absent > 0) return 'Absent';
    return 'No Data';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Late':
        return Colors.orange;
      case 'Leave':
        return Colors.blue;
      case 'Absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final analytics = widget.viewModel.analytics;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (analytics == null) return const SizedBox();

    return Column(
      children: [
        _buildHeader(isDark),
        const SizedBox(height: 16),
        _buildSearchSection(isDark),
        const SizedBox(height: 16),
        ..._filteredTeamMembers.asMap().entries.map((entry) {
          final index = entry.key;
          final member = entry.value;
          final projects = _getEmployeeProjects(member.email);
          final attendance = _getEmployeeAttendance(member.email);
          return _buildEmployeeCard(
            index,
            member,
            projects,
            attendance,
            isDark,
          );
        }),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    final period = widget.viewModel.selectedPeriod;
    final selectedDate = widget.viewModel.selectedDate;

    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.blue.shade800 : Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_alt_rounded,
              color: isDark ? Colors.blue.shade200 : Colors.blue.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Employee Overview - ${widget.viewModel.getPeriodDisplayName(period)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getPeriodDateRange(period, selectedDate),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.blue.shade800 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.blue.shade600 : Colors.blue.shade200,
              ),
            ),
            child: Text(
              '${_filteredTeamMembers.length} Employees',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white : Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPeriodDateRange(String period, DateTime selectedDate) {
    switch (period) {
      case 'daily':
        return 'Date: ${_formatDate(selectedDate)}';
      case 'weekly':
        final weekStart = widget.viewModel.getFirstDayOfWeek(selectedDate);
        final weekEnd = weekStart.add(const Duration(days: 6));
        return 'Week: ${_formatDate(weekStart)} - ${_formatDate(weekEnd)}';
      case 'monthly':
        return 'Month: ${_formatMonth(selectedDate)}';
      case 'quarterly':
        final quarter = ((selectedDate.month - 1) ~/ 3) + 1;
        return 'Quarter: Q$quarter ${selectedDate.year}';
      default:
        return 'Period: ${widget.viewModel.getPeriodDisplayName(period)}';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatMonth(DateTime date) {
    return '${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
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

  Widget _buildSearchSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Row(
            children: [
              // Search Field
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(
                        Icons.search,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search employees...',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade500,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade500,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Sort Buttons
              Row(
                children: [
                  // Name Sort
                  _buildSortButton('Name', _nameSort, () {
                    setState(() {
                      _nameSort = _nameSort == 'A-Z' ? 'Z-A' : 'A-Z';
                    });
                  }, isDark),

                  const SizedBox(width: 8),

                  // Project Sort
                  _buildSortButton('Project', _projectSort, () {
                    setState(() {
                      _projectSort = _projectSort == 'A-Z' ? 'Z-A' : 'A-Z';
                    });
                  }, isDark),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton(
    String label,
    String currentSort,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  currentSort == 'A-Z'
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 16,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(
    int index,
    dynamic member,
    List<String> projects,
    Map<String, dynamic> attendance,
    bool isDark,
  ) {
    final isExpanded = _expandedEmployeeIndex == index;
    final currentStatus = _getCurrentStatus(attendance);
    final statusColor = _getStatusColor(currentStatus);

    return GestureDetector(
      onTap: () {
        _navigateToEmployeeDetails(context, member);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with tap feedback
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _navigateToEmployeeDetails(context, member);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: isDark
                            ? Colors.blue.shade800
                            : Colors.blue.shade100,
                        child: Text(
                          member.name.split(' ').map((n) => n[0]).join(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.blue.shade200
                                : Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Employee Details
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                member.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    currentStatus,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          member.role,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Info Chips
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _buildCompactInfoChip(
                                  Icons.access_time_rounded,
                                  '${attendance['checkin']} - ${attendance['checkout']}',
                                  isDark,
                                ),
                                _buildCompactInfoChip(
                                  Icons.work_rounded,
                                  '${projects.length} Projects',
                                  isDark,
                                ),
                                _buildCompactInfoChip(
                                  Icons.calendar_today_rounded,
                                  '${attendance['period']}',
                                  isDark,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Projects List
                  Expanded(
                    flex: 2,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Projects:',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: projects.map((project) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 2),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.blue.shade800
                                          : Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      project,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: isDark
                                            ? Colors.blue.shade200
                                            : Colors.blue.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.right,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Expand Button
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                  ),
                ),
              ),
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  'View ${widget.viewModel.selectedPeriod} Attendance Details',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
                  size: 18,
                ),
                onTap: () {
                  setState(() {
                    _expandedEmployeeIndex = isExpanded ? null : index;
                  });
                },
              ),
            ),

            // Expanded Chart
            if (isExpanded)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade100,
                    ),
                  ),
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                ),
                child: Column(
                  children: [
                    Text(
                      '${widget.viewModel.selectedPeriod.toUpperCase()} Attendance Distribution - ${member.name}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: _buildAttendanceChart(attendance),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInfoChip(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 9,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceChart(Map<String, dynamic> attendance) {
    final present = attendance['present'] ?? 0;
    final absent = attendance['absent'] ?? 0;
    final leave = attendance['leave'] ?? 0;
    final late = attendance['late'] ?? 0;
    final total = present + absent + leave + late;

    if (total == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 40,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'No attendance data for ${widget.viewModel.selectedPeriod}',
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Create sections ensuring all four are visible
    final sections = <PieChartSectionData>[];

    // Always add all four sections with minimum values
    sections.add(_buildChartSection('Present', present, total, Colors.green));
    sections.add(_buildChartSection('Late', late, total, Colors.orange));
    sections.add(_buildChartSection('Leave', leave, total, Colors.blue));
    sections.add(_buildChartSection('Absent', absent, total, Colors.red));

    return PieChart(
      PieChartData(sections: sections, centerSpaceRadius: 30, sectionsSpace: 1),
    );
  }

  PieChartSectionData _buildChartSection(
    String label,
    int value,
    int total,
    Color color,
  ) {
    final percentage = total > 0 ? ((value / total) * 100).round() : 0;

    // Ensure all sections are visible with minimum value
    final displayValue = value == 0 ? 0.1 : value.toDouble();

    return PieChartSectionData(
      color: color,
      value: displayValue,
      title: '$percentage%',
      radius: 40,
      titleStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  void _navigateToEmployeeDetails(BuildContext context, dynamic member) {
    try {
      // Convert the member to TeamMember with all required parameters
      final teamMember = TeamMember(
        id: member.id != null ? int.tryParse(member.id.toString()) : null,
        name: member.name ?? 'Unknown Employee',
        email: member.email ?? '',
        role: member.role ?? 'Employee',
        profilePhoto: member.profilePhoto,
        status: member.status ?? 'Active',
        phoneNumber: member.phoneNumber ?? 'Not provided',
        joinDate: member.joinDate is DateTime
            ? member.joinDate
            : DateTime.now(), // Default to current date
        department: member.department ?? 'General', // Default department
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EmployeeIndividualDetailsScreen(employee: teamMember),
        ),
      );
    } catch (e) {
      print('Error in navigation: $e');

      // Fallback with minimal required data
      final fallbackMember = TeamMember(
        name: member.name?.toString() ?? 'Employee',
        email: member.email?.toString() ?? '',
        role: member.role?.toString() ?? 'Team Member',
        status: 'Active',
        phoneNumber: 'Not provided',
        joinDate: DateTime.now(),
        department: 'General',
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EmployeeIndividualDetailsScreen(employee: fallbackMember),
        ),
      );
    }
  }
}

// import 'package:attendanceapp/models/team_model.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:attendanceapp/view_models/projectviewmodels/project_view_model.dart';
// import 'package:attendanceapp/views/managerviews/individualmodeview/employee_individual_details_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// class IndividualGraphs extends StatefulWidget {
//   final AttendanceAnalyticsViewModel viewModel;
//   final ProjectViewModel projectViewModel;

//   const IndividualGraphs({
//     super.key,
//     required this.viewModel,
//     required this.projectViewModel,
//   });

//   @override
//   State<IndividualGraphs> createState() => _IndividualGraphsState();
// }

// class _IndividualGraphsState extends State<IndividualGraphs> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   String _nameSort = 'A-Z';
//   String _projectSort = 'A-Z';
//   int? _expandedEmployeeIndex;

//   List<dynamic> get _filteredTeamMembers {
//     List<dynamic> members = List.from(widget.viewModel.teamMembers);

//     if (_searchQuery.isNotEmpty) {
//       members = members
//           .where(
//             (member) =>
//                 member.name.toLowerCase().contains(
//                   _searchQuery.toLowerCase(),
//                 ) ||
//                 member.role.toLowerCase().contains(
//                   _searchQuery.toLowerCase(),
//                 ) ||
//                 member.email.toLowerCase().contains(_searchQuery.toLowerCase()),
//           )
//           .toList();
//     }

//     if (_nameSort == 'A-Z') {
//       members.sort((a, b) => a.name.compareTo(b.name));
//     } else if (_nameSort == 'Z-A') {
//       members.sort((a, b) => b.name.compareTo(a.name));
//     }

//     return members;
//   }

//   List<String> _getEmployeeProjects(String employeeEmail) {
//     final allProjects = widget.projectViewModel.projects;
//     final employeeProjects = <String>[];

//     for (final project in allProjects) {
//       final isAssigned = project.assignedTeam.any(
//         (member) => member.email == employeeEmail,
//       );
//       if (isAssigned) {
//         employeeProjects.add(project.name);
//       }
//     }

//     return employeeProjects.isNotEmpty
//         ? employeeProjects
//         : ['No Projects Assigned'];
//   }

//   Map<String, dynamic> _getEmployeeAttendance(String employeeEmail) {
//     return widget.viewModel.getPeriodAttendanceData(employeeEmail);
//   }

//   String _getCurrentStatus(Map<String, dynamic> attendance) {
//     final present = attendance['present'] ?? 0;
//     final absent = attendance['absent'] ?? 0;
//     final leave = attendance['leave'] ?? 0;
//     final late = attendance['late'] ?? 0;

//     if (present > 0) return 'Present';
//     if (late > 0) return 'Late';
//     if (leave > 0) return 'Leave';
//     if (absent > 0) return 'Absent';
//     return 'No Data';
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'Present':
//         return Colors.green;
//       case 'Late':
//         return Colors.yellow.shade700;
//       case 'Leave':
//         return Colors.orange;
//       case 'Absent':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final analytics = widget.viewModel.analytics;
//     if (analytics == null) return const SizedBox();

//     return Column(
//       children: [
//         _buildHeader(),
//         const SizedBox(height: 16),
//         _buildSearchSection(),
//         const SizedBox(height: 16),
//         ..._filteredTeamMembers.asMap().entries.map((entry) {
//           final index = entry.key;
//           final member = entry.value;
//           final projects = _getEmployeeProjects(member.email);
//           final attendance = _getEmployeeAttendance(member.email);
//           return _buildEmployeeCard(index, member, projects, attendance);
//         }),
//       ],
//     );
//   }

//   Widget _buildHeader() {
//     final period = widget.viewModel.selectedPeriod;
//     final selectedDate = widget.viewModel.selectedDate;

//     return Container(
//       padding: const EdgeInsets.all(20),
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
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.people_alt_rounded,
//               color: Colors.blue.shade600,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Employee Overview - ${widget.viewModel.getPeriodDisplayName(period)}',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey.shade800,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   _getPeriodDateRange(period, selectedDate),
//                   style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.blue.shade200),
//             ),
//             child: Text(
//               '${_filteredTeamMembers.length} Employees',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.blue.shade700,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getPeriodDateRange(String period, DateTime selectedDate) {
//     switch (period) {
//       case 'daily':
//         return 'Date: ${_formatDate(selectedDate)}';
//       case 'weekly':
//         final weekStart = widget.viewModel.getFirstDayOfWeek(selectedDate);
//         final weekEnd = weekStart.add(const Duration(days: 6));
//         return 'Week: ${_formatDate(weekStart)} - ${_formatDate(weekEnd)}';
//       case 'monthly':
//         return 'Month: ${_formatMonth(selectedDate)}';
//       case 'quarterly':
//         final quarter = ((selectedDate.month - 1) ~/ 3) + 1;
//         return 'Quarter: Q$quarter ${selectedDate.year}';
//       default:
//         return 'Period: ${widget.viewModel.getPeriodDisplayName(period)}';
//     }
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   String _formatMonth(DateTime date) {
//     return '${_getMonthName(date.month)} ${date.year}';
//   }

//   String _getMonthName(int month) {
//     const months = [
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

//   // Widget _buildSearchSection() {
//   //   return Container(
//   //     padding: const EdgeInsets.all(20),
//   //     decoration: BoxDecoration(
//   //       color: Colors.white,
//   //       borderRadius: BorderRadius.circular(12),
//   //       boxShadow: [
//   //         BoxShadow(
//   //           color: Colors.black.withOpacity(0.05),
//   //           blurRadius: 8,
//   //           offset: const Offset(0, 2),
//   //         ),
//   //       ],
//   //     ),
//   //     child: Column(
//   //       children: [
//   //         Row(
//   //           children: [
//   //             // Search Field
//   //             Expanded(
//   //               child: Container(
//   //                 height: 48,
//   //                 decoration: BoxDecoration(
//   //                   color: Colors.grey.shade50,
//   //                   borderRadius: BorderRadius.circular(8),
//   //                   border: Border.all(color: Colors.grey.shade200),
//   //                 ),
//   //                 child: Row(
//   //                   children: [
//   //                     const SizedBox(width: 16),
//   //                     Icon(
//   //                       Icons.search_rounded,
//   //                       color: Colors.grey.shade500,
//   //                       size: 20,
//   //                     ),
//   //                     const SizedBox(width: 12),
//   //                     Expanded(
//   //                       child: TextField(
//   //                         controller: _searchController,
//   //                         style: const TextStyle(
//   //                           fontSize: 14,
//   //                           color: Colors.black87,
//   //                         ),
//   //                         decoration: InputDecoration(
//   //                           hintText:
//   //                               'Search employees by name, role, or email...',
//   //                           hintStyle: TextStyle(
//   //                             color: Colors.grey.shade500,
//   //                             fontSize: 14,
//   //                           ),
//   //                           border: InputBorder.none,
//   //                           contentPadding: EdgeInsets.zero,
//   //                         ),
//   //                         onChanged: (value) {
//   //                           setState(() {
//   //                             _searchQuery = value;
//   //                           });
//   //                         },
//   //                       ),
//   //                     ),
//   //                     if (_searchQuery.isNotEmpty)
//   //                       IconButton(
//   //                         icon: Icon(
//   //                           Icons.clear_rounded,
//   //                           color: Colors.grey.shade500,
//   //                           size: 18,
//   //                         ),
//   //                         onPressed: () {
//   //                           setState(() {
//   //                             _searchController.clear();
//   //                             _searchQuery = '';
//   //                           });
//   //                         },
//   //                       ),
//   //                     const SizedBox(width: 8),
//   //                   ],
//   //                 ),
//   //               ),
//   //             ),

//   //             const SizedBox(width: 12),

//   //             // Sort by Name Button
//   //             Container(
//   //               height: 48,
//   //               decoration: BoxDecoration(
//   //                 color: Colors.grey.shade50,
//   //                 borderRadius: BorderRadius.circular(8),
//   //                 border: Border.all(color: Colors.grey.shade200),
//   //               ),
//   //               child: Material(
//   //                 color: Colors.transparent,
//   //                 child: InkWell(
//   //                   borderRadius: BorderRadius.circular(8),
//   //                   onTap: () {
//   //                     setState(() {
//   //                       _nameSort = _nameSort == 'A-Z' ? 'Z-A' : 'A-Z';
//   //                     });
//   //                   },
//   //                   child: Padding(
//   //                     padding: const EdgeInsets.symmetric(horizontal: 12),
//   //                     child: Row(
//   //                       children: [
//   //                         Icon(
//   //                           _nameSort == 'A-Z'
//   //                               ? Icons.arrow_upward_rounded
//   //                               : Icons.arrow_downward_rounded,
//   //                           size: 16,
//   //                           color: Colors.grey.shade600,
//   //                         ),
//   //                         const SizedBox(width: 6),
//   //                         Text(
//   //                           'Name',
//   //                           style: TextStyle(
//   //                             fontSize: 12,
//   //                             color: Colors.grey.shade700,
//   //                             fontWeight: FontWeight.w500,
//   //                           ),
//   //                         ),
//   //                       ],
//   //                     ),
//   //                   ),
//   //                 ),
//   //               ),
//   //             ),

//   //             const SizedBox(width: 8),

//   //             // Sort by Project Button
//   //             Container(
//   //               height: 48,
//   //               decoration: BoxDecoration(
//   //                 color: Colors.grey.shade50,
//   //                 borderRadius: BorderRadius.circular(8),
//   //                 border: Border.all(color: Colors.grey.shade200),
//   //               ),
//   //               child: Material(
//   //                 color: Colors.transparent,
//   //                 child: InkWell(
//   //                   borderRadius: BorderRadius.circular(8),
//   //                   onTap: () {
//   //                     setState(() {
//   //                       _projectSort = _projectSort == 'A-Z' ? 'Z-A' : 'A-Z';
//   //                     });
//   //                   },
//   //                   child: Padding(
//   //                     padding: const EdgeInsets.symmetric(horizontal: 12),
//   //                     child: Row(
//   //                       children: [
//   //                         Icon(
//   //                           _projectSort == 'A-Z'
//   //                               ? Icons.arrow_upward_rounded
//   //                               : Icons.arrow_downward_rounded,
//   //                           size: 16,
//   //                           color: Colors.grey.shade600,
//   //                         ),
//   //                         const SizedBox(width: 6),
//   //                         Text(
//   //                           'Project',
//   //                           style: TextStyle(
//   //                             fontSize: 12,
//   //                             color: Colors.grey.shade700,
//   //                             fontWeight: FontWeight.w500,
//   //                           ),
//   //                         ),
//   //                       ],
//   //                     ),
//   //                   ),
//   //                 ),
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   Widget _buildSearchSection() {
//     return Container(
//       padding: const EdgeInsets.all(20),
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
//       child: Column(
//         children: [
//           Row(
//             children: [
//               // Search Field
//               Expanded(
//                 child: Container(
//                   height: 44,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade50,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.grey.shade300),
//                   ),
//                   child: Row(
//                     children: [
//                       const SizedBox(width: 12),
//                       Icon(Icons.search, color: Colors.grey.shade500, size: 20),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: TextField(
//                           controller: _searchController,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.black87,
//                           ),
//                           decoration: InputDecoration(
//                             hintText: 'Search employees...',
//                             hintStyle: TextStyle(
//                               color: Colors.grey.shade500,
//                               fontSize: 14,
//                             ),
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.zero,
//                           ),
//                           onChanged: (value) {
//                             setState(() {
//                               _searchQuery = value;
//                             });
//                           },
//                         ),
//                       ),
//                       if (_searchQuery.isNotEmpty)
//                         IconButton(
//                           icon: Icon(
//                             Icons.clear,
//                             color: Colors.grey.shade500,
//                             size: 18,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _searchController.clear();
//                               _searchQuery = '';
//                             });
//                           },
//                         ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(width: 12),

//               // Sort Buttons
//               Row(
//                 children: [
//                   // Name Sort
//                   _buildSortButton('Name', _nameSort, () {
//                     setState(() {
//                       _nameSort = _nameSort == 'A-Z' ? 'Z-A' : 'A-Z';
//                     });
//                   }),

//                   const SizedBox(width: 8),

//                   // Project Sort
//                   _buildSortButton('Project', _projectSort, () {
//                     setState(() {
//                       _projectSort = _projectSort == 'A-Z' ? 'Z-A' : 'A-Z';
//                     });
//                   }),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSortButton(
//     String label,
//     String currentSort,
//     VoidCallback onTap,
//   ) {
//     return Container(
//       height: 44,
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(8),
//           onTap: onTap,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Row(
//               children: [
//                 Icon(
//                   currentSort == 'A-Z'
//                       ? Icons.arrow_upward
//                       : Icons.arrow_downward,
//                   size: 16,
//                   color: Colors.grey.shade700,
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey.shade700,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmployeeCard(
//     int index,
//     dynamic member,
//     List<String> projects,
//     Map<String, dynamic> attendance,
//   ) {
//     final isExpanded = _expandedEmployeeIndex == index;
//     final currentStatus = _getCurrentStatus(attendance);
//     final statusColor = _getStatusColor(currentStatus);

//     return GestureDetector(
//       onTap: () {
//         _navigateToEmployeeDetails(context, member);
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Avatar with tap feedback
//                   Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       onTap: () {
//                         _navigateToEmployeeDetails(context, member);
//                       },
//                       borderRadius: BorderRadius.circular(20),
//                       child: CircleAvatar(
//                         radius: 20,
//                         backgroundColor: Colors.blue.shade100,
//                         child: Text(
//                           member.name.split(' ').map((n) => n[0]).join(),
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.blue.shade700,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),

//                   // Employee Details - FIXED LAYOUT
//                   Expanded(
//                     flex: 3,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 member.name,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.black87,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             // Status Badge
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: statusColor.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Container(
//                                     width: 6,
//                                     height: 6,
//                                     decoration: BoxDecoration(
//                                       color: statusColor,
//                                       shape: BoxShape.circle,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     currentStatus,
//                                     style: TextStyle(
//                                       fontSize: 10,
//                                       color: statusColor,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           member.role,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),

//                         // Info Chips - FIXED: Using responsive layout
//                         LayoutBuilder(
//                           builder: (context, constraints) {
//                             return Wrap(
//                               spacing: 6,
//                               runSpacing: 6,
//                               children: [
//                                 _buildCompactInfoChip(
//                                   Icons.access_time_rounded,
//                                   '${attendance['checkin']} - ${attendance['checkout']}',
//                                 ),
//                                 _buildCompactInfoChip(
//                                   Icons.work_rounded,
//                                   '${projects.length} Projects',
//                                 ),
//                                 _buildCompactInfoChip(
//                                   Icons.calendar_today_rounded,
//                                   '${attendance['period']}',
//                                 ),
//                               ],
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(width: 12),

//                   // Projects List - FIXED: Better width management
//                   Expanded(
//                     flex: 2,
//                     child: Container(
//                       constraints: BoxConstraints(maxHeight: 100),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(
//                             'Projects:',
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: Colors.grey.shade600,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Expanded(
//                             child: SingleChildScrollView(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: projects.map((project) {
//                                   return Container(
//                                     margin: const EdgeInsets.only(bottom: 2),
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 6,
//                                       vertical: 2,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.blue.shade50,
//                                       borderRadius: BorderRadius.circular(4),
//                                     ),
//                                     child: Text(
//                                       project,
//                                       style: TextStyle(
//                                         fontSize: 9,
//                                         color: Colors.blue.shade700,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                       textAlign: TextAlign.right,
//                                       overflow: TextOverflow.ellipsis,
//                                       maxLines: 1,
//                                     ),
//                                   );
//                                 }).toList(),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Expand Button
//             Container(
//               decoration: BoxDecoration(
//                 border: Border(top: BorderSide(color: Colors.grey.shade100)),
//               ),
//               child: ListTile(
//                 dense: true,
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//                 title: Text(
//                   'View ${widget.viewModel.selectedPeriod} Attendance Details',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.blue.shade600,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 trailing: Icon(
//                   isExpanded ? Icons.expand_less : Icons.expand_more,
//                   color: Colors.blue.shade600,
//                   size: 18,
//                 ),
//                 onTap: () {
//                   setState(() {
//                     _expandedEmployeeIndex = isExpanded ? null : index;
//                   });
//                 },
//               ),
//             ),

//             // Expanded Chart
//             if (isExpanded)
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   border: Border(top: BorderSide(color: Colors.grey.shade100)),
//                   color: Colors.grey.shade50,
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       '${widget.viewModel.selectedPeriod.toUpperCase()} Attendance Distribution - ${member.name}',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey.shade700,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     SizedBox(
//                       height: 180,
//                       child: _buildAttendanceChart(attendance),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCompactInfoChip(IconData icon, String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 10, color: Colors.grey.shade600),
//           const SizedBox(width: 3),
//           Flexible(
//             child: Text(
//               text,
//               style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAttendanceChart(Map<String, dynamic> attendance) {
//     final present = attendance['present'] ?? 0;
//     final absent = attendance['absent'] ?? 0;
//     final leave = attendance['leave'] ?? 0;
//     final late = attendance['late'] ?? 0;
//     final total = present + absent + leave + late;

//     if (total == 0) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.bar_chart_rounded,
//               size: 40,
//               color: Colors.grey.shade400,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'No attendance data for ${widget.viewModel.selectedPeriod}',
//               style: TextStyle(color: Colors.grey.shade500),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       );
//     }

//     // Create sections ensuring all four are visible
//     final sections = <PieChartSectionData>[];

//     // Always add all four sections with minimum values
//     sections.add(_buildChartSection('Present', present, total, Colors.green));
//     sections.add(_buildChartSection('Late', late, total, Colors.orange));
//     sections.add(_buildChartSection('Leave', leave, total, Colors.blue));
//     sections.add(_buildChartSection('Absent', absent, total, Colors.red));

//     return PieChart(
//       PieChartData(sections: sections, centerSpaceRadius: 30, sectionsSpace: 1),
//     );
//   }

//   PieChartSectionData _buildChartSection(
//     String label,
//     int value,
//     int total,
//     Color color,
//   ) {
//     final percentage = total > 0 ? ((value / total) * 100).round() : 0;

//     // Ensure all sections are visible with minimum value
//     final displayValue = value == 0 ? 0.1 : value.toDouble();

//     return PieChartSectionData(
//       color: color,
//       value: displayValue,
//       title: '$percentage%',
//       radius: 40,
//       titleStyle: const TextStyle(
//         fontSize: 11,
//         fontWeight: FontWeight.w600,
//         color: Colors.white,
//       ),
//     );
//   }

//   void _navigateToEmployeeDetails(BuildContext context, dynamic member) {
//     try {
//       // Convert the member to TeamMember with all required parameters
//       final teamMember = TeamMember(
//         id: member.id != null ? int.tryParse(member.id.toString()) : null,
//         name: member.name ?? 'Unknown Employee',
//         email: member.email ?? '',
//         role: member.role ?? 'Employee',
//         profilePhoto: member.profilePhoto,
//         status: member.status ?? 'Active',
//         phoneNumber: member.phoneNumber ?? 'Not provided',
//         joinDate: member.joinDate is DateTime
//             ? member.joinDate
//             : DateTime.now(), // Default to current date
//         department: member.department ?? 'General', // Default department
//       );

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) =>
//               EmployeeIndividualDetailsScreen(employee: teamMember),
//         ),
//       );
//     } catch (e) {
//       print('Error in navigation: $e');

//       // Fallback with minimal required data
//       final fallbackMember = TeamMember(
//         name: member.name?.toString() ?? 'Employee',
//         email: member.email?.toString() ?? '',
//         role: member.role?.toString() ?? 'Team Member',
//         status: 'Active',
//         phoneNumber: 'Not provided',
//         joinDate: DateTime.now(),
//         department: 'General',
//       );

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) =>
//               EmployeeIndividualDetailsScreen(employee: fallbackMember),
//         ),
//       );
//     }
//   }
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:attendanceapp/view_models/projectviewmodels/project_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// class IndividualGraphs extends StatefulWidget {
//   final AttendanceAnalyticsViewModel viewModel;
//   final ProjectViewModel projectViewModel;

//   const IndividualGraphs({
//     super.key,
//     required this.viewModel,
//     required this.projectViewModel,
//   });

//   @override
//   State<IndividualGraphs> createState() => _IndividualGraphsState();
// }

// class _IndividualGraphsState extends State<IndividualGraphs> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   String _nameSort = 'A-Z';
//   String _projectSort = 'A-Z';
//   int? _expandedEmployeeIndex;

//   List<dynamic> get _filteredTeamMembers {
//     List<dynamic> members = List.from(widget.viewModel.teamMembers);

//     if (_searchQuery.isNotEmpty) {
//       members = members
//           .where(
//             (member) =>
//                 member.name.toLowerCase().contains(
//                   _searchQuery.toLowerCase(),
//                 ) ||
//                 member.role.toLowerCase().contains(
//                   _searchQuery.toLowerCase(),
//                 ) ||
//                 member.email.toLowerCase().contains(_searchQuery.toLowerCase()),
//           )
//           .toList();
//     }

//     if (_nameSort == 'A-Z') {
//       members.sort((a, b) => a.name.compareTo(b.name));
//     } else if (_nameSort == 'Z-A') {
//       members.sort((a, b) => b.name.compareTo(a.name));
//     }

//     return members;
//   }

//   List<String> _getEmployeeProjects(String employeeEmail) {
//     final allProjects = widget.projectViewModel.projects;
//     final employeeProjects = <String>[];

//     for (final project in allProjects) {
//       final isAssigned = project.assignedTeam.any(
//         (member) => member.email == employeeEmail,
//       );
//       if (isAssigned) {
//         employeeProjects.add(project.name);
//       }
//     }

//     return employeeProjects.isNotEmpty
//         ? employeeProjects
//         : ['No Projects Assigned'];
//   }

//   Map<String, dynamic> _getEmployeeAttendance(String employeeEmail) {
//     return widget.viewModel.getPeriodAttendanceData(employeeEmail);
//   }

//   String _getCurrentStatus(Map<String, dynamic> attendance) {
//     final present = attendance['present'] ?? 0;
//     final absent = attendance['absent'] ?? 0;
//     final leave = attendance['leave'] ?? 0;
//     final late = attendance['late'] ?? 0;

//     if (present > 0) return 'Present';
//     if (late > 0) return 'Late';
//     if (leave > 0) return 'Leave';
//     if (absent > 0) return 'Absent';
//     return 'No Data';
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'Present':
//         return Colors.green;
//       case 'Late':
//         return Colors.yellow.shade700;
//       case 'Leave':
//         return Colors.orange;
//       case 'Absent':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final analytics = widget.viewModel.analytics;
//     if (analytics == null) return const SizedBox();

//     return Column(
//       children: [
//         _buildHeader(),
//         const SizedBox(height: 16),
//         _buildSearchSection(),
//         const SizedBox(height: 16),
//         ..._filteredTeamMembers.asMap().entries.map((entry) {
//           final index = entry.key;
//           final member = entry.value;
//           final projects = _getEmployeeProjects(member.email);
//           final attendance = _getEmployeeAttendance(member.email);
//           return _buildEmployeeCard(index, member, projects, attendance);
//         }),
//       ],
//     );
//   }

//   Widget _buildHeader() {
//     final period = widget.viewModel.selectedPeriod;
//     final selectedDate = widget.viewModel.selectedDate;

//     return Container(
//       padding: const EdgeInsets.all(20),
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
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.people_alt_rounded,
//               color: Colors.blue.shade600,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Employee Overview - ${widget.viewModel.getPeriodDisplayName(period)}',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey.shade800,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   _getPeriodDateRange(period, selectedDate),
//                   style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.blue.shade200),
//             ),
//             child: Text(
//               '${_filteredTeamMembers.length} Employees',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.blue.shade700,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getPeriodDateRange(String period, DateTime selectedDate) {
//     switch (period) {
//       case 'daily':
//         return 'Date: ${_formatDate(selectedDate)}';
//       case 'weekly':
//         final weekStart = widget.viewModel.getFirstDayOfWeek(selectedDate);
//         final weekEnd = weekStart.add(const Duration(days: 6));
//         return 'Week: ${_formatDate(weekStart)} - ${_formatDate(weekEnd)}';
//       case 'monthly':
//         return 'Month: ${_formatMonth(selectedDate)}';
//       case 'quarterly':
//         final quarter = ((selectedDate.month - 1) ~/ 3) + 1;
//         return 'Quarter: Q$quarter ${selectedDate.year}';
//       default:
//         return 'Period: ${widget.viewModel.getPeriodDisplayName(period)}';
//     }
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   String _formatMonth(DateTime date) {
//     return '${_getMonthName(date.month)} ${date.year}';
//   }

//   String _getMonthName(int month) {
//     const months = [
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

//   Widget _buildSearchSection() {
//     return Container(
//       padding: const EdgeInsets.all(20),
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
//       child: Column(
//         children: [
//           Container(
//             height: 48,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: Row(
//               children: [
//                 const SizedBox(width: 16),
//                 Icon(
//                   Icons.search_rounded,
//                   color: Colors.grey.shade500,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     style: const TextStyle(fontSize: 14, color: Colors.black87),
//                     decoration: InputDecoration(
//                       hintText: 'Search employees by name, role, or email...',
//                       hintStyle: TextStyle(
//                         color: Colors.grey.shade500,
//                         fontSize: 14,
//                       ),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.zero,
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         _searchQuery = value;
//                       });
//                     },
//                   ),
//                 ),
//                 if (_searchQuery.isNotEmpty)
//                   IconButton(
//                     icon: Icon(
//                       Icons.clear_rounded,
//                       color: Colors.grey.shade500,
//                       size: 18,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _searchController.clear();
//                         _searchQuery = '';
//                       });
//                     },
//                   ),
//                 const SizedBox(width: 8),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               _buildSortOption('Sort by Name', _nameSort, (value) {
//                 setState(() {
//                   _nameSort = value!;
//                 });
//               }),
//               const SizedBox(width: 12),
//               _buildSortOption('Sort by Project', _projectSort, (value) {
//                 setState(() {
//                   _projectSort = value!;
//                 });
//               }),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSortOption(
//     String label,
//     String value,
//     ValueChanged<String?> onChanged,
//   ) {
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Container(
//             height: 40,
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 value: value,
//                 icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
//                 isExpanded: true,
//                 style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
//                 items: ['A-Z', 'Z-A', 'Latest'].map((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//                 onChanged: onChanged,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmployeeCard(
//     int index,
//     dynamic member,
//     List<String> projects,
//     Map<String, dynamic> attendance,
//   ) {
//     final isExpanded = _expandedEmployeeIndex == index;
//     final currentStatus = _getCurrentStatus(attendance);
//     final statusColor = _getStatusColor(currentStatus);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
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
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Avatar
//                 CircleAvatar(
//                   radius: 20,
//                   backgroundColor: Colors.blue.shade100,
//                   child: Text(
//                     member.name.split(' ').map((n) => n[0]).join(),
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.blue.shade700,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),

//                 // Employee Details - FIXED LAYOUT
//                 Expanded(
//                   flex: 3,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               member.name,
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.black87,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           // Status Badge
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: statusColor.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Container(
//                                   width: 6,
//                                   height: 6,
//                                   decoration: BoxDecoration(
//                                     color: statusColor,
//                                     shape: BoxShape.circle,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   currentStatus,
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     color: statusColor,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         member.role,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),

//                       // Info Chips - FIXED: Using responsive layout
//                       LayoutBuilder(
//                         builder: (context, constraints) {
//                           return Wrap(
//                             spacing: 6,
//                             runSpacing: 6,
//                             children: [
//                               _buildCompactInfoChip(
//                                 Icons.access_time_rounded,
//                                 '${attendance['checkin']} - ${attendance['checkout']}',
//                               ),
//                               _buildCompactInfoChip(
//                                 Icons.work_rounded,
//                                 '${projects.length} Projects',
//                               ),
//                               _buildCompactInfoChip(
//                                 Icons.calendar_today_rounded,
//                                 '${attendance['period']}',
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(width: 12),

//                 // Projects List - FIXED: Better width management
//                 Expanded(
//                   flex: 2,
//                   child: Container(
//                     constraints: BoxConstraints(maxHeight: 100),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           'Projects:',
//                           style: TextStyle(
//                             fontSize: 10,
//                             color: Colors.grey.shade600,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Expanded(
//                           child: SingleChildScrollView(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: projects.map((project) {
//                                 return Container(
//                                   margin: const EdgeInsets.only(bottom: 2),
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 6,
//                                     vertical: 2,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.blue.shade50,
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                   child: Text(
//                                     project,
//                                     style: TextStyle(
//                                       fontSize: 9,
//                                       color: Colors.blue.shade700,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                     textAlign: TextAlign.right,
//                                     overflow: TextOverflow.ellipsis,
//                                     maxLines: 1,
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Expand Button
//           Container(
//             decoration: BoxDecoration(
//               border: Border(top: BorderSide(color: Colors.grey.shade100)),
//             ),
//             child: ListTile(
//               dense: true,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//               title: Text(
//                 'View ${widget.viewModel.selectedPeriod} Attendance Details',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.blue.shade600,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               trailing: Icon(
//                 isExpanded ? Icons.expand_less : Icons.expand_more,
//                 color: Colors.blue.shade600,
//                 size: 18,
//               ),
//               onTap: () {
//                 setState(() {
//                   _expandedEmployeeIndex = isExpanded ? null : index;
//                 });
//               },
//             ),
//           ),

//           // Expanded Chart
//           if (isExpanded)
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(top: BorderSide(color: Colors.grey.shade100)),
//                 color: Colors.grey.shade50,
//               ),
//               child: Column(
//                 children: [
//                   Text(
//                     '${widget.viewModel.selectedPeriod.toUpperCase()} Attendance Distribution - ${member.name}',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   SizedBox(
//                     height: 180,
//                     child: _buildAttendanceChart(attendance),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactInfoChip(IconData icon, String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 10, color: Colors.grey.shade600),
//           const SizedBox(width: 3),
//           Flexible(
//             child: Text(
//               text,
//               style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAttendanceChart(Map<String, dynamic> attendance) {
//     final present = attendance['present'] ?? 0;
//     final absent = attendance['absent'] ?? 0;
//     final leave = attendance['leave'] ?? 0;
//     final late = attendance['late'] ?? 0;
//     final total = present + absent + leave + late;

//     if (total == 0) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.bar_chart_rounded,
//               size: 40,
//               color: Colors.grey.shade400,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'No attendance data for ${widget.viewModel.selectedPeriod}',
//               style: TextStyle(color: Colors.grey.shade500),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       );
//     }

//     // Create sections ensuring all four are visible
//     final sections = <PieChartSectionData>[];

//     // Always add all four sections with minimum values
//     sections.add(_buildChartSection('Present', present, total, Colors.green));
//     sections.add(_buildChartSection('Late', late, total, Colors.orange));
//     sections.add(_buildChartSection('Leave', leave, total, Colors.blue));
//     sections.add(_buildChartSection('Absent', absent, total, Colors.red));

//     return PieChart(
//       PieChartData(sections: sections, centerSpaceRadius: 30, sectionsSpace: 1),
//     );
//   }

//   PieChartSectionData _buildChartSection(
//     String label,
//     int value,
//     int total,
//     Color color,
//   ) {
//     final percentage = total > 0 ? ((value / total) * 100).round() : 0;

//     // Ensure all sections are visible with minimum value
//     final displayValue = value == 0 ? 0.1 : value.toDouble();

//     return PieChartSectionData(
//       color: color,
//       value: displayValue,
//       title: '$percentage%',
//       radius: 40,
//       titleStyle: const TextStyle(
//         fontSize: 11,
//         fontWeight: FontWeight.w600,
//         color: Colors.white,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:attendanceapp/view_models/projectviewmodels/project_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// class IndividualGraphs extends StatefulWidget {
//   final AttendanceAnalyticsViewModel viewModel;
//   final ProjectViewModel projectViewModel; // Add ProjectViewModel

//   const IndividualGraphs({
//     super.key,
//     required this.viewModel,
//     required this.projectViewModel, // Add this parameter
//   });

//   @override
//   State<IndividualGraphs> createState() => _IndividualGraphsState();
// }

// class _IndividualGraphsState extends State<IndividualGraphs> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   String _nameSort = 'A-Z';
//   String _projectSort = 'A-Z';
//   int? _expandedEmployeeIndex;

//   List<dynamic> get _filteredTeamMembers {
//     List<dynamic> members = List.from(widget.viewModel.teamMembers);

//     if (_searchQuery.isNotEmpty) {
//       members = members
//           .where(
//             (member) =>
//                 member.name.toLowerCase().contains(
//                   _searchQuery.toLowerCase(),
//                 ) ||
//                 member.role.toLowerCase().contains(
//                   _searchQuery.toLowerCase(),
//                 ) ||
//                 member.email.toLowerCase().contains(_searchQuery.toLowerCase()),
//           )
//           .toList();
//     }

//     if (_nameSort == 'A-Z') {
//       members.sort((a, b) => a.name.compareTo(b.name));
//     } else if (_nameSort == 'Z-A') {
//       members.sort((a, b) => b.name.compareTo(a.name));
//     }

//     return members;
//   }

//   // Get employee projects using the provided ProjectViewModel
//   List<String> _getEmployeeProjects(String employeeEmail) {
//     final allProjects =
//         widget.projectViewModel.projects; // Use widget.projectViewModel
//     final employeeProjects = <String>[];

//     for (final project in allProjects) {
//       final isAssigned = project.assignedTeam.any(
//         (member) => member.email == employeeEmail,
//       );
//       if (isAssigned) {
//         employeeProjects.add(project.name);
//       }
//     }

//     return employeeProjects.isNotEmpty
//         ? employeeProjects
//         : ['No Projects Assigned'];
//   }

//   // Get attendance data based on selected period using the new method from viewModel
//   Map<String, dynamic> _getEmployeeAttendance(String employeeEmail) {
//     // Use the new method from AttendanceAnalyticsViewModel
//     return widget.viewModel.getPeriodAttendanceData(employeeEmail);
//   }

//   // Get current status (only one status to show)
//   String _getCurrentStatus(Map<String, dynamic> attendance) {
//     final present = attendance['present'] ?? 0;
//     final absent = attendance['absent'] ?? 0;
//     final leave = attendance['leave'] ?? 0;
//     final late = attendance['late'] ?? 0;

//     // Priority: Present > Late > Leave > Absent
//     if (present > 0) return 'Present';
//     if (late > 0) return 'Late';
//     if (leave > 0) return 'Leave';
//     if (absent > 0) return 'Absent';
//     return 'No Data';
//   }

//   // Get color for current status
//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'Present':
//         return Colors.green;
//       case 'Late':
//         return Colors.yellow.shade700;
//       case 'Leave':
//         return Colors.orange;
//       case 'Absent':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final analytics = widget.viewModel.analytics;
//     if (analytics == null) return const SizedBox();

//     return Column(
//       children: [
//         // Header with Period Info
//         _buildHeader(),
//         const SizedBox(height: 16),

//         // Search and Filters
//         _buildSearchSection(),
//         const SizedBox(height: 16),

//         // Employee List
//         ..._filteredTeamMembers.asMap().entries.map((entry) {
//           final index = entry.key;
//           final member = entry.value;
//           final projects = _getEmployeeProjects(member.email);
//           final attendance = _getEmployeeAttendance(member.email);

//           return _buildEmployeeCard(index, member, projects, attendance);
//         }),
//       ],
//     );
//   }

//   Widget _buildHeader() {
//     final period = widget.viewModel.selectedPeriod;
//     final selectedDate = widget.viewModel.selectedDate;

//     return Container(
//       padding: const EdgeInsets.all(20),
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
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.people_alt_rounded,
//               color: Colors.blue.shade600,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Employee Overview - ${widget.viewModel.getPeriodDisplayName(period)}',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey.shade800,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   _getPeriodDateRange(period, selectedDate),
//                   style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//                 ),
//               ],
//             ),
//           ),
//           // Period Summary
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.blue.shade200),
//             ),
//             child: Text(
//               '${_filteredTeamMembers.length} Employees',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.blue.shade700,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getPeriodDateRange(String period, DateTime selectedDate) {
//     switch (period) {
//       case 'daily':
//         return 'Date: ${_formatDate(selectedDate)}';
//       case 'weekly':
//         final weekStart = widget.viewModel.getFirstDayOfWeek(selectedDate);
//         final weekEnd = weekStart.add(const Duration(days: 6));
//         return 'Week: ${_formatDate(weekStart)} - ${_formatDate(weekEnd)}';
//       case 'monthly':
//         return 'Month: ${_formatMonth(selectedDate)}';
//       case 'quarterly':
//         final quarter = ((selectedDate.month - 1) ~/ 3) + 1;
//         return 'Quarter: Q$quarter ${selectedDate.year}';
//       default:
//         return 'Period: ${widget.viewModel.getPeriodDisplayName(period)}';
//     }
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   String _formatMonth(DateTime date) {
//     return '${_getMonthName(date.month)} ${date.year}';
//   }

//   String _getMonthName(int month) {
//     const months = [
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

//   Widget _buildSearchSection() {
//     return Container(
//       padding: const EdgeInsets.all(20),
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
//       child: Column(
//         children: [
//           // Search Bar
//           Container(
//             height: 48,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: Row(
//               children: [
//                 const SizedBox(width: 16),
//                 Icon(
//                   Icons.search_rounded,
//                   color: Colors.grey.shade500,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     style: const TextStyle(fontSize: 14, color: Colors.black87),
//                     decoration: InputDecoration(
//                       hintText: 'Search employees by name, role, or email...',
//                       hintStyle: TextStyle(
//                         color: Colors.grey.shade500,
//                         fontSize: 14,
//                       ),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.zero,
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         _searchQuery = value;
//                       });
//                     },
//                   ),
//                 ),
//                 if (_searchQuery.isNotEmpty)
//                   IconButton(
//                     icon: Icon(
//                       Icons.clear_rounded,
//                       color: Colors.grey.shade500,
//                       size: 18,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _searchController.clear();
//                         _searchQuery = '';
//                       });
//                     },
//                   ),
//                 const SizedBox(width: 8),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Sort Options
//           Row(
//             children: [
//               _buildSortOption('Sort by Name', _nameSort, (value) {
//                 setState(() {
//                   _nameSort = value!;
//                 });
//               }),
//               const SizedBox(width: 12),
//               _buildSortOption('Sort by Project', _projectSort, (value) {
//                 setState(() {
//                   _projectSort = value!;
//                 });
//               }),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSortOption(
//     String label,
//     String value,
//     ValueChanged<String?> onChanged,
//   ) {
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Container(
//             height: 40,
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 value: value,
//                 icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
//                 isExpanded: true,
//                 style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
//                 items: ['A-Z', 'Z-A', 'Latest'].map((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//                 onChanged: onChanged,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmployeeCard(
//     int index,
//     dynamic member,
//     List<String> projects,
//     Map<String, dynamic> attendance,
//   ) {
//     final isExpanded = _expandedEmployeeIndex == index;
//     final currentStatus = _getCurrentStatus(attendance);
//     final statusColor = _getStatusColor(currentStatus);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
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
//       child: Column(
//         children: [
//           // Employee Info
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Avatar
//                 CircleAvatar(
//                   radius: 24,
//                   backgroundColor: Colors.blue.shade100,
//                   child: Text(
//                     member.name.split(' ').map((n) => n[0]).join(),
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.blue.shade700,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),

//                 // Employee Details
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         member.name,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         member.role,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 4,
//                         children: [
//                           _buildInfoChip(
//                             Icons.access_time_rounded,
//                             '${attendance['checkin']} - ${attendance['checkout']}',
//                           ),
//                           _buildInfoChip(
//                             Icons.work_rounded,
//                             '${projects.length} Projects',
//                           ),
//                           _buildInfoChip(
//                             Icons.calendar_today_rounded,
//                             '${attendance['period']}',
//                           ),
//                           // Current Status Chip
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: statusColor.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Container(
//                                   width: 6,
//                                   height: 6,
//                                   decoration: BoxDecoration(
//                                     color: statusColor,
//                                     shape: BoxShape.circle,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   currentStatus,
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     color: statusColor,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Projects List (All projects)
//                 ConstrainedBox(
//                   constraints: BoxConstraints(
//                     maxWidth: MediaQuery.of(context).size.width * 0.3,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       // All Projects List
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: projects.map((project) {
//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 4),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.blue.shade50,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               project,
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 color: Colors.blue.shade700,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                               textAlign: TextAlign.right,
//                               overflow: TextOverflow.ellipsis,
//                               maxLines: 1,
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Expand Button
//           Container(
//             decoration: BoxDecoration(
//               border: Border(top: BorderSide(color: Colors.grey.shade100)),
//             ),
//             child: ListTile(
//               dense: true,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 20),
//               title: Text(
//                 'View ${widget.viewModel.selectedPeriod} Attendance Details',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.blue.shade600,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               trailing: Icon(
//                 isExpanded ? Icons.expand_less : Icons.expand_more,
//                 color: Colors.blue.shade600,
//               ),
//               onTap: () {
//                 setState(() {
//                   _expandedEmployeeIndex = isExpanded ? null : index;
//                 });
//               },
//             ),
//           ),

//           // Expanded Chart
//           if (isExpanded)
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 border: Border(top: BorderSide(color: Colors.grey.shade100)),
//                 color: Colors.grey.shade50,
//               ),
//               child: Column(
//                 children: [
//                   Text(
//                     '${widget.viewModel.selectedPeriod.toUpperCase()} Attendance Distribution - ${member.name}',
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   SizedBox(
//                     height: 180,
//                     child: _buildAttendanceChart(attendance),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoChip(IconData icon, String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 12, color: Colors.grey.shade600),
//           const SizedBox(width: 4),
//           Text(
//             text,
//             style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAttendanceChart(Map<String, dynamic> attendance) {
//     final present = attendance['present'] ?? 0;
//     final absent = attendance['absent'] ?? 0;
//     final leave = attendance['leave'] ?? 0;
//     final late = attendance['late'] ?? 0;
//     final total = present + absent + leave + late;

//     if (total == 0) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.bar_chart_rounded,
//               size: 40,
//               color: Colors.grey.shade400,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'No attendance data for ${widget.viewModel.selectedPeriod}',
//               style: TextStyle(color: Colors.grey.shade500),
//             ),
//           ],
//         ),
//       );
//     }

//     return PieChart(
//       PieChartData(
//         sections: [
//           _buildChartSection('Present', present, total, Colors.green),
//           _buildChartSection('Absent', absent, total, Colors.red),
//           _buildChartSection('Leave', leave, total, Colors.orange),
//           _buildChartSection('Late', late, total, Colors.yellow.shade700),
//         ],
//         centerSpaceRadius: 40,
//         sectionsSpace: 2,
//       ),
//     );
//   }

//   PieChartSectionData _buildChartSection(
//     String label,
//     int value,
//     int total,
//     Color color,
//   ) {
//     final percentage = ((value / total) * 100).round();
//     return PieChartSectionData(
//       color: color,
//       value: value.toDouble(),
//       title: '$percentage%',
//       radius: 50,
//       titleStyle: const TextStyle(
//         fontSize: 12,
//         fontWeight: FontWeight.w600,
//         color: Colors.white,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:attendanceapp/view_models/projectviewmodels/project_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// class IndividualGraphs extends StatefulWidget {
//   final AttendanceAnalyticsViewModel viewModel;
//   final ProjectViewModel projectViewModel; // Add ProjectViewModel

//   const IndividualGraphs({
//     super.key,
//     required this.viewModel,
//     required this.projectViewModel, // Add this parameter
//   });

//   @override
//   State<IndividualGraphs> createState() => _IndividualGraphsState();
// }

// class _IndividualGraphsState extends State<IndividualGraphs> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   String _nameSort = 'A-Z';
//   String _projectSort = 'A-Z';
//   int? _expandedEmployeeIndex;

//   List<dynamic> get _filteredTeamMembers {
//     List<dynamic> members = List.from(widget.viewModel.teamMembers);

//     if (_searchQuery.isNotEmpty) {
//       members = members
//           .where(
//             (member) =>
//                 member.name.toLowerCase().contains(
//                   _searchQuery.toLowerCase(),
//                 ) ||
//                 member.role.toLowerCase().contains(
//                   _searchQuery.toLowerCase(),
//                 ) ||
//                 member.email.toLowerCase().contains(_searchQuery.toLowerCase()),
//           )
//           .toList();
//     }

//     if (_nameSort == 'A-Z') {
//       members.sort((a, b) => a.name.compareTo(b.name));
//     } else if (_nameSort == 'Z-A') {
//       members.sort((a, b) => b.name.compareTo(a.name));
//     }

//     return members;
//   }

//   // Get employee projects using the provided ProjectViewModel
//   List<String> _getEmployeeProjects(String employeeEmail) {
//     final allProjects =
//         widget.projectViewModel.projects; // Use widget.projectViewModel
//     final employeeProjects = <String>[];

//     for (final project in allProjects) {
//       final isAssigned = project.assignedTeam.any(
//         (member) => member.email == employeeEmail,
//       );
//       if (isAssigned) {
//         employeeProjects.add(project.name);
//       }
//     }

//     return employeeProjects.isNotEmpty
//         ? employeeProjects
//         : ['No Projects Assigned'];
//   }

//   // Get attendance data based on selected period using the new method from viewModel
//   Map<String, dynamic> _getEmployeeAttendance(String employeeEmail) {
//     // Use the new method from AttendanceAnalyticsViewModel
//     return widget.viewModel.getPeriodAttendanceData(employeeEmail);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final analytics = widget.viewModel.analytics;
//     if (analytics == null) return const SizedBox();

//     return Column(
//       children: [
//         // Header with Period Info
//         _buildHeader(),
//         const SizedBox(height: 16),

//         // Search and Filters
//         _buildSearchSection(),
//         const SizedBox(height: 16),

//         // Employee List
//         ..._filteredTeamMembers.asMap().entries.map((entry) {
//           final index = entry.key;
//           final member = entry.value;
//           final projects = _getEmployeeProjects(member.email);
//           final attendance = _getEmployeeAttendance(member.email);

//           return _buildEmployeeCard(index, member, projects, attendance);
//         }),
//       ],
//     );
//   }

//   Widget _buildHeader() {
//     final period = widget.viewModel.selectedPeriod;
//     final selectedDate = widget.viewModel.selectedDate;

//     return Container(
//       padding: const EdgeInsets.all(20),
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
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.people_alt_rounded,
//               color: Colors.blue.shade600,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Employee Overview - ${widget.viewModel.getPeriodDisplayName(period)}',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey.shade800,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   _getPeriodDateRange(period, selectedDate),
//                   style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//                 ),
//               ],
//             ),
//           ),
//           // Period Summary
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.blue.shade200),
//             ),
//             child: Text(
//               '${_filteredTeamMembers.length} Employees',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.blue.shade700,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getPeriodDateRange(String period, DateTime selectedDate) {
//     switch (period) {
//       case 'daily':
//         return 'Date: ${_formatDate(selectedDate)}';
//       case 'weekly':
//         final weekStart = widget.viewModel.getFirstDayOfWeek(selectedDate);
//         final weekEnd = weekStart.add(const Duration(days: 6));
//         return 'Week: ${_formatDate(weekStart)} - ${_formatDate(weekEnd)}';
//       case 'monthly':
//         return 'Month: ${_formatMonth(selectedDate)}';
//       case 'quarterly':
//         final quarter = ((selectedDate.month - 1) ~/ 3) + 1;
//         return 'Quarter: Q$quarter ${selectedDate.year}';
//       default:
//         return 'Period: ${widget.viewModel.getPeriodDisplayName(period)}';
//     }
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   String _formatMonth(DateTime date) {
//     return '${_getMonthName(date.month)} ${date.year}';
//   }

//   String _getMonthName(int month) {
//     const months = [
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

//   Widget _buildSearchSection() {
//     return Container(
//       padding: const EdgeInsets.all(20),
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
//       child: Column(
//         children: [
//           // Search Bar
//           Container(
//             height: 48,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: Row(
//               children: [
//                 const SizedBox(width: 16),
//                 Icon(
//                   Icons.search_rounded,
//                   color: Colors.grey.shade500,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     style: const TextStyle(fontSize: 14, color: Colors.black87),
//                     decoration: InputDecoration(
//                       hintText: 'Search employees by name, role, or email...',
//                       hintStyle: TextStyle(
//                         color: Colors.grey.shade500,
//                         fontSize: 14,
//                       ),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.zero,
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         _searchQuery = value;
//                       });
//                     },
//                   ),
//                 ),
//                 if (_searchQuery.isNotEmpty)
//                   IconButton(
//                     icon: Icon(
//                       Icons.clear_rounded,
//                       color: Colors.grey.shade500,
//                       size: 18,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _searchController.clear();
//                         _searchQuery = '';
//                       });
//                     },
//                   ),
//                 const SizedBox(width: 8),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Sort Options
//           Row(
//             children: [
//               _buildSortOption('Sort by Name', _nameSort, (value) {
//                 setState(() {
//                   _nameSort = value!;
//                 });
//               }),
//               const SizedBox(width: 12),
//               _buildSortOption('Sort by Project', _projectSort, (value) {
//                 setState(() {
//                   _projectSort = value!;
//                 });
//               }),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSortOption(
//     String label,
//     String value,
//     ValueChanged<String?> onChanged,
//   ) {
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Container(
//             height: 40,
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 value: value,
//                 icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
//                 isExpanded: true,
//                 style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
//                 items: ['A-Z', 'Z-A', 'Latest'].map((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//                 onChanged: onChanged,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmployeeCard(
//     int index,
//     dynamic member,
//     List<String> projects,
//     Map<String, dynamic> attendance,
//   ) {
//     final isExpanded = _expandedEmployeeIndex == index;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
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
//       child: Column(
//         children: [
//           // Employee Info
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Avatar
//                 CircleAvatar(
//                   radius: 24,
//                   backgroundColor: Colors.blue.shade100,
//                   child: Text(
//                     member.name.split(' ').map((n) => n[0]).join(),
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.blue.shade700,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),

//                 // Employee Details
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         member.name,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         member.role,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 4,
//                         children: [
//                           _buildInfoChip(
//                             Icons.access_time_rounded,
//                             '${attendance['checkin']} - ${attendance['checkout']}',
//                           ),
//                           _buildInfoChip(
//                             Icons.work_rounded,
//                             '${projects.length} Projects',
//                           ),
//                           _buildInfoChip(
//                             Icons.calendar_today_rounded,
//                             '${attendance['period']}',
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Status Indicators
//                 ConstrainedBox(
//                   constraints: BoxConstraints(
//                     maxWidth: MediaQuery.of(context).size.width * 0.3,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       // Projects
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: projects.take(2).map((project) {
//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 4),
//                             child: Text(
//                               project,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.blue.shade600,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                               textAlign: TextAlign.right,
//                               overflow: TextOverflow.ellipsis,
//                               maxLines: 1,
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                       const SizedBox(height: 12),

//                       // Attendance Status
//                       Wrap(
//                         spacing: 6,
//                         runSpacing: 4,
//                         alignment: WrapAlignment.end,
//                         children: [
//                           _buildAttendanceIndicator(
//                             'Present',
//                             attendance['present'],
//                             Colors.green,
//                           ),
//                           _buildAttendanceIndicator(
//                             'Absent',
//                             attendance['absent'],
//                             Colors.red,
//                           ),
//                           _buildAttendanceIndicator(
//                             'Leave',
//                             attendance['leave'],
//                             Colors.orange,
//                           ),
//                           _buildAttendanceIndicator(
//                             'Late',
//                             attendance['late'],
//                             Colors.yellow.shade700,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Expand Button
//           Container(
//             decoration: BoxDecoration(
//               border: Border(top: BorderSide(color: Colors.grey.shade100)),
//             ),
//             child: ListTile(
//               dense: true,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 20),
//               title: Text(
//                 'View ${widget.viewModel.selectedPeriod} Attendance Details',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.blue.shade600,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               trailing: Icon(
//                 isExpanded ? Icons.expand_less : Icons.expand_more,
//                 color: Colors.blue.shade600,
//               ),
//               onTap: () {
//                 setState(() {
//                   _expandedEmployeeIndex = isExpanded ? null : index;
//                 });
//               },
//             ),
//           ),

//           // Expanded Chart
//           if (isExpanded)
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 border: Border(top: BorderSide(color: Colors.grey.shade100)),
//                 color: Colors.grey.shade50,
//               ),
//               child: Column(
//                 children: [
//                   Text(
//                     '${widget.viewModel.selectedPeriod.toUpperCase()} Attendance Distribution - ${member.name}',
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   SizedBox(
//                     height: 180,
//                     child: _buildAttendanceChart(attendance),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoChip(IconData icon, String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 12, color: Colors.grey.shade600),
//           const SizedBox(width: 4),
//           Text(
//             text,
//             style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAttendanceIndicator(String label, int count, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 6,
//             height: 6,
//             decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//           ),
//           const SizedBox(width: 4),
//           Text(
//             '$count',
//             style: TextStyle(
//               fontSize: 12,
//               color: color,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAttendanceChart(Map<String, dynamic> attendance) {
//     final present = attendance['present'] ?? 0;
//     final absent = attendance['absent'] ?? 0;
//     final leave = attendance['leave'] ?? 0;
//     final late = attendance['late'] ?? 0;
//     final total = present + absent + leave + late;

//     if (total == 0) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.bar_chart_rounded,
//               size: 40,
//               color: Colors.grey.shade400,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'No attendance data for ${widget.viewModel.selectedPeriod}',
//               style: TextStyle(color: Colors.grey.shade500),
//             ),
//           ],
//         ),
//       );
//     }

//     return PieChart(
//       PieChartData(
//         sections: [
//           _buildChartSection('Present', present, total, Colors.green),
//           _buildChartSection('Absent', absent, total, Colors.red),
//           _buildChartSection('Leave', leave, total, Colors.orange),
//           _buildChartSection('Late', late, total, Colors.yellow.shade700),
//         ],
//         centerSpaceRadius: 40,
//         sectionsSpace: 2,
//       ),
//     );
//   }

//   PieChartSectionData _buildChartSection(
//     String label,
//     int value,
//     int total,
//     Color color,
//   ) {
//     final percentage = ((value / total) * 100).round();
//     return PieChartSectionData(
//       color: color,
//       value: value.toDouble(),
//       title: '$percentage%',
//       radius: 50,
//       titleStyle: const TextStyle(
//         fontSize: 12,
//         fontWeight: FontWeight.w600,
//         color: Colors.white,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// class IndividualGraphs extends StatefulWidget {
//   final AttendanceAnalyticsViewModel viewModel;

//   const IndividualGraphs({super.key, required this.viewModel});

//   @override
//   State<IndividualGraphs> createState() => _IndividualGraphsState();
// }

// class _IndividualGraphsState extends State<IndividualGraphs> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   String _activeFilter = 'employee'; // 'employee' or 'project'
//   bool _isEmployeeSorted = false;
//   bool _isProjectSorted = false;

//   List<dynamic> get _filteredTeamMembers {
//     List<dynamic> members = List.from(widget.viewModel.teamMembers);

//     // Apply search filter
//     if (_searchQuery.isNotEmpty) {
//       members = members
//           .where(
//             (member) =>
//                 member.name.toLowerCase().contains(
//                   _searchQuery.toLowerCase(),
//                 ) ||
//                 member.role.toLowerCase().contains(
//                   _searchQuery.toLowerCase(),
//                 ) ||
//                 member.email.toLowerCase().contains(_searchQuery.toLowerCase()),
//           )
//           .toList();
//     }

//     // Apply alphabetical sorting
//     if (_isEmployeeSorted && _activeFilter == 'employee') {
//       members.sort((a, b) => a.name.compareTo(b.name));
//     }

//     return members;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final analytics = widget.viewModel.analytics;
//     if (analytics == null) return const SizedBox();

//     final individualData = analytics.individualData;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Quantum Header
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             color: Colors.black26,
//             border: Border.all(
//               color: Colors.white.withOpacity(0.2),
//               width: 1.5,
//             ),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.cyan.shade400, Colors.blue.shade400],
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.analytics_rounded,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'INDIVIDUAL ANALYTICS',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w800,
//                         color: Colors.white.withOpacity(0.9),
//                         letterSpacing: 1.2,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       '${widget.viewModel.getPeriodDisplayName(widget.viewModel.selectedPeriod)} Performance',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w800,
//                         color: Colors.white,
//                         letterSpacing: 0.8,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),

//         const SizedBox(height: 16),

//         // Enhanced Search and Filter Section
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             color: Colors.black26,
//             border: Border.all(
//               color: Colors.white.withOpacity(0.2),
//               width: 1.5,
//             ),
//           ),
//           child: Column(
//             children: [
//               // Enhanced Search Bar
//               Container(
//                 height: 52,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(16),
//                   color: Colors.transparent,
//                   // gradient: LinearGradient(
//                   //   begin: Alignment.topLeft,
//                   //   end: Alignment.bottomRight,
//                   //   colors: [
//                   //     Colors.white.withOpacity(0.08),
//                   //     Colors.white.withOpacity(0.02),
//                   //   ],
//                   // ),
//                   border: Border.all(color: Colors.orange, width: 1.5),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.3),
//                       blurRadius: 15,
//                       offset: const Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     const SizedBox(width: 18),
//                     Icon(Icons.search_rounded, color: Colors.white, size: 22),
//                     const SizedBox(width: 14),
//                     Expanded(
//                       child: TextField(
//                         controller: _searchController,
//                         style: const TextStyle(
//                           color: Colors.black,
//                           fontSize: 15,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         decoration: InputDecoration(
//                           hintText: 'Search',
//                           hintStyle: TextStyle(
//                             color: Colors.white.withOpacity(0.5),
//                             fontSize: 15,
//                             fontWeight: FontWeight.w500,
//                           ),
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.zero,
//                         ),
//                         onChanged: (value) {
//                           setState(() {
//                             _searchQuery = value;
//                           });
//                         },
//                       ),
//                     ),
//                     if (_searchQuery.isNotEmpty)
//                       IconButton(
//                         icon: Icon(
//                           Icons.clear_rounded,
//                           color: Colors.white.withOpacity(0.6),
//                           size: 20,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _searchController.clear();
//                             _searchQuery = '';
//                           });
//                         },
//                       ),
//                     const SizedBox(width: 12),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Enhanced Filter Buttons
//               Row(
//                 children: [
//                   // Employee Filter
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _activeFilter = 'employee';
//                           _isEmployeeSorted = !_isEmployeeSorted;
//                           _isProjectSorted = false;
//                         });
//                       },
//                       child: Container(
//                         height: 44,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           gradient:
//                               _activeFilter == 'employee' && _isEmployeeSorted
//                               ? LinearGradient(
//                                   colors: [
//                                     Colors.cyan.shade400.withOpacity(0.3),
//                                     Colors.blue.shade400.withOpacity(0.2),
//                                   ],
//                                 )
//                               : null,
//                           color:
//                               _activeFilter == 'employee' && _isEmployeeSorted
//                               ? null
//                               : Colors.white.withOpacity(0.05),
//                           border: Border.all(
//                             color:
//                                 _activeFilter == 'employee' && _isEmployeeSorted
//                                 ? Colors.cyan.shade400.withOpacity(0.6)
//                                 : Colors.white.withOpacity(0.2),
//                             width:
//                                 _activeFilter == 'employee' && _isEmployeeSorted
//                                 ? 2
//                                 : 1.5,
//                           ),
//                           boxShadow:
//                               _activeFilter == 'employee' && _isEmployeeSorted
//                               ? [
//                                   BoxShadow(
//                                     color: Colors.cyan.shade400.withOpacity(
//                                       0.3,
//                                     ),
//                                     blurRadius: 8,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ]
//                               : null,
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.people_rounded,
//                               color:
//                                   _activeFilter == 'employee' &&
//                                       _isEmployeeSorted
//                                   ? Colors.cyan.shade300
//                                   : Colors.white.withOpacity(0.6),
//                               size: 18,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               'Employee',
//                               style: TextStyle(
//                                 color:
//                                     _activeFilter == 'employee' &&
//                                         _isEmployeeSorted
//                                     ? Colors.cyan.shade300
//                                     : Colors.white.withOpacity(0.6),
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                             if (_activeFilter == 'employee' &&
//                                 _isEmployeeSorted)
//                               const SizedBox(width: 4),
//                             if (_activeFilter == 'employee' &&
//                                 _isEmployeeSorted)
//                               Icon(
//                                 Icons.check_rounded,
//                                 color: Colors.cyan.shade300,
//                                 size: 16,
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(width: 12),

//                   // Project Filter
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _activeFilter = 'project';
//                           _isProjectSorted = !_isProjectSorted;
//                           _isEmployeeSorted = false;
//                         });
//                       },
//                       child: Container(
//                         height: 44,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           gradient:
//                               _activeFilter == 'project' && _isProjectSorted
//                               ? LinearGradient(
//                                   colors: [
//                                     Colors.purple.shade400.withOpacity(0.3),
//                                     Colors.pink.shade400.withOpacity(0.2),
//                                   ],
//                                 )
//                               : null,
//                           color: _activeFilter == 'project' && _isProjectSorted
//                               ? null
//                               : Colors.white.withOpacity(0.05),
//                           border: Border.all(
//                             color:
//                                 _activeFilter == 'project' && _isProjectSorted
//                                 ? Colors.purple.shade400.withOpacity(0.6)
//                                 : Colors.white.withOpacity(0.2),
//                             width:
//                                 _activeFilter == 'project' && _isProjectSorted
//                                 ? 2
//                                 : 1.5,
//                           ),
//                           boxShadow:
//                               _activeFilter == 'project' && _isProjectSorted
//                               ? [
//                                   BoxShadow(
//                                     color: Colors.purple.shade400.withOpacity(
//                                       0.3,
//                                     ),
//                                     blurRadius: 8,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ]
//                               : null,
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.work_rounded,
//                               color:
//                                   _activeFilter == 'project' && _isProjectSorted
//                                   ? Colors.purple.shade300
//                                   : Colors.white.withOpacity(0.6),
//                               size: 18,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               'Project',
//                               style: TextStyle(
//                                 color:
//                                     _activeFilter == 'project' &&
//                                         _isProjectSorted
//                                     ? Colors.purple.shade300
//                                     : Colors.white.withOpacity(0.6),
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                             if (_activeFilter == 'project' && _isProjectSorted)
//                               const SizedBox(width: 4),
//                             if (_activeFilter == 'project' && _isProjectSorted)
//                               Icon(
//                                 Icons.check_rounded,
//                                 color: Colors.purple.shade300,
//                                 size: 16,
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),

//         const SizedBox(height: 16),

//         // Team Members List with filtering
//         ..._filteredTeamMembers.map((member) {
//           final memberData = individualData[member.email] ?? {};
//           final attendanceRate = memberData['attendanceRate'] ?? 0.0;
//           final avgHours = memberData['avgHours'] ?? 0.0;
//           final productivity = memberData['productivity'] ?? 0.0;

//           return Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.2),
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
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Member Header
//                     Row(
//                       children: [
//                         // Avatar with Status
//                         Stack(
//                           children: [
//                             Container(
//                               width: 50,
//                               height: 50,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 gradient: LinearGradient(
//                                   colors: [
//                                     _getPerformanceColor(
//                                       attendanceRate,
//                                     ).withOpacity(0.8),
//                                     _getPerformanceColor(
//                                       attendanceRate,
//                                     ).withOpacity(0.6),
//                                   ],
//                                 ),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: _getPerformanceColor(
//                                       attendanceRate,
//                                     ).withOpacity(0.4),
//                                     blurRadius: 10,
//                                     spreadRadius: 2,
//                                   ),
//                                 ],
//                               ),
//                               child: const Center(
//                                 child: Icon(
//                                   Icons.person_rounded,
//                                   color: Colors.white,
//                                   size: 24,
//                                 ),
//                               ),
//                             ),
//                             // Performance Indicator
//                             Positioned(
//                               bottom: 2,
//                               right: 2,
//                               child: Container(
//                                 width: 12,
//                                 height: 12,
//                                 decoration: BoxDecoration(
//                                   color: _getPerformanceColor(attendanceRate),
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     color: Colors.white,
//                                     width: 2,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(width: 12),

//                         // Member Info
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 member.name.toUpperCase(),
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w800,
//                                   color: Colors.white,
//                                   letterSpacing: 0.5,
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               Text(
//                                 member.role.toUpperCase(),
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.white.withOpacity(0.7),
//                                   fontWeight: FontWeight.w600,
//                                   letterSpacing: 0.5,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         // Performance Score
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 _getPerformanceColor(
//                                   attendanceRate,
//                                 ).withOpacity(0.3),
//                                 _getPerformanceColor(
//                                   attendanceRate,
//                                 ).withOpacity(0.1),
//                               ],
//                             ),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: _getPerformanceColor(
//                                 attendanceRate,
//                               ).withOpacity(0.4),
//                               width: 1.5,
//                             ),
//                           ),
//                           child: Text(
//                             '${attendanceRate.toStringAsFixed(0)}%',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w800,
//                               color: _getPerformanceColor(attendanceRate),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 16),

//                     // Performance Chart
//                     SizedBox(
//                       height: 60,
//                       child: _buildQuantumPerformanceChart(attendanceRate),
//                     ),

//                     const SizedBox(height: 16),

//                     // Performance Metrics
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         _buildQuantumMetricWithChart(
//                           'ABSENT',
//                           '${avgHours.toStringAsFixed(1)}h',
//                           Icons.access_time_rounded,
//                           avgHours / 10,
//                           Colors.cyan.shade400,
//                         ),
//                         _buildQuantumMetricWithChart(
//                           'LEAVE',
//                           '${productivity.toStringAsFixed(0)}%',
//                           Icons.work_history_rounded,
//                           productivity / 100,
//                           Colors.orange.shade400,
//                         ),
//                         _buildQuantumMetricWithChart(
//                           'PRESENCE',
//                           '${attendanceRate.toStringAsFixed(0)}%',
//                           Icons.verified_user_rounded,
//                           attendanceRate / 100,
//                           Colors.green.shade400,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }),
//       ],
//     );
//   }

//   Widget _buildQuantumPerformanceChart(double attendanceRate) {
//     final spots = [
//       FlSpot(0, 40),
//       FlSpot(1, 60),
//       FlSpot(2, 75),
//       FlSpot(3, 65),
//       FlSpot(4, 85),
//       FlSpot(5, attendanceRate),
//     ];

//     return LineChart(
//       LineChartData(
//         minX: 0,
//         maxX: 5,
//         minY: 0,
//         maxY: 100,
//         lineTouchData: const LineTouchData(enabled: false),
//         lineBarsData: [
//           LineChartBarData(
//             spots: spots,
//             isCurved: true,
//             color: _getPerformanceColor(attendanceRate),
//             barWidth: 3,
//             belowBarData: BarAreaData(
//               show: true,
//               gradient: LinearGradient(
//                 colors: [
//                   _getPerformanceColor(attendanceRate).withOpacity(0.3),
//                   _getPerformanceColor(attendanceRate).withOpacity(0.1),
//                 ],
//               ),
//             ),
//             dotData: const FlDotData(show: false),
//             shadow: Shadow(
//               color: _getPerformanceColor(attendanceRate).withOpacity(0.4),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ),
//         ],
//         gridData: FlGridData(
//           show: true,
//           drawHorizontalLine: true,
//           drawVerticalLine: false,
//           horizontalInterval: 25,
//           getDrawingHorizontalLine: (value) {
//             return FlLine(
//               color: Colors.white.withOpacity(0.1),
//               strokeWidth: 1,
//               dashArray: [4, 4],
//             );
//           },
//         ),
//         titlesData: const FlTitlesData(show: false),
//         borderData: FlBorderData(
//           show: true,
//           border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
//         ),
//       ),
//     );
//   }

//   Color _getPerformanceColor(double rate) {
//     if (rate >= 90) return Colors.green.shade400;
//     if (rate >= 75) return Colors.orange.shade400;
//     if (rate >= 60) return Colors.blue.shade400;
//     return Colors.red.shade400;
//   }

//   Widget _buildQuantumMetricWithChart(
//     String label,
//     String value,
//     IconData icon,
//     double progress,
//     Color color,
//   ) {
//     return Column(
//       children: [
//         // Circular Progress with Icon
//         Stack(
//           alignment: Alignment.center,
//           children: [
//             SizedBox(
//               width: 50,
//               height: 50,
//               child: CircularProgressIndicator(
//                 value: progress,
//                 strokeWidth: 4,
//                 backgroundColor: Colors.white.withOpacity(0.1),
//                 valueColor: AlwaysStoppedAnimation<Color>(color),
//               ),
//             ),
//             Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.2),
//                 shape: BoxShape.circle,
//                 border: Border.all(color: color.withOpacity(0.4), width: 1.5),
//               ),
//               child: Icon(icon, size: 16, color: color),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w800,
//             color: color,
//             letterSpacing: 0.5,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 9,
//             color: Colors.white.withOpacity(0.7),
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.5,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// class IndividualGraphs extends StatelessWidget {
//   final AttendanceAnalyticsViewModel viewModel;

//   const IndividualGraphs({super.key, required this.viewModel});

//   @override
//   Widget build(BuildContext context) {
//     final analytics = viewModel.analytics;
//     if (analytics == null) return const SizedBox();

//     final individualData = analytics.individualData;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Quantum Header
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             color: Colors.black26,
//             // gradient: LinearGradient(
//             //   begin: Alignment.topLeft,
//             //   end: Alignment.bottomRight,
//             //   colors: [
//             //     Colors.white.withOpacity(0.15),
//             //     Colors.white.withOpacity(0.05),
//             //   ],
//             // ),
//             border: Border.all(
//               color: Colors.white.withOpacity(0.2),
//               width: 1.5,
//             ),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.cyan.shade400, Colors.blue.shade400],
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.analytics_rounded,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'INDIVIDUAL ANALYTICS',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w800,
//                         color: Colors.white.withOpacity(0.9),
//                         letterSpacing: 1.2,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       '${viewModel.getPeriodDisplayName(viewModel.selectedPeriod)} Performance',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w800,
//                         color: Colors.white,
//                         letterSpacing: 0.8,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),

//         const SizedBox(height: 16),

//         // Team Members List
//         ...viewModel.teamMembers.map((member) {
//           final memberData = individualData[member.email] ?? {};
//           final attendanceRate = memberData['attendanceRate'] ?? 0.0;
//           final avgHours = memberData['avgHours'] ?? 0.0;
//           final productivity = memberData['productivity'] ?? 0.0;

//           return Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               // gradient: LinearGradient(
//               //   begin: Alignment.topLeft,
//               //   end: Alignment.bottomRight,
//               //   colors: [
//               //     Colors.white.withOpacity(0.15),
//               //     Colors.white.withOpacity(0.05),
//               //   ],
//               // ),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.2),
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
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Member Header
//                     Row(
//                       children: [
//                         // Avatar with Status
//                         Stack(
//                           children: [
//                             Container(
//                               width: 50,
//                               height: 50,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 gradient: LinearGradient(
//                                   colors: [
//                                     _getPerformanceColor(
//                                       attendanceRate,
//                                     ).withOpacity(0.8),
//                                     _getPerformanceColor(
//                                       attendanceRate,
//                                     ).withOpacity(0.6),
//                                   ],
//                                 ),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: _getPerformanceColor(
//                                       attendanceRate,
//                                     ).withOpacity(0.4),
//                                     blurRadius: 10,
//                                     spreadRadius: 2,
//                                   ),
//                                 ],
//                               ),
//                               child: const Center(
//                                 child: Icon(
//                                   Icons.person_rounded,
//                                   color: Colors.white,
//                                   size: 24,
//                                 ),
//                               ),
//                             ),
//                             // Performance Indicator
//                             Positioned(
//                               bottom: 2,
//                               right: 2,
//                               child: Container(
//                                 width: 12,
//                                 height: 12,
//                                 decoration: BoxDecoration(
//                                   color: _getPerformanceColor(attendanceRate),
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     color: Colors.white,
//                                     width: 2,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(width: 12),

//                         // Member Info
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 member.name.toUpperCase(),
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w800,
//                                   color: Colors.white,
//                                   letterSpacing: 0.5,
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               Text(
//                                 member.role.toUpperCase(),
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.white.withOpacity(0.7),
//                                   fontWeight: FontWeight.w600,
//                                   letterSpacing: 0.5,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         // Performance Score
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 _getPerformanceColor(
//                                   attendanceRate,
//                                 ).withOpacity(0.3),
//                                 _getPerformanceColor(
//                                   attendanceRate,
//                                 ).withOpacity(0.1),
//                               ],
//                             ),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: _getPerformanceColor(
//                                 attendanceRate,
//                               ).withOpacity(0.4),
//                               width: 1.5,
//                             ),
//                           ),
//                           child: Text(
//                             '${attendanceRate.toStringAsFixed(0)}%',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w800,
//                               color: _getPerformanceColor(attendanceRate),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 16),

//                     // Performance Chart
//                     SizedBox(
//                       height: 60,
//                       child: _buildQuantumPerformanceChart(attendanceRate),
//                     ),

//                     const SizedBox(height: 16),

//                     // Performance Metrics
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         _buildQuantumMetricWithChart(
//                           'ABSENT',
//                           '${avgHours.toStringAsFixed(1)}h',
//                           Icons.access_time_rounded,
//                           avgHours / 10,
//                           Colors.cyan.shade400,
//                         ),
//                         _buildQuantumMetricWithChart(
//                           'LEAVE',
//                           '${productivity.toStringAsFixed(0)}%',
//                           Icons.work_history_rounded,
//                           productivity / 100,
//                           Colors.orange.shade400,
//                         ),
//                         _buildQuantumMetricWithChart(
//                           'PRESENCE',
//                           '${attendanceRate.toStringAsFixed(0)}%',
//                           Icons.verified_user_rounded,
//                           attendanceRate / 100,
//                           Colors.green.shade400,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }),
//       ],
//     );
//   }

//   Widget _buildQuantumPerformanceChart(double attendanceRate) {
//     final spots = [
//       FlSpot(0, 40),
//       FlSpot(1, 60),
//       FlSpot(2, 75),
//       FlSpot(3, 65),
//       FlSpot(4, 85),
//       FlSpot(5, attendanceRate),
//     ];

//     return LineChart(
//       LineChartData(
//         minX: 0,
//         maxX: 5,
//         minY: 0,
//         maxY: 100,
//         lineTouchData: const LineTouchData(enabled: false),
//         lineBarsData: [
//           LineChartBarData(
//             spots: spots,
//             isCurved: true,
//             color: _getPerformanceColor(attendanceRate),
//             barWidth: 3,
//             belowBarData: BarAreaData(
//               show: true,
//               gradient: LinearGradient(
//                 colors: [
//                   _getPerformanceColor(attendanceRate).withOpacity(0.3),
//                   _getPerformanceColor(attendanceRate).withOpacity(0.1),
//                 ],
//               ),
//             ),
//             dotData: const FlDotData(show: false),
//             shadow: Shadow(
//               color: _getPerformanceColor(attendanceRate).withOpacity(0.4),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ),
//         ],
//         gridData: FlGridData(
//           show: true,
//           drawHorizontalLine: true,
//           drawVerticalLine: false,
//           horizontalInterval: 25,
//           getDrawingHorizontalLine: (value) {
//             return FlLine(
//               color: Colors.white.withOpacity(0.1),
//               strokeWidth: 1,
//               dashArray: [4, 4],
//             );
//           },
//         ),
//         titlesData: const FlTitlesData(show: false),
//         borderData: FlBorderData(
//           show: true,
//           border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
//         ),
//       ),
//     );
//   }

//   Color _getPerformanceColor(double rate) {
//     if (rate >= 90) return Colors.green.shade400;
//     if (rate >= 75) return Colors.orange.shade400;
//     if (rate >= 60) return Colors.blue.shade400;
//     return Colors.red.shade400;
//   }

//   Widget _buildQuantumMetricWithChart(
//     String label,
//     String value,
//     IconData icon,
//     double progress,
//     Color color,
//   ) {
//     return Column(
//       children: [
//         // Circular Progress with Icon
//         Stack(
//           alignment: Alignment.center,
//           children: [
//             SizedBox(
//               width: 50,
//               height: 50,
//               child: CircularProgressIndicator(
//                 value: progress,
//                 strokeWidth: 4,
//                 backgroundColor: Colors.white.withOpacity(0.1),
//                 valueColor: AlwaysStoppedAnimation<Color>(color),
//               ),
//             ),
//             Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.2),
//                 shape: BoxShape.circle,
//                 border: Border.all(color: color.withOpacity(0.4), width: 1.5),
//               ),
//               child: Icon(icon, size: 16, color: color),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w800,
//             color: color,
//             letterSpacing: 0.5,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 9,
//             color: Colors.white.withOpacity(0.7),
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.5,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
// }

/* ************************************************************************************************************ */

//      ################################    *******************   ##################################

/* ************************************************************************************************************ */
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// class IndividualGraphs extends StatelessWidget {
//   final AttendanceAnalyticsViewModel viewModel;

//   const IndividualGraphs({super.key, required this.viewModel});

//   @override
//   Widget build(BuildContext context) {
//     final analytics = viewModel.analytics;
//     if (analytics == null) return const SizedBox();

//     final individualData = analytics.individualData;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Individual Performance - ${viewModel.getPeriodDisplayName(viewModel.selectedPeriod)}',
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         // const SizedBox(height: 8),
//         // Text(
//         //   'Detailed view of each team member\'s attendance pattern',
//         //   style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
//         // ),
//         const SizedBox(height: 16),

//         ...viewModel.teamMembers.map((member) {
//           final memberData = individualData[member.email] ?? {};
//           final attendanceRate = memberData['attendanceRate'] ?? 0.0;
//           final avgHours = memberData['avgHours'] ?? 0.0;
//           final productivity = memberData['productivity'] ?? 0.0;

//           return Card(
//             margin: const EdgeInsets.only(bottom: 12),
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
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
//                           color: viewModel
//                               .getPerformanceColor(attendanceRate)
//                               .withOpacity(0.1),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.person_rounded,
//                           size: 20,
//                           color: viewModel.getPerformanceColor(attendanceRate),
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
//                       // Performance Chart
//                       SizedBox(
//                         width: 80,
//                         height: 40,
//                         child: _buildPerformanceChart(attendanceRate),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 12),

//                   // Performance Metrics with Mini Charts
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildMetricWithChart(
//                         'Hours',
//                         '${avgHours.toStringAsFixed(1)}h',
//                         Icons.access_time_rounded,
//                         avgHours / 10,
//                       ),
//                       _buildMetricWithChart(
//                         'Productivity',
//                         '${productivity.toStringAsFixed(0)}%',
//                         Icons.work_rounded,
//                         productivity / 100,
//                       ),
//                       _buildMetricWithChart(
//                         'Attendance',
//                         '${attendanceRate.toStringAsFixed(0)}%',
//                         Icons.check_circle_rounded,
//                         attendanceRate / 100,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }),
//       ],
//     );
//   }

//   Widget _buildPerformanceChart(double attendanceRate) {
//     // Create spots list without using const
//     final spots = [
//       FlSpot(0, 40),
//       FlSpot(1, 60),
//       FlSpot(2, 75),
//       FlSpot(3, 65),
//       FlSpot(4, 85),
//       FlSpot(5, attendanceRate),
//     ];

//     return LineChart(
//       LineChartData(
//         minX: 0,
//         maxX: 5,
//         minY: 0,
//         maxY: 100,
//         lineBarsData: [
//           LineChartBarData(
//             spots: spots,
//             isCurved: true,
//             color: _getChartColor(attendanceRate),
//             barWidth: 2,
//             belowBarData: BarAreaData(
//               show: true,
//               color: _getChartColor(attendanceRate).withOpacity(0.1),
//             ),
//             dotData: const FlDotData(show: false),
//           ),
//         ],
//         gridData: const FlGridData(show: false),
//         titlesData: const FlTitlesData(show: false),
//         borderData: FlBorderData(show: false),
//       ),
//     );
//   }

//   Color _getChartColor(double rate) {
//     if (rate >= 90) return AppColors.success;
//     if (rate >= 75) return AppColors.warning;
//     if (rate >= 60) return AppColors.info;
//     return AppColors.error;
//   }

//   Widget _buildMetricWithChart(
//     String label,
//     String value,
//     IconData icon,
//     double progress,
//   ) {
//     return Column(
//       children: [
//         SizedBox(
//           width: 50,
//           height: 30,
//           child: Stack(
//             children: [
//               CircularProgressIndicator(
//                 value: progress,
//                 strokeWidth: 3,
//                 backgroundColor: AppColors.grey300,
//                 valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//               ),
//               Center(child: Icon(icon, size: 14, color: AppColors.primary)),
//             ],
//           ),
//         ),
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
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:flutter/material.dart';

// class IndividualGraphs extends StatelessWidget {
//   final AttendanceAnalyticsViewModel viewModel;

//   const IndividualGraphs({super.key, required this.viewModel});

//   @override
//   Widget build(BuildContext context) {
//     final analytics = viewModel.analytics;
//     if (analytics == null) return const SizedBox();

//     final individualData = analytics.individualData;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Individual Performance - ${viewModel.getPeriodDisplayName(viewModel.selectedPeriod)}',
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

//         ...viewModel.teamMembers.map((member) {
//           final memberData = individualData[member.email] ?? {};
//           final attendanceRate = memberData['attendanceRate'] ?? 0.0;
//           final avgHours = memberData['avgHours'] ?? 0.0;
//           final productivity = memberData['productivity'] ?? 0.0;

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
//                           color: viewModel
//                               .getPerformanceColor(attendanceRate)
//                               .withOpacity(0.1),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.person_rounded,
//                           size: 20,
//                           color: viewModel.getPerformanceColor(attendanceRate),
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
//                               color: viewModel.getPerformanceColor(
//                                 attendanceRate,
//                               ),
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
//                       viewModel.getPerformanceColor(attendanceRate),
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
// }
