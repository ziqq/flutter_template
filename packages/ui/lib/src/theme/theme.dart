import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:ui/ui.dart';

export 'extensions/colors.dart';
export 'extensions/sizes.dart';
export 'theme_helpers.dart';

/// Default indent value.
const double _kDefaultIndent = 10;

/// Default padding value.
const double _kDefaultPadding = 16;

/// Default padding value.
const double _kDefaultItemMultiplier = 0.85;

/// {@template theme}
/// UI theme data.
/// Custom implementation of [ThemeData].
/// {@endtemplate}
extension type UIThemeData._(ThemeData data) implements ThemeData {
  /// Create [UIThemeData] for light theme.
  /// Given optional [accent] color.
  /// {@macro theme}
  factory UIThemeData.light({Color? accent}) =>
      UIThemeData._($createThemeData(brightness: Brightness.light, accent: accent));

  /// Create [UIThemeData] for dark theme.
  /// Given optional [accent] color.
  /// {@macro theme}
  factory UIThemeData.dark({Color? accent}) =>
      UIThemeData._($createThemeData(brightness: Brightness.dark, accent: accent));
}

/// An extension for theme to get color palette and typography from [BuildContext].
extension ThemeDataExtensions on ThemeData {
  /// Returns the [UITheme].
  UITheme get uiTheme {
    final isDark = brightness == Brightness.dark;
    final ext = extension<UITheme>();
    if (ext == null) {
      final accent = extension<UIColors>()?.accent;
      return isDark ? UITheme.dark(accent: accent) : UITheme.light(accent: accent);
    }
    if (ext.color.brightness != brightness) {
      // Auto‑correct mismatch.
      return isDark ? UITheme.dark(accent: ext.color.accent) : UITheme.light(accent: ext.color.accent);
    }
    return ext;
  }
}

/// {@template theme}
/// Custom theme for ui package.
/// {@endtemplate}
@immutable
final class UITheme extends ThemeExtension<UITheme> with Diagnosticable {
  /// {@macro theme}
  factory UITheme({
    double? indent,
    double? padding,
    double? itemMultiplier,
    UIGradients? gradient,
    UIColors? color,
    UISizes? size,
    UISocialColors? socialColor,
    TextStyle? placeholderStyle,
  }) {
    indent ??= _kDefaultIndent;
    padding ??= _kDefaultPadding;
    itemMultiplier ??= _kDefaultItemMultiplier;
    color ??= $generateUIColorsForBrightness(Brightness.light);
    size ??= const UISizes.empty();
    gradient ??= const UIGradients.empty();
    socialColor ??= const UISocialColors.empty();
    return UITheme.raw(
      indent: indent,
      padding: padding,
      itemMultiplier: itemMultiplier,
      color: color,
      size: size,
      socialColor: socialColor,
      gradient: gradient,
      placeholderStyle: placeholderStyle,
    );
  }

  /// Create a [UITheme] given a set of exact values.
  const UITheme.raw({
    required this.indent,
    required this.padding,
    required this.itemMultiplier,
    required this.color,
    required this.size,
    required this.socialColor,
    required this.gradient,
    this.placeholderStyle,
  });

  /// A light ui theme.
  factory UITheme.light({UIColors? colors, Color? accent}) {
    final color = colors ?? $generateUIColorsForBrightness(Brightness.light, accent: accent);
    final placeholderColor = color.textSecondary.withValues(alpha: 0.55);
    return UITheme(
      color: color,
      placeholderStyle: TextStyle(fontSize: 17, color: placeholderColor, fontWeight: FontWeight.w400),
    );
  }

  /// A dark ui theme.
  factory UITheme.dark({UIColors? colors, Color? accent}) {
    final color = colors ?? $generateUIColorsForBrightness(Brightness.dark, accent: accent);
    final placeholderColor = color.textSecondary.withValues(alpha: 0.55);
    return UITheme(
      color: color,
      placeholderStyle: TextStyle(fontSize: 17, color: placeholderColor, fontWeight: FontWeight.w400),
    );
  }

