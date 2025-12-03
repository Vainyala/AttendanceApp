import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_styles.dart';

class PriorityTabWidget extends StatelessWidget {
  final TaskPriority priority;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const PriorityTabWidget({
    Key? key,
    required this.priority,
    required this.count,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.urgent:
        return 'Urgent';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.normal:
        return 'Normal';
    }
  }

  IconData get priorityIcon {
    switch (priority) {
      case TaskPriority.urgent:
        return Icons.emergency;
      case TaskPriority.high:
        return Icons.priority_high;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.normal:
        return Icons.low_priority;
    }
  }

  Color get priorityColor {
    switch (priority) {
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: 85,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? priorityColor : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? priorityColor : AppColors.grey300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: priorityColor.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.textLight.withOpacity(0.2)
                      : priorityColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  priorityIcon,
                  color: isSelected ? AppColors.textLight : priorityColor,
                  size: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                priorityLabel,
                style: TextStyle(
                  color: isSelected ? AppColors.textLight : AppColors.textDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.textLight.withOpacity(0.3)
                      : priorityColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? AppColors.textLight : priorityColor,
                    fontSize: 12,
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
}