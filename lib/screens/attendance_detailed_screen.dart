// attendance_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_details_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/allocated_pro_cards.dart';
import '../widgets/attendance_history_section.dart';
import '../widgets/attendance_overview_card.dart';
import '../widgets/attendance_widgets.dart';
import '../widgets/emp_info_card.dart';
import '../widgets/export_option_sheet.dart';
import '../widgets/period_info_widget.dart';

class AttendanceDetailsScreen extends StatefulWidget {
  final String employeeId;
  final String periodType; // 'daily', 'weekly', 'monthly', 'quarterly'

  const AttendanceDetailsScreen({
    super.key,
    required this.employeeId,
    this.periodType = 'quarterly',
  });

  @override
  State<AttendanceDetailsScreen> createState() => _AttendanceDetailsScreenState();
}

class _AttendanceDetailsScreenState extends State<AttendanceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceDetailsProvider>().loadEmployeeDetails(
        widget.employeeId,
        widget.periodType,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Consumer<AttendanceDetailsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, provider),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    PeriodTabsWidget(
                      selectedPeriod: provider.selectedPeriod,
                      onPeriodChanged: (period) {
                        provider.changePeriod(period, widget.employeeId);
                      },
                    ),
                    SizedBox(height: 16),
                    PeriodInfoWidget(
                      periodType: provider.selectedPeriod,
                      dateRange: provider.dateRange,
                    ),
                    SizedBox(height: 16),
                    EmployeeInfoCard(employee: provider.employee),
                    SizedBox(height: 16),
                    AttendanceOverviewCard(
                      periodType: provider.selectedPeriod,
                      attendanceStats: provider.attendanceStats,
                    ),
                    SizedBox(height: 16),
                    AllocatedProjectsCard(projects: provider.allocatedProjects),
                    SizedBox(height: 16),
                    AttendanceHistorySection(
                      periodType: provider.selectedPeriod,
                      attendanceRecords: provider.attendanceRecords,
                      selectedFilter: provider.selectedFilter,
                      onFilterChanged: provider.setFilter,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AttendanceDetailsProvider provider) {
    return SliverAppBar(
      expandedHeight: 70,
      pinned: true,
      backgroundColor: AppColors.primaryBlue,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBlue,
                AppColors.primaryBlue.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(60, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Employee Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16, top: 10),
          child: ElevatedButton.icon(
            onPressed: () => _showExportOptions(context, provider),
            icon: Icon(Icons.file_download, size: 18),
            label: Text("", style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showExportOptions(BuildContext context, AttendanceDetailsProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ExportOptionsSheet(
        onExport: (format) {
          provider.exportData(format);
          Navigator.pop(context);
        },
      ),
    );
  }
}