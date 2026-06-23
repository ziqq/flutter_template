import 'dart:async';
import 'dart:developer' as dev show log;
import 'dart:io' show OSError, SocketException;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_template_name/src/app.dart';
import 'package:flutter_template_name/src/common/api_client/api_exception.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/constant/generated/pubspec.yaml.g.dart';
import 'package:flutter_template_name/src/common/util/analytics.dart';
import 'package:flutter_template_name/src/common/util/connectivity/connectivity_scope.dart';
import 'package:flutter_template_name/src/common/util/error_util.dart';
import 'package:flutter_template_name/src/feature/initialization/data/initialize_dependencies.dart';
import 'package:flutter_template_name/src/feature/initialization/data/platform/platform_initialization_vm.dart'
    as platform_initialization;
import 'package:flutter_template_name/src/feature/settings/widget/settings_scope.dart';
import 'package:l/l.dart';
import 'package:sentry_flutter/sentry_flutter.dart' as sentry_flutter;
import 'package:ui/ui.dart' as material;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(/* options: Config.firebaseOptions */);

  // TODO(ziqq): Before uncommenting this code, check duplicate notifications issue in Android.
  // Anton Ustinoff <a.a.ustinoff@gmail.com>, 17 November 2025
  // LocalNotificationsManager.instance.showNotification(message);

  if (message.contentAvailable) {
    // dev.log('Handling silent notification');
    // Access data from the data payload
    // String textA = message.data['textA'];
    // String textB = message.data['textB'];
    // Uses HomeWidget package to store in user defaults
    // updateWidget(textA, texB);
  } else {
    // Regular Push Notification
    // dev.log('Handling regular push notification');
  }

  // Update the app badge count
  /* if (message.data.containsKey('notificationCount')) {
    final notificationCount = message.data['notificationCount'];
    if (notificationCount case String count) {
      FlutterBadgeManager.instance.update(int.parse(count)).ignore();
    }
  } */
}

