// lib/features/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:trirecall/features/auth/widgets/auth_button.dart';
import 'package:trirecall/features/auth/widgets/auth_field.dart';

// We use a StatefulWidget because we need to manage the state of the
// text field's content using a TextEditingController.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // A controller to get the text the user enters in the email field.
  final emailController = TextEditingController();
  // A key to identify and manage our Form.
  final formKey = GlobalKey<FormState>();

  // It's a best practice to dispose of controllers when the widget is
  // removed from the widget tree to free up resources.
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We wrap our main content in a SingleChildScrollView to prevent
      // a "pixel overflow" error if the keyboard pops up on a small screen.
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          // A Form widget allows us to group and validate multiple text fields.
          child: Form(
            key: formKey,
            child: Column(
              // Center the content vertically on the screen.
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Spacer to push content down from the status bar
                const SizedBox(height: 100),

                // Main Title
                const Text(
                  'TriRecall',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                const Text(
                  'Sign in or Sign up to continue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),

                // Email Text Field (our custom widget)
                AuthField(
                  hintText: 'Email',
                  controller: emailController,
                ),
                const SizedBox(height: 20),

                // Login Button (our custom widget)
                AuthButton(
                  buttonText: 'Send Magic Link',
                  // For now, the button does nothing when pressed.
                  // We will add the logic in Part C.
                  onPressed: () {},
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}