import 'package:AttendanceApp/employee/widgets/timesheet_widgets/create_edit_widgets/task_id_card.dart';
import 'package:flutter/material.dart';

import '../../../models/task_model.dart';
import '../../../utils/app_colors.dart';

/// Reusable Billable Switch Widget
class BillableSwitch extends StatelessWidget {
  final bool billable;
  final ValueChanged<bool> onChanged;

  const BillableSwitch({
    Key? key,
    required this.billable,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: billable
                  ? AppColors.primaryBlue.withOpacity(0.1)
                  : AppColors.grey200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.attach_money,
              color: billable ? AppColors.primaryBlue : AppColors.grey600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Billable Task',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  billable ? 'Client will be charged' : 'Internal task',
                  style: TextStyle(fontSize: 12, color: AppColors.grey600),
                ),
              ],
            ),
          ),
          Switch(
            value: billable,
            onChanged: onChanged,
            activeColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }
}

/// Reusable Attachments Section Widget
class AttachmentsSection extends StatelessWidget {
  final List<AttachedFile> attachedFiles;
  final VoidCallback onAddFiles;
  final ValueChanged<AttachedFile> onRemoveFile;

  const AttachmentsSection({
    Key? key,
    required this.attachedFiles,
    required this.onAddFiles,
    required this.onRemoveFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Attachments',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              TextButton.icon(
                onPressed: onAddFiles,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Files'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (attachedFiles.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.grey200,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 40,
                      color: AppColors.grey400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No files attached',
                      style: TextStyle(fontSize: 13, color: AppColors.grey600),
                    ),
                  ],
                ),
              ),
            )
          else
            ...(attachedFiles.map((file) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        file.fileType == 'pdf'
                            ? Icons.picture_as_pdf
                            : Icons.image,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        file.fileName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      color: AppColors.grey600,
                      onPressed: () => onRemoveFile(file),
                    ),
                  ],
                ),
              );
            }).toList()),
        ],
      ),
    );
  }
}