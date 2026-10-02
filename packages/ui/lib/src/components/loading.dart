/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 14 September 2026
 */

import 'package:flutter/material.dart';
import 'package:ui/src/localization/localization.dart' show UILocalizations;
import 'package:ui/src/theme/theme.dart' show ThemeDataExtensions;

const _loadingTitleTransitionDuration = Duration(milliseconds: 350);

/// Runs presentation-only operations and reports their combined loading state.
///
/// Each [run] call starts immediately and remains active until its own future
/// completes. Overlapping calls do not cancel or replace one another. This
/// controller does not own domain data, errors, retries, or cancellation.
///
/// A controller created by [UILoadingScope] is disposed with that scope. When a
/// controller is passed to [UILoadingScope.controller], its caller remains the
/// disposal owner.
final class UILoadingController extends ChangeNotifier {
  final Map<Object, _UILoadingOperation> _operations = <Object, _UILoadingOperation>{};
  bool _disposed = false;

  /// Whether at least one regular or lazy operation is active.
  bool get isProcessing => _operations.isNotEmpty;

  /// Whether at least one operation started with `lazy: true` is active.
  bool get isLazyLoading => _operations.values.any((operation) => operation.lazy);

  /// The explicit message when exactly one operation is active.
  ///
  /// Returns `null` when there are no operations, the only operation has no
  /// message, or several operations overlap. Consumers should use their
  /// localized default for `null` while [isProcessing] is true.
  String? get message => _snapshot(includeLazy: true).message;

  /// Runs [action] and reports its presentation loading state to listeners.
  ///
  /// The original result or error is propagated to the caller. Cleanup in the
  /// completion path removes only this invocation, so another overlapping
  /// operation remains visible. [lazy] marks work that may be hidden by a
  /// consumer such as [UILoadingTitle].
  Future<T> run<T>(Future<T> Function() action, {bool lazy = false, String? message}) async {
    if (_disposed) throw StateError('UILoadingController.run() called after dispose().');

    final token = Object();
    _operations[token] = _UILoadingOperation(lazy: lazy, message: message);
    notifyListeners();

    try {
      return await action();
    } finally {
      final removed = _operations.remove(token);
      if (removed != null && !_disposed) notifyListeners();
    }
  }

  _UILoadingSnapshot _snapshot({required bool includeLazy}) {
    var count = 0;
    String? message;
    for (final operation in _operations.values) {
      if (!includeLazy && operation.lazy) continue;
      count++;
      message = count == 1 ? operation.message : null;
    }
    return _UILoadingSnapshot(isProcessing: count > 0, message: message);
  }

  @override
  void dispose() {
    _disposed = true;
    _operations.clear();
    super.dispose();
  }
}

/// Provides a [UILoadingController] to a widget subtree.
///
/// When [controller] is omitted, the scope creates and disposes one. A supplied
/// controller remains caller-owned. Descendants normally issue commands from
/// event handlers with [of]; widgets that present loading state, such as
/// [UILoadingTitle], subscribe internally to the nearest scope.
class UILoadingScope extends StatefulWidget {
  /// Creates a loading scope around [child].
  const UILoadingScope({required this.child, this.controller, super.key});

  /// Returns the closest controller without subscribing [context] to updates.
  ///
  /// Throws a [FlutterError] when no [UILoadingScope] encloses [context].
  static UILoadingController of(BuildContext context) {
    final controller = maybeOf(context);
    if (controller != null) return controller;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary('No UILoadingScope found.'),
      ErrorDescription('UILoadingScope.of() was called with a context that does not contain a UILoadingScope.'),
      context.describeElement('The context used was'),
    ]);
  }

  /// Returns the closest controller without subscribing [context] to updates.
  static UILoadingController? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_UILoadingScope>()?.notifier;

  static UILoadingController? _dependOn(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_UILoadingScope>()?.notifier;

  /// Optional caller-owned controller.
  final UILoadingController? controller;

  /// Widget subtree that can access this scope.
  final Widget child;

  @override
  State<UILoadingScope> createState() => _UILoadingScopeState();
}

