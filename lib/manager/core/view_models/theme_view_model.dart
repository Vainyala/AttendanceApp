import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  // Professional Color Palette
  static const Color primary = Color(0xFF2563EB); // Professional blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF3B82F6);

  static const Color secondary = Color(0xFF7C3AED); // Professional purple
  static const Color secondaryDark = Color(0xFF6D28D9);
  static const Color secondaryLight = Color(0xFF8B5CF6);

  static const Color accent = Color(0xFF059669); // Professional green
  static const Color accentDark = Color(0xFF047857);
  static const Color accentLight = Color(0xFF10B981);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color backgroundDark = Color(0xFF111827);

  // Surface Colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF3F4F6);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color surfaceVariantDark = Color(0xFF374151);

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);
  static const Color textInverse = Color(0xFFFFFFFF);
}

class AppTheme with ChangeNotifier {
  static const String _themePreferenceKey = 'theme_preference';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  AppTheme() {
    _loadThemePreference();
  }

  // Current theme mode ko string mein get karein
  String get themeModeString {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'auto';
    }
  }

  // System theme ke according actual theme check karne ke liye
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  // SharedPreferences se theme load karein
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themePreferenceKey) ?? 'auto';

      switch (savedTheme) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'auto':
        default:
          _themeMode = ThemeMode.system;
          break;
      }
      notifyListeners();
    } catch (e) {
      print('Error loading theme preference: $e');
    }
  }

  // SharedPreferences mein theme save karein
  Future<void> _saveThemePreference(String theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePreferenceKey, theme);
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();

    // Save preference
    switch (mode) {
      case ThemeMode.light:
        _saveThemePreference('light');
        break;
      case ThemeMode.dark:
        _saveThemePreference('dark');
        break;
      case ThemeMode.system:
        _saveThemePreference('auto');
        break;
    }
  }

  void setLightTheme() {
    setThemeMode(ThemeMode.light);
  }

  void setDarkTheme() {
    setThemeMode(ThemeMode.dark);
  }

  void setAutoTheme() {
    setThemeMode(ThemeMode.system);
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.system);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }

  // Light Theme - Professional & Clean
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.surfaceLight,
        background: AppColors.backgroundLight,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: AppColors.white,
      ),

      // Scaffold & App Background
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.textDisabled,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textDisabled),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.grey200,
        thickness: 1,
        space: 1,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.grey100,
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        secondaryLabelStyle: const TextStyle(color: AppColors.white),
        brightness: Brightness.light,
      ),
    );
  }

  // Dark Theme - Professional & Clean
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        primaryContainer: AppColors.primary,
        secondary: AppColors.secondaryLight,
        secondaryContainer: AppColors.secondary,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textInverse,
        onBackground: AppColors.textInverse,
        onError: AppColors.white,
      ),

      // Scaffold & App Background
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textInverse,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textInverse),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textInverse,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textInverse,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textInverse,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textInverse,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textInverse,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textInverse,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textInverse,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textInverse,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.grey400,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.grey500,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey700),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        labelStyle: const TextStyle(color: AppColors.grey400),
        hintStyle: const TextStyle(color: AppColors.grey500),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.grey700,
        thickness: 1,
        space: 1,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.white,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.grey800,
        selectedColor: AppColors.primaryLight,
        labelStyle: const TextStyle(color: AppColors.textInverse),
        secondaryLabelStyle: const TextStyle(color: AppColors.white),
        brightness: Brightness.dark,
      ),
    );
  }
}

// Helper Extension for Easy Theme Access
extension ThemeHelper on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get surfaceColor =>
      isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight;

  Color get textColor =>
      isDarkMode ? AppColors.textInverse : AppColors.textPrimary;

  Color get backgroundColor =>
      isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight;
}

// import 'package:flutter/material.dart';

// class AppColors {
//   // Professional Color Palette
//   static const Color primary = Color(0xFF2563EB); // Professional blue
//   static const Color primaryDark = Color(0xFF1D4ED8);
//   static const Color primaryLight = Color(0xFF3B82F6);

//   static const Color secondary = Color(0xFF7C3AED); // Professional purple
//   static const Color secondaryDark = Color(0xFF6D28D9);
//   static const Color secondaryLight = Color(0xFF8B5CF6);

//   static const Color accent = Color(0xFF059669); // Professional green
//   static const Color accentDark = Color(0xFF047857);
//   static const Color accentLight = Color(0xFF10B981);

