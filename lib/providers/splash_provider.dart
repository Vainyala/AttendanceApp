//splashscreen, login and forgot password screen provider is their into this file

import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../models/user_model.dart';

class SplashProvider with ChangeNotifier {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isLoadingUser = false;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  UserModel? _user;
  bool _isSendingReset = false;
  bool get isSendingReset => _isSendingReset;

  Future<void> checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    final user = await StorageService.getUser();
    _isLoggedIn = user != null;
    _isLoading = false;
    notifyListeners();
  }
  Future<String?> sendResetLink(String email) async {
    _isSendingReset = true;
    notifyListeners();

    try {
      // Simulate API call / email sending
      await Future.delayed(const Duration(seconds: 2));

      // Dummy check
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        return 'Invalid email';
      }

      // Here, you can call actual backend to send reset email
      return null; // success
    } catch (e) {
      return 'Failed to send reset link: $e';
    } finally {
      _isSendingReset = false;
      notifyListeners();
    }
  }
// Handle Login
  Future<String?> login(String countryCode, String phone, String password) async {
    _isLoadingUser = true;
    notifyListeners();

    try {
      // 🧠 Simulate backend login check
      await Future.delayed(const Duration(seconds: 2)); // simulate API delay

      // Simple dummy login condition
      if (phone == "9999999999" && password == "123456") {
        // Dummy successful login
        _user = UserModel(
          id: 'U001',
          name: 'Samal Vainyala',
          email: 'samal@nutantek.com',
          role: 'Flutter Developer',
          projects: [],
        );

        await StorageService.saveUser(_user!); // optional, if you want persistence
        return null; // no error = success
      } else {
        return "Invalid phone or password";
      }
    } catch (e) {
      return "Login failed: $e";
    } finally {
      _isLoadingUser = false;
      notifyListeners();
    }
  }
}
