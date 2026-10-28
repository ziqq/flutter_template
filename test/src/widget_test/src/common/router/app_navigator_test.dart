/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 05 May 2026
 */

// ignore_for_file: cascade_invocations

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/common/router/router.dart';
import 'package:flutter_template_name/src/common/util/context_extension.dart';
import 'package:flutter_template_name/src/feature/settings/controller/settings_controller.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_settings.dart';
import 'package:flutter_template_name/src/feature/settings/model/user_preferences.dart';
import 'package:flutter_template_name/src/feature/settings/widget/settings_scope.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squid/squid.dart';

import '../../../../util/test_util.mocks.dart';

void main() => group('Squid navigation -', () {
  testWidgets('renders a controller-owned stack with feature-owned pages', (tester) async {
    final root = _FeaturePage('root');
    final next = _FeaturePage('next');
    final controller = NavigationController([root]);
    addTearDown(controller.dispose);
    await _pumpNavigator(tester, controller);

    controller.change((pages) => [...pages, next]);
    await tester.pumpAndSettle();

    expect(controller.stack, <AppPage>[root, next]);
    expect(find.byKey(const ValueKey<String>('feature_next')), findsOneWidget);

    await expectLater(controller.maybePop(), completion(isTrue));
    await tester.pumpAndSettle();
    expect(controller.stack, <AppPage>[root]);
    expect(find.byKey(const ValueKey<String>('feature_root')), findsOneWidget);
  });

  group('guards -', () {
    testWidgets('applies guards when the controller stack changes', (tester) async {
      final root = _page('root');
      final blocked = _page('blocked');
      final allowed = _page('allowed');
      final controller = NavigationController(
        [root],
        guards: [NavigationGuard((_, stack) => stack.where((page) => page.name != 'blocked').toList())],
      );
      addTearDown(controller.dispose);
      await _pumpNavigator(tester, controller);

      controller.stack = [root, blocked, allowed];
      await tester.pump();

      expect(controller.stack, <AppPage>[root, allowed]);
      expect(find.byKey(const ValueKey<String>('child_allowed')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('child_blocked')), findsNothing);
    });

    testWidgets('reports and rejects a change when guards produce an empty stack', (tester) async {
      final root = _page('root');
      final blocked = _page('blocked');
      final controller = NavigationController(
        [root],
        guards: [NavigationGuard((_, stack) => stack.where((page) => page.name != 'blocked').toList())],
      );
      addTearDown(controller.dispose);
      await _pumpNavigator(tester, controller);

      controller.stack = [blocked];
      expect(tester.takeException(), isA<StateError>());
      await tester.pump();

      expect(controller.stack, <AppPage>[root]);
      expect(find.byKey(const ValueKey<String>('child_root')), findsOneWidget);
    });
  });

  group('revalidate -', () {
    testWidgets('reruns guards when the controller signal changes', (tester) async {
      var canShowGatedPage = true;
      final revalidate = ChangeNotifier();
      final root = _page('root');
      final gated = _page('gated');
      final controller = NavigationController(
        [root, gated],
        guards: [
          NavigationGuard(
            (_, stack) => canShowGatedPage ? stack : stack.where((page) => page.name != 'gated').toList(),
          ),
        ],
        revalidate: revalidate,
      );
      addTearDown(controller.dispose);
      addTearDown(revalidate.dispose);
      await _pumpNavigator(tester, controller);

      expect(controller.stack, <AppPage>[root, gated]);
      canShowGatedPage = false;
      revalidate.notifyListeners();
      await tester.pump();

      expect(controller.stack, <AppPage>[root]);
      expect(find.byKey(const ValueKey<String>('child_root')), findsOneWidget);
    });

    testWidgets('uses the replacement signal after its owner disposes the old controller', (tester) async {
      var canShowGatedPage = true;
      final oldRevalidate = ChangeNotifier();
      final newRevalidate = ChangeNotifier();
      final root = _page('root');
      final gated = _page('gated');
      final guard = NavigationGuard(
        (_, stack) => canShowGatedPage ? stack : stack.where((page) => page.name != 'gated').toList(),
      );
      final oldController = NavigationController([root, gated], guards: [guard], revalidate: oldRevalidate);
      final newController = NavigationController([root, gated], guards: [guard], revalidate: newRevalidate);
      addTearDown(oldRevalidate.dispose);
      addTearDown(newRevalidate.dispose);
      addTearDown(oldController.dispose);
      addTearDown(newController.dispose);

      await _pumpNavigator(tester, oldController);
      await _pumpNavigator(tester, newController);
      oldController.dispose();
      expect(oldController.isDisposed, isTrue);
      expect(newController.isDisposed, isFalse);

      canShowGatedPage = false;
      oldRevalidate.notifyListeners();
      await tester.pump();
      expect(newController.stack, <AppPage>[root, gated]);

      newRevalidate.notifyListeners();
      await tester.pump();
      expect(newController.stack, <AppPage>[root]);
    });
  });

  group('controller lifecycle -', () {
    testWidgets('detaches the old controller and renders the replacement controller', (tester) async {
      final oldRoot = _page('old-root');
      final oldNext = _page('old-next');
      final newRoot = _page('new-root');
      final newNext = _page('new-next');
      final oldController = NavigationController([oldRoot]);
      final newController = NavigationController([newRoot]);
      addTearDown(oldController.dispose);
      addTearDown(newController.dispose);

      await _pumpNavigator(tester, oldController);
      await _pumpNavigator(tester, newController);
      expect(oldController.navigator, isNull);
      expect(oldController.context, isNull);
      expect(oldController.isDisposed, isFalse);
      expect(tester.widget<NavigationView>(find.byType(NavigationView)).controller, same(newController));
      expect(newController.stack, <AppPage>[newRoot]);

      oldController.stack = [oldRoot, oldNext];
      await tester.pump();
      expect(newController.stack, <AppPage>[newRoot]);
      expect(find.byKey(const ValueKey<String>('child_old-next')), findsNothing);

      newController.stack = [newRoot, newNext];
      await tester.pump();
      expect(newController.stack, <AppPage>[newRoot, newNext]);
      expect(find.byKey(const ValueKey<String>('child_new-next')), findsOneWidget);
    });
  });

  group('observers -', () {
    testWidgets('detaches replaced observers from the Flutter navigator', (tester) async {
      final root = _page('root');
      final first = _page('first');
      final second = _page('second');
      final controller = NavigationController([root]);
      final oldObserver = _RecordingNavigatorObserver();
      final newObserver = _RecordingNavigatorObserver();
      addTearDown(controller.dispose);
      await _pumpNavigator(tester, controller, observers: [oldObserver]);

      controller.stack = [root, first];
      await tester.pumpAndSettle();
      final oldPushes = oldObserver.pushedNames.length;
      expect(oldObserver.pushedNames, contains('first'));

      await _pumpNavigator(tester, controller, observers: [newObserver]);
      controller.stack = [root, first, second];
      await tester.pumpAndSettle();

      expect(oldObserver.pushedNames, hasLength(oldPushes));
      expect(newObserver.pushedNames, contains('second'));
    });
  });

  group('replaceTop -', () {
    testWidgets('replaces the current page while keeping previous pages', (tester) async {
      final first = _page('first');
      final second = _page('second');
      final replacement = _page('replacement');
      final controller = NavigationController([first, second]);
      addTearDown(controller.dispose);
      await _pumpNavigator(tester, controller);

      controller.replaceTop(replacement);
      expect(controller.stack, <AppPage>[first, replacement]);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('child_replacement')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('child_second')), findsNothing);
    });

    testWidgets('replaces the only page immediately', (tester) async {
      final first = _page('first');
      final replacement = _page('replacement');
      final controller = NavigationController([first]);
      addTearDown(controller.dispose);
      await _pumpNavigator(tester, controller);

      controller.replaceTop(replacement);
      expect(controller.stack, <AppPage>[replacement]);
    });

    testWidgets('ignores replacement after the owner disposes the controller', (tester) async {
      final first = _page('first');
      final second = _page('second');
      final replacement = _page('replacement');
      final controller = NavigationController([first, second]);
      addTearDown(controller.dispose);
      await _pumpNavigator(tester, controller);

      await tester.pumpWidget(const SizedBox.shrink());
      expect(controller.isDisposed, isFalse);
      controller.dispose();
      controller.replaceTop(replacement);
      await tester.pump();

      expect(controller.isDisposed, isTrue);
      expect(controller.stack, <AppPage>[first, second]);
    });
  });

  group('change -', () {
    testWidgets('reports and rejects mutations that would leave the stack empty', (tester) async {
      final root = _page('root');
      final current = _page('current');
      final controller = NavigationController([root, current]);
      addTearDown(controller.dispose);
      await _pumpNavigator(tester, controller);

      controller.change((_) => []);
      expect(tester.takeException(), isA<StateError>());
      await tester.pump();
      expect(controller.stack, <AppPage>[root, current]);
    });
  });

  group('flow removal -', () {
    testWidgets('pops the flow and every page above it back to its parent', (tester) async {
      final root = _page('root');
      final flow = _page('flow');
      final step = _page('step');
      final controller = NavigationController([root, flow, step]);
      addTearDown(controller.dispose);
      await _pumpNavigator(tester, controller);

      controller.popUntil((route) => route.key == root.key);
      await tester.pump();
      expect(controller.stack, <AppPage>[root]);
    });

    testWidgets('preserves the root through RootGuard and ignores a missing page', (tester) async {
      final root = _page('root');
      final current = _page('current');
      final controller = NavigationController([root, current], guards: [RootGuard(() => root)]);
      addTearDown(controller.dispose);
      await _pumpNavigator(tester, controller);

      expect(controller.remove(root), isTrue);
      expect(controller.stack, <AppPage>[root, current]);
      expect(controller.remove(_page('missing')), isFalse);
      expect(controller.stack, <AppPage>[root, current]);
    });
  });

  group('duplicate page keys -', () {
    testWidgets('keeps the last page for each duplicated key', (tester) async {
      final first = _page('first');
      final second = _page('second');
      final duplicate = _page('first');
      final controller = NavigationController([first, second]);
      addTearDown(controller.dispose);
      await _pumpNavigator(tester, controller);

      controller.stack = [first, second, duplicate];
      await tester.pump();
      expect(controller.stack, hasLength(2));
      expect(identical(controller.stack.first, second), isTrue);
      expect(identical(controller.stack.last, duplicate), isTrue);
    });
  });

  group('maybeOf -', () {
    testWidgets('returns the nearest controller while dependencies expose the root', (tester) async {
      NavigationController? nearest;
      NavigationController? root;
      final nestedController = NavigationController([
        _page(
          'nested',
          child: Builder(
            builder: (context) {
              nearest = NavigationView.of(context);
              root = Dependencies.of(context).navigator;
              return const SizedBox.shrink();
            },
          ),
        ),
      ]);
      final rootController = NavigationController([
        _page(
          'root',
          child: SizedBox(width: 48, height: 48, child: NavigationView(controller: nestedController)),
        ),
      ]);
      addTearDown(nestedController.dispose);
      addTearDown(rootController.dispose);
      final dependencies = FakeDependencies()..navigator = rootController;
      await _pumpNavigator(tester, rootController, dependencies: dependencies);

      expect(find.byType(NavigationView), findsNWidgets(2));
      expect(nearest, same(nestedController));
      expect(root, same(rootController));
    });
  });

  group('pop -', () {
    testWidgets('pops the nearest controller and explicitly targets the root through dependencies', (tester) async {
      late BuildContext nestedContext;
      final nestedController = NavigationController([
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
      final rootController = NavigationController([
        _page('root'),
        _page(
          'root-current',
          child: SizedBox(width: 48, height: 48, child: NavigationView(controller: nestedController)),
        ),
      ]);
      addTearDown(nestedController.dispose);
      addTearDown(rootController.dispose);
      final dependencies = FakeDependencies()..navigator = rootController;
      await _pumpNavigator(tester, rootController, dependencies: dependencies, withSettings: true);

      nestedContext.ext.navigator.pop();
      await tester.pump();
      expect(nestedController.stack, <AppPage>[_page('nested-root')]);
      expect(rootController.stack, hasLength(2));

      tester.element(find.byType(NavigationView).first).ext.navigator.pop(rootNavigator: true);
      await tester.pump();
      expect(rootController.stack, <AppPage>[_page('root')]);
    });
  });

  group('back -', () {
    testWidgets('allows a nested flow to own platform back before closing its host', (tester) async {
      final nestedController = NavigationController([_page('nested-root'), _page('nested-current')]);
      final root = _page('root');
      final flow = _page('flow', child: NavigationView(controller: nestedController));
      final rootController = NavigationController([root, flow]);
      addTearDown(nestedController.dispose);
      addTearDown(rootController.dispose);
      await _pumpNavigator(
        tester,
        rootController,
        onBackButtonPressed: (controller) async {
          if (nestedController.stack.length > 1) return false;
          controller.stack = [root];
          return true;
        },
      );

      expect(await tester.binding.handlePopRoute(), isTrue);
      await tester.pumpAndSettle();
      expect(nestedController.stack, <AppPage>[_page('nested-root')]);
      expect(rootController.stack, <AppPage>[root, flow]);

      expect(await tester.binding.handlePopRoute(), isTrue);
      await tester.pumpAndSettle();
      expect(rootController.stack, <AppPage>[root]);
    });

    testWidgets('handles platform back through the enclosing route', (tester) async {
      final root = _page('root');
      final current = _page('current');
      final controller = NavigationController([root, current]);
      addTearDown(controller.dispose);
      await _pumpNavigator(tester, controller);

      expect(await tester.binding.handlePopRoute(), isTrue);
      await tester.pump();
      expect(controller.stack, <AppPage>[root]);
    });

    testWidgets('honors PopScope before removing the current application page', (tester) async {
      final canPop = ValueNotifier(false);
      final root = _page('root');
      final current = _page(
        'current',
        child: ValueListenableBuilder<bool>(
          valueListenable: canPop,
          builder: (context, value, child) => PopScope<void>(canPop: value, child: child!),
          child: const Text('Protected page'),
        ),
      );
      final controller = NavigationController([root, current]);
      addTearDown(canPop.dispose);
      addTearDown(controller.dispose);
      await _pumpNavigator(tester, controller);

      expect(await tester.binding.handlePopRoute(), isTrue);
      await tester.pumpAndSettle();
      expect(controller.stack, [root, current]);
      expect(find.text('Protected page'), findsOneWidget);

      canPop.value = true;
      await tester.pump();
      expect(await tester.binding.handlePopRoute(), isTrue);
      await tester.pumpAndSettle();
      expect(controller.stack, [root]);
      expect(find.text('Protected page'), findsNothing);
    });

    testWidgets('lets platform back escape a single-page stack', (tester) async {
      final root = _page('root');
      final controller = NavigationController([root]);
      addTearDown(controller.dispose);
      await _pumpNavigator(tester, controller);

      expect(await tester.binding.handlePopRoute(), isFalse);
      await tester.pump();
      expect(controller.stack, <AppPage>[root]);
    });

    testWidgets('pops the last page and reports whether back was handled', (tester) async {
      final root = _page('root');
      final current = _page('current');
      final controller = NavigationController([root, current]);
      addTearDown(controller.dispose);
      await _pumpNavigator(tester, controller);

      await expectLater(controller.maybePop(), completion(isTrue));
      await tester.pumpAndSettle();
      expect(controller.stack, <AppPage>[root]);
      await expectLater(controller.maybePop(), completion(isFalse));
      expect(controller.stack, <AppPage>[root]);
    });

    testWidgets('uses the custom back handler when provided', (tester) async {
      NavigationStack? handledState;
      final root = _page('root');
      final current = _page('current');
      final controller = NavigationController([root, current]);
      addTearDown(controller.dispose);
      await _pumpNavigator(
        tester,
        controller,
        onBackButtonPressed: (navigation) async {
          handledState = navigation.stack;
          navigation.stack = [root];
          return true;
        },
      );

      expect(await tester.binding.handlePopRoute(), isTrue);
      expect(handledState, <AppPage>[root, current]);
      expect(controller.stack, <AppPage>[root]);
    });
  });

  group('context navigation -', () {
    for (final enabled in [true, false]) {
      testWidgets('keeps context actions and includes haptics when enabled=$enabled', (tester) async {
        final haptics = <String>[];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') haptics.add(call.arguments as String);
          return null;
        });
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null),
        );
        final root = _page('root');
        final next = _page('next');
        final replacement = _page('replacement');
        final controller = NavigationController([root]);
        addTearDown(controller.dispose);
        await _pumpNavigator(tester, controller, withSettings: true, hapticFeedback: enabled);
        final context = tester.element(find.byType(NavigationView));
        expect(NavigationView.maybeOf(context), isNull);

        context.ext.navigator.push(next);
        expect(controller.stack, [root, next]);
        context.ext.navigator.replace(replacement);
        expect(controller.stack, [root, replacement]);
        context.ext.navigator.navigate(next, (pages) => [...pages, next]);
        expect(controller.stack, [root, replacement, next]);
        context.ext.navigator.pop();
        expect(controller.stack, [root, replacement]);
        context.ext.navigator.reset([]);
        expect(controller.stack, [root, replacement]);
        context.ext.navigator.reset([root]);
        expect(controller.stack, [root]);
        context.ext.navigator.replaceWithAnimation(replacement);
        expect(controller.stack, [replacement]);
        await tester.pump();
        expect(haptics, enabled ? List.filled(7, 'HapticFeedbackType.heavyImpact') : <String>[]);
      });
    }

    testWidgets('waits for the pop animation before pushing a replacement', (tester) async {
      late BuildContext context;
      final root = _page('root');
      final current = _page(
        'current',
        child: Builder(
          builder: (value) {
            context = value;
            return const SizedBox.shrink();
          },
        ),
      );
      final replacement = _page('replacement');
      final controller = NavigationController([root, current]);
      addTearDown(controller.dispose);
      await _pumpNavigator(tester, controller, withSettings: true);

      context.ext.navigator.replaceWithAnimation(replacement);
      expect(controller.stack, [root]);
      await tester.pump(kDefaultNavigatorReplaceDuration - const Duration(milliseconds: 1));
      expect(controller.stack, [root]);
      await tester.pump(const Duration(milliseconds: 1));
      expect(controller.stack, [root, replacement]);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    for (final disposeController in [false, true]) {
      testWidgets('discards delayed replacement after unmount, disposed=$disposeController', (tester) async {
        final root = _page('root');
        final controller = NavigationController([root, _page('current')]);
        addTearDown(controller.dispose);
        await _pumpNavigator(tester, controller, withSettings: true);
        final context = tester.element(find.byType(NavigationView));
        context.ext.navigator.replaceWithAnimation(_page('replacement'));
        await tester.pumpWidget(const SizedBox.shrink());
        if (disposeController) controller.dispose();
        await tester.pump(kDefaultNavigatorReplaceDuration);
        expect(controller.stack, [root]);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('animated root replacement leaves the nested controller unchanged', (tester) async {
      late BuildContext context;
      final nested = NavigationController([
        _page('nested-root'),
        _page(
          'nested-current',
          child: Builder(
            builder: (value) {
              context = value;
              return const SizedBox.shrink();
            },
          ),
        ),
      ]);
      final root = _page('root');
      final controller = NavigationController([
        root,
        _page(
          'host',
          child: SizedBox(width: 48, height: 48, child: NavigationView(controller: nested)),
        ),
      ]);
      addTearDown(nested.dispose);
      addTearDown(controller.dispose);
      await _pumpNavigator(tester, controller, withSettings: true);
      final replacement = _page('replacement');
      context.ext.navigator.replaceWithAnimation(replacement, rootNavigator: true);
      expect(controller.stack, [root]);
      expect(nested.length, 2);
      await tester.pump(kDefaultNavigatorReplaceDuration);
      expect(controller.stack, [root, replacement]);
      expect(nested.length, 2);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('stack replacement -', () {
    testWidgets('restores an explicitly retained initial stack through the nearest controller', (tester) async {
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
      final initialStack = <AppPage>[root, initial];
      final controller = NavigationController(initialStack);
      addTearDown(controller.dispose);
      await _pumpNavigator(tester, controller, withSettings: true);

      controller.stack = [root, replacement];
      await tester.pump();
      resetContext.ext.navigator.reset(initialStack);
      await tester.pump();
      expect(controller.stack, <AppPage>[root, initial]);
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
  NavigationController controller, {
  List<NavigatorObserver> observers = const [],
  Future<bool> Function(NavigationController)? onBackButtonPressed,
  Dependencies? dependencies,
  bool withSettings = false,
  bool hapticFeedback = true,
}) async {
  final navigation = NavigationView(
    controller: controller,
    observers: observers,
    onBackButtonPressed: onBackButtonPressed,
  );
  final container = dependencies ?? (withSettings ? (FakeDependencies()..navigator = controller) : null);
  if (withSettings) {
    final settings = SettingsController(
      repository: MockSettingsRepository(),
      initialState: SettingsState.idle(
        preferences: UserPreferences(useHapticFeedback: hapticFeedback),
        settings: const AppSettings.empty(),
      ),
    );
    container!.settingsController = settings;
  }
  final child = MaterialApp(home: withSettings ? SettingsScope(child: navigation) : navigation);
  await tester.pumpWidget(container?.inject(child: child) ?? child);
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