//   // Neutral Colors
//   static const Color white = Color(0xFFFFFFFF);
//   static const Color black = Color(0xFF000000);
//   static const Color grey50 = Color(0xFFF9FAFB);
//   static const Color grey100 = Color(0xFFF3F4F6);
//   static const Color grey200 = Color(0xFFE5E7EB);
//   static const Color grey300 = Color(0xFFD1D5DB);
//   static const Color grey400 = Color(0xFF9CA3AF);
//   static const Color grey500 = Color(0xFF6B7280);
//   static const Color grey600 = Color(0xFF4B5563);
//   static const Color grey700 = Color(0xFF374151);
//   static const Color grey800 = Color(0xFF1F2937);
//   static const Color grey900 = Color(0xFF111827);

//   // Semantic Colors
//   static const Color success = Color(0xFF10B981);
//   static const Color warning = Color(0xFFF59E0B);
//   static const Color error = Color(0xFFEF4444);
//   static const Color info = Color(0xFF3B82F6);

//   // Background Colors
//   static const Color backgroundLight = Color(0xFFF9FAFB);
//   static const Color backgroundDark = Color(0xFF111827);

//   // Text Colors
//   static const Color textPrimary = Color(0xFF111827);
//   static const Color textSecondary = Color(0xFF6B7280);
//   static const Color textDisabled = Color(0xFF9CA3AF);
//   static const Color textInverse = Color(0xFFFFFFFF);
// }

// class AppTheme with ChangeNotifier {
//   ThemeMode _themeMode = ThemeMode.light;

//   ThemeMode get themeMode => _themeMode;

//   void setThemeMode(ThemeMode mode) {
//     _themeMode = mode;
//     notifyListeners();
//   }

//   void toggleTheme() {
//     _themeMode = _themeMode == ThemeMode.light
//         ? ThemeMode.dark
//         : ThemeMode.light;
//     notifyListeners();
//   }

//   // Light Theme - Professional & Clean
//   static ThemeData get lightTheme {
//     return ThemeData(
//       useMaterial3: true,
//       brightness: Brightness.light,
//       primaryColor: AppColors.primary,
//       scaffoldBackgroundColor: AppColors.backgroundLight,
//       appBarTheme: const AppBarTheme(
//         backgroundColor: AppColors.white,
//         foregroundColor: AppColors.textPrimary,
//         elevation: 1,
//         centerTitle: true,
//         iconTheme: IconThemeData(color: AppColors.textPrimary),
//         titleTextStyle: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textPrimary,
//         ),
//       ),
//       textTheme: const TextTheme(
//         displayLarge: TextStyle(
//           fontSize: 32,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textPrimary,
//         ),
//         displayMedium: TextStyle(
//           fontSize: 28,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textPrimary,
//         ),
//         displaySmall: TextStyle(
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textPrimary,
//         ),
//         headlineMedium: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textPrimary,
//         ),
//         headlineSmall: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textPrimary,
//         ),
//         titleLarge: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textPrimary,
//         ),
//         bodyLarge: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.normal,
//           color: AppColors.textPrimary,
//         ),
//         bodyMedium: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.normal,
//           color: AppColors.textSecondary,
//         ),
//         bodySmall: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.normal,
//           color: AppColors.textDisabled,
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: AppColors.grey300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: AppColors.primary, width: 2),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: AppColors.grey300),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: AppColors.error),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: AppColors.error, width: 2),
//         ),
//         filled: true,
//         fillColor: AppColors.white,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 12,
//         ),
//         labelStyle: const TextStyle(color: AppColors.textSecondary),
//         hintStyle: const TextStyle(color: AppColors.textDisabled),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primary,
//           foregroundColor: AppColors.white,
//           elevation: 0,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//       ),
//       textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(
//           foregroundColor: AppColors.primary,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//         ),
//       ),
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: AppColors.primary,
//           side: const BorderSide(color: AppColors.primary),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//       ),
//       dividerTheme: const DividerThemeData(
//         color: AppColors.grey200,
//         thickness: 1,
//         space: 1,
//       ),
//       floatingActionButtonTheme: const FloatingActionButtonThemeData(
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.white,
//       ),
//     );
//   }

