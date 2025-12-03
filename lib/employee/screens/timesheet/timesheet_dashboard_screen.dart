import 'package:AttendanceApp/employee/providers/timesheet_provider.dart';
import 'package:AttendanceApp/employee/screens/timesheet/todays_tasks.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_styles.dart';
import '../../widgets/custom_bars.dart';
import '../../widgets/timesheet_widgets/task_card.dart';
import '../../widgets/timesheet_widgets/task_piechart.dart';
import 'task_detail_page.dart';
import 'create_task_page.dart';

class TimesheetScreen extends StatefulWidget {
  const TimesheetScreen({super.key});

  @override
  State<TimesheetScreen> createState() => _TimesheetScreenState();
}

class _TimesheetScreenState extends State<TimesheetScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TimesheetProvider>(
      builder: (context, provider, child) {
        return ScreenWithBottomNav(
          currentIndex: 3,
          child: Scaffold(
            backgroundColor: AppColors.cardBackground,
            appBar: AppBar(
              title: const Text('Timesheet', style: AppStyles.headingLarge),
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.textLight,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Status Tabs
                  _buildStatusTabs(provider),
                  const SizedBox(height: 15),

                  // Priority Tabs
                  _buildPriorityTabs(provider),
                  const SizedBox(height: 15),

                  // Show selected tasks section only when filter is active
                  if (provider.selectedStatus != null)
                    _buildSelectedTasksSection(context, provider),

                  if (provider.selectedStatus != null)
                    const SizedBox(height: 15),

                  // Analytics Section
                  _buildAnalyticsSection(provider),
                  const SizedBox(height: 20),

                  // Today's Tasks Button
                  _buildTodaysTasksButton(context, provider),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateTaskPage()),
                );
              },
              backgroundColor: AppColors.primaryBlue,
              icon: const Icon(Icons.add, color: AppColors.textLight),
              label: const Text('New Task',
                  style: TextStyle(color: AppColors.textLight)),
            ),
          ),
        );
      },
    );
  }

  // ------------------ ENHANCED STATUS TABS --------------------
  Widget _buildStatusTabs(TimesheetProvider provider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.filter_list_rounded,
                    color: AppColors.info, size: 20),
                SizedBox(width: 8),
                Text('By Status', style: AppStyles.headingSmall1),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height:100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: TaskStatus.values.length,
              itemBuilder: (context, index) {
                final status = TaskStatus.values[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildEnhancedStatusTab(status, provider),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatusTab(
      TaskStatus status, TimesheetProvider provider) {
    final isSelected = provider.selectedStatus == status;
    final count = provider.getStatusCount(status);

    String statusLabel;
    IconData statusIcon;
    Color statusColor;

    switch (status) {
      case TaskStatus.assigned:
        statusLabel = 'Assigned';
        statusIcon = Icons.person_outline_rounded;
        statusColor = Color(0xFFFF9800);
        break;
      case TaskStatus.resolved:
        statusLabel = 'Resolved';
        statusIcon = Icons.check_circle_outline_rounded;
        statusColor = Color(0xFF4CAF50);
        break;
      case TaskStatus.closed:
        statusLabel = 'Closed';
        statusIcon = Icons.cancel_outlined;
        statusColor = Color(0xFF9E9E9E);
        break;
      case TaskStatus.pending:
        statusLabel = 'Pending';
        statusIcon = Icons.schedule_rounded;
        statusColor = Color(0xFF2196F3);
        break;
      case TaskStatus.open:
        statusLabel = 'Open';
        statusIcon = Icons.folder_open_rounded;
        statusColor = Color(0xFF673AB7);
        break;
    }

    return SingleChildScrollView(
      child: GestureDetector(
        onTap: () {
          if (provider.selectedStatus == status) {
            provider.setSelectedStatus(null);
          } else {
            provider.setSelectedStatus(status);
          }
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 90,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
              colors: [statusColor, statusColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? statusColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: statusColor.withOpacity(0.4),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ]
                : [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Icon(
                  statusIcon,
                  color: isSelected ? Colors.white : statusColor,
                  size: 22,
                ),
              ),
              SizedBox(height: 3),
              Text(
                statusLabel,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : statusColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ ENHANCED PRIORITY TABS --------------------
  Widget _buildPriorityTabs(TimesheetProvider provider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.flag_rounded,
                    color: AppColors.info, size: 20),
                SizedBox(width: 8),
                Text('By Priority', style: AppStyles.headingSmall1),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: TaskPriority.values.length,
              itemBuilder: (context, index) {
                final priority = TaskPriority.values[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildEnhancedPriorityTab(priority, provider),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPriorityTab(
      TaskPriority priority, TimesheetProvider provider) {
    final isSelected = provider.selectedPriority == priority;
    final count = provider.getPriorityCount(priority);

    String priorityLabel;
    IconData priorityIcon;
    Color priorityColor;

    switch (priority) {
      case TaskPriority.urgent:
        priorityLabel = 'Urgent';
        priorityIcon = Icons.emergency_rounded;
        priorityColor = Color(0xFFD32F2F);
        break;
      case TaskPriority.high:
        priorityLabel = 'High';
        priorityIcon = Icons.arrow_upward_rounded;
        priorityColor = Color(0xFFFF6F00);
        break;
      case TaskPriority.medium:
        priorityLabel = 'Medium';
        priorityIcon = Icons.remove_rounded;
        priorityColor = Color(0xFF0288D1);
        break;
      case TaskPriority.normal:
        priorityLabel = 'Normal';
        priorityIcon = Icons.arrow_downward_rounded;
        priorityColor = Color(0xFF388E3C);
        break;
    }

    return SingleChildScrollView(
      child: GestureDetector(
        onTap: () {
          if (provider.selectedPriority == priority) {
            provider.setSelectedPriority(null);
          } else {
            provider.setSelectedPriority(priority);
          }
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 90,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
              colors: [priorityColor, priorityColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? priorityColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: priorityColor.withOpacity(0.4),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ]
                : [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Icon(
                  priorityIcon,
                  color: isSelected ? Colors.white : priorityColor,
                  size: 22,
                ),
              ),
              SizedBox(height: 3),
              Text(
                priorityLabel,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade800,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : priorityColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ SELECTED TASKS SECTION --------------------
  Widget _buildSelectedTasksSection(
      BuildContext context, TimesheetProvider provider) {
    if (provider.selectedStatus == null) return SizedBox.shrink();

    final tasks = provider.getTasksByStatus(provider.selectedStatus!);
    final filterTitle =
        provider.selectedStatus!.name[0].toUpperCase() +
            provider.selectedStatus!.name.substring(1);


    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.task_alt, color: AppColors.success, size: 20),
                    SizedBox(width: 8),
                    Text('$filterTitle Tasks', style: AppStyles.headingSmall1),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            tasks.isEmpty
                ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textDark),
              ),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 40, color: AppColors.grey400),
                  SizedBox(height: 8),
                  Text('No tasks found',
                      style: AppStyles.bodyMedium
                          .copyWith(color: AppColors.grey600)),
                ],
              ),
            )
                : SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return TaskCardWidget(
                    task: tasks[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TaskDetailPage(task: tasks[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ ANALYTICS --------------------
  Widget _buildAnalyticsSection(TimesheetProvider provider) {
    final statusData = {
      'Assigned': provider.getStatusCount(TaskStatus.assigned),
      'Pending': provider.getStatusCount(TaskStatus.pending),
      'Resolved': provider.getStatusCount(TaskStatus.resolved),
      'Closed': provider.getStatusCount(TaskStatus.closed),
      'Open': provider.getStatusCount(TaskStatus.open),
    };

    final priorityData = {
      'Urgent': provider.getPriorityCount(TaskPriority.urgent),
      'High': provider.getPriorityCount(TaskPriority.high),
      'Medium': provider.getPriorityCount(TaskPriority.medium),
      'Normal': provider.getPriorityCount(TaskPriority.normal),
    };

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined,
                    color: AppColors.info, size: 20),
                SizedBox(width: 8),
                Text('Analytics', style: AppStyles.headingSmall1),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  TaskPieChartWidget(data: statusData, title: 'Tasks by Status'),
                  SizedBox(width: 12),
                  TaskPieChartWidget(
                      data: priorityData, title: 'Tasks by Priority'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ TODAY'S TASKS BUTTON --------------------
  Widget _buildTodaysTasksButton(
      BuildContext context, TimesheetProvider provider) {
    final todaysTasks = provider.getTodaysTasks();

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TodayTasksPage()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue,
                  AppColors.primaryBlue.withOpacity(0.8)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.textLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                  Icon(Icons.today, color: AppColors.textLight, size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Today's Tasks",
                          style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text(
                        '${todaysTasks.length} tasks due today',
                        style: TextStyle(
                          color: AppColors.textLight.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: AppColors.textLight, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}