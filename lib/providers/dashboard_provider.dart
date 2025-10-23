import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/attendance_model.dart';
import '../models/project_model.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

enum EmployeeStatus {
  notCheckedIn,
  checkedIn,
  outOfRange,
  outOfRangeWillReturn,
  returned,
}

class AppProvider extends ChangeNotifier {
  UserModel? _user;
  List<AttendanceModel> _todayAttendance = [];
  List<AttendanceModel> _weeklyAttendance = [];
  List<AttendanceModel> _allAttendance = [];
  ProjectModel? _selectedProject;

  bool _isLocationEnabled = false;
  bool _isInGeofence = false;
  bool _canCheckIn = false;
  bool _canCheckOut = false;
  bool _wasInsideGeofence = false;
  String _statusMessage = "Checking location...";
  String _geofenceStatus = "You Are Not In Range Of Nutantek";

  double _weeklyAvgHours = 0.0;
  double _monthlyAvgHours = 0.0;

  bool _isLoadingUser = false;
  bool _isLoadingAttendance = false;
  bool _isCheckingIn = false;
  bool _isCheckingOut = false;

  // Employee status tracking
  EmployeeStatus _employeeStatus = EmployeeStatus.notCheckedIn;
  bool _pendingVerification = false;
  String? _currentNotificationPayload;
  DateTime? _lastOutOfRangeTime;
  bool _wentOutDuringOfficeHours = false;

  // Getters
  UserModel? get user => _user;
  List<AttendanceModel> get todayAttendance => _todayAttendance;
  List<AttendanceModel> get weeklyAttendance => _weeklyAttendance;
  bool get isLocationEnabled => _isLocationEnabled;
  bool get isInGeofence => _isInGeofence;
  bool get canCheckIn => _canCheckIn;
  bool get canCheckOut => _canCheckOut;
  String get statusMessage => _statusMessage;
  String get geofenceStatus => _geofenceStatus;
  double get weeklyAvgHours => _weeklyAvgHours;
  double get monthlyAvgHours => _monthlyAvgHours;
  bool get isLoadingUser => _isLoadingUser;
  bool get isLoadingAttendance => _isLoadingAttendance;
  bool get isCheckingIn => _isCheckingIn;
  bool get isCheckingOut => _isCheckingOut;
  ProjectModel? get selectedProject => _selectedProject;

  EmployeeStatus get employeeStatus => _employeeStatus;
  bool get pendingVerification => _pendingVerification;
  bool get showVerificationAlert => _pendingVerification;

  // FIXED: Check-in and Check-out time getters
  DateTime? get checkInTime {
    try {
      return _todayAttendance
          .firstWhere((a) => a.type == AttendanceType.enter)
          .timestamp;
    } catch (_) {
      return null;
    }
  }

  DateTime? get checkOutTime {
    try {
      return _todayAttendance
          .firstWhere((a) => a.type == AttendanceType.exit)
          .timestamp;
    } catch (_) {
      return null;
    }
  }

  Future<void> loadUserData() async {
    _isLoadingUser = true;
    notifyListeners();

    try {
      final dummyProjects = [
        ProjectModel(
          id: 'P001',
          name: 'Nutantek Office App',
          site: 'Nutantek Office',
          shift: 'Morning',
          clientName: 'Client A',
          clientContact: '1234567890',
          manager: 'Manager A',
          description: 'Office attendance app',
          techStack: 'Flutter, Firebase',
          assignedDate: DateTime.now(),
        ),
        ProjectModel(
          id: 'P002',
          name: 'Delhi Police App',
          site: 'Client Site',
          shift: 'Evening',
          clientName: 'Client B',
          clientContact: '0987654321',
          manager: 'Manager B',
          description: 'Website development',
          techStack: 'React, Node.js',
          assignedDate: DateTime.now(),
        ),
      ];

      _user = UserModel(
        id: 'U001',
        name: 'Samal Vainyala',
        email: 'samal@nutantek.com',
        role: 'Flutter Developer',
        projects: dummyProjects,
      );
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      _isLoadingUser = false;
      notifyListeners();
    }
  }

  void setSelectedProject(ProjectModel project) {
    _selectedProject = project;
    notifyListeners();
  }