//   // Dark Theme - Professional & Clean
//   static ThemeData get darkTheme {
//     return ThemeData(
//       useMaterial3: true,
//       brightness: Brightness.dark,
//       primaryColor: AppColors.primaryLight,
//       scaffoldBackgroundColor: AppColors.backgroundDark,
//       appBarTheme: const AppBarTheme(
//         backgroundColor: AppColors.grey900,
//         foregroundColor: AppColors.textInverse,
//         elevation: 1,
//         centerTitle: true,
//         iconTheme: IconThemeData(color: AppColors.textInverse),
//         titleTextStyle: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textInverse,
//         ),
//       ),
//       textTheme: const TextTheme(
//         displayLarge: TextStyle(
//           fontSize: 32,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textInverse,
//         ),
//         displayMedium: TextStyle(
//           fontSize: 28,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textInverse,
//         ),
//         displaySmall: TextStyle(
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textInverse,
//         ),
//         headlineMedium: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textInverse,
//         ),
//         headlineSmall: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textInverse,
//         ),
//         titleLarge: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textInverse,
//         ),
//         bodyLarge: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.normal,
//           color: AppColors.textInverse,
//         ),
//         bodyMedium: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.normal,
//           color: AppColors.grey400,
//         ),
//         bodySmall: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.normal,
//           color: AppColors.grey500,
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: AppColors.grey700),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: AppColors.grey700),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: AppColors.error),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: AppColors.error, width: 2),
//         ),
//         filled: true,
//         fillColor: AppColors.grey800,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 12,
//         ),
//         labelStyle: const TextStyle(color: AppColors.grey400),
//         hintStyle: const TextStyle(color: AppColors.grey500),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primaryLight,
//           foregroundColor: AppColors.white,
//           elevation: 0,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//       ),
//       textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(
//           foregroundColor: AppColors.primaryLight,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//         ),
//       ),
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: AppColors.primaryLight,
//           side: const BorderSide(color: AppColors.primaryLight),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//       ),
//       dividerTheme: const DividerThemeData(
//         color: AppColors.grey700,
//         thickness: 1,
//         space: 1,
//       ),
//       floatingActionButtonTheme: const FloatingActionButtonThemeData(
//         backgroundColor: AppColors.primaryLight,
//         foregroundColor: AppColors.white,
//       ),
//     );
//   }
// }

//  #####################################   A D V A N C E D C O L O R T H E M E S    ##############################################
//  #####################################   A D V A N C E D C O L O R T H E M E S    ##############################################
//  #####################################   A D V A N C E D C O L O R T H E M E S    ##############################################
//  #####################################   A D V A N C E D C O L O R T H E M E S    ##############################################
//  #####################################   A D V A N C E D C O L O R T H E M E S    ##############################################

// import 'package:flutter/material.dart';

// class AppColors {
//   // Primary Colors
//   static const Color primary = Color(0xFF667eea);
//   static const Color primaryDark = Color(0xFF5a6fd8);
//   static const Color primaryLight = Color(0xFF8a9ef0);

//   // Secondary Colors
//   static const Color secondary = Color(0xFF764ba2);
//   static const Color secondaryDark = Color(0xFF684190);
//   static const Color secondaryLight = Color(0xFF8a65b4);

//   // Gradient Colors
//   static const List<Color> gradientColors = [
//     Color(0xFF667eea),
//     Color(0xFF764ba2),
//     Color(0xFFf093fb),
//   ];

//   // Neutral Colors
//   static const Color white = Color(0xFFFFFFFF);
//   static const Color black = Color(0xFF000000);
//   static const Color grey100 = Color(0xFFF5F5F5);
//   static const Color grey200 = Color(0xFFEEEEEE);
//   static const Color grey300 = Color(0xFFE0E0E0);
//   static const Color grey400 = Color(0xFFBDBDBD);
//   static const Color grey500 = Color(0xFF9E9E9E);
//   static const Color grey600 = Color(0xFF757575);
//   static const Color grey700 = Color(0xFF616161);
//   static const Color grey800 = Color(0xFF424242);
//   static const Color grey900 = Color(0xFF212121);

//   // Semantic Colors
//   static const Color success = Color(0xFF4CAF50);
//   static const Color warning = Color(0xFFFF9800);
//   static const Color error = Color(0xFFF44336);
//   static const Color info = Color(0xFF2196F3);

//   // Background Colors
//   static const Color backgroundLight = Color(0xFFFAFAFA);
//   static const Color backgroundDark = Color(0xFF121212);

