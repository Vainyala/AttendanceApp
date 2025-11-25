import 'dart:async';

import 'package:AttendanceApp/manager/models/attendance_model.dart';
import 'package:AttendanceApp/manager/models/managermodels/manager_dashboard_model.dart';
import 'package:AttendanceApp/manager/models/project_model.dart';
import 'package:AttendanceApp/manager/models/team_model.dart';
import 'package:AttendanceApp/manager/models/user_model.dart';
import 'package:AttendanceApp/manager/services/managerservices/attendance_service.dart';
import 'package:AttendanceApp/manager/services/managerservices/project_service.dart';
import 'package:AttendanceApp/manager/services/managerservices/team_service.dart';
import 'package:flutter/foundation.dart';

class ManagerDashboardViewModel with ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  final TeamService _teamService = TeamService();
  final ProjectService _projectService = ProjectService();

  bool _isLoading = false;
  String _errorMessage = '';
  ManagerDashboard? _dashboard;
  DashboardStats? _stats;
  WorkingHours _workingHours = WorkingHours(
    workedDuration: Duration.zero,
    isCheckedIn: false,
  );

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  ManagerDashboard? get dashboard => _dashboard;
  DashboardStats? get stats => _stats;
  WorkingHours get workingHours => _workingHours;

  Future<void> initializeDashboard(User manager) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final teamAttendance = await _attendanceService.getTeamAttendance(
        manager.email,
      );
      final teamMembers = await _teamService.getTeamMembers(manager.email);
      final projects = await _projectService.getManagerProjects(manager.email);

      _dashboard = ManagerDashboard(
        profile: manager,
        teamAttendance: teamAttendance,
        teamMembers: teamMembers,
        projects: projects,
        currentDateTime: DateTime.now(),
        workingHours: _workingHours,
      );

      _calculateStats(teamAttendance, teamMembers, projects);
      await _loadTodayWorkingHours(manager.email);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load dashboard: ${e.toString()}';
      notifyListeners();
    }
  }

  void _calculateStats(
    List<AttendanceRecord> attendance,
    List<TeamMember> members,
    List<Project> projects,
  ) {
    final today = DateTime.now();
    final presentCount = attendance.where((record) {
      return record.checkIn.year == today.year &&
          record.checkIn.month == today.month &&
          record.checkIn.day == today.day;
    }).length;

    // ✅ Calculate absent today
    final absentToday = members.length - presentCount;

    // ✅ Calculate overall present (monthly attendance)
    final overallPresent = _calculateOverallPresent(attendance, members);

    _stats = DashboardStats(
      totalTeamMembers: members.length,
      presentToday: presentCount,
      activeProjects: projects.where((p) => p.status == 'active').length,
      pendingLeaves: 0, // You can implement leave service later
      absentToday: absentToday, // ✅ Naya field add kiya
      overallPresent: overallPresent, // ✅ Naya field add kiya
    );
  }

  int _calculateOverallPresent(
    List<AttendanceRecord> attendance,
    List<TeamMember> members,
  ) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    // Current month ke working days calculate karo
    final workingDays = _calculateWorkingDays(firstDayOfMonth, now);

    // Average attendance rate (85% maan ke chalo)
    const averageAttendanceRate = 0.85;

    // Overall present = Total team members × Working days × Average attendance rate
    return (members.length * workingDays * averageAttendanceRate).round();
  }

  int _calculateWorkingDays(DateTime start, DateTime end) {
    int workingDays = 0;
    DateTime current = start;

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      // Monday (1) to Friday (5) working days maano
      if (current.weekday >= DateTime.monday &&
          current.weekday <= DateTime.friday) {
        workingDays++;
      }
      current = current.add(const Duration(days: 1));
    }

    return workingDays;
  }

  Future<void> checkIn(String managerEmail) async {
    try {
      final checkInTime = DateTime.now();
      await _attendanceService.recordCheckIn(
        managerEmail,
        checkInTime,
        'Office',
      );

      _workingHours = WorkingHours(
        checkIn: checkInTime,
        checkOut: null,
        workedDuration: Duration.zero,
        isCheckedIn: true,
      );
      notifyListeners();

      // Start timer for worked duration
      _startWorkingTimer();
    } catch (e) {
      _errorMessage = 'Check-in failed: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> checkOut(String managerEmail) async {
    try {
      final checkOutTime = DateTime.now();
      await _attendanceService.recordCheckOut(managerEmail, checkOutTime);

      _workingHours = WorkingHours(
        checkIn: _workingHours.checkIn,
        checkOut: checkOutTime,
        workedDuration: _workingHours.workedDuration,
        isCheckedIn: false,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Check-out failed: ${e.toString()}';
      notifyListeners();
    }
  }

  void _startWorkingTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_workingHours.isCheckedIn) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      final duration = now.difference(_workingHours.checkIn!);

      _workingHours = WorkingHours(
        checkIn: _workingHours.checkIn,
        checkOut: null,
        workedDuration: duration,
        isCheckedIn: true,
      );
      notifyListeners();
    });
  }

  Future<void> _loadTodayWorkingHours(String managerEmail) async {
    try {
      final todayRecord = await _attendanceService.getTodayAttendance(
        managerEmail,
      );
      if (todayRecord != null && todayRecord.checkOut == null) {
        final duration = DateTime.now().difference(todayRecord.checkIn);
        _workingHours = WorkingHours(
          checkIn: todayRecord.checkIn,
          checkOut: null,
          workedDuration: duration,
          isCheckedIn: true,
        );
        _startWorkingTimer();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading working hours: $e');
      }
    }
  }

  void refreshDashboard(User manager) {
    initializeDashboard(manager);
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
