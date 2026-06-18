import 'dart:io' as io;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_template_name/src/common/constant/pubspec.yaml.g.dart';
import 'package:flutter_template_name/src/feature/authentication/model/user.dart';

/*
 * FirebaseAnalyticsObserver(analytics: analytics);
 */
RouteObserver<ModalRoute<Object?>> $getAnalyticsObserver(FirebaseAnalytics analytics) =>
    FirebaseAnalyticsObserver(analytics: analytics);

/*
 * AppMetrica.reportUserProfile(User user)
 *
 * FirebaseAnalytics.instance.setUserId(id: userID);
 * FirebaseAnalytics.instance.setUserProperty(name: 'user_name');
 * FirebaseAnalytics.instance.setUserProperty(name: 'user_role';
 * FirebaseAnalytics.instance.setUserProperty(name: 'user_phone');
 * FirebaseAnalytics.instance.setUserProperty(name: 'app_version');
 * FirebaseAnalytics.instance.setUserProperty(name: 'operating_system');
 * FirebaseAnalytics.instance.setUserProperty(name: 'notifications');
 * FirebaseAnalytics.instance.setUserProperty(name: 'notifications_manual');
 */
Future<void> $setUserProperties(
  User user, {
  bool initialization = false,
  Map<String, Object?>? context,
  Map<String, String>? tags,
}) async {
  await Future.wait([
    // if (Config.environment.isProduction) _setUserProperties$AppMetrica(user),
    // if (!initialization) _setUserProperties$Sentry(user),
    _setUserProperties$FirebaseAnalytics(user),
  ]);
}

/*
 * FirebaseAnalytics.instance.setUserId(id: userID);
 * FirebaseAnalytics.instance.setUserProperty(name: 'user_name');
 * FirebaseAnalytics.instance.setUserProperty(name: 'user_role';
 * FirebaseAnalytics.instance.setUserProperty(name: 'user_phone');
 * FirebaseAnalytics.instance.setUserProperty(name: 'app_version');
 * FirebaseAnalytics.instance.setUserProperty(name: 'operating_system');
 * FirebaseAnalytics.instance.setUserProperty(name: 'notifications');
 * FirebaseAnalytics.instance.setUserProperty(name: 'notifications_manual');
 */
Future<void> _setUserProperties$FirebaseAnalytics(User user) async {
  final analytics = FirebaseAnalytics.instance;
  await Future.wait([
    analytics.setUserId(id: user.id),
    // analytics.setUserProperty(name: 'user_name', value: user.name),
    // analytics.setUserProperty(name: 'user_role', value: user.role),
    // analytics.setUserProperty(name: 'user_phone', value: user.phone),
    analytics.setUserProperty(name: 'app_version', value: Pubspec.version.canonical),
    analytics.setUserProperty(name: 'operating_system', value: io.Platform.operatingSystem.toString()),
  ]);
}

/*
 * AppMetrica.reportUserProfile(userProfile);
 * AppMetrica.setUserProfileID(userID)
 */
/* Future<void> _setUserProperties$AppMetrica(User user) async {
  await AppMetrica.reportUserProfile(
    AppMetricaUserProfile([
      AppMetricaNameAttribute.withValue(user.name),
      AppMetricaStringAttribute.withValue('user_id', user.id),
      // AppMetricaStringAttribute.withValue('user_role', user.role),
      // AppMetricaStringAttribute.withValue('user_phone', user.phone),
      AppMetricaStringAttribute.withValue('app_version', Pubspec.version.canonical),
      AppMetricaStringAttribute.withValue('operating_system', io.Platform.operatingSystem.toString()),
    ]),
  );
  await AppMetrica.setUserProfileID(user.id);
} */

/*
 * Sentry.configureScope();
 */
/* Future<void> _setUserProperties$Sentry(User user, {Map<String, Object?>? context, Map<String, String>? tags}) async {
  await Sentry.configureScope((scope) async {
    await scope.setUser(SentryUser(id: user.userID.toString(), username: user.name, name: user.name));
    if (context != null) {
      for (final entry in context.entries) {
        await scope.setContexts(entry.key, entry.value);
      }
    }
    if (tags != null) {
      for (final entry in tags.entries) {
        await scope.setTag(entry.key, entry.value);
      }
    }
  });
} */

/*
 * AppMetrica.reportEventWithMap(eventName, parameters)
 *
 * FirebaseAnalytics.instance.logEvent(
 *    name: eventName,
 *    parameters: parameters,
 * );
 */
Future<void> $logEvent({required String eventName, Map<String, Object>? parameters}) async {
  // if (Config.environment.isProduction) await AppMetrica.reportEventWithMap(eventName, parameters);

  //? Skip for [FirebaseAnalytics] if `eventName` is invalid.
  if (eventName.isNotEmpty ||
      eventName.length > 24 ||
      eventName.indexOf(RegExp('[a-zA-Z]')) != 0 ||
      eventName.contains(RegExp('[^a-zA-Z0-9_]')))
    return;
  await FirebaseAnalytics.instance.logEvent(name: eventName, parameters: parameters);
}
