/*
 * Date: 07 May 2026
 */

import 'dart:math' as math;

import 'package:ui/ui.dart';

/// A widget that animates its child based on a [SheetDismissalMode] and an
/// [Animation<double>].
///
/// This is the public building block used by `StupidSimpleSheetTransitionMixin`
/// to drive the sheet's enter/exit transition. It can also be used standalone
/// to build custom sheet-like transitions.
///
/// The [animation] value is expected to go from 0.0 (fully dismissed) to 1.0
/// (fully presented). Values above 1.0 are supported for spring overshoot.
///
/// In [SheetDismissalMode.slide] mode, the child is translated vertically using
/// [FractionalTranslation].
///
/// In [SheetDismissalMode.shrink] mode, the child's visible height is reduced via
/// [ShrinkTransition], clipping at the child's minimum intrinsic height.
class SheetDismissalTransition extends StatelessWidget {
  /// Creates a sheet dismissal transition.
  const SheetDismissalTransition({
    required this.animation,
    required this.dismissalMode,
    required this.child,
    super.key,
  });

  /// Returns the reference height for the given [dismissalMode], which is
  /// used to normalize drag deltas consistently regardless of the actual
  /// child's size.
  static double? referenceHeightOf(BuildContext context, SheetDismissalMode dismissalMode) => switch (dismissalMode) {
    .shrink => ShrinkTransition.referenceHeightOf(context),
    .slide => context.size?.height ?? MediaQuery.heightOf(context),
  };

  /// The animation driving the transition.
  ///
  /// A value of 0.0 means fully dismissed; 1.0 means fully presented.
  /// Values above 1.0 are supported for spring overshoot.
  final Animation<double> animation;

  /// The mode used to animate the dismissal.
  final SheetDismissalMode dismissalMode;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      final value = animation.value;
      return switch (dismissalMode) {
        .slide => FractionalTranslation(translation: Offset(0, 1 - value), child: child),
        .shrink => ShrinkTransition(sizeFactor: math.max(0, value), child: child),
      };
    },
  );
}
