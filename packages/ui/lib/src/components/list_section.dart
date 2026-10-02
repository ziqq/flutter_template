import 'package:flutter/cupertino.dart' show CupertinoListSection;
import 'package:flutter/material.dart';
import 'package:ui/src/theme/theme.dart';

/// A short, rounded group of rows with optional header and footer.
class UIListSection extends StatelessWidget {
  /// Creates a group on the standard list surface.
  const UIListSection({
    required this.children,
    this.header,
    this.footer,
    this.contentPadding,
    this.backgroundColor,
    this.separatorColor,
    this.dividerMargin,
    this.useSeparator = true,
    super.key,
  }) : _secondary = false;

  /// Creates a group on the secondary list surface.
  const UIListSection.secondary({
    required this.children,
    this.header,
    this.footer,
    this.contentPadding,
    this.backgroundColor,
    this.separatorColor,
    this.dividerMargin,
    this.useSeparator = true,
    super.key,
  }) : _secondary = true;

  /// Rows in the group. An empty list does not create a section.
  final List<Widget> children;

  /// Text above the group, displayed in uppercase.
  final String? header;

  /// Text below the group.
  final String? footer;

  /// Insets around the group surface.
  final EdgeInsetsGeometry? contentPadding;

  /// The fill of the group surface.
  final Color? backgroundColor;

  /// The divider color.
  final Color? separatorColor;

  /// The directional start inset of each divider.
  final double? dividerMargin;

  /// Whether to show dividers between rows.
  final bool useSeparator;

  final bool _secondary;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final uiTheme = Theme.of(context).uiTheme;
    return CupertinoListSection.insetGrouped(
      backgroundColor: Colors.transparent,
      margin:
          contentPadding ??
          (footer == null ? EdgeInsets.zero : EdgeInsets.only(bottom: uiTheme.size.offset.regular / 2)),
      dividerMargin: dividerMargin ?? uiTheme.size.offset.regular,
      additionalDividerMargin: 0,
      separatorColor: separatorColor ?? uiTheme.color.border,
      decoration: BoxDecoration(
        color: backgroundColor ?? (_secondary ? uiTheme.color.onSecondaryBackground : uiTheme.color.onBackground),
      ),
      header: switch (header) {
        String value => Text(
          value.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: uiTheme.color.textSecondary),
        ),
        null => null,
      },
      footer: switch (footer) {
        String value => Text(
          value,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: uiTheme.color.textSecondary),
        ),
        null => null,
      },
      children: useSeparator ? children : <Widget>[Column(mainAxisSize: MainAxisSize.min, children: children)],
    );
  }
}
