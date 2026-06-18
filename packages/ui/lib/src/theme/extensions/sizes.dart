/*
 * Date: 19 September 2023
 */

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// Default button height.
const double kDefaultButtonHeight = 56;

/// Default border radius.
/// Used for corners and sheets by default.
const double kDefaultBorderRadius = 12;

/// {@template ui_sizes}
/// UI sizes data.
/// {@endtemplate}
@immutable
class UISizes implements ThemeExtension<UISizes> {
  /// {@macro ui_sizes}
  const UISizes({
    required this.avatar,
    required this.button,
    required this.corner,
    required this.icon,
    required this.offset,
  });

  /// The default sizes scheme.
  ///
  /// {@macro app_colors}
  const UISizes.empty()
    : avatar = const SizeScheme.avatar(),
      button = const SizeScheme.button(),
      corner = const SizeScheme.corner(),
      icon = const SizeScheme.icon(),
      offset = const SizeScheme.offset();

  /// Avatar size scheme
  final SizeScheme avatar;

  /// Button size scheme
  final SizeScheme button;

  /// Corner size scheme
  final SizeScheme corner;

  /// Icon size scheme
  final SizeScheme icon;

  /// Offset size scheme
  final SizeScheme offset;

  @override
  Object get type => UISizes;

  @override
  ThemeExtension<UISizes> copyWith({
    SizeScheme? avatar,
    SizeScheme? button,
    SizeScheme? corner,
    SizeScheme? icon,
    SizeScheme? offset,
  }) => UISizes(
    avatar: avatar ?? this.avatar,
    button: button ?? this.button,
    corner: corner ?? this.corner,
    icon: icon ?? this.icon,
    offset: offset ?? this.offset,
  );

  @override
  ThemeExtension<UISizes> lerp(covariant ThemeExtension<UISizes>? other, double t) {
    if (other is! UISizes) return this;
    return UISizes(
      avatar: SizeScheme.lerp(avatar, other.avatar, t),
      button: SizeScheme.lerp(button, other.button, t),
      corner: SizeScheme.lerp(corner, other.corner, t),
      icon: SizeScheme.lerp(icon, other.icon, t),
      offset: SizeScheme.lerp(offset, other.offset, t),
    );
  }

  @override
  String toString() =>
      'UISizes{'
      'avatar: $avatar, '
      'button: $button, '
      'corner: $corner, '
      'icon: $icon'
      'offset: $offset'
      '}';
}

/// {@template size_scheme}
/// Size scheme data.
/// {@endtemplate}
@immutable
class SizeScheme {
  /// {@macro size_scheme}
  const SizeScheme({
    required this.regular,
    required this.large,
    required this.medium,
    required this.small,
    required this.extraSmall,
    required this.extraExtraSmall,
    this.secondary,
    this.xl,
    this.xxl,
  });

  /// Avatar size scheme
  /// {@macro ui_sizes}
  @literal
  const factory SizeScheme.avatar() = _SizeScheme$Avatars;

  /// Button size scheme
  /// {@macro ui_sizes}
  @literal
  const factory SizeScheme.button() = _SizeScheme$Button;

  /// Corner size scheme
  /// {@macro ui_sizes}
  @literal
  const factory SizeScheme.corner() = _SizeScheme$Corner;

  /// Icon size scheme
  /// {@macro ui_sizes}
  @literal
  const factory SizeScheme.icon() = _SizeScheme$Icon;

  /// Offset size scheme
  /// {@macro ui_sizes}
  @literal
  const factory SizeScheme.offset() = _SizeScheme$Offset;

  /// Regulatr (base) size
  ///
  /// ```dart
  /// avatar: 50
  /// button: 56
  /// corner: 12
  /// icon: 24
  /// offset: 16
  /// ```
  final double regular;

  // TODO(ziqq): Maybe should remove secondary variant
  // Anton Ustinoff <a.a.ustinoff@gmail.com>, 05 March 2026
  /// Secondary size
  ///
  /// ```dart
  /// avatar: null
  /// button: null
  /// corner: null
  /// icon: 20
  /// offset: null
  /// ```
  final double? secondary;

  /// Extra extra large size
  ///
  /// ```dart
  /// avatar: null
  /// button: null
  /// corner: null
  /// icon: 75
  /// offset: 75
  /// ```
  final double? xxl;

  /// Extra large size
  ///
  /// ```dart
  /// avatar: null
  /// button: null
  /// corner: null
  /// icon: 50
  /// offset: 50
  /// ```
  final double? xl;

  /// Large size
  ///
  /// ```dart
  /// avatar: 100
  /// button: 56
  /// corner: 20
  /// icon: 50
  /// offset: 32
  /// ```
  final double large;

  /// Medium size
  ///
  /// ```dart
  /// avatar: 80
  /// button: 44
  /// corner: 16
  /// icon: 40
  /// offset: 24
  /// ```
  final double medium;

  /// Small size
  ///
  /// ```dart
  /// avatar: 42
  /// button: 38
  /// corner: 10
  /// icon: 18
  /// offset: 10
  /// ```
  final double small;

