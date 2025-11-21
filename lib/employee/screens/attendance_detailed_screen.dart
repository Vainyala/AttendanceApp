// screens/attendance_details_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_details_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/attendance_history_section.dart';
import '../widgets/attendance_overview_card.dart';
import '../widgets/attendance_widgets.dart';
import '../widgets/emp_info_card.dart';
import '../widgets/export_option_sheet.dart';
import '../widgets/period_info_widget.dart';

class AttendanceDetailsScreen extends StatefulWidget {
  final String employeeId;
  final String periodType; // 'daily', 'weekly', 'monthly', 'quarterly'
  final String? projectId; // Optional project filter
  final String? projectName; // Optional project name for display

  const AttendanceDetailsScreen({
    super.key,
    required this.employeeId,
    this.periodType = 'quarterly',
    this.projectId,
    this.projectName,
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
        projectId: widget.projectId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textHint.shade50,
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
                    SizedBox(height: 16),
                    // Show project filter if provided
                    if (widget.projectId != null && widget.projectName != null)
                      _buildProjectFilterBanner(),

                    if (widget.projectId != null && widget.projectName != null)
                      SizedBox(height: 16),

                    PeriodInfoWidget(
                      periodType: provider.selectedPeriod,
                      dateRange: provider.dateRange,
                    ),
                    SizedBox(height: 16),
                    AttendanceOverviewCard(
                      periodType: provider.selectedPeriod,
                      attendanceStats: provider.attendanceStats,
                    ),
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

  Widget _buildProjectFilterBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.work_outline,
              color: Colors.blue.shade700,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtered by Project',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  widget.projectName ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // Clear filter and reload
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => AttendanceDetailsScreen(
                    employeeId: widget.employeeId,
                    periodType: widget.periodType,
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AttendanceDetailsProvider provider) {
    return SliverAppBar(
      expandedHeight: 50,
      pinned: true,
      backgroundColor: AppColors.primaryBlue,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textLight),
        onPressed: () => Navigator.pop(context),
      ),

      title: Text(
        'Attendance Details',
        style: TextStyle(
          color: AppColors.textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      centerTitle: false,

      // DOWNLOAD ICON WITH NO SHADOW
      actions: [
        IconButton(
          onPressed: () => _showExportOptions(context, provider),
          icon: Icon(Icons.download, color: AppColors.textLight, size: 24),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
      ],
      elevation: 0, // no shadow
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