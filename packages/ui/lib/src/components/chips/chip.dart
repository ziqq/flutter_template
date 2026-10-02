/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 */

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:ui/ui.dart';

/// {@template chip}
/// UIChip widget.
/// {@endtemplate}
class UIChip extends StatelessWidget {
  /// Default chip
  /// {@macro chip}
  const UIChip({
    required this.label,
    this.labelStyle,
    this.onTap,
    this.height,
    this.leading,
    this.trailing,
    this.onClear,
    this.padding,
    this.borderRadius,
    this.textColor,
    this.activeTextColor,
    this.backgroundColor,
    this.activeBackgroundColor,
    this.closeBtnColor,
    this.closeBtnBackgroundColor,
    this.isSelected = false,
    this.useBoxShadow = true,
    super.key,
  });

  /// Date select chip variant
  /// {@macro chip}
  const factory UIChip.date({
    DateTime? startDate,
    DateTime? endDate,
    bool? withOutYear,
    bool? secondary,
    bool? isSelected,
    bool? useBoxShadow,
    bool? useTralling,
    Widget? leading,
    Widget? trailing,
    void Function()? onTap,
    void Function()? onClear,
    Color? backgroundColor,
  }) = _UIChip$Date;

  /// Small chip variant
  /// {@macro chip}
  const factory UIChip.small({
    required String label,
    EdgeInsetsGeometry? padding,
    TextStyle? labelStyle,
    bool? secondary,
    bool? isSelected,
    bool? useBoxShadow,
    Widget? leading,
    Widget? trailing,
    void Function()? onTap,
    void Function()? onClear,
    Color? backgroundColor,
    Key? key,
  }) = _UIChip$Small;

  /// Editable chip variant. Used for tags how can be edited / removed.
  /// {@macro chip}
  const factory UIChip.editable({
    required String label,
    required Color color,
    bool isPreview,
    bool isSelected,
    Color? backgroundColor,
    void Function()? onClear,
    Key? key,
  }) = _UIChip$Editable;

  /// Is selected?
  final bool isSelected;

  /// Use box shadow?
  final bool useBoxShadow;

  /// Height of chip
  final double? height;

  /// Label of chip
  final String label;

  /// Label style
  final TextStyle? labelStyle;

  /// Text color of chip
  final Color? textColor;

  /// Active text color of chip
  final Color? activeTextColor;

  /// Background color of chip
  final Color? backgroundColor;

  /// Close button color
  final Color? closeBtnColor;

  /// Close button background color
  final Color? closeBtnBackgroundColor;

  /// Active background color of chip
  final Color? activeBackgroundColor;

  /// Border radius of chip
  final BorderRadiusGeometry? borderRadius;

  /// Padding of chip
  final EdgeInsetsGeometry? padding;

  /// Leading widget
  final Widget? leading;

  /// Trailing widget
  final Widget? trailing;

  /// Tap callback
  final void Function()? onTap;

  /// Clear callback
  final void Function()? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uiTheme = theme.uiTheme;

    final effectiveBackgroundColor = isSelected
        ? activeBackgroundColor ?? uiTheme.color.accent
        : backgroundColor ?? CupertinoDynamicColor.resolve(CupertinoColors.quaternarySystemFill, context);

    final effectiveTextColor = isSelected
        ? activeTextColor ?? Colors.white
        : textColor ?? theme.textTheme.bodyLarge?.color;

    final radius = borderRadius ?? BorderRadius.circular(30);
    return RawChip(
      avatar: leading,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
          if (trailing != null) ...[SizedBox(width: uiTheme.size.offset.small), trailing!],
        ],
      ),
      labelStyle: labelStyle ?? theme.textTheme.bodyMedium?.copyWith(color: effectiveTextColor),
      labelPadding: padding ?? EdgeInsets.symmetric(horizontal: uiTheme.size.offset.small),
      padding: EdgeInsets.symmetric(vertical: height == null ? 0 : (height! - 24).clamp(0, double.infinity) / 2),
      shape: RoundedRectangleBorder(borderRadius: radius),
      side: BorderSide.none,
      backgroundColor: effectiveBackgroundColor,
      selectedColor: effectiveBackgroundColor,
      selected: isSelected,
      showCheckmark: false,
      elevation: useBoxShadow ? 1 : 0,
      tapEnabled: onTap != null,
      onPressed: onTap,
      onDeleted: onClear,
      deleteButtonTooltipMessage: UILocalizations.of(context).clearLabel,
      deleteIcon: Icon(Icons.cancel, color: closeBtnColor ?? effectiveTextColor, size: 18),
    );
  }
}

