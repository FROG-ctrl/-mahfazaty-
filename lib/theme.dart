import 'package:flutter/material.dart';
import 'settings.dart';

class AppColors {
  static Color get emerald => switch (AppSettings.instance.themeId) {
    'blue' => const Color(0xFF245BB5),
    'orange' => const Color(0xFFAE4C13),
    'purple' => const Color(0xFF7750A8),
    'white' => const Color(0xFF34434C),
    'black' => const Color(0xFF718DAA),
    _ => const Color(0xFF0E7C66),
  };
  static Color get emeraldDark => Color.lerp(emerald, Colors.black, 0.32)!;
  static Color get teal => Color.lerp(emerald, Colors.white, 0.16)!;
  static Color get gold => switch (AppSettings.instance.themeId) {
    'blue' => const Color(0xFF3B77C0),
    'orange' => const Color(0xFFB76621),
    'purple' => const Color(0xFF8D65BA),
    'white' => const Color(0xFF5A6871),
    'black' => const Color(0xFF94ADC6),
    _ => const Color(0xFFE3A93B),
  };
  static const income = Color(0xFF1E9E6A);
  static const expense = Color(0xFFD64545);
  static Color get bg => AppSettings.instance.themeId == 'black'
      ? const Color(0xFF101317)
      : const Color(0xFFF3F6F5);
  static Color get ink => AppSettings.instance.themeId == 'black'
      ? const Color(0xFFF2F3F5)
      : const Color(0xFF17201D);
}

class AppTheme {
  static ThemeData get light {
    final dark = AppSettings.instance.themeId == 'black';
    final scheme = ColorScheme.fromSeed(
      brightness: dark ? Brightness.dark : Brightness.light,
      seedColor: AppColors.emerald,
      primary: dark ? const Color(0xFFB2CBE1) : AppColors.emerald,
      secondary: AppColors.gold,
      surface: dark ? const Color(0xFF1B2026) : Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: AppColors.bg,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.ink,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.emerald,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF262D35) : const Color(0xFFF1F4F3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
