
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_details_provider.dart';
import '../utils/app_colors.dart';
import 'dart:ui';
import '../models/attendance_record.dart';
import '../utils/app_colors.dart';
import 'export_option_sheet.dart';
// Attendance History Section
class AttendanceHistorySection extends StatelessWidget {
  final String periodType;
  final List<AttendanceRecords> attendanceRecords;
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const AttendanceHistorySection({
    super.key,
    required this.periodType,
    required this.attendanceRecords,
    required this.selectedFilter,
    required this.onFilterChanged,
  });


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceDetailsProvider>(context);
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.textLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textHint.shade900,
            ),
          ),
          SizedBox(height: 16),
          _buildFilters(),
          SizedBox(height: 16),
          _buildTableHeader(),
          SizedBox(height: 8),
          if (periodType.toLowerCase() == "quarterly")
            _buildQuarterlyDownloadBox(context, provider)
          else
            ...attendanceRecords.map((record) => _buildRecordRow(record)).toList(),
        ],
      ),
    );
  }

  Widget _buildQuarterlyDownloadBox(
      BuildContext context,
      AttendanceDetailsProvider provider
      ) {
    return GestureDetector(
      onTap: () => _showExportOptions(context, provider),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
        ),
        child: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.download, color: AppColors.primaryBlue, size: 20),
              SizedBox(width: 8),
              Text(
                "Click here to download \nfull attendance history",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),
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


  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          SizedBox(width: 8),
          _buildFilterChip('Present', 'present'),
          SizedBox(width: 8),
          _buildFilterChip('Absent', 'absent'),
          SizedBox(width: 8),
          _buildFilterChip('Late', 'late'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter == value;
    return GestureDetector(
      onTap: () => onFilterChanged(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.textHint.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.check, size: 16, color: AppColors.textLight),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.textLight : AppColors.textHint.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.textHint.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: _buildHeaderText('Date')),
          Expanded(flex: 1, child: _buildHeaderText('Status')),
          Expanded(flex: 1, child: _buildHeaderText('Check \nIn')),
          Expanded(flex: 1, child: _buildHeaderText('Check \nOut')),
          Expanded(flex: 1, child: _buildHeaderText('Hours')),
          Expanded(flex: 1, child: _buildHeaderText('Shortfall')),
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.textHint.shade700,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRecordRow(AttendanceRecords record) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.textHint.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  record.dateFormatted.split('/')[0],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHint.shade800,
                  ),
                ),
                Text(
                  record.dayName,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildStatusBadge(record.status),
          ),
          Expanded(
            flex: 1,
            child: Text(
              record.checkIn,
              style: TextStyle(fontSize: 12, color: AppColors.textHint.shade700),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              record.checkOut,
              style: TextStyle(fontSize: 12, color: AppColors.textHint.shade700),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              record.hours > 0 ? formatHM(record.hours) : "-",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Builder(
              builder: (_) {
                const required = 9.0; // required hours
                double shortfall = required - record.hours;

                return Text(
                  shortfall > 0 ? formatHM(shortfall) : "0h 0m",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: shortfall > 0 ? Colors.red : Colors.green,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String formatHM(double hours) {
    if (hours <= 0) return "-";
    final h = hours.floor();
    final m = ((hours % 1) * 60).round();
    return "${h}h ${m}m";
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'present':
        color = Color(0xFF4CAF50);
        label = 'P';
        break;
      case 'absent':
        color = Color(0xFFE53935);
        label = 'A';
        break;
      case 'late':
        color = Color(0xFFFF9800);
        label = 'L';
        break;
      default:
        color = AppColors.textHint;
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}