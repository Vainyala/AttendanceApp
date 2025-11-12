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
        inTime = '10:${15 + (dayNum % 30)}';   // ✅ Now both are numbers → result is string
        outTime = '18:${30 + (dayNum % 20)}';
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
        'rawDate': date,
        'inTime': inTime,
        'outTime': outTime,
        'status': status,
        'hours': hours,
        'project': _getProjectName(),
        'location': dayNum % 3 == 0 ? 'WFH' : 'Nutantek Office',
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

  void _exportData() {
    // Show export options
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                _showMessage('PDF export coming soon');
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart, color: Colors.green),
              title: Text('Export as Excel'),
              onTap: () {
                Navigator.pop(context);
                _showMessage('Excel export coming soon');
              },
            ),
            ListTile(
              leading: Icon(Icons.description, color: Colors.blue),
              title: Text('Export as CSV'),
              onTap: () {
                Navigator.pop(context);
                _showMessage('CSV export coming soon');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textLight,
      appBar: AppBar(
        title: Text('Attendance Analytics'),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _exportData,
            tooltip: 'Export Data',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildFilters(),
          _buildSummaryCards(),
          Expanded(child: _buildAttendanceTable()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final provider = context.watch<AppProvider>();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
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
                hint: Text('Select Project'),
                value: _selectedProjectId,
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text('All Projects'),
                  ),
                  if (provider.user?.projects != null)
                    ...provider.user!.projects.map((project) {
                      return DropdownMenuItem(
                        value: project.id,
                        child: Text(project.name),
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
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20, color: AppColors.primaryBlue),
                      SizedBox(width: 12),
                      Text(
                        _selectedDateRange != null
                            ? '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_selectedDateRange!.end)}'
                            : 'Select Date Range',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey),
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
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Present',
                  _totalPresent.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Absent',
                  _totalAbsent.toString(),
                  Icons.cancel,
                  Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'On Time',
                  _totalOnTime.toString(),
                  Icons.schedule,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Late',
                  _totalLate.toString(),
                  Icons.warning,
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.purple, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Avg Hours/Day',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                Text(
                  _avgHours.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTable() {
    if (_attendanceData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'No attendance records found',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 8),
            Text(
              'Try selecting a different date range',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: _buildHeaderCell('Date')),
                Expanded(flex: 2, child: _buildHeaderCell('In Time')),
                Expanded(flex: 2, child: _buildHeaderCell('Out Time')),
                Expanded(flex: 2, child: _buildHeaderCell('Status')),
                Expanded(flex: 1, child: _buildHeaderCell('Hours')),
                Expanded(flex: 2, child: _buildHeaderCell('Location')),
              ],
            ),
          ),

          // Table Body
          Expanded(
            child: ListView.builder(
              itemCount: _attendanceData.length,
              itemBuilder: (context, index) {
                final record = _attendanceData[index];
                return _buildTableRow(record, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryBlue,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTableRow(Map<String, dynamic> record, int index) {
    Color statusColor;
    switch (record['status']) {
      case 'Absent':
        statusColor = Colors.red;
        break;
      case 'Late':
        statusColor = Colors.orange;
        break;
      case 'OnTime':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              record['date'],
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              record['inTime'],
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              record['outTime'],
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                record['status'],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              record['hours'] > 0 ? record['hours'].toStringAsFixed(1) : '-',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              record['location'],
              style: TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}