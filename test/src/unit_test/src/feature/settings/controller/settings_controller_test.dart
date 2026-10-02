import 'package:flutter_template_name/src/common/api_client/api_exception.dart' show ApiException;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/feature/settings/controller/settings_controller.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_settings.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_theme.dart';
import 'package:flutter_template_name/src/feature/settings/model/user_preferences.dart';

import '../../../../../util/test_util.dart';
import '../../../../../util/test_util.mocks.dart';

/// Unit tests for the settings feature: the [SettingsController] behaviour
/// (restore and every preference/settings setter, incl. `setUseIOS26LiquidTheme`)
/// and the [SettingsState] value semantics.
void main() {
  _$controllerTest();
  _$stateTest();
}

/// Tests for [SettingsController]: success and failure paths of `restore()`
/// and each setter, verifying the emitted state and repository interactions.
void _$controllerTest() => group('SettingsController -', () {
  late MockSettingsRepository repository;
  late SettingsController controller;

  setUpAll(() {
    provideDummy<AppSettings>(const AppSettings.empty());
    provideDummy<UserPreferences>(const UserPreferences.empty());
  });

  setUp(() {
    repository = MockSettingsRepository();
    controller = SettingsController(repository: repository);
  });

  test('name', () {
    expect(controller.name, 'SettingsController');
  });

  test('analytics sending preference is persisted', () async {
    when(repository.savePreferences(any)).thenAnswer((_) async {});
    await controller.setAnalyticsDataSendingEnabled(false);
    expect(controller.state.preferences.analyticsDataSendingEnabled, isFalse);
    verify(repository.savePreferences(const UserPreferences(analyticsDataSendingEnabled: false))).called(1);
  });

  test('failed analytics preference save preserves the previous setting', () async {
    when(repository.savePreferences(any)).thenThrow(MockService.exceptions.api);
    await controller.setAnalyticsDataSendingEnabled(false);
    expect(controller.state.preferences.analyticsDataSendingEnabled, isTrue);
  });

  group('initial state -', () {
    test('defaults', () {
      expect(controller.state.settings, const AppSettings.empty());
      expect(controller.state.preferences, const UserPreferences.empty());
    });
  });

  group('restore() -', () {
    test('success', () async {
      const restoredSettings = AppSettings(
        theme: AppTheme(themeMode: ThemeMode.dark),
        locale: Locale('de'),
        textScale: 1.25,
      );
      const restoredPrefs = UserPreferences(
        useBeta: true,
        useDebug: true,
        useDevelopment: true,
        useExpiremental: true,
        useHapticFeedback: false,
      );

      when(repository.readSettings()).thenAnswer((_) async => restoredSettings);
      when(repository.readPreferences()).thenAnswer((_) async => restoredPrefs);

      await controller.restore();

      expect(controller.state.settings, restoredSettings);
      expect(controller.state.preferences, restoredPrefs);
      expect(controller.state.message, anyOf('Settings restored', 'Idle'));
      verify(repository.readSettings()).called(1);
      verify(repository.readPreferences()).called(1);
    });

    test('failure', () async {
      when(repository.readSettings()).thenThrow(MockService.exceptions.api);
      controller.restore().ignore();
      await untilCalled(repository.readSettings());
      expect(controller.state.error, isA<ApiException>());
    });
  });

  group('setThemeMode() -', () {
    test('success', () async {
      when(repository.saveSettings(settings: anyNamed('settings'))).thenAnswer((_) async {});
      await controller.setThemeMode(ThemeMode.dark);
      expect(controller.state.settings.theme.themeMode, ThemeMode.dark);
      verify(repository.saveSettings(settings: anyNamed('settings'))).called(1);
    });

    test('failure', () async {
      when(repository.saveSettings(settings: anyNamed('settings'))).thenThrow(MockService.exceptions.api);
      controller.setThemeMode(ThemeMode.dark).ignore();
      await untilCalled(repository.saveSettings(settings: anyNamed('settings')));
      expect(controller.state.error, isA<ApiException>());
      expect(controller.state.message, contains(MockService.exceptions.messageError));
    });
  });

  group('setLocale() -', () {
    test('success', () async {
      const locale = Locale('ru');
      when(repository.saveSettings(settings: anyNamed('settings'))).thenAnswer((_) async {});
      await controller.setLocale(locale);
      expect(controller.state.settings.locale, locale);
      verify(repository.saveSettings(settings: anyNamed('settings'))).called(1);
    });

    test('failure', () async {
      when(repository.saveSettings(settings: anyNamed('settings'))).thenThrow(MockService.exceptions.api);
      controller.setLocale(const Locale('ru')).ignore();
      await untilCalled(repository.saveSettings(settings: anyNamed('settings')));

      expect(controller.state.error, isA<ApiException>());
    });
  });

  group('setAccentColor() -', () {
    test('set color', () async {
      const color = Color(0xFF336699);
      when(repository.saveSettings(settings: anyNamed('settings'))).thenAnswer((_) async {});
      await controller.setAccentColor(color);
      expect(controller.state.settings.theme.accent, color);
      verify(repository.saveSettings(settings: anyNamed('settings'))).called(1);
    });

    test('remove color', () async {
      when(repository.saveSettings(settings: anyNamed('settings'))).thenAnswer((_) async {});
      await controller.setAccentColor(null);
      expect(controller.state.settings.theme.accent, isNull);
    });

    test('failure', () async {
      when(repository.saveSettings(settings: anyNamed('settings'))).thenThrow(MockService.exceptions.api);
      controller.setAccentColor(const Color(0xFF000000)).ignore();
      await untilCalled(repository.saveSettings(settings: anyNamed('settings')));
      expect(controller.state.error, isA<ApiException>());
    });
  });

  group('setUseBeta() -', () {
    test('success', () async {
      when(repository.savePreferences(any)).thenAnswer((_) async {});
      await controller.setUseBeta(true);
      expect(controller.state.preferences.useBeta, isTrue);
      verify(repository.savePreferences(any)).called(1);
    });

    test('failure', () async {
      when(repository.savePreferences(any)).thenThrow(MockService.exceptions.api);
      controller.setUseBeta(true).ignore();
      await untilCalled(repository.savePreferences(any));
      expect(controller.state.error, isA<ApiException>());
    });
  });

  group('setUseDebug() -', () {
    test('success', () async {
      when(repository.savePreferences(any)).thenAnswer((_) async {});
      await controller.setUseDebug(true);
      expect(controller.state.preferences.useDebug, isTrue);
    });

    test('failure', () async {
      when(repository.savePreferences(any)).thenThrow(MockService.exceptions.api);
      controller.setUseDebug(true).ignore();
      await untilCalled(repository.savePreferences(any));
      expect(controller.state.error, isA<ApiException>());
    });
  });

  group('setUseDevelompent() -', () {
    // method name kept as in source
    test('success', () async {
      when(repository.savePreferences(any)).thenAnswer((_) async {});
      await controller.setUseDevelompent(true);
      expect(controller.state.preferences.useDevelopment, isTrue);
    });

    test('failure', () async {
      when(repository.savePreferences(any)).thenThrow(MockService.exceptions.api);
      controller.setUseDevelompent(true).ignore();
      await untilCalled(repository.savePreferences(any));
      expect(controller.state.error, isA<ApiException>());
    });
  });

  group('setUseExpiremental() -', () {
    test('success', () async {
      when(repository.savePreferences(any)).thenAnswer((_) async {});
      await controller.setUseExpiremental(true);
      expect(controller.state.preferences.useExpiremental, isTrue);
    });

    test('failure', () async {
      when(repository.savePreferences(any)).thenThrow(MockService.exceptions.api);
      controller.setUseExpiremental(true).ignore();
      await untilCalled(repository.savePreferences(any));
      expect(controller.state.error, isA<ApiException>());
    });
  });

  group('setUseHapticFeedback() -', () {
    test('success', () async {
      when(repository.savePreferences(any)).thenAnswer((_) async {});
      await controller.setUseHapticFeedback(false);
      expect(controller.state.preferences.useHapticFeedback, isFalse);
    });

    test('failure', () async {
      when(repository.savePreferences(any)).thenThrow(MockService.exceptions.api);
      controller.setUseHapticFeedback(false).ignore();
      await untilCalled(repository.savePreferences(any));
      expect(controller.state.error, isA<ApiException>());
    });
  });

  // Toggling the iOS 26+ liquid theme persists the flag and reflects it in state.
  group('setUseIOS26LiquidTheme() -', () {
    test('success', () async {
      when(repository.savePreferences(any)).thenAnswer((_) async {});
      await controller.setUseIOS26LiquidTheme(false);
      expect(controller.state.preferences.useIOS26LiquidTheme, isFalse);
      verify(repository.savePreferences(any)).called(1);
    });

    test('failure', () async {
      when(repository.savePreferences(any)).thenThrow(MockService.exceptions.api);
      controller.setUseIOS26LiquidTheme(true).ignore();
      await untilCalled(repository.savePreferences(any));
      expect(controller.state.error, isA<ApiException>());
    });
  });
});

