import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// VGB brand colors (from verygood.ventures).
abstract class AppColors {
  static const Color primary = Color(0xFF0066FF);
  static const Color primaryDark = Color(0xFF0052CC);
  static const Color primaryLight = Color(0xFF3385FF);
  static const Color secondary = Color(0xFF00D4FF);
  static const Color navy = Color(0xFF0A1628);
  static const Color navyLight = Color(0xFF1A2A44);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray100 = Color(0xFFF7F9FC);
  static const Color gray200 = Color(0xFFE8ECF2);
  static const Color gray300 = Color(0xFFCBD2DC);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7A90);
  static const Color gray700 = Color(0xFF374151);
  static const Color success = Color(0xFF00C48C);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF4757);
  static const Color gold = Color(0xFFFFD700);
}

/// App theme and text styles — modern, clean.
class AppTheme {
  static const double radiusCard = 20;
  static const double radiusButton = 24;
  static const double radiusModal = 24;
  static const double radiusPill = 999;

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.navy,
        error: AppColors.error,
        onError: AppColors.white,
        surfaceContainerHighest: AppColors.gray100,
      ),
      scaffoldBackgroundColor: AppColors.gray100,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shadowColor: AppColors.gray300.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          elevation: 0,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: AppColors.navy,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: AppColors.navy,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: AppColors.navy,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.navy,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.4,
          color: AppColors.gray700,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.4,
          color: AppColors.gray700,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.35,
          color: AppColors.gray500,
        ),
      ),
    );
  }

  static CupertinoThemeData get cupertino {
    return CupertinoThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.gray100,
      brightness: Brightness.light,
    );
  }
}
