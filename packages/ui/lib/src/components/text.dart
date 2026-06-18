import 'package:flutter/material.dart';

// UIText widget to handle different text styles and sizes
class UIText extends StatelessWidget {
  const UIText._(
    this.content, {
    this.color,
    this.fontWeight,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    TextStyle? Function(TextTheme)? styleBuilder,
  }) : _styleBuilder = styleBuilder;

  /// Creates a [UIText] widget with a large display size.
  factory UIText.displayLarge(
    String content, {
    Color? color,
    FontWeight? fontWeight,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => UIText._(
    content,
    color: color,
    fontWeight: fontWeight,
    style: style,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    styleBuilder: (textTheme) => textTheme.displayLarge,
  );

  /// Creates a [UIText] widget with a medium display size.
  factory UIText.displayMedium(
    String content, {
    Color? color,
    FontWeight? fontWeight,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => UIText._(
    content,
    color: color,
    fontWeight: fontWeight,
    style: style,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    styleBuilder: (textTheme) => textTheme.displayMedium,
  );

  /// Creates a [UIText] widget with a small display size.
  factory UIText.displaySmall(
    String content, {
    Color? color,
    FontWeight? fontWeight,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => UIText._(
    content,
    color: color,
    fontWeight: fontWeight,
    style: style,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    styleBuilder: (textTheme) => textTheme.displaySmall,
  );

  /// Creates a [UIText] widget with a large headline size.
  factory UIText.headlineLarge(
    String content, {
    Color? color,
    FontWeight? fontWeight,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => UIText._(
    content,
    color: color,
    fontWeight: fontWeight,
    style: style,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    styleBuilder: (textTheme) => textTheme.headlineLarge,
  );

  /// Creates a [UIText] widget with a medium headline size.
  factory UIText.headlineMedium(
    String content, {
    Color? color,
    FontWeight? fontWeight,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => UIText._(
    content,
    color: color,
    fontWeight: fontWeight,
    style: style,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    styleBuilder: (textTheme) => textTheme.headlineMedium,
  );

  /// Creates a [UIText] widget with a small headline size.
  factory UIText.headlineSmall(
    String content, {
    Color? color,
    FontWeight? fontWeight,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => UIText._(
    content,
    color: color,
    fontWeight: fontWeight,
    style: style,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    styleBuilder: (textTheme) => textTheme.headlineSmall,
  );

  /// Creates a [UIText] widget with a large title size.
  factory UIText.titleLarge(
    String content, {
    Color? color,
    FontWeight? fontWeight,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => UIText._(
    content,
    color: color,
    fontWeight: fontWeight,
    style: style,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    styleBuilder: (textTheme) => textTheme.titleLarge,
  );

  /// Creates a [UIText] widget with a medium title size.
  factory UIText.titleMedium(
    String content, {
    Color? color,
    FontWeight? fontWeight,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => UIText._(
    content,
    color: color,
    fontWeight: fontWeight,
    style: style,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    styleBuilder: (textTheme) => textTheme.titleMedium,
  );

  /// Creates a [UIText] widget with a small title size.
  factory UIText.titleSmall(
    String content, {
    Color? color,
    FontWeight? fontWeight,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => UIText._(
    content,
    color: color,
    fontWeight: fontWeight,
    style: style,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    styleBuilder: (textTheme) => textTheme.titleSmall,
  );

  /// Creates a [UIText] widget with a large body size.
  factory UIText.bodyLarge(
    String content, {
    Color? color,
    FontWeight? fontWeight,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => UIText._(
    content,
    color: color,
    fontWeight: fontWeight,
    style: style,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    styleBuilder: (textTheme) => textTheme.bodyLarge,
  );

  /// Creates a [UIText] widget with a medium body size.
  factory UIText.bodyMedium(
    String content, {
    Color? color,
    FontWeight? fontWeight,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => UIText._(
    content,
    color: color,
    fontWeight: fontWeight,
    style: style,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    styleBuilder: (textTheme) => textTheme.bodyMedium,
  );

  /// Creates a [UIText] widget with a small body size.
  factory UIText.bodySmall(
    String content, {
    Color? color,
    FontWeight? fontWeight,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => UIText._(
    content,
    color: color,
    fontWeight: fontWeight,
    style: style,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    styleBuilder: (textTheme) => textTheme.bodySmall,
  );

  /// Creates a [UIText] widget with a large label size.
  factory UIText.labelLarge(
    String content, {
    Color? color,
    FontWeight? fontWeight,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => UIText._(
    content,
    color: color,
    fontWeight: fontWeight,
    style: style,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    styleBuilder: (textTheme) => textTheme.labelLarge,
  );

  /// Creates a [UIText] widget with a medium label size.
  factory UIText.labelMedium(
    String content, {
    Color? color,
    FontWeight? fontWeight,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => UIText._(
    content,
    color: color,
    fontWeight: fontWeight,
    style: style,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    styleBuilder: (textTheme) => textTheme.labelMedium,
  );

  /// Creates a [UIText] widget with a small label size.
  factory UIText.labelSmall(
    String content, {
    Color? color,
    FontWeight? fontWeight,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => UIText._(
    content,
    color: color,
    fontWeight: fontWeight,
    style: style,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    styleBuilder: (textTheme) => textTheme.labelSmall,
  );

  final String content;
  final TextStyle? style;

  /// {@macro flutter.widgets.editableText.textAlign}
  final TextAlign? textAlign;
  final TextOverflow? overflow;

  /// {@macro flutter.widgets.editableText.maxLines}
  final int? maxLines;
  final Color? color;
  final FontWeight? fontWeight;
  final TextStyle? Function(TextTheme)? _styleBuilder;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Get the text style based on the size
    final style = _styleBuilder?.call(textTheme) ?? textTheme.bodyLarge;

    return Text(
      content,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      style: style?.copyWith(color: color, fontWeight: fontWeight),
    );
  }
}
