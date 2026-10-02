/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 11 September 2026
 */

import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

/// The built-in rendering used by an operation status messenger.
enum UIOperationStatusIndicatorStyle {
  /// The expanding ring and themed result icons, without loading animation assets.
  standard,

  /// The package's Rive animation for loading, success, and error.
  ///
  /// Progress, unsupported phases, reduced motion, and loading failures use the
  /// standard indicator. The messenger owns initialization and resource cleanup.
  rive,
}

/// The content currently presented by an operation status messenger.
enum UIOperationStatus {
  /// An operation without a known completion fraction.
  loading,

  /// An operation with a completion fraction between zero and one.
  progress,

  /// A completed operation.
  success,

  /// An operation that could not be completed.
  error,

  /// An informational result.
  info,

  /// A toast notification, optionally accompanied by a success or error icon.
  toast,

  /// Caller-owned content in the status panel.
  custom,
}

/// Builds a replacement indicator for a messenger's current status.
///
/// [progress] is non-null only for [UIOperationStatus.progress]. Returning null
/// selects the host's configured built-in renderer. The builder is not called
/// for toast or custom content. Keep resource ownership in a stateful child;
/// this callback may run again when the message, theme, or progress changes.
typedef UIOperationStatusIndicatorBuilder = Widget? Function(
  BuildContext context,
  UIOperationStatus status,
  double? progress,
);

/// A themed spinner, determinate ring, or result icon for an operation.
///
/// Reads [ProgressIndicatorTheme] and [IconTheme] supplied by the messenger, or
/// by its caller when used inline. Reduced motion replaces the indeterminate
/// spinner with a still ring without announcing an invented percentage.
/// The loading ring preserves the application's 1200 ms expanding and rotating
/// arc, with square stroke caps. Its animation repaints only the indicator.
class UIOperationStatusIndicator extends StatelessWidget {
  /// Creates an indicator. Progress must be finite and within zero and one.
  const UIOperationStatusIndicator({required this.status, this.progress, super.key})
    : assert(progress == null || (progress >= 0 && progress <= 1), 'Progress must be finite and between zero and one.'),
      assert(
        status != UIOperationStatus.progress || progress != null,
        'The progress status requires a completion fraction.',
      );

  /// The operation phase to display.
  final UIOperationStatus status;

  /// The completion fraction for [UIOperationStatus.progress].
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return switch (status) {
      UIOperationStatus.loading when reducedMotion => const ExcludeSemantics(
        child: CircularProgressIndicator(value: .75),
      ),
      UIOperationStatus.loading => const _OperationStatusRing(),
      UIOperationStatus.progress => CircularProgressIndicator(value: progress),
      UIOperationStatus.success => const Icon(Icons.check_rounded),
      UIOperationStatus.error => const Icon(Icons.close_rounded),
      UIOperationStatus.info => const Icon(Icons.info_outline_rounded),
      UIOperationStatus.toast || UIOperationStatus.custom => const SizedBox.shrink(),
    };
  }
}

/// Plays the package animation using a file owned by the enclosing messenger.
///
/// Keeps its controller across message/status changes. The parent must keep
/// [file] alive until this indicator unmounts. Missing triggers fall back to the
/// standard status indicator; no `.riv` file is loaded by this widget.
/// The messenger supplies the shared indicator bounds; this widget must not
/// introduce a separate intrinsic size when switching to or from SDK rendering.
/// The bundled artboard's transparent inset is compensated inside those bounds
/// so its visible glyph matches the standard renderer without shifting layout.
class UIOperationStatusIndicator$Rive extends StatefulWidget {
  /// Creates an animation for a loaded file and operation phase.
  const UIOperationStatusIndicator$Rive({required this.file, required this.status, super.key});

  /// Decoded file owned by the messenger; this widget never disposes it.
  final rive.File file;

  /// Loading, success, or error state to play.
  final UIOperationStatus status;

