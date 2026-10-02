/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 11 September 2026
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;
import 'package:ui/src/localization/localization.dart';
import 'package:ui/src/utils/color_util.dart';
import 'package:ui/src/components/operation_status_indicator.dart';
import 'package:ui/src/components/operation_status_rive_loader.dart';
import 'package:ui/src/theme/theme.dart';

export 'package:ui/src/components/operation_status_indicator.dart';

/// A change in the presence of a messenger's status panel.
enum UIOperationStatusEvent {
  /// A show command made the panel active, before its entrance has finished.
  shown,

  /// Dismissal finished and the panel was removed.
  dismissed,
}

// Identity belongs to one show command, including identical consecutive values.
// Delayed completion and timers must never acquire ownership of its successor.
class _Presentation {
  _Presentation({
    required this.status,
    required this.toastStatus,
    required this.message,
    required this.progress,
    required this.indicator,
    required this.content,
    required this.duration,
    required this.blockInteraction,
    required this.dismissOnTap,
    required this.alignment,
    required this.bottomOffset,
  });

  final UIOperationStatus status;
  final UIOperationStatus? toastStatus;
  final String? message;
  final double? progress;
  final Widget? indicator;
  final Widget? content;
  final Duration? duration;
  final bool blockInteraction;
  final bool dismissOnTap;
  final AlignmentGeometry alignment;
  final double bottomOffset;
}

/// Presents loading, progress, results, and toast messages above [child].
///
/// Mount this widget in an application's builder, above its navigator, to keep
/// status content above routes and dialogs. It owns its presentation layer;
/// an ancestor [Overlay] or an external loading package is not required.
/// A locally mounted messenger covers only its own bounded layout area.
///
/// Obtain commands through [of] or [maybeOf]. Each messenger is independent.
/// A new show command replaces its current content and cancels its deadline.
/// Commands must be issued outside build, while the messenger is mounted.
///
/// ```dart
/// MaterialApp(
///   builder: UIOperationStatusMessenger.init(),
/// );
/// ```
///
/// This widget does not intercept global calls to other loading libraries.
/// Existing EasyLoading hosts can continue to run independently until their
/// callers are deliberately migrated.
class UIOperationStatusMessenger extends StatefulWidget {
  /// Creates a bounded presentation host with internally resolved theme defaults.
  const UIOperationStatusMessenger({
    required this.child,
    this.indicatorBuilder,
    this.indicatorStyle = UIOperationStatusIndicatorStyle.standard,
    this.displayDuration = const Duration(seconds: 2),
    this.animationStyle = const AnimationStyle(
      duration: Duration(milliseconds: 200),
      reverseDuration: Duration(milliseconds: 150),
    ),
    this.barrierColor,
    super.key,
  });

  /// The subtree covered by this messenger's panel and optional input barrier.
  final Widget child;

  /// The built-in renderer; standard is the default.
  ///
  /// Selecting Rive initializes its runtime and bundled animation internally.
  /// The file is loaded once per host, retained across shows and style changes,
  /// and released on unmount. No app preferences are read by this package.
  final UIOperationStatusIndicatorStyle indicatorStyle;

  /// Optional customization beyond the built-in standard and Rive renderers.
  ///
  /// A per-call indicator takes precedence. Returning null uses [indicatorStyle].
  /// All indicators receive the same tight layout constraints, resolved from
  /// [ProgressIndicatorThemeData.constraints] or the UI theme's regular icon
  /// size.
  /// This matches the application's existing indicator size.
  /// Changing an indicator cannot resize the panel when its text is unchanged.
  final UIOperationStatusIndicatorBuilder? indicatorBuilder;

  /// Default visible duration for result and toast messages.
  ///
  /// Loading and progress have no deadline unless supplied to their show call.
  /// A deadline starts after the entrance transition, and is replaced on update.
  final Duration displayDuration;

  /// Entrance and exit timing; omitted durations use 200 ms and 150 ms.
  ///
  /// [AnimationStyle.noAnimation] and the ambient reduced-motion preference
  /// disable transitions. Updating this property does not restart a deadline.
  final AnimationStyle animationStyle;

  /// Optional scrim color. Null leaves a blocking barrier transparent.
  ///
  /// This color does not determine whether input is blocked; each show command
  /// explicitly controls [UIOperationStatusMessengerState.show]'s blockInteraction.
  final Color? barrierColor;

