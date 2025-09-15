// lib/core/theme/theme.dart

import 'package:flutter/material.dart';
import 'package:trirecall/core/theme/app_palette.dart';

// This class defines the global theme data for the app.
class AppTheme {
  // A helper method to create a consistent border style for input fields.
  static _border([Color color = AppPalette.borderColor]) => OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      );

  // The main dark theme configuration for the application.
  static final darkThemeMode = ThemeData.dark().copyWith(
    // The default background color for all screens (Scaffolds).
    scaffoldBackgroundColor: AppPalette.backgroundColor,

    // Theming for AppBars.
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.backgroundColor,
      elevation: 0, // No shadow for a flatter look.
    ),

    cardTheme: CardThemeData(
      color: AppPalette.secondaryColor, // Use our secondary color for cards
      elevation: 2, // Give it a slight shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),

    // Theming for text input fields.
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(18),
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(AppPalette.primaryColor),
      errorBorder: _border(AppPalette.errorColor),
      hintStyle: const TextStyle(
        color: AppPalette.greyColor,
        fontWeight: FontWeight.w500,
      ),
    ),
    
    // Theming for ElevatedButton (our primary button type).
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.primaryColor,
        foregroundColor: AppPalette.whiteColor, // Text color
        minimumSize: const Size(double.infinity, 52), // Full width, fixed height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        )
      ),
    ),
  );
}