  @override
  State<UIOperationStatusIndicator$Rive> createState() => _UIOperationStatusIndicator$RiveState();
}

class _UIOperationStatusIndicator$RiveState extends State<UIOperationStatusIndicator$Rive> {
  /// Compensates for the transparent inset baked into the bundled artboard.
  static const double _artboardScale = 1.5;

  final _triggers = <UIOperationStatus, rive.TriggerInput>{};
  rive.RiveWidgetController? _controller;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    try {
      final controller = rive.RiveWidgetController(
        widget.file,
        artboardSelector: rive.ArtboardSelector.byIndex(0),
        stateMachineSelector: rive.StateMachineSelector.byName('State Machine 1'),
      );
      _controller = controller;
      for (final (status, name) in const [
        (UIOperationStatus.loading, 'Reset'),
        (UIOperationStatus.success, 'Check'),
        (UIOperationStatus.error, 'Error'),
      ]) {
        // The bundled asset exports legacy inputs, not data-binding properties.
        // ignore: deprecated_member_use
        final trigger = controller.stateMachine.trigger(name);
        if (trigger == null) throw StateError('Missing Rive trigger: $name');
        _triggers[status] = trigger;
      }
      _play();
    } on Object catch (error, stackTrace) {
      _release();
      dev.log(
        'Rive status inputs unavailable; using standard indicator.',
        name: r'UIOperationStatusIndicator$Rive',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void didUpdateWidget(covariant UIOperationStatusIndicator$Rive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.file, widget.file)) {
      _release();
      _initialize();
    } else if (oldWidget.status != widget.status) {
      _play();
    }
  }

  void _play() => _triggers[widget.status]?.fire();

  void _release() {
    for (final trigger in _triggers.values) {
      trigger.dispose();
    }
    _triggers.clear();
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return UIOperationStatusIndicator(status: widget.status);
    return ClipRect(
      child: Transform.scale(
        scale: _artboardScale,
        child: rive.RiveWidget(controller: controller, fit: rive.Fit.cover),
      ),
    );
  }
}

// A paint-only implementation of the ring used by the existing loading host.
// Layout and semantics remain owned by UIOperationStatusIndicator and its host.
class _OperationStatusRing extends StatefulWidget {
  const _OperationStatusRing();

  @override
  State<_OperationStatusRing> createState() => _OperationStatusRingState();
}

class _OperationStatusRingState extends State<_OperationStatusRing> with SingleTickerProviderStateMixin {
  late final AnimationController _animation;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = ProgressIndicatorTheme.of(context);
    return CustomPaint(
      size: (style.constraints ?? const BoxConstraints()).constrain(const Size.square(20)),
      painter: _OperationStatusRingPainter(
        animation: _animation,
        color: style.color ?? Theme.of(context).colorScheme.primary,
        strokeWidth: style.strokeWidth ?? 2,
      ),
    );
  }
}

class _OperationStatusRingPainter extends CustomPainter {
  _OperationStatusRingPainter({required this.animation, required this.color, required this.strokeWidth})
    : _paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.square,
      super(repaint: animation);

  final Animation<double> animation;
  final Color color;
  final double strokeWidth;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.shortestSide - strokeWidth) / 2;
    if (radius <= 0) return;
    final phase = animation.value;
    final expansion = phase <= .5 ? phase * 2 : (1 - phase) * 2;
    final trailingPhase = ((phase - .5) * 2).clamp(0.0, 1.0);
    final startAngle = math.pi * (-2 / 3 + 7 / 6 * trailingPhase + 5 / 6 * phase);
    final sweepAngle = math.pi * 2 * (.25 + 7 / 12 * expansion);
    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: radius),
      startAngle,
      sweepAngle,
      false,
      _paint,
    );
  }

  @override
  bool shouldRepaint(covariant _OperationStatusRingPainter oldDelegate) =>
      oldDelegate.animation != animation || oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
