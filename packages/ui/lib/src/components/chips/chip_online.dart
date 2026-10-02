// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'package:flutter/cupertino.dart';
import 'package:ui/ui.dart';

/// {@template chip_online}
/// UIChipOnline widget.
/// {@endtemplate}
class UIChipOnline extends StatelessWidget {
  /// {@macro chip_online}
  const UIChipOnline({this.textToLowerCase = false, this.backgroundColor, this.fontSize, this.padding, super.key});

  /// Use lower case for text?
  final bool textToLowerCase;

  /// Font size
  final double? fontSize;

  /// Background color
  final Color? backgroundColor;

  /// Padding
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        backgroundColor ?? CupertinoDynamicColor.resolve(CupertinoColors.quaternarySystemFill, context);
    final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 3.5);
    final l10n = UILocalizations.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 22),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(30)),
        ),
        child: Padding(
          padding: effectivePadding,
          child: Row(
            mainAxisSize: .min,
            children: <Widget>[
              SizedBox.square(
                dimension: 5,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: .circle,
                    color: CupertinoDynamicColor.maybeResolve(CupertinoColors.systemGreen, context),
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  textToLowerCase ? l10n.textIsOnline.toLowerCase() : l10n.textIsOnline,
                  overflow: .ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1, fontSize: fontSize ?? 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
