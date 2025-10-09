import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/attendance_model.dart';

class RegularisationProvider extends ChangeNotifier {
  List<AttendanceModel> _attendance = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<DateTime> _availableMonths = [];
  int _currentMonthIndex = 0;
  Map<String, Map<String, int>> _monthlyStats = {};

  // Getters
  List<AttendanceModel> get attendance => _attendance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<DateTime> get availableMonths => _availableMonths;
  int get currentMonthIndex => _currentMonthIndex;
  Map<String, Map<String, int>> get monthlyStats => _monthlyStats;

  // Initialize available months
  void initializeMonths() {
    final now = DateTime.now();
    _availableMonths = [];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      _availableMonths.add(month);
    }

    _currentMonthIndex = _availableMonths.length - 1;
    notifyListeners();
  }

  // Load attendance data
  Future<void> loadAttendance() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      final dummyData = _createDummyAttendance();
      _calculateMonthlyStats(dummyData);

      _attendance = dummyData;
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _errorMessage = 'Error loading attendance: $e';
      _isLoading = false;
      _attendance = [];
      notifyListeners();
      print('Error: $e\nStack: $stackTrace');
    }
  }

  // Calculate monthly statistics
  void _calculateMonthlyStats(List<AttendanceModel> records) {
    final stats = <String, Map<String, int>>{};

    for (var month in _availableMonths) {
      final monthKey = DateFormat('yyyy-MM').format(month);
      stats[monthKey] = {
        'Apply': 0,
        'Approved': 0,
        'Pending': 0,
        'Rejected': 0,
      };
    }

    final groupedByDate = <String, List<AttendanceModel>>{};
    for (var record in records) {
      final dateKey = DateFormat('yyyy-MM-dd').format(record.timestamp);
      groupedByDate.putIfAbsent(dateKey, () => []);
      groupedByDate[dateKey]!.add(record);
    }

    for (var entry in groupedByDate.entries) {
      final dayRecords = entry.value;
      final clockHours = calculateClockHours(dayRecords);
      final shortfall = calculateShortfall(clockHours);
      final date = dayRecords.first.timestamp;
      final monthKey = DateFormat('yyyy-MM').format(date);
      final status = getStatusForDay(date, shortfall);

      if (stats.containsKey(monthKey) && stats[monthKey]!.containsKey(status)) {
        stats[monthKey]![status] = stats[monthKey]![status]! + 1;
      }
    }

    _monthlyStats = stats;
  }

  // Create dummy attendance data
  List<AttendanceModel> _createDummyAttendance() {
    final records = <AttendanceModel>[];
    final now = DateTime.now();

    final holidays = [
      '2024-10-02', '2024-10-12', '2024-10-31', '2024-11-01',
      '2024-12-25', '2025-01-26',
    ];

    final projectNames = [
      'Project A', 'Project B', 'Project C', 'Project D',
      'Project Alpha', 'Project Beta', 'Project Gamma'
    ];

    for (var month in _availableMonths) {
      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
      final maxDay = month.month == now.month && month.year == now.year
          ? now.day
          : daysInMonth;

      for (int day = 1; day <= maxDay; day++) {
        final currentDate = DateTime(month.year, month.month, day);
        final dateKey = DateFormat('yyyy-MM-dd').format(currentDate);

        if (currentDate.weekday == DateTime.sunday) continue;
        if (holidays.contains(dateKey)) continue;

        final numProjects = 1 + ((day * month.month) % 3);
        final dayProjects = <String>[];

        for (int i = 0; i < numProjects; i++) {
          final projectIndex = ((day * 7 + i * 13 + month.month * 3) % projectNames.length);
          final project = projectNames[projectIndex];
          if (!dayProjects.contains(project)) {
            dayProjects.add(project);
          }
        }

        final dayVariation = (day * 3 + month.month * 7) % 10;

        for (int i = 0; i < dayProjects.length; i++) {
          final project = dayProjects[i];

          int workHours;
          int workMinutes;

          if (dayVariation < 2) {
            workHours = 2;
            workMinutes = 30 + ((day + i) % 30);
          } else if (dayVariation < 4) {
            workHours = 3;
            workMinutes = ((day * i) % 60);
          } else if (dayVariation < 7) {
            workHours = 3;
            workMinutes = 30 + ((day - i) % 30);
          } else {
            workHours = 4;
            workMinutes = ((day + month.month + i) % 45);
          }

          final checkInHour = 8 + ((day + i) % 2);
          final checkInMinute = (day * 5 + i * 15) % 60;

          final checkInTime = DateTime(
              month.year, month.month, day,
              checkInHour, checkInMinute
          );
          final checkOutTime = checkInTime.add(
              Duration(hours: workHours, minutes: workMinutes)
          );

          records.addAll([
            AttendanceModel(
              id: 'checkin_${month.month}_${day}_$project',
              userId: 'user_123',
              timestamp: checkInTime,
              type: AttendanceType.checkIn,
              latitude: 19.2183,
              longitude: 72.9781,
              projectName: project,
            ),
            AttendanceModel(
              id: 'checkout_${month.month}_${day}_$project',
              userId: 'user_123',
              timestamp: checkOutTime,
              type: AttendanceType.checkOut,
              latitude: 19.2183,
              longitude: 72.9781,
              projectName: project,
            ),
          ]);
        }
      }
    }

    return records;
  }

  // Filter attendance by month
  List<AttendanceModel> filterByMonth(DateTime month) {
    return _attendance
        .where((record) =>
    record.timestamp.year == month.year &&
        record.timestamp.month == month.month)
        .toList();
  }

  // Calculate clock hours for a day
  String calculateClockHours(List<AttendanceModel> dayRecords) {
    try {
      final projectGroups = <String, List<AttendanceModel>>{};
      for (var record in dayRecords) {
        projectGroups.putIfAbsent(record.projectName, () => []);
        projectGroups[record.projectName]!.add(record);
      }

      int totalMinutes = 0;

      for (var projectRecords in projectGroups.values) {
        final checkIn = projectRecords.firstWhere(
              (r) => r.type == AttendanceType.checkIn,
          orElse: () => projectRecords.first,
        );
        final checkOut = projectRecords.lastWhere(
              (r) => r.type == AttendanceType.checkOut,
          orElse: () => projectRecords.last,
        );

        totalMinutes += checkOut.timestamp.difference(checkIn.timestamp).inMinutes;
      }

      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00';
    }
  }

  // Calculate shortfall hours
  String calculateShortfall(String clockHours) {
    try {
      final parts = clockHours.split(':');
      final workedMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      final standardMinutes = 8 * 60;

      if (workedMinutes >= standardMinutes) return '00:00';

      final shortfallMinutes = standardMinutes - workedMinutes;
      final hours = shortfallMinutes ~/ 60;
      final minutes = shortfallMinutes % 60;
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00';
    }
  }

  // Get status for a day
  String getStatusForDay(DateTime date, String shortfall) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate.isAtSameMomentAs(today) || checkDate.isAfter(today)) {
      return 'Approved';
    }

    if (shortfall == '00:00') return 'Approved';

    final random = (date.day * 3 + date.month * 7) % 20;

    if (random < 5) return 'Apply';
    if (random < 9) return 'Pending';
    if (random < 12) return 'Rejected';
    return 'Approved';
  }

  // Check if record can be edited
  bool canEditRecord(DateTime date, String status) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    return checkDate.isBefore(today) && status == 'Apply';
  }

  // Get categorized records by status
  Map<String, List<Map<String, dynamic>>> getCategorizedRecords(DateTime month) {
    final records = filterByMonth(month);
    final byStatus = {
      'Apply': <Map<String, dynamic>>[],
      'Pending': <Map<String, dynamic>>[],
      'Rejected': <Map<String, dynamic>>[],
      'Approved': <Map<String, dynamic>>[],
    };

    final groupedByDate = <String, List<AttendanceModel>>{};
    for (var record in records) {
      final dateKey = DateFormat('dd/MM/yy').format(record.timestamp);
      groupedByDate.putIfAbsent(dateKey, () => []);
      groupedByDate[dateKey]!.add(record);
    }

    for (var entry in groupedByDate.entries) {
      final dayRecords = entry.value;
      final clockHours = calculateClockHours(dayRecords);
      final shortfall = calculateShortfall(clockHours);
      final actualDate = dayRecords.first.timestamp;
      final status = getStatusForDay(actualDate, shortfall);

      byStatus[status]?.add({
        'date': entry.key,
        'hours': clockHours,
        'shortfall': shortfall,
        'actualDate': actualDate,
        'records': dayRecords,
      });
    }

    return byStatus;
  }

  // Get project groups from day records
  Map<String, List<AttendanceModel>> getProjectGroups(List<AttendanceModel> dayRecords) {
    final projectGroups = <String, List<AttendanceModel>>{};
    for (var record in dayRecords) {
      projectGroups.putIfAbsent(record.projectName, () => []);
      projectGroups[record.projectName]!.add(record);
    }
    return projectGroups;
  }

  // Submit regularisation request
  Future<void> submitRegularisation({
    required String date,
    required TimeOfDay time,
    required String type,
    required String notes,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // In a real app, you would send this to your backend
    // and update the attendance status accordingly
    notifyListeners();
  }

  // Set current month index
  void setCurrentMonthIndex(int index) {
    _currentMonthIndex = index;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}