import 'package:AttendanceApp/employee/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_styles.dart';
import '../status_badge.dart';

class LeaveDetailsCard extends StatelessWidget {
  final Map<String, dynamic> leave;

  const LeaveDetailsCard({
    super.key,
    required this.leave,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppStyles.radiusMedium,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Leave Details',
            style: AppStyles.headingMedium.copyWith(color: AppColors.textLight),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Leave Type', leave['type']),
          _buildDivider(),
          _buildInfoRow('Status', '', customValue: StatusBadge(status: leave['status'])),
          _buildDivider(),
          _buildInfoRow('From Date', DateFormat('dd MMM yyyy').format(leave['fromDate'])),
          _buildDivider(),
          _buildInfoRow('To Date', DateFormat('dd MMM yyyy').format(leave['toDate'])),
          _buildDivider(),
          _buildInfoRow('Duration', '${leave['days']} day${leave['days'] > 1 ? 's' : ''}'),
          _buildDivider(),
          _buildInfoRow('Applied On', DateFormat('dd MMM yyyy').format(leave['appliedOn'])),
          _buildDivider(),
          _buildReasonSection(),
          if (leave['managerComment'] != null) ...[
            _buildDivider(),
            _buildManagerCommentSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Widget? customValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppStyles.labelMedium.copyWith(color: AppColors.textHint),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: customValue ?? Text(value, style: AppStyles.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reason',
          style: AppStyles.labelMedium.copyWith(color: AppColors.textHint),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.textHint.withOpacity(0.1),
            borderRadius: AppStyles.radiusSmall,
          ),
          child: Text(
            leave['reason'],
            style: AppStyles.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildManagerCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manager Comment',
          style: AppStyles.labelMedium.copyWith(color: AppColors.textDark),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: AppStyles.radiusSmall,
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Text(
            leave['managerComment'] ?? '',
            style: AppStyles.bodyMedium.copyWith(color: AppColors.success),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 16, color: AppColors.grey100);
  }
}