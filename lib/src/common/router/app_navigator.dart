import 'dart:collection';

import 'package:flutter/foundation.dart' show listEquals, SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/common/router/page.dart';

/// Default delay between removing a page and pushing its replacement.
const Duration kDefaultNavigatorReplaceDuration = Duration(milliseconds: 350);

/// A non-empty declarative stack of [AppPage] objects.
typedef AppNavigationState = List<AppPage>;

/// A reusable declarative navigator for [AppPage] stacks.
///
/// The navigator owns stack validation, guard application, controller
/// synchronization, back handling, and nested navigator lookup. Applications
/// provide concrete pages, business guards, and analytics or other side effects
/// through [observers]. Empty proposed stacks are ignored, and duplicate page
/// keys are normalized by keeping their last occurrence.
class AppNavigator extends StatefulWidget {
  /// Creates a navigator whose stack is owned by its [AppNavigatorState].
  ///
  /// The initial [pages] list must not be empty.
  AppNavigator({
    required this.pages,
    this.guards = const [],
    this.observers = const [],
    this.transitionDelegate = const DefaultTransitionDelegate<Object?>(),
    this.revalidate,
    this.onBackButtonPressed,
    super.key,
  }) : assert(pages.isNotEmpty, 'pages cannot be empty'),
       controller = null;

  /// Creates a navigator synchronized with an external [controller].
  ///
  /// The controller must contain at least one page. Guarded or normalized state
  /// is written back to the same controller.
  AppNavigator.controlled({
    required ValueNotifier<AppNavigationState> this.controller,
    this.guards = const [],
    this.observers = const [],
    this.transitionDelegate = const DefaultTransitionDelegate<Object?>(),
    this.revalidate,
    this.onBackButtonPressed,
    super.key,
  }) : assert(controller.value.isNotEmpty, 'controller cannot be empty'),
       pages = controller.value;

  /// Returns the nearest enclosing navigator, or the furthest when [rootNavigator] is `true`.
  static AppNavigatorState? maybeOf(BuildContext context, {bool rootNavigator = false}) => rootNavigator
      ? context.findRootAncestorStateOfType<AppNavigatorState>()
      : context.findAncestorStateOfType<AppNavigatorState>();

  /// Returns the current stack from the selected enclosing navigator.
  static AppNavigationState? stateOf(BuildContext context, {bool rootNavigator = false}) =>
      maybeOf(context, rootNavigator: rootNavigator)?.state;

  /// Returns the Flutter navigator from the selected enclosing navigator.
  static NavigatorState? navigatorOf(BuildContext context, {bool rootNavigator = false}) =>
      maybeOf(context, rootNavigator: rootNavigator)?.navigator;

  /// Applies [change] to the selected enclosing navigator stack when one exists.
  static void change(
    BuildContext context,
    AppNavigationState Function(AppNavigationState pages) change, {
    bool rootNavigator = false,
  }) => maybeOf(context, rootNavigator: rootNavigator)?.change(change);

  /// Pushes [page] onto the selected enclosing navigator stack.
  static void push(BuildContext context, AppPage page, {bool rootNavigator = false}) =>
      change(context, (state) => <AppPage>[...state, page], rootNavigator: rootNavigator);

  /// Removes the current page and pushes [page] after [delay].
  ///
  /// When the selected stack contains only one page, that page is replaced
  /// immediately. A delayed push is discarded if the navigator is disposed.
  static void replaceWithAnimation(
    BuildContext context,
    AppPage page, {
    Duration delay = kDefaultNavigatorReplaceDuration,
    bool rootNavigator = false,
  }) => maybeOf(context, rootNavigator: rootNavigator)?.replaceWithAnimation(page, delay: delay);

  /// Restores the selected navigator to the pages supplied by its current widget.
  static void reset(BuildContext context, {bool rootNavigator = false}) {
    final navigator = maybeOf(context, rootNavigator: rootNavigator);
    if (navigator == null) return;
    navigator.change((_) => navigator.widget.pages);
  }

  /// Removes [page] and every page above its last occurrence.
  ///
  /// Returns `false` when [page] is absent or is the root page.
  static bool removeFrom(BuildContext context, {required AppPage page, bool rootNavigator = false}) =>
      maybeOf(context, rootNavigator: rootNavigator)?.removeFrom(page) ?? false;

  /// The initial non-empty page stack.
  final AppNavigationState pages;

  /// The optional external stack controller.
  final ValueNotifier<AppNavigationState>? controller;

  /// Functions that validate or transform each proposed stack.
  final List<AppNavigationState Function(BuildContext context, AppNavigationState state)> guards;

  /// Observers attached to the underlying Flutter navigator.
  final List<NavigatorObserver> observers;

  /// The transition delegate used by the underlying Flutter navigator.
  final TransitionDelegate<Object?> transitionDelegate;

