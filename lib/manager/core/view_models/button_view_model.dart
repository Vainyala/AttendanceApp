import 'package:attendanceapp/manager/core/view_models/theme_view_model.dart';
import 'package:flutter/material.dart';

class ButtonState with ChangeNotifier {
  bool _isLoading = false;
  bool _isDisabled = false;

  bool get isLoading => _isLoading;
  bool get isDisabled => _isDisabled;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setDisabled(bool disabled) {
    _isDisabled = disabled;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _isDisabled = false;
    notifyListeners();
  }
}

class AppButtonStyles {
  // Primary Button Style
  static ButtonStyle primary(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 4,
      shadowColor: AppColors.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minimumSize: const Size(double.infinity, 56),
    );
  }

  // Secondary Button Style
  static ButtonStyle secondary(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.primary,
      elevation: 2,
      shadowColor: AppColors.grey300,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.primary),
      ),
      minimumSize: const Size(double.infinity, 56),
    );
  }

  // Outline Button Style
  static ButtonStyle outline(BuildContext context) {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      backgroundColor: Colors.transparent,
      side: const BorderSide(color: AppColors.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minimumSize: const Size(double.infinity, 56),
    );
  }

  // Text Button Style
  static ButtonStyle text(BuildContext context) {
    return TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      minimumSize: const Size(64, 48),
    );
  }

  // Disabled Button Style
  static ButtonStyle disabled(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.grey400,
      foregroundColor: AppColors.grey600,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minimumSize: const Size(double.infinity, 56),
    );
  }

  // Success Button Style
  static ButtonStyle success(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.success,
      foregroundColor: AppColors.white,
      elevation: 4,
      shadowColor: AppColors.success.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minimumSize: const Size(double.infinity, 56),
    );
  }

  // Error Button Style
  static ButtonStyle error(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.error,
      foregroundColor: AppColors.white,
      elevation: 4,
      shadowColor: AppColors.error.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minimumSize: const Size(double.infinity, 56),
    );
  }

  // Small Button Style
  static ButtonStyle small(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      minimumSize: const Size(80, 40),
    );
  }
}