class _UILoadingScopeState extends State<UILoadingScope> {
  late UILoadingController _controller;
  late bool _ownsController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? UILoadingController();
    _ownsController = widget.controller == null;
  }

  @override
  void didUpdateWidget(UILoadingScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(widget.controller, oldWidget.controller)) return;

    final previousController = _controller;
    final disposePreviousController = _ownsController;
    _controller = widget.controller ?? UILoadingController();
    _ownsController = widget.controller == null;
    if (disposePreviousController) WidgetsBinding.instance.addPostFrameCallback((_) => previousController.dispose());
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _UILoadingScope(notifier: _controller, child: widget.child);
}

class _UILoadingScope extends InheritedNotifier<UILoadingController> {
  const _UILoadingScope({required super.notifier, required super.child});
}

/// Displays a title or the loading state of the nearest [UILoadingScope].
///
/// Lazy operations participate by default. Set [showLazyLoading] to `false`
/// when pagination should remain visible only in the list footer. Without a
/// scope this widget displays [text] normally. Changes between the idle title
/// and loading state use a bounded cross-fade transition.
class UILoadingTitle extends StatelessWidget {
  /// Creates a title that observes the nearest loading scope.
  const UILoadingTitle(this.text, {this.showLazyLoading = true, this.style, super.key});

  /// Text displayed when no matching operation is active.
  final String text;

  /// Whether operations started with `lazy: true` affect this title.
  final bool showLazyLoading;

  /// Optional style for both the idle title and the loading message.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final controller = UILoadingScope._dependOn(context);
    final snapshot = controller?._snapshot(includeLazy: showLazyLoading);
    final effectiveStyle = style ?? Theme.of(context).textTheme.headlineMedium;
    final isProcessing = snapshot?.isProcessing ?? false;
    final idleTitle = Text(
      text,
      key: const ValueKey<String>('loading_title_text'),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: effectiveStyle,
    );
    final message = snapshot?.message ?? '${UILocalizations.of(context).loading}...';
    final theme = Theme.of(context);
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = disableAnimations ? Duration.zero : _loadingTitleTransitionDuration;
    return LayoutBuilder(
      builder: (_, constraints) {
        final width = constraints.hasBoundedWidth ? constraints.maxWidth : null;
        final loadingText = Text(
          message,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: effectiveStyle,
        );
        final loadingTitle = Row(
          key: const ValueKey<String>('loading_title_progress'),
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: theme.uiTheme.indent,
          children: <Widget>[
            SizedBox.square(
              dimension: theme.uiTheme.size.icon.small,
              child: ExcludeSemantics(
                child: CircularProgressIndicator(
                  value: disableAnimations ? .75 : null,
                  strokeWidth: 2,
                  strokeCap: StrokeCap.round,
                  valueColor: AlwaysStoppedAnimation<Color?>(effectiveStyle?.color),
                ),
              ),
            ),
            if (constraints.hasBoundedWidth) Flexible(child: loadingText) else loadingText,
          ],
        );
        return AnimatedCrossFade(
          firstChild: _UILoadingTitleSlot(width: width, child: idleTitle),
          secondChild: _UILoadingTitleSlot(width: width, child: loadingTitle),
          crossFadeState: isProcessing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: duration,
          firstCurve: Curves.easeInOut,
          secondCurve: Curves.easeInOut,
          sizeCurve: Curves.easeInOut,
          alignment: Alignment.center,
          layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) => Stack(
            alignment: Alignment.center,
            children: <Widget>[
              KeyedSubtree(key: bottomChildKey, child: bottomChild),
              KeyedSubtree(key: topChildKey, child: topChild),
            ],
          ),
        );
      },
    );
  }
}

class _UILoadingTitleSlot extends StatelessWidget {
  const _UILoadingTitleSlot({required this.width, required this.child});

  final double? width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (width == null) return child;
    return SizedBox(
      width: width,
      child: Align(alignment: Alignment.center, child: child),
    );
  }
}

final class _UILoadingOperation {
  const _UILoadingOperation({required this.lazy, required this.message});

  final bool lazy;
  final String? message;
}

final class _UILoadingSnapshot {
  const _UILoadingSnapshot({required this.isProcessing, required this.message});

  final bool isProcessing;
  final String? message;
}
