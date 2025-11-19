import 'package:AttendanceApp/manager/models/attendancemodels/attendance_analytics_model.dart';
import 'package:AttendanceApp/manager/services/attendanceservices/attendance_analytics_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/team_model.dart';

class AttendanceAnalyticsViewModel with ChangeNotifier {
  final AttendanceAnalyticsService _service = AttendanceAnalyticsService();

  bool _isLoading = false;
  bool _showIndividualGraphs = false;
  String _selectedPeriod = 'daily';
  DateTime _selectedDate = DateTime.now();
  AttendanceAnalytics? _analytics;
  List<TeamMember> _teamMembers = [];

  bool get isLoading => _isLoading;
  bool get showIndividualGraphs => _showIndividualGraphs;
  String get selectedPeriod => _selectedPeriod;
  DateTime get selectedDate => _selectedDate;
  AttendanceAnalytics? get analytics => _analytics;
  List<TeamMember> get teamMembers => _teamMembers;

  final List<String> availablePeriods = [
    'daily',
    'weekly',
    'monthly',
    'quarterly',
  ];

  Future<void> initializeAnalytics(List<TeamMember> teamMembers) async {
    if (teamMembers.isEmpty) {
      _handleQuantumError('MATRIX: No team members detected');
      return;
    }

    _setQuantumLoading(true);
    _teamMembers = teamMembers;

    try {
      _analytics = _service.generateAnalytics(
        teamMembers,
        _selectedPeriod,
        selectedDate: _selectedDate,
      );
      _logQuantumSuccess(
        'INITIALIZED: Neural network activated for ${teamMembers.length} team nodes',
      );
    } catch (e) {
      _handleQuantumError('FAILURE: Matrix initialization failed: $e');
    } finally {
      _setQuantumLoading(false);
    }
  }

  void toggleGraphView() {
    _showIndividualGraphs = !_showIndividualGraphs;
    _logQuantumAction(
      'VIEW MODE: ${_showIndividualGraphs ? 'INDIVIDUAL NODES' : 'MERGED MATRIX'} activated',
    );
    notifyListeners();
  }

  void changePeriod(String period, {DateTime? selectedDate}) {
    if (_selectedPeriod == period || !availablePeriods.contains(period)) return;

    _selectedPeriod = period;
    if (selectedDate != null) {
      _selectedDate = selectedDate;
    }

    _logQuantumAction(
      'TIME PERIOD: ${getQuantumPeriodDisplayName(period)} | DATE: ${_formatDateForQuantumLog(_selectedDate)}',
    );

    if (_teamMembers.isNotEmpty) {
      _refreshQuantumAnalytics();
    }
    notifyListeners();
  }

  Future<void> refreshAnalytics() async {
    if (_teamMembers.isEmpty) {
      _handleQuantumError('TODAY: No active nodes found');
      return;
    }

    _logQuantumAction('REFRESH: Recalibrating neural matrix');
    await _refreshQuantumAnalytics();
  }

  List<Insight> getInsights() {
    if (_analytics == null) return _getQuantumDefaultInsights();
    return _service.generateInsights(_analytics!.statistics);
  }

  List<PerformanceMetric> getPerformanceMetrics() {
    return _service.getPerformanceMetrics();
  }

  Color getPerformanceColor(double rate) {
    if (rate >= 90) return Colors.green.shade400; // Green
    if (rate >= 75) return Colors.orange.shade400; // Orange
    if (rate >= 60) return Colors.blue.shade400; // Blue
    return Colors.red.shade400; // Red
  }

  Color getQuantumMetricColor(String metricType) {
    switch (metricType) {
      case 'attendance':
        return Colors.green.shade400;
      case 'hours':
        return Colors.cyan.shade400;
      case 'productivity':
        return Colors.orange.shade400;
      case 'efficiency':
        return Colors.purple.shade400;
      default:
        return Colors.blue.shade400;
    }
  }

  String getPeriodDisplayName(String period) {
    const periodNames = {
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'quarterly': 'Quarterly',
    };
    return periodNames[period] ?? 'Daily';
  }

  String getQuantumPeriodDisplayName(String period) {
    const periodNames = {
      'daily': 'DAY',
      'weekly': 'WEEK',
      'monthly': 'MONTH',
      'quarterly': 'QUARTER',
    };
    return periodNames[period] ?? 'DAY';
  }

  String getGraphSubtitle() {
    final dateFormat = DateFormat('dd MMM yyyy');
    final monthFormat = DateFormat('MMM yyyy');

    switch (_selectedPeriod) {
      case 'daily':
        return 'DAILY: ${dateFormat.format(_selectedDate)}';
      case 'weekly':
        final weekEnd = _selectedDate.add(const Duration(days: 6));
        return 'WEEK ${_getWeekNumber(_selectedDate)} MATRIX: ${dateFormat.format(_selectedDate)} - ${dateFormat.format(weekEnd)}';
      case 'monthly':
        return 'MONTHLY: ${monthFormat.format(_selectedDate)}';
      case 'quarterly':
        final quarter = ((_selectedDate.month - 1) ~/ 3) + 1;
        return 'QUARTER $quarter ${_selectedDate.year} ANALYSIS';
      default:
        return 'ATTENDANCE MATRIX';
    }
  }

  String getQuantumHeaderTitle() {
    switch (_selectedPeriod) {
      case 'daily':
        return 'DAILY MATRIX';
      case 'weekly':
        return 'WEEKLY NEURAL NETWORK';
      case 'monthly':
        return 'MONTHLY PERFORMANCE GRID';
      case 'quarterly':
        return 'QUARTERLY ANALYTICS CORE';
      default:
        return 'ATTENDANCE SYSTEM';
    }
  }

  Map<String, dynamic> get statistics {
    return _analytics?.statistics ?? _getQuantumDefaultStatistics();
  }

  List<String> getGraphLabels() {
    switch (_selectedPeriod) {
      case 'daily':
        return ['9AM', '11AM', '1PM', '3PM', '5PM', '7PM'];
      case 'weekly':
        return ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
      case 'monthly':
        final daysInMonth = DateTime(
          _selectedDate.year,
          _selectedDate.month + 1,
          0,
        ).day;
        return ['W1', 'W2', 'W3', 'W4', if (daysInMonth > 28) 'W5'];
      case 'quarterly':
        final quarter = ((_selectedDate.month - 1) ~/ 3) + 1;
        return [
          'M${(quarter - 1) * 3 + 1}',
          'M${(quarter - 1) * 3 + 2}',
          'M${(quarter - 1) * 3 + 3}',
        ];
      default:
        return ['9AM', '11AM', '1PM', '3PM', '5PM', '7PM'];
    }
  }

  List<String> getQuantumGraphLabels() {
    switch (_selectedPeriod) {
      case 'daily':
        return ['9', '11', '13', '15', '17', '19'];
      case 'weekly':
        return ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
      case 'monthly':
        return ['WEEK 1', 'WEEK 2', 'WEEK 3', 'WEEK 4', 'WEEK 5'];
      case 'quarterly':
        return ['MONTH 1', 'MONTH 2', 'MONTH 3'];
      default:
        return ['NODE 1', 'NODE 2', 'NODE 3', 'NODE 4', 'NODE 5', 'NODE 6'];
    }
  }

