/*
 * Date: 08 October 2025
 */

import 'package:flutter/material.dart' show BuildContext, Locale, Localizations;
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/common/router/router.dart';
import 'package:flutter_template_name/src/feature/authentication/model/user.dart';
import 'package:flutter_template_name/src/feature/authentication/widget/authentication_scope.dart';
import 'package:flutter_template_name/src/feature/settings/widget/settings_scope.dart';
import 'package:squid/squid.dart' show NavigationController, NavigationView;

/// Extensions for [BuildContext].
extension BuildContextX on BuildContext {
  /// Wrap [BuildContext] in a [BuildContextExtension] and provide utility methods.
  BuildContextExtension get ext => BuildContextExtension(this);
}

/// Extension for [BuildContext] to provide additional utility methods.
extension type BuildContextExtension(BuildContext _context) {
  /// Get the current dependencies.
  Dependencies get dependencies => Dependencies.of(_context);

  /// Localization extension.
  LocaleExtension get l10n => LocaleExtension(_context);

  /// Navigation actions with the configured haptic feedback.
  NavigatorExtension get navigator => NavigatorExtension(_context);

  /// Settings extension.
  SettingsExtension get settings => SettingsExtension(_context);

  /// Get the current user entity.
  User user({bool listen = true}) => AuthenticationScope.userOf(_context, listen: listen);

  /// Triggers medium haptic feedback.
  void hapticMedium() {
    final enabled = SettingsScope.userPreferencesOf(_context, listen: false).useHapticFeedback == true;
    if (enabled) HapticFeedback.mediumImpact().ignore();
  }

  /// Triggers heavy haptic feedback.
  void hapticHeavy() {
    final enabled = SettingsScope.userPreferencesOf(_context, listen: false).useHapticFeedback == true;
    if (enabled) HapticFeedback.heavyImpact().ignore();
  }

  /// Triggers vibrate haptic feedback.
  void hapticVibrate() {
    final enabled = SettingsScope.userPreferencesOf(_context, listen: false).useHapticFeedback == true;
    if (enabled) HapticFeedback.vibrate().ignore();
  }
}

/// Localization extension.
extension type LocaleExtension(BuildContext _context) {
  /// Current locale of the app.
  Locale get current => Localizations.localeOf(_context);

  /// App localization.
  // AppLocalization get app => AppLocalization.of(_context);

  /// Errors localization.
  // ErrorsLocalization get errors => ErrorsLocalization.of(_context);
}

/// Navigator extension.
extension type NavigatorExtension(BuildContext _context) {
  NavigationController _controller({bool rootNavigator = false}) => rootNavigator
      ? Dependencies.of(_context).navigator
      : NavigationView.maybeOf(_context) ?? Dependencies.of(_context).navigator;

  /// Navigate to a page using the selected app-owned navigation stack.
  void navigate(AppPage page, AppNavigationState Function(AppNavigationState pages) change) {
    _context.ext.hapticHeavy();
    _controller().change(change);
  }

  /// Push a page onto the app-owned navigation stack.
  void push(AppPage page) {
    _context.ext.hapticHeavy();
    _controller().push(page);
  }

  /// Replace the current page on the app-owned navigation stack.
  void replace(AppPage page) {
    _context.ext.hapticHeavy();
    _controller().replaceTop(page);
  }

  /// Pop the current page, wait for the pop animation, then push [page].
  void replaceWithAnimation(
    AppPage page, {
    Duration delay = kDefaultNavigatorReplaceDuration,
    bool rootNavigator = false,
  }) {
    _context.ext.hapticHeavy();
    final controller = _controller(rootNavigator: rootNavigator);
    if (controller.length < 2) {
      controller.replaceTop(page);
      return;
    }
    final navigator = controller.navigator;
    controller.pop();
    Future<void>.delayed(delay).then<void>((_) {
      if (controller.isDisposed) return;
      if (navigator != null && (!navigator.mounted || !identical(controller.navigator, navigator))) return;
      controller.push(page);
    }).ignore();
  }

  /// Reset the app-owned navigation stack.
  void reset(List<AppPage> pages) {
    _context.ext.hapticHeavy();
    if (pages.isEmpty) return;
    _controller().stack = pages;
  }

  /// Pop the current page from the app-owned navigation stack.
  void pop({bool rootNavigator = false}) {
    _context.ext.hapticHeavy();
    _controller(rootNavigator: rootNavigator).pop();
  }
}

/// Settings extension.
extension type SettingsExtension(BuildContext _context) {
  /// Get the current settings.
  Object? aspect(SettingsAspect aspect, {bool listen = true}) =>
      SettingsScope.aspectOf(_context, aspect, listen: listen);

  /// Current locale of the UI selected in settings.
  Locale locale({bool listen = true}) => SettingsScope.settingsOf(_context, listen: listen).locale;

  /// Whether debug mode is enabled.
  bool useDebugMode({bool listen = true}) => SettingsScope.userPreferencesOf(_context, listen: listen).useDebug;

  /// Whether developer mode is enabled.
  bool useDevelopmentMode({bool listen = true}) =>
      SettingsScope.userPreferencesOf(_context, listen: listen).useDevelopment;

  /// Whether haptic feedback is enabled.
  bool useHapticFeedback({bool listen = true}) =>
      SettingsScope.userPreferencesOf(_context, listen: listen).useHapticFeedback;
}
