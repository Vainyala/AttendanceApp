import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'dart:ui';

import '../models/attendance_stats.dart';
import '../utils/app_colors.dart';
class AttendanceOverviewCard extends StatelessWidget {
  final String periodType;
  final AttendanceStats? attendanceStats;

  const AttendanceOverviewCard({
    super.key,
    required this.periodType,
    this.attendanceStats,
  });

  String get _title {
    switch (periodType) {
      case 'daily':
        return 'Daily Attendance Overview';
      case 'weekly':
        return 'Weekly Attendance Overview';
      case 'monthly':
        return 'Monthly Attendance Overview';
      case 'quarterly':
        return 'Quarterly Attendance Overview';
      default:
        return 'Attendance Overview';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (attendanceStats == null) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.textLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHint.shade800,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${attendanceStats!.attendancePercentage}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCircle(
                '${attendanceStats!.present}',
                'Present',
                Color(0xFF4CAF50),
              ),
              _buildStatCircle(
                '${attendanceStats!.absent}',
                'Absent',
                Color(0xFFE53935),
              ),
              _buildStatCircle(
                '${attendanceStats!.late}',
                'Late',
                Color(0xFFFF9800),
              ),
              _buildStatCircle(
                '${attendanceStats!.leave}',
                'Leave',
                Color(0xFF2196F3),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, color: AppColors.textLight, size: 20),
                SizedBox(width: 8),
                Text(
                  'Total Days: ${attendanceStats!.totalDays}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCircle(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textHint.shade700,
          ),
        ),
      ],
    );
  }
}