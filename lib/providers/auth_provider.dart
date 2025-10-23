import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  bool _isLoading = false;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _currentUser;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  // Initialize auth state
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _currentUser = await _authService.getCurrentUser();
        _isAuthenticated = _currentUser != null;
      }
    } catch (e) {
      _errorMessage = 'Initialization error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login method
  Future<String?> login(String countryCode, String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(countryCode, phone, password);

      if (result['success']) {
        _currentUser = result['user'];
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return null; // Success
      } else {
        _errorMessage = result['error'];
        _isLoading = false;
        notifyListeners();
        return result['error'];
      }
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return _errorMessage;
    }
  }

  // Logout method
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _isAuthenticated = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Logout error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    try {
      _currentUser = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error refreshing user data: ${e.toString()}';
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      if (_currentUser == null) return false;

      final userId = _currentUser!['user_id'];
      userData['updated_at'] = DateTime.now().toIso8601String();

      await _dbHelper.updateUser(userId, userData);
      await refreshUserData();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating profile: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}