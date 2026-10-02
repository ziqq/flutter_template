import 'package:flutter/cupertino.dart'
    show CupertinoColors, CupertinoDynamicColor, CupertinoIcons, CupertinoMenuAnchor;
import 'package:flutter/material.dart';
import 'package:ui/src/theme/theme.dart';

/// A theme-aware row for short lists and settings groups.
///
/// The caller owns the content and action.
class UIListTile extends StatelessWidget {
  /// Creates a list row with caller-owned leading, text, and trailing content.
  const UIListTile({
    required this.title,
    this.leading,
    this.subtitle,
    this.additionalInfo,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.padding,
    this.leadingSize,
    this.leadingToTitle,
    this.minHeight,
    super.key,
  }) : menuChildren = null;

  /// Creates a row that opens a Cupertino menu with caller-owned items.
  const UIListTile.selectable({
    required this.title,
    required this.menuChildren,
    this.leading,
    this.subtitle,
    this.additionalInfo,
    this.enabled = true,
    this.padding,
    this.leadingSize,
    this.leadingToTitle,
    this.minHeight,
    super.key,
  }) : trailing = null,
       onTap = null;

  /// The row's primary content.
  final Widget title;

  /// Content before [title].
  final Widget? leading;

  /// Supporting content below [title].
  final Widget? subtitle;

  /// Content after [title] and before [trailing].
  final Widget? additionalInfo;

  /// Content at the end of the row.
  final Widget? trailing;

  /// The action performed when the row is activated.
  final VoidCallback? onTap;

  /// Whether the row and its action are available.
  final bool enabled;

  /// Insets around the row content.
  final EdgeInsetsGeometry? padding;

  /// The square slot reserved for [leading].
  final double? leadingSize;

  /// The gap between [leading] and the text.
  final double? leadingToTitle;

  /// The minimum height of the row.
  final double? minHeight;

  /// The caller-owned menu entries used by [UIListTile.selectable].
  final List<Widget>? menuChildren;

  @override
  Widget build(BuildContext context) {
    final menuChildren = this.menuChildren;
    if (menuChildren == null) {
      return _buildTile(context, onTap: onTap, enabled: enabled);
    }
    return _SelectableListTile(tile: this, menuChildren: menuChildren);
  }

  Widget _buildTile(
    BuildContext context, {
    required VoidCallback? onTap,
    required bool enabled,
    bool selectable = false,
    FocusNode? focusNode,
  }) {
    final uiTheme = Theme.of(context).uiTheme;

    Widget content = LayoutBuilder(
      builder: (context, constraints) => Row(
        children: <Widget>[
          if (leading != null) ...<Widget>[
            SizedBox.square(
              dimension: leadingSize ?? uiTheme.size.icon.regular,
              child: Center(child: leading),
            ),
            SizedBox(width: leadingToTitle ?? uiTheme.size.offset.small),
          ],
          Expanded(
            flex: additionalInfo == null ? 1 : 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DefaultTextStyle(
                  style: Theme.of(context).textTheme.bodyLarge ?? DefaultTextStyle.of(context).style,
                  child: title,
                ),
                if (subtitle != null)
                  DefaultTextStyle(
                    style:
                        Theme.of(context).textTheme.bodySmall?.copyWith(color: uiTheme.color.textSecondary) ??
                        DefaultTextStyle.of(context).style,
                    child: subtitle!,
                  ),
              ],
            ),
          ),
          if (additionalInfo != null) ...<Widget>[
            SizedBox(width: uiTheme.size.offset.extraSmall),
            Flexible(
              fit: FlexFit.tight,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: DefaultTextStyle(
                  style:
                      Theme.of(context).textTheme.bodyMedium?.copyWith(color: uiTheme.color.textSecondary) ??
                      DefaultTextStyle.of(context).style,
                  child: additionalInfo!,
                ),
              ),
            ),
          ],
          if (trailing != null || onTap != null) ...<Widget>[
            SizedBox(width: uiTheme.size.offset.extraSmall),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.45),
              child:
                  trailing ??
                  Icon(
                    selectable ? CupertinoIcons.chevron_up_chevron_down : CupertinoIcons.chevron_right,
                    size: uiTheme.size.icon.extraSmall,
                    color: CupertinoDynamicColor.resolve(CupertinoColors.inactiveGray, context),
                  ),
            ),
          ],
        ],
      ),
    );
    if (!enabled) {
      content = ColorFiltered(colorFilter: ColorFilter.mode(uiTheme.color.onDisabled, BlendMode.srcIn), child: content);
    }

    return Semantics(
      button: onTap != null,
      enabled: onTap == null ? null : enabled,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          focusNode: focusNode,
          onTap: enabled ? onTap : null,
          canRequestFocus: enabled && onTap != null,
          mouseCursor: enabled && onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed) || states.contains(WidgetState.focused)) {
              return uiTheme.color.selected;
            }
            if (states.contains(WidgetState.hovered)) return uiTheme.color.selected.withValues(alpha: 0.5);
            return null;
          }),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity, minHeight: minHeight ?? uiTheme.size.button.medium),
            child: Padding(
              padding:
                  padding ??
                  EdgeInsetsDirectional.symmetric(
                    horizontal: uiTheme.size.offset.regular,
                    vertical: uiTheme.size.offset.extraSmall,
                  ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectableListTile extends StatefulWidget {
  const _SelectableListTile({required this.tile, required this.menuChildren});

  final UIListTile tile;
  final List<Widget> menuChildren;

  @override
  State<_SelectableListTile> createState() => _SelectableListTileState();
}

class _SelectableListTileState extends State<_SelectableListTile> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CupertinoMenuAnchor(
    menuChildren: widget.menuChildren,
    childFocusNode: _focusNode,
    builder: (context, controller, _) => widget.tile._buildTile(
      context,
      enabled: widget.tile.enabled && widget.menuChildren.isNotEmpty,
      selectable: true,
      focusNode: _focusNode,
      onTap: () {
        if (controller.isOpen) {
          controller.close();
        } else {
          controller.open();
        }
      },
    ),
  );
}