  /// Creates a [MaterialApp.builder] or [MaterialApp.router] builder.
  ///
  /// Use `UIOperationStatusMessenger.init()` for standard rendering, or pass
  /// `indicatorStyle: UIOperationStatusIndicatorStyle.rive` for the bundled Rive
  /// animation. No key, asset loader, or separate initialization is required.
  /// Commands are available to descendants through [of]. For additional host
  /// configuration, construct [UIOperationStatusMessenger] directly in a builder.
  static TransitionBuilder init({
    UIOperationStatusIndicatorStyle indicatorStyle = UIOperationStatusIndicatorStyle.standard,
  }) =>
      (_, child) => UIOperationStatusMessenger(indicatorStyle: indicatorStyle, child: child ?? const SizedBox.shrink());

  /// Returns the closest messenger, registering a dependency on its identity.
  ///
  /// Throws [FlutterError] when there is no enclosing messenger. Panel updates
  /// do not rebuild callers that only look up this state.
  static UIOperationStatusMessengerState of(BuildContext context) =>
      maybeOf(context) ?? (throw FlutterError('No UIOperationStatusMessenger found above this context.'));

  /// Returns the closest messenger, or null when none encloses [context].
  static UIOperationStatusMessengerState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_UIOperationStatusMessengerScope>()?.state;

  @override
  UIOperationStatusMessengerState createState() => UIOperationStatusMessengerState();
}

/// Commands and resource ownership for a [UIOperationStatusMessenger].
///
/// Show futures complete when the entrance ends or that command is superseded.
/// Dismiss futures complete when the exit ends or a new show interrupts it.
/// Removing the host also settles outstanding futures. These futures do not
/// represent completion of the caller's business operation.
class UIOperationStatusMessengerState extends State<UIOperationStatusMessenger> with SingleTickerProviderStateMixin {
  final _panelFocus = FocusScopeNode(debugLabel: 'Operation status');
  final _listeners = <ValueChanged<UIOperationStatusEvent>>{};
  final _presentation = ValueNotifier<_Presentation?>(null);
  final _riveLoader = OperationStatusRiveLoader();
  late ProgressIndicatorThemeData _indicatorStyle;
  late final AnimationController _animation;
  FocusNode? _previousFocus;
  Timer? _timer;

