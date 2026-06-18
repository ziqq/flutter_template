import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter_template_name/src/common/api_client/api_client.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/common/router/app_navigator.dart' show AppNavigationState, AppPage, HomePage;
import 'package:flutter_template_name/src/common/util/analytics.dart';
import 'package:flutter_template_name/src/feature/authentication/controller/authentication_controller.dart';
import 'package:flutter_template_name/src/feature/authentication/model/user.dart';
import 'package:flutter_template_name/src/feature/settings/controller/settings_controller.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../test/src/util/mocks/mock_service.dart';
import '../../test/src/util/test_util.mocks.dart';
import 'fake_shared_preferences.dart';

/// Initialize fake dependencies
@visibleForTesting
FakeDependencies $initializeFakeDependencies({
  Duration fakeDelay = const Duration(milliseconds: int.fromEnvironment('FAKE_DELAY', defaultValue: 500)),
  User? user,
}) {
  SharedPreferences.setMockInitialValues(<String, String>{});

  final store = FakeSharedPreferencesAsync();
  SharedPreferencesAsyncPlatform.instance = store;
  final sharedPreferences = SharedPreferencesAsync();

  final authenticationRepository = MockAuthenticationRepository();
  final dependencies = FakeDependencies()
    ..analytics = FakeAnalytics()
    ..navigator = ValueNotifier<AppNavigationState>(const <AppPage>[HomePage()])
    ..metadata = MockService.appMetadata
    ..sharedPreferences = sharedPreferences
    ..client = ApiClient$HTTP(baseURL: Config.baseUrl)
    ..database = MockDatabase()
    ..authenticationRepository = authenticationRepository
    ..authenticationController = AuthenticationController(
      repository: authenticationRepository,
      initialState: AuthenticationState.idle(user: user ?? MockService.user.authenticated),
    )
    ..settingsController = SettingsController(repository: MockSettingsRepository());

  return dependencies;
}
