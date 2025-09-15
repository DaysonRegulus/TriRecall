// lib/features/auth/widgets/auth_button.dart

import 'package:flutter/material.dart';
import 'package:trirecall/core/theme/app_palette.dart';

class AuthButton extends StatelessWidget {
  final String buttonText;
  // A function that will be called when the button is pressed.
  final VoidCallback onPressed;

  const AuthButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // The Container is used to create the gradient background.
    return Container(
      // The decoration applies the styling.
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppPalette.primaryColor,
            Color(0xFF8E44AD), // A slightly different shade of purple
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      // We still use an ElevatedButton to get all the button behaviors
      // for free, like the ripple effect on press.
      child: ElevatedButton(
        onPressed: onPressed,
        // We make the button's own background transparent so we can
        // see the gradient from the Container behind it.
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent, // No shadow
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}