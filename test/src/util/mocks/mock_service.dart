/*
 * Date: 16 June 2024
 */

// ignore_for_file: library_private_types_in_public_api, sort_constructors_first

import 'package:faker/faker.dart' hide Currency;
import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/common/api_client/api_client.dart';
import 'package:flutter_template_name/src/common/api_client/api_exception.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/model/app_metadata.dart';
import 'package:flutter_template_name/src/common/model/photo.dart';
import 'package:flutter_template_name/src/feature/authentication/model/user.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_settings.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:money2/money2.dart';
import 'package:ui/ui.dart';

import '../test_util.dart';

// Функция для создания заглушки User
User dummyUserBuilder(_, _) => MockService.user.authenticated;

/// {@template mock_service}
/// MoskService class.
///
/// Contains mock data for testing purposes.
/// {@endtemplate}
final class MockService {
  /// {@macro mock_service}
  static final _instance = MockService._internal();
  static MockService get instance => _instance;
  factory MockService() => _instance;
  MockService._internal();

  /// Initialize the mock service
  ///
  /// This method should be called in the [setUp] or [setUpAll] method of the test file.
  /// Default locale is `ru`
  static void initialize({String? locale}) {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeDateFormatting(locale ?? Config.locale.languageCode);
    provideDummyBuilder<User>(dummyUserBuilder);
    provideDummy<ApiClient$HTTP$Response>(Fixture.fromJSON(const <String, Object?>{}).toHTTPResponse());
  }

  /// Money factory method for creating Money instances with the default currency
  static Money money(num value) => Money.fromNumWithCurrency(value, Config.currency);

  /// Fake App Metadata
  static final AppMetadata appMetadata = AppMetadata(
    appName: 'App name',
    appVersion: '0.0.0',
    appVersionMajor: 0,
    appVersionMinor: 0,
    appVersionPatch: 0,
    appBuildTimestamp: DateTime.now().toUtc(),
    appLaunchedTimestamp: DateTime.now().toUtc(),
    deviceScreenSize: '',
    deviceVersion: '',
    isWeb: const bool.fromEnvironment('dart.library.js_util'),
    isRelease: const bool.fromEnvironment('dart.vm.product'),
    locale: Config.locale.toLanguageTag(),
    operatingSystem: 'unknown',
    operatingSystemManufacturer: 'unknown',
    processorsCount: 1,
    hasGmsServices: const bool.fromEnvironment('dart.vm.product'),
    hasHmsServices: false,
  );

  static const AppSettings appSettings = AppSettings(theme: AppTheme.empty(), locale: Locale('ru'), textScale: 1.0);

  static const String locale = 'ru';
  static const String baseUrl = 'https://beautybox-stage.ru';

  /// Fake JWT token for testing purposes
  static final String token = faker.jwt.valid();

  /// This id should be set in most cases to your mocks and should also be set at the second index in arrays.
  static const String id = '1';

  static final String addressString = '${faker.address.country()} ${faker.address.city()}';

  static final String color = '#${faker.randomGenerator.fromPatternToHex(['######'])}';

  static const String name = 'Jackei Chan';
  static const String phone = '+7 927 123 45 67';
  static final String email = faker.internet.email();
  static final String password = faker.internet.password();

  static final DateTime dateTime = DateTime.now().toUtc();
  static final String date = dateTime.toString();

  static const String timeFrom = '09:00';
  static const String timeTo = '21:00';

  static const String message = 'Hello world!';
  static const String messageError = 'An error occurred';

  static const exceptions = _MockService$Exceptions();
  static const common = _MockService$Common();
  static const auth = _MockService$Auth();
  static const user = _MockService$User();
}

/// MoskService$Exceptions class
/// {@macro mock_service}
final class _MockService$Exceptions {
  /// {@macro mock_service}
  const _MockService$Exceptions();

  /// Get the default error message for API exceptions.
  String get messageError => _messageError;
  static const _messageError = MockService.messageError;

  /// Get a fake API exception for testing purposes.
  ApiException get api => const ApiException$Client(
    code: 'fake_api_error',
    message: _messageError,
    statusCode: 0,
    error: null,
    data: null,
    stackTrace: null,
  );

  /// Get a fake API exception for testing purposes with authorization error type.
  ApiException get tokenInvalided => const ApiException$Authorization(
    code: 'fake_token_invalided',
    message: _messageError,
    statusCode: 0,
    error: null,
    data: null,
    stackTrace: null,
  );
}

/// MoskService$Auth class
/// {@macro mock_service}
final class _MockService$Auth {
  /// {@macro mock_service}
  const _MockService$Auth();

  /// Get a fake PIN code for testing purposes.
  String get code => faker.randomGenerator.string(4, min: 4);

  /// Get a fake secret string for testing purposes.
  String get secretString => faker.randomGenerator.string(15, min: 10);
}

/// MoskService$User class
/// {@macro mock_service}
final class _MockService$User {
  /// {@macro mock_service}
  const _MockService$User();

  /// Get a fake authenticated user for testing purposes.
  AuthenticatedUser get authenticated => AuthenticatedUser(id: MockService.id, token: MockService.token);
}

/// MoskService$Common class
/// {@macro mock_service}
final class _MockService$Common {
  /// {@macro mock_service}
  const _MockService$Common();

  Photo get photo => const Photo(crop: Crop.empty(), image: '${MockService.baseUrl}/image_mock.png');

  Photo get photoCroped => const Photo(crop: Crop.empty(), image: 'image');

  List<String> get dates => List<String>.generate(3, (index) {
    final date = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(DateTime(date.year, date.month, date.day, date.hour, date.minute + index));
  });

  List<String> get colors =>
      List.generate(5, (i) => i == 1 ? MockService.color : '#${faker.randomGenerator.fromPatternToHex(['######'])}');

  /* List<WeekDay> get weekDays => List.generate(
    7,
    (i) => WeekDay(
      isActive: i == 1,
      title: MockService.message,
      alias: MockService.message,
      shortTitle: MockService.message,
    ),
  ); */

  List<String> get shortWeek => ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
}
