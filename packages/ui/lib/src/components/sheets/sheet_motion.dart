/*
 * Date: 07 May 2026
 */

import 'package:flutter/physics.dart' show SpringSimulation;
import 'package:flutter/widgets.dart' show Simulation, SpringDescription, Tolerance;

/// An interface for defining the motion of a sheet, including transition durations and spring parameters.
/// This is used to customize the animation behavior of sheets, such as how they open, close, and snap to positions.
/// The [SheetMotion] interface allows for defining the duration of the transition, an optional reverse duration, and the spring parameters that govern the animation. It also provides a method to create a simulation for moving the sheet from one position to another based on a given velocity.
abstract interface class SheetMotion {
  /// The route transition duration used by [PopupRoute.transitionDuration].
  Duration get duration;

  /// Optional reverse duration used by [PopupRoute.reverseTransitionDuration].
  ///
  /// If null, [duration] is used for both directions.
  Duration? get reverseDuration;

  /// Spring parameters used for opening, closing, and snapping the sheet.
  SpringDescription get spring;

  /// Creates the spring simulation that moves the sheet from [start] to [end].
  ///
  /// [velocity] is expressed in the same normalized units as the sheet
  /// animation value. For this sheet, `0.0` means closed and `1.0` means open.
  Simulation createSimulation({required double start, required double end, required double velocity}) =>
      SpringSimulation(spring, start, end, velocity, tolerance: Tolerance.defaultTolerance);
}

/// A small local replacement for `motor`'s motion object.
///
/// The original package used `Motion.createSimulation(...)` from `motor`.
/// This class keeps the same idea, but uses Flutter's built-in [SpringSimulation].
class UISheetMotion implements SheetMotion {
  /// Creates spring-based sheet motion.
  const UISheetMotion({
    Duration duration = const Duration(milliseconds: 500),
    Duration? reverseDuration,
    SpringDescription spring = const SpringDescription(mass: 1, stiffness: 500, damping: 42),
  }) : _duration = duration,
       _reverseDuration = reverseDuration,
       _spring = spring;

  /// The route transition duration used by [PopupRoute.transitionDuration].
  @override
  Duration get duration => _duration;
  final Duration _duration;

  /// Optional reverse duration used by [PopupRoute.reverseTransitionDuration].
  ///
  /// If null, [duration] is used for both directions.
  @override
  Duration? get reverseDuration => _reverseDuration;
  final Duration? _reverseDuration;

  /// Spring parameters used for opening, closing, and snapping the sheet.
  @override
  SpringDescription get spring => _spring;
  final SpringDescription _spring;

  /// Creates the spring simulation that moves the sheet from [start] to [end].
  ///
  /// [velocity] is expressed in the same normalized units as the sheet
  /// animation value. For this sheet, `0.0` means closed and `1.0` means open.
  @override
  Simulation createSimulation({required double start, required double end, required double velocity}) =>
      SpringSimulation(spring, start, end, velocity, tolerance: Tolerance.defaultTolerance);
}