/// _UIChip$Small widget.
class _UIChip$Date extends UIChip {
  /// {@macro chip}
  const _UIChip$Date({
    this._startDate,
    this._endDate,
    bool? secondary,
    bool? isSelected,
    bool? useBoxShadow,
    bool? useTralling,
    bool? withOutYear,
    super.onTap,
    super.leading,
    super.trailing,
    super.onClear,
    super.backgroundColor,
    super.key, // ignore: unused_element_parameter
  }) : _secondary = secondary ?? false,
       _useTralling = useTralling ?? true,
       _withOutYear = withOutYear ?? true,
       super(label: '', isSelected: isSelected ?? false, useBoxShadow: useBoxShadow ?? true);

  final DateTime? _startDate;
  final DateTime? _endDate;
  final bool _secondary;
  final bool _useTralling;
  final bool _withOutYear;

  /// Check if two dates are the same day
  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  /// Get current date
  DateTime get _now => DateTime.now();

  /// Build label string
  String _buildLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final pattern = 'd MMM${_withOutYear ? '' : ' yyyy'}';
    final l10n = UILocalizations.of(context);
    final start = _startDate;
    final end = _endDate;

    /// Format date to string
    String format(DateTime date, String pattern) => DateFormat(pattern, locale).format(date).replaceAll('.', '');

    // No dates
    if (start == null && end == null) return l10n.todayLabel;

    // Only one date
    if (start != null && end == null) {
      return _sameDay(start, _now) ? l10n.todayLabel : format(start, pattern);
    }
    if (start == null && end != null) {
      return _sameDay(end, _now) ? l10n.todayLabel : format(end, pattern);
    }

    // Two dates
    if (_sameDay(start!, end!)) {
      return _sameDay(start, _now) ? l10n.todayLabel : format(start, pattern);
    }

    // Different years
    if (start.year != end.year) {
      return '${format(start, 'd MMM yyyy')} - ${format(end, 'd MMM yyyy')}';
    }

    // Same year, different months
    if (start.month != end.month) {
      final p = 'd MMM${_withOutYear ? '' : ' yyyy'}';
      return '${format(start, p)} - ${format(end, p)}';
    }

    // Same month, different days
    if (start.day != end.day) {
      final endPattern = 'd MMM${_withOutYear ? '' : ' yyyy'}';
      return '${format(start, 'd')} - ${format(end, endPattern)}';
    }

