import 'package:flutter/cupertino.dart';
import 'package:ui/ui.dart';

/// {@template chip_blocked}
/// This widget used to show blocked chip.
/// {@endtemplate}
class UIChipBlocked extends StatelessWidget {
  /// {@macro chip_blocked}
  const UIChipBlocked({this.onTap, super.key});

  /// Tap callback
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = CupertinoDynamicColor.resolve(CupertinoColors.systemRed, context);
    return CupertinoButton(
      onPressed: onTap,
      padding: .zero,
      sizeStyle: .small,
      pressedOpacity: 0.7,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: const .all(.circular(30))),
        child: Padding(
          padding: const .only(top: 5, bottom: 5, left: 5, right: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: theme.uiTheme.size.offset.small,
            children: <Widget>[
              Icon(Icons.block, size: theme.uiTheme.size.icon.small, color: color),
              Text(
                UILocalizations.of(context).textIsBlocked,
                style: theme.textTheme.bodySmall?.copyWith(color: color, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
