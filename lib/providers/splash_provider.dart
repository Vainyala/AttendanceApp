import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/storage_service.dart';
import '../models/user_model.dart';

class SplashProvider with ChangeNotifier {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isLoadingUser = false;
  bool _isSendingReset = false;
  bool isFirstLaunch = true;

  UserModel? _user;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get isSendingReset => _isSendingReset;

  // In splash_provider.dart - Replace checkLoginStatus method

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ Check if email verification is completed
    final emailVerified = prefs.getBool('emailVerified') ?? false;

    // ✅ Check if logged in
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // ✅ First launch = email NOT verified yet
    isFirstLaunch = !emailVerified;

    await Future.delayed(const Duration(seconds: 2));
    _isLoading = false;
    notifyListeners();
  }

  // ✅ 2️⃣ Forgot password flow — sending reset link
  Future<String?> sendResetLink(String email) async {
    _isSendingReset = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      // Basic email validation
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        return 'Invalid email address';
      }

      // In a real app → call backend API to send reset email
      return null; // success
    } catch (e) {
      return 'Failed to send reset link: $e';
    } finally {
      _isSendingReset = false;
      notifyListeners();
    }
  }

  // ✅ 3️⃣ Login logic
  Future<String?> login(String countryCode, String phone, String password) async {
    _isLoadingUser = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2)); // simulate API call

      if (phone == "9999999999" && password == "123456") {
        // Dummy successful login
        _user = UserModel(
          id: 'U001',
          name: 'Samal Vainyala',
          email: 'samal@nutantek.com',
          role: 'Flutter Developer',
          department: 'App Development dept.',
          projects: [],
        );

        await StorageService.saveUser(_user!);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true); // ✅ mark logged in

        return null; // success
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

  // ✅ Optional: logout (you can call this from profile/settings)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    _user = null;
    notifyListeners();
  }
}
