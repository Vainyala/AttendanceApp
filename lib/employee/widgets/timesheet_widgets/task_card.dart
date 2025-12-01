import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_styles.dart';

class TaskCardWidget extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCardWidget({
    Key? key,
    required this.task,
    required this.onTap,
  }) : super(key: key);

  Color get priorityColor {
    switch (task.priority) {
      case TaskPriority.urgent:
        return AppColors.error;
      case TaskPriority.high:
        return AppColors.warning;
      case TaskPriority.medium:
        return AppColors.info;
      case TaskPriority.normal:
        return AppColors.success;
    }
  }

  Color get statusColor {
    switch (task.status) {
      case TaskStatus.open:
        return AppColors.info;
      case TaskStatus.assigned:
        return AppColors.warning;
      case TaskStatus.pending:
        return AppColors.warning;
      case TaskStatus.resolved:
        return AppColors.success;
      case TaskStatus.closed:
        return AppColors.grey600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: AppDimensions.marginMedium),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      task.priority.name.toUpperCase(),
                      style: AppStyles.chipText.copyWith(
                        color: priorityColor,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: AppDimensions.iconSmall,
                    color: AppColors.grey400,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                task.taskName,
                style: AppStyles.headingSmall1,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'ID: ${task.taskId}',
                style: AppStyles.labelSmall1,
              ),
              const SizedBox(height: 4),
              Text(
                'Type: ${task.type}',
                style: AppStyles.labelSmall1,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: AppDimensions.iconSmall,
                    color: AppColors.grey600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.estEndDate.day}/${task.estEndDate.month}/${task.estEndDate.year}',
                    style: AppStyles.caption,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.status.name.toUpperCase(),
                  style: AppStyles.chipText.copyWith(
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}