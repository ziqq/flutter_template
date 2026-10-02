import 'package:flutter/material.dart';

/// Gives catalog actions a visible, local result without an external operation.
void showPreviewSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
