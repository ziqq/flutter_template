/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 */

import 'package:flutter/material.dart' show Colors;
import 'package:flutter/rendering.dart';

/// Converts external color values and derives presentation-safe variants.
final class UIColorUtil {
  const UIColorUtil._();

  /// Parses RGB, RRGGBB, or AARRGGBB hexadecimal notation.
  ///
  /// A leading `#` is optional. RGB and RRGGBB values are treated as opaque.
  /// Throws a [FormatException] when the normalized value has another length or
  /// contains a non-hexadecimal character.
  static Color fromHex(String hexString) {
    final cleaned = hexString.startsWith('#') ? hexString.substring(1) : hexString;
    if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(cleaned)) {
      throw FormatException('Invalid hexadecimal color.', hexString);
    }
    if (cleaned.length == 3) {
      final expanded = cleaned.split('').map((character) => '$character$character').join();
      return Color(int.parse('ff$expanded', radix: 16));
    }
    if (cleaned.length == 6) return Color(int.parse('ff$cleaned', radix: 16));
    if (cleaned.length == 8) return Color(int.parse(cleaned, radix: 16));
    throw FormatException('UIColorUtil.fromHex | invalid length', hexString);
  }

  /// Serializes [color] as RRGGBB or AARRGGBB hexadecimal notation.
  ///
  /// Alpha is omitted unless [includeAlpha] is true. Output is lowercase unless
  /// [upperCase] is true and includes `#` unless [leadingHashSign] is false.
  static String toHex(Color color, {bool leadingHashSign = true, bool includeAlpha = false, bool upperCase = false}) {
    final argb = color.toARGB32();
    final alpha = (argb >> 24) & 0xFF;
    final red = (argb >> 16) & 0xFF;
    final green = (argb >> 8) & 0xFF;
    final blue = argb & 0xFF;
    final value = StringBuffer()
      ..write(includeAlpha ? alpha.toRadixString(16).padLeft(2, '0') : '')
      ..write(red.toRadixString(16).padLeft(2, '0'))
      ..write(green.toRadixString(16).padLeft(2, '0'))
      ..write(blue.toRadixString(16).padLeft(2, '0'));
    final normalized = upperCase ? value.toString().toUpperCase() : value.toString();
    return '${leadingHashSign ? '#' : ''}$normalized';
  }

  /// Returns [color] with its HSL lightness reduced by [amount].
  ///
  /// [amount] must be between `0` and `1`; the result is clamped to the same
  /// range.
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  /// Returns [color] with its HSL lightness increased by [amount].
  ///
  /// [amount] must be between `0` and `1`; the result is clamped to the same
  /// range.
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  /// Selects the foreground color with the greater WCAG contrast against [color].
  ///
  /// When [color] is translucent, pass the opaque color painted beneath it as
  /// [backdropColor]. Translucent foreground candidates are evaluated after
  /// compositing them over the effective background. This method chooses the
  /// better of the two candidates but cannot guarantee that either one reaches
  /// a particular WCAG conformance level.
  static Color contrastingForegroundColor(
    Color color, {
    Color? backdropColor,
    Color lightColor = Colors.white,
    Color darkColor = Colors.black,
  }) {
    final background = backdropColor == null ? color : Color.alphaBlend(color, backdropColor);
    final effectiveLightColor = Color.alphaBlend(lightColor, background);
    final effectiveDarkColor = Color.alphaBlend(darkColor, background);
    final lightContrast = _contrastRatio(effectiveLightColor, background);
    final darkContrast = _contrastRatio(effectiveDarkColor, background);
    return darkContrast >= lightContrast ? darkColor : lightColor;
  }

  /// Selects [darkColor] or [lightColor] using the legacy brightness threshold.
  ///
  /// This method ignores alpha and is retained for source and behavior
  /// compatibility. New code should use [contrastingForegroundColor], which
  /// compares the candidates by their WCAG contrast ratio.
  @Deprecated('Use UIColorUtil.contrastingForegroundColor instead.')
  static Color contrastingTextColor(Color color, {Color lightColor = Colors.white, Color darkColor = Colors.black}) {
    final argb = color.toARGB32();
    final red = (argb >> 16) & 0xFF;
    final green = (argb >> 8) & 0xFF;
    final blue = argb & 0xFF;
    final brightness = (299 * red + 587 * green + 114 * blue) / 1000;
    return brightness > 128 ? darkColor : lightColor;
  }

  static double _contrastRatio(Color first, Color second) {
    final firstLuminance = first.computeLuminance();
    final secondLuminance = second.computeLuminance();
    final lighter = firstLuminance > secondLuminance ? firstLuminance : secondLuminance;
    final darker = firstLuminance > secondLuminance ? secondLuminance : firstLuminance;
    return (lighter + 0.05) / (darker + 0.05);
  }
}

/// Adds design-system color transformations to [Color].
extension UIColorExtension on Color {
  /// Returns a darker variant of this color.
  Color darken([double amount = 0.1]) => UIColorUtil.darken(this, amount);

  /// Returns a lighter variant of this color.
  Color lighten([double amount = 0.1]) => UIColorUtil.lighten(this, amount);
}
