import 'package:flutter/material.dart';

/// Market stall high-contrast Material 3 theme.
///
/// Designed for:
/// - Direct sunlight readability (high contrast, bold labels)
/// - One-handed ergonomics (>= 52dp touch targets)
/// - Minimal visual noise and instant recognition
class AppTheme {
  // Sunlight-readable high contrast color palette
  static const primaryColor = Color(0xFFF59E0B); // Vibrant Amber / Banana Gold
  static const primaryDark = Color(0xFFD97706);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const backgroundLight = Color(0xFFF8FAFC); // Slate-50
  static const textPrimary = Color(0xFF0F172A); // Slate-900 (ultra-crisp)
  static const textSecondary = Color(0xFF475569); // Slate-600
  static const borderSubtle = Color(0xFFCBD5E1); // Slate-300
  static const dangerColor = Color(
    0xFFDC2626,
  ); // Red-600 for loss/shortfall/void
  static const accentRed = dangerColor;
  static const accentGreen = Color(0xFF16A34A); // Emerald-600 for profit
  static const warningAmber = Color(0xFFD97706); // Amber-600
  static const accentAmber = primaryColor;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryDark,
        onPrimary: Colors.white,
        surface: surfaceLight,
        onSurface: textPrimary,
        error: dangerColor,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(
            54,
          ), // Extra-large thumb touch targets
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 50),
          foregroundColor: textPrimary,
          side: const BorderSide(color: borderSubtle, width: 1.5),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderSubtle, width: 1.2),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      ),
    );
  }
}
