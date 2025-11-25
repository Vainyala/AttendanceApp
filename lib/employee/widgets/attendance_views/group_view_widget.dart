
import 'package:flutter/material.dart';
import '../../providers/attendance_details_provider.dart';
import '../../screens/attendance_detailed_screen.dart';
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

        print('🎨 Building GroupViewWidget - Mode: $mode');
        print('📊 Data: $data');

        return Container(
          width: double.infinity,
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
      width: double.infinity,
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
              Expanded(
                child: Column(
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
              ),
              IconButton(
                icon: Icon(Icons.file_copy_rounded,
                    size: 20, color: AppColors.primaryBlue),
                onPressed: () => _openDetails(context),
              ),
            ],
          ),
          SizedBox(height: 16),
          AttendanceTableWidget(
            data: data,
            isDailyView: true,
          ),
          SizedBox(height: 12),
          DailyPieChartWidget(data: data),
        ],
      ),
    );
  }

  void _openDetails(BuildContext context) {
    final provider = context.read<AnalyticsProvider>();  // ✅ correct provider

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceDetailsScreen(
          employeeId: data['employeeId'] ?? 'emp123',
          periodType: 'daily',
          projectId: data['projectId'],
          selectedDate: provider.selectedDate,  // ✅ now correct
          projectName: data['projectName'],
        ),
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
    return Container(
      width: double.infinity,
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
              Expanded(
                child: Column(
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
              ),
              IconButton(
                icon: Icon(Icons.file_copy_rounded,
                    size: 20, color: AppColors.primaryBlue),
                onPressed: () => _openDetails(context),
              ),
            ],
          ),
          SizedBox(height: 16),
          AttendanceTableWidget(
            data: data,
            isDailyView: false,
          ),
          SizedBox(height: 12),
          PeriodPieChartWidget(data: data),
        ],
      ),
    );
  }

  void _openDetails(BuildContext context) {
    final provider = context.read<AnalyticsProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceDetailsScreen(
          employeeId: data['employeeId'] ?? 'emp123',
          periodType: provider.getPeriodType(),
          projectId: data['projectId'],
          projectName: data['projectName'],
          selectedDate: provider.selectedDate,
        ),
      ),
    );
  }
}