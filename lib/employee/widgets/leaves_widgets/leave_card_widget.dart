import 'package:AttendanceApp/employee/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_styles.dart';
import '../status_badge.dart';

class LeaveCardWidget extends StatelessWidget {
  final Map<String, dynamic> leave;
  final VoidCallback onView;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onDecrease;

  const LeaveCardWidget({
    super.key,
    required this.leave,
    required this.onView,
    this.onEdit,
    this.onCancel,
    this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.marginLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppDimensions.marginSmall),
          Text(
            leave['reason'],
            style: AppStyles.bodyMedium.copyWith(color: AppColors.textHint),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSmall,
                      vertical: AppDimensions.paddingXSmall,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: AppStyles.radiusSmall,
                    ),
                    child: Text(
                      leave['type'],
                      style: AppStyles.chipText.copyWith(color: AppColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  StatusBadge(status: leave['status']),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Text(
                '${DateFormat('dd MMM yyyy').format(leave['fromDate'])} - '
                    '${DateFormat('dd MMM yyyy').format(leave['toDate'])}',
                style: AppStyles.bodyLarge,
              ),
              const SizedBox(height: AppDimensions.paddingXSmall),
              Text(
                '${leave['days']} day${leave['days'] > 1 ? 's' : ''}',
                style: AppStyles.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Text(
          'Applied on: ${DateFormat('dd MMM yyyy').format(leave['appliedOn'])}',
          style: AppStyles.caption,
        ),
        const Spacer(),
        _buildActionButton('View', AppColors.primaryBlue, onView),
        if (onEdit != null)
          _buildActionButton('Edit', AppColors.primaryBlue, onEdit!),
        if (onDecrease != null)
          _buildActionButton('Decrease', AppColors.warning, onDecrease!),
        if (onCancel != null)
          _buildActionButton('Cancel', AppColors.error, onCancel!),
      ],
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
        minimumSize: const Size(0, AppDimensions.buttonHeightSmall),
      ),
      child: Text(label),
    );
  }
}