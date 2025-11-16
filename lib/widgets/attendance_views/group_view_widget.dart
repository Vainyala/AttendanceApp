// widgets/attendance_views/group_view_widget.dart
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/analytics_data.dart';
import '../../providers/analytics_provider.dart';
import '../common/attendance_table_widget.dart';
import '../common/period_pie_chart_widget.dart';
import '../common/pie_chart_widget.dart';

class GroupViewWidget extends StatelessWidget {
  const GroupViewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, child) {
        final mode = provider.mode;
        final data = provider.getCurrentModeData();
        final chartTitle = '${provider.getModeLabel()} Attendance Chart';
        final dateInfo = provider.getFormattedDateInfo();

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              if (mode == AnalyticsMode.daily)
                _DailyGroupView(
                  data: data,
                  title: chartTitle,
                  dateInfo: dateInfo,
                )
              else
                _PeriodGroupView(
                  data: data,
                  title: chartTitle,
                  dateInfo: dateInfo,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DailyGroupView extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;
  final String dateInfo;

  const _DailyGroupView({
    required this.data,
    required this.title,
    required this.dateInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.textLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textHint.shade800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    dateInfo,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          AttendanceTableWidget(
            data: data,
            isDailyView: true,
          ),
          SizedBox(height: 20),
          DailyPieChartWidget(data: data),
        ],
      ),
    );
  }
}

class _PeriodGroupView extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;
  final String dateInfo;

  const _PeriodGroupView({
    required this.data,
    required this.title,
    required this.dateInfo,
  });

  @override
  Widget build(BuildContext context) {
    final totalDays = data['totalDays'];
    final totalPresent = data['present'];
    final totalLeave = data['leave'];
    final totalAbsent = data['absent'];
    final totalOnTime = data['onTime'];
    final totalLate = data['late'];

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.textLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHint.shade800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                dateInfo,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          AttendanceTableWidget(
            data: data,
            isDailyView: false,
          ),
          SizedBox(height: 20),
          PeriodPieChartWidget(data: data),
        ],
      ),
    );
  }
}