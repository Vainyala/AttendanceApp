
import 'package:AttendanceApp/manager/models/team_model.dart';
import 'package:AttendanceApp/manager/views/managerviews/employee_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/view_models/theme_view_model.dart';
import '../../../models/projectmodels/project_models.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          project.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProjectOverview(),
            const SizedBox(height: 20),
            _buildTeamAllocationLineGraph(),
            // const SizedBox(height: 20),
            // _buildTaskDistribution(),
            // const SizedBox(height: 20),
            // _buildWorkProgress(),
            const SizedBox(height: 20),
            _buildTeamMembersList(context), // Context pass karo
          ],
        ),
      ),
    );
  }

  Widget _buildProjectOverview() {
    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildOverviewItem(
                  'Status',
                  project.status.toUpperCase(),
                  _getStatusColor(project.status),
                ),
                _buildOverviewItem(
                  'Priority',
                  project.priority.toUpperCase(),
                  _getPriorityColor(project.priority),
                ),
                // _buildOverviewItem(
                //   'Budget',
                //   '\$${project.budget.toStringAsFixed(0)}',
                //   Colors.blue,
                // ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // _buildOverviewItem(
                //   'Start Date',
                //   _formatDate(project.startDate),
                //   Colors.grey,
                // ),
                // _buildOverviewItem(
                //   'End Date',
                //   _formatDate(project.endDate),
                //   Colors.grey,
                // ),
                // _buildOverviewItem(
                //   'Days Left',
                //   '${project.daysRemaining}',
                //   _getDaysLeftColor(project.daysRemaining),
                // ),
              ],
            ),
            const SizedBox(height: 12),
            // LinearProgressIndicator(
            //   value: project.progress / 100,
            //   backgroundColor: Colors.white.withOpacity(0.2),
            //   valueColor: AlwaysStoppedAnimation<Color>(
            //     _getStatusColor(project.status),
            //   ),
            //   minHeight: 8,
            //   borderRadius: BorderRadius.circular(4),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamAllocationLineGraph() {
    final teamMembers = project.assignedTeam;
    final workloadData = _generateWorkloadData(teamMembers);

    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Team Workload Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Task allocation across team members',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (teamMembers.length - 1).toDouble(),
                  minY: 0,
                  maxY: _getMaxWorkload(workloadData) * 1.2,
                  lineTouchData: LineTouchData(
                    enabled: true,
                    getTouchedSpotIndicator:
                        (LineChartBarData barData, List<int> spotIndexes) {
                          return spotIndexes.map((index) {
                            return TouchedSpotIndicatorData(
                              FlLine(
                                color: Colors.white.withOpacity(0.8),
                                strokeWidth: 2,
                                dashArray: [3, 3],
                              ),
                              FlDotData(
                                getDotPainter:
                                    (spot, percent, barData, index) =>
                                        FlDotCirclePainter(
                                          radius: 6,
                                          color: Colors.cyan.shade400,
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        ),
                              ),
                            );
                          }).toList();
                        },
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final member = teamMembers[spot.x.toInt()];
                          return LineTooltipItem(
                            '${member.name}\nTasks: ${spot.y.toInt()}',
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            children: [],
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getGridInterval(workloadData),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white.withOpacity(0.1),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: _getGridInterval(workloadData),
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < teamMembers.length) {
                            final member = teamMembers[index];
                            final initials = member.name
                                .split(' ')
                                .map((n) => n[0])
                                .join();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                initials,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateWorkloadSpots(workloadData),
                      isCurved: true,
                      color: Colors.cyan.shade400,
                      barWidth: 4,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.cyan.shade400.withOpacity(0.3),
                            Colors.cyan.shade400.withOpacity(0.1),
                          ],
                        ),
                      ),
                      dotData: const FlDotData(show: false),
                      shadow: Shadow(
                        color: Colors.cyan.shade400.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildWorkloadLegend(teamMembers, workloadData),
          ],
        ),
      ),
    );
  }

  List<double> _generateWorkloadData(List<TeamMember> teamMembers) {
    // Simulate workload data based on team member roles and project progress
    return teamMembers.asMap().entries.map((entry) {
      final index = entry.key;
      final baseWorkload = (project.progress / 100 * 10).roundToDouble();
      final roleMultiplier = _getRoleMultiplier(entry.value.role);
      return (baseWorkload * roleMultiplier + index * 2).toDouble();
    }).toList();
  }

  double _getRoleMultiplier(String role) {
    switch (role.toLowerCase()) {
      case 'senior developer':
        return 1.5;
      case 'project manager':
        return 1.2;
      case 'ui/ux designer':
        return 1.0;
      case 'qa engineer':
        return 0.8;
      case 'backend developer':
        return 1.3;
      default:
        return 1.0;
    }
  }

  List<FlSpot> _generateWorkloadSpots(List<double> workloadData) {
    return workloadData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();
  }

  double _getMaxWorkload(List<double> workloadData) {
    return workloadData.isNotEmpty
        ? workloadData.reduce((a, b) => a > b ? a : b)
        : 10.0;
  }

  double _getGridInterval(List<double> workloadData) {
    final maxValue = _getMaxWorkload(workloadData);
    if (maxValue <= 5) return 1;
    if (maxValue <= 10) return 2;
    return (maxValue / 5).roundToDouble();
  }

  Widget _buildWorkloadLegend(
    List<TeamMember> teamMembers,
    List<double> workloadData,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: teamMembers.asMap().entries.map((entry) {
        final index = entry.key;
        final member = entry.value;
        final workload = workloadData[index];
        final color = _getMemberColor(index);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                '${member.name.split(' ').first}: ${workload.toInt()} tasks',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getMemberColor(int index) {
    final colors = [
      Colors.cyan,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }

  Widget _buildTaskDistribution() {
    final completed = project.completedTasks;
    final total = project.totalTasks;
    final pending = total - completed;
    final completionRate = total > 0 ? (completed / total * 100) : 0;

    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildTaskItem(
                  'Completed',
                  completed,
                  Colors.green,
                  Icons.check_circle,
                ),
                _buildTaskItem(
                  'Pending',
                  pending,
                  Colors.orange,
                  Icons.pending_actions,
                ),
                _buildTaskItem('Total', total, Colors.blue, Icons.assignment),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Completion Rate: ${completionRate.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkProgress() {
    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Work Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Progress',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  '${project.progress.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: project.progress / 100,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(project.status),
              ),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 16),
            _buildProgressDetail(
              'Tasks Completed',
              '${project.completedTasks}/${project.totalTasks}',
            ),
            _buildProgressDetail('Team Members', '${project.teamSize} people'),
            _buildProgressDetail(
              'Time Remaining',
              '${project.daysRemaining} days',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // YEH METHOD CHANGE KARO - context parameter add karo
  Widget _buildTeamMembersList(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Team Members',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${project.teamSize} members',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: project.assignedTeam
                  .map(
                    (member) => _buildTeamMemberCard(
                      member,
                      context,
                    ), // Context pass karo
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // YEH METHOD CHANGE KARO - context parameter add karo
  Widget _buildTeamMemberCard(TeamMember member, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeDetailsScreen(teamMember: member),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            _buildAvatar(member),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.role,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    member.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(member),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(TeamMember member) {
    return Stack(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: member.status == 'active'
                ? AppColors.primary
                : AppColors.warning,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person, color: Colors.white, size: 24),
        ),
        if (member.status == 'active')
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(TeamMember member) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: member.status == 'active'
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: member.status == 'active'
              ? AppColors.success.withOpacity(0.3)
              : AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Text(
        member.status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: member.status == 'active'
              ? AppColors.success
              : AppColors.warning,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'planning':
        return Colors.orange;
      case 'on-hold':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      case 'urgent':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getDaysLeftColor(int days) {
    if (days <= 7) return Colors.red;
    if (days <= 30) return Colors.orange;
    return Colors.green;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:attendanceapp/models/projectmodels/project_models.dart';
// import 'package:attendanceapp/models/team_model.dart';

// class ProjectDetailScreen extends StatelessWidget {
//   final Project project;

//   const ProjectDetailScreen({super.key, required this.project});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           project.name,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             _buildProjectOverview(),
//             const SizedBox(height: 20),
//             _buildTeamAllocationGraph(),
//             const SizedBox(height: 20),
//             _buildTaskDistribution(),
//             const SizedBox(height: 20),
//             _buildWorkProgress(),
//             const SizedBox(height: 20),
//             _buildTeamMembersList(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProjectOverview() {
//     return Card(
//       color: Colors.white.withOpacity(0.05),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               project.description,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.white.withOpacity(0.8),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 _buildOverviewItem(
//                   'Status',
//                   project.status.toUpperCase(),
//                   _getStatusColor(project.status),
//                 ),
//                 _buildOverviewItem(
//                   'Priority',
//                   project.priority.toUpperCase(),
//                   _getPriorityColor(project.priority),
//                 ),
//                 _buildOverviewItem(
//                   'Budget',
//                   '\$${project.budget.toStringAsFixed(0)}',
//                   Colors.blue,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 _buildOverviewItem(
//                   'Start Date',
//                   _formatDate(project.startDate),
//                   Colors.grey,
//                 ),
//                 _buildOverviewItem(
//                   'End Date',
//                   _formatDate(project.endDate),
//                   Colors.grey,
//                 ),
//                 _buildOverviewItem(
//                   'Days Left',
//                   '${project.daysRemaining}',
//                   _getDaysLeftColor(project.daysRemaining),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             LinearProgressIndicator(
//               value: project.progress / 100,
//               backgroundColor: Colors.white.withOpacity(0.2),
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 _getStatusColor(project.status),
//               ),
//               minHeight: 8,
//               borderRadius: BorderRadius.circular(4),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOverviewItem(String label, String value, Color color) {
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.white.withOpacity(0.6),
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTeamAllocationGraph() {
//     final teamMembers = project.assignedTeam;

//     return Card(
//       color: Colors.white.withOpacity(0.05),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Team Allocation',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               height: 200,
//               child: PieChart(
//                 PieChartData(
//                   sections: _buildTeamSections(teamMembers),
//                   centerSpaceRadius: 40,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<PieChartSectionData> _buildTeamSections(List<TeamMember> teamMembers) {
//     final colors = [
//       Colors.blue,
//       Colors.green,
//       Colors.orange,
//       Colors.purple,
//       Colors.red,
//       Colors.teal,
//     ];

//     return teamMembers.asMap().entries.map((entry) {
//       final index = entry.key;
//       final member = entry.value;
//       final color = colors[index % colors.length];
//       final percentage = (1 / teamMembers.length * 100).round();

//       return PieChartSectionData(
//         color: color,
//         value: 1,
//         title: '${percentage}%',
//         radius: 20,
//         titleStyle: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: Colors.white,
//         ),
//       );
//     }).toList();
//   }

//   Widget _buildTaskDistribution() {
//     final completed = project.completedTasks;
//     final total = project.totalTasks;
//     final pending = total - completed;
//     final completionRate = total > 0 ? (completed / total * 100) : 0;

//     return Card(
//       color: Colors.white.withOpacity(0.05),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Task Distribution',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 _buildTaskItem(
//                   'Completed',
//                   completed,
//                   Colors.green,
//                   Icons.check_circle,
//                 ),
//                 _buildTaskItem(
//                   'Pending',
//                   pending,
//                   Colors.orange,
//                   Icons.pending_actions,
//                 ),
//                 _buildTaskItem('Total', total, Colors.blue, Icons.assignment),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Completion Rate: ${completionRate.toStringAsFixed(1)}%',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.white.withOpacity(0.8),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTaskItem(String label, int count, Color color, IconData icon) {
//     return Expanded(
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               shape: BoxShape.circle,
//               border: Border.all(color: color.withOpacity(0.3)),
//             ),
//             child: Icon(icon, size: 20, color: color),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             count.toString(),
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.white.withOpacity(0.7),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWorkProgress() {
//     return Card(
//       color: Colors.white.withOpacity(0.05),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Work Progress',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Overall Progress',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.white.withOpacity(0.8),
//                   ),
//                 ),
//                 Text(
//                   '${project.progress.toStringAsFixed(1)}%',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             LinearProgressIndicator(
//               value: project.progress / 100,
//               backgroundColor: Colors.white.withOpacity(0.2),
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 _getStatusColor(project.status),
//               ),
//               minHeight: 10,
//               borderRadius: BorderRadius.circular(5),
//             ),
//             const SizedBox(height: 16),
//             _buildProgressDetail(
//               'Tasks Completed',
//               '${project.completedTasks}/${project.totalTasks}',
//             ),
//             _buildProgressDetail('Team Members', '${project.teamSize} people'),
//             _buildProgressDetail(
//               'Time Remaining',
//               '${project.daysRemaining} days',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProgressDetail(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.white.withOpacity(0.7),
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTeamMembersList() {
//     return Card(
//       color: Colors.white.withOpacity(0.05),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Team Members',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.blue.withOpacity(0.3)),
//                   ),
//                   child: Text(
//                     '${project.teamSize} members',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.blue,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Column(
//               children: project.assignedTeam
//                   .map((member) => _buildTeamMemberCard(member))
//                   .toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTeamMemberCard(TeamMember member) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.03),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.white.withOpacity(0.1)),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             backgroundColor: Colors.blue.withOpacity(0.3),
//             child: Text(
//               member.name.split(' ').map((n) => n[0]).join(),
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
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
//                 const SizedBox(height: 4),
//                 Text(
//                   member.role,
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.6),
//                     fontSize: 12,
//                   ),
//                 ),
//                 Text(
//                   member.email,
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.5),
//                     fontSize: 11,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.green.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(6),
//               border: Border.all(color: Colors.green.withOpacity(0.3)),
//             ),
//             child: Text(
//               'Active',
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.green,
//               ),
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

//   Color _getPriorityColor(String priority) {
//     switch (priority.toLowerCase()) {
//       case 'high':
//         return Colors.red;
//       case 'medium':
//         return Colors.orange;
//       case 'low':
//         return Colors.green;
//       case 'urgent':
//         return Colors.purple;
//       default:
//         return Colors.grey;
//     }
//   }

//   Color _getDaysLeftColor(int days) {
//     if (days <= 7) return Colors.red;
//     if (days <= 30) return Colors.orange;
//     return Colors.green;
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/projectviewmodels/project_view_model.dart';
// import 'package:attendanceapp/widgets/projectwidgets/add_project_fab.dart';
// import 'package:attendanceapp/widgets/projectwidgets/projects_list.dart';
// import 'package:attendanceapp/widgets/projectwidgets/view_selector_cards.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ProjectDetailsScreen extends StatefulWidget {
//   const ProjectDetailsScreen({super.key});

//   @override
//   State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
// }

// class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   void _initializeData() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final viewModel = Provider.of<ProjectViewModel>(context, listen: false);
//       viewModel.initialize();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final viewModel = Provider.of<ProjectViewModel>(context);

//     return Scaffold(
//       backgroundColor: theme.colorScheme.background,
//       appBar: AppBar(
//         title: const Text(
//           'Projects',
//           style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_rounded),
//           onPressed: () => Navigator.pop(context),
//         ),
//         backgroundColor: theme.colorScheme.surface,
//         elevation: 0,
//         scrolledUnderElevation: 1,
//         shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
//       ),
//       body: viewModel.isLoading && viewModel.projects.isEmpty
//           ? _buildAppleLoadingState(theme)
//           : _buildContent(theme, viewModel),
//       floatingActionButton: const AddProjectFAB(),
//     );
//   }

//   Widget _buildAppleLoadingState(ThemeData theme) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 24,
//             height: 24,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 theme.colorScheme.primary,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Loading Projects',
//             style: TextStyle(
//               fontSize: 16,
//               color: theme.colorScheme.onBackground.withOpacity(0.6),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContent(ThemeData theme, ProjectViewModel viewModel) {
//     return SingleChildScrollView(
//       physics: const BouncingScrollPhysics(),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header Section
//           _buildHeaderSection(theme),
//           const SizedBox(height: 20),

//           // View Selector
//           ViewSelectorCards(viewModel: viewModel),
//           const SizedBox(height: 24),

//           // Content Section
//           _buildSelectedView(theme, viewModel),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeaderSection(ThemeData theme) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Project Management',
//           style: TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.w700,
//             color: theme.colorScheme.onBackground,
//             height: 1.1,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'Manage and track all your projects',
//           style: TextStyle(
//             fontSize: 16,
//             color: theme.colorScheme.onBackground.withOpacity(0.6),
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSelectedView(ThemeData theme, ProjectViewModel viewModel) {
//     switch (viewModel.selectedView) {
//       case 'projects':
//         return ProjectsList(viewModel: viewModel);
//       case 'attendance':
//         return _buildComingSoonView(theme, 'Attendance Details');
//       case 'employees':
//         return _buildComingSoonView(theme, 'Employee Details');
//       default:
//         return ProjectsList(viewModel: viewModel);
//     }
//   }

//   Widget _buildComingSoonView(ThemeData theme, String title) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           if (theme.brightness == Brightness.light)
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: theme.colorScheme.primary.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.construction_rounded,
//               size: 30,
//               color: theme.colorScheme.primary,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: theme.colorScheme.onSurface,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'This feature is currently under development and will be available soon.',
//             style: TextStyle(
//               fontSize: 14,
//               color: theme.colorScheme.onSurface.withOpacity(0.6),
//               height: 1.4,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: theme.colorScheme.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               'Coming Soon',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: theme.colorScheme.primary,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

/*  ######################################################################################################################

**************************************              A I S C R E E N C O D E              *********************************

########################################################################################################################## */

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/projectviewmodels/project_view_model.dart';
// import 'package:attendanceapp/widgets/projectwidgets/add_project_fab.dart';
// import 'package:attendanceapp/widgets/projectwidgets/projects_list.dart';
// import 'package:attendanceapp/widgets/projectwidgets/view_selector_cards.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ProjectDetailsScreen extends StatefulWidget {
//   const ProjectDetailsScreen({super.key});

//   @override
//   State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
// }

// class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   void _initializeData() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final viewModel = Provider.of<ProjectViewModel>(context, listen: false);
//       viewModel.initialize();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);
//     final viewModel = Provider.of<ProjectViewModel>(context);

//     return Scaffold(
//       backgroundColor: theme.themeMode == ThemeMode.dark
//           ? AppColors.backgroundDark
//           : AppColors.backgroundLight,
//       appBar: AppBar(
//         title: const Text('Project Management'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_rounded),
//           onPressed: () => Navigator.pop(context),
//         ),
//         backgroundColor: theme.themeMode == ThemeMode.dark
//             ? AppColors.grey900
//             : AppColors.white,
//         elevation: 0,
//       ),
//       body: viewModel.isLoading && viewModel.projects.isEmpty
//           ? _buildLoadingState()
//           : _buildContent(viewModel),
//       floatingActionButton: const AddProjectFAB(),
//     );
//   }

//   Widget _buildLoadingState() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(),
//           SizedBox(height: 16),
//           Text('Loading projects...'),
//         ],
//       ),
//     );
//   }

//   Widget _buildContent(ProjectViewModel viewModel) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           ViewSelectorCards(viewModel: viewModel),
//           const SizedBox(height: 24),
//           _buildSelectedView(viewModel),
//         ],
//       ),
//     );
//   }

//   Widget _buildSelectedView(ProjectViewModel viewModel) {
//     switch (viewModel.selectedView) {
//       case 'projects':
//         return ProjectsList(viewModel: viewModel);
//       case 'attendance':
//         return _buildComingSoonView('Attendance Details');
//       case 'employees':
//         return _buildComingSoonView('Employee Details');
//       default:
//         return ProjectsList(viewModel: viewModel);
//     }
//   }

//   Widget _buildComingSoonView(String title) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         height: 200,
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.construction_rounded,
//               size: 48,
//               color: AppColors.grey400,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               '$title - Coming Soon',
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'This feature is under development',
//               style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
