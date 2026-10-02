import 'src/widget_test/src/feature/developer/developer_test.dart' as developer_test;

import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/app.dart';
import 'package:flutter_template_name/src/common/localization/localization.dart';
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/common/router/router.dart';
import 'package:flutter_template_name/src/common/util/analytics.dart';
import 'package:flutter_template_name/src/common/util/connectivity/connectivity_scope.dart';
import 'package:flutter_template_name/src/common/util/connectivity/connectivity_service.dart';
import 'package:flutter_template_name/src/feature/authentication/controller/authentication_controller.dart';
import 'package:flutter_template_name/src/feature/authentication/data/authentication_repository.dart';
import 'package:flutter_template_name/src/feature/settings/controller/settings_controller.dart';
import 'package:flutter_template_name/src/feature/settings/widget/settings_scope.dart';
import 'package:flutter_test/flutter_test.dart';

import 'src/util/test_util.dart';
import 'src/widget_test/src/common/_all.dart' as common_test;

void main() => group('Widget', () {
  developer_test.main();
  setUpAll(() async {
    MockService.initialize();
    for (final locale in Localization.supportedLocales) {
      await Localization.delegate.load(locale);
    }
  });

  testWidgets('Dependencies_are_injected', (tester) async {
    await tester.pumpWidget(FakeDependencies().inject(child: Container()));
    expect(find.byType(Container), findsOneWidget);
    expect(find.byType(InheritedDependencies), findsOneWidget);
    final context = tester.element(find.byType(Container));
    expect(Dependencies.of(context), allOf(isNotNull, isA<Dependencies>(), isA<FakeDependencies>()));
  });

  testWidgets('App', (tester) async {
    final dependencies = FakeDependencies()
      ..authenticationController = AuthenticationController(repository: AuthenticationRepository$Fake())
      ..settingsController = SettingsController(repository: MockSettingsRepository())
      ..navigator = ValueNotifier<AppNavigationState>(const [
        AppPage$Fade(name: 'test', key: ValueKey('test'), child: SizedBox.shrink()),
      ])
      ..database = MockDatabase()
      ..metadata = MockService.appMetadata
      ..analytics = Analytics.instance
      ..connectivityService = _ConnectivityService();
    addTearDown(dependencies.navigator.dispose);
    await tester.pumpWidget(
      dependencies.inject(
        child: const ConnectivityScope(child: SettingsScope(child: App())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(InheritedDependencies), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  common_test.main();
});

class _ConnectivityService implements IConnectivityService {
  @override
  final ValueNotifier<ConnectivityStatus> controller = ValueNotifier(ConnectivityStatus.online);
  @override
  Future<ConnectivityStatus> check() async => controller.value;
  @override
  Future<ConnectivityStatus> refresh({String reason = 'manual', bool force = false}) => check();
  @override
  void start() {}
  @override
  void dispose() => controller.dispose();
}
