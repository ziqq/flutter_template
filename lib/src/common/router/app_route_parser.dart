// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter_template_name/src/common/router/app_pages.dart';
import 'package:flutter_template_name/src/common/router/router.dart';

/// App-facing alias for the shared route failure kind.
typedef AppRouteParseFailureKind = RouteParseFailureKind;

/// App-facing alias for shared route failure metadata.
typedef AppRouteParseFailure = RouteParseFailure;

/// App-facing route parser result specialized to [AppPage].
typedef AppRouteParseResult = RouteParseResult<AppPage>;

/// App-facing successful route parser result.
typedef AppRouteParseResult$Page = RouteParseResult$Page<AppPage>;

/// App-facing failed route parser result.
typedef AppRouteParseResult$Failure = RouteParseResult$Failure<AppPage>;

/// Parser for app-owned route strings.
abstract final class AppRouteParser {
  /// Parses [route] into a typed page or failure without modifying the stack.
  static AppRouteParseResult parse(String route) => switch (route) {
    '/developer' => const AppRouteParseResult.page(DeveloperPage()),
    _ => AppRouteParseResult.failure(AppRouteParseFailure(route: route, kind: .unsupportedRoute)),
  };
}
