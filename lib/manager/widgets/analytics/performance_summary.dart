import 'package:AttendanceApp/manager/core/view_models/theme_view_model.dart';
import 'package:AttendanceApp/manager/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
import 'package:flutter/material.dart';

class PerformanceSummary extends StatelessWidget {
  final AttendanceAnalyticsViewModel viewModel;

  const PerformanceSummary({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final metrics = viewModel.getPerformanceMetrics();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: metrics
                  .map(
                    (metric) => _buildSummaryItem(
                      metric.title,
                      metric.value,
                      metric.subtitle,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String title, String value, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