  // Performance Analysis
  String getQuantumPerformanceLevel(double rate) {
    if (rate >= 90) return 'OPTIMAL';
    if (rate >= 75) return 'NEURAL STABLE';
    if (rate >= 60) return 'MATRIX NORMAL';
    return 'SYSTEM CRITICAL';
  }

  Color getQuantumPerformanceGlow(double rate) {
    if (rate >= 90) return Colors.green.shade400.withOpacity(0.6);
    if (rate >= 75) return Colors.orange.shade400.withOpacity(0.6);
    if (rate >= 60) return Colors.blue.shade400.withOpacity(0.6);
    return Colors.red.shade400.withOpacity(0.6);
  }

  // Helper methods for date calculations
  int _getWeekNumber(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final daysDiff = date.difference(firstDay).inDays;
    return ((daysDiff + firstDay.weekday) / 7).ceil();
  }

  DateTime getFirstDayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  DateTime getFirstDayOfQuarter(DateTime date) {
    final quarter = ((date.month - 1) ~/ 3) + 1;
    final quarterMonth = (quarter - 1) * 3 + 1;
    return DateTime(date.year, quarterMonth, 1);
  }

  String _formatDateForQuantumLog(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _refreshQuantumAnalytics() async {
    _setQuantumLoading(true);

    try {
      _analytics = _service.generateAnalytics(
        _teamMembers,
        _selectedPeriod,
        selectedDate: _selectedDate,
      );
      _logQuantumSuccess('MATRIX: Data stream recalibrated successfully');
    } catch (e) {
      _handleQuantumError('FAILURE: Matrix refresh failed: $e');
    } finally {
      _setQuantumLoading(false);
    }
  }

  void _setQuantumLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleQuantumError(String message) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
    }
  }

  void _logQuantumSuccess(String message) {
    if (kDebugMode) {
      print('✅ SUCCESS: $message');
    }
  }

  void _logQuantumAction(String message) {
    if (kDebugMode) {
      print('🔧 ACTION: $message');
    }
  }

  List<Insight> _getQuantumDefaultInsights() {
    return [
      Insight(text: 'SYSTEM: Initializing neural network...', type: 'info'),
      Insight(
        text: 'MATRIX STATUS: Awaiting team member data stream',
        type: 'warning',
      ),
    ];
  }

  Map<String, dynamic> _getQuantumDefaultStatistics() {
    return {
      'attendanceRate': 0,
      'avgHours': '0.0',
      'productivity': 0,
      'quantumScore': 0,
      'neuralEfficiency': 0,
    };
  }

  // Data Stream Methods
  List<Map<String, dynamic>> getQuantumTeamPerformance() {
    if (_analytics?.individualData == null) return [];

    return _teamMembers.map((member) {
      final memberData = _analytics!.individualData[member.email] ?? {};
      final attendanceRate = memberData['attendanceRate'] ?? 0.0;

      return {
        'member': member,
        'attendanceRate': attendanceRate,
        'quantumLevel': getQuantumPerformanceLevel(attendanceRate),
        'performanceColor': getPerformanceColor(attendanceRate),
        'glowColor': getQuantumPerformanceGlow(attendanceRate),
        'avgHours': memberData['avgHours'] ?? 0.0,
        'productivity': memberData['productivity'] ?? 0.0,
      };
    }).toList();
  }

  Map<String, dynamic> getQuantumSystemStatus() {
    final stats = statistics;
    final attendanceRate = stats['attendanceRate'] ?? 0;

    return {
      'systemStatus': attendanceRate >= 80
          ? 'OPTIMAL'
          : attendanceRate >= 60
          ? 'STABLE'
          : 'CRITICAL',
      'quantumScore': (attendanceRate * 1.2).clamp(0, 100).toInt(),
      'neuralEfficiency':
          ((stats['productivity'] ?? 0) * 0.8 + attendanceRate * 0.2).toInt(),
      'matrixIntegrity': ((stats['avgHours'] ?? 0) * 10).clamp(0, 100).toInt(),
    };
  }

  // New methods for period-based data integration
  Map<String, dynamic> getPeriodAttendanceData(String employeeEmail) {
    final individualData = _analytics?.individualData ?? {};
    final memberData = individualData[employeeEmail] ?? {};

    final period = _selectedPeriod;
    final selectedDate = _selectedDate;

    // Get base analytics data
    final attendanceRate = memberData['attendanceRate'] ?? 0.0;
    final avgHours = memberData['avgHours'] ?? 0.0;
    final productivity = memberData['productivity'] ?? 0.0;

    // Calculate period-specific attendance counts
    final periodData = _calculatePeriodAttendance(period, selectedDate);

    return {
      'present': periodData['present'] ?? 0,
      'absent': periodData['absent'] ?? 0,
      'leave': periodData['leave'] ?? 0,
      'late': periodData['late'] ?? 0,
      'checkin': _getPeriodCheckinTime(period),
      'checkout': _getPeriodCheckoutTime(period),
      'attendanceRate': attendanceRate,
      'period': getPeriodDisplayName(period),
      'periodDates': _getPeriodDateRange(period, selectedDate),
    };
  }

  Map<String, int> _calculatePeriodAttendance(
    String period,
    DateTime selectedDate,
  ) {
    final now = DateTime.now();

    switch (period) {
      case 'daily':
        return {
          'present': 1,
          'absent': 0,
          'leave': 0,
          'late':
              selectedDate.weekday == DateTime.saturday ||
                  selectedDate.weekday == DateTime.sunday
              ? 0
              : 1,
        };

      case 'weekly':
        final weekDays = _getWeekDays(selectedDate);
        final presentDays = weekDays
            .where(
              (day) =>
                  day.weekday != DateTime.saturday &&
                  day.weekday != DateTime.sunday,
            )
            .length;
        return {'present': presentDays - 1, 'absent': 1, 'leave': 0, 'late': 1};

      case 'monthly':
        final workingDays = _getWorkingDaysInMonth(
          selectedDate.month,
          selectedDate.year,
        );
        return {'present': workingDays - 3, 'absent': 2, 'leave': 1, 'late': 1};

      case 'quarterly':
        final quarter = ((selectedDate.month - 1) ~/ 3) + 1;
        final workingDays = _getWorkingDaysInQuarter(
          quarter,
          selectedDate.year,
        );
        return {'present': workingDays - 8, 'absent': 5, 'leave': 3, 'late': 2};

      default:
        return {'present': 20, 'absent': 2, 'leave': 3, 'late': 1};
    }
  }

  String _getPeriodCheckinTime(String period) {
    switch (period) {
      case 'daily':
        return '09:00 AM';
      case 'weekly':
        return 'Avg: 09:15 AM';
      case 'monthly':
        return 'Avg: 09:10 AM';
      case 'quarterly':
        return 'Avg: 09:05 AM';
      default:
        return '09:00 AM';
    }
  }

  String _getPeriodCheckoutTime(String period) {
    switch (period) {
      case 'daily':
        return '06:00 PM';
      case 'weekly':
        return 'Avg: 06:15 PM';
      case 'monthly':
        return 'Avg: 06:10 PM';
      case 'quarterly':
        return 'Avg: 06:05 PM';
      default:
        return '06:00 PM';
    }
  }

  String _getPeriodDateRange(String period, DateTime selectedDate) {
    final dateFormat = DateFormat('dd MMM yyyy');

    switch (period) {
      case 'daily':
        return dateFormat.format(selectedDate);
      case 'weekly':
        final weekStart = getFirstDayOfWeek(selectedDate);
        final weekEnd = weekStart.add(const Duration(days: 6));
        return '${dateFormat.format(weekStart)} - ${dateFormat.format(weekEnd)}';
      case 'monthly':
        return DateFormat('MMMM yyyy').format(selectedDate);
      case 'quarterly':
        final quarter = ((selectedDate.month - 1) ~/ 3) + 1;
        return 'Q$quarter ${selectedDate.year}';
      default:
        return getPeriodDisplayName(period);
    }
  }

  List<DateTime> _getWeekDays(DateTime weekStart) {
    final days = <DateTime>[];
    for (int i = 0; i < 7; i++) {
      days.add(weekStart.add(Duration(days: i)));
    }
    return days;
  }

  int _getWorkingDaysInMonth(int month, int year) {
    int workingDays = 0;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      if (date.weekday != DateTime.saturday &&
          date.weekday != DateTime.sunday) {
        workingDays++;
      }
    }

    return workingDays;
  }

  int _getWorkingDaysInQuarter(int quarter, int year) {
    int workingDays = 0;
    final startMonth = (quarter - 1) * 3 + 1;

    for (int month = startMonth; month < startMonth + 3; month++) {
      workingDays += _getWorkingDaysInMonth(month, year);
    }

    return workingDays;
  }

  // NEW IMPROVED METHODS FOR BETTER UX/UI

  // 1. Theme-aware color system
  Color getThemeAwareColor(BuildContext context, String colorType) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (colorType) {
      case 'primary':
        return isDark ? Colors.blue.shade300 : Colors.blue.shade700;
      case 'secondary':
        return isDark ? Colors.green.shade300 : Colors.green.shade700;
      case 'background':
        return isDark ? Colors.grey.shade900 : Colors.grey.shade50;
      case 'surface':
        return isDark ? Colors.grey.shade800 : Colors.white;
      case 'text':
        return isDark ? Colors.white : Colors.black87;
      case 'textSecondary':
        return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
      default:
        return isDark ? Colors.blue.shade300 : Colors.blue.shade700;
    }
  }

  // 2. Simplified performance indicators
  Map<String, dynamic> getSimplifiedPerformance(double rate) {
    if (rate >= 90) {
      return {
        'level': 'Excellent',
        'color': Colors.green,
        'icon': Icons.verified,
        'description': 'Outstanding performance',
      };
    } else if (rate >= 75) {
      return {
        'level': 'Good',
        'color': Colors.blue,
        'icon': Icons.check_circle,
        'description': 'Solid performance',
      };
    } else if (rate >= 60) {
      return {
        'level': 'Average',
        'color': Colors.orange,
        'icon': Icons.info,
        'description': 'Needs improvement',
      };
    } else {
      return {
        'level': 'Poor',
        'color': Colors.red,
        'icon': Icons.warning,
        'description': 'Requires attention',
      };
    }
  }

  // 3. User-friendly period data
  Map<String, dynamic> getUserFriendlyPeriodData() {
    final period = _selectedPeriod;
    final date = _selectedDate;

    switch (period) {
      case 'daily':
        return {
          'title': 'Today',
          'subtitle': DateFormat('EEEE, MMMM d').format(date),
          'icon': Icons.today,
          'totalDays': 1,
        };
      case 'weekly':
        final weekStart = getFirstDayOfWeek(date);
        final weekEnd = weekStart.add(const Duration(days: 6));
        return {
          'title': 'This Week',
          'subtitle':
              '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d').format(weekEnd)}',
          'icon': Icons.calendar_view_week,
          'totalDays': 7,
        };
      case 'monthly':
        return {
          'title': 'This Month',
          'subtitle': DateFormat('MMMM yyyy').format(date),
          'icon': Icons.calendar_month,
          'totalDays': _getWorkingDaysInMonth(date.month, date.year),
        };
      case 'quarterly':
        final quarter = ((date.month - 1) ~/ 3) + 1;
        return {
          'title': 'Quarter $quarter',
          'subtitle': '${date.year}',
          'icon': Icons.analytics,
          'totalDays': _getWorkingDaysInQuarter(quarter, date.year),
        };
      default:
        return {
          'title': 'Overview',
          'subtitle': 'Performance Summary',
          'icon': Icons.assessment,
          'totalDays': 0,
        };
    }
  }

  // 4. Enhanced insights with actionable items
  List<Map<String, dynamic>> getEnhancedInsights() {
    final stats = statistics;
    final attendanceRate = stats['attendanceRate'] ?? 0;
    final avgHours = double.tryParse(stats['avgHours']?.toString() ?? '0') ?? 0;

    final insights = <Map<String, dynamic>>[];

    // Attendance insights
    if (attendanceRate >= 90) {
      insights.add({
        'type': 'positive',
        'title': 'Excellent Attendance',
        'message': 'Team attendance is consistently high',
        'action': 'Maintain this momentum',
        'icon': Icons.emoji_events,
      });
    } else if (attendanceRate < 70) {
      insights.add({
        'type': 'warning',
        'title': 'Attendance Needs Improvement',
        'message': 'Consider implementing attendance reminders',
        'action': 'Review attendance policies',
        'icon': Icons.notifications_active,
      });
    }

    // Hours insights
    if (avgHours > 9) {
      insights.add({
        'type': 'info',
        'title': 'High Average Hours',
        'message': 'Team is putting in extra effort',
        'action': 'Monitor work-life balance',
        'icon': Icons.access_time,
      });
    } else if (avgHours < 7) {
      insights.add({
        'type': 'warning',
        'title': 'Low Average Hours',
        'message': 'Consider optimizing work schedules',
        'action': 'Review workload distribution',
        'icon': Icons.timelapse,
      });
    }

    // Productivity insights
    final productivity = stats['productivity'] ?? 0;
    if (productivity >= 80) {
      insights.add({
        'type': 'positive',
        'title': 'High Productivity',
        'message': 'Team is performing efficiently',
        'action': 'Continue current strategies',
        'icon': Icons.trending_up,
      });
    }

    return insights;
  }

  // 5. Quick actions for better UX
  List<Map<String, dynamic>> getQuickActions() {
    return [
      {
        'title': 'Refresh Data',
        'icon': Icons.refresh,
        'action': refreshAnalytics,
        'color': Colors.blue,
      },
      {
        'title': 'Toggle View',
        'icon': _showIndividualGraphs ? Icons.pie_chart : Icons.bar_chart,
        'action': toggleGraphView,
        'color': Colors.green,
      },
      {
        'title': 'Today',
        'icon': Icons.today,
        'action': () => changePeriod('daily', selectedDate: DateTime.now()),
        'color': Colors.orange,
      },
    ];
  }

  // 6. Professional summary data
  Map<String, dynamic> getProfessionalSummary() {
    final stats = statistics;
    final periodData = getUserFriendlyPeriodData();

    return {
      'period': periodData['title'],
      'timeframe': periodData['subtitle'],
      'attendanceRate': '${(stats['attendanceRate'] ?? 0).toStringAsFixed(1)}%',
      'averageHours': stats['avgHours']?.toString() ?? '0.0',
      'productivity': '${(stats['productivity'] ?? 0).toStringAsFixed(1)}%',
      'totalTeamMembers': _teamMembers.length,
      'activeMembers': _teamMembers.where((member) {
        final memberData = _analytics?.individualData[member.email] ?? {};
        return (memberData['attendanceRate'] ?? 0) >= 60;
      }).length,
    };
  }

  @override
  void dispose() {
    _teamMembers.clear();
    _analytics = null;
    _logQuantumAction('SYSTEM: Shutting down neural matrix');
    super.dispose();
  }
}

