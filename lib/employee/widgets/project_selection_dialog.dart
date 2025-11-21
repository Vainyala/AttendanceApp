import 'package:AttendanceApp/employee/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/attendance_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class ProjectSelectionDialog extends StatelessWidget {
  final String dateStr;
  final DateTime actualDate;
  final Map<String, List<AttendanceModel>> projectGroups;
  final String status;
  final bool isEditable;
  final Function(String, List<AttendanceModel>) onProjectSelected;

  const ProjectSelectionDialog({
    super.key,
    required this.dateStr,
    required this.actualDate,
    required this.projectGroups,
    required this.status,
    required this.isEditable,
    required this.onProjectSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primaryBlue,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateStr, style: AppStyles.headingLarge),
                      Text(
                        DateFormat('EEEE').format(actualDate),
                        style: AppStyles.text,
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: status, fontSize: 11),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              isEditable
                  ? 'Select Project to Regularize'
                  : 'Select Project to View',
              style: AppStyles.headingLarge,
            ),
            const SizedBox(height: 16),
            ...projectGroups.entries.map((entry) {
              final projectRecords = entry.value;
              final checkIn = projectRecords.firstWhere(
                    (r) => r.type == AttendanceType.checkIn,
                orElse: () => projectRecords.first,
              );
              final checkOut = projectRecords.lastWhere(
                    (r) => r.type == AttendanceType.checkOut,
                orElse: () => projectRecords.last,
              );

              final duration = checkOut.timestamp.difference(
                checkIn.timestamp,
              );
              final hours = duration.inHours;
              final minutes = duration.inMinutes % 60;
              final checkInTime = DateFormat(
                'hh:mm a',
              ).format(checkIn.timestamp);
              final checkOutTime = DateFormat(
                'hh:mm a',
              ).format(checkOut.timestamp);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: AppColors.textLight,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 1,
                  child: InkWell(
                    onTap: () => onProjectSelected(entry.key, projectRecords),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.folder_outlined,
                              color: AppColors.primaryBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.key, style: AppStyles.heading),
                                const SizedBox(height: 4),
                                Text(
                                  '$checkInTime - $checkOutTime',
                                  style: AppStyles.text.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Worked: ${hours}h ${minutes}m',
                                  style: AppStyles.text.copyWith(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.grey300,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}