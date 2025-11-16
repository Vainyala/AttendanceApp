import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class PeriodPieChartWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const PeriodPieChartWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Add null safety checks with default values
    final totalPresent = (data['present'] ?? 0) as int;
    final totalLeave = (data['leave'] ?? 0) as int;
    final totalAbsent = (data['absent'] ?? 0) as int;
    final totalOnTime = (data['onTime'] ?? 0) as int;
    final totalLate = (data['late'] ?? 0) as int;

    return Container(
      height: 220,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.textLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: totalPresent.toDouble(),
                    title: '$totalPresent',
                    color: AppColors.success,
                    radius: 50,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                  PieChartSectionData(
                    value: totalLeave.toDouble(),
                    title: '$totalLeave',
                    color: Colors.orange,
                    radius: 50,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                  PieChartSectionData(
                    value: totalAbsent.toDouble(),
                    title: '$totalAbsent',
                    color: AppColors.error,
                    radius: 50,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                  PieChartSectionData(
                    value: totalOnTime.toDouble(),
                    title: '$totalOnTime',
                    color: Colors.blue,
                    radius: 50,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                  PieChartSectionData(
                    value: totalLate.toDouble(),
                    title: '$totalLate',
                    color: Colors.purple,
                    radius: 50,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('Present', AppColors.success, totalPresent),
                SizedBox(height: 8),
                _buildLegendItem('Leave', Colors.orange, totalLeave),
                SizedBox(height: 8),
                _buildLegendItem('Absent', AppColors.error, totalAbsent),
                SizedBox(height: 8),
                _buildLegendItem('OnTime', Colors.blue, totalOnTime),
                SizedBox(height: 8),
                _buildLegendItem('Late', Colors.purple, totalLate),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int value) => Row(
    children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      SizedBox(width: 8),
      Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textHint.shade700,
        ),
      ),
    ],
  );
}