  /// Whether a panel is active, including its entrance and exit transitions.
  bool get isShowing => _presentation.value != null;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configure();
  }

  @override
  void didUpdateWidget(covariant UIOperationStatusMessenger oldWidget) {
    super.didUpdateWidget(oldWidget);
    _configure();
  }

  void _configure() {
    _validateDuration(widget.displayDuration, 'displayDuration');
    final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = widget.animationStyle.duration ?? const Duration(milliseconds: 200);
    final reverseDuration = widget.animationStyle.reverseDuration ?? const Duration(milliseconds: 150);
    _validateDuration(duration, 'animationStyle.duration');
    _validateDuration(reverseDuration, 'animationStyle.reverseDuration');
    _animation
      ..duration = reducedMotion ? Duration.zero : duration
      ..reverseDuration = reducedMotion ? Duration.zero : reverseDuration;
    final theme = Theme.of(context);
    _indicatorStyle = theme.progressIndicatorTheme.copyWith(
      color: theme.progressIndicatorTheme.color ?? theme.uiTheme.color.accent,
      strokeWidth: theme.progressIndicatorTheme.strokeWidth ?? 2,
    );
    _loadRiveIfNeeded();
  }

  void _loadRiveIfNeeded() {
    final presentation = _presentation.value;
    if (presentation == null || presentation.indicator != null) return;
    final supported = switch (presentation.status) {
      UIOperationStatus.loading || UIOperationStatus.success || UIOperationStatus.error => true,
      _ => false,
    };
    final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (supported && widget.indicatorStyle == UIOperationStatusIndicatorStyle.rive && !reducedMotion) {
      unawaited(_riveLoader.load(DefaultAssetBundle.of(context)));
    }
  }

  /// Shows or replaces an indeterminate operation.
  ///
  /// Without [duration], it stays until replaced or dismissed. A null [status]
  /// uses the package's localized loading label. Input below the panel is
  /// blocked by default; [dismissOnTap] enables pointer, Escape, and semantic
  /// dismissal. [indicator] overrides both the builder and built-in renderer.
  Future<void> show({
    String? status,
    Widget? indicator,
    Duration? duration,
    bool blockInteraction = true,
    bool dismissOnTap = false,
  }) => _show(
    status: UIOperationStatus.loading,
    message: status,
    indicator: indicator,
    duration: duration,
    blockInteraction: blockInteraction,
    dismissOnTap: dismissOnTap,
  );

  /// Shows a finite completion fraction between zero and one, inclusive.
  ///
  /// Rejects NaN, infinity, and out-of-range values with [ArgumentError]. A null
  /// [status] retains a previous progress message, otherwise uses the localized
  /// loading label. Each update replaces the previous optional deadline.
  Future<void> showProgress(
    double value, {
    String? status,
    Widget? indicator,
    Duration? duration,
    bool blockInteraction = true,
    bool dismissOnTap = false,
  }) {
    if (!value.isFinite || value < 0 || value > 1) {
      throw ArgumentError.value(value, 'value', 'Must be finite and between zero and one.');
    }
    final previous = _presentation.value;
    return _show(
      status: UIOperationStatus.progress,
      message: status ?? (previous?.status == UIOperationStatus.progress ? previous?.message : null),
      progress: value,
      indicator: indicator,
      duration: duration,
      blockInteraction: blockInteraction,
      dismissOnTap: dismissOnTap,
    );
  }

  /// Shows a success result until [duration] or the host's display duration ends.
  ///
  /// [status] is caller-localized. Input passes through unless explicitly blocked.
  Future<void> showSuccess(
    String status, {
    Duration? duration,
    bool blockInteraction = false,
    bool dismissOnTap = false,
  }) => _showResult(UIOperationStatus.success, status, duration, blockInteraction, dismissOnTap);

  /// Shows an error result with the same timing and input rules as [showSuccess].
  Future<void> showError(
    String status, {
    Duration? duration,
    bool blockInteraction = false,
    bool dismissOnTap = false,
  }) => _showResult(UIOperationStatus.error, status, duration, blockInteraction, dismissOnTap);

  /// Shows an informational result with the same timing and input rules as [showSuccess].
  Future<void> showInfo(
    String status, {
    Duration? duration,
    bool blockInteraction = false,
    bool dismissOnTap = false,
  }) => _showResult(UIOperationStatus.info, status, duration, blockInteraction, dismissOnTap);

  /// Shows a caller-localized floating toast within the visible host area.
  ///
  /// Uses [UIOperationStatusMessenger.displayDuration] when [duration] is omitted.
  /// Pass [UIOperationStatus.success] or [UIOperationStatus.error] as [status]
  /// to place the same leading icon used by the package snackbar beside the
  /// message. Leave [status] null for text only. Other values are rejected with
  /// [ArgumentError]. Directional alignments follow the ambient text direction.
  /// [bottomOffset] raises the toast above caller-owned chrome, such as a visible
  /// bottom navigation bar. Leave it at zero on screens without bottom chrome;
  /// the messenger always accounts for the system safe area and keyboard.
  /// Input passes through by default; no indicator builder is invoked for a toast.
  Future<void> showToast(
    String message, {
    UIOperationStatus? status,
    Duration? duration,
    AlignmentGeometry alignment = AlignmentDirectional.bottomCenter,
    double bottomOffset = 0,
    bool blockInteraction = false,
    bool dismissOnTap = false,
  }) {
    if (status != null && status != UIOperationStatus.success && status != UIOperationStatus.error) {
      throw ArgumentError.value(status, 'status', 'Only success and error are supported for toast icons.');
    }
    if (!bottomOffset.isFinite || bottomOffset < 0) {
      throw ArgumentError.value(bottomOffset, 'bottomOffset', 'Must be finite and non-negative.');
    }
    return _show(
      status: UIOperationStatus.toast,
      toastStatus: status,
      message: message,
      duration: duration ?? widget.displayDuration,
      alignment: alignment,
      bottomOffset: bottomOffset,
      blockInteraction: blockInteraction,
      dismissOnTap: dismissOnTap,
    );
  }

  /// Places [content] in the panel; the caller owns its semantics and resources.
  ///
  /// Without [duration] the content remains until explicitly replaced or closed.
  /// [status] optionally adds caller-localized text below the content.
  Future<void> showCustom(
    Widget content, {
    String? status,
    Duration? duration,
    AlignmentGeometry alignment = AlignmentDirectional.center,
    bool blockInteraction = true,
    bool dismissOnTap = false,
  }) => _show(
    status: UIOperationStatus.custom,
    content: content,
    message: status,
    duration: duration,
    alignment: alignment,
    blockInteraction: blockInteraction,
    dismissOnTap: dismissOnTap,
  );

  Future<void> _showResult(UIOperationStatus type, String message, Duration? duration, bool block, bool dismiss) =>
      _show(
        status: type,
        message: message,
        duration: duration ?? widget.displayDuration,
        blockInteraction: block,
        dismissOnTap: dismiss,
      );

  Future<void> _show({
    required UIOperationStatus status,
    required bool blockInteraction,
    required bool dismissOnTap,
    String? message,
    UIOperationStatus? toastStatus,
    double? progress,
    Widget? indicator,
    Widget? content,
    Duration? duration,
    AlignmentGeometry alignment = AlignmentDirectional.center,
    double bottomOffset = 0,
  }) async {
    _checkCommand();
    if (duration != null) _validateDuration(duration, 'duration');
    _timer?.cancel();
    final wasShowing = isShowing;
    if (blockInteraction && !(_presentation.value?.blockInteraction ?? false) && !_panelFocus.hasFocus) {
      _previousFocus = FocusManager.instance.primaryFocus;
    }
    final presentation = _Presentation(
      status: status,
      toastStatus: toastStatus,
      message: message,
      progress: progress,
      indicator: indicator,
      content: content,
      duration: duration,
      blockInteraction: blockInteraction,
      dismissOnTap: dismissOnTap,
      alignment: alignment,
      bottomOffset: bottomOffset,
    );
    _presentation.value = presentation;
    _loadRiveIfNeeded();
    _updateFocus(presentation);
    final entrance = _animation.forward().orCancel;
    if (!wasShowing) _notify(UIOperationStatusEvent.shown);
    try {
      await entrance;
      if (mounted && identical(_presentation.value, presentation) && duration != null) {
        _timer = Timer(duration, () {
          if (mounted && identical(_presentation.value, presentation)) unawaited(dismiss());
        });
      }
    } on TickerCanceled {
      // A replacement, dismissal, or host removal settles the superseded call.
    }
  }

  /// Removes the current panel, optionally skipping its exit animation.
  ///
  /// Does nothing when no panel is active. Repeated dismissal and a new show
  /// during exit are safe: an older exit cannot remove newer content.
  Future<void> dismiss({bool animation = true}) async {
    _checkCommand();
    _timer?.cancel();
    final presentation = _presentation.value;
    if (presentation == null) return;
    try {
      if (animation) {
        await _animation.reverse().orCancel;
      } else {
        _animation.value = 0;
      }
      if (!mounted || !identical(_presentation.value, presentation)) return;
      _presentation.value = null;
      _updateFocus(null);
      _notify(UIOperationStatusEvent.dismissed);
    } on TickerCanceled {
      // A new command or host removal owns the resulting presentation.
    }
  }

  /// Registers a listener once, for panel activation and completed dismissal.
  ///
  /// Content updates do not emit another shown event. Listeners may issue new
  /// commands or unregister themselves; exceptions are reported by Flutter.
  /// The host silently removes all listeners when disposed.
  void addStatusListener(ValueChanged<UIOperationStatusEvent> listener) => _listeners.add(listener);

  /// Unregisters [listener]; removing an absent listener has no effect.
  void removeStatusListener(ValueChanged<UIOperationStatusEvent> listener) => _listeners.remove(listener);

  /// Removes listeners registered on this host only.
  void clearStatusListeners() => _listeners.clear();

  void _notify(UIOperationStatusEvent event) {
    for (final listener in _listeners.toList(growable: false)) {
      if (!_listeners.contains(listener)) continue;
      try {
        listener(event);
      } on Object catch (error, stackTrace) {
        FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stackTrace, library: 'ui'));
      }
    }
  }

  void _checkCommand() {
    if (!mounted) throw StateError('UIOperationStatusMessenger is no longer mounted.');
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      throw FlutterError(
        'UIOperationStatusMessenger commands cannot run during build. Use an event or post-frame callback.',
      );
    }
  }

  void _updateFocus(_Presentation? presentation) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !identical(_presentation.value, presentation)) return;
      if (presentation?.blockInteraction ?? false) {
        _panelFocus.requestFocus();
      } else {
        final previous = _previousFocus;
        _previousFocus = null;
        if (previous != null && previous.context != null && previous.canRequestFocus) previous.requestFocus();
      }
    });
  }

  static void _validateDuration(Duration value, String name) {
    if (value.isNegative) throw ArgumentError.value(value, name, 'Must not be negative.');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _listeners.clear();
    _animation.dispose();
    _panelFocus.dispose();
    _presentation.dispose();
    _riveLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _UIOperationStatusMessengerScope(
    state: this,
    child: ValueListenableBuilder(
      valueListenable: _presentation,
      child: widget.child,
      builder: (context, presentation, child) {
        final blocked = presentation?.blockInteraction ?? false;
        return Focus(
          skipTraversal: true,
          canRequestFocus: false,
          onKeyEvent: (node, event) {
            if ((presentation?.dismissOnTap ?? false) &&
                event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.escape) {
              unawaited(dismiss());
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ExcludeFocus(
                excluding: blocked,
                child: ExcludeSemantics(excluding: blocked, child: child),
              ),
              if (presentation != null) ...[
                Positioned.fill(
                  child: ListenableBuilder(
                    listenable: _riveLoader,
                    builder: (context, child) => _OperationStatusOverlay(
                      indicatorBuilder: widget.indicatorBuilder,
                      barrierColor: widget.barrierColor,
                      renderer: widget.indicatorStyle,
                      indicatorStyle: _indicatorStyle,
                      riveFile: _riveLoader.file,
                      focusNode: _panelFocus,
                      animation: _animation,
                      presentation: presentation,
                      onDismiss: () => unawaited(dismiss()),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    ),
  );
}

class _UIOperationStatusMessengerScope extends InheritedWidget {
  const _UIOperationStatusMessengerScope({required this.state, required super.child});

  final UIOperationStatusMessengerState state;

  @override
  bool updateShouldNotify(_UIOperationStatusMessengerScope oldWidget) => state != oldWidget.state;
}

class _OperationStatusOverlay extends StatelessWidget {
  const _OperationStatusOverlay({
    required this.presentation,
    required this.animation,
    required this.indicatorStyle,
    required this.renderer,
    required this.riveFile,
    required this.focusNode,
    required this.indicatorBuilder,
    required this.barrierColor,
    required this.onDismiss,
  });

  final rive.File? riveFile;
  final Color? barrierColor;
  final VoidCallback onDismiss;
  final FocusScopeNode focusNode;
  final _Presentation presentation;
  final Animation<double> animation;
  final ProgressIndicatorThemeData indicatorStyle;
  final UIOperationStatusIndicatorStyle renderer;
  final UIOperationStatusIndicatorBuilder? indicatorBuilder;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final theme = Theme.of(context);
    final uiTheme = theme.uiTheme;
    final message =
        presentation.message ??
        switch (presentation.status) {
          .loading || .progress => UILocalizations.of(context).loading,
          _ => null,
        };
    final hasIndicator = presentation.status != .toast && presentation.status != .custom;
    final indicatorSize = (indicatorStyle.constraints ?? const BoxConstraints()).constrain(
      Size.square(uiTheme.size.icon.regular),
    );
    final background = theme.snackBarTheme.backgroundColor ?? uiTheme.color.snackbarBackgroundColor;
    final panelBackground = media.highContrast ? background.withValues(alpha: 1) : background;
    final foreground = UIColorUtil.contrastingForegroundColor(panelBackground, backdropColor: uiTheme.color.background);
    return FadeTransition(
      opacity: animation,
      child: Stack(
        children: <Widget>[
          if (presentation.blockInteraction)
            Positioned.fill(
              child: ModalBarrier(
                color: barrierColor,
                dismissible: presentation.dismissOnTap,
                onDismiss: onDismiss,
                semanticsLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
              ),
            ),
          Positioned.fill(
            key: const ValueKey<String>('operation_status_panel'),
            child: Padding(
              padding: _panelPadding(media, uiTheme.size.offset.regular),
              child: Align(
                alignment: presentation.alignment,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: presentation.status == UIOperationStatus.toast ? 480 : 360),
                  child: FocusScope(
                    node: focusNode,
                    canRequestFocus: presentation.blockInteraction || presentation.content != null,
                    child: IgnorePointer(
                      ignoring:
                          !presentation.blockInteraction && !presentation.dismissOnTap && presentation.content == null,
                      child: Semantics(
                        container: true,
                        onDismiss: presentation.dismissOnTap ? onDismiss : null,
                        child: GestureDetector(
                          onTap: presentation.dismissOnTap ? onDismiss : null,
                          child: Material(
                            color: panelBackground,
                            borderRadius: BorderRadius.circular(
                              presentation.status == UIOperationStatus.toast
                                  ? kDefaultBorderRadius
                                  : uiTheme.size.corner.regular,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: SingleChildScrollView(
                              padding: presentation.status == UIOperationStatus.toast
                                  ? EdgeInsets.symmetric(
                                      horizontal: uiTheme.size.offset.regular,
                                      vertical: uiTheme.size.offset.small,
                                    )
                                  : EdgeInsets.all(uiTheme.size.offset.regular),
                              child: DefaultTextStyle(
                                style:
                                    ((presentation.status == UIOperationStatus.toast
                                                ? theme.textTheme.bodySmall?.copyWith(height: 1)
                                                : theme.snackBarTheme.contentTextStyle ?? theme.textTheme.bodyMedium) ??
                                            const TextStyle())
                                        .copyWith(color: foreground),
                                textAlign: presentation.status == UIOperationStatus.toast
                                    ? TextAlign.start
                                    : TextAlign.center,
                                child: presentation.status == UIOperationStatus.toast
                                    ? ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minWidth: double.infinity,
                                          minHeight: uiTheme.size.button.extraSmall,
                                        ),
                                        child: _UIOperationStatusToast(
                                          message: message,
                                          status: presentation.toastStatus,
                                          foregroundColor: foreground,
                                        ),
                                      )
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        spacing: uiTheme.size.offset.small,
                                        children: <Widget>[
                                          if (hasIndicator)
                                            SizedBox.fromSize(
                                              size: indicatorSize,
                                              child: RepaintBoundary(
                                                child: ProgressIndicatorTheme(
                                                  data: indicatorStyle,
                                                  child: IconTheme(
                                                    data: IconThemeData(
                                                      color: foreground,
                                                      size: indicatorSize.shortestSide,
                                                      applyTextScaling: false,
                                                    ),
                                                    child: Builder(
                                                      builder: (context) =>
                                                          presentation.indicator ??
                                                          indicatorBuilder?.call(
                                                            context,
                                                            presentation.status,
                                                            presentation.progress,
                                                          ) ??
                                                          switch ((
                                                            renderer,
                                                            riveFile,
                                                            media.disableAnimations,
                                                            presentation.status,
                                                          )) {
                                                            (
                                                              UIOperationStatusIndicatorStyle.rive,
                                                              final rive.File file,
                                                              false,
                                                              UIOperationStatus.loading ||
                                                                  UIOperationStatus.success ||
                                                                  UIOperationStatus.error,
                                                            ) =>
                                                              UIOperationStatusIndicator$Rive(
                                                                file: file,
                                                                status: presentation.status,
                                                              ),
                                                            _ => UIOperationStatusIndicator(
                                                              status: presentation.status,
                                                              progress: presentation.progress,
                                                            ),
                                                          },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ?presentation.content,
                                          if (message != null && message.isNotEmpty)
                                            Semantics(liveRegion: true, child: Text(message)),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  EdgeInsets _panelPadding(MediaQueryData media, double margin) {
    if (presentation.status != UIOperationStatus.toast && presentation.status != UIOperationStatus.custom) {
      return EdgeInsets.all(margin);
    }
    return EdgeInsets.fromLTRB(
      media.padding.left > margin ? media.padding.left : margin,
      media.padding.top > margin ? media.padding.top : margin,
      media.padding.right > margin ? media.padding.right : margin,
      (media.padding.bottom > margin ? media.padding.bottom : margin) +
          media.viewInsets.bottom +
          presentation.bottomOffset,
    );
  }
}

class _UIOperationStatusToast extends StatelessWidget {
  const _UIOperationStatusToast({required this.message, required this.status, required this.foregroundColor});

  final String? message;
  final UIOperationStatus? status;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final icon = switch (status) {
      UIOperationStatus.success => Icons.check_circle_rounded,
      UIOperationStatus.error => Icons.error_outline_rounded,
      _ => null,
    };
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: Theme.of(context).uiTheme.size.offset.extraSmall,
      children: <Widget>[
        if (icon != null)
          ExcludeSemantics(
            child: Icon(icon, color: foregroundColor, size: Theme.of(context).iconTheme.size),
          ),
        if (message case final message? when message.isNotEmpty)
          Expanded(
            child: Semantics(liveRegion: true, child: Text(message, maxLines: 3, overflow: TextOverflow.ellipsis)),
          ),
      ],
    );
  }
}