// import 'package:flutter/foundation.dart';
// import 'package:attendanceapp/models/attendancemodels/attendance_analytics_model.dart';
// import 'package:attendanceapp/models/team_model.dart';
// import 'package:attendanceapp/services/attendanceservices/attendance_analytics_service.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class AttendanceAnalyticsViewModel with ChangeNotifier {
//   final AttendanceAnalyticsService _service = AttendanceAnalyticsService();

//   bool _isLoading = false;
//   bool _showIndividualGraphs = false;
//   String _selectedPeriod = 'daily';
//   DateTime _selectedDate = DateTime.now();
//   AttendanceAnalytics? _analytics;
//   List<TeamMember> _teamMembers = [];

//   bool get isLoading => _isLoading;
//   bool get showIndividualGraphs => _showIndividualGraphs;
//   String get selectedPeriod => _selectedPeriod;
//   DateTime get selectedDate => _selectedDate;
//   AttendanceAnalytics? get analytics => _analytics;
//   List<TeamMember> get teamMembers => _teamMembers;

//   final List<String> availablePeriods = [
//     'daily',
//     'weekly',
//     'monthly',
//     'quarterly',
//   ];

//   Future<void> initializeAnalytics(List<TeamMember> teamMembers) async {
//     if (teamMembers.isEmpty) {
//       _handleQuantumError('MATRIX: No team members detected');
//       return;
//     }

