import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AppColors {
  // Primary Colors
  static const primaryBlue = Color(0xFF4A90E2);
  static const textDark = Colors.black87;
  static const textLight = Colors.white;
  static const background = Color(0xFFF5F5F5);
  static const primaryLight = Color(0xFF6BA4EC);
  static const primaryDark = Color(0xFF2171C9);
  // Background Colors
  static const white = Colors.white54;
  static const cardBackground = Colors.white70;

  // Text Colors
  static const textPrimary = Colors.black87;
  static const textSecondary = Colors.black54;
  static const textHint = Colors.grey;

  // Status Colors
  static const success = Colors.green;
  static const error = Colors.red;
  static const warning = Colors.orange;
  static const info = Colors.blue;

  // Border Colors
  static Color borderLight = AppColors.textHint.shade300;
  static Color borderMedium = AppColors.textHint.shade400;

  // Shadow Colors
  static Color shadowColor = Colors.black.withOpacity(0.05);
  static Color shadowColorDark = Colors.black.withOpacity(0.1);

  // Other Colors
  static Color greyLight = AppColors.textHint.shade50;
  static Color greyMedium = AppColors.textHint.shade100;
  static Color greyDark = AppColors.textHint.shade600;

  // Leave Type Colors (for pie chart)
  static const sickLeave = Color(0xFFE57373);
  static const casualLeave = Color(0xFF64B5F6);
  static const earnedLeave = Color(0xFF81C784);
  static const unpaidLeave = Color(0xFFFFD54F);

  // Gray Shades
  static const grey50 = Color(0xFFFAFAFA);
  static const grey100 = Color(0xFFF5F5F5);
  static const grey200 = Color(0xFFEEEEEE);
  static const grey300 = Color(0xFFE0E0E0);
  static const grey400 = Color(0xFFBDBDBD);
  static const grey600 = Color(0xFF757575);
  static const grey700 = Color(0xFF616161);

  // Additional Colors (add as needed)
  static const divider = Color(0xFFE0E0E0);

  // Private constructor to prevent instantiation
  AppColors._();

  // Additional colors for reuse
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFFA500);
  static const Color errorRed = Color(0xFFFF5252);
  static const Color gradientStart = Color(0xFFFF8C00);
  static const Color gradientEnd = Color(0xFFFF6347);
}
