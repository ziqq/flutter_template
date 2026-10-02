/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 14 August 2026
 */

import 'package:flutter/material.dart';

/// Toggles the example between its light and dark UI Kit themes.
class CatalogThemeButton extends StatelessWidget {
  /// Creates the shared theme action used by both catalog shells.
  const CatalogThemeButton({required this.onPressed, super.key});

  /// Toggles the example theme.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == .light;
    return IconButton(
      tooltip: isLight ? 'Use dark theme' : 'Use light theme',
      onPressed: onPressed,
      icon: Icon(isLight ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
    );
  }
}
