import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_styles.dart';
// Status Tab Widget
class StatusTabWidget extends StatelessWidget {
  final TaskStatus status;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const StatusTabWidget({
    Key? key,
    required this.status,
    required this.count,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  String get statusLabel {
    switch (status) {
      case TaskStatus.assigned:
        return 'Assigned';
      case TaskStatus.resolved:
        return 'Resolved';
      case TaskStatus.closed:
        return 'Closed';
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.open:
        return 'Open';
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
          color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.grey300,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              statusLabel,
              style: AppStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.textLight : AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: AppStyles.headingSmall.copyWith(
                color: isSelected ? AppColors.textLight : AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}