  /// Get [UITheme] from [InheritedUITheme].
  ///
  /// If that's null get [UITheme] from [ThemeData.extensions]
  /// property of the ambient [Theme].
  static UITheme? maybeOf(BuildContext context) {
    // Canonical: ThemeData extension.
    final theme = Theme.of(context);
    final ext = theme.extension<UITheme>();
    if (ext != null) return ext;
    // Fallback only if brightness matches.
    final inh = InheritedUITheme.maybeOf(context);
    if (inh != null && inh.color.brightness == theme.brightness) return inh;
    return null;
  }

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
    'Out of scope or out of extensions, not found inherited widget '
        'a UITheme of the exact type',
    'out_of_scope or out_of_extensions',
  );

  /// The state from the closest instance of this class
  /// that encloses the given context.
  /// e.g. `UITheme.of(context)`
  static UITheme of(BuildContext context) => maybeOf(context) ?? _notFoundInheritedWidgetOfExactType();

  /// Base indent
  final double indent;

  /// Base padding
  final double padding;

  /// A multiplier for items of a horizontal list that has more than 2 items.
  final double itemMultiplier;

  /// Placeholder style
  final TextStyle? placeholderStyle;

  /// Sizes scheme
  final UISizes size;

  /// Color palette
  final UIColors color;

  /// Gradient schemes
  final UIGradients gradient;

  /// Social colors scheme
  final UISocialColors socialColor;

  @useResult
  @override
  UITheme copyWith({
    double? indent,
    double? padding,
    double? itemMultiplier,
    UIColors? color,
    UISizes? size,
    UISocialColors? socialColor,
    TextStyle? placeholderStyle,
  }) => UITheme(
    indent: indent ?? this.indent,
    padding: padding ?? this.padding,
    itemMultiplier: itemMultiplier ?? this.itemMultiplier,
    color: color ?? this.color,
    socialColor: socialColor ?? this.socialColor,
    size: size ?? this.size,
    placeholderStyle: placeholderStyle ?? this.placeholderStyle,
  );

  /// Controls how the properties change on theme changes
  @override
  ThemeExtension<UITheme> lerp(ThemeExtension<UITheme>? other, double t) {
    if (other == null || identical(this, other) || other is! UITheme) {
      return this;
    }
    return UITheme(
      indent: ui.lerpDouble(indent, other.indent, t),
      padding: ui.lerpDouble(padding, other.padding, t),
      itemMultiplier: ui.lerpDouble(itemMultiplier, other.itemMultiplier, t),
      placeholderStyle: TextStyle.lerp(placeholderStyle, other.placeholderStyle, t),
    );
  }

  @override
  int get hashCode => Object.hashAll([indent, padding, itemMultiplier, placeholderStyle, size, color, socialColor]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UITheme &&
          other.indent == indent &&
          other.padding == padding &&
          other.itemMultiplier == itemMultiplier &&
          other.placeholderStyle == placeholderStyle &&
          identical(other.size, size) &&
          identical(other.color, color) &&
          identical(other.socialColor, socialColor);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('indent', indent, defaultValue: _kDefaultIndent))
      ..add(DoubleProperty('padding', padding, defaultValue: _kDefaultPadding))
      ..add(DoubleProperty('itemMultiplier', itemMultiplier, defaultValue: _kDefaultItemMultiplier))
      ..add(DiagnosticsProperty<TextStyle?>('placeholderStyle', placeholderStyle, defaultValue: null))
      ..add(DiagnosticsProperty<UISizes>('size', size, defaultValue: const UISizes.empty()))
      ..add(
        DiagnosticsProperty<UIColors>('color', color, defaultValue: $generateUIColorsForBrightness(Brightness.light)),
      )
      ..add(
        DiagnosticsProperty<UISocialColors>('socialColor', socialColor, defaultValue: const UISocialColors.empty()),
      );
  }
}

