import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

/// {@template shake_controller}
/// Drives a [UIShakeTransition] and owns a field's validation error state.
///
/// This is the single source of truth for both the error message and the shake
/// cue. It survives rebuilds, is easy to test, and does not depend on the
/// transition being mounted when a shake is requested.
///
/// Typical form usage: call [addError] with the message on failed validation
/// and [clearError] once the field becomes valid again. Listen to the
/// controller (it is a [ChangeNotifier]) to repaint the field's error styling
/// such as a red label. The transition listens to [onShake] separately, so
/// [clearError] and other state reads never replay the animation.
///
/// For an attention-only cue with no stored error (for example a wrong PIN or a
/// rejected tap), call [shake] instead of [addError].
///
/// Dispose it together with the owning widget.
///
/// ```dart
/// final shake = UIShakeController();
///
/// // On submit:
/// if (name.isEmpty) {
///   shake.addError('Name is required'); // stores the error and shakes
/// } else {
///   shake.clearError(); // clears without shaking
/// }
///
/// // In build, bind styling to the error and wrap the field:
/// ListenableBuilder(
///   listenable: shake,
///   builder: (context, _) => UIShakeTransition(
///     controller: shake,
///     child: MyField(hasError: shake.hasError),
///   ),
/// );
/// ```
/// {@endtemplate}
class UIShakeController extends ChangeNotifier {
  /// {@macro shake_controller}
  UIShakeController();

  /// A signal that fires on every [shake] and [addError] request.
  ///
  /// A [UIShakeTransition] listens to this instead of the controller itself so
  /// that state-only changes such as [clearError] never play the animation.
  Listenable get onShake => _shakeSignal;
  final _UIShakeSignal _shakeSignal = _UIShakeSignal();

  /// The current error message, or `null` when the field is valid.
  String? get error => _error;
  String? _error;

  /// Whether a non-empty error message is set.
  bool get hasError => _error != null && (_error?.isNotEmpty ?? false);

  /// Stores [message] as the current error and requests a shake.
  ///
  /// Always shakes, including when the same message is set again, so a repeated
  /// failed submit re-animates the field.
  void addError(String message) {
    final changed = _error != message;
    _error = message;
    _shakeSignal.fire();
    if (changed) notifyListeners();
  }

  /// Clears the current error without shaking. A no-op when already empty.
  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  /// Requests a shake without changing the error state.
  void shake() => _shakeSignal.fire();

  @override
  void dispose() {
    _shakeSignal.dispose();
    super.dispose();
  }
}

/// Internal signal used by [UIShakeController] to fan out shake requests.
class _UIShakeSignal extends ChangeNotifier {
  void fire() => notifyListeners();
}

/// {@template shake_transition}
/// Plays a short horizontal shake on [child] to flag an invalid or rejected
/// field.
///
/// Drive it with a [UIShakeController] (the recommended way): the controller
/// owns the error state and this transition shakes whenever an error is added
/// or a shake is requested. See [UIShakeController] for the full contract and
/// an example.
///
/// The animation is tunable via [duration], [amplitude] and [oscillations].
/// When the platform requests reduced motion the visual shake is skipped while
/// optional [enableHapticFeedback] still fires, so the cue stays accessible.
/// {@endtemplate}
class UIShakeTransition extends StatefulWidget {
  /// {@macro shake_transition}
  const UIShakeTransition({
    required this.child,
    this.controller,
    this.duration = const Duration(milliseconds: 450),
    this.amplitude = 10,
    this.oscillations = 6,
    this.enableHapticFeedback = false,
    this.respectReduceMotion = true,
    super.key,
  }) : assert(amplitude >= 0 && amplitude < double.infinity, 'Amplitude must be nonnegative and finite.'),
       assert(oscillations > 0, 'Oscillations must be positive.');

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// Optional controller to trigger the shake imperatively.
  ///
  /// {@macro shake_controller}
  final UIShakeController? controller;

  /// The duration of the shake animation.
  final Duration duration;

  /// The maximum horizontal offset, in logical pixels, at the shake peak.
  final double amplitude;

  /// The number of oscillations played within [duration].
  final int oscillations;

  /// Whether to emit haptic feedback when the shake is triggered.
  ///
  /// Fires even when the visual animation is skipped for reduced motion, so the
  /// user still gets a tactile error cue.
  final bool enableHapticFeedback;

  /// Whether to skip the visual animation when the platform requests reduced motion.
  final bool respectReduceMotion;

  @override
  State<UIShakeTransition> createState() => _UIShakeTransitionState();
}

/// State for widget [UIShakeTransition].
class _UIShakeTransitionState extends State<UIShakeTransition> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    widget.controller?.onShake.addListener(shake);
  }

  @override
  void didUpdateWidget(covariant UIShakeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller?.onShake.removeListener(shake);
      widget.controller?.onShake.addListener(shake);
    }
    if (oldWidget.duration != widget.duration) _controller.duration = widget.duration;
  }

  @override
  void dispose() {
    widget.controller?.onShake.removeListener(shake);
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Plays the shake animation once.
  ///
  /// Safe to call repeatedly: an in-flight animation restarts from the start, so
  /// a repeated failed submit always re-shakes. When the platform requests
  /// reduced motion the visual animation is skipped while optional haptic
  /// feedback still fires.
  void shake() {
    if (!mounted) return;
    if (widget.enableHapticFeedback) HapticFeedback.vibrate().ignore();
    if (widget.respectReduceMotion && (MediaQuery.maybeDisableAnimationsOf(context) ?? false)) {
      _controller.value = 0;
      return;
    }
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: AnimatedBuilder(
      animation: _animation,
      builder: (_, child) {
        final t = _animation.value;
        final dx = math.sin(t * math.pi * widget.oscillations) * (1 - t) * widget.amplitude;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    ),
  );
}
