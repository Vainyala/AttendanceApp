// widgets/common/attendance_table_widget.dart
import 'package:flutter/material.dart';

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
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: isDailyView
                ? [
              _buildHeaderText('Check In', Colors.green),
              _buildHeaderText('Check Out', Colors.red),
              _buildHeaderText('Total Hrs', Colors.blue),
              _buildHeaderText(
                'Shortfall',
                (data['hasShortfall'] ?? false) ? Colors.red : Colors.green,
              ),
            ]
                : [
              _buildHeaderText('Days', Colors.grey.shade700),
              _buildHeaderText('P', Colors.green),
              _buildHeaderText('L', Colors.orange),
              _buildHeaderText('A', Colors.red),
              _buildHeaderText('OnTime', Colors.blue),
              _buildHeaderText('Late', Colors.purple),
            ],
          ),
          Divider(height: 20, color: Colors.grey.shade400, thickness: 1.5),
          Row(
            children: isDailyView
                ? [
              _buildDataText(data['checkIn'] ?? 'N/A', Colors.green),
              _buildDataText(data['checkOut'] ?? 'N/A', Colors.red),
              _buildDataText('${data['totalHours'] ?? 0}h', Colors.blue),
              _buildDataText(
                (data['hasShortfall'] ?? false) ? '${data['shortfall'] ?? 0}h' : 'None',
                (data['hasShortfall'] ?? false) ? Colors.red : Colors.green,
              ),
            ]
                : [
              _buildDataText('${data['totalDays'] ?? 0}', Colors.grey.shade800),
              _buildDataText('${data['present'] ?? 0}', Colors.green),
              _buildDataText('${data['leave'] ?? 0}', Colors.orange),
              _buildDataText('${data['absent'] ?? 0}', Colors.red),
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