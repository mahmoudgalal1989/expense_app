import 'package:flutter/material.dart';

class AppColors {
  // Background colors
  static const Color backgroundDark = Color(0xFF0C0F11);
  static const Color backgroundLight = Color(0xFF1A1E1F);
  static const Color bottomNavBar = Color(0xFF1C2022);
  static const Color backgroundBg8 = Color(0x14FFFFFF);  // 20% white opacity
  static const Color settingsContainerBg = Color(0x21FFFFFF);

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color textDark = Color(0xFF151A1F);

  // UI elements
  static const Color borderLight = Colors.white;
  static const Color shadow = Color.fromRGBO(0, 0, 0, 0.1);
  static const Color navBarUnselected = Color.fromRGBO(255, 255, 255, 0.7);

  // Gradients
  static const List<Color> backgroundGradient = [
    Color(0xFF1A1E1F),
    Color(0xFF0C0F11),
  ];

  static const List<Color> buttonGradient = [
    Color(0xFFEFF2F6),
    Color(0xFFDFDFDF),
  ];

  // Add any additional colors used in the app
  static const Color divider = Color(0xFF2A2F31);
  static const Color cardBackground = Color(0xFF1A1E1F);
}