//     _setQuantumLoading(true);
//     _teamMembers = teamMembers;

//     try {
//       _analytics = _service.generateAnalytics(
//         teamMembers,
//         _selectedPeriod,
//         selectedDate: _selectedDate,
//       );
//       _logQuantumSuccess(
//         'INITIALIZED: Neural network activated for ${teamMembers.length} team nodes',
//       );
//     } catch (e) {
//       _handleQuantumError('FAILURE: Matrix initialization failed: $e');
//     } finally {
//       _setQuantumLoading(false);
//     }
//   }

//   void toggleGraphView() {
//     _showIndividualGraphs = !_showIndividualGraphs;
//     _logQuantumAction(
//       'VIEW MODE: ${_showIndividualGraphs ? 'INDIVIDUAL NODES' : 'MERGED MATRIX'} activated',
//     );
//     notifyListeners();
//   }

//   void changePeriod(String period, {DateTime? selectedDate}) {
//     if (_selectedPeriod == period || !availablePeriods.contains(period)) return;

//     _selectedPeriod = period;
//     if (selectedDate != null) {
//       _selectedDate = selectedDate;
//     }

//     _logQuantumAction(
//       'TIME PERIOD: ${getQuantumPeriodDisplayName(period)} | DATE: ${_formatDateForQuantumLog(_selectedDate)}',
//     );

//     if (_teamMembers.isNotEmpty) {
//       _refreshQuantumAnalytics();
//     }
//     notifyListeners();
//   }

//   Future<void> refreshAnalytics() async {
//     if (_teamMembers.isEmpty) {
//       _handleQuantumError('TODAY: No active nodes found');
//       return;
//     }

//     _logQuantumAction('REFRESH: Recalibrating neural matrix');
//     await _refreshQuantumAnalytics();
//   }

//   List<Insight> getInsights() {
//     if (_analytics == null) return _getQuantumDefaultInsights();
//     return _service.generateInsights(_analytics!.statistics);
//   }

//   List<PerformanceMetric> getPerformanceMetrics() {
//     return _service.getPerformanceMetrics();
//   }

//   Color getPerformanceColor(double rate) {
//     if (rate >= 90) return Colors.green.shade400; // Green
//     if (rate >= 75) return Colors.orange.shade400; // Orange
//     if (rate >= 60) return Colors.blue.shade400; // Blue
//     return Colors.red.shade400; // Red
//   }

//   Color getQuantumMetricColor(String metricType) {
//     switch (metricType) {
//       case 'attendance':
//         return Colors.green.shade400;
//       case 'hours':
//         return Colors.cyan.shade400;
//       case 'productivity':
//         return Colors.orange.shade400;
//       case 'efficiency':
//         return Colors.purple.shade400;
//       default:
//         return Colors.blue.shade400;
//     }
//   }

//   String getPeriodDisplayName(String period) {
//     const periodNames = {
//       'daily': 'Daily',
//       'weekly': 'Weekly',
//       'monthly': 'Monthly',
//       'quarterly': 'Quarterly',
//     };
//     return periodNames[period] ?? 'Daily';
//   }

//   String getQuantumPeriodDisplayName(String period) {
//     const periodNames = {
//       'daily': 'DAY',
//       'weekly': 'WEEK',
//       'monthly': 'MONTH',
//       'quarterly': 'QUARTER',
//     };
//     return periodNames[period] ?? 'DAY';
//   }

//   String getGraphSubtitle() {
//     final dateFormat = DateFormat('dd MMM yyyy');
//     final monthFormat = DateFormat('MMM yyyy');

//     switch (_selectedPeriod) {
//       case 'daily':
//         return 'DAILY: ${dateFormat.format(_selectedDate)}';
//       case 'weekly':
//         final weekEnd = _selectedDate.add(const Duration(days: 6));
//         return 'WEEK ${_getWeekNumber(_selectedDate)} MATRIX: ${dateFormat.format(_selectedDate)} - ${dateFormat.format(weekEnd)}';
//       case 'monthly':
//         return 'MONTHLY: ${monthFormat.format(_selectedDate)}';
//       case 'quarterly':
//         final quarter = ((_selectedDate.month - 1) ~/ 3) + 1;
//         return 'QUARTER $quarter ${_selectedDate.year} ANALYSIS';
//       default:
//         return 'ATTENDANCE MATRIX';
//     }
//   }

//   String getQuantumHeaderTitle() {
//     switch (_selectedPeriod) {
//       case 'daily':
//         return 'DAILY MATRIX';
//       case 'weekly':
//         return 'WEEKLY NEURAL NETWORK';
//       case 'monthly':
//         return 'MONTHLY PERFORMANCE GRID';
//       case 'quarterly':
//         return 'QUARTERLY ANALYTICS CORE';
//       default:
//         return 'ATTENDANCE SYSTEM';
//     }
//   }

//   Map<String, dynamic> get statistics {
//     return _analytics?.statistics ?? _getQuantumDefaultStatistics();
//   }

//   List<String> getGraphLabels() {
//     switch (_selectedPeriod) {
//       case 'daily':
//         return ['9AM', '11AM', '1PM', '3PM', '5PM', '7PM'];
//       case 'weekly':
//         return ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
//       case 'monthly':
//         final daysInMonth = DateTime(
//           _selectedDate.year,
//           _selectedDate.month + 1,
//           0,
//         ).day;
//         return ['W1', 'W2', 'W3', 'W4', if (daysInMonth > 28) 'W5'];
//       case 'quarterly':
//         final quarter = ((_selectedDate.month - 1) ~/ 3) + 1;
//         return [
//           'M${(quarter - 1) * 3 + 1}',
//           'M${(quarter - 1) * 3 + 2}',
//           'M${(quarter - 1) * 3 + 3}',
//         ];
//       default:
//         return ['9AM', '11AM', '1PM', '3PM', '5PM', '7PM'];
//     }
//   }

