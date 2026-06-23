import 'dart:async';

import 'package:control/control.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter_template_name/src/common/api_client/api_client.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/constant/generated/pubspec.yaml.g.dart';
import 'package:flutter_template_name/src/common/controller/controller_observer.dart';
import 'package:flutter_template_name/src/common/database/database.dart';
import 'package:flutter_template_name/src/common/model/app_metadata.dart';
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/common/router/app_navigator.dart' show AppNavigationState;
import 'package:flutter_template_name/src/common/router/app_pages.dart' show AppPage, HomePage;
import 'package:flutter_template_name/src/common/util/analytics.dart';
import 'package:flutter_template_name/src/common/util/connectivity/connectivity_service.dart';
import 'package:flutter_template_name/src/common/util/log_buffer.dart';
import 'package:flutter_template_name/src/common/util/middleware/authentication_middleware.dart';
import 'package:flutter_template_name/src/common/util/middleware/connectivity_middleware.dart';
import 'package:flutter_template_name/src/common/util/middleware/deduplication_middleware.dart';
import 'package:flutter_template_name/src/common/util/middleware/logger_middleware.dart';
import 'package:flutter_template_name/src/common/util/middleware/metadata_middleware.dart';
import 'package:flutter_template_name/src/common/util/middleware/retry_middleware.dart';
import 'package:flutter_template_name/src/common/util/middleware/sentry_middleware.dart';
import 'package:flutter_template_name/src/common/util/middleware/timeout_middleware.dart';
import 'package:flutter_template_name/src/feature/authentication/controller/authentication_controller.dart';
import 'package:flutter_template_name/src/feature/authentication/data/authentication_repository.dart';
import 'package:flutter_template_name/src/feature/initialization/data/app_migrator.dart';
import 'package:flutter_template_name/src/feature/initialization/data/platform/platform_initialization.dart'
    as platform_initialization;
import 'package:flutter_template_name/src/feature/settings/controller/settings_controller.dart';
import 'package:flutter_template_name/src/feature/settings/data/providers/app_settings_data_provider.dart';
import 'package:flutter_template_name/src/feature/settings/data/providers/user_preferences_data_provider.dart';
import 'package:flutter_template_name/src/feature/settings/data/settings_repository.dart';
import 'package:l/l.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Initializes the app and returns a [Dependencies] object
Future<Dependencies> $initializeDependencies({void Function(int progress, String message)? onProgress}) async {
  final dependencies = Dependencies();
  final totalSteps = _initializationSteps.length;
  var currentStep = 0;
  for (final step in _initializationSteps.entries) {
    try {
      currentStep++;
      final percent = (currentStep * 100 ~/ totalSteps).clamp(0, 100);
      onProgress?.call(percent, step.key);
      // Last 10% (90% -> 100%) of the proggress is reserved for this inizialization.
      platform_initialization.$updateLoadingProgress(
        progress: (90 + percent * .1).clamp(90, 100).round(),
        message: step.key,
      );
      l.i(
        'Initialization '
        '| ${currentStep.toString().padLeft(2, '0')}/${totalSteps.toString().padLeft(2, '0')} '
        '($percent%) '
        '| "${step.key}"',
      );
      await step.value(dependencies);
    } on Object catch (error, stackTrace) {
      l.e('Initialization failed at step "${step.key}": $error', stackTrace);
      Error.throwWithStackTrace('Initialization failed at step "${step.key}": $error', stackTrace);
    }
  }
  return dependencies;
}

