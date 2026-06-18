// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_template_name/src/feature/settings/data/settings_repository.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_settings.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_theme.dart';
import 'package:flutter_template_name/src/feature/settings/model/user_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../../util/mocks/mock_service.dart';
import '../../../../../util/test_util.mocks.dart';

void main() {
  group('SettingsRepository -', () {
    late MockUserPreferencesDataProvider userPreferencesDataProvider;
    late MockAppSettingsDataProvider appSettingsDataProvider;
    late SettingsRepository repository;

    setUpAll(() {
      provideDummy<AppSettings>(const AppSettings(theme: AppTheme.empty(), locale: Locale('en'), textScale: 1.0));
      provideDummy<UserPreferences>(const UserPreferences());
    });

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      appSettingsDataProvider = MockAppSettingsDataProvider();
      userPreferencesDataProvider = MockUserPreferencesDataProvider();
      repository = SettingsRepository(
        appSettingsDataProvider: appSettingsDataProvider,
        userPreferencesDataProvider: userPreferencesDataProvider,
      );
    });

    test('implements interface', () {
      expect(repository, isA<ISettingsRepository>());
    });

    group('readSettings()', () {
      test('delegates to provider.read()', () async {
        const stub = MockService.appSettings;
        when(appSettingsDataProvider.read()).thenAnswer((_) async => stub);
        final result = await repository.readSettings();
        expect(result, stub);
        verify(appSettingsDataProvider.read()).called(1);
        verifyNoMoreInteractions(appSettingsDataProvider);
      });

      test('propagates exception (Future.error)', () async {
        when(appSettingsDataProvider.read()).thenAnswer((_) => Future<AppSettings>.error(StateError('fail')));
        expect(repository.readSettings(), throwsStateError);
      });
    });

    group('saveSettings()', () {
      test('delegates to provider.save()', () async {
        const stub = MockService.appSettings;
        when(appSettingsDataProvider.save(stub)).thenAnswer((_) async {});
        await repository.saveSettings(stub);
        verify(appSettingsDataProvider.save(stub)).called(1);
        verifyNoMoreInteractions(appSettingsDataProvider);
      });

      test('propagates exception (Future.error)', () async {
        const stub = MockService.appSettings;
        when(appSettingsDataProvider.save(stub)).thenAnswer((_) => Future<void>.error(ArgumentError('bad')));
        expect(repository.saveSettings(stub), throwsArgumentError);
      });
    });

    group('readPreferences()', () {
      test('delegates to provider.read()', () async {
        const prefs = UserPreferences(useBeta: true, useDebug: true);
        when(userPreferencesDataProvider.read()).thenAnswer((_) async => prefs);
        final result = await repository.readPreferences();
        expect(result, prefs);
        verify(userPreferencesDataProvider.read()).called(1);
        verifyNoMoreInteractions(userPreferencesDataProvider);
      });

      test('propagates exception (Future.error)', () async {
        when(userPreferencesDataProvider.read()).thenAnswer((_) => Future<UserPreferences>.error(ArgumentError('bad')));
        expect(repository.readPreferences(), throwsArgumentError);
      });
    });

    group('savePreferences()', () {
      test('delegates to provider.save()', () async {
        const prefs = UserPreferences(useExpiremental: true, useHapticFeedback: false);
        when(userPreferencesDataProvider.save(prefs)).thenAnswer((_) async {});
        await repository.savePreferences(prefs);
        verify(userPreferencesDataProvider.save(prefs)).called(1);
        verifyNoMoreInteractions(userPreferencesDataProvider);
      });

      test('propagates exception (Future.error)', () async {
        const prefs = UserPreferences();
        when(userPreferencesDataProvider.save(prefs)).thenAnswer((_) => Future<void>.error(StateError('fail')));
        expect(repository.savePreferences(prefs), throwsStateError);
      });
    });
  });
}
