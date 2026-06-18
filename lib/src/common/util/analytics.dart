// ignore_for_file: avoid_classes_with_only_static_members, avoid_positional_boolean_parameters

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/foundation.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:l/l.dart';

/// AnalyticsTracker is an abstract interface for tracking analytics events.
/// It provides methods to set user ID, user properties, log events, and handle consent.
/// This interface is implemented by different analytics providers, such as Matomo, Firebase Analytics, Google and others.
abstract interface class AnalyticsTracker {
  /// Name of the analytics tracker.
  abstract final String name;

  /// Sets the user ID for tracking.
  Future<void> setUserID(String? userID);

  /// Sets a user property to a given value.
  Future<void> setUserProperty({required String name, required String? value});

  /// Logs the page_view event.
  Future<void> logPageView(String page, {Map<String, String>? parameters});

  /// Tracks an event with the given category, action, name, and value.
  Future<void> logEvent(String category, String event, {Map<String, String>? parameters});

  /// Sets the applicable end user consent state. By default, no consent mode values are set.
  Future<void> setConsent(bool consent);
}

/// @template analytics
/// Analytics is a singleton class that manages the analytics tracking for the application.
/// It initializes the appropriate analytics tracker based on the current environment.
/// @endtemplate
final class Analytics implements AnalyticsTracker {
  /// Private constructor for the singleton instance.
  /// {@macro analytics}
  Analytics._({required Iterable<AnalyticsTracker> trackers})
    : _trackers = List<AnalyticsTracker>.unmodifiable(trackers);

  /// The singleton instance of the Analytics class.
  /// @{macro analytics}
  static final Analytics instance = Analytics._(
    // Add the appropriate analytics trackers based on the environment.
    // Example: FirebaseAnalyticsTracker(), GoogleAnalyticsTracker(), etc.
    trackers: switch (Config.environment) {
      // Production environment use Firebase and AppMetrica for analytics.
      EnvironmentFlavor.production => <AnalyticsTracker>[
        // Use Firebase for production analytics.
        AnalyticsTracker$Firebase(),

        // Add AppMetica for production analytics.
        // if (AnalyticsTracker$AppMetrica.key.isNotEmpty) ...[AnalyticsTracker$AppMetrica()],
      ],

      // Development and Staging environment use Firebase and Logger for analytics.
      EnvironmentFlavor.development || EnvironmentFlavor.staging => <AnalyticsTracker>[
        // Simple logger for staging analytics.
        const AnalyticsTracker$Logger(),

        // Use Firebase for development analytics.
        if (kReleaseMode && Firebase.apps.isNotEmpty) AnalyticsTracker$Firebase(),
      ],

      // Fake environment uses only Logger for analytics.
      EnvironmentFlavor.fake => <AnalyticsTracker>[
        // Simple logger for fake analytics.
        const AnalyticsTracker$Logger(),
      ],
    },
  );

  @override
  String get name => 'Analytics';

  final List<AnalyticsTracker> _trackers;

  @override
  Future<void> logEvent(String category, String name, {Map<String, String>? parameters}) {
    if (category.isEmpty || name.isEmpty) {
      l.d('Category and action must not be empty for tracking events.');
      return Future<void>.value();
    }

    Future<void> fn(AnalyticsTracker tracker) async {
      try {
        await tracker.logEvent(category, name, parameters: parameters);
      } on Object catch (e, s) {
        l.w('Error tracking event in ${tracker.name}: $e', s);
      }
    }

    return Future.wait<void>([for (final tracker in _trackers) fn(tracker)]);
  }

  @override
  Future<void> logPageView(String page, {Map<String, String>? parameters}) {
    if (page.isEmpty) {
      l.d('Page must not be empty for tracking page views.');
      return Future<void>.value();
    }

    Future<void> fn(AnalyticsTracker tracker) async {
      try {
        await tracker.logPageView(page, parameters: parameters);
      } on Object catch (e, s) {
        l.w('Error tracking page view in ${tracker.name}: $e', s);
      }
    }

    return Future.wait<void>([for (final tracker in _trackers) fn(tracker)]);
  }

  @override
  Future<void> setUserID(String? userID) {
    Future<void> fn(AnalyticsTracker tracker) async {
      try {
        await tracker.setUserID(userID);
      } on Object catch (e, s) {
        l.w('Error setting user ID in ${tracker.name}: $e', s);
      }
    }

    return Future.wait<void>([for (final tracker in _trackers) fn(tracker)]);
  }

  @override
  Future<void> setUserProperty({required String name, required String? value}) {
    Future<void> fn(AnalyticsTracker tracker) async {
      try {
        await tracker.setUserProperty(name: name, value: value);
      } on Object catch (e, s) {
        l.w('Error setting user property in ${tracker.name}: $e', s);
      }
    }

    return Future.wait<void>([for (final tracker in _trackers) fn(tracker)]);
  }

