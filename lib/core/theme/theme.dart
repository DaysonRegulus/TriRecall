// lib/core/theme/theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  static final Color _seedColor = const Color(0xFFBB86FC);

  // --- DARK THEME ---
  static final darkThemeMode = ThemeData(
    // 1. Set useMaterial3 to true in the main constructor.
    useMaterial3: true,

    // 2. Provide the ColorScheme generated from the seed.
    // The brightness property ensures it's a dark mode scheme.
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),

    // 3. Component theme overrides remain the same.
    // We are still just tweaking the appearance, not the core colors.
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade600,
      ),
    ),
  );

  // --- LIGHT THEME ---
  static final lightThemeMode = ThemeData(
    // 1. Set useMaterial3 to true in the main constructor.
    useMaterial3: true,

    // 2. Provide the ColorScheme. The default brightness is light.
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    ),

    // 3. Component theme overrides.
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade500,
      ),
    ),
  );
}