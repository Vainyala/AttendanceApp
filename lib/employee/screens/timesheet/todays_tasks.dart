import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/timesheet_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_styles.dart';
import '../../widgets/timesheet_widgets/task_piechart.dart';
import 'task_detail_page.dart';

class TodayTasksPage extends StatelessWidget {
  const TodayTasksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TimesheetProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              "Today's Tasks",
              style: AppStyles.headingMedium,
            ),
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.textLight,
            elevation: 0,
          ),
          body: Column(
            children: [
              // Time Filter Tabs
              _buildTimeFilterTabs(provider),

              // Date Range Display (if weekly/monthly selected)
              if (provider.selectedTimeFilter != TimeFilter.daily)
                _buildDateRangeSelector(context, provider),

              // Projects Horizontal Scroll
              _buildProjectsSection(provider),

              // Task List
              Expanded(
                child: _buildTaskList(context, provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeFilterTabs(TimesheetProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterTab(
              'Daily',
              TimeFilter.daily,
              provider.selectedTimeFilter == TimeFilter.daily,
                  () => provider.setSelectedTimeFilter(TimeFilter.daily),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterTab(
              'Weekly',
              TimeFilter.weekly,
              provider.selectedTimeFilter == TimeFilter.weekly,
                  () => provider.setSelectedTimeFilter(TimeFilter.weekly),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterTab(
              'Monthly',
              TimeFilter.monthly,
              provider.selectedTimeFilter == TimeFilter.monthly,
                  () => provider.setSelectedTimeFilter(TimeFilter.monthly),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(
      String label,
      TimeFilter filter,
      bool isSelected,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.success : AppColors.grey100,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.success : AppColors.grey300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppStyles.labelMedium.copyWith(
              color: isSelected ? AppColors.textLight : AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context, TimesheetProvider provider) {
    String dateRangeText = 'Select Date Range';
    if (provider.fromDate != null && provider.toDate != null) {
      dateRangeText =
      '${provider.fromDate!.day}/${provider.fromDate!.month}/${provider.fromDate!.year} - ${provider.toDate!.day}/${provider.toDate!.month}/${provider.toDate!.year}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.primaryBlue),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            color: AppColors.primaryBlue,
            size: AppDimensions.iconMedium,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              dateRangeText,
              style: AppStyles.bodyMedium,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_calendar,
              color: AppColors.primaryBlue,
            ),
            onPressed: () => _selectDateRange(context, provider),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange(
      BuildContext context,
      TimesheetProvider provider,
      ) async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: provider.fromDate != null && provider.toDate != null
          ? DateTimeRange(start: provider.fromDate!, end: provider.toDate!)
          : null,
    );

    if (dateRange != null) {
      provider.setDateRange(dateRange.start, dateRange.end);
    }
  }

  Widget _buildProjectsSection(TimesheetProvider provider) {
    final projects = provider.projects;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
            child: Text(
              'Mapped Projects',
              style: AppStyles.headingSmall1,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return ProjectSelectionWidget(
                  projectId: project['id']!,
                  projectName: project['name']!,
                  isSelected: provider.selectedProjectId == project['id'],
                  onTap: () => provider.setSelectedProject(project['id']!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, TimesheetProvider provider) {
    final tasks = provider.getTasksByProject(provider.selectedProjectId);

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_outlined,
              size: 80,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No tasks found for this project',
              style: AppStyles.bodyLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return _buildTaskItem(context, tasks[index]);
      },
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.urgent:
        priorityColor = AppColors.error;
        break;
      case TaskPriority.high:
        priorityColor = AppColors.warning;
        break;
      case TaskPriority.medium:
        priorityColor = AppColors.info;
        break;
      case TaskPriority.normal:
        priorityColor = AppColors.success;
        break;
    }

    Color statusColor;
    switch (task.status) {
      case TaskStatus.open:
        statusColor = AppColors.info;
        break;
      case TaskStatus.assigned:
        statusColor = AppColors.warning;
        break;
      case TaskStatus.pending:
        statusColor = AppColors.warning;
        break;
      case TaskStatus.resolved:
        statusColor = AppColors.success;
        break;
      case TaskStatus.closed:
        statusColor = AppColors.grey600;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: AppStyles.cardShadow,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailPage(task: task),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.taskName,
                      style: AppStyles.headingSmall1,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: AppDimensions.iconSmall,
                    color: AppColors.grey400,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    'ID: ${task.taskId}',
                    AppColors.grey600,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    task.priority.name.toUpperCase(),
                    priorityColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildDetailItem(
                    Icons.category,
                    task.type,
                  ),
                  const SizedBox(width: 16),
                  _buildDetailItem(
                    Icons.calendar_today,
                    '${task.estEndDate.day}/${task.estEndDate.month}/${task.estEndDate.year}',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoChip(
                task.status.name.toUpperCase(),
                statusColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppStyles.chipText.copyWith(color: color),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppDimensions.iconSmall,
          color: AppColors.grey600,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppStyles.caption,
        ),
      ],
    );
  }
}