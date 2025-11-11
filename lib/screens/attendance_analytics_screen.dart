import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/analytics_data.dart';
import '../models/attendance_model.dart';
import '../providers/dashboard_provider.dart';
import '../services/analytics_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import 'attendance_detailed_screen.dart';

class AttendanceAnalyticsScreen extends StatefulWidget {
  final String? preSelectedProjectId;

  const AttendanceAnalyticsScreen({super.key, this.preSelectedProjectId});

  @override
  State<AttendanceAnalyticsScreen> createState() => _AttendanceAnalyticsScreenState();
}

class _AttendanceAnalyticsScreenState extends State<AttendanceAnalyticsScreen> {
  AnalyticsMode _mode = AnalyticsMode.daily;
  DateTime _selectedDate = DateTime.now();
  String? _selectedProjectId;
  AttendanceSummary? _summary;
  Map<String, double> _chartData = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.preSelectedProjectId;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final provider = context.read<AppProvider>();
    final userId = provider.user?.id ?? '';

    DateRange range = _getDateRange();

    _summary = await AnalyticsService.getSummary(
      userId,
      range.start,
      range.end,
      projectId: _selectedProjectId,
    );

    // Get records for chart
    final records = await AnalyticsService.getDailyRecords(
      userId,
      _selectedDate,
      projectId: _selectedProjectId,
    );

    _chartData = AnalyticsService.getChartData(records, _mode);

    setState(() => _loading = false);
  }

  DateRange _getDateRange() {
    switch (_mode) {
      case AnalyticsMode.daily:
        return DateRange(
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day),
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59),
        );
      case AnalyticsMode.weekly:
        final weekday = _selectedDate.weekday;
        final start = _selectedDate.subtract(Duration(days: weekday - 1));
        final end = start.add(Duration(days: 6, hours: 23, minutes: 59));
        return DateRange(start, end);
      case AnalyticsMode.monthly:
        return DateRange(
          DateTime(_selectedDate.year, _selectedDate.month, 1),
          DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59),
        );
    }
  }

  void _changeDate(int delta) {
    setState(() {
      switch (_mode) {
        case AnalyticsMode.daily:
          _selectedDate = _selectedDate.add(Duration(days: delta));
          break;
        case AnalyticsMode.weekly:
          _selectedDate = _selectedDate.add(Duration(days: delta * 7));
          break;
        case AnalyticsMode.monthly:
          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + delta, 1);
          break;
      }
    });
    _loadData();
  }

  String _getDateLabel() {
    switch (_mode) {
      case AnalyticsMode.daily:
        return '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
      case AnalyticsMode.weekly:
        final range = _getDateRange();
        return 'Week: ${range.start.day}/${range.start.month} - ${range.end.day}/${range.end.month}';
      case AnalyticsMode.monthly:
        return '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}';
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      appBar: AppBar(
        title: Text('Attendance Analytics', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Mode selector at top (as per sketch 2)
          _buildModeSelector(),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: _loading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    // Date selector with arrows (sketch 2)
                    _buildDateSelector(),
                    SizedBox(height: 20),
                    // Project/Node selector (sketch 3)
                    _buildProjectSelector(provider),
                    SizedBox(height: 20),
                    // Summary cards (sketch 2 & 3)
                    if (_summary != null) _buildSummaryCards(),
                    SizedBox(height: 20),
                    // Graph section (sketch 2 & 3)
                    _buildGraphSection(),
                    SizedBox(height: 20),
                    // Quick stats (sketch 3)
                    if (_mode == AnalyticsMode.weekly && _summary != null)
                      _buildQuickStats(),
                    SizedBox(height: 20),
                    // Button to detailed view (sketch 4)
                    _buildDetailedViewButton(),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Match sketch 2 - Mode selector buttons
  Widget _buildModeSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Expanded(child: _buildModeButton('Daily', AnalyticsMode.daily)),
          SizedBox(width: 10),
          Expanded(child: _buildModeButton('Weekly', AnalyticsMode.weekly)),
          SizedBox(width: 10),
          Expanded(child: _buildModeButton('Monthly', AnalyticsMode.monthly)),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, AnalyticsMode mode) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () {
        setState(() => _mode = mode);
        _loadData();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.primaryBlue : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Match sketch 2 - Date selector with left/right arrows
  Widget _buildDateSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, size: 28),
            onPressed: () => _changeDate(-1),
            color: AppColors.primaryBlue,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                _getDateLabel(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, size: 28),
            onPressed: () => _changeDate(1),
            color: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  // Match sketch 3 - Node/Project dropdown selector
  Widget _buildProjectSelector(AppProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Node / Project',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButton<String>(
              value: _selectedProjectId,
              hint: Text('All Projects'),
              isExpanded: true,
              underline: SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Row(
                    children: [
                      Icon(Icons.apps, size: 18, color: Colors.grey.shade600),
                      SizedBox(width: 10),
                      Text('All Projects'),
                    ],
                  ),
                ),
                ...provider.user!.projects.map((p) => DropdownMenuItem(
                  value: p.id,
                  child: Row(
                    children: [
                      Icon(Icons.work, size: 18, color: Colors.blue),
                      SizedBox(width: 10),
                      Text(p.name),
                    ],
                  ),
                )),
              ],
              onChanged: (value) {
                setState(() => _selectedProjectId = value);
                _loadData();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Match sketch 2 & 3 - Summary cards in grid
  Widget _buildSummaryCards() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 1.5,
        children: [
          _buildCard('Present', _summary!.present.toString(), Colors.green, Icons.check_circle),
          _buildCard('Absent', _summary!.absent.toString(), Colors.red, Icons.cancel),
          _buildCard('Late', _summary!.late.toString(), Colors.orange, Icons.access_time),
          _buildCard('Half Day', _summary!.halfDay.toString(), Colors.blue, Icons.schedule),
        ],
      ),
    );
  }

  Widget _buildCard(String label, String value, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Match sketch 2 & 3 - Bar graph section
  Widget _buildGraphSection() {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
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
              Text(
                '${_mode == AnalyticsMode.daily ? "Hourly" : "Daily"} Attendance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              if (_summary != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Avg: ${_summary!.avgHours.toStringAsFixed(1)}h',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _chartData.isEmpty
                ? Center(child: Text('No data available', style: TextStyle(color: Colors.grey)))
                : BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 12,
                barGroups: _chartData.entries.map((entry) {
                  final index = _chartData.keys.toList().indexOf(entry.key);
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: AppColors.primaryBlue,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}h',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final keys = _chartData.keys.toList();
                        if (value.toInt() < keys.length) {
                          final label = keys[value.toInt()].split('-').last;
                          return Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              label,
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Match sketch 3 - Quick stats for weekly view
  Widget _buildQuickStats() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Days', '${_summary!.present + _summary!.absent}'),
                _buildStatItem('Present %', '${((_summary!.present / (_summary!.present + _summary!.absent)) * 100).toStringAsFixed(0)}%'),
                _buildStatItem('Avg Hours', '${_summary!.avgHours.toStringAsFixed(1)}h'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // Match sketch 4 - Button to detailed table view
  Widget _buildDetailedViewButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton.icon(
        icon: Icon(Icons.table_chart, color: Colors.white),
        label: Text(
          'View Detailed Attendance Table',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          minimumSize: Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AttendanceDetailedScreen(
                dateRange: _getDateRange(),
                projectId: _selectedProjectId,
              ),
            ),
          );
        },
      ),
    );
  }
}