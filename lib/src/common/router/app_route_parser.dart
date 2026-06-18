/*
 * Date: 06 May 2026
 */

// ignore_for_file: avoid_classes_with_only_static_members, unused_element

import 'package:flutter_template_name/src/common/router/app_pages.dart';
import 'package:meta/meta.dart';

/// Failure reason for app-owned route parsing.
enum AppRouteParseFailureKind {
  /// The route is not owned by the app navigator parser.
  unsupportedRoute,

  /// The route shape is known, but one of its parameters is invalid.
  malformedParameter,

  /// The route shape is known, but creating the page requires a model or controller that is not in the route.
  unavailablePreloadedData,
}

/// Typed route parser failure.
@immutable
final class AppRouteParseFailure {
  /// Creates route parser failure metadata.
  const AppRouteParseFailure({required this.kind, required this.route, this.parameter});

  /// Failure kind.
  final AppRouteParseFailureKind kind;

  /// Original route string.
  final String route;

  /// Optional failed or missing parameter name.
  final String? parameter;
}

/// Typed route parser result.
@immutable
sealed class AppRouteParseResult {
  /// Creates a parser result.
  const AppRouteParseResult();

  /// Creates a successful parser result.
  const factory AppRouteParseResult.page(AppPage page) = AppRouteParseResult$Page;

  /// Creates a failed parser result.
  const factory AppRouteParseResult.failure(AppRouteParseFailure failure) = AppRouteParseResult$Failure;

  /// Parsed app page, if any.
  AppPage? get pageOrNull => switch (this) {
    AppRouteParseResult$Page(:AppPage page) => page,
    AppRouteParseResult$Failure() => null,
  };

  /// Parser failure, if any.
  AppRouteParseFailure? get failureOrNull => switch (this) {
    AppRouteParseResult$Page() => null,
    AppRouteParseResult$Failure(:AppRouteParseFailure failure) => failure,
  };
}

/// Successful route parser result.
@immutable
final class AppRouteParseResult$Page extends AppRouteParseResult {
  /// Creates a successful parser result.
  const AppRouteParseResult$Page(this.page);

  /// Parsed app page.
  final AppPage page;
}

/// Failed route parser result.
@immutable
final class AppRouteParseResult$Failure extends AppRouteParseResult {
  /// Creates a failed parser result.
  const AppRouteParseResult$Failure(this.failure);

  /// Parser failure metadata.
  final AppRouteParseFailure failure;
}

/// Parser for app-owned route strings.
abstract final class AppRouteParser {
  /// Parses [route] into a typed [AppPage] or a typed failure.
  static AppRouteParseResult parse(String route) {
    final staticPage = switch (route) {
      '/developer' => const DeveloperPage(),
      _ => null,
    };
    if (staticPage != null) return AppRouteParseResult.page(staticPage);

    final uri = Uri.tryParse(route);
    if (uri == null || uri.hasAuthority || uri.pathSegments.isEmpty) return _unsupported(route);

    final segments = uri.pathSegments;
    return switch (segments) {
      // --- Unsoported routes --- //
      _ => _unsupported(route),
    };
  }

  static AppRouteParseResult _stringID(String route, String id, String parameter, AppPage Function(String id) build) {
    if (id.isEmpty || _isRoutePlaceholder(id)) return _malformedParameter(route, parameter);
    return AppRouteParseResult.page(build(id));
  }

  static AppRouteParseResult _numericStringID(
    String route,
    String id,
    String parameter,
    AppPage Function(String id) build,
  ) {
    if (_isRoutePlaceholder(id) || int.tryParse(id) == null) return _malformedParameter(route, parameter);
    return AppRouteParseResult.page(build(id));
  }

  static AppRouteParseResult _intID(String route, String id, String parameter, AppPage Function(int id) build) {
    if (_isRoutePlaceholder(id)) return _malformedParameter(route, parameter);
    final value = int.tryParse(id);
    if (value == null) return _malformedParameter(route, parameter);
    return AppRouteParseResult.page(build(value));
  }

  static AppRouteParseResult _unsupported(String route) =>
      AppRouteParseResult.failure(AppRouteParseFailure(route: route, kind: .unsupportedRoute));

  static AppRouteParseResult _unavailablePreloadedData(String route) =>
      AppRouteParseResult.failure(AppRouteParseFailure(route: route, kind: .unavailablePreloadedData));

  static AppRouteParseResult _malformedParameter(String route, String parameter) =>
      AppRouteParseResult.failure(AppRouteParseFailure(route: route, kind: .malformedParameter, parameter: parameter));

  static bool _isRoutePlaceholder(String value) => value.startsWith(':');
}
