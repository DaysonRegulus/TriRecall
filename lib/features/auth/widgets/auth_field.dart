// lib/features/auth/widgets/auth_field.dart

import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  // The hint text to display when the field is empty.
  final String hintText;
  // The controller to manage the text inside the field.
  final TextEditingController controller;

  const AuthField({
    super.key,
    required this.hintText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // TextFormField is a more powerful version of TextField that
    // integrates with Form widgets for validation, which we'll use later.
    return TextFormField(
      controller: controller,
      // The decoration styles the appearance of the text field.
      // Notice we don't need to specify colors or borders here,
      // because it's all inherited from the inputDecorationTheme
      // we defined in AppTheme! This is the power of a global theme.
      decoration: InputDecoration(
        hintText: hintText,
      ),
      // We'll add validation logic here in the next part.
      // validator: (value) {
      //   return null;
      // },
    );
  }
}