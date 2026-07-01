/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 24 December 2024
 */

import 'dart:math' as math show max;

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter_template_name/src/common/util/screen_util.dart' show ScreenUtilExtension;
import 'package:meta/meta.dart';
import 'package:ui/ui.dart';

/// {@template common_bottom_spacer}
/// Adds adaptive spacing at the bottom of the screen.
///
/// Use this as the last child in a column-like layout or as trailing spacing in
/// scroll content when the screen should stay readable above the system bottom
/// area.
///
/// The spacer derives its height from [MediaQuery] and the current UI theme. It
/// accounts for the keyboard, the iOS home indicator, Android button
/// navigation, and the regular bottom offset used by the app theme.
/// {@endtemplate}
class CommonBottomSpacer extends StatelessWidget {
  /// {@macro common_bottom_spacer}
  const CommonBottomSpacer({super.key});

  /// Returns a sliver that adds adaptive bottom spacing.
  ///
  /// Use this as the last sliver in a [CustomScrollView] when scroll content
  /// should stop above the bottom system area.
  @literal
  const factory CommonBottomSpacer.sliver({Key? key}) = _CommonBottomSpacer$Sliver;

  /// The minimum bottom inset treated as Android button navigation.
  ///
  /// Gesture insets around this size are typically reported on 3-button Android
  /// navigation bars.
  static const double _kAndroidNavigationBarThreshold = 48.0;

  /// Returns the bottom system gesture area reported by the system.
  ///
  /// On Android this may contain the area reserved for navigation gestures.
  static double bottomGestureInsetOf(BuildContext context) => MediaQuery.systemGestureInsetsOf(context).bottom;

  /// Returns the bottom safe area reported by the system.
  ///
  /// On iOS this is usually the home indicator area.
  /// On Android this may be the bottom navigation bar area.
  static double bottomSafeInsetOf(BuildContext context) => MediaQuery.viewPaddingOf(context).bottom;

  /// Whether Android probably has a bottom button navigation bar.
  ///
  /// Flutter does not expose a reliable public API for detecting 3-button
  /// navigation. In practice, button navigation may be reported as a large bottom
  /// [MediaQueryData.systemGestureInsets] value, for example 48dp on Pixel 2.
  static bool hasAndroidNavigationBarOf(BuildContext context) {
    if (defaultTargetPlatform != .android) return false;
    final safeInset = bottomSafeInsetOf(context);
    final gestureInset = bottomGestureInsetOf(context);
    return safeInset >= _kAndroidNavigationBarThreshold || gestureInset >= _kAndroidNavigationBarThreshold;
  }

  /// Whether the device has an Android-like bottom safe area.
  static bool hasAndroidSafeAreaOf(BuildContext context) {
    if (defaultTargetPlatform != .android) return false;
    return bottomSafeInsetOf(context) > .0;
  }

  /// Whether the device has an iOS-like bottom safe area.
  static bool hasIosBottomSafeAreaOf(BuildContext context) {
    if (defaultTargetPlatform != .iOS) return false;
    return bottomSafeInsetOf(context) > .0;
  }

  /// Whether the device has a bottom system inset that this helper treats as significant.
  ///
  /// On Android this returns `true` only when button navigation is detected by
  /// [hasAndroidNavigationBarOf]. On iOS this returns `true` when a bottom safe
  /// area is present.
  static bool hasBottomSystemInsetOf(BuildContext context) =>
      hasAndroidNavigationBarOf(context) || hasIosBottomSafeAreaOf(context);

  /// Returns the Android bottom navigation bar inset.
  ///
  /// Returns zero when Android button navigation is not detected.
  static double androidNavigationBarInsetOf(BuildContext context) {
    if (!hasAndroidNavigationBarOf(context)) return .0;
    final gestureInset = bottomGestureInsetOf(context);
    final safeInset = bottomSafeInsetOf(context);
    return math.max(safeInset, gestureInset);
  }

  /// Whether content should add extra bottom indent above the system area.
  ///
  /// On `Android` this is enabled only when button navigation is detected.
  /// On `iOS` this is enabled only when there is no bottom safe area, so content
  /// still keeps the app's bottom offset on devices without a home-indicator inset.
  static bool needBottomIndentOf(BuildContext context) {
    switch (defaultTargetPlatform) {
      case .android:
        return hasAndroidNavigationBarOf(context);
      case .iOS:
        return !hasIosBottomSafeAreaOf(context);
      default:
        return false;
    }
  }

