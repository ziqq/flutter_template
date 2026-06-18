import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/feature/settings/controller/settings_controller.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_settings.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_theme.dart';
import 'package:flutter_template_name/src/feature/settings/model/user_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../../util/test_util.dart';

void main() {
  _$controllerTest();
  _$stateTest();
}

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

  group('initial state -', () {
    test('defaults', () {
      expect(controller.state.settings, const AppSettings.empty());
      expect(controller.state.preferences, const UserPreferences.empty());
      expect(controller.state.isIdle, isTrue);
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

      expect(controller.state.isIdle, isTrue);
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
      expect(controller.state.isFailed, isTrue);
    });
  });

  group('setThemeMode() -', () {
    test('success', () async {
      when(repository.saveSettings(any)).thenAnswer((_) async {});
      await controller.setThemeMode(ThemeMode.dark);
      expect(controller.state.settings.theme.themeMode, ThemeMode.dark);
      expect(controller.state.isIdle, isTrue);
      verify(repository.saveSettings(any)).called(1);
    });

    test('failure', () async {
      when(repository.saveSettings(any)).thenThrow(MockService.exceptions.api);
      controller.setThemeMode(ThemeMode.dark).ignore();
      await untilCalled(repository.saveSettings(any));
      expect(controller.state.isFailed, isTrue);
      expect(controller.state.message, contains(MockService.exceptions.messageError));
    });
  });

  group('setLocale() -', () {
    test('success', () async {
      const locale = Locale('ru');
      when(repository.saveSettings(any)).thenAnswer((_) async {});
      await controller.setLocale(locale);
      expect(controller.state.settings.locale, locale);
      verify(repository.saveSettings(any)).called(1);
    });

    test('failure', () async {
      when(repository.saveSettings(any)).thenThrow(MockService.exceptions.api);
      controller.setLocale(const Locale('ru')).ignore();
      await untilCalled(repository.saveSettings(any));
      expect(controller.state.isFailed, isTrue);
    });
  });

  group('setAccentColor() -', () {
    test('set color', () async {
      const color = Color(0xFF336699);
      when(repository.saveSettings(any)).thenAnswer((_) async {});
      await controller.setAccentColor(color);
      expect(controller.state.settings.theme.accent, color);
      verify(repository.saveSettings(any)).called(1);
    });

    test('remove color', () async {
      when(repository.saveSettings(any)).thenAnswer((_) async {});
      await controller.setAccentColor(null);
      expect(controller.state.settings.theme.accent, isNull);
    });

    test('failure', () async {
      when(repository.saveSettings(any)).thenThrow(MockService.exceptions.api);
      controller.setAccentColor(const Color(0xFF000000)).ignore();
      await untilCalled(repository.saveSettings(any));
      expect(controller.state.isFailed, isTrue);
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
      expect(controller.state.isFailed, isTrue);
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
      expect(controller.state.isFailed, isTrue);
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
      expect(controller.state.isFailed, isTrue);
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
      expect(controller.state.isFailed, isTrue);
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
      expect(controller.state.isFailed, isTrue);
    });
  });
});

void _$stateTest() => group('SettingsState -', () {
  const locale = Locale('ru');
  const themeMode = ThemeMode.dark;
  const useBeta = true;
  const useDebug = true;
  const useDevelopment = true;
  const useExpiremental = true;
  const useHapticFeedback = true;
  const message = MockService.message;

  const preferences = UserPreferences(
    useBeta: useBeta,
    useDebug: useDebug,
    useDevelopment: useDevelopment,
    useExpiremental: useExpiremental,
    useHapticFeedback: useHapticFeedback,
  );
  const settings = AppSettings(
    theme: AppTheme(themeMode: themeMode, accent: null),
    locale: locale,
    textScale: 1,
  );

  const processingState = SettingsState.processing(preferences: preferences, settings: settings);
  const failedState = SettingsState.failed(preferences: preferences, settings: settings);
  const idleState = SettingsState.idle(preferences: preferences, settings: settings);

  test('Processing state should be created correctly', () {
    expect(processingState, isA<SettingsState$Processing>());
    expect(processingState.type, 'processing');
    expect(processingState.isProcessing, isTrue);
    expect(processingState.isFailed, isFalse);
    expect(processingState.isIdle, isFalse);
  });

  test('Failed state should be created correctly', () {
    expect(failedState, isA<SettingsState$Failed>());
    expect(failedState.type, 'failed');
    expect(failedState.isFailed, isTrue);
    expect(failedState.isIdle, isFalse);
    expect(failedState.isProcessing, isFalse);
  });

  test('Idle state should be created correctly', () {
    expect(idleState, isA<SettingsState$Idle>());
    expect(idleState.type, 'idle');
    expect(idleState.isIdle, isTrue);
    expect(idleState.isFailed, isFalse);
    expect(idleState.isProcessing, isFalse);
    expect(idleState.message, 'Idle');
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
  });
});
