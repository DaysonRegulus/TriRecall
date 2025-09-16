import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text, {bool isError = false}) {
  ScaffoldMessenger.of(context)
    // Hide any currently showing snackbar to prevent them from stacking up.
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
        
        // This is the new logic. If `isError` is true, we use the error color
        // defined in our app's theme. Otherwise, we let it use the default color.
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : null,
      ),
    );
}