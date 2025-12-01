import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/timesheet_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_styles.dart';
import '../../widgets/date_time_utils.dart';
import '../../widgets/month_selection_drawer.dart';
import '../../widgets/timesheet_widgets/task_piechart.dart';
import '../../widgets/week_selection_drawer.dart';
import 'task_detail_page.dart';

class TodayTasksPage extends StatelessWidget {
  const TodayTasksPage({Key? key}) : super(key: key);

  Future<void> _selectDate(BuildContext context, TimesheetProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDailyDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.textLight,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) provider.setDailyDate(picked);
  }

  void _showWeeklyDrawer(BuildContext context, TimesheetProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => WeekSelectionDrawer(
        selectedIndex: provider.selectedWeekIndex,
        onWeekSelected: (index) {
          provider.setWeekIndex(index);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showMonthlyDrawer(BuildContext context, TimesheetProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => MonthSelectionDrawer(
        selectedIndex: provider.selectedMonthIndex,
        onMonthSelected: (index) {
          provider.setMonthIndex(index);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimesheetProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.primaryBlue,
          appBar: AppBar(
            title: const Text(
              "Today's Tasks",
              style: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.textLight),
          ),
          body: Column(
            children: [
              // Time Filter Tabs (Top Section)
              _buildTimeFilterTabs(context, provider),

              // Main Content Area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10),

                      // Date Range Selector
                      _buildDateRangeSelector(context, provider),

                      SizedBox(height: 10),

                      // Projects Horizontal Scroll
                      _buildProjectsSection(provider),

                      SizedBox(height: 16),

                      // Task List
                      Expanded(
                        child: _buildTaskList(context, provider),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeFilterTabs(BuildContext context, TimesheetProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTopTab(context, "Daily", TimeFilter.daily, provider),
          SizedBox(width: 8),
          _buildTopTab(context, "Weekly", TimeFilter.weekly, provider),
          SizedBox(width: 8),
          _buildTopTab(context, "Monthly", TimeFilter.monthly, provider),
        ],
      ),
    );
  }

  Widget _buildTopTab(BuildContext context, String label, TimeFilter filter, TimesheetProvider provider) {
    final selected = provider.selectedTimeFilter == filter;

    return GestureDetector(
      onTap: () {
        provider.setSelectedTimeFilter(filter);

        if (filter == TimeFilter.daily) _selectDate(context, provider);
        if (filter == TimeFilter.weekly) _showWeeklyDrawer(context, provider);
        if (filter == TimeFilter.monthly) _showMonthlyDrawer(context, provider);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.textLight : AppColors.textLight.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.textLight.withOpacity(selected ? 1 : 0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primaryBlue : AppColors.textLight,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  String _getDateLabel(TimesheetProvider provider) {
    switch (provider.selectedTimeFilter) {
      case TimeFilter.daily:
        final date = provider.selectedDailyDate;
        return DateFormattingUtils.formatDate(date);

      case TimeFilter.weekly:
        final now = DateTime.now();
        final index = provider.selectedWeekIndex;
        final startDate = now.subtract(Duration(days: (index + 1) * 7));
        final endDate = now.subtract(Duration(days: index * 7));

        if (index == 0) {
          return 'Current Week\n(${startDate.day}/${startDate.month} - ${endDate.day}/${endDate.month})';
        }
        return 'Week ${index + 1}\n(${startDate.day}/${startDate.month} - ${endDate.day}/${endDate.month})';

      case TimeFilter.monthly:
        final date = DateTime(DateTime.now().year, provider.selectedMonthIndex);
        return 'Current Month\n(${DateFormattingUtils.formatMonthYear(date)})';

      default:
        return 'Select Date';
    }
  }

  Widget _buildDateRangeSelector(BuildContext context, TimesheetProvider provider) {
    String dateLabel = _getDateLabel(provider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Arrow
          IconButton(
            icon: Icon(Icons.chevron_left, size: 28),
            onPressed: () => _navigateDate(provider, -1),
            color: AppColors.primaryBlue,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.textLight,
              shape: CircleBorder(),
            ),
          ),

          // Date Display
          Expanded(
            child: GestureDetector(
              onTap: () => _onDateTap(context, provider),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.textLight,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        dateLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right Arrow
          IconButton(
            icon: Icon(Icons.chevron_right, size: 28),
            onPressed: () => _navigateDate(provider, 1),
            color: AppColors.primaryBlue,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.textLight,
              shape: CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateDate(TimesheetProvider provider, int direction) {
    switch (provider.selectedTimeFilter) {
      case TimeFilter.daily:
        final newDate = provider.selectedDailyDate.add(Duration(days: direction));
        provider.setDailyDate(newDate);
        break;

      case TimeFilter.weekly:
        if (direction < 0) {
          provider.incrementWeekIndex();
        } else {
          provider.decrementWeekIndex();
        }
        break;

      case TimeFilter.monthly:
        if (direction < 0) {
          provider.incrementMonthIndex();
        } else {
          provider.decrementMonthIndex();
        }
        break;
    }
  }

  void _onDateTap(BuildContext context, TimesheetProvider provider) {
    switch (provider.selectedTimeFilter) {
      case TimeFilter.daily:
        _selectDate(context, provider);
        break;
      case TimeFilter.weekly:
        _showWeeklyDrawer(context, provider);
        break;
      case TimeFilter.monthly:
        _showMonthlyDrawer(context, provider);
        break;
    }
  }

  Widget _buildProjectsSection(TimesheetProvider provider) {
    final projects = [
      {'id': 'ALL', 'name': 'All'},
      ...provider.projects,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Mapped Projects',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              final isSelected = provider.selectedProjectId == project['id'];

              return GestureDetector(
                onTap: () => provider.setSelectedProject(project['id']!),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryBlue : AppColors.textLight,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryBlue : AppColors.grey300,
                      width: 1.5,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ] : [],
                  ),
                  child: Center(
                    child: Text(
                      project['name']!,
                      style: TextStyle(
                        color: isSelected ? AppColors.textLight : AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(BuildContext context, TimesheetProvider provider) {
    List<Task> tasks;

    if (provider.selectedProjectId == 'ALL') {
      tasks = provider.getFilteredTasks();
    } else {
      tasks = provider.getTasksByProject(provider.selectedProjectId)
          .where((task) {
        switch (provider.selectedTimeFilter) {
          case TimeFilter.daily:
            return provider.isSameDate(task.estEndDate, provider.selectedDailyDate);
          case TimeFilter.weekly:
            final now = DateTime.now();
            final index = provider.selectedWeekIndex;
            final start = now.subtract(Duration(days: (index + 1) * 7));
            final end = now.subtract(Duration(days: index * 7));
            return task.estEndDate.isAfter(start) && task.estEndDate.isBefore(end);
          case TimeFilter.monthly:
            return task.estEndDate.month == provider.selectedMonthIndex &&
                task.estEndDate.year == DateTime.now().year;
          default:
            return true;
        }
      }).toList();
    }

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_outlined,
                size: 60,
                color: AppColors.grey400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No tasks found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.selectedProjectId == 'ALL'
                  ? 'Try selecting a different date or filter'
                  : 'No tasks for this project',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.textLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailPage(task: task),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.taskName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.grey400,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip('ID: ${task.taskId}', AppColors.grey600),
                    const SizedBox(width: 8),
                    _buildInfoChip(task.priority.name.toUpperCase(), priorityColor),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.category, size: 16, color: AppColors.grey600),
                    const SizedBox(width: 6),
                    Text(
                      task.type,
                      style: TextStyle(fontSize: 13, color: AppColors.grey600),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.calendar_today, size: 16, color: AppColors.grey600),
                    const SizedBox(width: 6),
                    Text(
                      DateFormattingUtils.formatDateShort(task.estEndDate),
                      style: TextStyle(fontSize: 13, color: AppColors.grey600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildInfoChip(task.status.name.toUpperCase(), statusColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}