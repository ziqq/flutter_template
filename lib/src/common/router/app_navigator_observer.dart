import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/common/util/analytics.dart';
import 'package:flutter_template_name/src/common/util/string_util.dart';

/// Observer for the [AppNavigatorObserver].
final class AppNavigatorObserver extends NavigatorObserver {
  AppNavigatorObserver({required this._analytics});

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
