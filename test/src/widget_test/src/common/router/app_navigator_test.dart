/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 05 May 2026
 */

// ignore_for_file: cascade_invocations

import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/common/router/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group('AppNavigator -', () {
  testWidgets('supports an uncontrolled stack with feature-owned pages', (tester) async {
    final root = _FeaturePage('root');
    final next = _FeaturePage('next');
    await tester.pumpWidget(MaterialApp(home: AppNavigator(pages: [root])));

    final state = tester.state<AppNavigatorState>(find.byType(AppNavigator));
    state.change((pages) => <AppPage>[...pages, next]);
    await tester.pumpAndSettle();

    expect(state.state, <AppPage>[root, next]);
    expect(find.byKey(const ValueKey<String>('feature_next')), findsOneWidget);

    await expectLater(state.didPopRoute(), completion(isTrue));
    await tester.pumpAndSettle();
    expect(state.state, <AppPage>[root]);
    expect(find.byKey(const ValueKey<String>('feature_root')), findsOneWidget);
  });

  group('guards -', () {
    testWidgets('applies guards when the external controller changes', (tester) async {
      final root = _page('root');
      final blocked = _page('blocked');
      final allowed = _page('allowed');
      final controller = ValueNotifier<AppNavigationState>(<AppPage>[root]);
      addTearDown(controller.dispose);

      await _pumpNavigator(
        tester,
        controller,
        guards: [(_, state) => state.where((page) => page.name != 'blocked').toList(growable: false)],
      );

      controller.value = <AppPage>[root, blocked, allowed];
      await tester.pump();

      expect(controller.value, <AppPage>[root, allowed]);
      expect(tester.state<AppNavigatorState>(find.byType(AppNavigator)).state, <AppPage>[root, allowed]);
    });

    testWidgets('reverts the controller when guards produce an empty stack', (tester) async {
      final root = _page('root');
      final blocked = _page('blocked');
      final controller = ValueNotifier<AppNavigationState>(<AppPage>[root]);
      addTearDown(controller.dispose);

      await _pumpNavigator(tester, controller, guards: [(_, _) => <AppPage>[]]);

      controller.value = <AppPage>[blocked];
      await tester.pump();

      expect(controller.value, <AppPage>[root]);
      expect(tester.state<AppNavigatorState>(find.byType(AppNavigator)).state, <AppPage>[root]);
    });
  });

  group('revalidate -', () {
    testWidgets('reruns guards and synchronizes the controller', (tester) async {
      var canShowGatedPage = true;
      final revalidate = ChangeNotifier();
      final root = _page('root');
      final gated = _page('gated');
      final controller = ValueNotifier<AppNavigationState>(<AppPage>[root, gated]);
      addTearDown(controller.dispose);
      addTearDown(revalidate.dispose);

      await _pumpNavigator(
        tester,
        controller,
        guards: [
          (_, state) => canShowGatedPage ? state : state.where((page) => page.name != 'gated').toList(growable: false),
        ],
        revalidate: revalidate,
      );

      expect(controller.value, <AppPage>[root, gated]);

      canShowGatedPage = false;
      revalidate.notifyListeners();
      await tester.pump();

      expect(controller.value, <AppPage>[root]);
      expect(tester.state<AppNavigatorState>(find.byType(AppNavigator)).state, <AppPage>[root]);
    });

    testWidgets('detaches the old signal when the widget receives a new revalidate listenable', (tester) async {
      var canShowGatedPage = true;
      final oldRevalidate = ChangeNotifier();
      final newRevalidate = ChangeNotifier();
      final root = _page('root');
      final gated = _page('gated');
      final controller = ValueNotifier<AppNavigationState>(<AppPage>[root, gated]);
      addTearDown(oldRevalidate.dispose);
      addTearDown(newRevalidate.dispose);
      addTearDown(controller.dispose);

      AppNavigationState guard(BuildContext _, AppNavigationState state) =>
          canShowGatedPage ? state : state.where((page) => page.name != 'gated').toList(growable: false);

      await _pumpNavigator(tester, controller, guards: [guard], revalidate: oldRevalidate);
      await _pumpNavigator(tester, controller, guards: [guard], revalidate: newRevalidate);

      canShowGatedPage = false;
      oldRevalidate.notifyListeners();
      await tester.pump();

      expect(controller.value, <AppPage>[root, gated]);

      newRevalidate.notifyListeners();
      await tester.pump();

      expect(controller.value, <AppPage>[root]);
    });
  });

  group('controller lifecycle -', () {
    testWidgets('detaches the old controller and synchronizes the replacement controller', (tester) async {
      final oldRoot = _page('old-root');
      final oldNext = _page('old-next');
      final newRoot = _page('new-root');
      final newNext = _page('new-next');
      final oldController = ValueNotifier<AppNavigationState>(<AppPage>[oldRoot]);
      final newController = ValueNotifier<AppNavigationState>(<AppPage>[newRoot]);
      addTearDown(oldController.dispose);
      addTearDown(newController.dispose);

      await _pumpNavigator(tester, oldController);
      await _pumpNavigator(tester, newController);

      final state = tester.state<AppNavigatorState>(find.byType(AppNavigator));
      expect(state.state, <AppPage>[newRoot]);

      oldController.value = <AppPage>[oldRoot, oldNext];
      await tester.pump();

      expect(state.state, <AppPage>[newRoot]);
      expect(newController.value, <AppPage>[newRoot]);

      newController.value = <AppPage>[newRoot, newNext];
      await tester.pump();

      expect(state.state, <AppPage>[newRoot, newNext]);
    });
  });

  group('observers -', () {
    testWidgets('detaches replaced observers from the Flutter navigator', (tester) async {
      final root = _page('root');
      final first = _page('first');
      final second = _page('second');
      final controller = ValueNotifier<AppNavigationState>(<AppPage>[root]);
      final oldObserver = _RecordingNavigatorObserver();
      final newObserver = _RecordingNavigatorObserver();
      addTearDown(controller.dispose);

      await _pumpNavigator(tester, controller, observers: <NavigatorObserver>[oldObserver]);

      controller.value = <AppPage>[root, first];
      await tester.pumpAndSettle();
      final oldPushes = oldObserver.pushedNames.length;
      expect(oldObserver.pushedNames, contains('first'));

      await _pumpNavigator(tester, controller, observers: <NavigatorObserver>[newObserver]);
      controller.value = <AppPage>[root, first, second];
      await tester.pumpAndSettle();

      expect(oldObserver.pushedNames, hasLength(oldPushes));
      expect(newObserver.pushedNames, contains('second'));
    });
  });

  group('replaceWithAnimation -', () {
    testWidgets('pops the current page and pushes replacement after delay', (tester) async {
      final first = _page('first');
      final second = _page('second');
      final replacement = _page('replacement');
      final controller = ValueNotifier<AppNavigationState>(<AppPage>[first, second]);
      addTearDown(controller.dispose);

      await _pumpNavigator(tester, controller);

      final state = tester.state<AppNavigatorState>(find.byType(AppNavigator));
      state.replaceWithAnimation(replacement, delay: const Duration(milliseconds: 10));

      expect(controller.value, <AppPage>[first]);

      await tester.pump(const Duration(milliseconds: 9));
      expect(controller.value, <AppPage>[first]);

      await tester.pump(const Duration(milliseconds: 1));
      expect(controller.value, <AppPage>[first, replacement]);
    });

    testWidgets('replaces the only page immediately', (tester) async {
      final first = _page('first');
      final replacement = _page('replacement');
      final controller = ValueNotifier<AppNavigationState>(<AppPage>[first]);
      addTearDown(controller.dispose);

      await _pumpNavigator(tester, controller);

      final state = tester.state<AppNavigatorState>(find.byType(AppNavigator));
      state.replaceWithAnimation(replacement, delay: const Duration(milliseconds: 10));

      expect(controller.value, <AppPage>[replacement]);
    });

    testWidgets('does not push the replacement after the navigator is disposed', (tester) async {
      final first = _page('first');
      final second = _page('second');
      final replacement = _page('replacement');
      final controller = ValueNotifier<AppNavigationState>(<AppPage>[first, second]);
      addTearDown(controller.dispose);

      await _pumpNavigator(tester, controller);

      final state = tester.state<AppNavigatorState>(find.byType(AppNavigator));
      state.replaceWithAnimation(replacement, delay: const Duration(milliseconds: 10));

      expect(controller.value, <AppPage>[first]);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 10));

      expect(controller.value, <AppPage>[first]);
    });
  });

  group('change -', () {
    testWidgets('ignores mutations that would leave the stack empty', (tester) async {
      final root = _page('root');
      final current = _page('current');
      final controller = ValueNotifier<AppNavigationState>(<AppPage>[root, current]);
      addTearDown(controller.dispose);

      await _pumpNavigator(tester, controller);

      final state = tester.state<AppNavigatorState>(find.byType(AppNavigator));
      state.change((_) => <AppPage>[]);
      await tester.pump();

      expect(controller.value, <AppPage>[root, current]);
      expect(state.state, <AppPage>[root, current]);
    });
  });

  group('removeFrom -', () {
    testWidgets('removes the last matching page and every page above it', (tester) async {
      final root = _page('root');
      final flow = _page('flow');
      final step = _page('step');
      final controller = ValueNotifier<AppNavigationState>(<AppPage>[root, flow, step]);
      addTearDown(controller.dispose);

      await _pumpNavigator(tester, controller);

      final state = tester.state<AppNavigatorState>(find.byType(AppNavigator));

      expect(state.removeFrom(flow), isTrue);
      await tester.pump();
      expect(controller.value, <AppPage>[root]);
    });

    testWidgets('does not remove the root page or a missing page', (tester) async {
      final root = _page('root');
      final current = _page('current');
      final controller = ValueNotifier<AppNavigationState>(<AppPage>[root, current]);
      addTearDown(controller.dispose);

      await _pumpNavigator(tester, controller);

      final state = tester.state<AppNavigatorState>(find.byType(AppNavigator));

      expect(state.removeFrom(root), isFalse);
      expect(state.removeFrom(_page('missing')), isFalse);
      expect(controller.value, <AppPage>[root, current]);
    });
  });

  group('duplicate page keys -', () {
    testWidgets('keeps the last page for each duplicated key', (tester) async {
      final first = _page('first');
      final second = _page('second');
      final duplicate = _page('first');
      final controller = ValueNotifier<AppNavigationState>(<AppPage>[first, second]);
      addTearDown(controller.dispose);

      await _pumpNavigator(tester, controller);

      controller.value = <AppPage>[first, second, duplicate];
      await tester.pump();

      expect(controller.value, hasLength(2));
      expect(identical(controller.value.first, second), isTrue);
      expect(identical(controller.value.last, duplicate), isTrue);
    });
  });

  group('maybeOf -', () {
    testWidgets('returns nearest or root app navigator by lookup mode', (tester) async {
      AppNavigatorState? nearest;
      AppNavigatorState? root;

      final nestedController = ValueNotifier<AppNavigationState>(<AppPage>[
        _page(
          'nested',
          child: Builder(
            builder: (context) {
              nearest = AppNavigator.maybeOf(context);
              root = AppNavigator.maybeOf(context, rootNavigator: true);
              return const SizedBox.shrink();
            },
          ),
        ),
      ]);
      final rootController = ValueNotifier<AppNavigationState>(<AppPage>[
        _page(
          'root',
          child: SizedBox(width: 48, height: 48, child: AppNavigator.controlled(controller: nestedController)),
        ),
      ]);
      addTearDown(nestedController.dispose);
      addTearDown(rootController.dispose);

      await _pumpNavigator(tester, rootController);

      final states = tester.stateList<AppNavigatorState>(find.byType(AppNavigator)).toList(growable: false);
      expect(states, hasLength(2));
      expect(nearest, isNotNull);
      expect(root, isNotNull);
      expect(identical(nearest, states.last), isTrue);
      expect(identical(root, states.first), isTrue);
    });
  });

  group('pop -', () {
    testWidgets('pops the nearest app navigator by default and the root navigator when requested', (tester) async {
      late BuildContext nestedContext;

      final nestedController = ValueNotifier<AppNavigationState>(<AppPage>[
        _page('nested-root'),
        _page(
          'nested-current',
          child: Builder(
            builder: (context) {
              nestedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ]);
      final rootController = ValueNotifier<AppNavigationState>(<AppPage>[
        _page('root'),
        _page(
          'root-current',
          child: SizedBox(width: 48, height: 48, child: AppNavigator.controlled(controller: nestedController)),
        ),
      ]);
      addTearDown(nestedController.dispose);
      addTearDown(rootController.dispose);

      await _pumpNavigator(tester, rootController);

      AppNavigator.change(nestedContext, (state) => state.sublist(0, state.length - 1));
      await tester.pump();

      expect(nestedController.value, <AppPage>[_page('nested-root')]);
      expect(rootController.value, hasLength(2));

      AppNavigator.change(nestedContext, (state) => state.sublist(0, state.length - 1), rootNavigator: true);
      await tester.pump();

      expect(rootController.value, <AppPage>[_page('root')]);
    });
  });

  group('didPopRoute -', () {
    testWidgets('allows a nested flow to own platform back before closing its host', (tester) async {
      final nestedController = ValueNotifier<AppNavigationState>(<AppPage>[
        _page('nested-root'),
        _page('nested-current'),
      ]);
      final root = _page('root');
      final flow = _page('flow', child: AppNavigator.controlled(controller: nestedController));
      final rootController = ValueNotifier<AppNavigationState>(<AppPage>[root, flow]);
      addTearDown(nestedController.dispose);
      addTearDown(rootController.dispose);

      await _pumpNavigator(
        tester,
        rootController,
        onBackButtonPressed: (pages) => nestedController.value.length > 1
            ? (state: pages, handled: false)
            : (state: <AppPage>[root], handled: true),
      );

      expect(await tester.binding.handlePopRoute(), isTrue);
      await tester.pumpAndSettle();
      expect(nestedController.value, <AppPage>[_page('nested-root')]);
      expect(rootController.value, <AppPage>[root, flow]);

      expect(await tester.binding.handlePopRoute(), isTrue);
      await tester.pumpAndSettle();
      expect(rootController.value, <AppPage>[root]);
    });

    testWidgets('handles platform back through the enclosing route', (tester) async {
      final root = _page('root');
      final current = _page('current');
      final controller = ValueNotifier<AppNavigationState>(<AppPage>[root, current]);
      addTearDown(controller.dispose);

      await _pumpNavigator(tester, controller);

      expect(await tester.binding.handlePopRoute(), isTrue);
      await tester.pump();

      expect(controller.value, <AppPage>[root]);
    });

    testWidgets('lets platform back escape a single-page stack', (tester) async {
      final root = _page('root');
      final controller = ValueNotifier<AppNavigationState>(<AppPage>[root]);
      addTearDown(controller.dispose);

      await _pumpNavigator(tester, controller);

      expect(await tester.binding.handlePopRoute(), isFalse);
      await tester.pump();

      expect(controller.value, <AppPage>[root]);
    });

    testWidgets('pops the last page by default and reports whether the route was handled', (tester) async {
      final root = _page('root');
      final current = _page('current');
      final controller = ValueNotifier<AppNavigationState>(<AppPage>[root, current]);
      addTearDown(controller.dispose);

      await _pumpNavigator(tester, controller);

      final state = tester.state<AppNavigatorState>(find.byType(AppNavigator));

      await expectLater(state.didPopRoute(), completion(isTrue));
      expect(controller.value, <AppPage>[root]);

      await expectLater(state.didPopRoute(), completion(isFalse));
      expect(controller.value, <AppPage>[root]);
    });

    testWidgets('uses the custom back handler when provided', (tester) async {
      AppNavigationState? handledState;
      final root = _page('root');
      final current = _page('current');
      final controller = ValueNotifier<AppNavigationState>(<AppPage>[root, current]);
      addTearDown(controller.dispose);

      await _pumpNavigator(
        tester,
        controller,
        onBackButtonPressed: (state) {
          handledState = state;
          return (state: <AppPage>[root], handled: true);
        },
      );

      final state = tester.state<AppNavigatorState>(find.byType(AppNavigator));

      await expectLater(state.didPopRoute(), completion(isTrue));
      expect(handledState, <AppPage>[root, current]);
      expect(controller.value, <AppPage>[root]);
    });
  });

  group('reset -', () {
    testWidgets('restores the initial pages from the root app navigator', (tester) async {
      late BuildContext resetContext;
      final root = _page('root');
      final initial = _page('initial');
      final replacement = _page(
        'replacement',
        child: Builder(
          builder: (context) {
            resetContext = context;
            return const SizedBox.shrink();
          },
        ),
      );
      final controller = ValueNotifier<AppNavigationState>(<AppPage>[root, initial]);
      addTearDown(controller.dispose);

      await _pumpNavigator(tester, controller);

      controller.value = <AppPage>[root, replacement];
      await tester.pump();

      AppNavigator.reset(resetContext);
      await tester.pump();

      expect(controller.value, <AppPage>[root, initial]);
    });
  });
});

AppPage _page(String id, {Widget? child}) => AppPage$Fade(
  key: ValueKey<String>(id),
  name: id,
  arguments: null,
  child: child ?? SizedBox(key: ValueKey<String>('child_$id')),
);

Future<void> _pumpNavigator(
  WidgetTester tester,
  ValueNotifier<AppNavigationState> controller, {
  List<AppNavigationState Function(BuildContext context, AppNavigationState state)> guards = const [],
  List<NavigatorObserver> observers = const [],
  Listenable? revalidate,
  ({AppNavigationState state, bool handled}) Function(AppNavigationState state)? onBackButtonPressed,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AppNavigator.controlled(
        controller: controller,
        guards: guards,
        observers: observers,
        revalidate: revalidate,
        onBackButtonPressed: onBackButtonPressed,
      ),
    ),
  );
  await tester.pump();
}

final class _RecordingNavigatorObserver extends NavigatorObserver {
  final List<String?> pushedNames = <String?>[];

  @override
  void didPush(Route<Object?> route, Route<Object?>? previousRoute) {
    super.didPush(route, previousRoute);
    pushedNames.add(route.settings.name);
  }
}

final class _FeaturePage extends AppPage {
  _FeaturePage(String id)
    : super(
        key: ValueKey<String>(id),
        name: id,
        arguments: null,
        child: SizedBox(key: ValueKey<String>('feature_$id')),
      );
}