//   // Text Colors
//   static const Color textPrimary = Color(0xFF212121);
//   static const Color textSecondary = Color(0xFF757575);
//   static const Color textDisabled = Color(0xFF9E9E9E);
//   static const Color textInverse = Color(0xFFFFFFFF);
// }

// // 🆕 NEW AI COLOR VARIANTS - Original code unchanged
// class AIColorVariants {
//   // 🧠 Cyber Futuristic Variant
//   static const Color cyberPrimary = Color(0xFF00D4FF);
//   static const Color cyberSecondary = Color(0xFF7B42FF);
//   static const Color cyberAccent = Color(0xFF00FF88);
//   static const Color cyberWarning = Color(0xFFFF6B35);
//   static const Color cyberError = Color(0xFFFF0080);

//   static const List<Color> cyberGradient = [
//     Color(0xFF0066FF),
//     Color(0xFF00D4FF),
//     Color(0xFF7B42FF),
//   ];

//   static const Color cyberBackgroundDark = Color(0xFF0A0F2D);
//   static const Color cyberCardDark = Color(0xFF1E1E2E);

//   // ⚡ Neural Network Variant
//   static const Color neuralPrimary = Color(0xFF00B4FF);
//   static const Color neuralSecondary = Color(0xFF8A2BE2);
//   static const Color neuralAccent = Color(0xFF00FF7F);
//   static const Color neuralWarning = Color(0xFFFF6B35);
//   static const Color neuralError = Color(0xFFFF1493);

//   static const List<Color> neuralGradient = [
//     Color(0xFF00B4FF),
//     Color(0xFF8A2BE2),
//     Color(0xFFFF1493),
//   ];

//   static const Color neuralBackgroundDark = Color(0xFF1A0F2D);
//   static const Color neuralCardDark = Color(0xFF2D1B48);

//   // 🌌 Quantum Computing Variant
//   static const Color quantumPrimary = Color(0xFF00FFFF);
//   static const Color quantumSecondary = Color(0xFF9D00FF);
//   static const Color quantumAccent = Color(0xFF00FFAA);
//   static const Color quantumWarning = Color(0xFFFF7700);
//   static const Color quantumError = Color(0xFFFF00AA);

//   static const List<Color> quantumGradient = [
//     Color(0xFF00FFFF),
//     Color(0xFF9D00FF),
//     Color(0xFFFF00AA),
//   ];

//   static const Color quantumBackgroundDark = Color(0xFF000814);
//   static const Color quantumCardDark = Color(0xFF1A1A2E);

//   // 📊 Data Science Variant
//   static const Color dataPrimary = Color(0xFF0080FF);
//   static const Color dataSecondary = Color(0xFF6A0DAD);
//   static const Color dataAccent = Color(0xFF00CC66);
//   static const Color dataWarning = Color(0xFFFF6600);
//   static const Color dataError = Color(0xFFFF0066);

//   static const List<Color> dataGradient = [
//     Color(0xFF0080FF),
//     Color(0xFF6A0DAD),
//     Color(0xFF00CC66),
//   ];

//   static const Color dataBackgroundDark = Color(0xFF0F141F);
//   static const Color dataCardDark = Color(0xFF1E2432);

//   // 🎯 Matrix Green Variant
//   static const Color matrixPrimary = Color(0xFF00FF41);
//   static const Color matrixSecondary = Color(0xFF00D4AA);
//   static const Color matrixAccent = Color(0xFF00FF88);
//   static const Color matrixWarning = Color(0xFFFFAA00);
//   static const Color matrixError = Color(0xFFFF0066);

//   static const List<Color> matrixGradient = [
//     Color(0xFF00FF41),
//     Color(0xFF00D4AA),
//     Color(0xFF0080FF),
//   ];

//   static const Color matrixBackgroundDark = Color(0xFF001100);
//   static const Color matrixCardDark = Color(0xFF003300);

//   // 🚀 Holographic Variant
//   static const Color holoPrimary = Color(0xFF00F5FF);
//   static const Color holoSecondary = Color(0xFFB300FF);
//   static const Color holoAccent = Color(0xFF00FFD1);
//   static const Color holoWarning = Color(0xFFFF8C00);
//   static const Color holoError = Color(0xFFFF0055);

