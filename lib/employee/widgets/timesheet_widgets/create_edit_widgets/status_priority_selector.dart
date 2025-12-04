import 'package:flutter/material.dart';

import '../../../models/task_model.dart';
import '../../../utils/app_colors.dart';


/// Reusable Priority Selector Widget
class PrioritySelector extends StatelessWidget {
  final TaskPriority selectedPriority;
  final ValueChanged<TaskPriority> onChanged;

  const PrioritySelector({
    Key? key,
    required this.selectedPriority,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority Level',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TaskPriority.values.map((priority) {
            final bool isSelected = selectedPriority == priority;

            late Color priorityColor;
            late IconData priorityIcon;

            switch (priority) {
              case TaskPriority.urgent:
                priorityColor = AppColors.error;
                priorityIcon = Icons.emergency;
                break;
              case TaskPriority.high:
                priorityColor = AppColors.warning;
                priorityIcon = Icons.priority_high;
                break;
              case TaskPriority.medium:
                priorityColor = AppColors.info;
                priorityIcon = Icons.remove;
                break;
              case TaskPriority.normal:
                priorityColor = AppColors.success;
                priorityIcon = Icons.low_priority;
                break;
            }

            return GestureDetector(
              onTap: () => onChanged(priority),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? priorityColor : Colors.white,
                  border: Border.all(
                    color: isSelected ? priorityColor : AppColors.grey300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: priorityColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      priorityIcon,
                      size: 16,
                      color: isSelected ? Colors.white : priorityColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      priority.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Reusable Status Selector Widget
class StatusSelector extends StatelessWidget {
  final TaskStatus selectedStatus;
  final ValueChanged<TaskStatus> onChanged;

  const StatusSelector({
    Key? key,
    required this.selectedStatus,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Level',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TaskStatus.values.map((status) {
            final bool isSelected = selectedStatus == status;

            late Color statusColor;
            late IconData statusIcon;

            switch (status) {
              case TaskStatus.open:
                statusColor = AppColors.primaryBlue;
                statusIcon = Icons.folder_open;
                break;
              case TaskStatus.assigned:
                statusColor = AppColors.warning;
                statusIcon = Icons.person_outline;
                break;
              case TaskStatus.resolved:
                statusColor = AppColors.success;
                statusIcon = Icons.check_circle_outline;
                break;
              case TaskStatus.closed:
                statusColor = AppColors.grey600;
                statusIcon = Icons.cancel_outlined;
                break;
              case TaskStatus.pending:
                statusColor = AppColors.info;
                statusIcon = Icons.schedule;
                break;
            }

            return GestureDetector(
              onTap: () => onChanged(status),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? statusColor : Colors.white,
                  border: Border.all(
                    color: isSelected ? statusColor : AppColors.grey300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: statusColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 16,
                      color: isSelected ? Colors.white : statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
