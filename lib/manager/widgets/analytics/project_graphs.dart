// widgets/project_graph.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:AttendanceApp/manager/view_models/projectviewmodels/project_analytics_view_model.dart';

class ProjectGraph extends StatefulWidget {
  final ProjectAnalyticsViewModel viewModel;

  const ProjectGraph({super.key, required this.viewModel});

  @override
  State<ProjectGraph> createState() => _ProjectGraphState();
}

class _ProjectGraphState extends State<ProjectGraph> {
  int _selectedProjectIndex = 0;

  @override
  Widget build(BuildContext context) {
    final projects = widget.viewModel.projects;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (projects.isEmpty) {
      return _buildEmptyState(isDark);
    }

    final selectedProject = projects[_selectedProjectIndex];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(isDark),
          const SizedBox(height: 20),
          _buildHorizontalProjectsList(projects, isDark),
          const SizedBox(height: 20),
          _buildProjectDashboard(selectedProject, isDark),
          const SizedBox(height: 20),
          _buildPieChartSection(selectedProject, isDark),
          const SizedBox(height: 20),
          _buildViewAllButton(isDark),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Project Analytics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.grey.shade800,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? Colors.blue.shade800 : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${widget.viewModel.projects.length} Projects',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.blue.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalProjectsList(List<dynamic> projects, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Project',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              final isSelected = index == _selectedProjectIndex;
              return _buildProjectItem(project, index, isSelected, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProjectItem(
    dynamic project,
    int index,
    bool isSelected,
    bool isDark,
  ) {
    final projectName = _getProjectProperty(project, 'name', 'Unnamed Project');
    final status = _getProjectProperty(project, 'status', 'Active');
    final teamSize = _getProjectProperty(project, 'teamSize', 0);
    final progress = _getProjectProperty(project, 'progress', 0.0);

    final statusColor = _getStatusColor(status);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProjectIndex = index;
        });
      },
      child: Container(
        width: 140,
        margin: EdgeInsets.only(right: 12, left: index == 0 ? 0 : 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? statusColor.withOpacity(0.1)
              : isDark
              ? Colors.grey.shade800
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? statusColor
                : (isDark ? Colors.grey.shade600 : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              projectName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.grey.shade800,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 6),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status.toString().toUpperCase(),
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 10,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '$teamSize members',
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 8,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${(progress as num).toDouble().toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                LinearProgressIndicator(
                  value: (progress).toDouble() / 100,
                  backgroundColor: isDark
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectDashboard(dynamic project, bool isDark) {
    final projectName = _getProjectProperty(
      project,
      'name',
      'Project Dashboard',
    );
    final status = _getProjectProperty(project, 'status', 'Active');
    final teamSize = _getProjectProperty(project, 'teamSize', 0);
    final description = _getProjectProperty(
      project,
      'description',
      'No description available',
    );
    final completedTasks = _getProjectProperty(project, 'completedTasks', 0);
    final totalTasks = _getProjectProperty(project, 'totalTasks', 0);
    final daysRemaining = _getProjectProperty(project, 'daysRemaining', 0);
    final progress = _getProjectProperty(project, 'progress', 0.0);

    final attendanceData = _generateAttendanceData(teamSize as int);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.blue.shade900.withOpacity(0.3)
            : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  projectName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _getStatusColor(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          _buildDashboardStats(attendanceData, teamSize, isDark),
          const SizedBox(height: 16),
          _buildProgressSection(
            progress as double,
            completedTasks as int,
            totalTasks as int,
            daysRemaining as int,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardStats(
    Map<String, int> attendanceData,
    int teamSize,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          'Team',
          teamSize.toString(),
          Icons.people,
          Colors.blue,
          isDark,
        ),
        _buildStatItem(
          'Present',
          attendanceData['present'].toString(),
          Icons.check_circle,
          Colors.green,
          isDark,
        ),
        _buildStatItem(
          'Leave',
          attendanceData['leave'].toString(),
          Icons.beach_access,
          Colors.orange,
          isDark,
        ),
        _buildStatItem(
          'Late',
          attendanceData['late'].toString(),
          Icons.schedule,
          Colors.yellow.shade700,
          isDark,
        ),
        _buildStatItem(
          'Absent',
          attendanceData['absent'].toString(),
          Icons.cancel,
          Colors.red,
          isDark,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(
    double progress,
    int completedTasks,
    int totalTasks,
    int daysRemaining,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Project Progress',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
            Text(
              '${progress.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress / 100,
          backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completedTasks/$totalTasks tasks',
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            Text(
              '$daysRemaining days left',
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPieChartSection(dynamic project, bool isDark) {
    final teamSize = _getProjectProperty(project, 'teamSize', 0) as int;
    final attendanceData = _generateAttendanceData(teamSize);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance Distribution',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
          ),
          child: Row(
            children: [
              Expanded(flex: 2, child: _buildPieChart(attendanceData)),
              Expanded(
                flex: 1,
                child: _buildPieChartLegend(attendanceData, isDark),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(Map<String, int> attendanceData) {
    final present = attendanceData['present']!;
    final absent = attendanceData['absent']!;
    final leave = attendanceData['leave']!;
    final late = attendanceData['late']!;
    final total = present + absent + leave + late;

    if (total == 0) {
      return Center(
        child: Text(
          'No Data',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      );
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          _buildPieSection('Present', present, total, Colors.green),
          _buildPieSection('Late', late, total, Colors.yellow.shade700),
          _buildPieSection('Leave', leave, total, Colors.orange),
          _buildPieSection('Absent', absent, total, Colors.red),
        ],
      ),
    );
  }

  PieChartSectionData _buildPieSection(
    String title,
    int value,
    int total,
    Color color,
  ) {
    final percentage = total > 0 ? (value / total) : 0;

    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: '${(percentage * 100).toStringAsFixed(0)}%',
      radius: 30,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildPieChartLegend(Map<String, int> attendanceData, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(
          'Present',
          attendanceData['present']!,
          Colors.green,
          isDark,
        ),
        _buildLegendItem(
          'Late',
          attendanceData['late']!,
          Colors.yellow.shade700,
          isDark,
        ),
        _buildLegendItem(
          'Leave',
          attendanceData['leave']!,
          Colors.orange,
          isDark,
        ),
        _buildLegendItem(
          'Absent',
          attendanceData['absent']!,
          Colors.red,
          isDark,
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, int value, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildViewAllButton(bool isDark) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Navigate to detailed project view
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.blue.shade600 : Colors.blue.shade700,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: Text(
          'VIEW ALL PROJECT DETAILS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 48,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Projects Available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create projects to see analytics',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods for safe property access
  dynamic _getProjectProperty(
    dynamic project,
    String property,
    dynamic defaultValue,
  ) {
    try {
      if (project is Map) {
        return project[property] ?? defaultValue;
      } else {
        return _getPropertyFromObject(project, property) ?? defaultValue;
      }
    } catch (e) {
      return defaultValue;
    }
  }

  dynamic _getPropertyFromObject(dynamic obj, String property) {
    switch (property) {
      case 'name':
        return obj.name;
      case 'status':
        return obj.status;
      case 'teamSize':
        return obj.teamSize;
      case 'progress':
        return obj.progress;
      case 'description':
        return obj.description;
      case 'completedTasks':
        return obj.completedTasks;
      case 'totalTasks':
        return obj.totalTasks;
      case 'daysRemaining':
        return obj.daysRemaining;
      default:
        return null;
    }
  }

  Map<String, int> _generateAttendanceData(int teamSize) {
    return {
      'present': (teamSize * 0.7).round(),
      'absent': (teamSize * 0.1).round(),
      'leave': (teamSize * 0.15).round(),
      'late': (teamSize * 0.05).round(),
    };
  }

  Color _getStatusColor(String status) {
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.purple;
      case 'on hold':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

// // widgets/project_graph.dart
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:AttendanceApp/view_models/projectviewmodels/project_analytics_view_model.dart';

// class ProjectGraph extends StatefulWidget {
//   final ProjectAnalyticsViewModel viewModel;

//   const ProjectGraph({super.key, required this.viewModel});

//   @override
//   State<ProjectGraph> createState() => _ProjectGraphState();
// }

// class _ProjectGraphState extends State<ProjectGraph> {
//   int _selectedProjectIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     final projects = widget.viewModel.projects;

//     if (projects.isEmpty) {
//       return _buildEmptyState();
//     }

//     final selectedProject = projects[_selectedProjectIndex];

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildHeaderSection(),
//           const SizedBox(height: 20),
//           _buildHorizontalProjectsList(projects),
//           const SizedBox(height: 20),
//           _buildProjectDashboard(selectedProject),
//           const SizedBox(height: 20),
//           _buildPieChartSection(selectedProject),
//           const SizedBox(height: 20),
//           _buildViewAllButton(),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeaderSection() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           'Project Analytics',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//             color: Colors.grey.shade800,
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: Colors.blue.shade50,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             '${widget.viewModel.projects.length} Projects',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: Colors.blue.shade700,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildHorizontalProjectsList(List<dynamic> projects) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Select Project',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey.shade700,
//           ),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           height: 120, // Increased height for better visibility
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             physics: const BouncingScrollPhysics(),
//             itemCount: projects.length,
//             itemBuilder: (context, index) {
//               final project = projects[index];
//               final isSelected = index == _selectedProjectIndex;
//               return _buildProjectItem(project, index, isSelected);
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildProjectItem(dynamic project, int index, bool isSelected) {
//     // Safe property access with null checks
//     final projectName = _getProjectProperty(project, 'name', 'Unnamed Project');
//     final status = _getProjectProperty(project, 'status', 'Active');
//     final teamSize = _getProjectProperty(project, 'teamSize', 0);
//     final progress = _getProjectProperty(project, 'progress', 0.0);

//     final statusColor = _getStatusColor(status);

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedProjectIndex = index;
//         });
//       },
//       child: Container(
//         width: 140,
//         margin: EdgeInsets.only(
//           right: 12,
//           left: index == 0 ? 0 : 0, // No left margin for first item
//         ),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? statusColor.withOpacity(0.1)
//               : Colors.grey.shade50,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: isSelected ? statusColor : Colors.grey.shade300,
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             // Project Name
//             Text(
//               projectName,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey.shade800,
//               ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),

//             const SizedBox(height: 6),

//             // Status Badge
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//               decoration: BoxDecoration(
//                 color: statusColor.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(
//                 status.toString().toUpperCase(),
//                 style: TextStyle(
//                   fontSize: 8,
//                   fontWeight: FontWeight.w700,
//                   color: statusColor,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 6),

//             // Team Members
//             Row(
//               children: [
//                 Icon(Icons.people, size: 10, color: Colors.grey.shade600),
//                 const SizedBox(width: 4),
//                 Text(
//                   '$teamSize members',
//                   style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 6),

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
//                         fontSize: 8,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     Text(
//                       '${(progress as num).toDouble().toStringAsFixed(0)}%',
//                       style: TextStyle(
//                         fontSize: 8,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey.shade800,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 2),
//                 LinearProgressIndicator(
//                   value: (progress).toDouble() / 100,
//                   backgroundColor: Colors.grey.shade300,
//                   valueColor: AlwaysStoppedAnimation<Color>(statusColor),
//                   minHeight: 4,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProjectDashboard(dynamic project) {
//     // Safe property access
//     final projectName = _getProjectProperty(
//       project,
//       'name',
//       'Project Dashboard',
//     );
//     final status = _getProjectProperty(project, 'status', 'Active');
//     final teamSize = _getProjectProperty(project, 'teamSize', 0);
//     final description = _getProjectProperty(
//       project,
//       'description',
//       'No description available',
//     );
//     final completedTasks = _getProjectProperty(project, 'completedTasks', 0);
//     final totalTasks = _getProjectProperty(project, 'totalTasks', 0);
//     final daysRemaining = _getProjectProperty(project, 'daysRemaining', 0);
//     final progress = _getProjectProperty(project, 'progress', 0.0);

//     // Generate sample attendance data
//     final attendanceData = _generateAttendanceData(teamSize as int);

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   projectName,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: _getStatusColor(status).withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Text(
//                   status.toString().toUpperCase(),
//                   style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w700,
//                     color: _getStatusColor(status),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             description,
//             style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 16),
//           _buildDashboardStats(attendanceData, teamSize),
//           const SizedBox(height: 16),
//           _buildProgressSection(
//             progress as double,
//             completedTasks as int,
//             totalTasks as int,
//             daysRemaining as int,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDashboardStats(Map<String, int> attendanceData, int teamSize) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         _buildStatItem('Team', teamSize.toString(), Icons.people, Colors.blue),
//         _buildStatItem(
//           'Present',
//           attendanceData['present'].toString(),
//           Icons.check_circle,
//           Colors.green,
//         ),
//         _buildStatItem(
//           'Leave',
//           attendanceData['leave'].toString(),
//           Icons.beach_access,
//           Colors.orange,
//         ),
//         _buildStatItem(
//           'Late',
//           attendanceData['late'].toString(),
//           Icons.schedule,
//           Colors.yellow,
//         ),
//         _buildStatItem(
//           'Absent',
//           attendanceData['absent'].toString(),
//           Icons.cancel,
//           Colors.red,
//         ),
//       ],
//     );
//   }

//   Widget _buildStatItem(
//     String label,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, size: 16, color: color),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w700,
//             color: Colors.black87,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
//         ),
//       ],
//     );
//   }

//   Widget _buildProgressSection(
//     double progress,
//     int completedTasks,
//     int totalTasks,
//     int daysRemaining,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Project Progress',
//               style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
//             ),
//             Text(
//               '${progress.toStringAsFixed(1)}%',
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.black87,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         LinearProgressIndicator(
//           value: progress / 100,
//           backgroundColor: Colors.grey.shade300,
//           valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
//           minHeight: 8,
//           borderRadius: BorderRadius.circular(4),
//         ),
//         const SizedBox(height: 4),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               '$completedTasks/$totalTasks tasks',
//               style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
//             ),
//             Text(
//               '$daysRemaining days left',
//               style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildPieChartSection(dynamic project) {
//     final teamSize = _getProjectProperty(project, 'teamSize', 0) as int;
//     final attendanceData = _generateAttendanceData(teamSize);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Attendance Distribution',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey.shade800,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Container(
//           height: 200,
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             color: Colors.grey.shade50,
//           ),
//           child: Row(
//             children: [
//               Expanded(flex: 2, child: _buildPieChart(attendanceData)),
//               Expanded(flex: 1, child: _buildPieChartLegend(attendanceData)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPieChart(Map<String, int> attendanceData) {
//     final present = attendanceData['present']!;
//     final absent = attendanceData['absent']!;
//     final leave = attendanceData['leave']!;
//     final late = attendanceData['late']!;
//     final total = present + absent + leave + late;

//     if (total == 0) {
//       return Center(
//         child: Text(
//           'No Data',
//           style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
//         ),
//       );
//     }

//     return PieChart(
//       PieChartData(
//         sectionsSpace: 2,
//         centerSpaceRadius: 40,
//         sections: [
//           _buildPieSection('Present', present, total, Colors.green),
//           _buildPieSection('Late', late, total, Colors.yellow),
//           _buildPieSection('Leave', leave, total, Colors.orange),
//           _buildPieSection('Absent', absent, total, Colors.red),
//         ],
//       ),
//     );
//   }

//   PieChartSectionData _buildPieSection(
//     String title,
//     int value,
//     int total,
//     Color color,
//   ) {
//     final percentage = total > 0 ? (value / total) : 0;

//     return PieChartSectionData(
//       color: color,
//       value: value.toDouble(),
//       title: '${(percentage * 100).toStringAsFixed(0)}%',
//       radius: 30,
//       titleStyle: const TextStyle(
//         fontSize: 12,
//         fontWeight: FontWeight.w600,
//         color: Colors.white,
//       ),
//     );
//   }

//   Widget _buildPieChartLegend(Map<String, int> attendanceData) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         _buildLegendItem('Present', attendanceData['present']!, Colors.green),
//         _buildLegendItem('Late', attendanceData['late']!, Colors.yellow),
//         _buildLegendItem('Leave', attendanceData['leave']!, Colors.orange),
//         _buildLegendItem('Absent', attendanceData['absent']!, Colors.red),
//       ],
//     );
//   }

//   Widget _buildLegendItem(String label, int value, Color color) {
//     return Row(
//       children: [
//         Container(
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             label,
//             style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
//           ),
//         ),
//         Text(
//           value.toString(),
//           style: const TextStyle(
//             fontSize: 10,
//             fontWeight: FontWeight.w700,
//             color: Colors.black87,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildViewAllButton() {
//     return Center(
//       child: ElevatedButton(
//         onPressed: () {
//           // Navigate to detailed project view
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.blue.shade600,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         ),
//         child: const Text(
//           'VIEW ALL PROJECT DETAILS',
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w700,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Container(
//       padding: const EdgeInsets.all(40),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.work_outline, size: 48, color: Colors.grey.shade400),
//           const SizedBox(height: 16),
//           Text(
//             'No Projects Available',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Create projects to see analytics',
//             style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper methods for safe property access
//   dynamic _getProjectProperty(
//     dynamic project,
//     String property,
//     dynamic defaultValue,
//   ) {
//     try {
//       if (project is Map) {
//         return project[property] ?? defaultValue;
//       } else {
//         // Use reflection or direct property access
//         return _getPropertyFromObject(project, property) ?? defaultValue;
//       }
//     } catch (e) {
//       return defaultValue;
//     }
//   }

//   dynamic _getPropertyFromObject(dynamic obj, String property) {
//     // Simple property access - you might need to adjust this based on your actual Project class
//     switch (property) {
//       case 'name':
//         return obj.name;
//       case 'status':
//         return obj.status;
//       case 'teamSize':
//         return obj.teamSize;
//       case 'progress':
//         return obj.progress;
//       case 'description':
//         return obj.description;
//       case 'completedTasks':
//         return obj.completedTasks;
//       case 'totalTasks':
//         return obj.totalTasks;
//       case 'daysRemaining':
//         return obj.daysRemaining;
//       default:
//         return null;
//     }
//   }

//   Map<String, int> _generateAttendanceData(int teamSize) {
//     return {
//       'present': (teamSize * 0.7).round(),
//       'absent': (teamSize * 0.1).round(),
//       'leave': (teamSize * 0.15).round(),
//       'late': (teamSize * 0.05).round(),
//     };
//   }

//   Color _getStatusColor(String status) {
//     final statusStr = status.toString().toLowerCase();
//     switch (statusStr) {
//       case 'active':
//         return Colors.green;
//       case 'completed':
//         return Colors.purple;
//       case 'on hold':
//         return Colors.orange;
//       default:
//         return Colors.blue;
//     }
//   }
// }

// // widgets/project_graph.dart
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:AttendanceApp/view_models/projectviewmodels/project_analytics_view_model.dart';
// import 'package:AttendanceApp/models/projectmodels/project_analytics_model.dart';

// class ProjectGraph extends StatefulWidget {
//   final ProjectAnalyticsViewModel viewModel;

//   const ProjectGraph({super.key, required this.viewModel});

//   @override
//   State<ProjectGraph> createState() => _ProjectGraphState();
// }

// class _ProjectGraphState extends State<ProjectGraph>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _barAnimation;
//   final ScrollController _horizontalScrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//   }

//   void _initializeAnimations() {
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );

//     _barAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOutCubic,
//     );

//     _animationController.forward();
//   }

//   @override
//   void didUpdateWidget(ProjectGraph oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.viewModel.analytics != widget.viewModel.analytics ||
//         oldWidget.viewModel.selectedPeriod != widget.viewModel.selectedPeriod) {
//       _animationController.reset();
//       _animationController.forward();
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _horizontalScrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final analytics = widget.viewModel.analytics;

//     if (analytics == null) {
//       return _buildLoadingState();
//     }

//     return _buildGraphCard(analytics);
//   }

//   Widget _buildLoadingState() {
//     return SizedBox(
//       height: 650,
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.white.withOpacity(0.15),
//               Colors.white.withOpacity(0.05),
//             ],
//           ),
//           border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//         ),
//         child: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(color: Colors.purple, strokeWidth: 3),
//               SizedBox(height: 16),
//               Text(
//                 'LOADING PROJECT ANALYTICS...',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   letterSpacing: 1.0,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGraphCard(ProjectAnalytics analytics) {
//     return SizedBox(
//       height: 650,
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.white.withOpacity(0.15),
//               Colors.white.withOpacity(0.05),
//             ],
//           ),
//           border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 20,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(20),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHeaderSection(),
//                 const SizedBox(height: 10),
//                 _buildGraphSection(analytics),
//                 const SizedBox(height: 20),
//                 _buildHorizontalProjectsList(),
//                 const SizedBox(height: 20),
//                 _buildLegendSection(analytics),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '${widget.viewModel.getPeriodDisplayName(widget.viewModel.selectedPeriod)} Project Analytics',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                       letterSpacing: 0.8,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     widget.viewModel.getGraphSubtitle(),
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.white.withOpacity(0.7),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             _buildProjectCountBadge(),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildProjectCountBadge() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.purple.shade400.withOpacity(0.3),
//             Colors.indigo.shade400.withOpacity(0.2),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
//       ),
//       child: Text(
//         '${widget.viewModel.projects.length} PROJECTS',
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w800,
//           color: Colors.white,
//           letterSpacing: 0.8,
//         ),
//       ),
//     );
//   }

//   Widget _buildHorizontalProjectsList() {
//     final projects = widget.viewModel.projects;

//     if (projects.isEmpty) {
//       return Container(
//         height: 120,
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           color: Colors.white.withOpacity(0.05),
//           border: Border.all(color: Colors.white.withOpacity(0.1)),
//         ),
//         child: Center(
//           child: Text(
//             'No Projects Available',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.6),
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(bottom: 12),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'PROJECTS LIST',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white.withOpacity(0.8),
//                   letterSpacing: 1.0,
//                 ),
//               ),
//               Text(
//                 '${projects.length} projects →',
//                 style: TextStyle(
//                   fontSize: 10,
//                   color: Colors.white.withOpacity(0.6),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Container(
//           height: 120,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             color: Colors.white.withOpacity(0.05),
//             border: Border.all(color: Colors.white.withOpacity(0.1)),
//           ),
//           child: _buildHorizontalListView(projects),
//         ),
//       ],
//     );
//   }

//   Widget _buildHorizontalListView(List<dynamic> projects) {
//     return Scrollbar(
//       controller: _horizontalScrollController,
//       thumbVisibility: true,
//       trackVisibility: true,
//       child: ListView.builder(
//         controller: _horizontalScrollController,
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         itemCount: projects.length,
//         itemBuilder: (context, index) {
//           final project = projects[index];
//           return _buildProjectItem(project, index);
//         },
//       ),
//     );
//   }

//   Widget _buildProjectItem(dynamic project, int index) {
//     final status = project.status?.toLowerCase() ?? 'planning';
//     Color statusColor;

//     switch (status) {
//       case 'active':
//         statusColor = Colors.green.shade400;
//         break;
//       case 'completed':
//         statusColor = Colors.purple.shade400;
//         break;
//       case 'on hold':
//         statusColor = Colors.orange.shade400;
//         break;
//       default:
//         statusColor = Colors.blue.shade400;
//     }

//     return Container(
//       width: 160,
//       margin: const EdgeInsets.only(right: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         gradient: LinearGradient(
//           colors: [
//             statusColor.withOpacity(0.15),
//             statusColor.withOpacity(0.05),
//           ],
//         ),
//         border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Project Name
//           Text(
//             project.name ?? 'Unnamed Project',
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w700,
//               color: Colors.white,
//               overflow: TextOverflow.ellipsis,
//             ),
//             maxLines: 2,
//           ),

//           const SizedBox(height: 6),

//           // Project Status
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//             decoration: BoxDecoration(
//               color: statusColor.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(4),
//               border: Border.all(color: statusColor.withOpacity(0.4)),
//             ),
//             child: Text(
//               project.status?.toUpperCase() ?? 'PLANNING',
//               style: TextStyle(
//                 fontSize: 9,
//                 fontWeight: FontWeight.w800,
//                 color: statusColor,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ),

//           const SizedBox(height: 6),

//           // Team Members Count
//           Row(
//             children: [
//               Icon(
//                 Icons.people_outline,
//                 size: 10,
//                 color: Colors.white.withOpacity(0.6),
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 '${project.assignedTeam?.length ?? 0} members',
//                 style: TextStyle(
//                   fontSize: 9,
//                   color: Colors.white.withOpacity(0.6),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGraphSection(ProjectAnalytics analytics) {
//     return SizedBox(height: 200, child: _buildFLChartGraph(analytics));
//   }

//   Widget _buildFLChartGraph(ProjectAnalytics analytics) {
//     final graphData = analytics.graphData;
//     final labels = analytics.labels;

//     if (labels.isEmpty) {
//       return Center(
//         child: Text(
//           'NO PROJECT DATA AVAILABLE',
//           style: TextStyle(
//             color: Colors.white.withOpacity(0.7),
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.8,
//           ),
//         ),
//       );
//     }

//     return AnimatedBuilder(
//       animation: _barAnimation,
//       builder: (context, child) {
//         return BarChart(
//           BarChartData(
//             alignment: BarChartAlignment.spaceAround,
//             maxY: _getMaxGraphValue(graphData),
//             minY: 0,
//             groupsSpace: _calculateGroupSpace(labels.length),
//             barTouchData: BarTouchData(
//               enabled: true,
//               touchTooltipData: BarTouchTooltipData(
//                 getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                   final status = [
//                     'Planning',
//                     'Active',
//                     'Completed',
//                     'On Hold',
//                   ][rodIndex];
//                   final value =
//                       rod.toY -
//                       (rodIndex > 0
//                           ? _getPreviousRodValue(group, rodIndex)
//                           : 0);

//                   return BarTooltipItem(
//                     '$status\n${value.toInt()}',
//                     const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   );
//                 },
//               ),
//             ),
//             titlesData: _buildTitlesData(labels),
//             gridData: FlGridData(
//               show: true,
//               drawVerticalLine: false,
//               horizontalInterval: _getGridInterval(graphData),
//               getDrawingHorizontalLine: (value) {
//                 return FlLine(
//                   color: Colors.white.withOpacity(0.1),
//                   strokeWidth: 1,
//                   dashArray: [4, 4],
//                 );
//               },
//             ),
//             borderData: FlBorderData(
//               show: true,
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.2),
//                 width: 1.5,
//               ),
//             ),
//             barGroups: _buildBarGroups(graphData, labels),
//           ),
//         );
//       },
//     );
//   }

//   double _getPreviousRodValue(BarChartGroupData group, int currentRodIndex) {
//     double previousValue = 0;
//     for (int i = 0; i < currentRodIndex; i++) {
//       previousValue += group.barRods[i].toY;
//     }
//     return previousValue;
//   }

//   List<BarChartGroupData> _buildBarGroups(
//     Map<String, List<double>> graphData,
//     List<String> labels,
//   ) {
//     return labels.asMap().entries.map((entry) {
//       final index = entry.key;
//       final planning =
//           (graphData['planning']?[index] ?? 0.0) * _barAnimation.value;
//       final active = (graphData['active']?[index] ?? 0.0) * _barAnimation.value;
//       final completed =
//           (graphData['completed']?[index] ?? 0.0) * _barAnimation.value;
//       final onHold = (graphData['onHold']?[index] ?? 0.0) * _barAnimation.value;

//       return BarChartGroupData(
//         x: index,
//         groupVertically: true,
//         barRods: [
//           BarChartRodData(
//             toY: planning,
//             color: Colors.blue.shade400,
//             width: _calculateBarWidth(labels.length),
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(6),
//               topRight: Radius.circular(6),
//             ),
//           ),
//           BarChartRodData(
//             toY: planning + active,
//             fromY: planning,
//             color: Colors.green.shade400,
//             width: _calculateBarWidth(labels.length),
//           ),
//           BarChartRodData(
//             toY: planning + active + completed,
//             fromY: planning + active,
//             color: Colors.purple.shade400,
//             width: _calculateBarWidth(labels.length),
//           ),
//           BarChartRodData(
//             toY: planning + active + completed + onHold,
//             fromY: planning + active + completed,
//             color: Colors.orange.shade400,
//             width: _calculateBarWidth(labels.length),
//             borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(6),
//               bottomRight: Radius.circular(6),
//             ),
//           ),
//         ],
//         showingTooltipIndicators: [0, 1, 2, 3],
//       );
//     }).toList();
//   }

//   FlTitlesData _buildTitlesData(List<String> labels) {
//     return FlTitlesData(
//       show: true,
//       leftTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 40,
//           interval: _getLeftInterval(),
//           getTitlesWidget: (value, meta) {
//             return Padding(
//               padding: const EdgeInsets.only(right: 8),
//               child: Text(
//                 value.toInt().toString(),
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.8),
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//       rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       bottomTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 32,
//           getTitlesWidget: (value, meta) {
//             final index = value.toInt();
//             if (index >= 0 && index < labels.length) {
//               return Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: Text(
//                   labels[index],
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.8),
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               );
//             }
//             return const SizedBox();
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildLegendSection(ProjectAnalytics analytics) {
//     final percentages = analytics.statusDistribution;

//     return Center(
//       child: Wrap(
//         alignment: WrapAlignment.center,
//         spacing: 12,
//         runSpacing: 12,
//         children: [
//           _buildLegendItem(
//             'Planning',
//             Colors.blue.shade400,
//             percentages['planning'] ?? 0,
//           ),
//           _buildLegendItem(
//             'Active',
//             Colors.green.shade400,
//             percentages['active'] ?? 0,
//           ),
//           _buildLegendItem(
//             'Completed',
//             Colors.purple.shade400,
//             percentages['completed'] ?? 0,
//           ),
//           _buildLegendItem(
//             'On Hold',
//             Colors.orange.shade400,
//             percentages['onHold'] ?? 0,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLegendItem(String text, Color color, double percentage) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.4), width: 1.5),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 12,
//                 height: 12,
//                 decoration: BoxDecoration(
//                   color: color,
//                   borderRadius: BorderRadius.circular(3),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 text,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w800,
//                   color: color,
//                   letterSpacing: 0.8,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             '${percentage.toStringAsFixed(1)}%',
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w800,
//               color: Colors.white,
//               letterSpacing: 0.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   double _getMaxGraphValue(Map<String, List<double>> graphData) {
//     double maxValue = 0.0;
//     for (final values in graphData.values) {
//       for (final value in values) {
//         if (value > maxValue) maxValue = value;
//       }
//     }
//     return maxValue > 0 ? maxValue * 1.2 : 10.0;
//   }

//   double _getGridInterval(Map<String, List<double>> graphData) {
//     final maxValue = _getMaxGraphValue(graphData);
//     if (maxValue <= 5) return 1;
//     if (maxValue <= 10) return 2;
//     return (maxValue / 5).roundToDouble();
//   }

//   double _getLeftInterval() {
//     final maxValue = _getMaxGraphValue(
//       widget.viewModel.analytics?.graphData ?? {},
//     );
//     if (maxValue <= 5) return 1;
//     if (maxValue <= 10) return 2;
//     return (maxValue / 5).roundToDouble();
//   }

//   double _calculateGroupSpace(int labelCount) {
//     if (labelCount <= 6) return 12;
//     if (labelCount <= 12) return 8;
//     return 4;
//   }

//   double _calculateBarWidth(int labelCount) {
//     if (labelCount <= 6) return 16;
//     if (labelCount <= 12) return 12;
//     return 8;
//   }
// }

// // widgets/project_graph.dart
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:AttendanceApp/view_models/projectviewmodels/project_analytics_view_model.dart';
// import 'package:AttendanceApp/models/projectmodels/project_analytics_model.dart';

// class ProjectGraph extends StatefulWidget {
//   final ProjectAnalyticsViewModel viewModel;

//   const ProjectGraph({super.key, required this.viewModel});

//   @override
//   State<ProjectGraph> createState() => _ProjectGraphState();
// }

// class _ProjectGraphState extends State<ProjectGraph>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _barAnimation;
//   final ScrollController _horizontalScrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//   }

//   void _initializeAnimations() {
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );

//     _barAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOutCubic,
//     );

//     _animationController.forward();
//   }

//   @override
//   void didUpdateWidget(ProjectGraph oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.viewModel.analytics != widget.viewModel.analytics ||
//         oldWidget.viewModel.selectedPeriod != widget.viewModel.selectedPeriod) {
//       _animationController.reset();
//       _animationController.forward();
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _horizontalScrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final analytics = widget.viewModel.analytics;

//     if (analytics == null) {
//       return _buildLoadingState();
//     }

//     return _buildGraphCard(analytics);
//   }

//   Widget _buildLoadingState() {
//     return Container(
//       height: 380,
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
//       ),
//       child: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(color: Colors.purple, strokeWidth: 3),
//             SizedBox(height: 16),
//             Text(
//               'LOADING PROJECT ANALYTICS...',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 1.0,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGraphCard(ProjectAnalytics analytics) {
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
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeaderSection(),
//               const SizedBox(height: 10),
//               _buildGraphSection(analytics),
//               const SizedBox(height: 20),
//               _buildHorizontalProjectsList(), // NEW: Horizontal projects list
//               const SizedBox(height: 20),
//               _buildLegendSection(analytics),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '${widget.viewModel.getPeriodDisplayName(widget.viewModel.selectedPeriod)} Project Analytics',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                       letterSpacing: 0.8,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     widget.viewModel.getGraphSubtitle(),
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.white.withOpacity(0.7),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             _buildProjectCountBadge(),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildProjectCountBadge() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.purple.shade400.withOpacity(0.3),
//             Colors.indigo.shade400.withOpacity(0.2),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
//       ),
//       child: Text(
//         '${widget.viewModel.projects.length} PROJECTS',
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w800,
//           color: Colors.white,
//           letterSpacing: 0.8,
//         ),
//       ),
//     );
//   }

//   // NEW: Horizontal Projects List
//   Widget _buildHorizontalProjectsList() {
//     final projects = widget.viewModel.projects;

//     if (projects.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           color: Colors.white.withOpacity(0.05),
//           border: Border.all(color: Colors.white.withOpacity(0.1)),
//         ),
//         child: Center(
//           child: Text(
//             'No Projects Available',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.6),
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(bottom: 12),
//           child: Text(
//             'PROJECTS LIST',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w700,
//               color: Colors.white.withOpacity(0.8),
//               letterSpacing: 1.0,
//             ),
//           ),
//         ),
//         Container(
//           height: 80,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             color: Colors.white.withOpacity(0.05),
//             border: Border.all(color: Colors.white.withOpacity(0.1)),
//           ),
//           child: Scrollbar(
//             controller: _horizontalScrollController,
//             thumbVisibility: true,
//             child: ListView.builder(
//               controller: _horizontalScrollController,
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               itemCount: projects.length,
//               itemBuilder: (context, index) {
//                 final project = projects[index];
//                 return _buildProjectItem(project, index);
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // NEW: Individual Project Item for Horizontal List
//   Widget _buildProjectItem(dynamic project, int index) {
//     final status = project.status?.toLowerCase() ?? 'planning';
//     Color statusColor;

//     switch (status) {
//       case 'active':
//         statusColor = Colors.green.shade400;
//         break;
//       case 'completed':
//         statusColor = Colors.purple.shade400;
//         break;
//       case 'on hold':
//         statusColor = Colors.orange.shade400;
//         break;
//       default:
//         statusColor = Colors.blue.shade400;
//     }

//     return Container(
//       width: 160,
//       margin: const EdgeInsets.only(right: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         gradient: LinearGradient(
//           colors: [
//             statusColor.withOpacity(0.15),
//             statusColor.withOpacity(0.05),
//           ],
//         ),
//         border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Project Name
//           Text(
//             project.name ?? 'Unnamed Project',
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w700,
//               color: Colors.white,
//               overflow: TextOverflow.ellipsis,
//             ),
//             maxLines: 1,
//           ),

//           // Project Status
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: statusColor.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(4),
//               border: Border.all(color: statusColor.withOpacity(0.4)),
//             ),
//             child: Text(
//               project.status?.toUpperCase() ?? 'PLANNING',
//               style: TextStyle(
//                 fontSize: 9,
//                 fontWeight: FontWeight.w800,
//                 color: statusColor,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ),

//           // Team Members Count
//           Row(
//             children: [
//               Icon(
//                 Icons.people_outline,
//                 size: 10,
//                 color: Colors.white.withOpacity(0.6),
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 '${project.assignedTeam?.length ?? 0} members',
//                 style: TextStyle(
//                   fontSize: 9,
//                   color: Colors.white.withOpacity(0.6),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGraphSection(ProjectAnalytics analytics) {
//     return SizedBox(height: 280, child: _buildFLChartGraph(analytics));
//   }

//   Widget _buildFLChartGraph(ProjectAnalytics analytics) {
//     final graphData = analytics.graphData;
//     final labels = analytics.labels;

//     if (labels.isEmpty) {
//       return Center(
//         child: Text(
//           'NO PROJECT DATA AVAILABLE',
//           style: TextStyle(
//             color: Colors.white.withOpacity(0.7),
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.8,
//           ),
//         ),
//       );
//     }

//     return AnimatedBuilder(
//       animation: _barAnimation,
//       builder: (context, child) {
//         return BarChart(
//           BarChartData(
//             alignment: BarChartAlignment.spaceAround,
//             maxY: _getMaxGraphValue(graphData),
//             minY: 0,
//             groupsSpace: _calculateGroupSpace(labels.length),
//             barTouchData: BarTouchData(
//               enabled: true,
//               touchTooltipData: BarTouchTooltipData(
//                 getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                   final status = [
//                     'Planning',
//                     'Active',
//                     'Completed',
//                     'On Hold',
//                   ][rodIndex];
//                   final value =
//                       rod.toY -
//                       (rodIndex > 0
//                           ? _getPreviousRodValue(group, rodIndex)
//                           : 0);

//                   return BarTooltipItem(
//                     '$status\n${value.toInt()}',
//                     const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   );
//                 },
//               ),
//             ),
//             titlesData: _buildTitlesData(labels),
//             gridData: FlGridData(
//               show: true,
//               drawVerticalLine: false,
//               horizontalInterval: _getGridInterval(graphData),
//               getDrawingHorizontalLine: (value) {
//                 return FlLine(
//                   color: Colors.white.withOpacity(0.1),
//                   strokeWidth: 1,
//                   dashArray: [4, 4],
//                 );
//               },
//             ),
//             borderData: FlBorderData(
//               show: true,
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.2),
//                 width: 1.5,
//               ),
//             ),
//             barGroups: _buildBarGroups(graphData, labels),
//           ),
//         );
//       },
//     );
//   }

//   double _getPreviousRodValue(BarChartGroupData group, int currentRodIndex) {
//     double previousValue = 0;
//     for (int i = 0; i < currentRodIndex; i++) {
//       previousValue += group.barRods[i].toY;
//     }
//     return previousValue;
//   }

//   List<BarChartGroupData> _buildBarGroups(
//     Map<String, List<double>> graphData,
//     List<String> labels,
//   ) {
//     return labels.asMap().entries.map((entry) {
//       final index = entry.key;
//       final planning =
//           (graphData['planning']?[index] ?? 0.0) * _barAnimation.value;
//       final active = (graphData['active']?[index] ?? 0.0) * _barAnimation.value;
//       final completed =
//           (graphData['completed']?[index] ?? 0.0) * _barAnimation.value;
//       final onHold = (graphData['onHold']?[index] ?? 0.0) * _barAnimation.value;

//       return BarChartGroupData(
//         x: index,
//         groupVertically: true,
//         barRods: [
//           BarChartRodData(
//             toY: planning,
//             color: Colors.blue.shade400,
//             width: _calculateBarWidth(labels.length),
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(6),
//               topRight: Radius.circular(6),
//             ),
//           ),
//           BarChartRodData(
//             toY: planning + active,
//             fromY: planning,
//             color: Colors.green.shade400,
//             width: _calculateBarWidth(labels.length),
//           ),
//           BarChartRodData(
//             toY: planning + active + completed,
//             fromY: planning + active,
//             color: Colors.purple.shade400,
//             width: _calculateBarWidth(labels.length),
//           ),
//           BarChartRodData(
//             toY: planning + active + completed + onHold,
//             fromY: planning + active + completed,
//             color: Colors.orange.shade400,
//             width: _calculateBarWidth(labels.length),
//             borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(6),
//               bottomRight: Radius.circular(6),
//             ),
//           ),
//         ],
//         showingTooltipIndicators: [0, 1, 2, 3],
//       );
//     }).toList();
//   }

//   FlTitlesData _buildTitlesData(List<String> labels) {
//     return FlTitlesData(
//       show: true,
//       leftTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 40,
//           interval: _getLeftInterval(),
//           getTitlesWidget: (value, meta) {
//             return Padding(
//               padding: const EdgeInsets.only(right: 8),
//               child: Text(
//                 value.toInt().toString(),
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.8),
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//       rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       bottomTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 32,
//           getTitlesWidget: (value, meta) {
//             final index = value.toInt();
//             if (index >= 0 && index < labels.length) {
//               return Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: Text(
//                   labels[index],
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.8),
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               );
//             }
//             return const SizedBox();
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildLegendSection(ProjectAnalytics analytics) {
//     final percentages = analytics.statusDistribution;

//     return Center(
//       child: Wrap(
//         alignment: WrapAlignment.center,
//         spacing: 12,
//         runSpacing: 12,
//         children: [
//           _buildLegendItem(
//             'Planning',
//             Colors.blue.shade400,
//             percentages['planning'] ?? 0,
//           ),
//           _buildLegendItem(
//             'Active',
//             Colors.green.shade400,
//             percentages['active'] ?? 0,
//           ),
//           _buildLegendItem(
//             'Completed',
//             Colors.purple.shade400,
//             percentages['completed'] ?? 0,
//           ),
//           _buildLegendItem(
//             'On Hold',
//             Colors.orange.shade400,
//             percentages['onHold'] ?? 0,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLegendItem(String text, Color color, double percentage) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.4), width: 1.5),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 12,
//                 height: 12,
//                 decoration: BoxDecoration(
//                   color: color,
//                   borderRadius: BorderRadius.circular(3),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 text,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w800,
//                   color: color,
//                   letterSpacing: 0.8,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             '${percentage.toStringAsFixed(1)}%',
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w800,
//               color: Colors.white,
//               letterSpacing: 0.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   double _getMaxGraphValue(Map<String, List<double>> graphData) {
//     double maxValue = 0.0;
//     for (final values in graphData.values) {
//       for (final value in values) {
//         if (value > maxValue) maxValue = value;
//       }
//     }
//     return maxValue > 0 ? maxValue * 1.2 : 10.0; // Add 20% padding
//   }

//   double _getGridInterval(Map<String, List<double>> graphData) {
//     final maxValue = _getMaxGraphValue(graphData);
//     if (maxValue <= 5) return 1;
//     if (maxValue <= 10) return 2;
//     return (maxValue / 5).roundToDouble();
//   }

//   double _getLeftInterval() {
//     final maxValue = _getMaxGraphValue(
//       widget.viewModel.analytics?.graphData ?? {},
//     );
//     if (maxValue <= 5) return 1;
//     if (maxValue <= 10) return 2;
//     return (maxValue / 5).roundToDouble();
//   }

//   double _calculateGroupSpace(int labelCount) {
//     if (labelCount <= 6) return 12;
//     if (labelCount <= 12) return 8;
//     return 4;
//   }

//   double _calculateBarWidth(int labelCount) {
//     if (labelCount <= 6) return 16;
//     if (labelCount <= 12) return 12;
//     return 8;
//   }
// }

// // widgets/project_graph.dart
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:AttendanceApp/view_models/projectviewmodels/project_analytics_view_model.dart';
// import 'package:AttendanceApp/models/projectmodels/project_analytics_model.dart';

// class ProjectGraph extends StatefulWidget {
//   final ProjectAnalyticsViewModel viewModel;

//   const ProjectGraph({super.key, required this.viewModel});

//   @override
//   State<ProjectGraph> createState() => _ProjectGraphState();
// }

// class _ProjectGraphState extends State<ProjectGraph>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _barAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//   }

//   void _initializeAnimations() {
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );

//     _barAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOutCubic,
//     );

//     _animationController.forward();
//   }

//   @override
//   void didUpdateWidget(ProjectGraph oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.viewModel.analytics != widget.viewModel.analytics ||
//         oldWidget.viewModel.selectedPeriod != widget.viewModel.selectedPeriod) {
//       _animationController.reset();
//       _animationController.forward();
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final analytics = widget.viewModel.analytics;

//     if (analytics == null) {
//       return _buildLoadingState();
//     }

//     return _buildGraphCard(analytics);
//   }

//   Widget _buildLoadingState() {
//     return Container(
//       height: 380,
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
//       ),
//       child: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(color: Colors.purple, strokeWidth: 3),
//             SizedBox(height: 16),
//             Text(
//               'LOADING PROJECT ANALYTICS...',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 1.0,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGraphCard(ProjectAnalytics analytics) {
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
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeaderSection(),
//               const SizedBox(height: 10),
//               _buildGraphSection(analytics),
//               const SizedBox(height: 20),
//               _buildLegendSection(analytics),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '${widget.viewModel.getPeriodDisplayName(widget.viewModel.selectedPeriod)} Project Analytics',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                       letterSpacing: 0.8,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     widget.viewModel.getGraphSubtitle(),
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.white.withOpacity(0.7),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             _buildProjectCountBadge(),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildProjectCountBadge() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.purple.shade400.withOpacity(0.3),
//             Colors.indigo.shade400.withOpacity(0.2),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
//       ),
//       child: Text(
//         '${widget.viewModel.projects.length} PROJECTS',
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w800,
//           color: Colors.white,
//           letterSpacing: 0.8,
//         ),
//       ),
//     );
//   }

//   Widget _buildGraphSection(ProjectAnalytics analytics) {
//     return SizedBox(height: 280, child: _buildFLChartGraph(analytics));
//   }

//   Widget _buildFLChartGraph(ProjectAnalytics analytics) {
//     final graphData = analytics.graphData;
//     final labels = analytics.labels;

//     if (labels.isEmpty) {
//       return Center(
//         child: Text(
//           'NO PROJECT DATA AVAILABLE',
//           style: TextStyle(
//             color: Colors.white.withOpacity(0.7),
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.8,
//           ),
//         ),
//       );
//     }

//     return AnimatedBuilder(
//       animation: _barAnimation,
//       builder: (context, child) {
//         return BarChart(
//           BarChartData(
//             alignment: BarChartAlignment.spaceAround,
//             maxY: _getMaxGraphValue(graphData),
//             minY: 0,
//             groupsSpace: _calculateGroupSpace(labels.length),
//             barTouchData: BarTouchData(
//               enabled: true,
//               touchTooltipData: BarTouchTooltipData(
//                 getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                   final status = [
//                     'Planning',
//                     'Active',
//                     'Completed',
//                     'On Hold',
//                   ][rodIndex];
//                   final value =
//                       rod.toY -
//                       (rodIndex > 0
//                           ? _getPreviousRodValue(group, rodIndex)
//                           : 0);

//                   return BarTooltipItem(
//                     '$status\n${value.toInt()}',
//                     const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   );
//                 },
//               ),
//             ),
//             titlesData: _buildTitlesData(labels),
//             gridData: FlGridData(
//               show: true,
//               drawVerticalLine: false,
//               horizontalInterval: _getGridInterval(graphData),
//               getDrawingHorizontalLine: (value) {
//                 return FlLine(
//                   color: Colors.white.withOpacity(0.1),
//                   strokeWidth: 1,
//                   dashArray: [4, 4],
//                 );
//               },
//             ),
//             borderData: FlBorderData(
//               show: true,
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.2),
//                 width: 1.5,
//               ),
//             ),
//             barGroups: _buildBarGroups(graphData, labels),
//           ),
//         );
//       },
//     );
//   }

//   double _getPreviousRodValue(BarChartGroupData group, int currentRodIndex) {
//     double previousValue = 0;
//     for (int i = 0; i < currentRodIndex; i++) {
//       previousValue += group.barRods[i].toY;
//     }
//     return previousValue;
//   }

//   List<BarChartGroupData> _buildBarGroups(
//     Map<String, List<double>> graphData,
//     List<String> labels,
//   ) {
//     return labels.asMap().entries.map((entry) {
//       final index = entry.key;
//       final planning =
//           (graphData['planning']?[index] ?? 0.0) * _barAnimation.value;
//       final active = (graphData['active']?[index] ?? 0.0) * _barAnimation.value;
//       final completed =
//           (graphData['completed']?[index] ?? 0.0) * _barAnimation.value;
//       final onHold = (graphData['onHold']?[index] ?? 0.0) * _barAnimation.value;

//       return BarChartGroupData(
//         x: index,
//         groupVertically: true,
//         barRods: [
//           BarChartRodData(
//             toY: planning,
//             color: Colors.blue.shade400,
//             width: _calculateBarWidth(labels.length),
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(6),
//               topRight: Radius.circular(6),
//             ),
//           ),
//           BarChartRodData(
//             toY: planning + active,
//             fromY: planning,
//             color: Colors.green.shade400,
//             width: _calculateBarWidth(labels.length),
//           ),
//           BarChartRodData(
//             toY: planning + active + completed,
//             fromY: planning + active,
//             color: Colors.purple.shade400,
//             width: _calculateBarWidth(labels.length),
//           ),
//           BarChartRodData(
//             toY: planning + active + completed + onHold,
//             fromY: planning + active + completed,
//             color: Colors.orange.shade400,
//             width: _calculateBarWidth(labels.length),
//             borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(6),
//               bottomRight: Radius.circular(6),
//             ),
//           ),
//         ],
//         showingTooltipIndicators: [0, 1, 2, 3],
//       );
//     }).toList();
//   }

//   FlTitlesData _buildTitlesData(List<String> labels) {
//     return FlTitlesData(
//       show: true,
//       leftTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 40,
//           interval: _getLeftInterval(),
//           getTitlesWidget: (value, meta) {
//             return Padding(
//               padding: const EdgeInsets.only(right: 8),
//               child: Text(
//                 value.toInt().toString(),
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.8),
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//       rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       bottomTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 32,
//           getTitlesWidget: (value, meta) {
//             final index = value.toInt();
//             if (index >= 0 && index < labels.length) {
//               return Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: Text(
//                   labels[index],
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.8),
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               );
//             }
//             return const SizedBox();
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildLegendSection(ProjectAnalytics analytics) {
//     final percentages = analytics.statusDistribution;

//     return Center(
//       child: Wrap(
//         alignment: WrapAlignment.center,
//         spacing: 12,
//         runSpacing: 12,
//         children: [
//           _buildLegendItem(
//             'Planning',
//             Colors.blue.shade400,
//             percentages['planning'] ?? 0,
//           ),
//           _buildLegendItem(
//             'Active',
//             Colors.green.shade400,
//             percentages['active'] ?? 0,
//           ),
//           _buildLegendItem(
//             'Completed',
//             Colors.purple.shade400,
//             percentages['completed'] ?? 0,
//           ),
//           _buildLegendItem(
//             'On Hold',
//             Colors.orange.shade400,
//             percentages['onHold'] ?? 0,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLegendItem(String text, Color color, double percentage) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.4), width: 1.5),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 12,
//                 height: 12,
//                 decoration: BoxDecoration(
//                   color: color,
//                   borderRadius: BorderRadius.circular(3),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 text,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w800,
//                   color: color,
//                   letterSpacing: 0.8,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             '${percentage.toStringAsFixed(1)}%',
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w800,
//               color: Colors.white,
//               letterSpacing: 0.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   double _getMaxGraphValue(Map<String, List<double>> graphData) {
//     double maxValue = 0.0;
//     for (final values in graphData.values) {
//       for (final value in values) {
//         if (value > maxValue) maxValue = value;
//       }
//     }
//     return maxValue > 0 ? maxValue * 1.2 : 10.0; // Add 20% padding
//   }

//   double _getGridInterval(Map<String, List<double>> graphData) {
//     final maxValue = _getMaxGraphValue(graphData);
//     if (maxValue <= 5) return 1;
//     if (maxValue <= 10) return 2;
//     return (maxValue / 5).roundToDouble();
//   }

//   double _getLeftInterval() {
//     final maxValue = _getMaxGraphValue(
//       widget.viewModel.analytics?.graphData ?? {},
//     );
//     if (maxValue <= 5) return 1;
//     if (maxValue <= 10) return 2;
//     return (maxValue / 5).roundToDouble();
//   }

//   double _calculateGroupSpace(int labelCount) {
//     if (labelCount <= 6) return 12;
//     if (labelCount <= 12) return 8;
//     return 4;
//   }

//   double _calculateBarWidth(int labelCount) {
//     if (labelCount <= 6) return 16;
//     if (labelCount <= 12) return 12;
//     return 8;
//   }
// }
