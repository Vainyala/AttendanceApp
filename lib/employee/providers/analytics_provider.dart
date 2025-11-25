// providers/attendance_analytics_provider.dart
import 'package:flutter/material.dart';
import '../models/analytics_data.dart';
import '../widgets/date_time_utils.dart';

enum ViewMode { all, project }

class AnalyticsProvider with ChangeNotifier {
  // View Mode State
  ViewMode _viewMode = ViewMode.all;
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
  String? _selectedProjectName;
  String? get selectedProjectName => _selectedProjectName;

  bool get hasProjectSelected => _selectedProjectId != null;

  AnalyticsProvider() {
    _initializeData();
  }

  void _initializeData() {
    print('🚀 Initializing AnalyticsProvider...');
    _generateDummyData();
    //_loadEmployeeProjects();
    print('✅ Initialization complete');
  }

  void _generateDummyData() {
    print('🔄 Generating dummy data...');
    _dailyData = {
      'employeeId': 'emp123',
      'projectId': null,
      'projectName': null,
      'date': _selectedDate,
      'checkIn': '09:15 \nAM',
      'checkOut': '06:30 \nPM',
      'totalHours': 8.25,
      'requiredHours': 9.0,
      'shortfall': 0.75,
      'hasShortfall': true,
    };

    _weeklyData = {
      'employeeId': 'emp123',
      'projectId': null,
      'projectName': null,
      'totalDays': 7,
      'present': 5,
      'leave': 1,
      'absent': 1,
      'onTime': 4,
      'late': 2,
    };

    _monthlyData = {
      'employeeId': 'emp123',
      'projectId': null,
      'projectName': null,
      'totalDays': 30,
      'present': 22,
      'leave': 3,
      'absent': 5,
      'onTime': 18,
      'late': 7,
    };

    _quarterlyData = {
      'employeeId': 'emp123',
      'projectId': null,
      'projectName': null,
      'totalDays': 90,
      'present': 70,
      'leave': 10,
      'absent': 10,
      'onTime': 60,
      'late': 20,
    };
    print('✅ Dummy data generated');
  }

  void setViewMode(ViewMode mode) {
    print('🔄 Setting view mode: $mode');
    _viewMode = mode;
    notifyListeners();
  }

  // Analytics Mode Methods
  void setMode(AnalyticsMode mode) {
    print('🔄 Setting analytics mode: $mode');
    _mode = mode;
    notifyListeners();
  }

  // Date Selection Methods
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _generateDummyData();
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

  void setProjectId(String? projectId, {String? projectName}) {
    print('🔄 Setting project: $projectId - $projectName');
    _selectedProjectId = projectId;

    // FIX: do NOT overwrite if name is null
    if (projectName != null && projectName.isNotEmpty) {
      _selectedProjectName = projectName;
    }

    if (projectName == null) {
      print("⚠️ WARNING: setProjectId called with NULL projectName");
    }

    _generateDummyDataForProject(projectId);
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
    final weekStart = targetDate.subtract(
      Duration(days: targetDate.weekday - 1),
    );
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

    // Safe month calculation
    int monthIndex = targetMonth.month - 1;
    if (monthIndex < 0) monthIndex = 11; // December
    if (monthIndex >= DateTimeUtils.months.length) monthIndex = 0; // January

    String monthName = DateTimeUtils.months[monthIndex];

    if (index == 0) {
      return 'Current Month\n($monthName ${targetMonth.year})';
    } else {
      return '$monthName ${targetMonth.year}';
    }
  }

  String _getQuarterLabel(int index) {
    final now = DateTime.now();
    int year = now.year;

    // Identify Current Quarter
    int currentQuarter;
    if (now.month >= 10) {
      currentQuarter = 4;
    } else if (now.month >= 7) {
      currentQuarter = 3;
    } else if (now.month >= 4) {
      currentQuarter = 2;
    } else {
      currentQuarter = 1;
    }

    // Calculate quarter and year
    int quarter = currentQuarter;
    int qYear = year;

    if (index == 1) {
      // previous quarter
      quarter = currentQuarter - 1;

      if (quarter == 0) {
        quarter = 4;
        qYear = year - 1;
      }
    }

    if (index == 0) {
      return "Current Quarter\n(Q$quarter $qYear)";
    } else {
      return "Q$quarter $qYear";
    }
  }

  void clearProjectSelection() {
    _selectedProjectId = null;
    _selectedProjectName = null;
    _generateDummyData();
    notifyListeners();
  }

  void _generateDummyDataForProject(String? projectId) {
    print('🔄 Generating dummy data for project: $projectId');
    _dailyData = {
      'employeeId': 'emp123',
      'projectId': projectId,
      'projectName': _selectedProjectName,
      'date': _selectedDate,
      'checkIn': '08:45 \nAM',
      'checkOut': '05:30 \nPM',
      'totalHours': 8.75,
      'requiredHours': 9.0,
      'shortfall': 0.25,
      'hasShortfall': true,
    };

    _weeklyData = {
      'employeeId': 'emp123',
      'projectId': projectId,
      'projectName': _selectedProjectName,
      'totalDays': 7,
      'present': 6,
      'leave': 0,
      'absent': 1,
      'onTime': 5,
      'late': 1,
    };

    _monthlyData = {
      'employeeId': 'emp123',
      'projectId': projectId,
      'projectName': _selectedProjectName,
      'totalDays': 30,
      'present': 25,
      'leave': 2,
      'absent': 3,
      'onTime': 20,
      'late': 5,
    };

    _quarterlyData = {
      'employeeId': 'emp123',
      'projectId': projectId,
      'projectName': _selectedProjectName,
      'totalDays': 90,
      'present': 75,
      'leave': 8,
      'absent': 7,
      'onTime': 65,
      'late': 10,
    };
    print('✅ Project-specific dummy data generated');
  }

  String _getMonthName(int month) {
    int monthIndex = month - 1;
    if (monthIndex < 0 || monthIndex >= DateTimeUtils.months.length) {
      return 'Jan'; // Fallback
    }
    return DateTimeUtils.months[monthIndex];
  }

  // Refresh data method
  Future<void> refreshData() async {
    setLoading(true);
    await Future.delayed(Duration(seconds: 1));
    _generateDummyData();
    // _loadEmployeeProjects();
    setLoading(false);
  }
}
