/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 */

import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart' show AsyncCallback, ValueNotifier;
import 'package:flutter/widgets.dart';
import 'package:ui/src/components/list_loader_indicator.dart' show UIListLoaderIndicator;
import 'package:ui/src/components/loading.dart' show UILoadingScope;

/// Tracks whether [UILazyLoadScrollView] may request another page.
enum LazyUILoadingStatus {
  /// A load callback is currently outstanding.
  loading,

  /// The next threshold crossing may trigger a load.
  stable,
}

/// Requests another page when the watched scrollable approaches its end.
///
/// The preferred [onLazyLoad] callback remains guarded until its returned
/// future completes. If a [UILoadingScope] is available, the operation is also
/// published there as lazy loading. Place [UILazyLoadingIndicator] inside
/// [child] to rebuild only the footer while this scrollable is loading.
///
/// Notifications from nested scrollables are ignored, and handled
/// notifications continue bubbling to outer listeners.
class UILazyLoadScrollView extends StatefulWidget {
  /// Creates a lazy-load boundary around [child].
  const UILazyLoadScrollView({
    required this.child,
    this.onLazyLoad,
    this.canLazyLoad = true,
    this.lazyLoadOffset,
    @Deprecated('Use onLazyLoad instead.') this.onLoad,
    @Deprecated('Use canLazyLoad and the Future returned by onLazyLoad instead.') this.isLoading = false,
    @Deprecated('Use lazyLoadOffset instead.') this.scrollOffset = 100,
    this.scrollDirection = Axis.vertical,
    super.key,
  }) : assert((onLazyLoad == null) != (onLoad == null), 'Exactly one of onLazyLoad and onLoad must be provided.'),
       assert(lazyLoadOffset == null || lazyLoadOffset >= 0, 'lazyLoadOffset must not be negative.'),
       assert(scrollOffset >= 0, 'scrollOffset must not be negative.');

  /// Scrollable subtree whose notifications are observed.
  final Widget child;

  /// Asynchronously loads the next page.
  ///
  /// Repeated threshold crossings are ignored until this future completes.
  /// Errors remain uncaught so they are reported through the caller's current
  /// error zone after local loading state is released.
  final AsyncCallback? onLazyLoad;

  /// Whether another lazy-load operation may start.
  final bool canLazyLoad;

  /// Remaining logical pixels at which [onLazyLoad] is triggered.
  ///
  /// When omitted, deprecated [scrollOffset] is used.
  final double? lazyLoadOffset;

  /// Legacy synchronous callback.
  @Deprecated('Use onLazyLoad instead.')
  final VoidCallback? onLoad;

  /// Legacy external loading guard.
  @Deprecated('Use canLazyLoad and the Future returned by onLazyLoad instead.')
  final bool isLoading;

  /// Legacy threshold in logical pixels.
  @Deprecated('Use lazyLoadOffset instead.')
  final int scrollOffset;

  /// Notification axis observed when nested scrollables are present.
  final Axis scrollDirection;

  double get _effectiveLazyLoadOffset => lazyLoadOffset ?? scrollOffset.toDouble();

  @override
  State<UILazyLoadScrollView> createState() => _UILazyLoadScrollViewState();
}

class _UILazyLoadScrollViewState extends State<UILazyLoadScrollView> {
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier<bool>(false);
  bool _loading = false;

  bool get _canStartLoading => widget.canLazyLoad && !_loading && (widget.onLazyLoad != null || !widget.isLoading);

  @override
  void dispose() {
    _loadingNotifier.dispose();
    super.dispose();
  }

  bool _onNotification(ScrollNotification notification) {
    if (!mounted || notification.depth != 0 || notification.metrics.axis != widget.scrollDirection) return false;

    final reachedThreshold = switch (notification) {
      ScrollUpdateNotification() => notification.metrics.extentAfter <= widget._effectiveLazyLoadOffset,
      OverscrollNotification() => notification.metrics.extentAfter == 0 && notification.overscroll > 0,
      _ => false,
    };
    if (reachedThreshold) unawaited(_load());
    return false;
  }

  Future<void> _load() async {
    if (!_canStartLoading) return;

    _loading = true;
    _loadingNotifier.value = true;
    try {
      final onLazyLoad = widget.onLazyLoad;
      if (onLazyLoad != null) {
        final controller = UILoadingScope.maybeOf(context);
        if (controller == null) {
          await onLazyLoad();
        } else {
          await controller.run<void>(onLazyLoad, lazy: true);
        }
      } else {
        widget.onLoad?.call();
      }
    } finally {
      _loading = false;
      if (mounted) _loadingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) => NotificationListener<ScrollNotification>(
    onNotification: _onNotification,
    child: _UILazyLoadingScope(notifier: _loadingNotifier, child: widget.child),
  );
}

class _UILazyLoadingScope extends InheritedNotifier<ValueNotifier<bool>> {
  const _UILazyLoadingScope({required super.notifier, required super.child});

  static ValueNotifier<bool> of(BuildContext context) {
    final notifier = context.dependOnInheritedWidgetOfExactType<_UILazyLoadingScope>()?.notifier;
    if (notifier != null) return notifier;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary('No UILazyLoadScrollView found.'),
      ErrorDescription('UILazyLoadingIndicator must be placed below the child of a UILazyLoadScrollView.'),
      context.describeElement('The context used was'),
    ]);
  }
}

/// Displays the loading footer for the nearest [UILazyLoadScrollView].
///
/// This widget occupies no space while idle. It must be placed inside the
/// scroll view's [UILazyLoadScrollView.child] subtree.
class UILazyLoadingIndicator extends StatelessWidget {
  /// Creates a footer controlled by the nearest lazy-load boundary.
  const UILazyLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) => UIListLoaderIndicator(visible: _UILazyLoadingScope.of(context).value);
}
