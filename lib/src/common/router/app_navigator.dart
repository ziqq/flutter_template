/*
 * Date: 05 May 2025
 */

import 'dart:collection';

import 'package:flutter/foundation.dart' show listEquals, SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/common/router/app_pages.dart';
import 'package:flutter_template_name/src/common/util/analytics.dart';
import 'package:flutter_template_name/src/common/util/string_util.dart';

export 'app_pages.dart';

/// Default duration for the [replaceWithAnimation] method.
const Duration kDefaultNavigatorReplaceDuration = Duration(milliseconds: 350);

/// Typedefinition for the app navigation state.
typedef AppNavigationState = List<AppPage>;

/// {@template navigator}
/// AppNavigator widget.
/// {@endtemplate}
class AppNavigator extends StatefulWidget {
  /// Default constructor: uncontrolled by external controller.
  /// {@macro navigator}
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

  /// Controlled constructor: driven by an external ValueNotifier.
  /// {@macro navigator}
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

  /// The [AppNavigatorState] from an instance of this class that encloses the given context, if any.
  ///
  /// If [rootNavigator] is true, returns the furthest enclosing [AppNavigatorState].
  /// Otherwise, returns the closest enclosing [AppNavigatorState].
  static AppNavigatorState? maybeOf(BuildContext context, {bool rootNavigator = false}) => rootNavigator
      ? context.findRootAncestorStateOfType<AppNavigatorState>()
      : context.findAncestorStateOfType<AppNavigatorState>();

  /// The [AppNavigationState] from the closest instance of this class
  /// that encloses the given context, if any.
  static AppNavigationState? stateOf(BuildContext context, {bool rootNavigator = false}) =>
      maybeOf(context, rootNavigator: rootNavigator)?.state;

  /// The [NavigatorState] from the closest instance of this class
  /// that encloses the given context, if any.
  static NavigatorState? navigatorOf(BuildContext context, {bool rootNavigator = false}) =>
      maybeOf(context, rootNavigator: rootNavigator)?.navigator;

  /// Change the pages.
  static void change(
    BuildContext context,
    AppNavigationState Function(AppNavigationState pages) fn, {
    bool rootNavigator = false,
  }) => maybeOf(context, rootNavigator: rootNavigator)?.change(fn);

  /// Add a new page onto the stack.
  static void push(BuildContext context, AppPage page, {bool rootNavigator = false}) =>
      change(context, (state) => [...state, page], rootNavigator: rootNavigator);

  /// Pops the current page, waits for the pop animation, then pushes [page].
  static void replaceWithAnimation(
    BuildContext context,
    AppPage page, {
    Duration delay = kDefaultNavigatorReplaceDuration,
    bool rootNavigator = false,
  }) => maybeOf(context, rootNavigator: rootNavigator)?.replaceWithAnimation(page, delay: delay);

  /// Reset to the initial pages.
  static void reset(BuildContext context, {bool rootNavigator = false}) {
    final navigator = maybeOf(context, rootNavigator: rootNavigator);
    if (navigator == null) return;
    navigator.change((_) => navigator.widget.pages);
  }

  /// Removes the last flow that starts with page.
  static bool removeFrom(BuildContext context, {required AppPage page, bool rootNavigator = false}) =>
      maybeOf(context, rootNavigator: rootNavigator)?.removeFrom(page) ?? false;

  /// Initial pages to display.
  final AppNavigationState pages;

  /// Optional external controller.
  final ValueNotifier<AppNavigationState>? controller;

  /// Guard to apply to the pages.
  final List<AppNavigationState Function(BuildContext context, AppNavigationState state)> guards;

  /// Observers to attach to the Navigator.
  final List<NavigatorObserver> observers;

  /// TransitionDelegate to use for page transitions.
  final TransitionDelegate<Object?> transitionDelegate;

  /// Optional external signal to re-run guards.
  final Listenable? revalidate;

  /// The callback function that will be called when the back button is pressed.
  ///
  /// It must return a boolean with true if this navigator will handle the request;
  /// otherwise, return a boolean with false.
  ///
  /// Also you can mutate the [AppNavigationState] to change the navigation stack.
  final ({AppNavigationState state, bool handled}) Function(AppNavigationState state)? onBackButtonPressed;

  @override
  AppNavigatorState createState() => AppNavigatorState();
}

/// State for the [AppNavigator] widget.
class AppNavigatorState extends State<AppNavigator> with WidgetsBindingObserver {
  /// Internal observer to get the NavigatorState.
  NavigatorState? get navigator => _observer.navigator;
  final NavigatorObserver _observer = NavigatorObserver();

  /// Current pages list.
  AppNavigationState get state => _state;

