import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/attendance_model.dart';
import '../models/geofence_model.dart';
import '../models/user_model.dart';

class StorageService {
  static const String _userKey = 'user_data';
  static const String _geofencesKey = 'geofences_data';
  static const String _attendanceKey = 'attendance_data';
  static const String _loginCredentialsKey = 'login_credentials';

  // User management
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }

  static Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Login credentials for demo
  static Future<void> saveLoginCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loginCredentialsKey, jsonEncode({
      'email': email,
      'password': password,
    }));
  }

  static Future<Map<String, String>?> getLoginCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final credentials = prefs.getString(_loginCredentialsKey);
    if (credentials != null) {
      final data = jsonDecode(credentials);
      return {
        'email': data['email'],
        'password': data['password'],
      };
    }
    return null;
  }

  // Geofence management
  static Future<void> saveGeofences(List<GeofenceModel> geofences) async {
    final prefs = await SharedPreferences.getInstance();
    final geofencesJson = geofences.map((g) => g.toJson()).toList();
    await prefs.setString(_geofencesKey, jsonEncode(geofencesJson));
  }

  static Future<List<GeofenceModel>> getGeofences() async {
    final prefs = await SharedPreferences.getInstance();
    final geofencesData = prefs.getString(_geofencesKey);
    if (geofencesData != null) {
      final List<dynamic> geofencesList = jsonDecode(geofencesData);
      return geofencesList.map((g) => GeofenceModel.fromJson(g)).toList();
    }
    return [];
  }

  static Future<void> addGeofence(GeofenceModel geofence) async {
    final geofences = await getGeofences();
    geofences.add(geofence);
    await saveGeofences(geofences);
  }

  static Future<void> updateGeofence(GeofenceModel updatedGeofence) async {
    final geofences = await getGeofences();
    final index = geofences.indexWhere((g) => g.id == updatedGeofence.id);
    if (index != -1) {
      geofences[index] = updatedGeofence;
      await saveGeofences(geofences);
    }
  }

  static Future<void> removeGeofence(String geofenceId) async {
    final geofences = await getGeofences();
    geofences.removeWhere((g) => g.id == geofenceId);
    await saveGeofences(geofences);
  }

  // Attendance management
  static Future<void> saveAttendanceHistory(List<AttendanceModel> attendance) async {
    final prefs = await SharedPreferences.getInstance();
    final attendanceJson = attendance.map((a) => a.toJson()).toList();
    await prefs.setString(_attendanceKey, jsonEncode(attendanceJson));
  }

  static Future<List<AttendanceModel>> getAttendanceHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final attendanceData = prefs.getString(_attendanceKey);
    if (attendanceData != null) {
      final List<dynamic> attendanceList = jsonDecode(attendanceData);
      return attendanceList.map((a) => AttendanceModel.fromJson(a)).toList();
    }
    return [];
  }

  static Future<void> addAttendanceRecord(AttendanceModel record) async {
    final attendance = await getAttendanceHistory();
    attendance.add(record);
    await saveAttendanceHistory(attendance);
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}