final _initializationSteps = <String, Future<void> Function(Dependencies)>{
  'Platform pre-initialization': (_) => platform_initialization.$platformInitialization(),

  // Metadata of the app
  // This is where you can set up name of the app, version, build number
  'Creating app metadata': (d) async => d.metadata = await AppMetadata.platform(),

  // Shared preferences and secure storage initialization
  'Storages initialization': (d) async {
    // final prefix = Config.environment.toString();
    // final accountName = '${AppleOptions.defaultAccountName}${prefix == null ? '' : '_$prefix'}}';
    d.sharedPreferences = SharedPreferencesAsync();
    /* ..storage = FlutterSecureStorage(
         aOptions: AndroidOptions(preferencesKeyPrefix: prefix),
         iOptions: IOSOptions(accountName: accountName, accessibility: KeychainAccessibility.first_unlock),
       );
    */
  },

  // Observe all controllers in the app
  'Observer state managment': (_) async => Controller.observer = const ControllerObserver(),

  // Firebase initialization
  /* 'Firebase initialization': (_) async {
    final _ = await initialization.$initializeFirebase(Config.firebaseOptions);
    // await platform_initialization.$firebaseAppCheckInitialization();
  }, */

  // Initialize database
  'Connect to database': (d) async {
    d.database = Config.inMemoryDatabase ? Database.memory() : Database.lazy();
    await d.database.refresh();
    d.database
      ..setKey('app_version', Pubspec.version.canonical)
      ..setKey('app_last_launch', DateTime.now().millisecondsSinceEpoch);
  },

  // Shrink database
  'Shrink database': (d) async {
    try {
      await d.database.customStatement('VACUUM;');
      await d.database.transaction(() async {
        final log =
            await (d.database.select<LogTbl, LogTblData>(d.database.logTbl)
                  ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)])
                  ..limit(1, offset: 1000))
                .getSingleOrNull();
        if (log != null) {
          await (d.database.delete(d.database.logTbl)..where((t) => t.time.isSmallerOrEqualValue(log.time))).go();
        }
      });

      // Shrink database sometimes
      if (DateTime.now().second % 10 == 0) await d.database.customStatement('VACUUM;');
    } on Object catch (e, s) {
      l.e('Error shrink database: $e', s);
    }
  },

  // Migrate app from previous version, for example drop old database and create a new one.
  'Migrate app from previous version': (d) async => AppMigrator.migrate(d),

  //? If u want to uncomit this line, u will should test it on Android devices.
  // 'Get remote config': (_) => RemoteConfigService.instance.initialize().timeout(const Duration(seconds: 30)),

  // Analytics initialization (Use fake analytics in development mode).
  // This is where you can set up analytics for the app.
  'Analytics initialization': (d) async => d.analytics = Analytics.instance,

  // Connectivity service initialization.
  // This is where you can set up connectivity service for the app.
  'Connectivity initialization': (d) async => d.connectivityService = ConnectivityService.instance..start(),

  // Prepare settings controller
  // This is where you can set up settings controller for the app.
  // Settings controller is used to manage app settings and user preferences.
  'Prepare settings controller': (d) async {
    d.settingsController = SettingsController(
      repository: SettingsRepository(
        appSettingsDataProvider: AppSettingsDataProvider(sharedPreferences: d.sharedPreferences),
        userPreferencesDataProvider: UserPreferencesDataProvider(sharedPreferences: d.sharedPreferences),
      ),
    );
    try {
      await d.settingsController.restore();
    } on Object catch (e, st) {
      l.w('Error restore settings state: $e', st);
      Error.throwWithStackTrace(e, st);
    }
  },

  // Initialize API client
  // This is where you can set up API client for the app.
  'HTTP Client factory': (d) async {
    // Resolve API base URL (with optional override from local storage).
    var apiBaseUrlString = Config.apiBaseUrl;

    // Allow to set API URL from local storage
    // This is useful for testing purposes at stage, when you want to change the API URL.
    if (Config.environment.isDevelopment && const bool.fromEnvironment('URL_FROM_LOCAL_STORAGE', defaultValue: true)) {
      apiBaseUrlString = (await d.sharedPreferences.getString('api_base_url')) ?? apiBaseUrlString;
      if (!apiBaseUrlString.startsWith('https://') && !apiBaseUrlString.startsWith('http://')) {
        apiBaseUrlString = Config.apiBaseUrl;
      }
      d.sharedPreferences.setString('api_base_url', apiBaseUrlString).ignore();
    }

    if (Config.apiBaseUrl != apiBaseUrlString) {
      l.w('API URL changed from ${Config.apiBaseUrl} to $apiBaseUrlString');
    } else {
      l.i('API URL: $apiBaseUrlString');
    }

    /// HTTP Client factory
    ApiClient$HTTP httpFactory([Iterable<ApiClientMiddleware>? middlewares]) {
      final list = <ApiClientMiddleware>[
        /// Middleware for handling connectivity state and blocking requests when offline.
        ConnectivityMiddleware(controller: d.connectivityService.controller).call,

        /// Middleware for handling deduplication requests.
        DeduplicationMiddleware().call,

        // TODO(ziqq): Add cache middleware
        // Anton Ustinoff <a.a.ustinoff@gmail.com>, 31 July 2025

        // Metadata middleware to add common headers and metadata to each request.
        MetadataMiddleware(metadata: d.metadata).call,

        // Retry middleware to retry failed requests.
        RetryMiddleware(defaultRetryEvaluator: defaultRetryEvaluator$HTTP).call,

        // Logger middleware to log requests and responses.
        const LoggerMiddleware().call,

        // Sentry middleware to capture errors and performance data.
        const SentryMiddleware().call,

        // Timeout middleware
        // Set the timeout duration for requests
        const TimeoutMiddleware(duration: Duration(seconds: 30)).call,

        ...?middlewares,
      ];
      return ApiClient$HTTP(baseURL: apiBaseUrlString, /* maxRedirects: 5, */ middlewares: list);
    }

    /// Assign http factory
    d.httpFactory = httpFactory;
  },

  // General HTTP client initialization
  'General HTTP Client': (d) async {
    Future<String?> getToken() async {
      try {
        return Future<String?>.value(d.authenticationController.state.user.token);
      } on Object catch (e, s) {
        l.w('Error getting token: $e', s);
        return null;
      }
    }

    Future<void> onUpdateToken(String newToken) async {
      try {
        // final userID = await d.tokenStorage.parseTokenPairToUserID(newToken);
        // await d.authenticationController.updateToken(newToken);
        /* await d.accountStorage.updateTokenInAccount(
          accessToken: newToken.accessToken,
          refreshToken: newToken.refreshToken,
          userID: userID,
        ); */
      } on Object catch (e, s) {
        l.w('Error saving token: $e', s);
      }
    }

    Future<void> onTokenExpired() async {
      l.w('Received "Not authenticated" HTTP response, logging out...');
      await d.authenticationController.signOut(useLogoutDialog: true);
    }

    d.client = d.httpFactory([
      // You can add additional middlewares here if needed
      AuthenticationMiddleware(
        baseURL: (await d.sharedPreferences.getString('api_base_url')) ?? Config.apiBaseUrl,
        getToken: getToken,
        onUpdateToken: onUpdateToken,
        onTokenExpired: onTokenExpired,
      ).call,
    ]);
  },

  // Prepare authentication controller
  // This is where you can set up authentication controller for the app.
  'Prepare authentication controller': (d) async {
    d
      ..authenticationRepository = AuthenticationRepository(sharedPreferences: d.sharedPreferences)
      ..authenticationController = AuthenticationController(repository: d.authenticationRepository);
    try {
      await d.authenticationController.restore();
    } on Object catch (e, st) {
      l.w('Error restore authentication state: $e', st);
      Error.throwWithStackTrace(e, st);
    }
  },

  // Prepare repositories
  // This is where you can set up repositories for the app.
  'Prepare repositories': (d) async {},

  // Prepare navigation
  // This is where you can set up navigation for the app.
  'Prepare navigation': (d) async => d.navigator = ValueNotifier<AppNavigationState>(const <AppPage>[HomePage()]),

  // Load spritesheet data
  // This is where you can set up spritesheet data for the app.
  /* 'Load spritesheet data': (_) async => await Atlas.initialize(), */

  // Initialize log buffer
  // This is where you can set up log buffer for the app.
  'Collect logs': (d) async {
    await (d.database.select<LogTbl, LogTblData>(d.database.logTbl)
          ..orderBy([(t) => OrderingTerm(expression: t.time, mode: OrderingMode.desc)])
          ..limit(LogBuffer.bufferLimit))
        .get()
        .then<List<LogMessage>>(
          (logs) => logs
              .map(
                (l) => l.stack != null
                    ? LogMessageError(
                        timestamp: DateTime.fromMillisecondsSinceEpoch(l.time * 1000),
                        level: LogLevel.fromValue(l.level),
                        message: l.message,
                        stackTrace: StackTrace.fromString(l.stack!),
                      )
                    : LogMessageVerbose(
                        timestamp: DateTime.fromMillisecondsSinceEpoch(l.time * 1000),
                        level: LogLevel.fromValue(l.level),
                        message: l.message,
                      ),
              )
              .toList(growable: false),
        )
        .then<void>(LogBuffer.instance.addAll);
    l
        .bufferTime(const Duration(seconds: 1))
        .where((logs) => logs.isNotEmpty)
        .listen(LogBuffer.instance.addAll, cancelOnError: false);
    l
        .map<LogTblCompanion>(
          (log) => LogTblCompanion.insert(
            level: log.level.level,
            message: log.message.toString(),
            time: Value<int>(log.timestamp.millisecondsSinceEpoch ~/ 1000),
            stack: Value<String?>(switch (log) {
              LogMessageError l => l.stackTrace.toString(),
              _ => null,
            }),
          ),
        )
        .bufferTime(const Duration(seconds: 5))
        .where((logs) => logs.isNotEmpty)
        .listen(
          (logs) => d.database.batch((batch) => batch.insertAll(d.database.logTbl, logs)).ignore(),
          cancelOnError: false,
        );
  },

  // Finalize initialization
  'Log app initialized': (_) async {},
};
