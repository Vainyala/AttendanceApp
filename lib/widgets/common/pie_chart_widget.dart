// widgets/common/pie_chart_widget.dart
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class DailyPieChartWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const DailyPieChartWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Add null safety checks
    final totalHours = data['totalHours'];
    final requiredHours = data['requiredHours'];

    final worked = (totalHours is num) ? totalHours.toDouble() : 0.0;
    final required = (requiredHours is num) ? requiredHours.toDouble() : 9.0;
    final remaining = (required - worked).clamp(0.0, double.infinity);

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hours Distribution',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textHint.shade800,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 150,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: worked,
                          title: '${worked.toStringAsFixed(1)}h',
                          color: AppColors.success,
                          radius: 45,
                          titleStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight,
                          ),
                        ),
                        PieChartSectionData(
                          value: remaining > 0 ? remaining : 0.1,
                          title: remaining > 0 ? '${remaining.toStringAsFixed(1)}h' : '',
                          color: AppColors.error,
                          radius: 45,
                          titleStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegend('Worked', AppColors.success, worked.toInt()),
                    SizedBox(height: 10),
                    if (remaining > 0)
                      _buildLegend('Shortfall', AppColors.error, remaining.toInt()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHint.shade700,
                ),
              ),
              Text(
                '$value hrs',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textHint.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}