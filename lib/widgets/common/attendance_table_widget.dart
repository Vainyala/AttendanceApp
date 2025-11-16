// widgets/common/attendance_table_widget.dart
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class AttendanceTableWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDailyView;

  const AttendanceTableWidget({
    Key? key,
    required this.data,
    required this.isDailyView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Null safety check
    if (data.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.textHint.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textHint.shade300),
        ),
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(color: AppColors.textHint.shade600),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.textHint.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textHint.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: isDailyView
                ? [
              _buildHeaderText('Check In', AppColors.success),
              _buildHeaderText('Check Out', AppColors.error),
              _buildHeaderText('Total Hrs', Colors.blue),
              _buildHeaderText(
                'Shortfall',
                (data['hasShortfall'] ?? false) ? AppColors.error : AppColors.success,
              ),
            ]
                : [
              _buildHeaderText('Days', AppColors.textHint.shade700),
              _buildHeaderText('P', AppColors.success),
              _buildHeaderText('L', Colors.orange),
              _buildHeaderText('A', AppColors.error),
              _buildHeaderText('OnTime', Colors.blue),
              _buildHeaderText('Late', Colors.purple),
            ],
          ),
          Divider(height: 20, color: AppColors.textHint.shade400, thickness: 1.5),
          Row(
            children: isDailyView
                ? [
              _buildDataText(data['checkIn'] ?? 'N/A', AppColors.success),
              _buildDataText(data['checkOut'] ?? 'N/A', AppColors.error),
              _buildDataText('${data['totalHours'] ?? 0}h', Colors.blue),
              _buildDataText(
                (data['hasShortfall'] ?? false) ? '${data['shortfall'] ?? 0}h' : 'None',
                (data['hasShortfall'] ?? false) ? AppColors.error : AppColors.success,
              ),
            ]
                : [
              _buildDataText('${data['totalDays'] ?? 0}', AppColors.textHint.shade800),
              _buildDataText('${data['present'] ?? 0}', AppColors.success),
              _buildDataText('${data['leave'] ?? 0}', Colors.orange),
              _buildDataText('${data['absent'] ?? 0}', AppColors.error),
              _buildDataText('${data['onTime'] ?? 0}', Colors.blue),
              _buildDataText('${data['late'] ?? 0}', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text, Color color) => Expanded(
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    ),
  );

  Widget _buildDataText(String text, Color color) => Expanded(
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    ),
  );
}