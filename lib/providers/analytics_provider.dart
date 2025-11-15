// providers/attendance_analytics_provider.dart
import 'package:flutter/material.dart';

import '../models/analytics_data.dart';

enum ViewMode { group, person, project }

class AnalyticsProvider with ChangeNotifier {
  // View Mode State
  ViewMode _viewMode = ViewMode.group;
  ViewMode get viewMode => _viewMode;

  // Analytics Mode State
  AnalyticsMode _mode = AnalyticsMode.daily;
  AnalyticsMode get mode => _mode;

  // Date Selection State
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  int _selectedWeekIndex = 0;
  int get selectedWeekIndex => _selectedWeekIndex;

  int _selectedMonthIndex = 0;
  int get selectedMonthIndex => _selectedMonthIndex;

  int _selectedQuarterIndex = 0;
  int get selectedQuarterIndex => _selectedQuarterIndex;

  // Project Selection State
  String? _selectedProjectId;
  String? get selectedProjectId => _selectedProjectId;

  // Loading State
  bool _loading = false;
  bool get loading => _loading;

  // Dummy Data
  Map<String, dynamic> _dailyData = {};
  Map<String, dynamic> _weeklyData = {};
  Map<String, dynamic> _monthlyData = {};
  Map<String, dynamic> _quarterlyData = {};

  Map<String, dynamic> get dailyData => _dailyData;
  Map<String, dynamic> get weeklyData => _weeklyData;
  Map<String, dynamic> get monthlyData => _monthlyData;
  Map<String, dynamic> get quarterlyData => _quarterlyData;

  // Employee Projects Data
  List<Map<String, dynamic>> _employeeProjects = [];
  List<Map<String, dynamic>> get employeeProjects => _employeeProjects;

  // Team Summary Data
  Map<String, dynamic> _teamSummary = {
    'team': 50,
    'present': 35,
    'leave': 5,
    'absent': 10,
    'onTime': 30,
    'late': 5,
  };
  Map<String, dynamic> get teamSummary => _teamSummary;

  AnalyticsProvider() {
    _initializeData();
  }

  void _initializeData() {
    _generateDummyData();
    _loadEmployeeProjects();
  }

  void _generateDummyData() {
    print('🔄 Generating dummy data...');
    _dailyData = {
      'date': _selectedDate,
      'checkIn': '09:15 AM',
      'checkOut': '06:30 PM',
      'totalHours': 8.25,
      'requiredHours': 9.0,
      'shortfall': 0.75,
      'hasShortfall': true,
    };

    _weeklyData = {
      'totalDays': 7,
      'present': 5,
      'leave': 1,
      'absent': 1,
      'onTime': 4,
      'late': 2,
    };

    _monthlyData = {
      'totalDays': 30,
      'present': 22,
      'leave': 3,
      'absent': 5,
      'onTime': 18,
      'late': 7,
    };

    _quarterlyData = {
      'totalDays': 90,
      'present': 70,
      'leave': 10,
      'absent': 10,
      'onTime': 60,
      'late': 20,
    };
  }

  void _loadEmployeeProjects() {
    _employeeProjects = [
      {
        'id': 'proj1',
        'name': 'E-Commerce Platform',
        'status': 'ACTIVE',
        'progress': 65.0,
        'members': 8,
        'tasks': 23,
        'daysLeft': 45,
        'teamMembers': ['Amit Kumar', 'Neha Patel', 'Rahul Sharma'],
        'myTask': 'Frontend Development',
        'present': 18,
        'leave': 2,
        'absent': 1,
        'onTime': 16,
        'late': 3,
      },
      {
        'id': 'proj2',
        'name': 'Mobile App Redesign',
        'status': 'ACTIVE',
        'progress': 35.0,
        'members': 5,
        'tasks': 12,
        'daysLeft': 60,
        'teamMembers': ['Priya Singh', 'Vikram Desai'],
        'myTask': 'UI/UX Design',
        'present': 15,
        'leave': 1,
        'absent': 0,
        'onTime': 14,
        'late': 2,
      },
      {
        'id': 'proj3',
        'name': 'Banking System Upgrade',
        'status': 'ACTIVE',
        'progress': 85.0,
        'members': 12,
        'tasks': 45,
        'daysLeft': 15,
        'teamMembers': ['Sandeep Gupta', 'Anjali Verma', 'Karan Singh'],
        'myTask': 'Backend Development',
        'present': 20,
        'leave': 3,
        'absent': 2,
        'onTime': 18,
        'late': 4,
      },
    ];
  }

  // View Mode Methods
  void setViewMode(ViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  // Analytics Mode Methods
  void setMode(AnalyticsMode mode) {
    _mode = mode;
    notifyListeners();
  }

  // Date Selection Methods
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _generateDummyData(); // Regenerate data for new date
    notifyListeners();
  }

  void changeDate(int delta) {
    final newDate = _selectedDate.add(Duration(days: delta));
    if (newDate.isBefore(DateTime.now().add(Duration(days: 1)))) {
      _selectedDate = newDate;
      _generateDummyData();
      notifyListeners();
    }
  }

