/*
 * Date: 07 May 2026
 */

import 'package:flutter/animation.dart' show Animation, AnimationWithParentMixin;

/// Clamps an animation value to the visible sheet range.
///
/// The route uses an unbounded controller so the spring can overshoot slightly.
/// Public transition animations should stay in the `0.0..1.0` range.
class ClampedAnimation extends Animation<double> with AnimationWithParentMixin<double> {
  /// Creates a clamped wrapper around [parent].
  ClampedAnimation(this.parent);

  @override
  final Animation<double> parent;

  @override
  double get value => parent.value.clamp(0.0, 1.0);
}

/// Convenience extension for wrapping an animation in [ClampedAnimation].
extension ClampedAnimationX on Animation<double> {
  /// Returns this animation with its value clamped to `0.0..1.0`.
  Animation<double> get clamped => ClampedAnimation(this);
}
