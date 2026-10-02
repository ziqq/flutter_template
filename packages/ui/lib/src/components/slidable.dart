// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'package:flutter/cupertino.dart' show CupertinoDynamicColor, CupertinoIcons, CupertinoColors;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// The extent ratio of the [ActionPane] relatively to the enclosing [Slidable]
enum UISlidableExtentRatio {
  small(0.2),
  medium(0.25),
  large(0.35),
  xl(0.5);

  /// {@macro custom_slidable}
  const UISlidableExtentRatio(this.value);

  /// The value of the extent ratio.
  final double value;
}

/// {@template custom_slidable}
/// A custom [Slidable] widget.
/// {@endtemplate}
class UISlidable extends StatelessWidget {
  /// Creates a [Slidable].
  ///
  /// The [key] and [child] arguments must not be null.
  const UISlidable({
    required Key key,
    required this.child,
    this.confirmDismiss,
    this.onDismissed,
    this.backgroundColor,
    this.disabled = false,
    this.actions = const <Widget>[],
    this.extentRatio = UISlidableExtentRatio.medium,
  }) : super(key: key);

  /// Whether the trailing action pane is hidden.
  final bool disabled;

  /// The child widget.
  final Widget child;

  /// The actions that can be performed on the [Slidable].
  final List<Widget> actions;

  /// The background color of the action pane.
  final Color? backgroundColor;

  /// The total extent of this [ActionPane] relatively to the enclosing
  /// [Slidable] widget.
  ///
  /// Must be between 0 (excluded) and 1.
  ///
  /// Default value [UISlidableExtentRatio.medium]
  final UISlidableExtentRatio extentRatio;

  /// Signature used by [DismissiblePane] to give the application an opportunity
  /// to confirm or veto a dismiss gesture.
  ///
  /// Used by [DismissiblePane.confirmDismiss].
  final Future<bool> Function()? confirmDismiss;

  /// Removes the dismissed item from the caller-owned collection.
  final VoidCallback? onDismissed;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: backgroundColor),
    child: Slidable(
      endActionPane: disabled || actions.isEmpty
          ? null
          : ActionPane(
              motion: const DrawerMotion(),
              extentRatio: extentRatio.value,
              dismissible: onDismissed == null
                  ? null
                  : DismissiblePane(closeOnCancel: true, onDismissed: onDismissed!, confirmDismiss: confirmDismiss),
              children: actions,
            ),
      child: child,
    ),
  );
}

/// UISlidableAction widget.
///
/// Used to create a custom slidable action.
///
/// {@macro custom_slidable}
class UISlidableAction extends StatelessWidget {
  /// {@macro custom_slidable}
  const UISlidableAction({
    required this.backgroundColor,
    this.foregroundColor,
    this.child,
    this.label,
    this.icon,
    this.iconSize,
    this.onPressed,
    super.key, // ignore: unused_element_parameter
  }) : assert(child != null || (icon != null || label != null), 'Either child or icon or label must be provided');

  /// Delete slideble action.
  ///
  /// {@macro custom_slidable}
  factory UISlidableAction.delete({void Function()? onPressed, String? label, double? iconSize, Key? key}) =>
      _UISlidableAction(
        backgroundColor: CupertinoColors.systemRed,
        icon: CupertinoIcons.delete_solid,
        foregroundColor: Colors.white,
        onPressed: onPressed,
        iconSize: iconSize,
        label: label,
      );

  /// Edit slideble action.
  ///
  /// {@macro custom_slidable}
  factory UISlidableAction.edit({void Function()? onPressed, String? label, double? iconSize, Key? key}) =>
      _UISlidableAction(
        backgroundColor: CupertinoColors.systemIndigo,
        foregroundColor: Colors.white,
        icon: CupertinoIcons.pencil,
        onPressed: onPressed,
        iconSize: iconSize,
        label: label,
      );

  /// The label of the action.
  final String? label;

  /// The child widget.
  final Widget? child;

  /// The icon of the action.
  final IconData? icon;

  /// The size of the icon.
  final double? iconSize;

  /// The background color of the action.
  final Color backgroundColor;

  /// The foreground color of the action.
  final Color? foregroundColor;

  /// The callback that is called when the action is tapped.
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomSlidableAction(
      onPressed: onPressed == null ? null : (_) => onPressed!(),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: EdgeInsets.zero,
      child:
          child ??
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: foregroundColor),
              if (label != null && label!.isNotEmpty) ...[
                Text(
                  label!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: theme.textTheme.labelSmall?.fontSize,
                    fontWeight: FontWeight.w600,
                    color: foregroundColor,
                  ),
                ),
              ],
            ],
          ),
    );
  }
}

class _UISlidableAction extends UISlidableAction {
  const _UISlidableAction({
    required super.backgroundColor,
    super.foregroundColor,
    super.onPressed,
    super.label,
    super.icon,
    super.iconSize,
    super.key, // ignore: unused_element_parameter
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomSlidableAction(
      onPressed: onPressed == null ? null : (_) => onPressed!(),
      backgroundColor: CupertinoDynamicColor.resolve(backgroundColor, context),
      foregroundColor: foregroundColor,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: foregroundColor),
          if (label != null && label!.isNotEmpty) ...[
            Text(
              label!,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: theme.textTheme.labelSmall?.fontSize,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
