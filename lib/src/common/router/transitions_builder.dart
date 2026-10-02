// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Provides reusable page-transition builder functions for shared navigation.
///
/// Use these builders with APIs such as [PageRouteBuilder] when a feature wants
/// to reuse the same transition behavior without re-declaring tweens and
/// curves inside each route.
final class TransitionsBuilder {
  /// Prevents instantiation of this utility namespace.
  const TransitionsBuilder._();

  /// Fades the incoming page from transparent to fully visible.
  ///
  /// This is the least opinionated transition and works well for modal or
  /// utility screens where movement would add unnecessary emphasis.
  static Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget page,
  )
  fade = _fadeTransitionsBuilder;

  /// Rotates the incoming page around the Y axis while it appears.
  ///
  /// Use sparingly for highly expressive transitions, as it is more visually
  /// aggressive than the fade and slide variants.
  static Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget page,
  )
  rotate = _rotateTransitionsBuilder;

  /// Slides the incoming page upward from the bottom edge.
  ///
  /// This is a good fit for bottom-up flows and screens that should feel like
  /// they are presented over the current context.
  static Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget page,
  )
  slideBottom = _slideTransitionsBuilder;
}

/// Builds a Y-axis rotation transition for a route page.
Widget _rotateTransitionsBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget page,
) {
  // ignore: prefer_int_literals
  final tween = Tween(begin: 0.0, end: 2 * math.pi);
  const curve = Curves.easeInOut;
  final animatedRotation = animation.drive(tween.chain(CurveTween(curve: curve)));
  return Transform(transform: Matrix4.rotationY(animatedRotation.value), alignment: Alignment.center, child: page);
}

/// Builds a fade transition for a route page.
Widget _fadeTransitionsBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget page,
) {
  const begin = 0.0;
  const end = 1.0;
  const curve = Curves.ease;
  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  return FadeTransition(opacity: animation.drive(tween), child: page);
}

/// Builds a bottom-up slide transition for a route page.
Widget _slideTransitionsBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget page,
) {
  const begin = Offset(0, 1);
  const end = Offset.zero;
  const curve = Curves.ease;
  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  return SlideTransition(position: animation.drive(tween), child: page);
}
