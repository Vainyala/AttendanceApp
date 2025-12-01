import 'package:AttendanceApp/employee/providers/timesheet_provider.dart';
import 'package:AttendanceApp/employee/screens/timesheet/todays_tasks.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_styles.dart';
import '../../widgets/custom_bars.dart';
import '../../widgets/timesheet_widgets/priority_tab.dart';
import '../../widgets/timesheet_widgets/status_tab.dart';
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
            backgroundColor: AppColors.background,
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
                  // Status Tabs Section
                  _buildStatusSection(context, provider),

                  const SizedBox(height: AppDimensions.marginLarge),

                  // Priority Tabs Section
                  _buildPrioritySection(context, provider),

                  const SizedBox(height: AppDimensions.marginLarge),

                  // Graph Section (Horizontally Scrollable)
                  _buildGraphSection(provider),

                  const SizedBox(height: AppDimensions.marginLarge),

                  // Task Cards Section
                  _buildTaskCardsSection(context, provider),

                  const SizedBox(height: AppDimensions.marginLarge),

                  // Today's Tasks Expand Button
                  _buildTodaysTasksButton(context, provider),

                  const SizedBox(height: 80),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateTaskPage()),
                );
              },
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(Icons.add, color: AppColors.textLight),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusSection(BuildContext context, TimesheetProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              const Text('By Status', style: AppStyles.headingSmall1),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TaskStatus.values.map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: StatusTabWidget(
                    status: status,
                    count: provider.getStatusCount(status),
                    isSelected: provider.selectedStatus == status,
                    onTap: () => provider.setSelectedStatus(status),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySection(
    BuildContext context,
    TimesheetProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              const Text('By Priority', style: AppStyles.headingSmall1),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TaskPriority.values.map((priority) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: PriorityTabWidget(
                    priority: priority,
                    count: provider.getPriorityCount(priority),
                    isSelected: provider.selectedPriority == priority,
                    onTap: () => provider.setSelectedPriority(priority),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildGraphSection(TimesheetProvider provider) {
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              const Text('Analytics', style: AppStyles.headingSmall1),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                TaskPieChartWidget(
                  data: statusData,
                  title: 'Tasks by Status',
                ),
                const SizedBox(width: 16),
                TaskPieChartWidget(
                  data: priorityData,
                  title: 'Tasks by Priority',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCardsSection(
    BuildContext context,
    TimesheetProvider provider,
  ) {
    final tasks = provider.getTasksByStatus(provider.selectedStatus);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${provider.selectedStatus.name.toUpperCase()} Tasks',
            style: AppStyles.headingSmall1,
          ),
          const SizedBox(height: 12),
          tasks.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(24),
                  child: const Center(
                    child: Text('No tasks found', style: AppStyles.bodyMedium),
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
    );
  }

  Widget _buildTodaysTasksButton(BuildContext context, TimesheetProvider provider) {
    final todaysTasks = provider.getTodaysTasks();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TodayTasksPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            boxShadow: AppStyles.cardShadowMedium,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.today, color: AppColors.textLight, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Today's Tasks",
                        style: AppStyles.headingSmall1.copyWith(color: AppColors.textLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.textLight.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${todaysTasks.length} tasks due today',
                      style: AppStyles.labelMedium.copyWith(color: AppColors.textLight),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.textLight.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textLight,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
