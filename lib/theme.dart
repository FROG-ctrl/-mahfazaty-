import 'package:flutter/material.dart';
import 'settings.dart';

/// Paired palettes keep the same stored IDs so an update keeps each selection.
class WalletPalette {
  const WalletPalette(
    this.primary,
    this.accent,
    this.background,
    this.surface,
    this.input,
    this.ink,
    this.heroEnd,
  );
  final Color primary, accent, background, surface, input, ink, heroEnd;
  static const all = <String, WalletPalette>{
    'green': WalletPalette(
      Color(0xFF28775E),
      Color(0xFFD9B65B),
      Color(0xFF123A30),
      Color(0xFF1D4D3F),
      Color(0xFF285C4D),
      Color(0xFFF1EEDC),
      Color(0xFF8C6D25),
    ),
    'purple': WalletPalette(
      Color(0xFF795397),
      Color(0xFFE3A1B7),
      Color(0xFF30213E),
      Color(0xFF483054),
      Color(0xFF583C66),
      Color(0xFFF6EAF4),
      Color(0xFF97566F),
    ),
    'blue': WalletPalette(
      Color(0xFF35678A),
      Color(0xFFE1AB89),
      Color(0xFF172E43),
      Color(0xFF24455F),
      Color(0xFF315671),
      Color(0xFFEAF0F6),
      Color(0xFF8C5A45),
    ),
    'orange': WalletPalette(
      Color(0xFFA55A3C),
      Color(0xFFB4C8A3),
      Color(0xFF543329),
      Color(0xFF704737),
      Color(0xFF835541),
      Color(0xFFF6EAD8),
      Color(0xFF4B6B53),
    ),
    'white': WalletPalette(
      Color(0xFF38434E),
      Color(0xFF687580),
      Color(0xFFF5F6F7),
      Color(0xFFFFFFFF),
      Color(0xFFEBEEF0),
      Color(0xFF202830),
      Color(0xFF596772),
    ),
    'black': WalletPalette(
      Color(0xFF4F5B68),
      Color(0xFFABB6C2),
      Color(0xFF101214),
      Color(0xFF1C2024),
      Color(0xFF292F35),
      Color(0xFFF1F3F5),
      Color(0xFF333C46),
    ),
  };
  static WalletPalette get current =>
      all[AppSettings.instance.themeId] ?? all['green']!;
}

class AppColors {
  static Color get emerald => WalletPalette.current.primary;
  static Color get emeraldDark => Color.lerp(emerald, Colors.black, 0.24)!;
  static Color get teal => Color.lerp(emerald, Colors.white, 0.08)!;
  static Color get gold => WalletPalette.current.accent;
  static List<Color> get heroGradient => [
    emerald,
    WalletPalette.current.heroEnd,
  ];
  static Color get income => AppSettings.instance.themeId == 'white'
      ? const Color(0xFF1E9E6A)
      : const Color(0xFF73D3A8);
  static Color get expense => AppSettings.instance.themeId == 'white'
      ? const Color(0xFFD64545)
      : const Color(0xFFFFA69B);
  static Color get muted => ink.withValues(alpha: .72);
  static Color get bg => WalletPalette.current.background;
  static Color get ink => WalletPalette.current.ink;
}

class AppTheme {
  static ThemeData get light {
    final p = WalletPalette.current;
    final dark = AppSettings.instance.themeId != 'white';
    final scheme = ColorScheme.fromSeed(
      brightness: dark ? Brightness.dark : Brightness.light,
      seedColor: p.primary,
      primary: dark ? Color.lerp(p.primary, p.ink, .6)! : p.primary,
      secondary: p.accent,
      surface: p.surface,
      onSurface: p.ink,
      secondaryContainer: p.accent.withValues(alpha: .18),
      onSecondaryContainer: p.ink,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: p.background,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: p.ink,
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        indicatorColor: p.accent.withValues(alpha: dark ? .22 : .18),
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
        fillColor: p.input,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