  void setWeekIndex(int index) {
    _selectedWeekIndex = index;
    notifyListeners();
  }

  void setMonthIndex(int index) {
    _selectedMonthIndex = index;
    notifyListeners();
  }

  void setQuarterIndex(int index) {
    _selectedQuarterIndex = index;
    notifyListeners();
  }

  void incrementWeekIndex() {
    if (_selectedWeekIndex < 3) {
      _selectedWeekIndex++;
      notifyListeners();
    }
  }

  void decrementWeekIndex() {
    if (_selectedWeekIndex > 0) {
      _selectedWeekIndex--;
      notifyListeners();
    }
  }

  void incrementMonthIndex() {
    if (_selectedMonthIndex < 3) {
      _selectedMonthIndex++;
      notifyListeners();
    }
  }

  void decrementMonthIndex() {
    if (_selectedMonthIndex > 0) {
      _selectedMonthIndex--;
      notifyListeners();
    }
  }

  void incrementQuarterIndex() {
    if (_selectedQuarterIndex < 3) {
      _selectedQuarterIndex++;
      notifyListeners();
    }
  }

  void decrementQuarterIndex() {
    if (_selectedQuarterIndex > 0) {
      _selectedQuarterIndex--;
      notifyListeners();
    }
  }

  // Project Selection Methods
  void setProjectId(String? projectId) {
    _selectedProjectId = projectId;
    notifyListeners();
  }

  // Loading Methods
  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  // Data Fetching Methods
  Map<String, dynamic> getCurrentModeData() {
    switch (_mode) {
      case AnalyticsMode.daily:
        return _dailyData;
      case AnalyticsMode.weekly:
        return _weeklyData;
      case AnalyticsMode.monthly:
        return _monthlyData;
      case AnalyticsMode.quarterly:
        return _quarterlyData;
      default:
        return {};
    }
  }

  // Helper Methods
  String getModeLabel() {
    switch (_mode) {
      case AnalyticsMode.daily:
        return 'Daily';
      case AnalyticsMode.weekly:
        return 'Weekly';
      case AnalyticsMode.monthly:
        return 'Monthly';
      case AnalyticsMode.quarterly:
        return 'Quarterly';
      default:
        return '';
    }
  }

  String getPeriodType() {
    switch (_mode) {
      case AnalyticsMode.daily:
        return 'daily';
      case AnalyticsMode.weekly:
        return 'weekly';
      case AnalyticsMode.monthly:
        return 'monthly';
      case AnalyticsMode.quarterly:
        return 'quarterly';
      default:
        return 'daily';
    }
  }

  String getDateLabel() {
    switch (_mode) {
      case AnalyticsMode.daily:
        return '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';
      case AnalyticsMode.weekly:
        return _getWeekLabel(_selectedWeekIndex);
      case AnalyticsMode.monthly:
        return _getMonthLabel(_selectedMonthIndex);
      case AnalyticsMode.quarterly:
        return _getQuarterLabel(_selectedQuarterIndex);
      default:
        return '';
    }
  }

  String getFormattedDateInfo() {
    switch (_mode) {
      case AnalyticsMode.daily:
        return '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}';
      case AnalyticsMode.weekly:
        return _getWeekLabel(_selectedWeekIndex).replaceAll('\n', ' ');
      case AnalyticsMode.monthly:
        return _getMonthLabel(_selectedMonthIndex).replaceAll('\n', ' ');
      case AnalyticsMode.quarterly:
        return _getQuarterLabel(_selectedQuarterIndex).replaceAll('\n', ' ');
      default:
        return '';
    }
  }

  String _getWeekLabel(int index) {
    final now = DateTime.now();
    final targetDate = now.subtract(Duration(days: 7 * index));
    final weekStart = targetDate.subtract(Duration(days: targetDate.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));

    if (index == 0) {
      return 'Current Week\n(${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month})';
    } else {
      return 'Week $index ago\n(${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month})';
    }
  }

  String _getMonthLabel(int index) {
    final now = DateTime.now();
    final targetMonth = DateTime(now.year, now.month - index, 1);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    int safeMonth = targetMonth.month - 1;
    if (safeMonth < 0) safeMonth += 12;

    if (index == 0) {
      return 'Current Month\n(${months[safeMonth]} ${targetMonth.year})';
    } else {
      return '${months[safeMonth]} ${targetMonth.year}';
    }
  }

  String _getQuarterLabel(int index) {
    final now = DateTime.now();
    final currentQuarter = ((now.month - 1) ~/ 3) + 1;
    final targetQuarter = currentQuarter - index;
    final year = targetQuarter > 0 ? now.year : now.year - 1;
    final quarter = targetQuarter > 0 ? targetQuarter : 4 + targetQuarter;

    if (index == 0) {
      return 'Current Quarter\n(Q$quarter $year)';
    } else {
      return 'Q$quarter $year';
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  // Refresh data method
  Future<void> refreshData() async {
    setLoading(true);
    await Future.delayed(Duration(seconds: 1)); // Simulate API call
    _generateDummyData();
    _loadEmployeeProjects();
    setLoading(false);
  }
}