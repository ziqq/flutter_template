/*
 * Date: 08 October 2025
 */

import 'package:flutter/material.dart' show BuildContext, Locale, Localizations;
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/common/router/app_navigator.dart';
import 'package:flutter_template_name/src/feature/authentication/model/user.dart';
import 'package:flutter_template_name/src/feature/authentication/widget/authentication_scope.dart';
import 'package:flutter_template_name/src/feature/settings/widget/settings_scope.dart';

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

  /// Navigator extension.
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
  /// Get the current dependencies.
  Dependencies get _dependencies => Dependencies.of(_context);

  /// Navigate to a page using the app-owned navigation stack.
  void navigate(AppPage page, AppNavigationState Function(AppNavigationState pages) change) {
    final enabled = SettingsScope.userPreferencesOf(_context, listen: false).useHapticFeedback == true;
    if (enabled) HapticFeedback.heavyImpact().ignore();
    final navigator = AppNavigator.maybeOf(_context);
    if (navigator != null) {
      navigator.change(change);
      return;
    }
    _dependencies.navigator.value = change(_dependencies.navigator.value);
  }

  /// Push a page onto the app-owned navigation stack.
  void push(AppPage page) {
    final enabled = SettingsScope.userPreferencesOf(_context, listen: false).useHapticFeedback == true;
    if (enabled) HapticFeedback.heavyImpact().ignore();
    final navigator = AppNavigator.maybeOf(_context);
    if (navigator != null) {
      AppNavigator.push(_context, page);
      return;
    }
    _dependencies.navigator.value = <AppPage>[..._dependencies.navigator.value, page];
  }

  /// Replace the current page on the app-owned navigation stack.
  void replace(AppPage page) {
    final enabled = SettingsScope.userPreferencesOf(_context, listen: false).useHapticFeedback == true;
    if (enabled) HapticFeedback.heavyImpact().ignore();
    final navigator = AppNavigator.maybeOf(_context);
    if (navigator != null) {
      AppNavigator.change(_context, (state) => <AppPage>[...state..removeLast(), page]);
      return;
    }
    final current = _dependencies.navigator.value;
    if (current.isEmpty) {
      _dependencies.navigator.value = <AppPage>[page];
      return;
    }
    _dependencies.navigator.value = <AppPage>[...current..removeLast(), page];
  }

  /// Pop the current app-owned page, wait for the pop animation, then push [page].
  void replaceWithAnimation(
    AppPage page, {
    Duration delay = kDefaultNavigatorReplaceDuration,
    bool rootNavigator = false,
  }) {
    final enabled = SettingsScope.userPreferencesOf(_context, listen: false).useHapticFeedback == true;
    if (enabled) HapticFeedback.heavyImpact().ignore();

    final navigator = AppNavigator.maybeOf(_context, rootNavigator: rootNavigator);
    if (navigator != null) {
      navigator.replaceWithAnimation(page, delay: delay);
      return;
    }

    final controller = _dependencies.navigator;
    final current = controller.value;
    if (current.length < 2) {
      controller.value = <AppPage>[page];
      return;
    }

    controller.value = current.sublist(0, current.length - 1);
    Future<void>.delayed(delay).then<void>((_) {
      controller.value = <AppPage>[...controller.value, page];
    }).ignore();
  }

  /// Reset the app-owned navigation stack.
  void reset(List<AppPage> pages) {
    final enabled = SettingsScope.userPreferencesOf(_context, listen: false).useHapticFeedback == true;
    if (enabled) HapticFeedback.heavyImpact().ignore();
    if (pages.isEmpty) return;
    final navigator = AppNavigator.maybeOf(_context);
    if (navigator != null) {
      AppNavigator.change(_context, (_) => pages);
      return;
    }
    _dependencies.navigator.value = pages;
  }

  /// Pop the current page from the app-owned navigation stack.
  void pop({bool rootNavigator = false}) {
    final enabled = SettingsScope.userPreferencesOf(_context, listen: false).useHapticFeedback == true;
    if (enabled) HapticFeedback.heavyImpact().ignore();

    final navigator = AppNavigator.maybeOf(_context, rootNavigator: rootNavigator);
    if (navigator != null) {
      navigator.change((state) {
        if (state.length < 2) return state;
        return state.sublist(0, state.length - 1);
      });
      return;
    }

    final current = _dependencies.navigator.value;
    if (current.length < 2) return;
    _dependencies.navigator.value = current.sublist(0, current.length - 1);
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
