import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_styles.dart';
import '../../widgets/date_time_utils.dart';
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
              if (task.description.isNotEmpty) _buildDescriptionSection(),

              const SizedBox(height: AppDimensions.marginLarge),

              // Task History Section
              if (task.taskHistory != null && task.taskHistory!.isNotEmpty)
                _buildTaskHistorySection(),

              const SizedBox(height: AppDimensions.marginLarge),

              // Manager Comments Section
              if (task.managerComments != null &&
                  task.managerComments!.isNotEmpty)
                _buildManagerCommentsSection(),

              const SizedBox(height: AppDimensions.marginLarge),

              // Deliverables Section
              if (task.deliverables != null && task.deliverables!.isNotEmpty)
                _buildDeliverablesSection(),

              const SizedBox(height: AppDimensions.marginLarge),

              // Attachments Section
              if (task.attachedFiles != null && task.attachedFiles!.isNotEmpty)
                _buildAttachmentsSection(),

              const SizedBox(height: AppDimensions.marginLarge),

              // Notes Section
              if (task.notes != null && task.notes!.isNotEmpty)
                _buildNotesSection(),

              const SizedBox(height: AppDimensions.marginLarge),
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
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.8)
          ],
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
            icon: Icons.work_outline,
            label: 'Project',
            value: '${task.projectName} (${task.projectId})',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.category,
            label: 'Task Type',
            value: task.type,
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
            value: DateFormattingUtils.formatDate(task.estEndDate), // Use utility
          ),
          if (task.actualEndDate != null) const Divider(height: 24),
          if (task.actualEndDate != null)
            _buildDetailRow(
              icon: Icons.event_available,
              label: 'Actual End Date',
              value: DateFormattingUtils.formatDate(task.actualEndDate!), // Use utility
            ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.access_time,
            label: 'Est. Effort',
            value: '${task.estEffortHrs} hrs',
          ),
          if (task.actualEffortHrs != null) const Divider(height: 24),
          if (task.actualEffortHrs != null)
            _buildDetailRow(
              icon: Icons.timer,
              label: 'Actual Effort',
              value: '${task.actualEffortHrs} hrs',
            ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.attach_money,
            label: 'Billable',
            value: task.billable ? 'Yes' : 'No',
            valueColor: task.billable ? AppColors.success : AppColors.grey600,
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
                'Task Description',
                style: AppStyles.headingSmall1,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            task.description,
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

  Widget _buildTaskHistorySection() {
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
                Icons.history,
                size: AppDimensions.iconMedium,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              const Text('Task History', style: AppStyles.headingSmall1),
            ],
          ),
          const SizedBox(height: 12),
          Text(task.taskHistory!, style: AppStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
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
                Icons.note,
                size: AppDimensions.iconMedium,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              const Text('Notes', style: AppStyles.headingSmall1),
            ],
          ),
          const SizedBox(height: 12),
          Text(task.notes!, style: AppStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildManagerCommentsSection() {
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
                Icons.comment,
                size: AppDimensions.iconMedium,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              const Text('Manager Comments', style: AppStyles.headingSmall1),
            ],
          ),
          const SizedBox(height: 12),
          Text(task.managerComments!, style: AppStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection() {
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
                Icons.attach_file,
                size: AppDimensions.iconMedium,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              const Text('Attachments', style: AppStyles.headingSmall1),
            ],
          ),
          const SizedBox(height: 12),
          ...task.attachedFiles!.map((file) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    file.fileType == 'pdf'
                        ? Icons.picture_as_pdf
                        : Icons.image,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      file.fileName,
                      style: AppStyles.bodyMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download, size: 20),
                    onPressed: () {
                      // TODO: Implement file download
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}