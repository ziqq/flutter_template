// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'package:flutter/cupertino.dart';
import 'package:ui/ui.dart';

/// {@template custom_clear_button}
/// UIClearButton widget.
///
/// A custom clear button.
/// {@endtemplate}
class UIClearButton extends StatelessWidget {
  /// {@macro custom_clear_button}
  const UIClearButton({this.size, this.color, this.backgroundColor, this.padding, this.onTap, super.key});

  /// The size of the button.
  final double? size;

  /// The color of the button.
  final Color? color;

  /// The background color of the button.
  final Color? backgroundColor;

  /// The padding of the button.
  final EdgeInsetsGeometry? padding;

  /// The callback function.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color effectiveBackgroundColor =
        backgroundColor ?? CupertinoDynamicColor.resolve(CupertinoColors.quaternarySystemFill, context);

    final Color effectiveColor = color ?? CupertinoDynamicColor.resolve(CupertinoColors.systemGrey, context);

    final double effectiveIconSize = size ?? 20;

    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.all(4);

    return IconButton(
      tooltip: UILocalizations.of(context).clearLabel,
      onPressed: onTap,
      padding: EdgeInsets.zero,
      icon: SizedBox(
        width: 1.4 * effectiveIconSize,
        height: 1.4 * effectiveIconSize,
        child: DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, color: effectiveBackgroundColor),
          child: Padding(
            padding: effectivePadding,
            child: Center(
              child: Icon(Icons.close_rounded, color: effectiveColor, size: effectiveIconSize),
            ),
          ),
        ),
      ),
    );
  }
}
