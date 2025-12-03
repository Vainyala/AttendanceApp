import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_styles.dart';

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

  IconData get statusIcon {
    switch (status) {
      case TaskStatus.assigned:
        return Icons.person_outline;
      case TaskStatus.resolved:
        return Icons.check_circle_outline;
      case TaskStatus.closed:
        return Icons.cancel_outlined;
      case TaskStatus.pending:
        return Icons.schedule;
      case TaskStatus.open:
        return Icons.folder_open;
    }
  }

  Color get statusColor {
    switch (status) {
      case TaskStatus.assigned:
        return AppColors.warning;
      case TaskStatus.resolved:
        return AppColors.success;
      case TaskStatus.closed:
        return AppColors.grey600;
      case TaskStatus.pending:
        return AppColors.info;
      case TaskStatus.open:
        return AppColors.primaryBlue;
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
            color: isSelected ? statusColor : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? statusColor : AppColors.grey300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: statusColor.withOpacity(0.3),
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
                      : statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  color: isSelected ? AppColors.textLight : statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                statusLabel,
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
                      : statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? AppColors.textLight : statusColor,
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