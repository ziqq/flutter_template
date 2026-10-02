import 'package:flutter/widgets.dart';
import 'package:flutter_template_name/src/common/router/app_pages.dart';
import 'package:flutter_template_name/src/common/router/app_route_parser.dart';
import 'package:flutter_template_name/src/common/router/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group('AppRouteParser -', () {
  test('preserves the developer destination and its identity', () {
    final result = AppRouteParser.parse('/developer');

    expect(result, isA<RouteParseResult$Page<AppPage>>());
    expect(result, isA<AppRouteParseResult$Page>());
    expect(result.pageOrNull, const DeveloperPage());
    expect(result.pageOrNull?.key, const ValueKey<String>('developer'));
    expect(result.pageOrNull?.name, 'developer');
    expect(result.failureOrNull, isNull);
  });

  test('reports unsupported input without inventing destinations or throwing', () {
    for (final route in <String>[
      '',
      '/',
      '/home',
      '/sign-up',
      '/developer-info',
      '/developer?tab=info',
      'https://example.com/developer',
      '/%FF',
      '/unknown/:id',
    ]) {
      final result = AppRouteParser.parse(route);

      expect(result, isA<AppRouteParseResult$Failure>(), reason: route);
      expect(result.pageOrNull, isNull, reason: route);
      expect(result.failureOrNull?.kind, AppRouteParseFailureKind.unsupportedRoute, reason: route);
      expect(result.failureOrNull?.route, route);
    }
  });
});
