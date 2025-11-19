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
              _buildHeaderFlexible('Check \nIn', AppColors.success),
              _buildHeaderFlexible('Check Out', AppColors.error),
              _buildHeaderFlexible('Total \nHrs', Colors.blue),
              _buildHeaderFlexible(
                'Shortfall',
                data['hasShortfall'] ? AppColors.error : AppColors.success,
              ),
              _buildHeaderFlexible('Status', AppColors.primaryBlue),
            ]
                : [
              _buildHeaderFlexible('Days', AppColors.textHint.shade700),
              _buildHeaderFlexible('P', AppColors.success),
              _buildHeaderFlexible('L', Colors.orange),
              _buildHeaderFlexible('A', AppColors.error),
              _buildHeaderFlexible('OnTime', Colors.blue),
              _buildHeaderFlexible('Late', Colors.purple),
            ],
          ),


          Divider(height: 20, color: AppColors.textHint.shade400, thickness: 1.5),

          Row(
            children: isDailyView
                ? [
              _buildDataFlexible(data['checkIn'] ?? 'N/A', AppColors.success),
              _buildDataFlexible(data['checkOut'] ?? 'N/A', AppColors.error),
              _buildDataFlexible('${data['totalHours'] ?? 0}h', Colors.blue),
              _buildDataFlexible(
                (data['hasShortfall'] ?? false)
                    ? '${data['shortfall'] ?? 0}h'
                    : 'None',
                (data['hasShortfall'] ?? false)
                    ? AppColors.error
                    : AppColors.success,
              ),
              Flexible(
                child: Center(
                  child: _buildShortfallIcon(data),
                ),
              ),
            ]
                : [
              _buildDataFlexible('${data['totalDays'] ?? 0}', AppColors.textHint.shade800),
              _buildDataFlexible('${data['present'] ?? 0}', AppColors.success),
              _buildDataFlexible('${data['leave'] ?? 0}', Colors.orange),
              _buildDataFlexible('${data['absent'] ?? 0}', AppColors.error),
              _buildDataFlexible('${data['onTime'] ?? 0}', Colors.blue),
              _buildDataFlexible('${data['late'] ?? 0}', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderFlexible(String text, Color color) {
    return Flexible(
      flex: 1,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDataFlexible(String text, Color color) {
    return Flexible(
      flex: 1,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }


  /// FUNCTION TO SHOW THUMBS UP / DOWN
  Widget _buildShortfallIcon(Map<String, dynamic> data) {
    final hasShortfall = data['hasShortfall'] ?? false;
    final shortfall = (data['shortfall'] ?? 0).toDouble();

    if (!hasShortfall) {
      return Icon(Icons.thumb_up, color: AppColors.success, size: 15);
    }

    if (shortfall <= 1) {
      return Icon(Icons.thumb_up, color: AppColors.success, size: 15);
    } else {
      return Icon(Icons.thumb_down, color: AppColors.error, size: 15);
    }
  }
}
