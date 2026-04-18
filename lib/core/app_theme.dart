import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand Palette from shared design
  static const Color background = Color(0xFFF9F9FF);
  static const Color surface = Color(0xFFF1F3FF);
  static const Color primary = Color(0xFF0A1422); // Deep Navy
  static const Color secondary = Color(0xFF0051D5); // Vibrant Blue
  static const Color surfaceContainerHighest = Color(0xFFDCE2F7);
  static const Color outlineVariant = Color(0xFFC5C6CC);
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF2E7D32); // Success Green
  static const Color warning = Color(0xFFED6C02); // Warning Orange
  
  static const Color textPrimary = Color(0xFF0A1422);
  static const Color textSecondary = Color(0xFF44474C);
  
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xCC0A1422), // 80% opacity primary
      Color(0xCC1F2937),
    ],
  );
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 56,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.1,
        letterSpacing: -1.0,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.primary),
    ),
  );
}
