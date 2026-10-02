/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 03 August 2026
 */

import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/common/router/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group('AppPage -', () {
  testWidgets('keeps the previous page visible below an overlay and synchronizes a Flutter pop', (tester) async {
    const root = AppPage(key: ValueKey<String>('root'), name: 'root', arguments: null, child: Text('Root content'));
    const overlay = AppPage(
      key: ValueKey<String>('overlay'),
      name: 'overlay',
      arguments: null,
      opaque: false,
      barrierColor: Color(0x66000000),
      child: Align(alignment: Alignment.topCenter, child: Text('Overlay content')),
    );
    final controller = ValueNotifier<AppNavigationState>(const [root]);
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(home: AppNavigator.controlled(controller: controller)));

    controller.value = const [root, overlay];
    await tester.pumpAndSettle();
    expect(find.text('Root content'), findsOneWidget);
    expect(find.text('Overlay content'), findsOneWidget);

    final state = tester.state<AppNavigatorState>(find.byType(AppNavigator));
    state.navigator!.pop();
    await tester.pumpAndSettle();
    expect(controller.value, const [root]);
    expect(find.text('Root content'), findsOneWidget);
    expect(find.text('Overlay content'), findsNothing);
  }, variant: const TargetPlatformVariant({TargetPlatform.android, TargetPlatform.iOS}));

  test('normalizes route metadata and compares pages by key', () {
    const first = AppPage(
      key: ValueKey<String>('page'),
      name: '/page',
      arguments: <String, Object?>{},
      path: '/page/:id',
      child: SizedBox.shrink(),
    );
    const sameKey = AppPage$Fade(key: ValueKey<String>('page'), name: '/other', child: SizedBox.shrink());

    expect(first.name, '/page');
    expect(first.arguments, isEmpty);
    expect(first.path, '/page/:id');
    expect(first, sameKey);
    expect(first.hashCode, sameKey.hashCode);
  });

  testWidgets('creates an overlay route with the requested presentation metadata', (tester) async {
    const barrierColor = Color(0x66000000);
    late PageRoute<void> route;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: Builder(
          builder: (context) {
            route = const AppPage(
              key: ValueKey<String>('overlay'),
              name: '/overlay',
              arguments: null,
              opaque: false,
              barrierColor: barrierColor,
              child: SizedBox.shrink(),
            ).createRoute(context) as PageRoute<void>;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(route.opaque, isFalse);
    expect(route.barrierColor, barrierColor);
    expect(route.settings.name, '/overlay');
  });

  testWidgets('creates a Cupertino overlay route without requiring an opaque page', (tester) async {
    const barrierColor = Color(0x66000000);
    late PageRoute<void> route;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: Builder(
          builder: (context) {
            route = const AppPage(
              key: ValueKey<String>('cupertino-overlay'),
              name: 'cupertino_overlay',
              arguments: null,
              opaque: false,
              barrierColor: barrierColor,
              child: SizedBox.shrink(),
            ).createRoute(context) as PageRoute<void>;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(route.opaque, isFalse);
    expect(route.barrierColor, barrierColor);
    expect(route.delegatedTransition, isNotNull);
    expect(route.canTransitionFrom(_TestPopupRoute()), isTrue);
  });

  testWidgets('configures fade and slide routes independently', (tester) async {
    late PageRoute<Object?> fadeRoute;
    late PageRoute<Object?> slideRoute;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            fadeRoute = const AppPage$Fade(
              key: ValueKey<String>('fade'),
              name: '/fade',
              duration: Duration(milliseconds: 180),
              child: SizedBox.shrink(),
            ).createRoute(context) as PageRoute<Object?>;
            slideRoute = const AppPage$SlideFromBottom(
              key: ValueKey<String>('slide'),
              name: '/slide',
              duration: Duration(milliseconds: 220),
              child: SizedBox.shrink(),
            ).createRoute(context) as PageRoute<Object?>;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(fadeRoute.transitionDuration, const Duration(milliseconds: 180));
    expect(slideRoute.transitionDuration, const Duration(milliseconds: 220));
    expect(fadeRoute.fullscreenDialog, isTrue);
    expect(slideRoute.fullscreenDialog, isTrue);
  });
});

final class _TestPopupRoute extends PopupRoute<void> {
  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
      const SizedBox.shrink();
}
