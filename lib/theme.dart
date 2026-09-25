import 'package:flutter/material.dart';

/// Visual preset for this app. Must stay one of the ten canonical presets.
const String kPresetName = 'RETRO_NEON';

/// RETRO_NEON with brief-specific neon-water accents.
class AppColors {
  const AppColors._();

  static const String name = kPresetName;

  static const Color bgDarkest = Color(0xFF050D18);
  static const Color bgDeep = Color(0xFF071322);
  static const Color bgBase = Color(0xFF10233C);
  static const Color bgMid = Color(0xFF0A1A2C);

  static const Color primary = Color(0xFF26BCE8);
  static const Color secondary = Color(0xFF7655D4);
  static const Color gold = Color(0xFFF2C64D);
  static const Color danger = Color(0xFFEF5A79);

  static const Color textPrimary = Color(0xFFF4F8FF);

  /// Single alpha helper so opacity handling lives in one place.
  static Color a(Color c, double opacity) => c.withValues(alpha: opacity);

  static Color get textSecondary => a(textPrimary, 0.62);
  static Color get textMuted => a(textPrimary, 0.38);
  static Color get surface => a(textPrimary, 0.06);
  static Color get surfaceBorder => a(textPrimary, 0.12);

  static const LinearGradient ctaGradient = LinearGradient(
    colors: <Color>[primary, secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class AppTheme {
  const AppTheme._();

  static ThemeData build() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      secondary: AppColors.secondary,
      surface: AppColors.bgBase,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bgBase,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.4,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.8,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
