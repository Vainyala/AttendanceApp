import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized text style definitions for the entire app
/// Usage: Text('Hello', style: AppStyles.heading)
class AppStyles {

  // regularisation screen
  // Headings
  static const heading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
static const id = TextStyle(
  fontSize: 14,
  color: Colors.white70,
);
  static const headingLarge1 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const headingSmall1 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  // Labels
  static const label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const labelSmall1 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.grey600,
  );

  // Body Text
  static const text = TextStyle(
    fontSize: 14,
    color: AppColors.grey600,
  );

  static const textMedium = TextStyle(
    fontSize: 16,
    color: AppColors.textDark,
  );

  // Button Text
  static const buttonText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );

  static const buttonTextSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );

  // Caption
  static const captions = TextStyle(
    fontSize: 12,
    color: AppColors.grey600,
    fontWeight: FontWeight.w500
  );


//dashboard screen
  static const text1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight,
  );
//time
  static const time = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryBlue,
  );
  static const description = TextStyle(
    fontSize: 15,
    color: Colors.black87,
    height: 1.5,
  );
  static const name =TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight,
  );
  // Private constructor to prevent instantiation
  AppStyles._();

  // Heading Styles
  static const headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body Text Styles
  static const bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const bodySmall = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static const caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  // Label Styles
  static const labelMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const labelSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Button Text Styles
  static const buttonTextMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryBlue,
  );

  // Badge/Chip Text Styles
  static const chipText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  // Hint Text Style
  static TextStyle hintText = TextStyle(
    color: AppColors.textHint,
    fontSize: 14,
  );

  // Border Radius
  static BorderRadius radiusSmall = BorderRadius.circular(4);
  static BorderRadius radiusMedium = BorderRadius.circular(8);
  static BorderRadius radiusLarge = BorderRadius.circular(12);
  static BorderRadius radiusXLarge = BorderRadius.circular(20);

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> cardShadowMedium = [
    BoxShadow(
      color: AppColors.shadowColorDark,
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  // Input Decoration
  static InputDecoration getInputDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppStyles.hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.greyLight,
      border: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: BorderSide(
          color: AppColors.primaryBlue,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}