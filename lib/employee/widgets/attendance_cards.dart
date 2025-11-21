import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/attendance_model.dart';
import '../providers/regularisation_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/status_badge.dart';
import '../widgets/stat_item.dart';

class AttendanceCard extends StatelessWidget {
  final String date;
  final String hours;
  final String shortfall;
  final String status;
  final DateTime actualDate;
  final List<AttendanceModel> dayRecords;
  final VoidCallback onTap;

  const AttendanceCard({
    super.key,
    required this.date,
    required this.hours,
    required this.shortfall,
    required this.status,
    required this.actualDate,
    required this.dayRecords,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RegularisationProvider>();
    final projectGroups = provider.getProjectGroups(dayRecords);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.textLight,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(date, style: AppStyles.heading),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatItem(
                        icon: Icons.access_time,
                        label: 'Check-in Hr',
                        value: hours,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.grey200),
                    Expanded(
                      child: StatItem(
                        icon: Icons.trending_down,
                        label: 'Shortfall Hr',
                        value: shortfall,
                        color: shortfall == '00:00'
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.grey200),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            Icon(
                              status == 'Apply'
                                  ? Icons.add_circle_outline
                                  : status == 'Approved'
                                  ? Icons.check_circle
                                  : Icons.pending,
                              size: 20,
                              color: status == 'Apply'
                                  ? AppColors.warning
                                  : status == 'Approved'
                                  ? AppColors.success
                                  : AppColors.primaryBlue,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Regularize',
                              style: AppStyles.text.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (projectGroups.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Divider(height: 1, color: AppColors.grey200),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: projectGroups.keys.take(3).map((projectName) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryBlue.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.folder,
                              size: 14,
                              color: AppColors.primaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              projectName,
                              style: AppStyles.text.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  if (projectGroups.length > 3) ...[
                    const SizedBox(height: 8),
                    Text(
                      '+${projectGroups.length - 3} more projects',
                      style: AppStyles.text.copyWith(
                        color: AppColors.grey600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}