/// Tests for [SettingsState]: construction of each variant, pattern-matching
/// helpers (`map`/`maybeMap`/`mapOrNull`), equality, `hashCode` and `toString`.
void _$stateTest() => group('SettingsState -', () {
  const message = MockService.message;
  const locale = Config.locale;
  const useBeta = true;
  const useDebug = true;
  const useDevelopment = true;
  const useExpiremental = true;
  const useHapticFeedback = true;

  const preferences = UserPreferences(
    useBeta: useBeta,
    useDebug: useDebug,
    useDevelopment: useDevelopment,
    useExpiremental: useExpiremental,
    useHapticFeedback: useHapticFeedback,
  );
  const settings = AppSettings(theme: .empty(), locale: locale, textScale: 1);

  const processingState = SettingsState.processing(preferences: preferences, settings: settings);
  const failedState = SettingsState.failed(preferences: preferences, settings: settings);
  const idleState = SettingsState.idle(preferences: preferences, settings: settings);

  test('Processing state should be created correctly', () {
    expect(processingState, isA<SettingsState$Processing>());
    expect(processingState.isProcessing, isTrue);
    expect(processingState.type, 'processing');
  });

  test('Failed state should be created correctly', () {
    expect(failedState, isA<SettingsState$Failed>());
    expect(failedState.isProcessing, isFalse);
    expect(failedState.type, 'failed');
  });

  test('Idle state should be created correctly', () {
    expect(idleState, isA<SettingsState$Idle>());
    expect(idleState.isProcessing, isFalse);
    expect(idleState.message, 'Idle');
    expect(idleState.type, 'idle');
  });

  test('map should correctly handle all states', () {
    expect(idleState.map(processing: (_) => 'processing', failed: (_) => 'failed', idle: (_) => 'idle'), 'idle');
    expect(
      processingState.map(processing: (_) => 'processing', failed: (_) => 'failed', idle: (_) => 'idle'),
      'processing',
    );
    expect(failedState.map(processing: (_) => 'processing', failed: (_) => 'failed', idle: (_) => 'idle'), 'failed');
  });

  test('maybeMap should correctly handle all states with orElse', () {
    expect(processingState.maybeMap<String?>(processing: (_) => 'processing', orElse: () => 'other'), 'processing');
    expect(failedState.maybeMap<String?>(failed: (_) => 'failed', orElse: () => 'other'), 'failed');
    expect(idleState.maybeMap<String?>(idle: (_) => 'idle', orElse: () => 'other'), 'idle');
    expect(processingState.maybeMap<String?>(failed: (_) => 'failed', orElse: () => 'other'), 'other');
    expect(failedState.maybeMap<String?>(processing: (_) => 'processing', orElse: () => 'other'), 'other');
    expect(idleState.maybeMap<String?>(processing: (_) => 'processing', orElse: () => 'other'), 'other');
  });

  test('mapOrNull should correctly handle all states', () {
    expect(processingState.mapOrNull<String?>(processing: (_) => 'processing'), 'processing');
    expect(failedState.mapOrNull<String?>(failed: (_) => 'failed'), 'failed');
    expect(idleState.mapOrNull<String?>(idle: (_) => 'idle'), 'idle');
    expect(processingState.mapOrNull<String?>(failed: (_) => 'failed', idle: (_) => 'idle'), null);
    expect(failedState.mapOrNull<String?>(processing: (_) => 'processing', idle: (_) => 'idle'), null);
    expect(idleState.mapOrNull<String?>(processing: (_) => 'processing', failed: (_) => 'failed'), null);
  });

  group('hashCode -', () {
    test('Different states should have different hashCodes', () {
      const idleState = SettingsState.idle(preferences: preferences, settings: settings, message: message);
      final processingState = SettingsState.processing(
        preferences: preferences,
        settings: settings.copyWith(locale: const Locale('en')),
        message: message,
      );
      final failedState = SettingsState.failed(
        preferences: preferences,
        settings: settings.copyWith(locale: const Locale('fr')),
        message: message,
      );
      expect(idleState.hashCode != processingState.hashCode, isTrue);
      expect(idleState.hashCode != failedState.hashCode, isTrue);
      expect(processingState.hashCode != failedState.hashCode, isTrue);
    });
  });

  group('toString() -', () {
    test('Should return string', () {
      expect(idleState.toString(), isA<String>());
      expect(idleState.toString(), 'SettingsState.idle{message: Idle}');
    });
  });

  group('identical (==) -', () {
    test('Should check on identical', () {
      const otherState = SettingsState.idle(
        preferences: UserPreferences.empty(),
        settings: AppSettings.empty(),
        message: message,
      );
      expect(idleState, isNot(equals(otherState)));
      expect(idleState.hashCode, isNot(equals(otherState.hashCode)));
    });

    test('Should treat states with same preferences settings and type as equal', () {
      const first = SettingsState.idle(preferences: .empty(), settings: settings);
      const second = SettingsState.idle(preferences: .empty(), settings: settings);
      expect(first == first, isTrue);
      expect(first, equals(second));

      const third = SettingsState.idle(preferences: .empty(), settings: .empty());
      const fourth = SettingsState.processing(preferences: .empty(), settings: .empty());
      expect(third, isNot(equals(fourth)));
    });
  });
});