//   static const List<Color> holoGradient = [
//     Color(0xFF00F5FF),
//     Color(0xFFB300FF),
//     Color(0xFFFF00AA),
//   ];

//   static const Color holoBackgroundDark = Color(0xFF0A0A1A);
//   static const Color holoCardDark = Color(0xFF1A1A2E);
// }

// // 🆕 AI Theme Variants Manager
// class AIThemeManager {
//   // Get specific AI color variant
//   static AIColorVariant getVariant(AIThemeVariant variant) {
//     switch (variant) {
//       case AIThemeVariant.cyber:
//         return AIColorVariant(
//           primary: AIColorVariants.cyberPrimary,
//           secondary: AIColorVariants.cyberSecondary,
//           accent: AIColorVariants.cyberAccent,
//           warning: AIColorVariants.cyberWarning,
//           error: AIColorVariants.cyberError,
//           gradient: AIColorVariants.cyberGradient,
//           backgroundDark: AIColorVariants.cyberBackgroundDark,
//           cardDark: AIColorVariants.cyberCardDark,
//         );
//       case AIThemeVariant.neural:
//         return AIColorVariant(
//           primary: AIColorVariants.neuralPrimary,
//           secondary: AIColorVariants.neuralSecondary,
//           accent: AIColorVariants.neuralAccent,
//           warning: AIColorVariants.neuralWarning,
//           error: AIColorVariants.neuralError,
//           gradient: AIColorVariants.neuralGradient,
//           backgroundDark: AIColorVariants.neuralBackgroundDark,
//           cardDark: AIColorVariants.neuralCardDark,
//         );
//       case AIThemeVariant.quantum:
//         return AIColorVariant(
//           primary: AIColorVariants.quantumPrimary,
//           secondary: AIColorVariants.quantumSecondary,
//           accent: AIColorVariants.quantumAccent,
//           warning: AIColorVariants.quantumWarning,
//           error: AIColorVariants.quantumError,
//           gradient: AIColorVariants.quantumGradient,
//           backgroundDark: AIColorVariants.quantumBackgroundDark,
//           cardDark: AIColorVariants.quantumCardDark,
//         );
//       case AIThemeVariant.data:
//         return AIColorVariant(
//           primary: AIColorVariants.dataPrimary,
//           secondary: AIColorVariants.dataSecondary,
//           accent: AIColorVariants.dataAccent,
//           warning: AIColorVariants.dataWarning,
//           error: AIColorVariants.dataError,
//           gradient: AIColorVariants.dataGradient,
//           backgroundDark: AIColorVariants.dataBackgroundDark,
//           cardDark: AIColorVariants.dataCardDark,
//         );
//       case AIThemeVariant.matrix:
//         return AIColorVariant(
//           primary: AIColorVariants.matrixPrimary,
//           secondary: AIColorVariants.matrixSecondary,
//           accent: AIColorVariants.matrixAccent,
//           warning: AIColorVariants.matrixWarning,
//           error: AIColorVariants.matrixError,
//           gradient: AIColorVariants.matrixGradient,
//           backgroundDark: AIColorVariants.matrixBackgroundDark,
//           cardDark: AIColorVariants.matrixCardDark,
//         );
//       case AIThemeVariant.holographic:
//         return AIColorVariant(
//           primary: AIColorVariants.holoPrimary,
//           secondary: AIColorVariants.holoSecondary,
//           accent: AIColorVariants.holoAccent,
//           warning: AIColorVariants.holoWarning,
//           error: AIColorVariants.holoError,
//           gradient: AIColorVariants.holoGradient,
//           backgroundDark: AIColorVariants.holoBackgroundDark,
//           cardDark: AIColorVariants.holoCardDark,
//         );
//     }
//   }
// }

// class GradientThemes {
//   const GradientThemes();

//   // Radial Gradients
//   RadialGradient get cyberRadialBackground => const RadialGradient(
//     center: Alignment.topLeft,
//     radius: 2.0,
//     colors: [
//       Color(0xFF6366F1), // primary
//       Color(0xFF8B5CF6), // secondary
//       Color(0xFF0F0F1A), // background
//     ],
//     stops: [0.0, 0.5, 1.0],
//   );

//   RadialGradient get cyberRadialBackgroundWithOpacity => RadialGradient(
//     center: Alignment.topLeft,
//     radius: 2.0,
//     colors: [
//       QuickAIColors.cyber.primary.withOpacity(0.3),
//       QuickAIColors.cyber.secondary.withOpacity(0.2),
//       Colors.black,
//     ],
//     stops: const [0.0, 0.5, 1.0],
//   );

