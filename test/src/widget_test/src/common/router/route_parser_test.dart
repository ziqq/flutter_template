/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 03 August 2026
 */

import 'package:flutter/widgets.dart';
import 'package:flutter_template_name/src/common/router/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group('RouteParseResult -', () {
  test('exposes a typed page for successful parsing', () {
    const page = AppPage(key: ValueKey<String>('known'), name: '/known', child: SizedBox.shrink(), arguments: null);
    const parser = _Parser(page);

    final result = parser.parse('/known');

    expect(result, isA<RouteParseResult$Page<AppPage>>());
    expect(result.pageOrNull, same(page));
    expect(result.failureOrNull, isNull);
  });

  test('exposes structured failure metadata', () {
    const page = AppPage(key: ValueKey<String>('known'), name: '/known', child: SizedBox.shrink(), arguments: null);
    const parser = _Parser(page);

    final result = parser.parse('/unknown');

    expect(result.pageOrNull, isNull);
    expect(result.failureOrNull?.kind, RouteParseFailureKind.unsupportedRoute);
    expect(result.failureOrNull?.route, '/unknown');
  });
});

final class _Parser implements IRouteParser<AppPage> {
  const _Parser(this.page);

  final AppPage page;

  @override
  RouteParseResult<AppPage> parse(String route) => route == page.name
      ? RouteParseResult<AppPage>.page(page)
      : RouteParseResult<AppPage>.failure(
          RouteParseFailure(kind: RouteParseFailureKind.unsupportedRoute, route: route),
        );
}
