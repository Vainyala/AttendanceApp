import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CommonState with ChangeNotifier {
  bool _isLoading = false;
  String _loadingText = 'Loading...';
  String _errorMessage = '';
  bool _hasError = false;

  bool get isLoading => _isLoading;
  String get loadingText => _loadingText;
  String get errorMessage => _errorMessage;
  bool get hasError => _hasError;

  void setLoading(bool loading, {String text = 'Loading...'}) {
    _isLoading = loading;
    _loadingText = text;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    _hasError = true;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    _hasError = false;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _loadingText = 'Loading...';
    _errorMessage = '';
    _hasError = false;
    notifyListeners();
  }
}

class AppConstants {
  // App Constants
  static const String appName = 'Nutantek Attendance';
  static const String appVersion = '1.0.0';
  static const String companyName = 'Nutantek Solutions';
  static const String copyrightText = '© 2024 Nutantek. All rights reserved.';

  // API Constants
  static const String baseUrl = 'https://api.nutantek.com';
  static const int apiTimeout = 30000;
  static const int maxRetryAttempts = 3;

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeModeKey = 'theme_mode';
  static const String languageKey = 'app_language';

  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd MMM yyyy, HH:mm';
}

class AppValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password must be less than ${AppConstants.maxPasswordLength} characters';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < AppConstants.minNameLength) {
      return 'Name must be at least ${AppConstants.minNameLength} characters';
    }

    if (value.length > AppConstants.maxNameLength) {
      return 'Name must be less than ${AppConstants.maxNameLength} characters';
    }

    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^[0-9]{10}$');

    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number';
    }

    return null;
  }
}
