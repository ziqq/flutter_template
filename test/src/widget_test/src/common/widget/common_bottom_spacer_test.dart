/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 26 June 2026
 */

import 'package:flutter/foundation.dart';
import 'package:flutter_template_name/src/common/widget/common_bottom_spacer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';

import '../../../../util/test_util.dart';

void main() => group('CommonBottomSpacer -', () {
  setUpAll(MockService.initialize);

  group('adaptiveKeyboardInsetOf() -', () {
    testWidgets('returns keyboard inset plus regular offset when keyboard is open', (tester) async {
      final result = await _pumpWidget(
        tester,
        mediaQueryData: const MediaQueryData(viewInsets: EdgeInsets.only(bottom: 200)),
        builder: CommonBottomSpacer.adaptiveKeyboardInsetOf,
      );

      expect(result, 216);
    });

    testWidgets('falls back to heightOf when keyboard is closed', (tester) async {
      await _resolvePlatform(TargetPlatform.iOS, () async {
        final result = await _pumpWidget(
          tester,
          mediaQueryData: const MediaQueryData(viewPadding: EdgeInsets.only(bottom: 20)),
          builder: CommonBottomSpacer.adaptiveKeyboardInsetOf,
        );

        expect(result, 20);
      });
    });
  });

  group('adaptiveBottomInsetOf() -', () {
    testWidgets('uses tab bar height plus small offset when bottom indent is needed', (tester) async {
      await _resolvePlatform(TargetPlatform.android, () async {
        final result = await _pumpWidget(
          tester,
          mediaQueryData: const MediaQueryData(
            size: Size(400, 900),
            viewPadding: EdgeInsets.only(bottom: 16),
            systemGestureInsets: EdgeInsets.only(bottom: 48),
          ),
          builder: (context) => (
            adaptiveInset: CommonBottomSpacer.adaptiveBottomInsetOf(context),
            tabBarHeight: CommonBottomSpacer.tabBarHeightOf(context),
            smallOffset: Theme.of(context).uiTheme.size.offset.small,
          ),
        );

        expect(result.adaptiveInset, result.tabBarHeight + result.smallOffset);
      });
    });

    testWidgets('uses tab bar height plus iOS regular offset only when requested', (tester) async {
      await _resolvePlatform(TargetPlatform.iOS, () async {
        final result = await _pumpWidget(
          tester,
          mediaQueryData: const MediaQueryData(size: Size(400, 900), viewPadding: EdgeInsets.only(bottom: 34)),
          builder: (context) => (
            defaultInset: CommonBottomSpacer.adaptiveBottomInsetOf(context),
            additionalInset: CommonBottomSpacer.adaptiveBottomInsetOf(context, iOSAdditionalOffset: true),
            tabBarHeight: CommonBottomSpacer.tabBarHeightOf(context),
            regularOffset: Theme.of(context).uiTheme.size.offset.regular,
          ),
        );

        expect(result.defaultInset, result.tabBarHeight);
        expect(result.additionalInset, result.tabBarHeight + result.regularOffset);
      });
    });
  });

  group('system inset helpers -', () {
    testWidgets('builder bottom gesture, safe and keyboard insets from MediaQuery', (tester) async {
      final result = await _pumpWidget(
        tester,
        mediaQueryData: const MediaQueryData(
          viewPadding: EdgeInsets.only(bottom: 10),
          systemGestureInsets: EdgeInsets.only(bottom: 18),
          viewInsets: EdgeInsets.only(bottom: 24),
        ),
        builder: (context) => (
          bottomGestureInset: CommonBottomSpacer.bottomGestureInsetOf(context),
          bottomSafeInset: CommonBottomSpacer.bottomSafeInsetOf(context),
          keyboardInset: CommonBottomSpacer.keyboardInsetOf(context),
          keyboardIsOpen: CommonBottomSpacer.keyboardIsOpenOf(context),
        ),
      );

      expect(result.bottomGestureInset, 18);
      expect(result.bottomSafeInset, 10);
      expect(result.keyboardInset, 24);
      expect(result.keyboardIsOpen, isTrue);
    });

    testWidgets('detect android navigation bar and compute related helpers', (tester) async {
      await _resolvePlatform(TargetPlatform.android, () async {
        final result = await _pumpWidget(
          tester,
          mediaQueryData: const MediaQueryData(
            viewPadding: EdgeInsets.only(bottom: 20),
            systemGestureInsets: EdgeInsets.only(bottom: 48),
          ),
          builder: (context) => (
            hasAndroidNavigationBar: CommonBottomSpacer.hasAndroidNavigationBarOf(context),
            hasAndroidSafeArea: CommonBottomSpacer.hasAndroidSafeAreaOf(context),
            hasBottomSystemInset: CommonBottomSpacer.hasBottomSystemInsetOf(context),
            androidNavigationBarInset: CommonBottomSpacer.androidNavigationBarInsetOf(context),
            /* bottomSystemInsetWithGesture: CommonBottomSpacer.bottomSystemInsetOf(context),
            bottomSystemInsetWithoutGesture: CommonBottomSpacer.bottomSystemInsetOf(
              context,
              considerGestureNavigation: false,
            ), */
          ),
        );

        expect(result.hasAndroidNavigationBar, isTrue);
        expect(result.hasAndroidSafeArea, isTrue);
        expect(result.hasBottomSystemInset, isTrue);
        expect(result.androidNavigationBarInset, 48);
        // expect(result.bottomSystemInsetWithGesture, 48);
        // expect(result.bottomSystemInsetWithoutGesture, 20);
      });
    });

    testWidgets('detects iOS bottom safe area only on iOS', (tester) async {
      await _resolvePlatform(TargetPlatform.iOS, () async {
        final result = await _pumpWidget(
          tester,
          mediaQueryData: const MediaQueryData(viewPadding: EdgeInsets.only(bottom: 34)),
          builder: (context) => (
            hasIosBottomSafeArea: CommonBottomSpacer.hasIosBottomSafeAreaOf(context),
            hasBottomSystemInset: CommonBottomSpacer.hasBottomSystemInsetOf(context),
          ),
        );

        expect(result.hasIosBottomSafeArea, isTrue);
        expect(result.hasBottomSystemInset, isTrue);
      });
    });

    testWidgets('does not treat small android safe area as a bottom system inset', (tester) async {
      await _resolvePlatform(TargetPlatform.android, () async {
        final result = await _pumpWidget(
          tester,
          mediaQueryData: const MediaQueryData(
            viewPadding: EdgeInsets.only(bottom: 12),
            systemGestureInsets: EdgeInsets.only(bottom: 24),
          ),
          builder: (context) => (
            hasAndroidNavigationBar: CommonBottomSpacer.hasAndroidNavigationBarOf(context),
            hasAndroidSafeArea: CommonBottomSpacer.hasAndroidSafeAreaOf(context),
            hasBottomSystemInset: CommonBottomSpacer.hasBottomSystemInsetOf(context),
          ),
        );

        expect(result.hasAndroidNavigationBar, isFalse);
        expect(result.hasAndroidSafeArea, isTrue);
        expect(result.hasBottomSystemInset, isFalse);
      });
    });

    testWidgets('needBottomIndentOf follows platform-specific rules', (tester) async {
      await _resolvePlatform(TargetPlatform.android, () async {
        final androidResult = await _pumpWidget(
          tester,
          mediaQueryData: const MediaQueryData(
            viewPadding: EdgeInsets.only(bottom: 16),
            systemGestureInsets: EdgeInsets.only(bottom: 48),
          ),
          builder: CommonBottomSpacer.needBottomIndentOf,
        );

        expect(androidResult, isTrue);
      });

      await _resolvePlatform(TargetPlatform.iOS, () async {
        final withSafeArea = await _pumpWidget(
          tester,
          mediaQueryData: const MediaQueryData(viewPadding: EdgeInsets.only(bottom: 34)),
          builder: CommonBottomSpacer.needBottomIndentOf,
        );
        final withoutSafeArea = await _pumpWidget(
          tester,
          mediaQueryData: const MediaQueryData(),
          builder: CommonBottomSpacer.needBottomIndentOf,
        );

        expect(withSafeArea, isFalse);
        expect(withoutSafeArea, isTrue);
      });
    });
  });

  group('tabBar helpers -', () {
    testWidgets('return portrait tab bar height with bottom inset', (tester) async {
      await _resolvePlatform(TargetPlatform.android, () async {
        final result = await _pumpWidget(
          tester,
          mediaQueryData: const MediaQueryData(
            size: Size(400, 900),
            viewPadding: EdgeInsets.only(bottom: 16),
            systemGestureInsets: EdgeInsets.only(bottom: 48),
          ),
          builder: (context) => (
            tabBarHeight: CommonBottomSpacer.tabBarHeightOf(context),
            tabBarWithBottomInset: CommonBottomSpacer.tabBarWithBottomInsetOf(context),
          ),
        );

        expect(result.tabBarHeight, kTabBarHeight);
        expect(result.tabBarWithBottomInset, kTabBarHeight + 64);
      });
    });

    testWidgets('returns landscape tab bar height', (tester) async {
      final result = await _pumpWidget(
        tester,
        mediaQueryData: const MediaQueryData(size: Size(900, 400)),
        builder: CommonBottomSpacer.tabBarHeightOf,
      );
      expect(result, 38);
    });
  });

  group('heightOf() -', () {
    testWidgets('returns android navigation bar inset plus regular offset', (tester) async {
      await _resolvePlatform(TargetPlatform.android, () async {
        final result = await _pumpWidget(
          tester,
          mediaQueryData: const MediaQueryData(
            viewPadding: EdgeInsets.only(bottom: 16),
            systemGestureInsets: EdgeInsets.only(bottom: 48),
          ),
          builder: CommonBottomSpacer.heightOf,
        );

        expect(result, 64);
      });
    });

    testWidgets('returns regular offset on android without bottom navigation bar', (tester) async {
      await _resolvePlatform(TargetPlatform.android, () async {
        final result = await _pumpWidget(
          tester,
          mediaQueryData: const MediaQueryData(
            viewPadding: EdgeInsets.only(bottom: 12),
            systemGestureInsets: EdgeInsets.only(bottom: 24),
          ),
          builder: CommonBottomSpacer.heightOf,
        );

        expect(result, 16);
      });
    });

    testWidgets('returns iOS safe area without adding regular offset', (tester) async {
      await _resolvePlatform(TargetPlatform.iOS, () async {
        final result = await _pumpWidget(
          tester,
          mediaQueryData: const MediaQueryData(viewPadding: EdgeInsets.only(bottom: 34)),
          builder: CommonBottomSpacer.heightOf,
        );

        expect(result, 34);
      });
    });
  });

  group('build() -', () {
    testWidgets('renders sized box with adaptive height', (tester) async {
      const spacerKey = ValueKey<String>('common-bottom-spacer');
      await _resolvePlatform(TargetPlatform.iOS, () async {
        await tester.pumpWidget(
          _createWidgetUnderTest(
            mediaQueryData: const MediaQueryData(viewPadding: EdgeInsets.only(bottom: 34)),
            child: const CommonBottomSpacer(key: spacerKey),
          ),
        );
        await tester.pumpAndSettle();

        final sizedBox = tester.widget<SizedBox>(
          find.descendant(of: find.byKey(spacerKey), matching: find.byType(SizedBox)),
        );

        expect(sizedBox.height, 34);
      });
    });

    testWidgets('sliver factory renders SliverToBoxAdapter with adaptive height', (tester) async {
      await _resolvePlatform(TargetPlatform.android, () async {
        await tester.pumpWidget(
          _createWidgetUnderTest(
            mediaQueryData: const MediaQueryData(
              viewPadding: EdgeInsets.only(bottom: 16),
              systemGestureInsets: EdgeInsets.only(bottom: 48),
            ),
            child: const CustomScrollView(slivers: <Widget>[CommonBottomSpacer.sliver()]),
          ),
        );
        await tester.pumpAndSettle();

        final sizedBox = tester.widget<SizedBox>(
          find.descendant(of: find.byType(SliverToBoxAdapter), matching: find.byType(SizedBox)),
        );

        expect(find.byType(SliverToBoxAdapter), findsOneWidget);
        expect(sizedBox.height, 64);
      });
    });
  });
});

Widget _createWidgetUnderTest({required MediaQueryData mediaQueryData, required Widget child}) =>
    WidgetTestUtil.createWidgetUnderTest(
      builder: (_) => MediaQuery(data: mediaQueryData, child: child),
    );

Future<void> _resolvePlatform(TargetPlatform platform, Future<void> Function() fn) async {
  final previousPlatform = debugDefaultTargetPlatformOverride;
  debugDefaultTargetPlatformOverride = platform;

  try {
    await fn();
  } finally {
    debugDefaultTargetPlatformOverride = previousPlatform;
  }
}

Future<T> _pumpWidget<T>(
  WidgetTester tester, {
  required MediaQueryData mediaQueryData,
  required T Function(BuildContext context) builder,
}) async {
  late T result;

  await tester.pumpWidget(
    _createWidgetUnderTest(
      mediaQueryData: mediaQueryData,
      child: Builder(
        builder: (context) {
          result = builder(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();

  return result;
}