//   List<String> getQuantumGraphLabels() {
//     switch (_selectedPeriod) {
//       case 'daily':
//         return ['9', '11', '13', '15', '17', '19'];
//       case 'weekly':
//         return ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
//       case 'monthly':
//         return ['WEEK 1', 'WEEK 2', 'WEEK 3', 'WEEK 4', 'WEEK 5'];
//       case 'quarterly':
//         return ['MONTH 1', 'MONTH 2', 'MONTH 3'];
//       default:
//         return ['NODE 1', 'NODE 2', 'NODE 3', 'NODE 4', 'NODE 5', 'NODE 6'];
//     }
//   }

//   // Performance Analysis
//   String getQuantumPerformanceLevel(double rate) {
//     if (rate >= 90) return 'OPTIMAL';
//     if (rate >= 75) return 'NEURAL STABLE';
//     if (rate >= 60) return 'MATRIX NORMAL';
//     return 'SYSTEM CRITICAL';
//   }

//   Color getQuantumPerformanceGlow(double rate) {
//     if (rate >= 90) return Colors.green.shade400.withOpacity(0.6);
//     if (rate >= 75) return Colors.orange.shade400.withOpacity(0.6);
//     if (rate >= 60) return Colors.blue.shade400.withOpacity(0.6);
//     return Colors.red.shade400.withOpacity(0.6);
//   }

//   // Helper methods for date calculations
//   int _getWeekNumber(DateTime date) {
//     final firstDay = DateTime(date.year, 1, 1);
//     final daysDiff = date.difference(firstDay).inDays;
//     return ((daysDiff + firstDay.weekday) / 7).ceil();
//   }

//   DateTime getFirstDayOfWeek(DateTime date) {
//     return date.subtract(Duration(days: date.weekday - 1));
//   }

//   DateTime getFirstDayOfMonth(DateTime date) {
//     return DateTime(date.year, date.month, 1);
//   }

//   DateTime getFirstDayOfQuarter(DateTime date) {
//     final quarter = ((date.month - 1) ~/ 3) + 1;
//     final quarterMonth = (quarter - 1) * 3 + 1;
//     return DateTime(date.year, quarterMonth, 1);
//   }

//   String _formatDateForQuantumLog(DateTime date) {
//     return DateFormat('dd/MM/yyyy').format(date);
//   }

//   Future<void> _refreshQuantumAnalytics() async {
//     _setQuantumLoading(true);

//     try {
//       _analytics = _service.generateAnalytics(
//         _teamMembers,
//         _selectedPeriod,
//         selectedDate: _selectedDate,
//       );
//       _logQuantumSuccess('MATRIX: Data stream recalibrated successfully');
//     } catch (e) {
//       _handleQuantumError('FAILURE: Matrix refresh failed: $e');
//     } finally {
//       _setQuantumLoading(false);
//     }
//   }

//   void _setQuantumLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }

//   void _handleQuantumError(String message) {
//     if (kDebugMode) {
//       print('❌ ERROR: $message');
//     }
//   }

//   void _logQuantumSuccess(String message) {
//     if (kDebugMode) {
//       print('✅ SUCCESS: $message');
//     }
//   }

//   void _logQuantumAction(String message) {
//     if (kDebugMode) {
//       print('🔧 ACTION: $message');
//     }
//   }

//   List<Insight> _getQuantumDefaultInsights() {
//     return [
//       Insight(text: 'SYSTEM: Initializing neural network...', type: 'info'),
//       Insight(
//         text: 'MATRIX STATUS: Awaiting team member data stream',
//         type: 'warning',
//       ),
//     ];
//   }

//   Map<String, dynamic> _getQuantumDefaultStatistics() {
//     return {
//       'attendanceRate': 0,
//       'avgHours': '0.0',
//       'productivity': 0,
//       'quantumScore': 0,
//       'neuralEfficiency': 0,
//     };
//   }

//   // Data Stream Methods
//   List<Map<String, dynamic>> getQuantumTeamPerformance() {
//     if (_analytics?.individualData == null) return [];

//     return _teamMembers.map((member) {
//       final memberData = _analytics!.individualData[member.email] ?? {};
//       final attendanceRate = memberData['attendanceRate'] ?? 0.0;

//       return {
//         'member': member,
//         'attendanceRate': attendanceRate,
//         'quantumLevel': getQuantumPerformanceLevel(attendanceRate),
//         'performanceColor': getPerformanceColor(attendanceRate),
//         'glowColor': getQuantumPerformanceGlow(attendanceRate),
//         'avgHours': memberData['avgHours'] ?? 0.0,
//         'productivity': memberData['productivity'] ?? 0.0,
//       };
//     }).toList();
//   }

//   Map<String, dynamic> getQuantumSystemStatus() {
//     final stats = statistics;
//     final attendanceRate = stats['attendanceRate'] ?? 0;

//     return {
//       'systemStatus': attendanceRate >= 80
//           ? 'OPTIMAL'
//           : attendanceRate >= 60
//           ? 'STABLE'
//           : 'CRITICAL',
//       'quantumScore': (attendanceRate * 1.2).clamp(0, 100).toInt(),
//       'neuralEfficiency':
//           ((stats['productivity'] ?? 0) * 0.8 + attendanceRate * 0.2).toInt(),
//       'matrixIntegrity': ((stats['avgHours'] ?? 0) * 10).clamp(0, 100).toInt(),
//     };
//   }

//   // New methods for period-based data integration
//   Map<String, dynamic> getPeriodAttendanceData(String employeeEmail) {
//     final individualData = _analytics?.individualData ?? {};
//     final memberData = individualData[employeeEmail] ?? {};

//     final period = _selectedPeriod;
//     final selectedDate = _selectedDate;

//     // Get base analytics data
//     final attendanceRate = memberData['attendanceRate'] ?? 0.0;
//     final avgHours = memberData['avgHours'] ?? 0.0;
//     final productivity = memberData['productivity'] ?? 0.0;

//     // Calculate period-specific attendance counts
//     final periodData = _calculatePeriodAttendance(period, selectedDate);

//     return {
//       'present': periodData['present'] ?? 0,
//       'absent': periodData['absent'] ?? 0,
//       'leave': periodData['leave'] ?? 0,
//       'late': periodData['late'] ?? 0,
//       'checkin': _getPeriodCheckinTime(period),
//       'checkout': _getPeriodCheckoutTime(period),
//       'attendanceRate': attendanceRate,
//       'period': getPeriodDisplayName(period),
//       'periodDates': _getPeriodDateRange(period, selectedDate),
//     };
//   }

//   Map<String, int> _calculatePeriodAttendance(
//     String period,
//     DateTime selectedDate,
//   ) {
//     final now = DateTime.now();

//     switch (period) {
//       case 'daily':
//         return {
//           'present': 1,
//           'absent': 0,
//           'leave': 0,
//           'late':
//               selectedDate.weekday == DateTime.saturday ||
//                   selectedDate.weekday == DateTime.sunday
//               ? 0
//               : 1,
//         };