  late AppNavigationState _state;

  /// Combined observers (including internal one).
  late List<NavigatorObserver> _observers;

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

  @override
  Future<bool> didPopRoute() {
    // If the back button handler is defined, call it.
    final backButtonHandler = widget.onBackButtonPressed;
    if (backButtonHandler != null) {
      final result = backButtonHandler(_state.toList());
      change((pages) => result.state);
      return SynchronousFuture(result.handled);
    }

    // Otherwise, handle the back button press with the default behavior.
    if (_state.length < 2) return SynchronousFuture(false);
    _onDidRemovePage(_state.last);
    return SynchronousFuture(true);
  }

  void _controllerListener() {
    final controller = widget.controller;
    if (controller == null || !mounted) return;
    final newValue = controller.value;
    if (identical(newValue, _state)) return;
    final ctx = context;
    final next = _removeDuplicatedPageKeys(widget.guards.fold(newValue.toList(), (s, g) => g(ctx, s)));
    if (next.isEmpty || listEquals(next, _state)) {
      _setStateToController(); // Revert the controller value
    } else {
      _state = UnmodifiableListView<AppPage>(next);
      _setStateToController();
      setState(() {});
    }
  }

  /// Revalidate the pages.
  void revalidate() {
    if (!mounted) return;
    final ctx = context;
    final next = _removeDuplicatedPageKeys(widget.guards.fold(_state.toList(), (s, g) => g(ctx, s)));
    if (next.isEmpty || listEquals(next, _state)) return;
    _state = UnmodifiableListView<AppPage>(next);
    _setStateToController();
    setState(() {});
  }

  /// Applies a programmatic change to the navigation stack.
  void change(AppNavigationState Function(AppNavigationState pages) fn) {
    final prev = _state.toList();
    var next = fn(prev);
    if (next.isEmpty) return;
    if (!mounted) return;
    final ctx = context;
    next = _removeDuplicatedPageKeys(widget.guards.fold(next, (s, g) => g(ctx, s)));
    if (next.isEmpty || listEquals(next, _state)) return;
    _state = UnmodifiableListView<AppPage>(next);
    _setStateToController();
    setState(() {});
  }

  /// Pops the current page, waits for the pop animation, then pushes [page].
  void replaceWithAnimation(AppPage page, {Duration delay = kDefaultNavigatorReplaceDuration}) {
    if (_state.length < 2) {
      change((_) => <AppPage>[page]);
      return;
    }

    change((pages) => pages.sublist(0, pages.length - 1));
    Future<void>.delayed(delay).then<void>((_) {
      change((pages) => <AppPage>[...pages, page]);
    }).ignore();
  }

  /// Removes all pages from the stack until the last occurrence of page.
  bool removeFrom(AppPage page) {
    final index = _state.lastIndexWhere((p) => p == page);
    if (index <= 0) return false;
    change((state) => state.sublist(0, index));
    return true;
  }

  /// Removes duplicated page keys from the navigation state,
  /// keeping only the last occurrence of each key.
  AppNavigationState _removeDuplicatedPageKeys(AppNavigationState pages) {
    final keys = <LocalKey>{};
    final result = <AppPage>[];
    for (final page in pages.reversed) {
      final key = page.key;
      if (key != null && !keys.add(key)) continue;
      result.add(page);
    }
    return result.reversed.toList(growable: false);
  }

  // Called when the page is removed from the stack.
  void _onDidRemovePage(Page<Object?> page) {
    change((pages) => pages..removeWhere((p) => p.key == page.key));
  }

  /// Sets the current state to the external controller if it exists.
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

/// Observer for the [AppNavigatorObserver].
final class AppNavigatorObserver extends NavigatorObserver {
  AppNavigatorObserver({required Analytics analytics}) : _analytics = analytics;

  /// The analytics instance to log events.
  final Analytics _analytics;

  /// Sanitizes the route name by removing dashes, capitalizing words, and appending 'Route'.
  String _sanitazeRouteName(String? name) =>
      '${name?.replaceAll('-', ' ').toCapitilize().split(' ').join('') ?? 'Unknown'}Route';

  /// Called when a new page is pushed onto the stack.
  @override
  void didPush(Route<Object?> route, Route<Object?>? previousRoute) {
    super.didPush(route, previousRoute);
    final routeName = _sanitazeRouteName(route.settings.name);
    if (routeName == '/flushbarrouteRoute' || routeName == 'UnknownRoute') return;
    _analytics
        .logPageView(
          routeName,
          parameters: <String, String>{
            'previous': _sanitazeRouteName(previousRoute?.settings.name),
            'current': _sanitazeRouteName(route.settings.name),
          },
        )
        .ignore();
  }
}
