// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'package:flutter/material.dart';

/// {@template dismiss_keyboard}
/// UIDismissKeyboard widget.
/// {@endtemplate}
class UIDismissKeyboard extends StatelessWidget {
  /// {@macro dismiss_keyboard}
  const UIDismissKeyboard({required this.child, this.onUnfocus, super.key});

  /// The child widget.
  final Widget child;

  /// This callback calls when `primaryFocus` is unfocused.
  final VoidCallback? onUnfocus;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      final currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        FocusManager.instance.primaryFocus?.unfocus();
        onUnfocus?.call();
      }
    },
    child: child,
  );
}
