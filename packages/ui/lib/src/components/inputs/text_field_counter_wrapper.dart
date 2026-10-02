import 'package:flutter/cupertino.dart' show CupertinoDynamicColor, CupertinoColors;
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

/// {@template text_field_counter_wrapper}
/// UITextFieldCounterWrapper widget.
/// {@endtemplate}
class UITextFieldCounterWrapper extends StatelessWidget {
  /// {@macro text_field_counter_wrapper}
  const UITextFieldCounterWrapper({
    required this.controller,
    required this.child,
    this.maxLength = 1500,
    this.position,
    super.key,
  }) : assert(maxLength >= 0, 'Maximum length must be nonnegative.');

  /// The maximum length of the text field child widget.
  /// Default is 1500.
  final int maxLength;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// The controller of the text field child widget.
  final TextEditingController controller;

  /// The position of the counter.
  final ({double? top, double? bottom, double? left, double? right})? position;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final $position =
        position ??
        (top: null, bottom: theme.uiTheme.size.offset.small, left: null, right: theme.uiTheme.size.offset.small);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // --- Child --- //
        child,

        // --- Counter --- //
        Positioned(
          top: $position.top,
          left: $position.left,
          right: $position.right,
          bottom: $position.bottom,
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final text = controller.text;
              final length = maxLength - text.characters.length;
              if (text.isEmpty) return const SizedBox.shrink();
              if (length > 50) return const SizedBox.shrink();
              return Text(
                length.toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                  color: length < 0 ? CupertinoDynamicColor.resolve(CupertinoColors.systemRed, context) : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
