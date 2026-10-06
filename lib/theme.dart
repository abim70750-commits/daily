import 'package:flutter/material.dart';

ThemeData buildTheme(Color accent, Brightness b) {
  final scheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: b,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: b == Brightness.light
        ? const Color(0xFFF7F7FA)
        : const Color(0xFF0E0E12),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: scheme.onSurface,
      centerTitle: false,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: b == Brightness.light ? Colors.white : const Color(0xFF16161C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      elevation: 0,
      backgroundColor:
          b == Brightness.light ? Colors.white : const Color(0xFF16161C),
      indicatorColor: accent.withValues(alpha: 0.18),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor:
          b == Brightness.light ? const Color(0xFFEFEFF4) : const Color(0xFF1C1C24),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}

/// Warna heatmap normal — gradasi dari aksen.
Color heatmapNormal(Color accent, int level) {
  switch (level) {
    case 0:
      return accent.withValues(alpha: 0.08);
    case 1:
      return accent.withValues(alpha: 0.30);
    case 2:
      return accent.withValues(alpha: 0.55);
    case 3:
      return accent.withValues(alpha: 0.80);
    default:
      return accent;
  }
}

/// Warna streak — gradasi api → plasma.
Color streakColor(int streak, Color fallback) {
  if (streak <= 0) return fallback;
  if (streak <= 2) return const Color(0xFFFFF176);
  if (streak <= 6) return const Color(0xFFFFEE58);
  if (streak <= 13) return const Color(0xFFFFB300);
  if (streak <= 29) return const Color(0xFFFB8C00);
  if (streak <= 69) return const Color(0xFFE53935);
  if (streak <= 99) {
    final t = (streak - 70) / 29.0;
    return Color.lerp(const Color(0xFFE53935), const Color(0xFF8E24AA), t)!;
  }
  return const Color(0xFF8E24AA);
}