//       case 'weekly':
//         final weekDays = _getWeekDays(selectedDate);
//         final presentDays = weekDays
//             .where(
//               (day) =>
//                   day.weekday != DateTime.saturday &&
//                   day.weekday != DateTime.sunday,
//             )
//             .length;
//         return {'present': presentDays - 1, 'absent': 1, 'leave': 0, 'late': 1};

//       case 'monthly':
//         final workingDays = _getWorkingDaysInMonth(
//           selectedDate.month,
//           selectedDate.year,
//         );
//         return {'present': workingDays - 3, 'absent': 2, 'leave': 1, 'late': 1};

//       case 'quarterly':
//         final quarter = ((selectedDate.month - 1) ~/ 3) + 1;
//         final workingDays = _getWorkingDaysInQuarter(
//           quarter,
//           selectedDate.year,
//         );
//         return {'present': workingDays - 8, 'absent': 5, 'leave': 3, 'late': 2};

//       default:
//         return {'present': 20, 'absent': 2, 'leave': 3, 'late': 1};
//     }
//   }

//   String _getPeriodCheckinTime(String period) {
//     switch (period) {
//       case 'daily':
//         return '09:00 AM';
//       case 'weekly':
//         return 'Avg: 09:15 AM';
//       case 'monthly':
//         return 'Avg: 09:10 AM';
//       case 'quarterly':
//         return 'Avg: 09:05 AM';
//       default:
//         return '09:00 AM';
//     }
//   }

//   String _getPeriodCheckoutTime(String period) {
//     switch (period) {
//       case 'daily':
//         return '06:00 PM';
//       case 'weekly':
//         return 'Avg: 06:15 PM';
//       case 'monthly':
//         return 'Avg: 06:10 PM';
//       case 'quarterly':
//         return 'Avg: 06:05 PM';
//       default:
//         return '06:00 PM';
//     }
//   }

//   String _getPeriodDateRange(String period, DateTime selectedDate) {
//     final dateFormat = DateFormat('dd MMM yyyy');

//     switch (period) {
//       case 'daily':
//         return dateFormat.format(selectedDate);
//       case 'weekly':
//         final weekStart = getFirstDayOfWeek(selectedDate);
//         final weekEnd = weekStart.add(const Duration(days: 6));
//         return '${dateFormat.format(weekStart)} - ${dateFormat.format(weekEnd)}';
//       case 'monthly':
//         return DateFormat('MMMM yyyy').format(selectedDate);
//       case 'quarterly':
//         final quarter = ((selectedDate.month - 1) ~/ 3) + 1;
//         return 'Q$quarter ${selectedDate.year}';
//       default:
//         return getPeriodDisplayName(period);
//     }
//   }

//   List<DateTime> _getWeekDays(DateTime weekStart) {
//     final days = <DateTime>[];
//     for (int i = 0; i < 7; i++) {
//       days.add(weekStart.add(Duration(days: i)));
//     }
//     return days;
//   }

//   int _getWorkingDaysInMonth(int month, int year) {
//     int workingDays = 0;
//     final daysInMonth = DateTime(year, month + 1, 0).day;

//     for (int day = 1; day <= daysInMonth; day++) {
//       final date = DateTime(year, month, day);
//       if (date.weekday != DateTime.saturday &&
//           date.weekday != DateTime.sunday) {
//         workingDays++;
//       }
//     }

//     return workingDays;
//   }

//   int _getWorkingDaysInQuarter(int quarter, int year) {
//     int workingDays = 0;
//     final startMonth = (quarter - 1) * 3 + 1;

//     for (int month = startMonth; month < startMonth + 3; month++) {
//       workingDays += _getWorkingDaysInMonth(month, year);
//     }

//     return workingDays;
//   }

//   @override
//   void dispose() {
//     _teamMembers.clear();
//     _analytics = null;
//     _logQuantumAction('SYSTEM: Shutting down neural matrix');
//     super.dispose();
//   }
// }

// import 'package:flutter/foundation.dart';
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/attendancemodels/attendance_analytics_model.dart';
// import 'package:attendanceapp/models/team_model.dart';
// import 'package:attendanceapp/services/attendanceservices/attendance_analytics_service.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class AttendanceAnalyticsViewModel with ChangeNotifier {
//   final AttendanceAnalyticsService _service = AttendanceAnalyticsService();

//   bool _isLoading = false;
//   bool _showIndividualGraphs = false;
//   String _selectedPeriod = 'daily';
//   DateTime _selectedDate = DateTime.now();
//   AttendanceAnalytics? _analytics;
//   List<TeamMember> _teamMembers = [];

//   bool get isLoading => _isLoading;
//   bool get showIndividualGraphs => _showIndividualGraphs;
//   String get selectedPeriod => _selectedPeriod;
//   DateTime get selectedDate => _selectedDate;
//   AttendanceAnalytics? get analytics => _analytics;
//   List<TeamMember> get teamMembers => _teamMembers;

//   final List<String> availablePeriods = [
//     'daily',
//     'weekly',
//     'monthly',
//     'quarterly',
//   ];

//   Future<void> initializeAnalytics(List<TeamMember> teamMembers) async {
//     if (teamMembers.isEmpty) {
//       _handleQuantumError('MATRIX: No team members detected');
//       return;
//     }

//     _setQuantumLoading(true);
//     _teamMembers = teamMembers;

//     try {
//       _analytics = _service.generateAnalytics(
//         teamMembers,
//         _selectedPeriod,
//         selectedDate: _selectedDate,
//       );
//       _logQuantumSuccess(
//         'INITIALIZED: Neural network activated for ${teamMembers.length} team nodes',
//       );
//     } catch (e) {
//       _handleQuantumError('FAILURE: Matrix initialization failed: $e');
//     } finally {
//       _setQuantumLoading(false);
//     }
//   }

//   void toggleGraphView() {
//     _showIndividualGraphs = !_showIndividualGraphs;
//     _logQuantumAction(
//       'VIEW MODE: ${_showIndividualGraphs ? 'INDIVIDUAL NODES' : 'MERGED MATRIX'} activated',
//     );
//     notifyListeners();
//   }

//   void changePeriod(String period, {DateTime? selectedDate}) {
//     if (_selectedPeriod == period || !availablePeriods.contains(period)) return;

//     _selectedPeriod = period;
//     if (selectedDate != null) {
//       _selectedDate = selectedDate;
//     }

//     _logQuantumAction(
//       'TIME PERIOD: ${getQuantumPeriodDisplayName(period)} | DATE: ${_formatDateForQuantumLog(_selectedDate)}',
//     );

//     if (_teamMembers.isNotEmpty) {
//       _refreshQuantumAnalytics();
//     }
//     notifyListeners();
//   }

//   Future<void> refreshAnalytics() async {
//     if (_teamMembers.isEmpty) {
//       _handleQuantumError('TODAY: No active nodes found');
//       return;
//     }

//     _logQuantumAction('REFRESH: Recalibrating neural matrix');
//     await _refreshQuantumAnalytics();
//   }

//   List<Insight> getInsights() {
//     if (_analytics == null) return _getQuantumDefaultInsights();
//     return _service.generateInsights(_analytics!.statistics);
//   }

//   List<PerformanceMetric> getPerformanceMetrics() {
//     return _service.getPerformanceMetrics();
//   }