  Future<void> loadTodayAttendance() async {
    _isLoadingAttendance = true;
    notifyListeners();

    try {
      _allAttendance = await StorageService.getAttendanceHistory();

      if (_allAttendance.isEmpty) {
        final dummyAttendance = _generateDummyAttendance();
        for (var record in dummyAttendance) {
          await StorageService.saveAttendanceRecord(record);
        }
        _allAttendance = await StorageService.getAttendanceHistory();
      }

      final today = DateTime.now();
      _todayAttendance = _allAttendance.where((record) {
        return record.timestamp.year == today.year &&
            record.timestamp.month == today.month &&
            record.timestamp.day == today.day;
      }).toList();

      // Update employee status based on today's attendance
      _updateEmployeeStatus();
    } catch (e) {
      debugPrint('Error loading today attendance: $e');
    } finally {
      _isLoadingAttendance = false;
      notifyListeners();
    }
  }

  Future<void> loadWeeklyAttendance() async {
    try {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      _weeklyAttendance = _allAttendance.where((record) {
        return record.timestamp.isAfter(weekAgo);
      }).toList();

      _calculateAverages();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading weekly attendance: $e');
    }
  }

  List<AttendanceModel> _generateDummyAttendance() {
    List<AttendanceModel> dummyData = [];
    final now = DateTime.now();

    for (int day = 0; day < 7; day++) {
      final date = now.subtract(Duration(days: day));

      dummyData.add(AttendanceModel(
        id: 'dummy_${day}_in',
        userId: 'U001',
        timestamp: DateTime(date.year, date.month, date.day, 9, 0),
        type: AttendanceType.enter,
        latitude: 19.2952,
        longitude: 73.1186,
      ));

      dummyData.add(AttendanceModel(
        id: 'dummy_${day}_out',
        userId: 'U001',
        timestamp: DateTime(date.year, date.month, date.day, 18, 0),
        type: AttendanceType.exit,
        latitude: 19.2952,
        longitude: 73.1186,
      ));
    }

    return dummyData;
  }

  void _calculateAverages() {
    double weeklyHours = 0;
    int weeklyDays = 0;

    for (int i = 0; i < _weeklyAttendance.length - 1; i += 2) {
      if (i + 1 < _weeklyAttendance.length &&
          _weeklyAttendance[i].type == AttendanceType.enter &&
          _weeklyAttendance[i + 1].type == AttendanceType.exit) {
        final duration = _weeklyAttendance[i + 1]
            .timestamp
            .difference(_weeklyAttendance[i].timestamp);
        weeklyHours += duration.inMinutes / 60.0;
        weeklyDays++;
      }
    }

    final monthStart = DateTime.now().subtract(const Duration(days: 30));
    final monthlyRecords = _allAttendance
        .where((record) => record.timestamp.isAfter(monthStart))
        .toList();

    double monthlyHours = 0;
    for (int i = 0; i < monthlyRecords.length - 1; i += 2) {
      if (i + 1 < monthlyRecords.length &&
          monthlyRecords[i].type == AttendanceType.enter &&
          monthlyRecords[i + 1].type == AttendanceType.exit) {
        final duration = monthlyRecords[i + 1]
            .timestamp
            .difference(monthlyRecords[i].timestamp);
        monthlyHours += duration.inMinutes / 60.0;
      }
    }

    _weeklyAvgHours = weeklyDays > 0 ? weeklyHours / weeklyDays : 0;
    _monthlyAvgHours = monthlyHours;
  }

  // Update employee status based on attendance and location
  void _updateEmployeeStatus() {
    if (_todayAttendance.isEmpty) {
      _employeeStatus = EmployeeStatus.notCheckedIn;
    } else if (_todayAttendance.last.type == AttendanceType.enter) {
      if (_isInGeofence) {
        _employeeStatus = EmployeeStatus.checkedIn;
      } else {
        _employeeStatus = _wentOutDuringOfficeHours
            ? EmployeeStatus.outOfRangeWillReturn
            : EmployeeStatus.outOfRange;
      }
    }
  }

