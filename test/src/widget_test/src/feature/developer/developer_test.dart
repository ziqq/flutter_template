import 'package:flutter_template_name/src/feature/authentication/model/user.dart';

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_template_name/src/common/localization/localization.dart';
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/common/router/app_pages.dart';
import 'package:flutter_template_name/src/common/router/router.dart';
import 'package:flutter_template_name/src/common/util/analytics.dart';
import 'package:flutter_template_name/src/common/util/log_buffer.dart';
import 'package:flutter_template_name/src/feature/authentication/controller/authentication_controller.dart';
import 'package:flutter_template_name/src/feature/authentication/data/authentication_repository.dart';
import 'package:flutter_template_name/src/feature/developer/developer_screens.dart';
import 'package:flutter_template_name/src/feature/developer/widget/developer_button.dart';
import 'package:flutter_template_name/src/feature/initialization/model/initialization_stats.dart';
import 'package:flutter_template_name/src/feature/settings/controller/settings_controller.dart';
import 'package:flutter_template_name/src/feature/settings/model/user_preferences.dart';
import 'package:flutter_template_name/src/feature/settings/widget/settings_scope.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l/l.dart';
import 'package:mockito/mockito.dart';
import 'package:ui/ui.dart';

import '../../../../util/test_util.dart';

void main() => group('Developer and settings -', () {
  for (final saveFails in [false, true]) {
    testWidgets(saveFails ? 'failed opt-out preserves consent' : 'opt-out persists and disables analytics', (
      tester,
    ) async {
      final repository = MockSettingsRepository();
      final tracker = _ConsentTracker();
      final analytics = Analytics.forTesting(trackers: [tracker]);
      await analytics.setConsent(true);
      tracker.consents.clear();
      final dependencies = _dependencies(repository, analytics);
      addTearDown(dependencies.authenticationController.dispose);
      when(repository.savePreferences(any)).thenAnswer((_) async {
        if (saveFails) throw StateError('save failed');
      });
      await tester.pumpWidget(
        WidgetTestUtil.createWidgetUnderTest(
          locale: const Locale('en'),
          dependencies: dependencies,
          builder: (_) => const DeveloperInfoScreen(),
        ),
      );
      await tester.pumpAndSettle();
      final tile = find.byKey(const ValueKey<String>('developer_analytics_data_sending'));
      await tester.scrollUntilVisible(tile, 250, scrollable: find.byType(Scrollable).first);
      final toggle = find.descendant(of: tile, matching: find.byType(UISwitch));
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(tester.widget<UISwitch>(toggle).value, saveFails);
      expect(tracker.consents, saveFails ? isEmpty : [false]);
      verify(repository.savePreferences(const UserPreferences(analyticsDataSendingEnabled: false))).called(1);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('state aspect sees processing while unchanged preference consumers do not rebuild', (tester) async {
    final repository = MockSettingsRepository();
    final dependencies = _dependencies(repository, FakeAnalytics());
    final pending = Completer<void>();
    when(repository.savePreferences(any)).thenAnswer((_) => pending.future);
    var preferenceBuilds = 0;
    await tester.pumpWidget(
      WidgetTestUtil.createWidgetUnderTest(
        dependencies: dependencies,
        builder: (_) => Column(
          children: [
            Builder(builder: (context) => Text(SettingsScope.stateOf(context).type)),
            Builder(
              builder: (context) {
                SettingsScope.userPreferencesOf(context);
                preferenceBuilds++;
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
    final initialBuilds = preferenceBuilds;
    final change = dependencies.settingsController.setUseDebug(true);
    await tester.pump();
    expect(find.text('processing'), findsOneWidget);
    expect(preferenceBuilds, initialBuilds);
    pending.complete();
    await change;
    await tester.pump();
    expect(find.text('idle'), findsOneWidget);
    expect(preferenceBuilds, initialBuilds + 1);
    dependencies.authenticationController.dispose();
  });

  testWidgets('developer button and logs use typed navigation', (tester) async {
    final dependencies = _dependencies(MockSettingsRepository(), FakeAnalytics());
    addTearDown(dependencies.authenticationController.dispose);
    await tester.pumpWidget(
      WidgetTestUtil.createWidgetUnderTest(
        locale: const Locale('en'),
        dependencies: dependencies,
        builder: (_) => AppNavigator(
          pages: const [
            AppPage(
              arguments: null,
              key: ValueKey('entry'),
              name: 'entry',
              child: Scaffold(body: DeveloperButton()),
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.byType(DeveloperButton));
    await tester.pumpAndSettle();
    expect(find.byType(DeveloperScreen), findsOneWidget);
    final context = tester.element(find.byType(DeveloperScreen));
    await tester.tap(find.text(Localization.of(context).developerShowLogsButton));
    await tester.pumpAndSettle();
    expect(find.byType(LogsScreen), findsOneWidget);
    expect(tester.state<AppNavigatorState>(find.byType(AppNavigator)).state.last, const DeveloperLogsScreenPage());
    expect(tester.takeException(), isNull);
  });

  for (final empty in [true, false]) {
    testWidgets(empty ? 'statistics show the empty state' : 'statistics render measured steps and total', (
      tester,
    ) async {
      final stats = empty
          ? const InitializationStats.empty()
          : InitializationStats(
              steps: const [
                InitializationStepTiming(index: 0, name: 'Storage', duration: Duration(milliseconds: 20)),
                InitializationStepTiming(index: 1, name: 'Settings', duration: Duration(milliseconds: 5)),
              ],
            );
      await tester.pumpWidget(
        WidgetTestUtil.createWidgetUnderTest(
          locale: const Locale('en'),
          builder: (_) => DeveloperInitializationStatsScreen(stats: stats),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(UIPieChart), empty ? findsNothing : findsOneWidget);
      if (!empty) expect(find.text('25 ms'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('log search uses the latest buffer snapshot', (tester) async {
    final dependencies = _dependencies(MockSettingsRepository(), FakeAnalytics());
    addTearDown(dependencies.authenticationController.dispose);
    final buffer = LogBuffer.instance..clear();
    addTearDown(buffer.clear);
    buffer.addAll([
      LogMessageVerbose(timestamp: DateTime(2026), level: const LogLevel.info(), message: 'alpha'),
      LogMessageVerbose(timestamp: DateTime(2026), level: const LogLevel.info(), message: 'beta'),
    ]);
    await tester.pumpWidget(
      WidgetTestUtil.createWidgetUnderTest(dependencies: dependencies, builder: (_) => const LogsScreen()),
    );
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getCenter(find.byType(CupertinoSearchTextField)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CupertinoSearchTextField), 'beta');
    buffer.add(LogMessageVerbose(timestamp: DateTime(2026), level: const LogLevel.info(), message: 'beta new'));
    await tester.pumpAndSettle();
    expect(tester.widget<CupertinoSearchTextField>(find.byType(CupertinoSearchTextField)).controller!.text, 'beta');
    expect(find.text('alpha'), findsNothing);
    expect(find.text('beta new'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    buffer.clear();
    expect(tester.takeException(), isNull);
  });
});

FakeDependencies _dependencies(MockSettingsRepository repository, Analytics analytics) => FakeDependencies()
  ..analytics = analytics
  ..metadata = MockService.appMetadata
  ..database = MockDatabase()
  ..authenticationController = AuthenticationController(
    repository: AuthenticationRepository$Fake(),
    initialState: const AuthenticationState.idle(
      user: User.authenticated(id: 'test-user', token: 'test-token'),
    ),
  )
  ..settingsController = SettingsController(repository: repository);

class _ConsentTracker extends AnalyticsTracker$Logger {
  final List<bool> consents = [];
  @override
  Future<void> setConsent(bool consent) async => consents.add(consent);
}
