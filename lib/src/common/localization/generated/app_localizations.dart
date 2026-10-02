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

  /// No description provided for @localeCode.
  ///
  /// In ru, this message translates to:
  /// **'ru'**
  String get localeCode;

  /// No description provided for @localeName.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get localeName;

  /// No description provided for @title.
  ///
  /// In ru, this message translates to:
  /// **'Заголовок'**
  String get title;

  /// No description provided for @emailLabel.
  ///
  /// In ru, this message translates to:
  /// **'Электронная почта'**
  String get emailLabel;

  /// No description provided for @emailPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Введите электронную почту'**
  String get emailPlaceholder;

  /// No description provided for @authGeneratePasswordTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Сгенерировать пароль'**
  String get authGeneratePasswordTooltip;

  /// No description provided for @logoutButton.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logoutButton;

  /// No description provided for @authLogoutConfirmationMessage.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите выйти?'**
  String get authLogoutConfirmationMessage;

  /// No description provided for @passwordLabel.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get passwordLabel;

  /// No description provided for @passwordPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль'**
  String get passwordPlaceholder;

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

  /// No description provided for @authValidationEmailInvalidMessage.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректный адрес электронной почты.'**
  String get authValidationEmailInvalidMessage;

  /// No description provided for @authValidationEmailRequiredMessage.
  ///
  /// In ru, this message translates to:
  /// **'Электронная почта обязательна.'**
  String get authValidationEmailRequiredMessage;

  /// No description provided for @authValidationPasswordMissingLowercaseMessage.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен содержать хотя бы одну строчную букву.'**
  String get authValidationPasswordMissingLowercaseMessage;

  /// No description provided for @authValidationPasswordMissingUppercaseMessage.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен содержать хотя бы одну заглавную букву.'**
  String get authValidationPasswordMissingUppercaseMessage;

  /// No description provided for @authValidationPasswordRequiredMessage.
  ///
  /// In ru, this message translates to:
  /// **'Пароль обязателен.'**
  String get authValidationPasswordRequiredMessage;

  /// No description provided for @authValidationPasswordTooLongMessage.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен содержать не более 32 символов.'**
  String get authValidationPasswordTooLongMessage;

  /// No description provided for @authValidationPasswordTooShortMessage.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен содержать не менее 8 символов.'**
  String get authValidationPasswordTooShortMessage;

  /// No description provided for @bugReportAttachLogsHelpText.
  ///
  /// In ru, this message translates to:
  /// **'Прикреплённые логи помогают быстрее найти и исправить проблему.'**
  String get bugReportAttachLogsHelpText;

  /// No description provided for @bugReportAttachLogsToggleLabel.
  ///
  /// In ru, this message translates to:
  /// **'Прикрепить логи'**
  String get bugReportAttachLogsToggleLabel;

  /// No description provided for @bugReportDialogDescription.
  ///
  /// In ru, this message translates to:
  /// **'Опишите проблему, с которой вы столкнулись, и мы постараемся исправить её как можно скорее.'**
  String get bugReportDialogDescription;

  /// No description provided for @bugReportDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться ошибкой'**
  String get bugReportDialogTitle;

  /// No description provided for @bugReportShakeToReportToggleHint.
  ///
  /// In ru, this message translates to:
  /// **'Отключите это, если не хотите, чтобы диалог отчёта об ошибке открывался при встряхивании устройства.'**
  String get bugReportShakeToReportToggleHint;

  /// No description provided for @bugReportShakeToReportToggleLabel.
  ///
  /// In ru, this message translates to:
  /// **'Открывать диалог отчёта об ошибке при встряхивании'**
  String get bugReportShakeToReportToggleLabel;

  /// No description provided for @submitReportButton.
  ///
  /// In ru, this message translates to:
  /// **'Отправить отчёт'**
  String get submitReportButton;

  /// No description provided for @appLabel.
  ///
  /// In ru, this message translates to:
  /// **'Приложение'**
  String get appLabel;

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

  /// No description provided for @clearButton.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get clearButton;

  /// No description provided for @copiedMessage.
  ///
  /// In ru, this message translates to:
  /// **'Скопировано'**
  String get copiedMessage;

  /// No description provided for @copyToClipboardLabel.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать в буфер обмена'**
  String get copyToClipboardLabel;

  /// No description provided for @deleteButton.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get deleteButton;

  /// No description provided for @detailsButton.
  ///
  /// In ru, this message translates to:
  /// **'Подробнее'**
  String get detailsButton;

  /// No description provided for @editButton.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get editButton;

  /// No description provided for @nameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get nameLabel;

  /// No description provided for @selectedLabel.
  ///
  /// In ru, this message translates to:
  /// **'Выбрано'**
  String get selectedLabel;

  /// No description provided for @sizeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Размер'**
  String get sizeLabel;

  /// No description provided for @statusLabel.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get statusLabel;

  /// No description provided for @storageLabel.
  ///
  /// In ru, this message translates to:
  /// **'Хранилище'**
  String get storageLabel;

  /// No description provided for @timeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get timeLabel;

  /// No description provided for @typeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get typeLabel;

  /// No description provided for @versionLabel.
  ///
  /// In ru, this message translates to:
  /// **'Версия'**
  String get versionLabel;

  /// No description provided for @ofSeparator.
  ///
  /// In ru, this message translates to:
  /// **'из'**
  String get ofSeparator;

  /// No description provided for @developerApplicationInfoTitle.
  ///
  /// In ru, this message translates to:
  /// **'Информация о приложении'**
  String get developerApplicationInfoTitle;

  /// No description provided for @developerApplicationInfoOpenDescription.
  ///
  /// In ru, this message translates to:
  /// **'Показать информацию о приложении.'**
  String get developerApplicationInfoOpenDescription;

  /// No description provided for @developerAppVersionLabel.
  ///
  /// In ru, this message translates to:
  /// **'Версия приложения'**
  String get developerAppVersionLabel;

  /// No description provided for @developerDatabaseClearFailureMessage.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось очистить базу данных'**
  String get developerDatabaseClearFailureMessage;

  /// No description provided for @developerDatabaseClearSuccessMessage.
  ///
  /// In ru, this message translates to:
  /// **'База данных очищена'**
  String get developerDatabaseClearSuccessMessage;

  /// No description provided for @developerDatabaseDropTitle.
  ///
  /// In ru, this message translates to:
  /// **'Очистить базу данных'**
  String get developerDatabaseDropTitle;

  /// No description provided for @developerDatabaseDropDescription.
  ///
  /// In ru, this message translates to:
  /// **'Очистить содержимое базы данных.'**
  String get developerDatabaseDropDescription;

  /// No description provided for @developerDatabaseOpenTitle.
  ///
  /// In ru, this message translates to:
  /// **'Открыть базу данных'**
  String get developerDatabaseOpenTitle;

  /// No description provided for @developerDatabaseOpenDescription.
  ///
  /// In ru, this message translates to:
  /// **'Показать содержимое базы данных.'**
  String get developerDatabaseOpenDescription;

  /// No description provided for @developerDependenciesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Зависимости'**
  String get developerDependenciesTitle;

  /// No description provided for @developerDependenciesOpenDescription.
  ///
  /// In ru, this message translates to:
  /// **'Показать зависимости.'**
  String get developerDependenciesOpenDescription;

  /// No description provided for @developerDeveloperModeToggleLabel.
  ///
  /// In ru, this message translates to:
  /// **'Использовать режим разработчика'**
  String get developerDeveloperModeToggleLabel;

  /// No description provided for @developerDevDependenciesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Dev-зависимости'**
  String get developerDevDependenciesTitle;

  /// No description provided for @developerDevDependenciesOpenDescription.
  ///
  /// In ru, this message translates to:
  /// **'Показать зависимости для разработки.'**
  String get developerDevDependenciesOpenDescription;

  /// No description provided for @developerFeatureFlagsDescription.
  ///
  /// In ru, this message translates to:
  /// **'Расширенные опции для разработчиков. Используйте с осторожностью: они могут вызвать непредсказуемое поведение или сбои.'**
  String get developerFeatureFlagsDescription;

  /// No description provided for @developerHapticFeedbackDescription.
  ///
  /// In ru, this message translates to:
  /// **'Включить тактильную отдачу в приложении. Полезно для тестирования haptic feedback.'**
  String get developerHapticFeedbackDescription;

  /// No description provided for @developerHapticFeedbackToggleLabel.
  ///
  /// In ru, this message translates to:
  /// **'Использовать тактильную отдачу'**
  String get developerHapticFeedbackToggleLabel;

  /// No description provided for @developerInfoButton.
  ///
  /// In ru, this message translates to:
  /// **'Информация для разработчика'**
  String get developerInfoButton;

  /// No description provided for @clearLogsButton.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get clearLogsButton;

  /// No description provided for @developerLogsEmptyStateMessage.
  ///
  /// In ru, this message translates to:
  /// **'Логов пока нет'**
  String get developerLogsEmptyStateMessage;

  /// No description provided for @developerLogsOpenDescription.
  ///
  /// In ru, this message translates to:
  /// **'Показать логи.'**
  String get developerLogsOpenDescription;

  /// No description provided for @sendLogsButton.
  ///
  /// In ru, this message translates to:
  /// **'Отправить логи'**
  String get sendLogsButton;

  /// No description provided for @developerLogsShareDescription.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться логами приложения для более удобной поддержки'**
  String get developerLogsShareDescription;

  /// No description provided for @developerLogsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Логи'**
  String get developerLogsTitle;

  /// No description provided for @developerNavigationResetDescription.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить стек навигации.'**
  String get developerNavigationResetDescription;

  /// No description provided for @developerNavigationResetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить навигацию'**
  String get developerNavigationResetTitle;

  /// No description provided for @developerNotificationsRefreshDescription.
  ///
  /// In ru, this message translates to:
  /// **'Обновить FCM-токен. Полезно для тестирования push-уведомлений в development-сборках.'**
  String get developerNotificationsRefreshDescription;

  /// No description provided for @developerNotificationsRefreshTitle.
  ///
  /// In ru, this message translates to:
  /// **'Обновить FCM-токен'**
  String get developerNotificationsRefreshTitle;

  /// No description provided for @developerSectionApplicationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Приложение'**
  String get developerSectionApplicationTitle;

  /// No description provided for @developerSectionAuthenticationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Аутентификация'**
  String get developerSectionAuthenticationTitle;

  /// No description provided for @developerSectionDatabaseTitle.
  ///
  /// In ru, this message translates to:
  /// **'База данных'**
  String get developerSectionDatabaseTitle;

  /// No description provided for @developerSectionNavigationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Навигация'**
  String get developerSectionNavigationTitle;

  /// No description provided for @developerSectionUsefulLinksTitle.
  ///
  /// In ru, this message translates to:
  /// **'Полезные ссылки'**
  String get developerSectionUsefulLinksTitle;

  /// No description provided for @logoutAllDevicesButton.
  ///
  /// In ru, this message translates to:
  /// **'Выйти на всех устройствах'**
  String get logoutAllDevicesButton;

  /// No description provided for @developerSessionsLogoutAllConfirmationMessage.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите выйти на всех устройствах?'**
  String get developerSessionsLogoutAllConfirmationMessage;

  /// No description provided for @developerSessionsLogoutAllDescription.
  ///
  /// In ru, this message translates to:
  /// **'Выйти на всех устройствах. Полезно для тестирования выхода или обновления сессии на всех устройствах.'**
  String get developerSessionsLogoutAllDescription;

  /// No description provided for @clearKVStorageButton.
  ///
  /// In ru, this message translates to:
  /// **'Очистить key-value хранилище'**
  String get clearKVStorageButton;

  /// No description provided for @developerStorageClearDescription.
  ///
  /// In ru, this message translates to:
  /// **'Очистить key-value хранилище. Полезно для тестирования онбординга и промокодов.'**
  String get developerStorageClearDescription;

  /// No description provided for @developerStorageClearSuccessMessage.
  ///
  /// In ru, this message translates to:
  /// **'Key-value хранилище успешно очищено'**
  String get developerStorageClearSuccessMessage;

  /// No description provided for @developerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Разработчик'**
  String get developerTitle;

  /// No description provided for @developerToggleBetaFeaturesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Использовать beta-функции'**
  String get developerToggleBetaFeaturesLabel;

  /// No description provided for @developerToggleDebugFeaturesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Использовать debug-функции'**
  String get developerToggleDebugFeaturesLabel;

  /// No description provided for @developerToggleExperimentalFeaturesDescription.
  ///
  /// In ru, this message translates to:
  /// **'Экспериментальные функции. Используйте с осторожностью: они могут вызвать непредсказуемое поведение или сбои.'**
  String get developerToggleExperimentalFeaturesDescription;

  /// No description provided for @developerToggleExperimentalFeaturesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Использовать экспериментальные функции'**
  String get developerToggleExperimentalFeaturesLabel;

  /// No description provided for @developerUserAuthenticatedLabel.
  ///
  /// In ru, this message translates to:
  /// **'Авторизован'**
  String get developerUserAuthenticatedLabel;

  /// No description provided for @developerUserCurrentInfoDescription.
  ///
  /// In ru, this message translates to:
  /// **'Информация о текущем пользователе'**
  String get developerUserCurrentInfoDescription;

  /// No description provided for @developerUserCurrentLogoutDescription.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из текущей учётной записи'**
  String get developerUserCurrentLogoutDescription;

  /// No description provided for @developerUserRefreshSessionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Обновить сессию'**
  String get developerUserRefreshSessionTitle;

  /// No description provided for @developerUserRefreshSessionDescription.
  ///
  /// In ru, this message translates to:
  /// **'Обновить текущую пользовательскую сессию'**
  String get developerUserRefreshSessionDescription;

  /// No description provided for @errorLabel.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get errorLabel;

  /// No description provided for @errorNotFoundLabel.
  ///
  /// In ru, this message translates to:
  /// **'Не найдено'**
  String get errorNotFoundLabel;

  /// No description provided for @errorUnimplementedLabel.
  ///
  /// In ru, this message translates to:
  /// **'Не реализовано'**
  String get errorUnimplementedLabel;

  /// No description provided for @errorDetailsDialogLabel.
  ///
  /// In ru, this message translates to:
  /// **'Подробности ошибки'**
  String get errorDetailsDialogLabel;

  /// No description provided for @errorInternalServerLabel.
  ///
  /// In ru, this message translates to:
  /// **'Внутренняя ошибка сервера'**
  String get errorInternalServerLabel;

  /// No description provided for @contactSupportButton.
  ///
  /// In ru, this message translates to:
  /// **'Написать в поддержку'**
  String get contactSupportButton;

  /// No description provided for @shareErrorButton.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться ошибкой'**
  String get shareErrorButton;

  /// No description provided for @shareErrorSuccessMessage.
  ///
  /// In ru, this message translates to:
  /// **'Сообщение об ошибке успешно отправлено!'**
  String get shareErrorSuccessMessage;

  /// No description provided for @homeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get homeTitle;

  /// No description provided for @profileSettingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get profileSettingsTitle;

  /// No description provided for @profileSettingsDescription.
  ///
  /// In ru, this message translates to:
  /// **'Изменить настройки'**
  String get profileSettingsDescription;

  /// No description provided for @profileTitle.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profileTitle;

  /// No description provided for @developerAccountAndDeviceSectionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Учетная запись и устройство'**
  String get developerAccountAndDeviceSectionTitle;

  /// No description provided for @developerActivityStatusOverlayDescription.
  ///
  /// In ru, this message translates to:
  /// **'Предпросмотр состояний загрузки, успеха и ошибки'**
  String get developerActivityStatusOverlayDescription;

  /// No description provided for @developerActivityStatusOverlayTitle.
  ///
  /// In ru, this message translates to:
  /// **'Индикатор состояния'**
  String get developerActivityStatusOverlayTitle;

  /// No description provided for @developerAdvancedOptionsHint.
  ///
  /// In ru, this message translates to:
  /// **'Включите или отключите доступ к режиму отладки и настройкам разработчика'**
  String get developerAdvancedOptionsHint;

  /// No description provided for @developerAdvancedOptionsUseBetaLabel.
  ///
  /// In ru, this message translates to:
  /// **'Бета-версия'**
  String get developerAdvancedOptionsUseBetaLabel;

  /// No description provided for @developerAdvancedOptionsUseDebugLabel.
  ///
  /// In ru, this message translates to:
  /// **'Режим отладки'**
  String get developerAdvancedOptionsUseDebugLabel;

  /// No description provided for @developerAdvancedOptionsUseDeveloperModeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Режим разработчика'**
  String get developerAdvancedOptionsUseDeveloperModeLabel;

  /// No description provided for @developerAdvancedOptionsUseExperementalLabel.
  ///
  /// In ru, this message translates to:
  /// **'Экспериментальные функции'**
  String get developerAdvancedOptionsUseExperementalLabel;

  /// No description provided for @developerAdvancedOptionsUseHapticFeedbackHint.
  ///
  /// In ru, this message translates to:
  /// **'Включите или отключите тактильную обратную связь (вибрацию) на поддерживаемых устройствах'**
  String get developerAdvancedOptionsUseHapticFeedbackHint;

  /// No description provided for @developerAdvancedOptionsUseHapticFeedbackLabel.
  ///
  /// In ru, this message translates to:
  /// **'Тактильная обратная связь'**
  String get developerAdvancedOptionsUseHapticFeedbackLabel;

  /// No description provided for @developerAnalyticsDataSendingDescription.
  ///
  /// In ru, this message translates to:
  /// **'Отправлять события использования приложения'**
  String get developerAnalyticsDataSendingDescription;

  /// No description provided for @developerAnalyticsDataSendingLabel.
  ///
  /// In ru, this message translates to:
  /// **'Отправка аналитики'**
  String get developerAnalyticsDataSendingLabel;

  /// No description provided for @developerAppMetadataDescription.
  ///
  /// In ru, this message translates to:
  /// **'Сведения о среде выполнения и сборке для отладки и поддержки'**
  String get developerAppMetadataDescription;

  /// No description provided for @developerAppMetadataTitle.
  ///
  /// In ru, this message translates to:
  /// **'Метаданные приложения'**
  String get developerAppMetadataTitle;

  /// No description provided for @developerApplicationSectionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Приложение'**
  String get developerApplicationSectionTitle;

  /// No description provided for @developerBugReportDialogDescription.
  ///
  /// In ru, this message translates to:
  /// **'Показать диалог отчета об ошибке'**
  String get developerBugReportDialogDescription;

  /// No description provided for @developerClearKVStorageButton.
  ///
  /// In ru, this message translates to:
  /// **'Очистить локальную базу данных'**
  String get developerClearKVStorageButton;

  /// No description provided for @developerClearKVStorageHint.
  ///
  /// In ru, this message translates to:
  /// **'Очистите локальную базу данных, это не повлияет на основной функционал приложения'**
  String get developerClearKVStorageHint;

  /// No description provided for @developerClearLogsButton.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get developerClearLogsButton;

  /// No description provided for @developerConfirmationDialogDescription.
  ///
  /// In ru, this message translates to:
  /// **'Показать подтверждение несохраненных изменений'**
  String get developerConfirmationDialogDescription;

  /// No description provided for @developerConfirmationDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Диалог подтверждения'**
  String get developerConfirmationDialogTitle;

  /// No description provided for @developerDarkModeDescription.
  ///
  /// In ru, this message translates to:
  /// **'Переключение между светлой и темной темой'**
  String get developerDarkModeDescription;

  /// No description provided for @developerDarkModeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Темная тема'**
  String get developerDarkModeLabel;

  /// No description provided for @developerDeveloperInfoButton.
  ///
  /// In ru, this message translates to:
  /// **'Информация для разработчиков'**
  String get developerDeveloperInfoButton;

  /// No description provided for @developerErrorPreviewLabel.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get developerErrorPreviewLabel;

  /// No description provided for @developerExperimentalHint.
  ///
  /// In ru, this message translates to:
  /// **'Включите или отключите доступ к экспериментальным функциям и бета версии приложения'**
  String get developerExperimentalHint;

  /// No description provided for @developerFcmPushTokenDescription.
  ///
  /// In ru, this message translates to:
  /// **'Токен push-уведомлений'**
  String get developerFcmPushTokenDescription;

  /// No description provided for @developerFcmPushTokenLabel.
  ///
  /// In ru, this message translates to:
  /// **'FCM Push Token'**
  String get developerFcmPushTokenLabel;

  /// No description provided for @developerIOS26LiquidThemeHint.
  ///
  /// In ru, this message translates to:
  /// **'Стеклянное оформление панели логов. Это Flutter-эффект, а не нативный Liquid Glass.'**
  String get developerIOS26LiquidThemeHint;

  /// No description provided for @developerIOS26LiquidThemeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Жидкая тема iOS 26'**
  String get developerIOS26LiquidThemeLabel;

  /// No description provided for @developerInitializationHeatMapDescription.
  ///
  /// In ru, this message translates to:
  /// **'Цвет сектора показывает скорость: синий — самые быстрые этапы, красный — самые медленные.'**
  String get developerInitializationHeatMapDescription;

  /// No description provided for @developerInitializationStatsDescription.
  ///
  /// In ru, this message translates to:
  /// **'Длительность каждого этапа запуска'**
  String get developerInitializationStatsDescription;

  /// No description provided for @developerInitializationStatsEmptyDescription.
  ///
  /// In ru, this message translates to:
  /// **'Данные о времени появятся после запуска приложения с замером.'**
  String get developerInitializationStatsEmptyDescription;

  /// No description provided for @developerInitializationStatsEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нет данных инициализации'**
  String get developerInitializationStatsEmptyTitle;

  /// No description provided for @developerInitializationStatsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Статистика инициализации'**
  String get developerInitializationStatsTitle;

  /// No description provided for @developerInitializationStatsTotalMessageOf.
  ///
  /// In ru, this message translates to:
  /// **'Всего · {count, plural, =1{{count} этап} few{{count} этапа} other{{count} этапов}}'**
  String developerInitializationStatsTotalMessageOf(num count);

  /// No description provided for @developerLogoutButton.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get developerLogoutButton;

  /// No description provided for @developerLogoutHint.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из текущей сессии приложения.'**
  String get developerLogoutHint;

  /// No description provided for @developerLogoutSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите выйти со всех устройств?'**
  String get developerLogoutSubtitle;

  /// No description provided for @developerLogsEmptyLabel.
  ///
  /// In ru, this message translates to:
  /// **'Нет логов'**
  String get developerLogsEmptyLabel;

  /// No description provided for @developerLogsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Логи'**
  String get developerLogsLabel;

  /// No description provided for @developerMetadataApiURLLabel.
  ///
  /// In ru, this message translates to:
  /// **'URL API'**
  String get developerMetadataApiURLLabel;

  /// No description provided for @developerMetadataBuildModeDebugLabel.
  ///
  /// In ru, this message translates to:
  /// **'Отладка'**
  String get developerMetadataBuildModeDebugLabel;

  /// No description provided for @developerMetadataBuildModeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Режим сборки'**
  String get developerMetadataBuildModeLabel;

  /// No description provided for @developerMetadataBuildModeReleaseLabel.
  ///
  /// In ru, this message translates to:
  /// **'Релиз'**
  String get developerMetadataBuildModeReleaseLabel;

  /// No description provided for @developerMetadataBuildTimestampLabel.
  ///
  /// In ru, this message translates to:
  /// **'Время сборки'**
  String get developerMetadataBuildTimestampLabel;

  /// No description provided for @developerMetadataCPULabel.
  ///
  /// In ru, this message translates to:
  /// **'Процессоры'**
  String get developerMetadataCPULabel;

  /// No description provided for @developerMetadataCurrentLocaleLabel.
  ///
  /// In ru, this message translates to:
  /// **'Текущая локаль'**
  String get developerMetadataCurrentLocaleLabel;

  /// No description provided for @developerMetadataDevicePixelRatioLabel.
  ///
  /// In ru, this message translates to:
  /// **'Коэффициент пикселей устройства'**
  String get developerMetadataDevicePixelRatioLabel;

  /// No description provided for @developerMetadataDeviceScreenSizeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Размер экрана устройства'**
  String get developerMetadataDeviceScreenSizeLabel;

  /// No description provided for @developerMetadataDisplayFeaturesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Особенности дисплея'**
  String get developerMetadataDisplayFeaturesLabel;

  /// No description provided for @developerMetadataDisplaysLabel.
  ///
  /// In ru, this message translates to:
  /// **'Дисплеи'**
  String get developerMetadataDisplaysLabel;

  /// No description provided for @developerMetadataEnvironmentLabel.
  ///
  /// In ru, this message translates to:
  /// **'Окружение'**
  String get developerMetadataEnvironmentLabel;

  /// No description provided for @developerMetadataGoogleMobileServicesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Google Mobile Services'**
  String get developerMetadataGoogleMobileServicesLabel;

  /// No description provided for @developerMetadataHuaweiMobileServicesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Huawei Mobile Services'**
  String get developerMetadataHuaweiMobileServicesLabel;

  /// No description provided for @developerMetadataLaunchedTimestampLabel.
  ///
  /// In ru, this message translates to:
  /// **'Время запуска'**
  String get developerMetadataLaunchedTimestampLabel;

  /// No description provided for @developerMetadataLogicalSizeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Логический размер'**
  String get developerMetadataLogicalSizeLabel;

  /// No description provided for @developerMetadataOperationSystemLabel.
  ///
  /// In ru, this message translates to:
  /// **'Операционная система'**
  String get developerMetadataOperationSystemLabel;

  /// No description provided for @developerMetadataOperationSystemManufacturerLabel.
  ///
  /// In ru, this message translates to:
  /// **'Производитель операционной системы'**
  String get developerMetadataOperationSystemManufacturerLabel;

  /// No description provided for @developerMetadataPaddingLabel.
  ///
  /// In ru, this message translates to:
  /// **'Отступы'**
  String get developerMetadataPaddingLabel;

  /// No description provided for @developerMetadataPhysicalSizeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Физический размер'**
  String get developerMetadataPhysicalSizeLabel;

  /// No description provided for @developerMetadataPlatformBrightnessLabel.
  ///
  /// In ru, this message translates to:
  /// **'Яркость платформы'**
  String get developerMetadataPlatformBrightnessLabel;

  /// No description provided for @developerMetadataPlatformLocaleLabel.
  ///
  /// In ru, this message translates to:
  /// **'Локаль платформы'**
  String get developerMetadataPlatformLocaleLabel;

  /// No description provided for @developerMetadataPlatformLocalesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Локали платформы'**
  String get developerMetadataPlatformLocalesLabel;

  /// No description provided for @developerMetadataPlatformVersionLabel.
  ///
  /// In ru, this message translates to:
  /// **'Версия платформы'**
  String get developerMetadataPlatformVersionLabel;

  /// No description provided for @developerMetadataSentryLabel.
  ///
  /// In ru, this message translates to:
  /// **'Sentry'**
  String get developerMetadataSentryLabel;

  /// No description provided for @developerMetadataSupportedLocalesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Поддерживаемые локали'**
  String get developerMetadataSupportedLocalesLabel;

  /// No description provided for @developerMetadataSystemGestureInsetsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Отступы системных жестов'**
  String get developerMetadataSystemGestureInsetsLabel;

  /// No description provided for @developerMetadataTextScaleFactorLabel.
  ///
  /// In ru, this message translates to:
  /// **'Масштаб текста'**
  String get developerMetadataTextScaleFactorLabel;

  /// No description provided for @developerMetadataViewInsetsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Отступы представления'**
  String get developerMetadataViewInsetsLabel;

  /// No description provided for @developerMetadataYandexMetricaLabel.
  ///
  /// In ru, this message translates to:
  /// **'Яндекс Метрика'**
  String get developerMetadataYandexMetricaLabel;

  /// No description provided for @developerNoDisplayFeaturesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get developerNoDisplayFeaturesLabel;

  /// No description provided for @developerNoTokenAvailableLabel.
  ///
  /// In ru, this message translates to:
  /// **'Токен недоступен'**
  String get developerNoTokenAvailableLabel;

  /// No description provided for @developerPreviewSelectStateDescription.
  ///
  /// In ru, this message translates to:
  /// **'Выберите состояние для предпросмотра'**
  String get developerPreviewSelectStateDescription;

  /// No description provided for @developerProcessingPreviewLabel.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка'**
  String get developerProcessingPreviewLabel;

  /// No description provided for @developerSendLogsButton.
  ///
  /// In ru, this message translates to:
  /// **'Отправить логи'**
  String get developerSendLogsButton;

  /// No description provided for @developerSendLogsMessage.
  ///
  /// In ru, this message translates to:
  /// **'Отправляем логи'**
  String get developerSendLogsMessage;

  /// No description provided for @developerSendLogsMessageError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get developerSendLogsMessageError;

  /// No description provided for @developerSendLogsMessageSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Логи отправлены!'**
  String get developerSendLogsMessageSuccess;

  /// No description provided for @developerShowLogsButton.
  ///
  /// In ru, this message translates to:
  /// **'Показать логи'**
  String get developerShowLogsButton;

  /// No description provided for @developerSnackbarErrorPreviewMessage.
  ///
  /// In ru, this message translates to:
  /// **'Демонстрационное уведомление об ошибке'**
  String get developerSnackbarErrorPreviewMessage;

  /// No description provided for @developerSnackbarGalleryDescription.
  ///
  /// In ru, this message translates to:
  /// **'Предпросмотр успешных уведомлений и уведомлений об ошибке'**
  String get developerSnackbarGalleryDescription;

  /// No description provided for @developerSnackbarGalleryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Галерея уведомлений'**
  String get developerSnackbarGalleryTitle;

  /// No description provided for @developerSnackbarSuccessPreviewMessage.
  ///
  /// In ru, this message translates to:
  /// **'Демонстрационное успешное уведомление'**
  String get developerSnackbarSuccessPreviewMessage;

  /// No description provided for @developerSuccessPreviewLabel.
  ///
  /// In ru, this message translates to:
  /// **'Успешно'**
  String get developerSuccessPreviewLabel;

  /// No description provided for @developerTotalLabel.
  ///
  /// In ru, this message translates to:
  /// **'Всего'**
  String get developerTotalLabel;

  /// No description provided for @developerUiFlowsSectionTitle.
  ///
  /// In ru, this message translates to:
  /// **'UI-сценарии'**
  String get developerUiFlowsSectionTitle;

  /// No description provided for @developerUserIDLabel.
  ///
  /// In ru, this message translates to:
  /// **'ID пользователя'**
  String get developerUserIDLabel;

  /// No description provided for @developerUserInformationDescription.
  ///
  /// In ru, this message translates to:
  /// **'Информация о текущем пользователе'**
  String get developerUserInformationDescription;
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
