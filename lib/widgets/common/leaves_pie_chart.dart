import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/app_colors.dart';

class LeavePieChartWidget extends StatelessWidget {
  final Map<String, int> data; // Changed from Map<String, dynamic>

  const LeavePieChartWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract values using the correct keys from provider
    final casual = data['Casual Leave'] ?? 0;
    final sick = data['Sick Leave'] ?? 0;
    final annual = data['Annual Leave'] ?? 0;
    final emergency = data['Emergency Leave'] ?? 0;
    final maternity = data['Maternity Leave'] ?? 0;
    final paternity = data['Paternity Leave'] ?? 0;

    // Calculate total to check if there's any data
    final total = casual + sick + annual + emergency + maternity + paternity;

    return Container(
      height: 260,
      margin: EdgeInsets.symmetric(horizontal: 16),
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
      child: total == 0
          ? Center(
        child: Text(
          'No leave data available',
          style: TextStyle(
            color: AppColors.textHint,
            fontSize: 14,
          ),
        ),
      )
          : Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _buildSections(
                  casual,
                  sick,
                  annual,
                  emergency,
                  maternity,
                  paternity,
                ),
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
                _legend("Casual", Colors.blue, casual),
                SizedBox(height: 8),
                _legend("Sick", Colors.green, sick),
                SizedBox(height: 8),
                _legend("Annual", Colors.orange, annual),
                SizedBox(height: 8),
                _legend("Emergency", Colors.red, emergency),
                SizedBox(height: 8),
                _legend("Maternity", Colors.purple, maternity),
                SizedBox(height: 8),
                _legend("Paternity", Colors.teal, paternity),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(
      int casual,
      int sick,
      int annual,
      int emergency,
      int maternity,
      int paternity,
      ) {
    final sections = <PieChartSectionData>[];

    if (casual > 0) {
      sections.add(_section(casual, "Casual", Colors.blue));
    }
    if (sick > 0) {
      sections.add(_section(sick, "Sick", Colors.green));
    }
    if (annual > 0) {
      sections.add(_section(annual, "Annual", Colors.orange));
    }
    if (emergency > 0) {
      sections.add(_section(emergency, "Emergency", Colors.red));
    }
    if (maternity > 0) {
      sections.add(_section(maternity, "Maternity", Colors.purple));
    }
    if (paternity > 0) {
      sections.add(_section(paternity, "Paternity", Colors.teal));
    }

    return sections;
  }

  PieChartSectionData _section(int value, String title, Color color) {
    return PieChartSectionData(
      value: value.toDouble(),
      title: '$value',
      color: color,
      radius: 50,
      titleStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textLight,
      ),
    );
  }

  Widget _legend(String label, Color color, int value) {
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
        SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}