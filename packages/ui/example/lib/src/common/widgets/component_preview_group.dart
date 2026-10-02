/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 14 August 2026
 */

import 'package:ui/ui.dart';

/// Groups related component examples into one token-aligned catalog surface.
class ComponentPreviewGroup extends StatelessWidget {
  /// Creates a labeled preview group.
  const ComponentPreviewGroup({required this.title, required this.child, this.description, this.icon, super.key});

  /// Short group title.
  final String title;

  /// Optional caller-focused explanation.
  final String? description;

  /// Optional visual category marker.
  final IconData? icon;

  /// Related component examples.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uiTheme = theme.uiTheme;
    final spacing = uiTheme.size.offset;
    return Material(
      color: uiTheme.color.secondaryBackground,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: uiTheme.color.border),
        borderRadius: UIBorderRadius.regular(context),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.regular),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: spacing.regular,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (icon != null) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: uiTheme.color.selected,
                      borderRadius: UIBorderRadius.small(context),
                    ),
                    child: SizedBox.square(
                      dimension: uiTheme.size.button.small,
                      child: Icon(icon, size: uiTheme.size.icon.small, color: uiTheme.color.accent),
                    ),
                  ),
                  SizedBox(width: spacing.small),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: spacing.extraExtraSmall,
                    children: <Widget>[
                      Text(title, style: theme.textTheme.titleMedium),
                      if (description case final description? when description.isNotEmpty)
                        Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(color: uiTheme.color.textSecondary),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            child,
          ],
        ),
      ),
    );
  }
}