  // Check if it's office hours (9 AM to 6 PM)
  bool _isOfficeHours() {
    final now = DateTime.now();
    return now.hour >= 9 && now.hour < 18;
  }

  // Check if it's after office hours
  bool _isAfterOfficeHours() {
    final now = DateTime.now();
    return now.hour >= 18;
  }

  Future<void> updateLocationStatus() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (position == null) return;

      final geofences = await StorageService.getGeofences();
      bool insideAnyGeofence = false;
      String geofenceName = "";

      for (var geofence in geofences) {
        if (LocationService.isWithinGeofence(position, geofence)) {
          insideAnyGeofence = true;
          geofenceName = geofence.name;
          break;
        }
      }

      // Handle geofence state changes
      if (insideAnyGeofence != _wasInsideGeofence) {
        if (insideAnyGeofence) {
          await _handleEnteringGeofence(geofenceName);
        } else {
          await _handleLeavingGeofence();
        }
        _wasInsideGeofence = insideAnyGeofence;
      }

      _isInGeofence = insideAnyGeofence;
      _geofenceStatus = insideAnyGeofence
          ? "You Are In Range Of $geofenceName"
          : "You Are Not In Range Of Nutantek";

      _updateCheckInOutPermissions();
      _statusMessage = _geofenceStatus;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating location status: $e');
    }
  }

  Future<void> _handleEnteringGeofence(String geofenceName) async {
    if (_employeeStatus == EmployeeStatus.notCheckedIn) {
      // FIXED: First time entering - show check-in notification (FACE ONLY)
      final payload = 'checkin_${DateTime.now().millisecondsSinceEpoch}';
      _currentNotificationPayload = payload;

      await NotificationService.showGeofenceNotification(
        title: 'Welcome to $geofenceName',
        body: 'Tap to complete face verification and check in',
        isEntering: true,
        payload: payload,
      );

      _pendingVerification = true;
    } else if (_employeeStatus == EmployeeStatus.outOfRange ||
        _employeeStatus == EmployeeStatus.outOfRangeWillReturn) {
      // Employee returning - needs verification
      _pendingVerification = true;
      _employeeStatus = EmployeeStatus.returned;
    }

    notifyListeners();
  }

  Future<void> _handleLeavingGeofence() async {
    if (_employeeStatus == EmployeeStatus.checkedIn) {
      _lastOutOfRangeTime = DateTime.now();

      if (_isOfficeHours()) {
        // FIXED: During office hours - show choice notification (FACE + FINGERPRINT)
        _wentOutDuringOfficeHours = true;
        await NotificationService.showOutOfRangeNotification(
          title: 'You are out of range',
          body: 'Please verify: Face (not returning) or Fingerprint (will return)',
          payload: 'out_of_range_${DateTime.now().millisecondsSinceEpoch}',
        );
        _pendingVerification = true;
      } else if (_isAfterOfficeHours()) {
        // FIXED: After office hours - only face verification
        await NotificationService.showOutOfRangeNotification(
          title: 'End of Day',
          body: 'Please complete face verification to check out',
          payload: 'checkout_${DateTime.now().millisecondsSinceEpoch}',
        );
        _pendingVerification = true;
      }
    }

    notifyListeners();
  }

  void _updateCheckInOutPermissions() {
    if (_isInGeofence) {
      _canCheckIn = _todayAttendance.isEmpty ||
          _todayAttendance.last.type == AttendanceType.exit;
      _canCheckOut = _todayAttendance.isNotEmpty &&
          _todayAttendance.last.type == AttendanceType.enter;
    } else {
      _canCheckIn = false;
      _canCheckOut = false;
    }
  }

  void updateGeofenceStatus({
    required bool inGeofence,
    required bool canCheckIn,
    required bool canCheckOut,
    required String message,
  }) {
    _isInGeofence = inGeofence;
    _canCheckIn = canCheckIn;
    _canCheckOut = canCheckOut;
    _statusMessage = message;
    notifyListeners();
  }

  void setLocationEnabled(bool enabled) {
    _isLocationEnabled = enabled;
    _statusMessage = enabled
        ? "Location monitoring active"
        : "Location permission required";
    if (!enabled) {
      _geofenceStatus = "Location Permission Required";
    }
    notifyListeners();
  }

  // FIXED: Handle check-in with verification status
  Future<String> handleCheckIn({bool verified = false}) async {
    if (!_isLocationEnabled) {
      return 'Please enable location services';
    }

    // FIXED: For first check-in, always require verification
    if (_employeeStatus == EmployeeStatus.notCheckedIn && !verified) {
      _pendingVerification = true;
      notifyListeners();
      return 'Please complete face verification first';
    }

    if (!_canCheckIn) {
      return 'You have already checked in or are not in range';
    }

    _isCheckingIn = true;
    notifyListeners();

    try {
      final position = await LocationService.getCurrentPosition();
      if (position == null) {
        return 'Unable to get current location';
      }

      final geofences = await StorageService.getGeofences();
      bool insideGeofence = false;

      for (var geofence in geofences) {
        if (LocationService.isWithinGeofence(position, geofence)) {
          insideGeofence = true;

          final attendance = AttendanceModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: _user?.id ?? '',
            timestamp: DateTime.now(),
            type: AttendanceType.enter,
            latitude: position.latitude,
            longitude: position.longitude,
            geofence: geofence,
          );

          await StorageService.saveAttendanceRecord(attendance);
          await loadTodayAttendance();
          await loadWeeklyAttendance();

          _pendingVerification = false;
          _employeeStatus = EmployeeStatus.checkedIn;
          await updateLocationStatus();

          await NotificationService.showAttendanceNotification(
            title: 'Check-In Successful',
            body: 'You have successfully checked in at ${_formatTime(DateTime.now())}',
          );

          notifyListeners();
          return 'Check-in successful!';
        }
      }

      if (!insideGeofence) {
        return 'You are not within any geofence area';
      }
    } catch (e) {
      return 'Check-in failed: $e';
    } finally {
      _isCheckingIn = false;
      notifyListeners();
    }

    return 'Check-in failed';
  }

  // FIXED: Handle check-out with verification
  Future<String> handleCheckOut({bool verified = false}) async {
    if (!_isLocationEnabled) {
      return 'Please enable location services';
    }

    // After office hours, verification is required
    if (_isAfterOfficeHours() && !verified) {
      return 'Please complete face verification first';
    }

    if (!_canCheckOut) {
      return 'You need to check in first';
    }

    _isCheckingOut = true;
    notifyListeners();

    try {
      final position = await LocationService.getCurrentPosition();
      if (position == null) {
        return 'Unable to get current location';
      }

      final attendance = AttendanceModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _user?.id ?? '',
        timestamp: DateTime.now(),
        type: AttendanceType.exit,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      await StorageService.saveAttendanceRecord(attendance);
      await loadTodayAttendance();
      await loadWeeklyAttendance();

      _pendingVerification = false;
      _employeeStatus = EmployeeStatus.notCheckedIn;
      _wentOutDuringOfficeHours = false;
      await updateLocationStatus();

      await NotificationService.showAttendanceNotification(
        title: 'Check-Out Successful',
        body: 'You have successfully checked out at ${_formatTime(DateTime.now())}',
      );

      notifyListeners();
      return 'Check-out successful!';
    } catch (e) {
      return 'Check-out failed: $e';
    } finally {
      _isCheckingOut = false;
      notifyListeners();
    }
  }

  // Handle out of range verification
  Future<void> handleOutOfRangeVerification(bool willReturn) async {
    if (willReturn) {
      _employeeStatus = EmployeeStatus.outOfRangeWillReturn;
    } else {
      _employeeStatus = EmployeeStatus.outOfRange;
      // Treat as checkout if not returning
      await handleCheckOut(verified: true);
    }

    _pendingVerification = false;
    notifyListeners();
  }

  // Clear pending verification
  void clearPendingVerification() {
    _pendingVerification = false;
    notifyListeners();
  }

  // Check if notification is valid
  bool isNotificationValid(String? payload) {
    if (payload == null) return false;
    return NotificationService.isNotificationValid(payload);
  }

  Future<void> refreshAllData() async {
    await loadTodayAttendance();
    await loadWeeklyAttendance();
    await updateLocationStatus();
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}