//   // Linear Gradients
//   LinearGradient get cyberLinearVertical => const LinearGradient(
//     begin: Alignment.topCenter,
//     end: Alignment.bottomCenter,
//     colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFF0F0F1A)],
//   );

//   LinearGradient get cyberLinearHorizontal => const LinearGradient(
//     begin: Alignment.centerLeft,
//     end: Alignment.centerRight,
//     colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//   );

//   LinearGradient get cyberLinearDiagonal => const LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFF06D6A0)],
//   );

//   // Card Gradients
//   LinearGradient get cyberCardGradient => LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [
//       QuickAIColors.cyber.primary.withOpacity(0.8),
//       QuickAIColors.cyber.secondary.withOpacity(0.6),
//     ],
//   );

//   // Button Gradients
//   LinearGradient get cyberButtonGradient => const LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//   );

//   // Special Effect Gradients
//   RadialGradient get cyberNeuralGlow => RadialGradient(
//     center: Alignment.center,
//     radius: 1.5,
//     colors: [
//       QuickAIColors.cyber.accent.withOpacity(0.4),
//       QuickAIColors.cyber.primary.withOpacity(0.2),
//       Colors.transparent,
//     ],
//     stops: const [0.0, 0.3, 1.0],
//   );

//   LinearGradient get cyberGlassMorphism => LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [
//       Colors.white.withOpacity(0.1),
//       Colors.white.withOpacity(0.05),
//       Colors.white.withOpacity(0.0),
//     ],
//   );
// }

// // 🆕 AI Theme Variant Types
// enum AIThemeVariant { cyber, neural, quantum, data, matrix, holographic }

// // 🆕 AI Color Variant Data Class
// class AIColorVariant {
//   final Color primary;
//   final Color secondary;
//   final Color accent;
//   final Color warning;
//   final Color error;
//   final List<Color> gradient;
//   final Color backgroundDark;
//   final Color cardDark;

//   const AIColorVariant({
//     required this.primary,
//     required this.secondary,
//     required this.accent,
//     required this.warning,
//     required this.error,
//     required this.gradient,
//     required this.backgroundDark,
//     required this.cardDark,
//   });
// }

// // 🆕 Usage Examples in Login Screen
// class AILoginColors {
//   // Example usage with Cyber variant
//   static final cyberVariant = AIThemeManager.getVariant(AIThemeVariant.cyber);

//   // You can use like this in your login screen:
//   static Color getLoginButtonColor(AIThemeVariant variant) {
//     return AIThemeManager.getVariant(variant).primary;
//   }

//   static List<Color> getBackgroundGradient(AIThemeVariant variant) {
//     return AIThemeManager.getVariant(variant).gradient;
//   }

//   static Color getSuccessColor(AIThemeVariant variant) {
//     return AIThemeManager.getVariant(variant).accent;
//   }
// }

// // 🆕 Quick Access Shortcuts
// class QuickAIColors {
//   // Quick access to popular variants
//   static AIColorVariant get cyber =>
//       AIThemeManager.getVariant(AIThemeVariant.cyber);
//   static AIColorVariant get neural =>
//       AIThemeManager.getVariant(AIThemeVariant.neural);
//   static AIColorVariant get quantum =>
//       AIThemeManager.getVariant(AIThemeVariant.quantum);
//   static AIColorVariant get data =>
//       AIThemeManager.getVariant(AIThemeVariant.data);
//   static AIColorVariant get matrix =>
//       AIThemeManager.getVariant(AIThemeVariant.matrix);
//   static AIColorVariant get holo =>
//       AIThemeManager.getVariant(AIThemeVariant.holographic);
// }

// class AppTheme with ChangeNotifier {
//   ThemeMode _themeMode = ThemeMode.light;
//   // 🆕 Add AI theme variant support
//   AIThemeVariant _aiVariant = AIThemeVariant.cyber;

//   ThemeMode get themeMode => _themeMode;
//   AIThemeVariant get aiVariant => _aiVariant;

//   void setThemeMode(ThemeMode mode) {
//     _themeMode = mode;
//     notifyListeners();
//   }

//   // 🆕 New method to set AI variant
//   void setAIVariant(AIThemeVariant variant) {
//     _aiVariant = variant;
//     notifyListeners();
//   }