//   Color getPerformanceColor(double rate) {
//     if (rate >= 90) return Colors.green.shade400; // Green
//     if (rate >= 75) return Colors.orange.shade400; // Orange
//     if (rate >= 60) return Colors.blue.shade400; // Blue
//     return Colors.red.shade400; // Red
//   }

//   Color getQuantumMetricColor(String metricType) {
//     switch (metricType) {
//       case 'attendance':
//         return Colors.green.shade400;
//       case 'hours':
//         return Colors.cyan.shade400;
//       case 'productivity':
//         return Colors.orange.shade400;
//       case 'efficiency':
//         return Colors.purple.shade400;
//       default:
//         return Colors.blue.shade400;
//     }
//   }

//   String getPeriodDisplayName(String period) {
//     const periodNames = {
//       'daily': 'Daily',
//       'weekly': 'Weekly',
//       'monthly': 'Monthly',
//       'quarterly': 'Quarterly',
//     };
//     return periodNames[period] ?? 'Daily';
//   }

//   String getQuantumPeriodDisplayName(String period) {
//     const periodNames = {
//       'daily': 'DAY',
//       'weekly': 'WEEK',
//       'monthly': 'MONTH',
//       'quarterly': 'QUARTER',
//     };
//     return periodNames[period] ?? 'DAY';
//   }

//   String getGraphSubtitle() {
//     final dateFormat = DateFormat('dd MMM yyyy');
//     final monthFormat = DateFormat('MMM yyyy');

//     switch (_selectedPeriod) {
//       case 'daily':
//         return 'DAILY: ${dateFormat.format(_selectedDate)}';
//       case 'weekly':
//         final weekEnd = _selectedDate.add(const Duration(days: 6));
//         return 'WEEK ${_getWeekNumber(_selectedDate)} MATRIX: ${dateFormat.format(_selectedDate)} - ${dateFormat.format(weekEnd)}';
//       case 'monthly':
//         return 'MONTHLY: ${monthFormat.format(_selectedDate)}';
//       case 'quarterly':
//         final quarter = ((_selectedDate.month - 1) ~/ 3) + 1;
//         return 'QUARTER ${quarter} ${_selectedDate.year} ANALYSIS';
//       default:
//         return 'ATTENDANCE MATRIX';
//     }
//   }

//   String getQuantumHeaderTitle() {
//     switch (_selectedPeriod) {
//       case 'daily':
//         return 'DAILY MATRIX';
//       case 'weekly':
//         return 'WEEKLY NEURAL NETWORK';
//       case 'monthly':
//         return 'MONTHLY PERFORMANCE GRID';
//       case 'quarterly':
//         return 'QUARTERLY ANALYTICS CORE';
//       default:
//         return 'ATTENDANCE SYSTEM';
//     }
//   }

//   Map<String, dynamic> get statistics {
//     return _analytics?.statistics ?? _getQuantumDefaultStatistics();
//   }

//   List<String> getGraphLabels() {
//     switch (_selectedPeriod) {
//       case 'daily':
//         return ['9AM', '11AM', '1PM', '3PM', '5PM', '7PM'];
//       case 'weekly':
//         return ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
//       case 'monthly':
//         final daysInMonth = DateTime(
//           _selectedDate.year,
//           _selectedDate.month + 1,
//           0,
//         ).day;
//         return ['W1', 'W2', 'W3', 'W4', if (daysInMonth > 28) 'W5'];
//       case 'quarterly':
//         final quarter = ((_selectedDate.month - 1) ~/ 3) + 1;
//         return [
//           'M${(quarter - 1) * 3 + 1}',
//           'M${(quarter - 1) * 3 + 2}',
//           'M${(quarter - 1) * 3 + 3}',
//         ];
//       default:
//         return ['9AM', '11AM', '1PM', '3PM', '5PM', '7PM'];
//     }
//   }

//   List<String> getQuantumGraphLabels() {
//     switch (_selectedPeriod) {
//       case 'daily':
//         return ['9', '11', '13', '15', '17', '19'];
//       case 'weekly':
//         return ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
//       case 'monthly':
//         return ['WEEK 1', 'WEEK 2', 'WEEK 3', 'WEEK 4', 'WEEK 5'];
//       case 'quarterly':
//         return ['MONTH 1', 'MONTH 2', 'MONTH 3'];
//       default:
//         return ['NODE 1', 'NODE 2', 'NODE 3', 'NODE 4', 'NODE 5', 'NODE 6'];
//     }
//   }

//   // Performance Analysis
//   String getQuantumPerformanceLevel(double rate) {
//     if (rate >= 90) return 'OPTIMAL';
//     if (rate >= 75) return 'NEURAL STABLE';
//     if (rate >= 60) return 'MATRIX NORMAL';
//     return 'SYSTEM CRITICAL';
//   }

//   Color getQuantumPerformanceGlow(double rate) {
//     if (rate >= 90) return Colors.green.shade400.withOpacity(0.6);
//     if (rate >= 75) return Colors.orange.shade400.withOpacity(0.6);
//     if (rate >= 60) return Colors.blue.shade400.withOpacity(0.6);
//     return Colors.red.shade400.withOpacity(0.6);
//   }

//   // Helper methods for date calculations
//   int _getWeekNumber(DateTime date) {
//     final firstDay = DateTime(date.year, 1, 1);
//     final daysDiff = date.difference(firstDay).inDays;
//     return ((daysDiff + firstDay.weekday) / 7).ceil();
//   }

//   DateTime getFirstDayOfWeek(DateTime date) {
//     return date.subtract(Duration(days: date.weekday - 1));
//   }

//   DateTime getFirstDayOfMonth(DateTime date) {
//     return DateTime(date.year, date.month, 1);
//   }

//   DateTime getFirstDayOfQuarter(DateTime date) {
//     final quarter = ((date.month - 1) ~/ 3) + 1;
//     final quarterMonth = (quarter - 1) * 3 + 1;
//     return DateTime(date.year, quarterMonth, 1);
//   }

//   String _formatDateForQuantumLog(DateTime date) {
//     return DateFormat('dd/MM/yyyy').format(date);
//   }

//   Future<void> _refreshQuantumAnalytics() async {
//     _setQuantumLoading(true);

//     try {
//       _analytics = _service.generateAnalytics(
//         _teamMembers,
//         _selectedPeriod,
//         selectedDate: _selectedDate,
//       );
//       _logQuantumSuccess('MATRIX: Data stream recalibrated successfully');
//     } catch (e) {
//       _handleQuantumError('FAILURE: Matrix refresh failed: $e');
//     } finally {
//       _setQuantumLoading(false);
//     }
//   }

//   void _setQuantumLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }

//   void _handleQuantumError(String message) {
//     if (kDebugMode) {
//       print('❌ ERROR: $message');
//     }
//   }

//   void _logQuantumSuccess(String message) {
//     if (kDebugMode) {
//       print('✅ SUCCESS: $message');
//     }
//   }

//   void _logQuantumAction(String message) {
//     if (kDebugMode) {
//       print('🔧 ACTION: $message');
//     }
//   }

//   List<Insight> _getQuantumDefaultInsights() {
//     return [
//       Insight(text: 'SYSTEM: Initializing neural network...', type: 'info'),
//       Insight(
//         text: 'MATRIX STATUS: Awaiting team member data stream',
//         type: 'warning',
//       ),
//     ];
//   }

