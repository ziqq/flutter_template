import 'package:flutter/cupertino.dart';
import 'package:ui/ui.dart';

/// {@template list_section}
/// UIListSection widget.
///
/// Custom [CupertinoListSection] widget with additional properties.
/// {@endtemplate}
class UIListSection extends StatelessWidget {
  /// {@macro list_section}
  const UIListSection({
    this.additionalDividerMargin,
    this.dividerMargin = 0,
    this.margin,
    this.headerButton,
    this.textHeader,
    this.textFooter,
    this.borderRadius,
    this.backgroundColor,
    this.clipBehavior = Clip.hardEdge,
    this.children,
    this.topMargin,
    this.useSeparator = true,
    bool? secodary,
    super.key,
  }) : _secodary = secodary ?? false;

  /// {@macro list_section}
  const factory UIListSection.secodary({
    bool useSeparator,
    double dividerMargin,
    double? additionalDividerMargin,
    String? textHeader,
    String? textFooter,
    double? topMargin,
    Clip clipBehavior,
    Color? backgroundColor,
    EdgeInsetsGeometry? margin,
    BorderRadiusGeometry? borderRadius,
    Widget? headerButton,
    List<Widget>? children,
  }) = _UIListSection$Secodary;

  final bool useSeparator;

  /// The top margin of section.
  final double? topMargin;

  /// The [dividerMargin] parameter sets the starting offset of the divider between rows.
  ///
  /// The default value is 0.
  final double dividerMargin;

  /// The [additionalDividerMargin] parameter adds additional margin to existing [dividerMargin] when [hasLeading] is set to true. By default, it offsets for the width of leading and space between leading and title of [CupertinoListTile], but it can be overwritten for custom look.
  ///
  /// The default value is 16.0 as [Theme.of(context).uiTheme.padding].
  final double? additionalDividerMargin;

  /// The [textHeader] parameter sets the header text of the section.
  final String? textHeader;

  /// The [textFooter] parameter sets the footer text of the section.
  final String? textFooter;

  /// The [borderRadius] parameter sets the border radius of the section.
  final BorderRadiusGeometry? borderRadius;

  /// The [margin] parameter sets the margin of the section.
  final EdgeInsetsGeometry? margin;

  /// Sets the background color behind the section.
  ///
  /// Defaults to [UITheme.color.onBackground]
  /// or [UITheme.color.onSecondaryBackground].
  final Color? backgroundColor;

  /// {@macro flutter.material.Material.clipBehavior}
  final Clip clipBehavior;

  /// The header button.
  final Widget? headerButton;

  /// The list of rows in the section.
  final List<Widget>? children;

  /// Use secondary variant?
  final bool _secodary;

  /// Build header or footer widget.
  Widget? _buildHeaderOrFooterOrNull(BuildContext context, String? text, {bool isHeader = true}) {
    Widget? child;
    if (text != null) {
      child = Transform(
        transform: Matrix4.translationValues(-4, 0, 0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(height: 1.1, fontWeight: FontWeight.w400),
        ),
      );
    }
    if ((headerButton == null || !isHeader) && child != null) return child;
    if (headerButton != null && isHeader && child != null) {
      return Row(mainAxisAlignment: .spaceBetween, children: [child, ?headerButton]);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final uiTheme = Theme.of(context).uiTheme;
    return CupertinoListSection.insetGrouped(
      topMargin: topMargin,
      clipBehavior: clipBehavior,
      dividerMargin: dividerMargin,
      backgroundColor: backgroundColor ?? Colors.transparent,
      separatorColor: useSeparator ? null : Colors.transparent,
      additionalDividerMargin: additionalDividerMargin ?? uiTheme.padding,
      margin: margin ?? (textFooter == null ? EdgeInsets.zero : EdgeInsets.only(bottom: uiTheme.padding / 2)),
      decoration: BoxDecoration(
        color: backgroundColor ?? (_secodary ? uiTheme.color.onSecondaryBackground : uiTheme.color.onBackground),
        borderRadius: borderRadius ?? UIBorderRadius.regular(context),
      ),
      header: _buildHeaderOrFooterOrNull(context, textHeader, isHeader: true),
      footer: _buildHeaderOrFooterOrNull(context, textFooter, isHeader: false),
      children: children == null || children!.isEmpty ? [const SizedBox.shrink()] : children,
    );
  }
}

/// {@macro list_section}
/// Secodary variant of [UIListSection] with reversed background color.
class _UIListSection$Secodary extends UIListSection {
  const _UIListSection$Secodary({
    super.additionalDividerMargin,
    super.dividerMargin,
    super.useSeparator,
    super.topMargin,
    super.margin,
    super.headerButton,
    super.textHeader,
    super.textFooter,
    super.borderRadius,
    super.backgroundColor,
    super.clipBehavior = Clip.hardEdge,
    super.children,
  }) : super(secodary: true);
}