  /// A signal that causes the current stack to be revalidated by [guards].
  final Listenable? revalidate;

  /// An optional system-back handler that can replace the stack and report handling.
  final ({AppNavigationState state, bool handled}) Function(AppNavigationState state)? onBackButtonPressed;

  @override
  AppNavigatorState createState() => AppNavigatorState();
}

/// Mutable state for an [AppNavigator].
class AppNavigatorState extends State<AppNavigator> with WidgetsBindingObserver {
  /// The underlying Flutter navigator state.
  NavigatorState? get navigator => _observer.navigator;
  final NavigatorObserver _observer = NavigatorObserver();

  late List<NavigatorObserver> _observers;

  /// The current navigation stack.
  ///
  /// Callers must treat the returned list as read-only and use [change] to
  /// propose updates.
  AppNavigationState get state => _state;
  late AppNavigationState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.pages;
    widget.revalidate?.addListener(revalidate);
    _observers = <NavigatorObserver>[_observer, ...widget.observers];
    widget.controller?.addListener(_controllerListener);
    _controllerListener();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    revalidate();
  }

  @override
  void didUpdateWidget(AppNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revalidate != widget.revalidate) {
      oldWidget.revalidate?.removeListener(revalidate);
      widget.revalidate?.addListener(revalidate);
    }
    if (!identical(oldWidget.observers, widget.observers)) {
      _observers = <NavigatorObserver>[_observer, ...widget.observers];
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_controllerListener);
      widget.controller?.addListener(_controllerListener);
      _controllerListener();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_controllerListener);
    widget.revalidate?.removeListener(revalidate);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Handles a back request and reports whether this navigator consumed it.
  @override
  Future<bool> didPopRoute() {
    final handler = widget.onBackButtonPressed;
    if (handler != null) {
      final result = handler(_state.toList());
      change((pages) => result.state);
      return SynchronousFuture<bool>(result.handled);
    }
    if (_state.length < 2) return SynchronousFuture<bool>(false);
    _onDidRemovePage(_state.last);
    return SynchronousFuture<bool>(true);
  }

  /// Reapplies [AppNavigator.guards] to the current stack.
  void revalidate() {
    if (!mounted) return;
    final next = _guard(_state.toList());
    if (next.isEmpty || listEquals(next, _state)) return;
    _update(next);
  }

  /// Applies [change] when it produces a non-empty, distinct, guarded stack.
  void change(AppNavigationState Function(AppNavigationState pages) change) {
    if (!mounted) return;
    final next = _guard(change(_state.toList()));
    if (next.isEmpty || listEquals(next, _state)) return;
    _update(next);
  }

  /// Removes the current page and pushes [page] after [delay].
  void replaceWithAnimation(AppPage page, {Duration delay = kDefaultNavigatorReplaceDuration}) {
    if (_state.length < 2) {
      change((_) => <AppPage>[page]);
      return;
    }
    change((pages) => pages.sublist(0, pages.length - 1));
    Future<void>.delayed(delay).then<void>((_) {
      if (!mounted) return;
      change((pages) => <AppPage>[...pages, page]);
    }).ignore();
  }

  /// Removes [page] and every page above its last occurrence.
  ///
  /// Returns `false` when [page] is absent or is the root page.
  bool removeFrom(AppPage page) {
    final index = _state.lastIndexWhere((candidate) => candidate == page);
    if (index <= 0) return false;
    change((state) => state.sublist(0, index));
    return true;
  }

  void _controllerListener() {
    final controller = widget.controller;
    if (!mounted || controller == null || identical(controller.value, _state)) return;
    final next = _guard(controller.value.toList());
    if (next.isEmpty || listEquals(next, _state)) {
      _setStateToController();
      return;
    }
    _update(next);
  }

  AppNavigationState _guard(AppNavigationState pages) {
    final guarded = widget.guards.fold(pages, (state, guard) => guard(context, state));
    final keys = <LocalKey>{};
    final result = <AppPage>[];
    for (final page in guarded.reversed) {
      final key = page.key;
      if (key != null && !keys.add(key)) continue;
      result.add(page);
    }
    return result.reversed.toList(growable: false);
  }

  void _update(AppNavigationState next) {
    _state = UnmodifiableListView<AppPage>(next);
    _setStateToController();
    setState(() {});
  }

  void _onDidRemovePage(Page<Object?> page) => change((pages) => pages..removeWhere((p) => p.key == page.key));

  void _setStateToController() {
    if (widget.controller case ValueNotifier<AppNavigationState> controller) {
      controller
        ..removeListener(_controllerListener)
        ..value = _state
        ..addListener(_controllerListener);
    }
  }

  @override
  Widget build(BuildContext context) => Navigator(
    transitionDelegate: widget.transitionDelegate,
    reportsRouteUpdateToEngine: false,
    onDidRemovePage: _onDidRemovePage,
    observers: _observers,
    pages: _state,
  );
}