/// Alternative way of defining [UITheme].
///
/// Example:
///
/// ```dart
/// CupertinoApp(
///    builder: (context, child) => InheritedUITheme(
///      data: const UITheme(
///        ...
///      ),
///      child: child!,
///  ),
/// home: ...,
/// ```
@immutable
class InheritedUITheme extends InheritedTheme {
  /// Creates a [InheritedUITheme].
  const InheritedUITheme({required this.data, required super.child, super.key});

  /// The configuration of this theme.
  final UITheme data;

  /// Returns the current [UITheme] from the closest
  /// [InheritedUITheme] ancestor.
  ///
  /// If there is no ancestor, it returns `null`.
  static UITheme? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<InheritedUITheme>()?.data;

  @override
  bool updateShouldNotify(covariant InheritedUITheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) => InheritedUITheme(data: data, child: child);
}

/// {@template social_colors_scheme}
/// Custom social color for the ui kit
///
/// Social colors:
/// - [telegram] - Telegram color
/// - [viber] - Viber color
/// - [vk] - VK color
/// - [whatsapp] - WhatsApp color
/// {@endtemplate}
@immutable
class UISocialColors {
  /// {@macro social_colors_scheme}
  const UISocialColors({required this.telegram, required this.viber, required this.vk, required this.whatsapp});

  /// {@macro social_colors_scheme}
  ///
  /// A default social color scheme.
  const factory UISocialColors.empty() = _UISocialColors$Default;

  /// Telegram color
  final Color telegram;

  /// Viber color
  final Color viber;

  /// VK color
  final Color vk;

  /// WhatsApp color
  final Color whatsapp;
}

/// {@macro theme}
///
/// Default social colors.
@immutable
class _UISocialColors$Default extends UISocialColors {
  /// {@macro theme}
  const _UISocialColors$Default()
    : super(
        telegram: const Color(0xFF2AABEE),
        viber: const Color(0xFF8875F0),
        vk: const Color(0xFF2787F5),
        whatsapp: const Color(0xFF43D854),
      );
}

/// {@macro theme}
///
/// Default gradients.
@immutable
sealed class UIGradients {
  /// {@macro theme}
  const UIGradients({required this.blueAndPurple, required this.blueAndViolet, required this.whatsapp});

  /// {@macro theme}
  ///
  /// Create a [UIGradients] given a set of exact values.
  const factory UIGradients.empty() = _UIGradients$Default;

  /// Blue and purple gradient
  final ({List<Color> colors, List<double> stops}) blueAndPurple;

  /// Blue and violet gradient
  final ({List<Color> colors, List<double> stops}) blueAndViolet;

  /// WhatsApp gradient
  final ({List<Color> colors, List<double> stops}) whatsapp;
}

/// {@macro theme}
///
/// Default gradient schemes.
@immutable
class _UIGradients$Default extends UIGradients {
  /// {@macro theme}
  const _UIGradients$Default()
    : super(
        blueAndPurple: (
          colors: const [
            Color(0XFF0A84FF), // 0 1383FE
            Color(0XFF6274EF), // 0.25
            Color(0XFF7371EC), // 0.4
            Color(0XFF876DE8), // 0.75
            Color(0XFFB664DF), // 1
          ],
          stops: const [0, 0.25, 0.4, 0.75, 1],
        ),
        blueAndViolet: (colors: const [Color(0XFF0A84FF), Color(0XFF5E5CE6)], stops: const [0, 0.75]),
        whatsapp: (
          colors: const [Color(0XFF1185F7), Color(0XFF079CB9), Color(0XFF05A896), Color(0XFF04B573), Color(0XFF00C73D)],
          stops: const [0, 0.25, 0.4, 0.75, 1],
        ),
      );
}
