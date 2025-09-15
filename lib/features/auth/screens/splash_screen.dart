// lib/features/auth/screens/splash_screen.dart

import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // A Scaffold provides the basic visual layout structure.
    // It will automatically use the scaffoldBackgroundColor from our theme.
    return const Scaffold(
      // A Center widget centers its child both horizontally and vertically.
      body: Center(
        // We display the app's name. The default text color
        // will also be inherited from our darkThemeMode.
        child: Text(
          'TriRecall',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}