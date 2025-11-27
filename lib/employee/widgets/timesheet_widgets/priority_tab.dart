import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: isSelected ? priorityColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected ? priorityColor : AppColors.grey300,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              priorityLabel,
              style: AppStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.textLight : AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: AppStyles.headingSmall.copyWith(
                color: isSelected ? AppColors.textLight : priorityColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}