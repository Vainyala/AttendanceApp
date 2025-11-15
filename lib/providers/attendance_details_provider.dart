
// providers/attendance_details_provider.dart
import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../models/attendance_stats.dart';
import '../models/emp_model.dart';
import '../models/projects_model.dart';

class AttendanceDetailsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _selectedPeriod = 'quarterly';
  String _selectedFilter = 'all';

  EmployeeModel? _employee;
  AttendanceStats? _attendanceStats;
  List<ProjectsModel> _allocatedProjects = [];
  List<AttendanceRecord> _attendanceRecords = [];
  String _dateRange = '';

  // Getters
  bool get isLoading => _isLoading;
  String get selectedPeriod => _selectedPeriod;
  String get selectedFilter => _selectedFilter;
  EmployeeModel? get employee => _employee;
  AttendanceStats? get attendanceStats => _attendanceStats;
  List<ProjectsModel> get allocatedProjects => _allocatedProjects;
  List<AttendanceRecord> get attendanceRecords => _filteredRecords;
  String get dateRange => _dateRange;

  List<AttendanceRecord> get _filteredRecords {
    if (_selectedFilter == 'all') return _attendanceRecords;
    return _attendanceRecords
        .where((record) => record.status.toLowerCase() == _selectedFilter)
        .toList();
  }

  Future<void> loadEmployeeDetails(
      String employeeId,
      String periodType, {
        String? projectId,
      }) async {

    _isLoading = true;
    _selectedPeriod = periodType;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: 500)); // Simulate API call

    _employee = _generateDummyEmployee();
    _allocatedProjects = _generateDummyProjects();
    _generateAttendanceData();
    _calculateStats();
    _updateDateRange();

    _isLoading = false;
    notifyListeners();
  }

  void changePeriod(String period, String employeeId, {String? projectId}) {
    _selectedPeriod = period;
    _selectedFilter = 'all';
    loadEmployeeDetails(
      employeeId,
      period,
      projectId: projectId,
    );
  }


  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void _updateDateRange() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'daily':
        _dateRange = 'Today: ${_formatDate(now)}';
        break;
      case 'weekly':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(Duration(days: 6));
        _dateRange = 'From: ${_formatDate(weekStart)} To: ${_formatDate(weekEnd)}';
        break;
      case 'monthly':
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 0);
        _dateRange = 'From: ${_formatDate(monthStart)} To: ${_formatDate(monthEnd)}';
        break;
      case 'quarterly':
        final quarter = ((now.month - 1) ~/ 3) + 1;
        final quarterStart = DateTime(now.year, (quarter - 1) * 3 + 1, 1);
        final quarterEnd = DateTime(now.year, quarter * 3 + 1, 0);
        final months = ['January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'];
        _dateRange = 'From: ${months[quarterStart.month - 1]} To: ${months[quarterEnd.month - 1]}';
        break;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _generateAttendanceData() {
    _attendanceRecords.clear();
    final now = DateTime.now();
    int daysCount = _getDaysCount();

    for (int i = 0; i < daysCount; i++) {
      final date = now.subtract(Duration(days: i));
      if (date.weekday == DateTime.sunday) continue;

      final dayNum = date.day;
      String status;
      String checkIn;
      String checkOut;
      double hours;

      if (dayNum % 7 == 0) {
        status = 'absent';
        checkIn = '-';
        checkOut = '-';
        hours = 0;
      } else if (dayNum % 6 == 0) {
        status = 'late';
        checkIn = '10:${(15 + dayNum % 30).toString().padLeft(2, '0')}';
        checkOut = '18:${(30 + dayNum % 20).toString().padLeft(2, '0')}';
        hours = 8.0 + (dayNum % 2);
      } else {
        status = 'present';
        checkIn = '09:${(dayNum % 30).toString().padLeft(2, '0')}';
        checkOut = '18:${(15 + dayNum % 30).toString().padLeft(2, '0')}';
        hours = 9.0 + (dayNum % 2) * 0.25;
      }

      _attendanceRecords.add(AttendanceRecord(
        date: date,
        status: status,
        checkIn: checkIn,
        checkOut: checkOut,
        hours: hours,
      ));
    }
  }

  int _getDaysCount() {
    switch (_selectedPeriod) {
      case 'daily':
        return 1;
      case 'weekly':
        return 7;
      case 'monthly':
        return 30;
      case 'quarterly':
        return 90;
      default:
        return 30;
    }
  }

  void _calculateStats() {
    int present = 0;
    int absent = 0;
    int late = 0;
    int leave = 0;
    double totalHours = 0;
    int totalDays = _attendanceRecords.length;

    for (var record in _attendanceRecords) {
      totalHours += record.hours;
      switch (record.status) {
        case 'present':
          present++;
          break;
        case 'absent':
          absent++;
          break;
        case 'late':
          late++;
          present++;
          break;
      }
    }

    final attendancePercentage = totalDays > 0 ? (present / totalDays * 100).toInt() : 0;

    _attendanceStats = AttendanceStats(
      present: present,
      absent: absent,
      late: late,
      leave: leave,
      totalDays: totalDays,
      attendancePercentage: attendancePercentage,
    );
  }

  EmployeeModel _generateDummyEmployee() {
    return EmployeeModel(
      id: 'EMP001',
      name: 'Amit Kumar',
      designation: 'QA Engineer',
      email: 'amit.kumar@nutantek.com',
      phone: '+919876543212',
      status: 'active',
      avatarUrl: null,
    );
  }

  List<ProjectsModel> _generateDummyProjects() {
    return [
      ProjectsModel(id: '1', name: 'E-Commerce Platform', status: 'Active'),
      ProjectsModel(id: '2', name: 'Banking System Upgrade', status: 'Active'),
      ProjectsModel(id: '3', name: 'Inventory Management System', status: 'Active'),
    ];
  }

  void exportData(String format) {
    // Simulate export
    print('Exporting data as $format');
  }
}