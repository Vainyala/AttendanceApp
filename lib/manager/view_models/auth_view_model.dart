
import 'package:flutter/material.dart';
import '../core/view_models/theme_view_model.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../database/database_helper.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../services/geofencing_service.dart';

class AuthViewModel with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final GeofencingService _geofencingService = GeofencingService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isLoading = false;
  String _errorMessage = '';
  User? _currentUser;
  Map<String, dynamic>? _locationData;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  Map<String, dynamic>? get locationData => _locationData;

  // Password hashing method - DatabaseHelper ke same
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    _locationData = null;
    notifyListeners();

    try {
      print('🔐 Login attempt: $email');

      // Direct database login (temporary fix)
      final user = await _dbHelper.getUserByEmail(email);

      if (user != null) {
        print('✅ User found: ${user.email}');

        // Password verification
        final inputHash = _hashPassword(password);
        print('🔑 Input hash: $inputHash');
        print('🔑 Stored hash: ${user.password}');

        if (user.password == inputHash) {
          _currentUser = user;
          _errorMessage = '';
          _isLoading = false;

          // Get location data
          try {
            _locationData = await _geofencingService.checkAllowedLocation();
          } catch (e) {
            print('⚠️ Location check failed: $e');
            _locationData = {
              'allowed': true,
              'city': 'Unknown',
            }; // Default allow
          }

          notifyListeners();

          print('🎉 Login successful for: ${user.name}');
          return true;
        } else {
          print('❌ Password mismatch');
          _errorMessage = 'Invalid email or password';
        }
      } else {
        print('❌ User not found');
        _errorMessage = 'Invalid email or password';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Login failed: ${e.toString()}';
      notifyListeners();
      print('❌ Login error: $e');
      return false;
    }
  }

  // ✅ ADD THIS MISSING METHOD
  Future<List<User>> getAvailableUsers() async {
    try {
      print('📋 Getting all available users...');

      // Get users by type
      final employees = await _dbHelper.getUsersByType('employee');
      final managers = await _dbHelper.getUsersByType('manager');
      final hr = await _dbHelper.getUsersByType('hr');
      final finance = await _dbHelper.getUsersByType('finance_manager');

      // Combine all users
      final allUsers = [...employees, ...managers, ...hr, ...finance];

      print('✅ Found ${allUsers.length} users total');
      print('   Employees: ${employees.length}');
      print('   Managers: ${managers.length}');
      print('   HR: ${hr.length}');
      print('   Finance: ${finance.length}');

      return allUsers;
    } catch (e) {
      print('❌ Error getting available users: $e');
      return [];
    }
  }

  // Emergency method for testing
  Future<void> resetDatabase() async {
    await _dbHelper.resetDatabase();
    print('✅ Database reset complete');
  }

  // Emergency login bypass
  void emergencyLogin(String userType) {
    _currentUser = User(
      email: 'test@nutantek.com',
      userType: userType,
      name: 'Test User',
      createdAt: DateTime.now(),
      password: 'test',
    );
    _locationData = {'allowed': true, 'city': 'Test City'};
    _errorMessage = '';
    notifyListeners();
    print('🚀 Emergency login activated for: $userType');
  }

  // Navigate to appropriate dashboard based on user type
  void navigateToDashboard(BuildContext context) {
    if (_currentUser != null) {
      switch (_currentUser!.userType) {
        case 'manager':
          Navigator.pushReplacementNamed(context, '/manager_dashboard');
          break;
        case 'hr':
          Navigator.pushReplacementNamed(context, '/hr_dashboard');
          break;
        case 'finance_manager':
          Navigator.pushReplacementNamed(context, '/finance_dashboard');
          break;
        case 'employee':
        default:
          Navigator.pushReplacementNamed(context, '/employee_dashboard');
          break;
      }
    }
  }

  void _showComingSoonSnackbar(BuildContext context, String dashboardName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$dashboardName - Coming Soon!'),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Check location only (for pre-check)
  Future<Map<String, dynamic>> checkLocation() async {
    return await _geofencingService.checkAllowedLocation();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  List<String> getAllowedCities() {
    return GeofencingService.getAllowedCities();
  }

  // Test all logins
  Future<void> testAllLogins() async {
    await _dbHelper.testAllLogins();
  }
  // ---------------------------------------------------------
  // ⭐ REQUIRED FOR TEST LOGIN (manager1 / vainyala)
  // ---------------------------------------------------------
  void setCurrentUser({required String email, required String role}) {
    _currentUser = User(
      email: email,
      userType: role.toLowerCase(),       // manager / employee
      name: email.split('@').first,       // simple name
      createdAt: DateTime.now(),
      password: 'test',                   // not used for test login
    );

    _locationData = {
      'allowed': true,
      'city': 'Test City',
    };  // Allow access for test logins

    notifyListeners();

    print("🎉 Test login active for: $email ($role)");
  }

}
