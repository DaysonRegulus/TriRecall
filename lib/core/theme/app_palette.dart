// lib/core/theme/app_palette.dart

import 'package:flutter/material.dart';

// This class holds the specific color palette for the TriRecall app.
// By centralizing colors here, we can ensure consistency and easily
// update the theme across the entire application.
class AppPalette {
  // Main background color, a deep, dark purple.
  static const Color backgroundColor = Color(0xFF1E1E2E); // A very dark blue/purple

  // Primary color for buttons, interactive elements, and highlights. A vibrant purple.
  static const Color primaryColor = Color(0xFFBB86FC);

  // A secondary, less prominent color.
  static const Color secondaryColor = Color(0xFF373752);

  // Color for text that needs to stand out.
  static const Color whiteColor = Color(0xFFFFFFFF);
  
  // A muted gray for less important text or icons.
  static const Color greyColor = Color(0xFF8D8D9E);

  // Color to indicate an error or a destructive action.
  static const Color errorColor = Color(0xFFCF6679);
  
  // Color for the border of text fields and other elements.
  static const Color borderColor = Color(0xFF454561);
}