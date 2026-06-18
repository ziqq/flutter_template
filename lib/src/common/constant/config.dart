// ignore_for_file: avoid_classes_with_only_static_members

import 'package:money2/money2.dart' show Currency;
import 'package:ui/ui.dart' show Locale;

/// Config for app.
abstract final class Config {
  // --- ENVIRONMENT --- //

  /// Environment flavor.
  /// e.g. development, staging, production
  static final EnvironmentFlavor environment = EnvironmentFlavor.from(
    const String.fromEnvironment('ENVIRONMENT', defaultValue: 'development'),
  );

  // --- API --- //

  /// Firebase options for the app.
  /* static final FirebaseOptions firebaseOptions = switch (environment) {
    .production => DefaultFirebaseOptions$Prod.currentPlatform,
    _ => DefaultFirebaseOptions$Dev.currentPlatform,
  }; */

  /// Base url for api.
  /// e.g. https://domen.com/api
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://domen.com/api');

  /// Base url.
  /// e.g. https://domen.com
  static const String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'https://domen.com');

  /// Key for [AppMetrica].
  /// e.g. app-metrika-key
  static const String appMetricaKey = String.fromEnvironment('APP_METRICA_KEY', defaultValue: '');

  /// Key for [GoogleMap].
  /// e.g. google-maps-key
  static const String googleMapsKey = String.fromEnvironment('GOOGLE_MAPS_KEY', defaultValue: '');

  /// Key for identify user in authentications.
  /// e.g. uth-hmac-key
  static const String authHmacKey = String.fromEnvironment('AUTH_HMAC_KEY', defaultValue: 'auth-hmac-key');

  /// Timeout in milliseconds for opening url.
  /// [Dio] will throw the [DioException] with [DioExceptionType.connectTimeout] type when time out.
  /// e.g. 15000
  static const Duration apiConnectTimeout = Duration(
    milliseconds: int.fromEnvironment('API_CONNECT_TIMEOUT', defaultValue: 15000),
  );

  /// Timeout in milliseconds for receiving data from url.
  /// [Dio] will throw the [DioException] with [DioExceptionType.receiveTimeout] type when time out.
  /// e.g. 15000
  static const Duration apiReceiveTimeout = Duration(
    milliseconds: int.fromEnvironment('API_RECEIVE_TIMEOUT', defaultValue: 15000),
  );

  /// The client key for sentry SDK. The DSN tells the SDK where to send the events to.
  static const String sentryDSN = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  /// The feedback email address.
  /// e.g. `help@domen.com`
  static const String feedbackEmail = 'help@domen.com';

  /// The feedback phone number.
  /// e.g. +7 937 224-36-18
  static const String feedbackPhone = String.fromEnvironment('PHONE_FEEDBACK', defaultValue: '');

  /// The token for telegram error bot collector.
  static const String telegramErrorBotToken = String.fromEnvironment('TELEGRAM_ERROR_BOT_TOKEN', defaultValue: '');

  /// The chat id for telegram error bot collector.
  static const int telegramErrorBotChatID = int.fromEnvironment('TELEGRAM_ERROR_BOT_CHAT_ID', defaultValue: 0);

  /// Cache lifetime.
  /// Refetch data from url when cache is expired.
  /// e.g. 1 hour
  static const Duration cacheLifetime = Duration(hours: 1);

  // --- DATABASE --- //

  /// Database version.
  /// e.g. 1
  static const int databaseVersion = int.fromEnvironment('DATABASE_VERSION', defaultValue: 1);

  /// Whether to drop database on start.
  /// e.g. true
  static const bool dropDatabase = bool.fromEnvironment('DROP_DATABASE', defaultValue: false);

  /// Database file name by default.
  /// e.g. sqlite means "sqlite.db" for native platforms and "sqlite" for web platform.
  static const String databaseName = String.fromEnvironment('DATABASE_NAME', defaultValue: 'sqlite');

  /// Whether to use in-memory database.
  static const bool inMemoryDatabase = bool.fromEnvironment('IN_MEMORY_DATABASE', defaultValue: false);

  // --- AUTHENTICATION --- //

  /// Minimum length of password.
  /// e.g. `6`
  static const int passwordMinLength = int.fromEnvironment('PASSWORD_MIN_LENGTH', defaultValue: 6);

  /// Maximum length of password.
  /// e.g. `32`
  static const int passwordMaxLength = int.fromEnvironment('PASSWORD_MAX_LENGTH', defaultValue: 32);

  // --- COMMENTS --- //

  /// Maximum length of client comment.
  /// e.g. `1000`
  static const int commentClientMaxLength = int.fromEnvironment('COMMENT_CLIENT_MAX_LENGTH', defaultValue: 1000);

  /// Maximum length of employee comment.
  /// e.g. `500`
  static const int commentEmployeeMaxLength = int.fromEnvironment('COMMENT_EMPLOYEE_MAX_LENGTH', defaultValue: 500);

  /// Maximum length of notification template.
  /// e.g. `600`
  static const int commentNotificationTemplateMaxLength = int.fromEnvironment(
    'COMMENT_NOTIFICATION_TEMPLATE_MAX_LENGTH',
    defaultValue: 600,
  );

  /// Maximum length of visit comment.
  /// e.g. `3000`
  static const int commentVisitMaxLength = int.fromEnvironment('COMMENT_VISIT_MAX_LENGTH', defaultValue: 3000);

  /// Maximum length of company description comment.
  /// e.g. `250`
  static const int descriptionCompanyMaxLength = int.fromEnvironment(
    'DESCRIPTION_COMPANY_MAX_LENGTH',
    defaultValue: 250,
  );

  /// Maximum length of clients mailing template.
  /// e.g. 935
  static const int mailingTemplateMaxLength = int.fromEnvironment(
    'COMMENT_NOTIFICATION_TEMPLATE_MAX_LENGTH',
    defaultValue: 935,
  );

  // --- LAYOUT --- //

  /// Maximum screen layout width for screen with list view.
  static const int maxScreenLayoutWidth = int.fromEnvironment('MAX_LAYOUT_WIDTH', defaultValue: 768);

  // --- Key storage namespace --- //

  /// Namespace for all version keys
  static const String storageNamespace = 'flutter_template_name';

  /// Keys for storing the current version of the app
  static const String versionMajorKey = '$storageNamespace.version.major';

  /// Keys for storing the current version of the app
  static const String versionMinorKey = '$storageNamespace.version.minor';

  /// Keys for storing the current version of the app
  static const String versionPatchKey = '$storageNamespace.version.patch';

  // --- LINK'S --- //

  /// Consent to the processing of personal data.
  /// e.g: `https://domen.com/page/agreement`
  static const String agreementURL = 'https://domen.com/page/agreement';

  /// Privacy Policy url.
  /// e.g: `https://domen.com/page/politics`
  static const String privacyPoliticsURL = 'https://domen.com/page/politics';

  /// Offer Agreement for Paid Software Implementation url.
  /// e.g: `https://domen.com/page/contract-offer`
  static const String contractOfferURL = 'https://domen.com/page/contract-offer';

  // --- APP --- //

  /// The default [Locale] for the app.
  /// Default is `ru`
  static const Locale locale = Locale.fromSubtags(languageCode: 'ru');

  /// The default [Currency] for the app.
  /// Default is `RUB`
  ///
  /// To create a custom currency, use [Currency.create] method.
  /// Example:
  /// ```dart
  /// Currency.create(
  ///   'RUB', 2,
  ///   symbol: '₽',
  ///   groupSeparator: ' ',
  ///   decimalSeparator: ','
  ///   pattern: '#,##0.00 S'
  /// );
  /// ```
  static final Currency currency = Currency.create(
    'RUB',
    2,
    symbol: '₽',
    groupSeparator: ' ',
    decimalSeparator: ',',
    pattern: '#,##0.00 S',
  );

  /// Available currencies for the app.
  /// Default is `RUB`, `USD`, `EUR`
  static final List<Currency> currencies = <Currency>[
    currency,
    Currency.create('EUR', 2, symbol: '€', groupSeparator: '.', decimalSeparator: ',', pattern: '#,##0.00 S'),
    Currency.create('USD', 2, symbol: r'$', groupSeparator: ',', decimalSeparator: '.', pattern: '#,##0.00 S'),
  ];

  /// Get [Currency] from app currencies by iso code.
  static Currency getCurrencyByIsoCode(String? isoCode) {
    try {
      if (isoCode == null || isoCode.isEmpty) return currency;
      return currencies.firstWhere((c) => c.isoCode == isoCode, orElse: () => currency);
    } on Object catch (_) {
      throw ArgumentError.value(
        isoCode,
        'Config.getCurrencyByIsoCode',
        'Supported values are: ${currencies.map((c) => c.isoCode).join(', ')}',
      );
    }
  }

  /// Default country for the app.
  /// Default is `Russia`
  // static final Country country = Country.ru();

  /// Favorite country for the app.
  static final List<String> coutntriesFavorites = List<String>.unmodifiable([
    'RU', // Russia
  ]);

  /// Available countries for the app.
  static final List<String> coutntries = List<String>.unmodifiable([
    'RU', // Russia
    // 'AB', // Abkhazia
    'AZ', // Azerbaijan
    'AM', // Armenia
    'AT', // Austria
    'BY', // Belarus
    'CY', // Cyprus
    'ES', // Spain
    'GE', // Georgia
    'GR', // Greece
    'ID', // Indonesia
    'IL', // Israel
    'IR', // Iran
    'KZ', // Kazakhstan
    'KG', // Kyrgyzstan
    'MD', // Moldova
    'TJ', // Tajikistan
    'TH', // Thailand
    'TR', // Türkiye
    'US', // United States
    'UZ', // Uzbekistan
  ]);

  // --- BUSINESS --- //

  /// The uploaded limit of the cloud for the notes.
  /// e.g. `80` means `80%`
  static const int noteCloudUploadedLimitPercent = 80;

  /// Maximum images for the note.
  /// e.g. `15`
  static const int noteMaxImages = 15;

  /// Maximum files for the note.
  /// e.g. `10`
  static const int noteMaxFiles = 10;

  /// Maximum weight of file for the note.
  /// e.g. `20 MB`
  static const int noteMaxFileWeight = 20 * 1024 * 1024;

  /// Maximum weight of all fils for the note.
  /// e.g. `50 MB`
  static const int noteMaxFilesWeight = 50 * 1024 * 1024;
}

/// Environment flavor.
/// e.g. `development`, `staging`, `production`
enum EnvironmentFlavor {
  /// Development
  development('dev'),

  /// Fake
  fake('fake'),

  /// Staging
  staging('stage'),

  /// Production
  production('prod');

  /// @nodoc
  const EnvironmentFlavor(this.value);

  /// @nodoc
  factory EnvironmentFlavor.from(String? value) => switch (value?.trim().toLowerCase()) {
    'development' || 'debug' || 'develop' || 'dev' => development,
    'staging' || 'profile' || 'stage' || 'stg' => staging,
    'production' || 'release' || 'prod' || 'prd' => production,
    'fake' || 'fak' || 'fk' => fake,
    _ => const bool.fromEnvironment('dart.vm.product') ? production : development,
  };

  /// development, staging, production
  final String value;

  /// Whether the environment is development.
  bool get isDevelopment => this == .development;

  /// Whether the environment is staging.
  bool get isStaging => this == .staging;

  /// Whether the environment is fake.
  bool get isFake => this == .fake;

  /// Whether the environment is production.
  bool get isProduction => this == .production;

  @override
  String toString() => value;
}
