import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/attendance_model.dart';
import '../models/project_model.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

class AppProvider extends ChangeNotifier {
  // User Data
  UserModel? _user;

  // Attendance Data
  List<AttendanceModel> _todayAttendance = [];
  List<AttendanceModel> _weeklyAttendance = [];
  List<AttendanceModel> _allAttendance = [];

  ProjectModel? _selectedProject;
  ProjectModel? get selectedProject => _selectedProject;
  // Location & Geofence Status
  bool _isLocationEnabled = false;
  bool _isInGeofence = false;
  bool _canCheckIn = false;
  bool _canCheckOut = false;
  bool _wasInsideGeofence = false;
  String _statusMessage = "Checking location...";
  String _geofenceStatus = "You Are Not In Range Of Nutantek";

  // Statistics
  double _weeklyAvgHours = 0.0;
  double _monthlyAvgHours = 0.0;

  // Loading States
  bool _isLoadingUser = false;
  bool _isLoadingAttendance = false;
  bool _isCheckingIn = false;
  bool _isCheckingOut = false;

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

  // Initialize User Data
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
        ProjectModel(
          id: 'P003',
          name: 'eMulakat App',
          site: 'WFH',
          shift: 'Morning',
          clientName: 'Client A',
          clientContact: '1234567890',
          manager: 'Manager A',
          description: 'Office attendance app',
          techStack: 'Flutter, Firebase',
          assignedDate: DateTime.now(),
        ),
        ProjectModel(
          id: 'P004',
          name: 'Attedance App',
          site: 'WFH',
          shift: 'Morning',
          clientName: 'Client A',
          clientContact: '1234567890',
          manager: 'Manager A',
          description: 'Office attendance app',
          techStack: 'Flutter, Firebase',
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
  // Load Today's Attendance
  Future<void> loadTodayAttendance() async {
    _isLoadingAttendance = true;
    notifyListeners();

    try {
      _allAttendance = await StorageService.getAttendanceHistory();

      // Generate dummy data if empty
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
    } catch (e) {
      debugPrint('Error loading today attendance: $e');
    } finally {
      _isLoadingAttendance = false;
      notifyListeners();
    }
  }

  // Load Weekly Attendance
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

  // Generate Dummy Attendance
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

  // Calculate Statistics
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

  // Update Location Status
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

      // Check if geofence state changed
      if (insideAnyGeofence != _wasInsideGeofence) {
        if (insideAnyGeofence) {
          await NotificationService.showGeofenceNotification(
            title: 'Welcome to $geofenceName',
            body: 'You are now in range. You can check in.',
            isEntering: true,
          );
        } else {
          await NotificationService.showGeofenceNotification(
            title: 'Left Geofence Area',
            body: 'You are no longer in range of Nutantek.',
            isEntering: false,
          );
        }
        _wasInsideGeofence = insideAnyGeofence;
      }

      _isInGeofence = insideAnyGeofence;
      _geofenceStatus = insideAnyGeofence
          ? "You Are In Range Of $geofenceName"
          : "You Are Not In Range Of Nutantek";

      if (insideAnyGeofence) {
        _canCheckIn = _todayAttendance.isEmpty ||
            _todayAttendance.last.type == AttendanceType.exit;
        _canCheckOut = _todayAttendance.isNotEmpty &&
            _todayAttendance.last.type == AttendanceType.enter;
      } else {
        _canCheckIn = false;
        _canCheckOut = false;
      }

      _statusMessage = _geofenceStatus;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating location status: $e');
    }
  }

  // Update Geofence Status (Manual)
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

  // Set Location Enabled
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

  // Handle Check In
  Future<String> handleCheckIn() async {
    if (!_isLocationEnabled) {
      return 'Please enable location services';
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
          await updateLocationStatus();

          await NotificationService.showAttendanceNotification(
            title: 'Check-In Successful',
            body: 'You have successfully checked in at ${_formatTime(DateTime.now())}',
          );

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

  // Handle Check Out
  Future<String> handleCheckOut() async {
    if (!_isLocationEnabled) {
      return 'Please enable location services';
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
      await updateLocationStatus();

      await NotificationService.showAttendanceNotification(
        title: 'Check-Out Successful',
        body: 'You have successfully checked out at ${_formatTime(DateTime.now())}',
      );

      return 'Check-out successful!';
    } catch (e) {
      return 'Check-out failed: $e';
    } finally {
      _isCheckingOut = false;
      notifyListeners();
    }
  }

  // Refresh All Data
  Future<void> refreshAllData() async {
    await loadTodayAttendance();
    await loadWeeklyAttendance();
    await updateLocationStatus();
  }

  // Helper method
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}