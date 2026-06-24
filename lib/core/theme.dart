import 'package:flutter/material.dart';

/// High-contrast, large-text themes tuned for low-vision and elderly users.
/// Dark mode is a first-class citizen because real Seekr users have asked for
/// it (light-sensitive users find white backgrounds painful).
class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0066CC)),
    textTheme: _textTheme,
    chipTheme: const ChipThemeData(
      labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4DA3FF),
      brightness: Brightness.dark,
    ),
    textTheme: _textTheme,
    chipTheme: const ChipThemeData(
      labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    ),
  );

  static const TextTheme _textTheme = TextTheme(
    bodyLarge: TextStyle(fontSize: 20),
    bodyMedium: TextStyle(fontSize: 18),
    titleLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
  );
}