/// Initializes the app and prepares it for use.
Future<void> $initializeApp({
  void Function(int progress, String message)? onProgress,
  void Function(/* Dependencies dependencies */)? onSuccess,
  void Function(Object error, StackTrace stackTrace)? onError,
}) async {
  final binding = sentry_flutter.SentryWidgetsFlutterBinding.ensureInitialized()..deferFirstFrame();
  /* final binding = WidgetsFlutterBinding.ensureInitialized()..deferFirstFrame(); */
  /* SemanticsBinding.instance.ensureSemantics(); */
  try {
    // Handle errors that occured in the app
    // and send them as breadcrumbs to Sentry.
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      l.e('Top level error: $error', stackTrace);
      return true;
    };

    // binding.allowFirstFrame();
    // material.runApp(const SplashScreen());

    final dependencies = await $initializeDependencies(onProgress: onProgress);

    Future<void> appRunner() async {
      // Allow the first frame to be displayed after the app is initialized.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        binding.allowFirstFrame();
        platform_initialization.$removeLoadingWidget();
        l.i('App initialized successfully');
        onSuccess?.call();
        Analytics.instance
            .logEvent(
              'app',
              'open',
              parameters: <String, String>{
                'app_name': dependencies.metadata.appName,
                'environment': Config.environment.name,
                'app_version': dependencies.metadata.appVersion,
                'app_build_timestamp': dependencies.metadata.appBuildTimestamp.toUtc().toIso8601String(),
                'app_launch_timestamp': dependencies.metadata.appLaunchedTimestamp.toUtc().toIso8601String(),
                'device_screen_size': dependencies.metadata.deviceScreenSize,
                // 'device_with_gms': dependencies.metadata.deviceWithGMS ? 'true' : 'false',
                // 'device_with_hms': dependencies.metadata.deviceWithHMS ? 'true' : 'false',
                'is_web': kIsWeb ? 'true' : 'false',
                'is_wasm': kIsWasm ? 'true' : 'false',
                'locale': dependencies.metadata.locale,
                'operating_system': dependencies.metadata.operatingSystem,
                'processors_count': dependencies.metadata.processorsCount.toString(),
              },
            )
            .ignore();
      });
      const child = ConnectivityScope(child: SettingsScope(child: App()));
      material.runApp(
        Config.sentryDSN.isEmpty
            ? dependencies.inject(child: child)
            : sentry_flutter.SentryWidget(child: dependencies.inject(child: child)),
      );
    }

    // Start the app whitout Sentry if the app in development mode.
    final useDebug = (Config.environment.isDevelopment || Config.environment.isFake) && kDebugMode;
    if (Config.sentryDSN.isEmpty || useDebug) {
      await appRunner();
      return;
    }

    // Dio types who are considered as network noise (for filtering in Sentry).
    /* bool isDioNetworkNoise(DioException e) => switch (e.type) {
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.connectionError => true,
      DioExceptionType.badResponse || DioExceptionType.cancel => false,
      DioExceptionType.unknown => e.error is SocketException || e.error is HttpException || e.error is OSError,
      _ => false,
    }; */

    bool isNetworkNoise(Object? error) => switch (error) {
      ApiException$Network _ || ApiException$Offline _ => true,
      // DioException _ => isDioNetworkNoise(error),
      OSError _ => error.errorCode == 7, // errno = 7 => "No address associated with hostname"
      SocketException _ => true,
      _ => false,
    };

    bool isNetworkNoiseByEvent(sentry_flutter.SentryEvent event) {
      final exceptions = event.exceptions;
      if (exceptions == null || exceptions.isEmpty) return false;
      for (final e in exceptions) {
        final type = (e.type ?? '').trim();
        final value = (e.value ?? '').trim();
        if (type.contains('DioException') &&
            (value.contains('connection timeout') ||
                value.contains('connection error') ||
                value.contains('Failed host lookup') ||
                value.contains('No address associated with hostname') ||
                value.contains('Connection reset by peer') ||
                value.contains('Software caused connection abort'))) {
          return true;
        }

        if (type == 'OSError' &&
            (value.contains('No address associated with hostname') || value.contains('errno = 7'))) {
          return true;
        }

        if (type.startsWith(r'ApiException$Network')) return true;
      }
      return false;
    }

    await sentry_flutter.SentryFlutter.init((options) {
      options
        ..dsn = Config.sentryDSN
        ..release = Pubspec.version.canonical
        ..environment = Config.environment.value
        ..sampleRate = switch (Config.environment) {
          EnvironmentFlavor.development => 1.0,
          EnvironmentFlavor.staging => 1.0,
          EnvironmentFlavor.fake => 1.0,
          EnvironmentFlavor.production => 0.1,
          /* EnvironmentFlavor.testing => 0.0, */
        }.clamp(0.0, 1.0)
        ..tracesSampleRate = switch (Config.environment) {
          EnvironmentFlavor.development => 1.0,
          EnvironmentFlavor.staging => 1.0,
          EnvironmentFlavor.fake => 1.0,
          EnvironmentFlavor.production => 0.1,
          /* EnvironmentFlavor.testing => 0.0, */
        }.clamp(0.0, 1.0)
        // ignore: experimental_member_use
        ..profilesSampleRate = switch (Config.environment) {
          EnvironmentFlavor.development => 1.0,
          EnvironmentFlavor.staging => 1.0,
          EnvironmentFlavor.fake => 1.0,
          EnvironmentFlavor.production => 0.1,
          /* EnvironmentFlavor.testing => 0.0, */
        }.clamp(0.0, 1.0)
        ..debug = false
        ..maxBreadcrumbs = 50
        ..attachScreenshot = true
        ..attachStacktrace = true
        ..enableDeduplication = true
        ..enableUserInteractionBreadcrumbs = !kIsWeb
        ..enableUserInteractionTracing = !kIsWeb
        /* ..ignoreErrors = <String>[
          'FlutterError',
          'SentryException',
          r'^minified:.+$',
          // Important: do not try to match Dio by text here — it's unreliable.

          // r'^DioException: DioException \[(connection timeout|receive timeout|send timeout|connection error)\]:.*$',
          // r'^OSError: No address associated with hostname.*$',
          // r'^SocketException: .*Failed host lookup.*$',
          // r'^ApiException\$Network.*$',
        ] */
        ..reportSilentFlutterErrors = false
        ..beforeSend = (event, hint) {
          final error = event.throwable;
          if (isNetworkNoise(error)) return null; // Если throwable доступен — фильтруем по типам.
          if (isNetworkNoiseByEvent(event)) return null; // Фолбэк: фильтруем по SentryException type/value.
          return event;
        }
        ..beforeCaptureScreenshot = (event, hint, debounce) {
          final error = event.throwable;
          if (debounce || hint.screenshot != null) return false;
          if (isNetworkNoise(error) || isNetworkNoiseByEvent(event)) return false;
          return switch (error) {
            FlutterError _ || AssertionError _ => true,
            ApiException _ => false,
            _ => false,
          };
        }
      /* ..addExceptionCauseExtractor(SentryApiClientExceptionCauseExtractor()) */
      /* ..addEventProcessor(SentryLogBreadcrumbsProcessor(buffer: LogBuffer.instance, limit: 25)) */
      /* ..addEventProcessor(SentryMetaProcessor(dependencies: dependencies)) */;
    }, appRunner: appRunner);
  } on Object catch (error, stackTrace) {
    onError?.call(error, stackTrace);
    binding.allowFirstFrame();
    material.runApp(App$Error(error: error, stackTrace: stackTrace));
  }
}

/// Resets the app's state to its initial state.
@visibleForTesting
Future<void> $resetApp() async {}

/// Disposes the app and releases all resources.
@visibleForTesting
Future<void> $disposeApp() async {}

/// Initialize [Firebase]
Future<void> $initializeFirebase(FirebaseOptions? firebaseOptions) async {
  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await Firebase.initializeApp(options: firebaseOptions);
  } on Object catch (error, stackTrace) {
    Future<void>.delayed(Duration.zero, () {
      dev.log(
        'main() => initializeApp() => \$initializeFirebase()\nCan not initialize Firebase: $error',
        level: 1200,
        error: error,
        name: '_initializeFirebase',
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      return ErrorUtil.logError(error, stackTrace);
    }).ignore();
    if (kDebugMode) rethrow;
  }
}
