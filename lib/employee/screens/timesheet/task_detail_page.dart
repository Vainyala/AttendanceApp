import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_styles.dart';
import 'edit_task_page.dart';

class TaskDetailPage extends StatelessWidget {
  final Task task;

  const TaskDetailPage({
    Key? key,
    required this.task,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          task.projectName,
          style: AppStyles.headingMedium,
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTaskPage(task: task),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Header Card
              _buildHeaderCard(),

              const SizedBox(height: AppDimensions.marginLarge),

              // Task Details Card
              _buildDetailsCard(),

              const SizedBox(height: AppDimensions.marginLarge),

              // Description Section
              if (task.description != null) _buildDescriptionSection(),

              const SizedBox(height: AppDimensions.marginLarge),

              // Deliverables Section
              if (task.deliverables != null) _buildDeliverablesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: AppStyles.cardShadowMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.taskName,
                  style: AppStyles.headingLarge.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ID: ${task.taskId}',
                  style: AppStyles.labelMedium.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  task.priority.name.toUpperCase(),
                  style: AppStyles.chipText.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.category,
            label: 'Type',
            value: task.type,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.flag,
            label: 'Priority',
            value: task.priority.name.toUpperCase(),
            valueColor: priorityColor,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.info_outline,
            label: 'Status',
            value: task.status.name.toUpperCase(),
            valueColor: statusColor,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Est. End Date',
            value: '${task.estEndDate.day}/${task.estEndDate.month}/${task.estEndDate.year}',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.access_time,
            label: 'Est. Effort',
            value: '${task.estEffortHrs} hrs',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.work_outline,
            label: 'Project',
            value: '${task.projectName} (${task.projectId})',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppDimensions.iconMedium,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppStyles.labelSmall1,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppStyles.bodyMedium.copyWith(
                  color: valueColor ?? AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.description,
                size: AppDimensions.iconMedium,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              const Text(
                'Description',
                style: AppStyles.headingSmall1,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            task.description!,
            style: AppStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverablesSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.checklist,
                size: AppDimensions.iconMedium,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              const Text(
                'Deliverables',
                style: AppStyles.headingSmall1,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            task.deliverables!,
            style: AppStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}