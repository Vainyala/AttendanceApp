import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class SmallPieChartWidget extends StatelessWidget {
  final Map<String, dynamic> projectData;
  final double? height;

  const SmallPieChartWidget({
    Key? key,
    required this.projectData,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Add null safety checks with default values
    final present = (projectData['present'] ?? 0) as int;
    final leave = (projectData['leave'] ?? 0) as int;
    final absent = (projectData['absent'] ?? 0) as int;
    final onTime = (projectData['onTime'] ?? 0) as int;
    final late = (projectData['late'] ?? 0) as int;

    // Check if all values are zero
    final hasData = present > 0 || leave > 0 || absent > 0 || onTime > 0 || late > 0;

    if (!hasData) {
      return Container(
        height: height ?? 180,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.textHint.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textHint.shade300),
        ),
        child: Center(
          child: Text(
            'No attendance data available',
            style: TextStyle(
              color: AppColors.textHint.shade600,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return Container(
      height: height ?? 180,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.textHint.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textHint.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: height != null ? 35 : 30,
                sections: _buildPieChartSections(present, leave, absent, onTime, late),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSmallLegendItem('Present', AppColors.success, present),
                SizedBox(height: height != null ? 8 : 6),
                _buildSmallLegendItem('Leave', Colors.orange, leave),
                SizedBox(height: height != null ? 8 : 6),
                _buildSmallLegendItem('Absent', AppColors.error, absent),
                SizedBox(height: height != null ? 8 : 6),
                _buildSmallLegendItem('OnTime', Colors.blue, onTime),
                SizedBox(height: height != null ? 8 : 6),
                _buildSmallLegendItem('Late', Colors.purple, late),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
      int present,
      int leave,
      int absent,
      int onTime,
      int late,
      ) {
    final List<PieChartSectionData> sections = [];
    final radius = height != null ? 45.0 : 40.0;
    final fontSize = height != null ? 13.0 : 12.0;

    if (present > 0) {
      sections.add(
        PieChartSectionData(
          value: present.toDouble(),
          title: '$present',
          color: AppColors.success,
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      );
    }

    if (leave > 0) {
      sections.add(
        PieChartSectionData(
          value: leave.toDouble(),
          title: '$leave',
          color: Colors.orange,
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      );
    }

    if (absent > 0) {
      sections.add(
        PieChartSectionData(
          value: absent.toDouble(),
          title: '$absent',
          color: AppColors.error,
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      );
    }

    if (onTime > 0) {
      sections.add(
        PieChartSectionData(
          value: onTime.toDouble(),
          title: '$onTime',
          color: Colors.blue,
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      );
    }

    if (late > 0) {
      sections.add(
        PieChartSectionData(
          value: late.toDouble(),
          title: '$late',
          color: Colors.purple,
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      );
    }

    return sections;
  }

  Widget _buildSmallLegendItem(String label, Color color, int value) => Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      SizedBox(width: 6),
      Expanded(
        child: Text(
          '$label: $value',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textHint.shade700,
          ),
        ),
      ),
    ],
  );
}