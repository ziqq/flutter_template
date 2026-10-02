/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 03 August 2026
 */

// ignore_for_file: one_member_abstracts

import 'package:flutter_template_name/src/common/router/page.dart';
import 'package:meta/meta.dart';

/// The reason a route could not be converted to a page.
enum RouteParseFailureKind {
  /// The parser does not own the route.
  unsupportedRoute,

  /// A known route contains an invalid parameter.
  malformedParameter,

  /// Creating the destination requires data that is not encoded in the route.
  unavailablePreloadedData,
}

/// Metadata describing a route parsing failure.
@immutable
final class RouteParseFailure {
  /// Creates route parsing failure metadata.
  const RouteParseFailure({required this.kind, required this.route, this.parameter});

  /// The failure category.
  final RouteParseFailureKind kind;

  /// The original route passed to the parser.
  final String route;

  /// The name of the invalid or missing parameter, when applicable.
  final String? parameter;
}

/// The result of parsing a route into an [AppPage] subtype.
@immutable
sealed class RouteParseResult<P extends AppPage> {
  /// Creates a parser result.
  const RouteParseResult();

  /// Creates a successful result containing [page].
  const factory RouteParseResult.page(P page) = RouteParseResult$Page<P>;

  /// Creates a failed result containing [failure].
  const factory RouteParseResult.failure(RouteParseFailure failure) = RouteParseResult$Failure<P>;

  /// The parsed page, or `null` for a failed result.
  P? get pageOrNull => switch (this) {
    RouteParseResult$Page<P>(:P page) => page,
    RouteParseResult$Failure<P>() => null,
  };

  /// The parsing failure, or `null` for a successful result.
  RouteParseFailure? get failureOrNull => switch (this) {
    RouteParseResult$Page<P>() => null,
    RouteParseResult$Failure<P>(:RouteParseFailure failure) => failure,
  };
}

/// A successful route parsing result.
@immutable
final class RouteParseResult$Page<P extends AppPage> extends RouteParseResult<P> {
  /// Creates a successful result containing [page].
  const RouteParseResult$Page(this.page);

  /// The parsed page.
  final P page;
}

/// A failed route parsing result.
@immutable
final class RouteParseResult$Failure<P extends AppPage> extends RouteParseResult<P> {
  /// Creates a failed result containing [failure].
  const RouteParseResult$Failure(this.failure);

  /// The parsing failure.
  final RouteParseFailure failure;
}

/// Converts route strings into an application-owned [AppPage] subtype.
///
/// Implementations own concrete route tables and return typed failures instead
/// of throwing for unsupported routes or invalid external parameters.
abstract interface class IRouteParser<P extends AppPage> {
  /// Parses [route] into a page or a typed failure.
  RouteParseResult<P> parse(String route);
}
