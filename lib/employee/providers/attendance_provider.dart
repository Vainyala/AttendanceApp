import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';
import '../services/auth_service.dart';
import 'dart:convert';

class AttendanceProvider with ChangeNotifier {
  final AuthService _authService = AuthService.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  bool _isLoading = false;
  List<Map<String, dynamic>> _attendanceList = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get attendanceList => _attendanceList;
  String? get errorMessage => _errorMessage;

  // Fetch attendance from server and sync with local database
  Future<void> fetchAttendance({bool forceRefresh = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = await _authService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      // First, load from local database for instant display
      if (!forceRefresh) {
        _attendanceList = await _dbHelper.getAttendanceByUserId(userId);
        _isLoading = false;
        notifyListeners();
      }

      // Then fetch from server to sync
      final response = await _authService.authenticatedRequest('/attendance');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Clear and repopulate local database
        await _dbHelper.database.then((db) => db.delete('attendance', where: 'user_id = ?', whereArgs: [userId]));

        for (var record in data) {
          await _dbHelper.insertAttendance({
            'user_id': userId,
            'date': record['date'],
            'check_in': record['check_in'],
            'check_out': record['check_out'],
            'status': record['status'],
            'location': record['location'],
            'created_at': record['created_at'] ?? DateTime.now().toIso8601String(),
          });
        }

        _attendanceList = await _dbHelper.getAttendanceByUserId(userId);
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = 'Error fetching attendance: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Mark attendance (check-in)
  Future<bool> checkIn({String? location}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = await _authService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      final now = DateTime.now();
      final date = now.toIso8601String().split('T')[0];
      final time = now.toIso8601String();

      // Check if already checked in today
      final existingRecords = await _dbHelper.getAttendanceByDate(userId, date);
      if (existingRecords.isNotEmpty && existingRecords.first['check_in'] != null) {
        _errorMessage = 'Already checked in today';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Send to server
      final response = await _authService.authenticatedRequest(
        '/attendance/check-in',
        method: 'POST',
        body: {
          'date': date,
          'check_in': time,
          'location': location ?? 'Unknown',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Store in local database
        await _dbHelper.insertAttendance({
          'user_id': userId,
          'date': date,
          'check_in': time,
          'check_out': null,
          'status': 'present',
          'location': location ?? 'Unknown',
          'created_at': time,
        });

        await fetchAttendance();
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Check-in failed');
      }
    } catch (e) {
      _errorMessage = 'Check-in error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Mark attendance (check-out)
  Future<bool> checkOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = await _authService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      final now = DateTime.now();
      final date = now.toIso8601String().split('T')[0];
      final time = now.toIso8601String();

      // Get today's record
      final records = await _dbHelper.getAttendanceByDate(userId, date);
      if (records.isEmpty || records.first['check_in'] == null) {
        _errorMessage = 'No check-in record found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final recordId = records.first['id'];

      // Send to server
      final response = await _authService.authenticatedRequest(
        '/attendance/check-out',
        method: 'POST',
        body: {
          'date': date,
          'check_out': time,
        },
      );

      if (response.statusCode == 200) {
        // Update local database
        await _dbHelper.updateAttendance(recordId, {
          'check_out': time,
        });

        await fetchAttendance();
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Check-out failed');
      }
    } catch (e) {
      _errorMessage = 'Check-out error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get today's attendance status
  Future<Map<String, dynamic>?> getTodayStatus() async {
    try {
      final userId = await _authService.getUserId();
      if (userId == null) return null;

      final date = DateTime.now().toIso8601String().split('T')[0];
      final records = await _dbHelper.getAttendanceByDate(userId, date);

      return records.isNotEmpty ? records.first : null;
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}