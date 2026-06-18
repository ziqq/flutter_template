import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @languageCode.
  ///
  /// In ru, this message translates to:
  /// **'ru'**
  String get languageCode;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get language;

  /// No description provided for @title.
  ///
  /// In ru, this message translates to:
  /// **'Заголовок'**
  String get title;

  /// No description provided for @settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profile;

  /// No description provided for @home.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get home;

  /// No description provided for @error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get error;

  /// No description provided for @errorDetailsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подробности ошибки'**
  String get errorDetailsTitle;

  /// No description provided for @notFound.
  ///
  /// In ru, this message translates to:
  /// **'Не найдено'**
  String get notFound;

  /// No description provided for @unimplemented.
  ///
  /// In ru, this message translates to:
  /// **'Не реализовано'**
  String get unimplemented;

  /// No description provided for @internalServerError.
  ///
  /// In ru, this message translates to:
  /// **'Внутренняя ошибка сервера'**
  String get internalServerError;

  /// No description provided for @emailHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите электронную почту'**
  String get emailHint;

  /// No description provided for @emailRequiredError.
  ///
  /// In ru, this message translates to:
  /// **'Электронная почта обязательна.'**
  String get emailRequiredError;

  /// No description provided for @emailInvalidError.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректный адрес электронной почты.'**
  String get emailInvalidError;

  /// No description provided for @passwordRequiredError.
  ///
  /// In ru, this message translates to:
  /// **'Пароль обязателен.'**
  String get passwordRequiredError;

  /// No description provided for @passwordMinLengthError.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен содержать не менее 8 символов.'**
  String get passwordMinLengthError;

  /// No description provided for @passwordMaxLengthError.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен содержать не более 32 символов.'**
  String get passwordMaxLengthError;

  /// No description provided for @passwordUppercaseError.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен содержать хотя бы одну заглавную букву.'**
  String get passwordUppercaseError;

  /// No description provided for @passwordLowercaseError.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен содержать хотя бы одну строчную букву.'**
  String get passwordLowercaseError;

  /// No description provided for @logOutButton.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logOutButton;

  /// No description provided for @signInButton.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get signInButton;

  /// No description provided for @signUpButton.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get signUpButton;

  /// No description provided for @backButton.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get backButton;

  /// No description provided for @cancelButton.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancelButton;

  /// No description provided for @deleteButton.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get deleteButton;

  /// No description provided for @editButton.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get editButton;

  /// No description provided for @detailsButton.
  ///
  /// In ru, this message translates to:
  /// **'Подробнее'**
  String get detailsButton;

  /// No description provided for @contactSupportButton.
  ///
  /// In ru, this message translates to:
  /// **'Написать в поддержку'**
  String get contactSupportButton;

  /// No description provided for @shareErrorSuccessMessage.
  ///
  /// In ru, this message translates to:
  /// **'Сообщение об ошибке успешно отправлено!'**
  String get shareErrorSuccessMessage;

  /// No description provided for @shareErrorButton.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться ошибкой'**
  String get shareErrorButton;

  /// No description provided for @sendReportButton.
  ///
  /// In ru, this message translates to:
  /// **'Отправить отчёт'**
  String get sendReportButton;

  /// No description provided for @attachLogsButton.
  ///
  /// In ru, this message translates to:
  /// **'Прикрепить логи'**
  String get attachLogsButton;

  /// No description provided for @email.
  ///
  /// In ru, this message translates to:
  /// **'Электронная почта'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get password;

  /// No description provided for @name.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get name;

  /// No description provided for @app.
  ///
  /// In ru, this message translates to:
  /// **'Приложение'**
  String get app;

  /// No description provided for @authenticated.
  ///
  /// In ru, this message translates to:
  /// **'Авторизован'**
  String get authenticated;

  /// No description provided for @authentication.
  ///
  /// In ru, this message translates to:
  /// **'Аутентификация'**
  String get authentication;

  /// No description provided for @database.
  ///
  /// In ru, this message translates to:
  /// **'База данных'**
  String get database;

  /// No description provided for @version.
  ///
  /// In ru, this message translates to:
  /// **'Версия'**
  String get version;

  /// No description provided for @status.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get status;

  /// No description provided for @size.
  ///
  /// In ru, this message translates to:
  /// **'Размер'**
  String get size;

  /// No description provided for @time.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get time;

  /// No description provided for @type.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get type;

  /// No description provided for @storage.
  ///
  /// In ru, this message translates to:
  /// **'Хранилище'**
  String get storage;

  /// No description provided for @selected.
  ///
  /// In ru, this message translates to:
  /// **'Выбрано'**
  String get selected;

  /// No description provided for @generatePasswordTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Сгенерировать пароль'**
  String get generatePasswordTooltip;

  /// No description provided for @enterPasswordHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль'**
  String get enterPasswordHint;

  /// No description provided for @logoutConfirmation.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите выйти?'**
  String get logoutConfirmation;

  /// No description provided for @copyToClipboardTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать в буфер обмена'**
  String get copyToClipboardTooltip;

  /// No description provided for @settingsDescription.
  ///
  /// In ru, this message translates to:
  /// **'Изменить настройки'**
  String get settingsDescription;

  /// No description provided for @developer.
  ///
  /// In ru, this message translates to:
  /// **'Разработчик'**
  String get developer;

  /// No description provided for @application.
  ///
  /// In ru, this message translates to:
  /// **'Приложение'**
  String get application;

  /// No description provided for @navigation.
  ///
  /// In ru, this message translates to:
  /// **'Навигация'**
  String get navigation;

  /// No description provided for @usefulLinks.
  ///
  /// In ru, this message translates to:
  /// **'Полезные ссылки'**
  String get usefulLinks;

  /// No description provided for @appVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия приложения'**
  String get appVersion;

  /// No description provided for @copied.
  ///
  /// In ru, this message translates to:
  /// **'Скопировано'**
  String get copied;

  /// No description provided for @databaseClearedMessage.
  ///
  /// In ru, this message translates to:
  /// **'База данных очищена'**
  String get databaseClearedMessage;

  /// No description provided for @databaseClearFailedMessage.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось очистить базу данных'**
  String get databaseClearFailedMessage;

  /// No description provided for @applicationInformation.
  ///
  /// In ru, this message translates to:
  /// **'Информация о приложении'**
  String get applicationInformation;

  /// No description provided for @showApplicationInformation.
  ///
  /// In ru, this message translates to:
  /// **'Показать информацию о приложении.'**
  String get showApplicationInformation;

  /// No description provided for @dependencies.
  ///
  /// In ru, this message translates to:
  /// **'Зависимости'**
  String get dependencies;

  /// No description provided for @showDependencies.
  ///
  /// In ru, this message translates to:
  /// **'Показать зависимости.'**
  String get showDependencies;

  /// No description provided for @devDependencies.
  ///
  /// In ru, this message translates to:
  /// **'Dev-зависимости'**
  String get devDependencies;

  /// No description provided for @showDevDependencies.
  ///
  /// In ru, this message translates to:
  /// **'Показать зависимости для разработки.'**
  String get showDevDependencies;

  /// No description provided for @logs.
  ///
  /// In ru, this message translates to:
  /// **'Логи'**
  String get logs;

  /// No description provided for @showLogs.
  ///
  /// In ru, this message translates to:
  /// **'Показать логи.'**
  String get showLogs;

  /// No description provided for @clearButton.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get clearButton;

  /// No description provided for @noLogsYet.
  ///
  /// In ru, this message translates to:
  /// **'Логов пока нет'**
  String get noLogsYet;

  /// No description provided for @shareErrorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться ошибкой'**
  String get shareErrorTitle;

  /// No description provided for @shareErrorDescription.
  ///
  /// In ru, this message translates to:
  /// **'Опишите проблему, с которой вы столкнулись, и мы постараемся исправить её как можно скорее.'**
  String get shareErrorDescription;

  /// No description provided for @attachLogsDescription.
  ///
  /// In ru, this message translates to:
  /// **'Прикреплённые логи помогают быстрее найти и исправить проблему.'**
  String get attachLogsDescription;

  /// No description provided for @shareErrorOnShakeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Открывать диалог отчёта об ошибке при встряхивании'**
  String get shareErrorOnShakeLabel;

  /// No description provided for @shareErrorOnShakeHint.
  ///
  /// In ru, this message translates to:
  /// **'Отключите это, если не хотите, чтобы диалог отчёта об ошибке открывался при встряхивании устройства.'**
  String get shareErrorOnShakeHint;

  /// No description provided for @resetNavigation.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить навигацию'**
  String get resetNavigation;

  /// No description provided for @resetNavigationDescription.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить стек навигации.'**
  String get resetNavigationDescription;

  /// No description provided for @viewDatabase.
  ///
  /// In ru, this message translates to:
  /// **'Открыть базу данных'**
  String get viewDatabase;

  /// No description provided for @viewDatabaseDescription.
  ///
  /// In ru, this message translates to:
  /// **'Показать содержимое базы данных.'**
  String get viewDatabaseDescription;

  /// No description provided for @dropDatabase.
  ///
  /// In ru, this message translates to:
  /// **'Очистить базу данных'**
  String get dropDatabase;

  /// No description provided for @dropDatabaseDescription.
  ///
  /// In ru, this message translates to:
  /// **'Очистить содержимое базы данных.'**
  String get dropDatabaseDescription;

  /// No description provided for @currentUserInformation.
  ///
  /// In ru, this message translates to:
  /// **'Информация о текущем пользователе'**
  String get currentUserInformation;

  /// No description provided for @refreshSession.
  ///
  /// In ru, this message translates to:
  /// **'Обновить сессию'**
  String get refreshSession;

  /// No description provided for @refreshSessionDescription.
  ///
  /// In ru, this message translates to:
  /// **'Обновить текущую пользовательскую сессию'**
  String get refreshSessionDescription;

  /// No description provided for @logOutCurrentUser.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из текущей учётной записи'**
  String get logOutCurrentUser;

  /// No description provided for @advancedOptionsDescription.
  ///
  /// In ru, this message translates to:
  /// **'Расширенные опции для разработчиков. Используйте с осторожностью: они могут вызвать непредсказуемое поведение или сбои.'**
  String get advancedOptionsDescription;

  /// No description provided for @useDebugFeatures.
  ///
  /// In ru, this message translates to:
  /// **'Использовать debug-функции'**
  String get useDebugFeatures;

  /// No description provided for @useDeveloperMode.
  ///
  /// In ru, this message translates to:
  /// **'Использовать режим разработчика'**
  String get useDeveloperMode;

  /// No description provided for @developerInfoButton.
  ///
  /// In ru, this message translates to:
  /// **'Информация для разработчика'**
  String get developerInfoButton;

  /// No description provided for @experimentalFeaturesDescription.
  ///
  /// In ru, this message translates to:
  /// **'Экспериментальные функции. Используйте с осторожностью: они могут вызвать непредсказуемое поведение или сбои.'**
  String get experimentalFeaturesDescription;

  /// No description provided for @useBetaFeatures.
  ///
  /// In ru, this message translates to:
  /// **'Использовать beta-функции'**
  String get useBetaFeatures;

  /// No description provided for @useExperimentalFeatures.
  ///
  /// In ru, this message translates to:
  /// **'Использовать экспериментальные функции'**
  String get useExperimentalFeatures;

  /// No description provided for @hapticFeedbackDescription.
  ///
  /// In ru, this message translates to:
  /// **'Включить тактильную отдачу в приложении. Полезно для тестирования haptic feedback.'**
  String get hapticFeedbackDescription;

  /// No description provided for @useHapticFeedback.
  ///
  /// In ru, this message translates to:
  /// **'Использовать тактильную отдачу'**
  String get useHapticFeedback;

  /// No description provided for @clearKeyValueStorageDescription.
  ///
  /// In ru, this message translates to:
  /// **'Очистить key-value хранилище. Полезно для тестирования онбординга и промокодов.'**
  String get clearKeyValueStorageDescription;

  /// No description provided for @clearKeyValueStorageButton.
  ///
  /// In ru, this message translates to:
  /// **'Очистить key-value хранилище'**
  String get clearKeyValueStorageButton;

  /// No description provided for @clearKeyValueStorageSuccessMessage.
  ///
  /// In ru, this message translates to:
  /// **'Key-value хранилище успешно очищено'**
  String get clearKeyValueStorageSuccessMessage;

  /// No description provided for @refreshFcmTokenDescription.
  ///
  /// In ru, this message translates to:
  /// **'Обновить FCM-токен. Полезно для тестирования push-уведомлений в development-сборках.'**
  String get refreshFcmTokenDescription;

  /// No description provided for @refreshFcmTokenButton.
  ///
  /// In ru, this message translates to:
  /// **'Обновить FCM-токен'**
  String get refreshFcmTokenButton;

  /// No description provided for @shareApplicationLogsDescription.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться логами приложения для более удобной поддержки'**
  String get shareApplicationLogsDescription;

  /// No description provided for @sendLogsButton.
  ///
  /// In ru, this message translates to:
  /// **'Отправить логи'**
  String get sendLogsButton;

  /// No description provided for @logoutAllDevicesDescription.
  ///
  /// In ru, this message translates to:
  /// **'Выйти на всех устройствах. Полезно для тестирования выхода или обновления сессии на всех устройствах.'**
  String get logoutAllDevicesDescription;

  /// No description provided for @logoutAllDevicesConfirmation.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите выйти на всех устройствах?'**
  String get logoutAllDevicesConfirmation;

  /// No description provided for @logoutAllDevicesButton.
  ///
  /// In ru, this message translates to:
  /// **'Выйти на всех устройствах'**
  String get logoutAllDevicesButton;

  /// No description provided for @ofSeparator.
  ///
  /// In ru, this message translates to:
  /// **'из'**
  String get ofSeparator;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