  @override
  Future<void> setConsent(bool consent) {
    Future<void> fn(AnalyticsTracker tracker) async {
      try {
        await tracker.setConsent(consent);
      } on Object catch (e, s) {
        l.w('Error setting consent in ${tracker.name}: $e', s);
      }
    }

    return Future.wait<void>([for (final tracker in _trackers) fn(tracker)]);
  }
}

class AnalyticsTracker$Logger implements AnalyticsTracker {
  const AnalyticsTracker$Logger();

  @override
  String get name => 'Logger';

  @override
  Future<void> logEvent(String category, String name, {Map<String, String>? parameters}) async {
    l.d('Analytics | Event $category - $name', parameters);
  }

  @override
  Future<void> logPageView(String page, {Map<String, String>? parameters}) async {
    l.d('Analytics | PageView $page', parameters);
  }

  @override
  Future<void> setConsent(bool consent) async {
    l.d('Analytics | Consent $consent');
  }

  @override
  Future<void> setUserID(String? userID) async {
    l.d('Analytics | User $userID');
  }

  @override
  Future<void> setUserProperty({required String name, required String? value}) async {
    l.d('Analytics | Property $name: $value');
  }
}

/// AppMetrica analytics tracker implementation.
/* class AnalyticsTracker$AppMetrica implements AnalyticsTracker {
  AnalyticsTracker$AppMetrica() {
    _initialized.ignore();
  }

  /// Returns the AppMetrica key from the configuration.
  static const String key = Config.appMetricaKey;

  /// Initialize the AppMetrica tracker with the given key.
  final Future<bool> _initialized = () async {
    try {
      await AppMetrica.activate(const AppMetricaConfig(key));
      l.d('AppMetrica initialized');
      return true;
    } on Object catch (e, s) {
      l.w('Error initializing AppMetrica: $e', s);
      return false;
    }
  }();

  @override
  String get name => 'AppMetrica';

  @override
  Future<void> logEvent(String category, String name, {Map<String, String>? parameters}) async =>
      AppMetrica.reportEventWithMap(name, parameters);

  @override
  Future<void> logPageView(String page, {Map<String, String>? parameters}) async =>
      AppMetrica.reportEventWithMap('page_view', {'page': page});

  @override
  Future<void> setConsent(bool consent) async => AppMetrica.reportEvent(consent ? 'consented' : 'not_consented');

  @override
  Future<void> setUserID(String? userID) async => AppMetrica.setUserProfileID(userID);

  @override
  Future<void> setUserProperty({required String name, required String? value}) async =>
      AppMetrica.reportUserProfile(AppMetricaUserProfile([AppMetricaStringAttribute.withValue(name, value)]));
} */

/// Firebase analytics tracker implementation.
class AnalyticsTracker$Firebase implements AnalyticsTracker {
  AnalyticsTracker$Firebase() {
    _initialized.ignore();
  }

  /// Returns the AppMetrica key from the configuration.
  static const String key = Config.appMetricaKey;

  /// Initialize the AppMetrica tracker with the given key.
  final Future<bool> _initialized = () async {
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      l.d('Firebase Analytics initialized');
      return true;
    } on Object catch (e, s) {
      l.w('Error initializing Firebase Analytics: $e', s);
      return false;
    }
  }();

  @override
  String get name => 'AppMetrica';

  @override
  Future<void> logEvent(String category, String name, {Map<String, String>? parameters}) async =>
      FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);

  @override
  Future<void> logPageView(String page, {Map<String, String>? parameters}) async =>
      FirebaseAnalytics.instance.logScreenView(screenClass: 'page_view', screenName: page, parameters: parameters);

  @override
  Future<void> setConsent(bool consent) async => FirebaseAnalytics.instance.setConsent(
    adPersonalizationSignalsConsentGranted: consent,
    adStorageConsentGranted: consent,
    adUserDataConsentGranted: consent,
    analyticsStorageConsentGranted: consent,
    functionalityStorageConsentGranted: consent,
    personalizationStorageConsentGranted: consent,
    securityStorageConsentGranted: consent,
  );

  @override
  Future<void> setUserID(String? userID) async => FirebaseAnalytics.instance.setUserId(id: userID);

  @override
  Future<void> setUserProperty({required String name, required String? value}) async =>
      FirebaseAnalytics.instance.setUserProperty(name: name, value: value);
}

/// Fake AnalyticsTracker
@visibleForTesting
final class FakeAnalytics implements Analytics {
  @override
  String get name => 'FakeAnalytics';

  @override
  List<AnalyticsTracker> get _trackers => <AnalyticsTracker>[];

  @override
  Future<void> setUserID(String? userID) async {}

  @override
  Future<void> setUserProperty({required String name, required String? value}) async {}

  @override
  Future<void> logPageView(String page, {Map<String, String>? parameters}) async {}

  @override
  Future<void> logEvent(String category, String event, {Map<String, String>? parameters}) async {}

  @override
  Future<void> setConsent(bool consent) async {}
}