//   void toggleTheme() {
//     _themeMode = _themeMode == ThemeMode.light
//         ? ThemeMode.dark
//         : ThemeMode.light;
//     notifyListeners();
//   }

//   // Light Theme - UNCHANGED
//   static ThemeData get lightTheme {
//     return ThemeData(
//       useMaterial3: true,
//       brightness: Brightness.light,
//       primaryColor: AppColors.primary,
//       colorScheme: const ColorScheme.light(
//         primary: AppColors.primary,
//         secondary: AppColors.secondary,
//         surface: AppColors.white,
//         onPrimary: AppColors.white,
//         onSecondary: AppColors.white,
//         onSurface: AppColors.textPrimary,
//       ),
//       scaffoldBackgroundColor: AppColors.backgroundLight,
//       appBarTheme: const AppBarTheme(
//         backgroundColor: AppColors.white,
//         foregroundColor: AppColors.textPrimary,
//         elevation: 0,
//         centerTitle: true,
//         iconTheme: IconThemeData(color: AppColors.textPrimary),
//       ),
//       textTheme: const TextTheme(
//         displayLarge: TextStyle(
//           fontSize: 32,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textPrimary,
//         ),
//         displayMedium: TextStyle(
//           fontSize: 28,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textPrimary,
//         ),
//         displaySmall: TextStyle(
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textPrimary,
//         ),
//         headlineMedium: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textPrimary,
//         ),
//         headlineSmall: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textPrimary,
//         ),
//         titleLarge: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textPrimary,
//         ),
//         bodyLarge: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.normal,
//           color: AppColors.textPrimary,
//         ),
//         bodyMedium: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.normal,
//           color: AppColors.textSecondary,
//         ),
//         bodySmall: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.normal,
//           color: AppColors.textDisabled,
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.grey300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.primary, width: 2),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.grey300),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.error),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.error, width: 2),
//         ),
//         filled: true,
//         fillColor: AppColors.white,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 14,
//         ),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primary,
//           foregroundColor: AppColors.white,
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//       ),
//       textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(
//           foregroundColor: AppColors.primary,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//         ),
//       ),
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: AppColors.primary,
//           side: const BorderSide(color: AppColors.primary),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//       ),
//     );
//   }

//   // Dark Theme - UNCHANGED
//   static ThemeData get darkTheme {
//     return ThemeData(
//       useMaterial3: true,
//       brightness: Brightness.dark,
//       primaryColor: AppColors.primaryLight,
//       colorScheme: const ColorScheme.dark(
//         primary: AppColors.primaryLight,
//         secondary: AppColors.secondaryLight,
//         surface: AppColors.grey800,
//         onPrimary: AppColors.white,
//         onSecondary: AppColors.white,
//         onSurface: AppColors.textInverse,
//       ),
//       scaffoldBackgroundColor: AppColors.backgroundDark,
//       appBarTheme: const AppBarTheme(
//         backgroundColor: AppColors.grey900,
//         foregroundColor: AppColors.textInverse,
//         elevation: 0,
//         centerTitle: true,
//         iconTheme: IconThemeData(color: AppColors.textInverse),
//       ),
//       textTheme: const TextTheme(
//         displayLarge: TextStyle(
//           fontSize: 32,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textInverse,
//         ),
//         displayMedium: TextStyle(
//           fontSize: 28,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textInverse,
//         ),
//         displaySmall: TextStyle(
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textInverse,
//         ),
//         headlineMedium: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textInverse,
//         ),
//         headlineSmall: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textInverse,
//         ),
//         titleLarge: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textInverse,
//         ),
//         bodyLarge: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.normal,
//           color: AppColors.textInverse,
//         ),
//         bodyMedium: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.normal,
//           color: AppColors.grey400,
//         ),
//         bodySmall: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.normal,
//           color: AppColors.grey500,
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.grey700),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.grey700),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.error),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.error, width: 2),
//         ),
//         filled: true,
//         fillColor: AppColors.grey800,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 14,
//         ),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primaryLight,
//           foregroundColor: AppColors.white,
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//       ),
//       textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(
//           foregroundColor: AppColors.primaryLight,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//         ),
//       ),
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: AppColors.primaryLight,
//           side: const BorderSide(color: AppColors.primaryLight),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//       ),
//     );
//   }
// }