  /// Returns the adaptive bottom inset for content above the system area.
  /// [excludeBottomSafeInset] - if true, the bottom system inset will be excluded from the result.
  /// [iOSAdditionalOffset] - if true, an additional offset will be added for iOS devices.
  ///
  /// Tips:
  /// [excludeBottomSafeInset] - set to true when the content should be above the system area,
  /// for example, when using a stack and positioning widgets above the system area.
  /// See [lib/src/feature/calendar/widget/calendar_screen.dart] for example.
  ///
  /// [iOSAdditionalOffset] - set to true when the content should have additional offset for iOS devices,
  /// for example, when using a stack and positioning widgets above the system area.
  /// See [lib/src/feature/calendar/widget/calendar_screen.dart] for example.
  static double adaptiveBottomInsetOf(
    BuildContext context, {
    bool excludeBottomSafeInset = true,
    bool iOSAdditionalOffset = false,
  }) {
    final theme = Theme.of(context);
    final smallOffset = theme.uiTheme.size.offset.small;
    final regularOffset = theme.uiTheme.size.offset.regular;
    final tabBarHeight = excludeBottomSafeInset ? tabBarHeightOf(context) : tabBarWithBottomInsetOf(context);
    if (needBottomIndentOf(context)) {
      return tabBarHeight + smallOffset;
    }
    return switch (defaultTargetPlatform) {
      .android => tabBarHeight + regularOffset - (excludeBottomSafeInset ? bottomSafeInsetOf(context) : .0),
      .iOS => tabBarHeight + (iOSAdditionalOffset ? regularOffset : .0),
      _ => 0,
    };
  }

  /// Returns the current keyboard height.
  ///
  /// Returns zero when the keyboard is closed.
  static double keyboardInsetOf(BuildContext context) => MediaQuery.viewInsetsOf(context).bottom;

  /// Whether the keyboard is currently visible.
  static bool keyboardIsOpenOf(BuildContext context) => keyboardInsetOf(context) > .0;

  /// Returns an adaptive bottom inset for input panels and bottom actions.
  ///
  /// When the keyboard is open, returns the keyboard height plus the regular
  /// offset. When the keyboard is closed, returns [heightOf].
  static double adaptiveKeyboardInsetOf(BuildContext context) {
    final keyboardInset = keyboardInsetOf(context);
    if (keyboardInset > .0) {
      final offset = Theme.of(context).uiTheme.size.offset.regular;
      return keyboardInset + offset;
    }
    return heightOf(context);
  }

  /// Returns adaptive bottom spacing for regular screen content.
  ///
  /// Rules:
  /// - Android navigation bar: navigation bar inset + regular offset.
  /// - iOS home indicator: safe area only.
  /// - Other Android layouts: regular offset.
  /// - Other platforms: regular offset.
  static double heightOf(BuildContext context) {
    final offset = Theme.of(context).uiTheme.size.offset.regular;
    switch (defaultTargetPlatform) {
      case .android:
        final navigationBarInset = androidNavigationBarInsetOf(context);
        if (navigationBarInset > .0) return navigationBarInset + offset;
        return offset;
      case .iOS:
        final safeInset = bottomSafeInsetOf(context);
        if (safeInset > .0) return safeInset;
        return offset;
      default:
        return offset;
    }
  }

  /// Returns the visual tab bar height based on the current orientation.
  ///
  /// This does not include bottom safe area or navigation bar spacing.
  static double tabBarHeightOf(BuildContext context) => context.orientation == .portrait ? kTabBarHeight : 38.0;

  /// Returns the tab bar height plus adaptive bottom spacing.
  ///
  /// Use this when a bottom navigation or tab bar should include bottom system
  /// spacing.
  static double tabBarWithBottomInsetOf(BuildContext context) => tabBarHeightOf(context) + heightOf(context);

  /// Returns the [FloatingActionButtonLocation] based on the bottom safe area.
  ///
  /// Prefer explicit FAB placement in new code. This helper remains only for
  /// legacy call sites that still mirror the old docked-vs-floating behavior.
  @Deprecated('Do not use this method. Will be removed in the future.')
  static FloatingActionButtonLocation fabLocationOf(BuildContext context) => bottomSafeInsetOf(context) > .0
      ? FloatingActionButtonLocation.centerDocked
      : FloatingActionButtonLocation.centerFloat;

  @override
  Widget build(BuildContext context) => SizedBox(height: heightOf(context));
}

/// A sliver wrapper around [CommonBottomSpacer].
///
/// Use this when a sliver list or custom scroll view needs the same adaptive
/// bottom spacing contract as the box widget variant.
class _CommonBottomSpacer$Sliver extends CommonBottomSpacer {
  /// {@macro common_bottom_spacer}
  const _CommonBottomSpacer$Sliver({
    super.key, // ignore: unused_element_parameter
  });

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(child: super.build(context));
}
