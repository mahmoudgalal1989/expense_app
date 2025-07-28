import 'package:flutter/material.dart';
import 'package:expense_app/theme/app_colors.dart';

class AppTheme with ChangeNotifier {
  static bool _isDarkMode = false;

  static bool get isDarkMode => _isDarkMode;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.light500,
        secondary: AppColors.light300,
        surface: AppColors.light0,
        background: AppColors.light50,
        error: AppColors.error500,
      ),
      scaffoldBackgroundColor: AppColors.light50,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.light50,
        foregroundColor: AppColors.dark900,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: AppColors.light0,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: AppColors.dark900),
        displayMedium: TextStyle(color: AppColors.dark900),
        bodyLarge: TextStyle(color: AppColors.dark900),
        bodyMedium: TextStyle(color: AppColors.dark700),
        bodySmall: TextStyle(color: AppColors.dark500),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.light100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.light100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.light500),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.dark0,
        secondary: AppColors.dark300,
        surface: AppColors.dark800,
        background: AppColors.dark900,
        error: AppColors.error500,
      ),
      scaffoldBackgroundColor: AppColors.dark900,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.dark900,
        foregroundColor: AppColors.dark0,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: AppColors.dark800,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: AppColors.dark0),
        displayMedium: TextStyle(color: AppColors.dark0),
        bodyLarge: TextStyle(color: AppColors.dark0),
        bodyMedium: TextStyle(color: AppColors.dark100),
        bodySmall: TextStyle(color: AppColors.dark300),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.dark600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.dark600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.dark300),
        ),
      ),
    );
  }

  static ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  static void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    // Notify listeners if needed
  }
}

// Extension for custom theme properties
class AppThemeColors {
  final List<Color> backgroundGradient;

  const AppThemeColors({
    required this.backgroundGradient,
  });
}

// Extension for easy access to theme colors
extension AppThemeExtension on BuildContext {
  // Text colors
  Color get textPrimary => Theme.of(this).brightness == Brightness.light
      ? AppColors.textPrimaryLight
      : AppColors.textPrimaryDark;

  Color get textSecondary => Theme.of(this).brightness == Brightness.light
      ? AppColors.textSecondaryLight
      : AppColors.textSecondaryDark;

  // Background colors
  Color get bgPrimary => Theme.of(this).brightness == Brightness.light
      ? AppColors.bgPrimaryLight
      : AppColors.bgPrimaryDark;

  Color get bgSecondary => Theme.of(this).brightness == Brightness.light
      ? AppColors.bgSecondaryLight
      : AppColors.bgSecondaryDark;

  // Border colors
  Color get borderPrimary => Theme.of(this).brightness == Brightness.light
      ? AppColors.borderPrimaryLight
      : AppColors.borderPrimaryDark;

  // Status colors
  Color get success => Theme.of(this).brightness == Brightness.light
      ? AppColors.success500
      : AppColors.success300;

  Color get error => Theme.of(this).brightness == Brightness.light
      ? AppColors.error500
      : AppColors.error300;

  Color get warning => Theme.of(this).brightness == Brightness.light
      ? AppColors.warning500
      : AppColors.warning300;

  // Gradients
  List<Color> get backgroundGradient => AppColors.backgroundGradient;
  List<Color> get buttonGradient => AppColors.buttonGradient;
}