//   Map<String, dynamic> _getQuantumDefaultStatistics() {
//     return {
//       'attendanceRate': 0,
//       'avgHours': '0.0',
//       'productivity': 0,
//       'quantumScore': 0,
//       'neuralEfficiency': 0,
//     };
//   }

//   // Data Stream Methods
//   List<Map<String, dynamic>> getQuantumTeamPerformance() {
//     if (_analytics?.individualData == null) return [];

//     return _teamMembers.map((member) {
//       final memberData = _analytics!.individualData[member.email] ?? {};
//       final attendanceRate = memberData['attendanceRate'] ?? 0.0;

//       return {
//         'member': member,
//         'attendanceRate': attendanceRate,
//         'quantumLevel': getQuantumPerformanceLevel(attendanceRate),
//         'performanceColor': getPerformanceColor(attendanceRate),
//         'glowColor': getQuantumPerformanceGlow(attendanceRate),
//         'avgHours': memberData['avgHours'] ?? 0.0,
//         'productivity': memberData['productivity'] ?? 0.0,
//       };
//     }).toList();
//   }

//   Map<String, dynamic> getQuantumSystemStatus() {
//     final stats = statistics;
//     final attendanceRate = stats['attendanceRate'] ?? 0;

//     return {
//       'systemStatus': attendanceRate >= 80
//           ? 'OPTIMAL'
//           : attendanceRate >= 60
//           ? 'STABLE'
//           : 'CRITICAL',
//       'quantumScore': (attendanceRate * 1.2).clamp(0, 100).toInt(),
//       'neuralEfficiency':
//           ((stats['productivity'] ?? 0) * 0.8 + attendanceRate * 0.2).toInt(),
//       'matrixIntegrity': ((stats['avgHours'] ?? 0) * 10).clamp(0, 100).toInt(),
//     };
//   }

//   @override
//   void dispose() {
//     _teamMembers.clear();
//     _analytics = null;
//     _logQuantumAction('SYSTEM: Shutting down neural matrix');
//     super.dispose();
//   }
// }

// import 'dart:ui';
// import 'package:flutter/foundation.dart';
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/attendancemodels/attendance_analytics_model.dart';
// import 'package:attendanceapp/models/team_model.dart';
// import 'package:attendanceapp/services/attendanceservices/attendance_analytics_service.dart';

// class AttendanceAnalyticsViewModel with ChangeNotifier {
//   final AttendanceAnalyticsService _service = AttendanceAnalyticsService();

//   bool _isLoading = false;
//   bool _showIndividualGraphs = false;
//   String _selectedPeriod = 'daily';
//   AttendanceAnalytics? _analytics;
//   List<TeamMember> _teamMembers = [];

//   bool get isLoading => _isLoading;
//   bool get showIndividualGraphs => _showIndividualGraphs;
//   String get selectedPeriod => _selectedPeriod;
//   AttendanceAnalytics? get analytics => _analytics;
//   List<TeamMember> get teamMembers => _teamMembers;

//   final List<String> availablePeriods = [
//     'daily',
//     'weekly',
//     'monthly',
//     'yearly',
//   ];

//   Future<void> initializeAnalytics(List<TeamMember> teamMembers) async {
//     if (teamMembers.isEmpty) {
//       _handleError('No team members provided');
//       return;
//     }

//     _setLoading(true);
//     _teamMembers = teamMembers;

//     try {
//       _analytics = _service.generateAnalytics(teamMembers, _selectedPeriod);
//       _logSuccess(
//         'Analytics initialized for ${teamMembers.length} team members',
//       );
//     } catch (e) {
//       _handleError('Failed to initialize analytics: $e');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   void toggleGraphView() {
//     _showIndividualGraphs = !_showIndividualGraphs;
//     _logAction(
//       'Graph view toggled to: ${_showIndividualGraphs ? 'Individual' : 'Merged'}',
//     );
//     notifyListeners();
//   }

//   void changePeriod(String period) {
//     if (_selectedPeriod == period || !availablePeriods.contains(period)) return;

//     _selectedPeriod = period;
//     _logAction('Period changed to: ${getPeriodDisplayName(period)}');

//     if (_teamMembers.isNotEmpty) {
//       _refreshAnalyticsData();
//     }
//     notifyListeners();
//   }

//   Future<void> refreshAnalytics() async {
//     if (_teamMembers.isEmpty) {
//       _handleError('No team members available for refresh');
//       return;
//     }

//     _logAction('Refreshing analytics data');
//     await _refreshAnalyticsData();
//   }

//   List<Insight> getInsights() {
//     if (_analytics == null) return _getDefaultInsights();
//     return _service.generateInsights(_analytics!.statistics);
//   }

//   List<PerformanceMetric> getPerformanceMetrics() {
//     return _service.getPerformanceMetrics();
//   }

//   Color getPerformanceColor(double rate) {
//     if (rate >= 90) return AppColors.success;
//     if (rate >= 75) return AppColors.warning;
//     if (rate >= 60) return AppColors.info;
//     return AppColors.error;
//   }

//   String getPeriodDisplayName(String period) {
//     const periodNames = {
//       'daily': 'Daily',
//       'weekly': 'Weekly',
//       'monthly': 'Monthly',
//       'yearly': 'Yearly',
//     };
//     return periodNames[period] ?? 'Daily';
//   }

//   String getGraphSubtitle() {
//     const subtitles = {
//       'daily': 'Today\'s attendance pattern across working hours',
//       'weekly': 'This week\'s attendance trend (Monday to Saturday)',
//       'monthly': 'Monthly attendance overview (4 weeks)',
//       'yearly': 'Yearly attendance performance by month',
//     };
//     return subtitles[_selectedPeriod] ?? 'Attendance overview';
//   }

//   Map<String, dynamic> get statistics {
//     return _analytics?.statistics ?? _getDefaultStatistics();
//   }

//   List<String> getGraphLabels() {
//     return _analytics?.labels ?? _getDefaultLabels();
//   }

//   Future<void> _refreshAnalyticsData() async {
//     _setLoading(true);

//     try {
//       _analytics = _service.generateAnalytics(_teamMembers, _selectedPeriod);
//     } catch (e) {
//       _handleError('Failed to refresh analytics: $e');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }

//   void _handleError(String message) {
//     if (kDebugMode) {
//       print('❌ AttendanceAnalyticsViewModel: $message');
//     }
//   }

//   void _logSuccess(String message) {
//     if (kDebugMode) {
//       print('✅ AttendanceAnalyticsViewModel: $message');
//     }
//   }

//   void _logAction(String message) {
//     if (kDebugMode) {
//       print('🔧 AttendanceAnalyticsViewModel: $message');
//     }
//   }

//   List<Insight> _getDefaultInsights() {
//     return [Insight(text: 'Analytics data is not available yet', type: 'info')];
//   }

//   Map<String, dynamic> _getDefaultStatistics() {
//     return {'attendanceRate': 0, 'avgHours': '0.0', 'productivity': 0};
//   }

//   List<String> _getDefaultLabels() {
//     return ['9AM', '11AM', '1PM', '3PM', '5PM', '7PM'];
//   }

//   @override
//   void dispose() {
//     _teamMembers.clear();
//     _analytics = null;
//     super.dispose();
//   }
// }