  /// Extra small size
  ///
  /// ```dart
  /// avatar: 32
  /// button: 28
  /// corner: 8
  /// icon: 16
  /// offset: 8
  /// ```
  final double extraSmall;

  /// Extra extra small size
  ///
  /// ```dart
  /// avatar: 24
  /// button: 24
  /// corner: 6
  /// icon: 12
  /// offset: 5
  /// ```
  final double extraExtraSmall;

  /// Linearly interpolate between two [SizeScheme] objects.
  ///
  /// {@macro dart.ui.shadow.lerp}
  // ignore: prefer_constructors_over_static_methods
  static SizeScheme lerp(SizeScheme a, SizeScheme b, double t) {
    if (identical(a, b)) return a;
    return SizeScheme(
      regular: lerpDouble(a.regular, b.regular, t)!,
      secondary: lerpDouble(a.secondary, b.secondary, t),
      xxl: lerpDouble(a.xxl, b.xxl, t),
      xl: lerpDouble(a.xl, b.xl, t),
      large: lerpDouble(a.large, b.large, t)!,
      medium: lerpDouble(a.medium, b.medium, t)!,
      small: lerpDouble(a.small, b.small, t)!,
      extraSmall: lerpDouble(a.extraSmall, b.extraSmall, t)!,
      extraExtraSmall: lerpDouble(a.extraExtraSmall, b.extraExtraSmall, t)!,
    );
  }

  /// List of all size values.
  Map<String, double> get values => {
    regular.toString(): regular,
    secondary.toString(): ?secondary,
    xxl.toString(): ?xxl,
    xl.toString(): ?xl,
    large.toString(): large,
    medium.toString(): medium,
    small.toString(): small,
    extraSmall.toString(): extraSmall,
    extraExtraSmall.toString(): extraExtraSmall,
  };

  @override
  String toString() =>
      'SizeScheme{'
      'regular: $regular, '
      'secondary: $secondary, '
      'xxl: $xxl, '
      'xl: $xl, '
      'large: $large, '
      'medium: $medium, '
      'small: $small, '
      'extraSmall: $extraSmall, '
      'extraExtraSmall: $extraExtraSmall'
      '}';
}

/// {@macro sizes_scheme}
///
/// Sizes schemes for:
/// [avatar] - Avatar size scheme
/// [button] - Button size scheme
/// [corner] - Border radius size scheme
/// [icon] - Icon size scheme
sealed class SizesScheme {
  /// {@macro sizes_scheme}
  const SizesScheme({required this.avatar, required this.button, required this.corner, required this.icon});

  @literal
  const factory SizesScheme.empty() = _SizesScheme$Default;

  /// Avatar size scheme
  final SizeScheme avatar;

  /// Button size scheme
  final SizeScheme button;

  /// Corner size scheme
  final SizeScheme corner;

  /// Icon size scheme
  final SizeScheme icon;
}

/// {@macro size_scheme}
///
/// Default size schemes.
@immutable
class _SizesScheme$Default extends SizesScheme {
  /// {@macro size_scheme}
  const _SizesScheme$Default()
    : super(
        avatar: const SizeScheme.avatar(),
        button: const SizeScheme.button(),
        corner: const SizeScheme.corner(),
        icon: const SizeScheme.icon(),
      );
}

/// {@macro size_scheme}
///
/// Default avatar sizes.
@immutable
class _SizeScheme$Avatars extends SizeScheme {
  /// {@macro size_scheme}
  const _SizeScheme$Avatars()
    : super(regular: 50, extraExtraSmall: 24, extraSmall: 32, small: 42, medium: 80, large: 100);
}

/// {@macro size_scheme}
///
/// Default button sizes.
@immutable
class _SizeScheme$Button extends SizeScheme {
  /// {@macro size_scheme}
  const _SizeScheme$Button()
    : super(
        regular: kDefaultButtonHeight,
        extraExtraSmall: 26,
        extraSmall: 32,
        small: 38,
        medium: 44,
        large: kDefaultButtonHeight,
      );
}

/// {@macro size_scheme}
///
/// Default corner sizes.
@immutable
class _SizeScheme$Corner extends SizeScheme {
  /// {@macro size_scheme}
  const _SizeScheme$Corner()
    : super(
        regular: kDefaultBorderRadius,
        large: 20,
        medium: 16,
        small: 10,
        extraSmall: 8,
        extraExtraSmall: kDefaultBorderRadius / 2,
      );
}

/// {@macro size_scheme}
///
/// Default icons sizes.
@immutable
class _SizeScheme$Icon extends SizeScheme {
  /// {@macro size_scheme}
  const _SizeScheme$Icon()
    : super(
        regular: 24,
        secondary: 20,
        xxl: 75,
        xl: 50,
        large: 50,
        medium: 40,
        small: 18,
        extraSmall: 16,
        extraExtraSmall: 12,
      );
}

/// {@macro ui_sizes}
///
/// Default icons sizes.
@immutable
class _SizeScheme$Offset extends SizeScheme {
  /// {@macro ui_sizes}
  const _SizeScheme$Offset()
    : super(regular: 16, extraSmall: 8, extraExtraSmall: 5, small: 10, medium: 24, large: 32, xl: 50, xxl: 75);
}
