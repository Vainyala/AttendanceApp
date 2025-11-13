import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../models/project_model.dart';

class AttendanceDetailedScreen extends StatefulWidget {
  final String? preSelectedProjectId;

  const AttendanceDetailedScreen({
    super.key,
    this.preSelectedProjectId,
  });

  @override
  State<AttendanceDetailedScreen> createState() => _AttendanceDetailedScreenState();
}

class _AttendanceDetailedScreenState extends State<AttendanceDetailedScreen> {
  String? _selectedProjectId;
  DateTimeRange? _selectedDateRange;
  List<Map<String, dynamic>> _attendanceData = [];
  bool _isLoading = false;

  // Summary Stats
  int _totalPresent = 0;
  int _totalAbsent = 0;
  int _totalLate = 0;
  int _totalOnTime = 0;
  double _avgHours = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.preSelectedProjectId;

    // Default date range: Current month
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );

    _loadAttendanceData();
  }

  void _loadAttendanceData() {
    setState(() => _isLoading = true);

    // Generate dummy attendance data for the selected date range
    _attendanceData = _generateDummyAttendanceData();
    _calculateSummary();

    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> _generateDummyAttendanceData() {
    List<Map<String, dynamic>> data = [];

    if (_selectedDateRange == null) return data;

    final startDate = _selectedDateRange!.start;
    final endDate = _selectedDateRange!.end;

    for (DateTime date = startDate;
    date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
    date = date.add(Duration(days: 1))) {

      if (date.weekday == DateTime.sunday) continue;

      String status;
      String inTime;
      String outTime;
      double hours;
      final dayNum = date.day;

      if (dayNum % 7 == 0) {
        status = 'Absent';
        inTime = '-';
        outTime = '-';
        hours = 0;
      } else if (dayNum % 6 == 0) {
        status = 'Late';
        inTime = '10:${(15 + (dayNum % 30)).toString().padLeft(2, '0')}';
        outTime = '18:${(30 + (dayNum % 20)).toString().padLeft(2, '0')}';
        hours = 8.0 + (dayNum % 2);
      } else if (dayNum % 5 == 0) {
        status = 'OnTime';
        inTime = '09:${(dayNum % 30).toString().padLeft(2, '0')}';
        outTime = '17:${(dayNum % 30).toString().padLeft(2, '0')}';
        hours = 7.5 + (dayNum % 2) * 0.5;
      } else {
        status = 'OnTime';
        inTime = '09:${(dayNum % 30).toString().padLeft(2, '0')}';
        outTime = '18:${(15 + (dayNum % 30)).toString().padLeft(2, '0')}';
        hours = 9.0 + (dayNum % 2) * 0.25;
      }

      data.add({
        'date': DateFormat('dd MMM yyyy').format(date),
        'dayName': DateFormat('EEE').format(date),
        'rawDate': date,
        'inTime': inTime,
        'outTime': outTime,
        'status': status,
        'hours': hours,
        'project': _getProjectName(),
        'location': dayNum % 3 == 0 ? 'WFH' : 'Office',
      });
    }

    return data.reversed.toList();
  }

  String _getProjectName() {
    final provider = context.read<AppProvider>();

    if (_selectedProjectId != null && provider.user?.projects != null) {
      final project = provider.user!.projects.firstWhere(
            (p) => p.id == _selectedProjectId,
        orElse: () => provider.user!.projects.first,
      );
      return project.name;
    }

    return provider.user?.projects.first.name ?? 'All Projects';
  }

  void _calculateSummary() {
    _totalPresent = 0;
    _totalAbsent = 0;
    _totalLate = 0;
    _totalOnTime = 0;
    double totalHours = 0;

    for (var record in _attendanceData) {
      switch (record['status']) {
        case 'Absent':
          _totalAbsent++;
          break;
        case 'Late':
          _totalLate++;
          _totalPresent++;
          break;
        case 'OnTime':
          _totalOnTime++;
          _totalPresent++;
          break;
      }
      totalHours += record['hours'] as double;
    }

    _avgHours = _attendanceData.isEmpty ? 0 : totalHours / _attendanceData.length;
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      _loadAttendanceData();
    }
  }

  void _exportData(String format) {
    // In real implementation, you would generate the file here
    // For now, just show a success message
    _showMessage('Downloading $format...');

    // Simulate download delay
    Future.delayed(Duration(seconds: 1), () {
      _showMessage('$format downloaded successfully!');
    });
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Export Attendance Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildExportOption(
              icon: Icons.picture_as_pdf,
              title: 'Export as PDF',
              subtitle: 'Download attendance report',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _exportData('PDF');
              },
            ),
            _buildExportOption(
              icon: Icons.table_chart,
              title: 'Export as Excel',
              subtitle: 'Download .xlsx file',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                _exportData('Excel');
              },
            ),
            _buildExportOption(
              icon: Icons.description,
              title: 'Export as CSV',
              subtitle: 'Download .csv file',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                _exportData('CSV');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Attendance Analytics', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download_outlined),
            onPressed: _showExportOptions,
            tooltip: 'Export Data',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildFilters(),
            _buildSummaryCards(),
            _buildAttendanceList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final provider = context.watch<AppProvider>();

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 12),

          // Project Dropdown
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text('Select Project', style: TextStyle(fontSize: 14)),
                value: _selectedProjectId,
                icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryBlue),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text('All Projects', style: TextStyle(fontSize: 14)),
                  ),
                  if (provider.user?.projects != null)
                    ...provider.user!.projects.map((project) {
                      return DropdownMenuItem(
                        value: project.id,
                        child: Text(project.name, style: TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedProjectId = value;
                  });
                  _loadAttendanceData();
                },
              ),
            ),
          ),

          SizedBox(height: 12),

          // Date Range Selector
          InkWell(
            onTap: _selectDateRange,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.date_range, size: 20, color: AppColors.primaryBlue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDateRange != null
                          ? '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_selectedDateRange!.end)}'
                          : 'Select Date Range',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCompactSummaryCard(
                  'Present',
                  _totalPresent.toString(),
                  Icons.check_circle_outline,
                  Color(0xFF4CAF50),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildCompactSummaryCard(
                  'Absent',
                  _totalAbsent.toString(),
                  Icons.cancel_outlined,
                  Color(0xFFE53935),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildCompactSummaryCard(
                  'On Time',
                  _totalOnTime.toString(),
                  Icons.access_time,
                  Color(0xFF2196F3),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildCompactSummaryCard(
                  'Late',
                  _totalLate.toString(),
                  Icons.warning_amber_outlined,
                  Color(0xFFFF9800),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.timelapse, color: Colors.white, size: 20),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Avg Hours/Day',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_avgHours.toStringAsFixed(1)}h',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (_attendanceData.isEmpty) {
      return Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
              SizedBox(height: 16),
              Text(
                'No attendance records found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try selecting a different date range',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Attendance Records',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_attendanceData.length} Days',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _attendanceData.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final record = _attendanceData[index];
              return _buildAttendanceCard(record);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record) {
    Color statusColor;
    IconData statusIcon;

    switch (record['status']) {
      case 'Absent':
        statusColor = Color(0xFFE53935);
        statusIcon = Icons.cancel;
        break;
      case 'Late':
        statusColor = Color(0xFFFF9800);
        statusIcon = Icons.schedule;
        break;
      case 'OnTime':
        statusColor = Color(0xFF4CAF50);
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // Date Section
          Container(
            width: 50,
            child: Column(
              children: [
                Text(
                  record['date'].split(' ')[0], // Day number
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  record['dayName'], // Day name
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 16),

          // Main Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          SizedBox(width: 4),
                          Text(
                            record['status'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            record['location'] == 'WFH'
                                ? Icons.home_outlined
                                : Icons.business_outlined,
                            size: 12,
                            color: Colors.grey.shade700,
                          ),
                          SizedBox(width: 4),
                          Text(
                            record['location'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.login, size: 14, color: Colors.grey.shade600),
                    SizedBox(width: 4),
                    Text(
                      record['inTime'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.logout, size: 14, color: Colors.grey.shade600),
                    SizedBox(width: 4),
                    Text(
                      record['outTime'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Spacer(),
                    if (record['hours'] > 0)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${record['hours'].toStringAsFixed(1)}h',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}