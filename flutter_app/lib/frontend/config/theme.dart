 import 'package:flutter/material.dart';

/// SmartPrice Brand Colors
class AppColors {
  // Primary Colors
  static const Color isabeline = Color(0xFFF3F2EE); // Light background
  static const Color bone = Color(0xFFD8D2BD); // Secondary background

  // Accent Colors
  static const Color tangerine = Color(0xFFE78B3B); // Orange accent
  static const Color flame = Color(0xFFEA672D); // Red-orange accent

  // Nature/Green Colors
  static const Color hunterGreen = Color(0xFF315A2B); // Primary green
  static const Color calPolyGreen = Color(0xFF26422a); // Dark green
  static const Color columbiaBlue = Color(0xFFD2E8FF); // Light blue

  // Dark Colors
  static const Color night = Color(0xFF161616); // Almost black
  static const Color bistre = Color(0xFF5D372A); // Brown

  // App Theme Colors
  static const Color primaryColor = hunterGreen;
  static const Color accentColor = flame;
  static const Color backgroundColor = isabeline;
  static const Color surfaceColor = bone;
}

/// App Theme Configuration
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.hunterGreen,
        primary: AppColors.hunterGreen,
        secondary: AppColors.flame,
        surface: AppColors.bone,
      ),
      scaffoldBackgroundColor: AppColors.isabeline,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.hunterGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.flame,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.hunterGreen, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }
}

/// Gradient Presets
class AppGradients {
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.hunterGreen, AppColors.calPolyGreen, AppColors.bistre],
  );

  static const Gradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.flame, AppColors.tangerine],
  );

  static const Gradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.hunterGreen, AppColors.calPolyGreen],
  );
}
