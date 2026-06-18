import 'package:flutter/widgets.dart';
import 'package:flutter_template_name/src/common/api_client/api_client.dart';
import 'package:flutter_template_name/src/common/database/database.dart';
import 'package:flutter_template_name/src/common/model/app_metadata.dart';
import 'package:flutter_template_name/src/common/router/app_navigator.dart';
import 'package:flutter_template_name/src/common/util/analytics.dart';
import 'package:flutter_template_name/src/common/util/connectivity/connectivity_service.dart';
import 'package:flutter_template_name/src/feature/authentication/controller/authentication_controller.dart';
import 'package:flutter_template_name/src/feature/authentication/data/authentication_repository.dart';
import 'package:flutter_template_name/src/feature/settings/controller/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dependencies
class Dependencies {
  Dependencies();

  /// The state from the closest instance of this class.
  factory Dependencies.of(BuildContext context) => InheritedDependencies.of(context);

  /// Injest dependencies to the widget tree.
  Widget inject({required Widget child, Key? key}) => InheritedDependencies(dependencies: this, key: key, child: child);

  /// App navigator state
  late final ValueNotifier<AppNavigationState> navigator;

  /// App metadata
  late final AppMetadata metadata;

  /// App analytics
  late final Analytics analytics;

  /// Connectivity service
  late final IConnectivityService connectivityService;

  /// Shared preferences
  late final SharedPreferencesAsync sharedPreferences;

  /// Flutter secure storage
  // late final FlutterSecureStorage storage;

  /// Database
  late final Database database;

  /// API Client wrapper
  late final ApiClient$HTTP client;

  /// HTTP Client factory
  late final ApiClient$HTTP Function([Iterable<ApiClientMiddleware>? middlewares]) httpFactory;

  /// Authentication repository
  late final IAuthenticationRepository authenticationRepository;

  /// Authentication controller
  late final AuthenticationController authenticationController;

  /// Settings controller
  late final SettingsController settingsController;
}

/// Fake Dependencies
class FakeDependencies implements Dependencies {
  FakeDependencies();

  /// The state from the closest instance of this class.
  static Dependencies of(BuildContext context) => Dependencies.of(context);

  /// Injest dependencies to the widget tree.
  @override
  Widget inject({required Widget child, Key? key}) => InheritedDependencies(dependencies: this, key: key, child: child);

  /// App navigator state
  @override
  late final ValueNotifier<AppNavigationState> navigator;

  /// App metadata
  @override
  late final AppMetadata metadata;

  /// App analytics
  @override
  late final Analytics analytics;

  /// Connectivity service
  @override
  late final IConnectivityService connectivityService;

  /// Shared preferences
  @override
  late final SharedPreferencesAsync sharedPreferences;

  /// Flutter secure storage
  // @override
  // late final FlutterSecureStorage storage;

  /// Database
  @override
  late final Database database;

  /// HTTP Client factory
  @override
  late final ApiClient$HTTP Function([Iterable<ApiClientMiddleware>? middlewares]) httpFactory;

  /// HTTP Client
  @override
  late final ApiClient$HTTP client;

  /// Authentication repository
  @override
  late final IAuthenticationRepository authenticationRepository;

  /// Authentication controller
  @override
  late final AuthenticationController authenticationController;

  /// Settings controller
  @override
  late final SettingsController settingsController;
}

/// {@template inherited_dependencies}
/// InheritedDependencies widget.
/// {@endtemplate}
class InheritedDependencies extends InheritedWidget {
  /// {@macro inherited_dependencies}
  const InheritedDependencies({required this.dependencies, required super.child, super.key});

  final Dependencies dependencies;

  /// The state from the closest instance of this class
  /// that encloses the given context, if any.
  /// e.g. `InheritedDependencies.maybeOf(context)`.
  static Dependencies? maybeOf(BuildContext context) =>
      (context.getElementForInheritedWidgetOfExactType<InheritedDependencies>()?.widget as InheritedDependencies?)
          ?.dependencies;

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
    'Out of scope, not found inherited widget '
        'a InheritedDependencies of the exact type',
    'out_of_scope',
  );

  /// The state from the closest instance of this class
  /// that encloses the given context.
  /// e.g. `InheritedDependencies.of(context)`
  static Dependencies of(BuildContext context) => maybeOf(context) ?? _notFoundInheritedWidgetOfExactType();

  @override
  bool updateShouldNotify(InheritedDependencies oldWidget) => false;
}