    // Fallback
    return format(end, pattern);
  }

  /// Build trailing widget
  Widget? _buildTralling(BuildContext context) {
    final backgroundColor = this.backgroundColor;
    if (trailing != null) return trailing;
    if (_useTralling) {
      final theme = Theme.of(context);
      return Icon(
        Icons.keyboard_arrow_down_rounded,
        size: theme.uiTheme.size.icon.extraSmall,
        color: isSelected
            ? Colors.white
            : backgroundColor != null
            ? UIColorUtil.contrastingForegroundColor(
                backgroundColor,
                lightColor: Colors.white,
                darkColor: theme.uiTheme.color.text,
                backdropColor: theme.uiTheme.color.background,
              )
            : theme.uiTheme.color.text,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => _UIChip$Small(
    trailing: _buildTralling(context),
    label: _buildLabel(context),
    onTap: onTap,
    leading: leading,
    secondary: _secondary,
    isSelected: isSelected,
    useBoxShadow: useBoxShadow,
    onClear: _startDate == null && _endDate == null ? null : onClear,
    backgroundColor: backgroundColor,
  );
}

/// _UIChip$Small widget.
class _UIChip$Small extends UIChip {
  /// {@macro chip}
  const _UIChip$Small({
    required super.label,
    super.labelStyle,
    super.leading,
    super.padding,
    super.onClear,
    super.onTap,
    super.trailing,
    bool? secondary,
    bool? isSelected,
    bool? useBoxShadow,
    this._backgroundColor,
    super.key, // ignore: unused_element_parameter
  }) : _secondary = secondary ?? true,
       super(isSelected: isSelected ?? false, useBoxShadow: useBoxShadow ?? true);

  /// Background color of chip
  final Color? _backgroundColor;

  /// Whether the background color is secondary
  final bool _secondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveBackgroundColor = isSelected
        ? theme.uiTheme.color.accent
        : _backgroundColor ??
              (_secondary
                  ? (theme.brightness == Brightness.dark)
                        ? CupertinoDynamicColor.resolve(CupertinoColors.quaternarySystemFill, context)
                        : theme.uiTheme.color.surface
                  : CupertinoDynamicColor.resolve(CupertinoColors.quaternarySystemFill, context));

    final effectiveTextColor = isSelected
        ? Colors.white
        : textColor ??
              (_backgroundColor != null
                  ? UIColorUtil.contrastingForegroundColor(
                      _backgroundColor,
                      backdropColor: theme.uiTheme.color.background,
                      lightColor: Colors.white,
                      darkColor: theme.uiTheme.color.text,
                    )
                  : theme.uiTheme.color.text);

    return UIChip(
      label: label,
      labelStyle: labelStyle ?? theme.textTheme.bodySmall?.copyWith(color: effectiveTextColor),
      leading: leading,
      trailing: trailing,
      onTap: onTap,
      onClear: onClear,
      padding: padding,
      isSelected: isSelected,
      useBoxShadow: useBoxShadow && !_secondary && theme.brightness == Brightness.light,
      backgroundColor: effectiveBackgroundColor,
      activeBackgroundColor: effectiveBackgroundColor,
      textColor: effectiveTextColor,
      activeTextColor: effectiveTextColor,
      closeBtnColor: closeBtnColor,
      closeBtnBackgroundColor: closeBtnBackgroundColor,
    );
  }
}

/// _UIChip$Editable widget.
class _UIChip$Editable extends UIChip {
  const _UIChip$Editable({
    required super.label,
    required this.color,
    this.isPreview = false,
    super.onClear,
    super.isSelected,
    super.backgroundColor,
    super.key, // ignore: unused_element_parameter
  });

  /// Is preview mode?
  ///
  /// Usually used for previewing the tag in [CupertinoContextMenu].
  final bool isPreview;

  /// The chip color.
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(canvasColor: Colors.transparent),
      child: Chip(
        // chipAnimationStyle: ChipAnimationStyle(
        //   enableAnimation: AnimationStyle.noAnimation,
        //   selectAnimation: AnimationStyle.noAnimation,
        //   avatarDrawerAnimation: AnimationStyle.noAnimation,
        //   deleteDrawerAnimation: AnimationStyle.noAnimation,
        // ),
        elevation: 0,
        onDeleted: onClear,
        deleteIconColor: color,
        padding: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        labelPadding: EdgeInsets.only(
          left: theme.uiTheme.indent,
          right: (isSelected && !isPreview) ? 0 : theme.uiTheme.indent,
        ),
        deleteIconBoxConstraints: isPreview ? BoxConstraints.tight(Size.zero) : null,
        deleteIcon: isPreview ? const SizedBox.shrink() : const Icon(CupertinoIcons.clear_thick_circled, size: 20),
        label: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            height: 1.35,
            color: isPreview
                ? Colors.white
                : isSelected
                ? color
                : theme.uiTheme.color.text,
          ),
        ),
        backgroundColor: isPreview
            ? color
            : isSelected
            ? color.withAlpha(25)
            : backgroundColor ?? theme.uiTheme.color.background,
        side: BorderSide(
          color: isPreview
              ? color
              : isSelected
              ? color.withAlpha(1)
              : (backgroundColor ?? theme.dividerColor),
        ),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
      ),
    );
  }
}
