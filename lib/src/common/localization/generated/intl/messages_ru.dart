// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ru';

  static String m0(count) =>
      "Всего · ${Intl.plural(count, one: '${count} этап', few: '${count} этапа', other: '${count} этапов')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "appLabel": MessageLookupByLibrary.simpleMessage("Приложение"),
    "authGeneratePasswordTooltip": MessageLookupByLibrary.simpleMessage(
      "Сгенерировать пароль",
    ),
    "authLogoutConfirmationMessage": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите выйти?",
    ),
    "authValidationEmailInvalidMessage": MessageLookupByLibrary.simpleMessage(
      "Введите корректный адрес электронной почты.",
    ),
    "authValidationEmailRequiredMessage": MessageLookupByLibrary.simpleMessage(
      "Электронная почта обязательна.",
    ),
    "authValidationPasswordMissingLowercaseMessage":
        MessageLookupByLibrary.simpleMessage(
          "Пароль должен содержать хотя бы одну строчную букву.",
        ),
    "authValidationPasswordMissingUppercaseMessage":
        MessageLookupByLibrary.simpleMessage(
          "Пароль должен содержать хотя бы одну заглавную букву.",
        ),
    "authValidationPasswordRequiredMessage":
        MessageLookupByLibrary.simpleMessage("Пароль обязателен."),
    "authValidationPasswordTooLongMessage":
        MessageLookupByLibrary.simpleMessage(
          "Пароль должен содержать не более 32 символов.",
        ),
    "authValidationPasswordTooShortMessage":
        MessageLookupByLibrary.simpleMessage(
          "Пароль должен содержать не менее 8 символов.",
        ),
    "backButton": MessageLookupByLibrary.simpleMessage("Назад"),
    "bugReportAttachLogsHelpText": MessageLookupByLibrary.simpleMessage(
      "Прикреплённые логи помогают быстрее найти и исправить проблему.",
    ),
    "bugReportAttachLogsToggleLabel": MessageLookupByLibrary.simpleMessage(
      "Прикрепить логи",
    ),
    "bugReportDialogDescription": MessageLookupByLibrary.simpleMessage(
      "Опишите проблему, с которой вы столкнулись, и мы постараемся исправить её как можно скорее.",
    ),
    "bugReportDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Поделиться ошибкой",
    ),
    "bugReportShakeToReportToggleHint": MessageLookupByLibrary.simpleMessage(
      "Отключите это, если не хотите, чтобы диалог отчёта об ошибке открывался при встряхивании устройства.",
    ),
    "bugReportShakeToReportToggleLabel": MessageLookupByLibrary.simpleMessage(
      "Открывать диалог отчёта об ошибке при встряхивании",
    ),
    "cancelButton": MessageLookupByLibrary.simpleMessage("Отмена"),
    "clearButton": MessageLookupByLibrary.simpleMessage("Очистить"),
    "clearKVStorageButton": MessageLookupByLibrary.simpleMessage(
      "Очистить key-value хранилище",
    ),
    "clearLogsButton": MessageLookupByLibrary.simpleMessage("Очистить"),
    "contactSupportButton": MessageLookupByLibrary.simpleMessage(
      "Написать в поддержку",
    ),
    "copiedMessage": MessageLookupByLibrary.simpleMessage("Скопировано"),
    "copyToClipboardLabel": MessageLookupByLibrary.simpleMessage(
      "Скопировать в буфер обмена",
    ),
    "deleteButton": MessageLookupByLibrary.simpleMessage("Удалить"),
    "detailsButton": MessageLookupByLibrary.simpleMessage("Подробнее"),
    "developerAccountAndDeviceSectionTitle":
        MessageLookupByLibrary.simpleMessage("Учетная запись и устройство"),
    "developerActivityStatusOverlayDescription":
        MessageLookupByLibrary.simpleMessage(
          "Предпросмотр состояний загрузки, успеха и ошибки",
        ),
    "developerActivityStatusOverlayTitle": MessageLookupByLibrary.simpleMessage(
      "Индикатор состояния",
    ),
    "developerAdvancedOptionsHint": MessageLookupByLibrary.simpleMessage(
      "Включите или отключите доступ к режиму отладки и настройкам разработчика",
    ),
    "developerAdvancedOptionsUseBetaLabel":
        MessageLookupByLibrary.simpleMessage("Бета-версия"),
    "developerAdvancedOptionsUseDebugLabel":
        MessageLookupByLibrary.simpleMessage("Режим отладки"),
    "developerAdvancedOptionsUseDeveloperModeLabel":
        MessageLookupByLibrary.simpleMessage("Режим разработчика"),
    "developerAdvancedOptionsUseExperementalLabel":
        MessageLookupByLibrary.simpleMessage("Экспериментальные функции"),
    "developerAdvancedOptionsUseHapticFeedbackHint":
        MessageLookupByLibrary.simpleMessage(
          "Включите или отключите тактильную обратную связь (вибрацию) на поддерживаемых устройствах",
        ),
    "developerAdvancedOptionsUseHapticFeedbackLabel":
        MessageLookupByLibrary.simpleMessage("Тактильная обратная связь"),
    "developerAnalyticsDataSendingDescription":
        MessageLookupByLibrary.simpleMessage(
          "Отправлять события использования приложения",
        ),
    "developerAnalyticsDataSendingLabel": MessageLookupByLibrary.simpleMessage(
      "Отправка аналитики",
    ),
    "developerAppMetadataDescription": MessageLookupByLibrary.simpleMessage(
      "Сведения о среде выполнения и сборке для отладки и поддержки",
    ),
    "developerAppMetadataTitle": MessageLookupByLibrary.simpleMessage(
      "Метаданные приложения",
    ),
    "developerAppVersionLabel": MessageLookupByLibrary.simpleMessage(
      "Версия приложения",
    ),
    "developerApplicationInfoOpenDescription":
        MessageLookupByLibrary.simpleMessage(
          "Показать информацию о приложении.",
        ),
    "developerApplicationInfoTitle": MessageLookupByLibrary.simpleMessage(
      "Информация о приложении",
    ),
    "developerApplicationSectionTitle": MessageLookupByLibrary.simpleMessage(
      "Приложение",
    ),
    "developerBugReportDialogDescription": MessageLookupByLibrary.simpleMessage(
      "Показать диалог отчета об ошибке",
    ),
    "developerClearKVStorageButton": MessageLookupByLibrary.simpleMessage(
      "Очистить локальную базу данных",
    ),
    "developerClearKVStorageHint": MessageLookupByLibrary.simpleMessage(
      "Очистите локальную базу данных, это не повлияет на основной функционал приложения",
    ),
    "developerClearLogsButton": MessageLookupByLibrary.simpleMessage(
      "Очистить",
    ),
    "developerConfirmationDialogDescription":
        MessageLookupByLibrary.simpleMessage(
          "Показать подтверждение несохраненных изменений",
        ),
    "developerConfirmationDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Диалог подтверждения",
    ),
    "developerDarkModeDescription": MessageLookupByLibrary.simpleMessage(
      "Переключение между светлой и темной темой",
    ),
    "developerDarkModeLabel": MessageLookupByLibrary.simpleMessage(
      "Темная тема",
    ),
    "developerDatabaseClearFailureMessage":
        MessageLookupByLibrary.simpleMessage("Не удалось очистить базу данных"),
    "developerDatabaseClearSuccessMessage":
        MessageLookupByLibrary.simpleMessage("База данных очищена"),
    "developerDatabaseDropDescription": MessageLookupByLibrary.simpleMessage(
      "Очистить содержимое базы данных.",
    ),
    "developerDatabaseDropTitle": MessageLookupByLibrary.simpleMessage(
      "Очистить базу данных",
    ),
    "developerDatabaseOpenDescription": MessageLookupByLibrary.simpleMessage(
      "Показать содержимое базы данных.",
    ),
    "developerDatabaseOpenTitle": MessageLookupByLibrary.simpleMessage(
      "Открыть базу данных",
    ),
    "developerDependenciesOpenDescription":
        MessageLookupByLibrary.simpleMessage("Показать зависимости."),
    "developerDependenciesTitle": MessageLookupByLibrary.simpleMessage(
      "Зависимости",
    ),
    "developerDevDependenciesOpenDescription":
        MessageLookupByLibrary.simpleMessage(
          "Показать зависимости для разработки.",
        ),
    "developerDevDependenciesTitle": MessageLookupByLibrary.simpleMessage(
      "Dev-зависимости",
    ),
    "developerDeveloperInfoButton": MessageLookupByLibrary.simpleMessage(
      "Информация для разработчиков",
    ),
    "developerDeveloperModeToggleLabel": MessageLookupByLibrary.simpleMessage(
      "Использовать режим разработчика",
    ),
    "developerErrorPreviewLabel": MessageLookupByLibrary.simpleMessage(
      "Ошибка",
    ),
    "developerExperimentalHint": MessageLookupByLibrary.simpleMessage(
      "Включите или отключите доступ к экспериментальным функциям и бета версии приложения",
    ),
    "developerFcmPushTokenDescription": MessageLookupByLibrary.simpleMessage(
      "Токен push-уведомлений",
    ),
    "developerFcmPushTokenLabel": MessageLookupByLibrary.simpleMessage(
      "FCM Push Token",
    ),
    "developerFeatureFlagsDescription": MessageLookupByLibrary.simpleMessage(
      "Расширенные опции для разработчиков. Используйте с осторожностью: они могут вызвать непредсказуемое поведение или сбои.",
    ),
    "developerHapticFeedbackDescription": MessageLookupByLibrary.simpleMessage(
      "Включить тактильную отдачу в приложении. Полезно для тестирования haptic feedback.",
    ),
    "developerHapticFeedbackToggleLabel": MessageLookupByLibrary.simpleMessage(
      "Использовать тактильную отдачу",
    ),
    "developerIOS26LiquidThemeHint": MessageLookupByLibrary.simpleMessage(
      "Стеклянное оформление панели логов. Это Flutter-эффект, а не нативный Liquid Glass.",
    ),
    "developerIOS26LiquidThemeLabel": MessageLookupByLibrary.simpleMessage(
      "Жидкая тема iOS 26",
    ),
    "developerInfoButton": MessageLookupByLibrary.simpleMessage(
      "Информация для разработчика",
    ),
    "developerInitializationHeatMapDescription":
        MessageLookupByLibrary.simpleMessage(
          "Цвет сектора показывает скорость: синий — самые быстрые этапы, красный — самые медленные.",
        ),
    "developerInitializationStatsDescription":
        MessageLookupByLibrary.simpleMessage(
          "Длительность каждого этапа запуска",
        ),
    "developerInitializationStatsEmptyDescription":
        MessageLookupByLibrary.simpleMessage(
          "Данные о времени появятся после запуска приложения с замером.",
        ),
    "developerInitializationStatsEmptyTitle":
        MessageLookupByLibrary.simpleMessage("Нет данных инициализации"),
    "developerInitializationStatsTitle": MessageLookupByLibrary.simpleMessage(
      "Статистика инициализации",
    ),
    "developerInitializationStatsTotalMessageOf": m0,
    "developerLogoutButton": MessageLookupByLibrary.simpleMessage("Выйти"),
    "developerLogoutHint": MessageLookupByLibrary.simpleMessage(
      "Выйти из текущей сессии приложения.",
    ),
    "developerLogoutSubtitle": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите выйти со всех устройств?",
    ),
    "developerLogsEmptyLabel": MessageLookupByLibrary.simpleMessage(
      "Нет логов",
    ),
    "developerLogsEmptyStateMessage": MessageLookupByLibrary.simpleMessage(
      "Логов пока нет",
    ),
    "developerLogsLabel": MessageLookupByLibrary.simpleMessage("Логи"),
    "developerLogsOpenDescription": MessageLookupByLibrary.simpleMessage(
      "Показать логи.",
    ),
    "developerLogsShareDescription": MessageLookupByLibrary.simpleMessage(
      "Поделиться логами приложения для более удобной поддержки",
    ),
    "developerLogsTitle": MessageLookupByLibrary.simpleMessage("Логи"),
    "developerMetadataApiURLLabel": MessageLookupByLibrary.simpleMessage(
      "URL API",
    ),
    "developerMetadataBuildModeDebugLabel":
        MessageLookupByLibrary.simpleMessage("Отладка"),
    "developerMetadataBuildModeLabel": MessageLookupByLibrary.simpleMessage(
      "Режим сборки",
    ),
    "developerMetadataBuildModeReleaseLabel":
        MessageLookupByLibrary.simpleMessage("Релиз"),
    "developerMetadataBuildTimestampLabel":
        MessageLookupByLibrary.simpleMessage("Время сборки"),
    "developerMetadataCPULabel": MessageLookupByLibrary.simpleMessage(
      "Процессоры",
    ),
    "developerMetadataCurrentLocaleLabel": MessageLookupByLibrary.simpleMessage(
      "Текущая локаль",
    ),
    "developerMetadataDevicePixelRatioLabel":
        MessageLookupByLibrary.simpleMessage("Коэффициент пикселей устройства"),
    "developerMetadataDeviceScreenSizeLabel":
        MessageLookupByLibrary.simpleMessage("Размер экрана устройства"),
    "developerMetadataDisplayFeaturesLabel":
        MessageLookupByLibrary.simpleMessage("Особенности дисплея"),
    "developerMetadataDisplaysLabel": MessageLookupByLibrary.simpleMessage(
      "Дисплеи",
    ),
    "developerMetadataEnvironmentLabel": MessageLookupByLibrary.simpleMessage(
      "Окружение",
    ),
    "developerMetadataGoogleMobileServicesLabel":
        MessageLookupByLibrary.simpleMessage("Google Mobile Services"),
    "developerMetadataHuaweiMobileServicesLabel":
        MessageLookupByLibrary.simpleMessage("Huawei Mobile Services"),
    "developerMetadataLaunchedTimestampLabel":
        MessageLookupByLibrary.simpleMessage("Время запуска"),
    "developerMetadataLogicalSizeLabel": MessageLookupByLibrary.simpleMessage(
      "Логический размер",
    ),
    "developerMetadataOperationSystemLabel":
        MessageLookupByLibrary.simpleMessage("Операционная система"),
    "developerMetadataOperationSystemManufacturerLabel":
        MessageLookupByLibrary.simpleMessage(
          "Производитель операционной системы",
        ),
    "developerMetadataPaddingLabel": MessageLookupByLibrary.simpleMessage(
      "Отступы",
    ),
    "developerMetadataPhysicalSizeLabel": MessageLookupByLibrary.simpleMessage(
      "Физический размер",
    ),
    "developerMetadataPlatformBrightnessLabel":
        MessageLookupByLibrary.simpleMessage("Яркость платформы"),
    "developerMetadataPlatformLocaleLabel":
        MessageLookupByLibrary.simpleMessage("Локаль платформы"),
    "developerMetadataPlatformLocalesLabel":
        MessageLookupByLibrary.simpleMessage("Локали платформы"),
    "developerMetadataPlatformVersionLabel":
        MessageLookupByLibrary.simpleMessage("Версия платформы"),
    "developerMetadataSentryLabel": MessageLookupByLibrary.simpleMessage(
      "Sentry",
    ),
    "developerMetadataSupportedLocalesLabel":
        MessageLookupByLibrary.simpleMessage("Поддерживаемые локали"),
    "developerMetadataSystemGestureInsetsLabel":
        MessageLookupByLibrary.simpleMessage("Отступы системных жестов"),
    "developerMetadataTextScaleFactorLabel":
        MessageLookupByLibrary.simpleMessage("Масштаб текста"),
    "developerMetadataViewInsetsLabel": MessageLookupByLibrary.simpleMessage(
      "Отступы представления",
    ),
    "developerMetadataYandexMetricaLabel": MessageLookupByLibrary.simpleMessage(
      "Яндекс Метрика",
    ),
    "developerNavigationResetDescription": MessageLookupByLibrary.simpleMessage(
      "Сбросить стек навигации.",
    ),
    "developerNavigationResetTitle": MessageLookupByLibrary.simpleMessage(
      "Сбросить навигацию",
    ),
    "developerNoDisplayFeaturesLabel": MessageLookupByLibrary.simpleMessage(
      "Нет",
    ),
    "developerNoTokenAvailableLabel": MessageLookupByLibrary.simpleMessage(
      "Токен недоступен",
    ),
    "developerNotificationsRefreshDescription":
        MessageLookupByLibrary.simpleMessage(
          "Обновить FCM-токен. Полезно для тестирования push-уведомлений в development-сборках.",
        ),
    "developerNotificationsRefreshTitle": MessageLookupByLibrary.simpleMessage(
      "Обновить FCM-токен",
    ),
    "developerPreviewSelectStateDescription":
        MessageLookupByLibrary.simpleMessage(
          "Выберите состояние для предпросмотра",
        ),
    "developerProcessingPreviewLabel": MessageLookupByLibrary.simpleMessage(
      "Загрузка",
    ),
    "developerSectionApplicationTitle": MessageLookupByLibrary.simpleMessage(
      "Приложение",
    ),
    "developerSectionAuthenticationTitle": MessageLookupByLibrary.simpleMessage(
      "Аутентификация",
    ),
    "developerSectionDatabaseTitle": MessageLookupByLibrary.simpleMessage(
      "База данных",
    ),
    "developerSectionNavigationTitle": MessageLookupByLibrary.simpleMessage(
      "Навигация",
    ),
    "developerSectionUsefulLinksTitle": MessageLookupByLibrary.simpleMessage(
      "Полезные ссылки",
    ),
    "developerSendLogsButton": MessageLookupByLibrary.simpleMessage(
      "Отправить логи",
    ),
    "developerSendLogsMessage": MessageLookupByLibrary.simpleMessage(
      "Отправляем логи",
    ),
    "developerSendLogsMessageError": MessageLookupByLibrary.simpleMessage(
      "Ошибка",
    ),
    "developerSendLogsMessageSuccess": MessageLookupByLibrary.simpleMessage(
      "Логи отправлены!",
    ),
    "developerSessionsLogoutAllConfirmationMessage":
        MessageLookupByLibrary.simpleMessage(
          "Вы уверены, что хотите выйти на всех устройствах?",
        ),
    "developerSessionsLogoutAllDescription":
        MessageLookupByLibrary.simpleMessage(
          "Выйти на всех устройствах. Полезно для тестирования выхода или обновления сессии на всех устройствах.",
        ),
    "developerShowLogsButton": MessageLookupByLibrary.simpleMessage(
      "Показать логи",
    ),
    "developerSnackbarErrorPreviewMessage":
        MessageLookupByLibrary.simpleMessage(
          "Демонстрационное уведомление об ошибке",
        ),
    "developerSnackbarGalleryDescription": MessageLookupByLibrary.simpleMessage(
      "Предпросмотр успешных уведомлений и уведомлений об ошибке",
    ),
    "developerSnackbarGalleryTitle": MessageLookupByLibrary.simpleMessage(
      "Галерея уведомлений",
    ),
    "developerSnackbarSuccessPreviewMessage":
        MessageLookupByLibrary.simpleMessage(
          "Демонстрационное успешное уведомление",
        ),
    "developerStorageClearDescription": MessageLookupByLibrary.simpleMessage(
      "Очистить key-value хранилище. Полезно для тестирования онбординга и промокодов.",
    ),
    "developerStorageClearSuccessMessage": MessageLookupByLibrary.simpleMessage(
      "Key-value хранилище успешно очищено",
    ),
    "developerSuccessPreviewLabel": MessageLookupByLibrary.simpleMessage(
      "Успешно",
    ),
    "developerTitle": MessageLookupByLibrary.simpleMessage("Разработчик"),
    "developerToggleBetaFeaturesLabel": MessageLookupByLibrary.simpleMessage(
      "Использовать beta-функции",
    ),
    "developerToggleDebugFeaturesLabel": MessageLookupByLibrary.simpleMessage(
      "Использовать debug-функции",
    ),
    "developerToggleExperimentalFeaturesDescription":
        MessageLookupByLibrary.simpleMessage(
          "Экспериментальные функции. Используйте с осторожностью: они могут вызвать непредсказуемое поведение или сбои.",
        ),
    "developerToggleExperimentalFeaturesLabel":
        MessageLookupByLibrary.simpleMessage(
          "Использовать экспериментальные функции",
        ),
    "developerTotalLabel": MessageLookupByLibrary.simpleMessage("Всего"),
    "developerUiFlowsSectionTitle": MessageLookupByLibrary.simpleMessage(
      "UI-сценарии",
    ),
    "developerUserAuthenticatedLabel": MessageLookupByLibrary.simpleMessage(
      "Авторизован",
    ),
    "developerUserCurrentInfoDescription": MessageLookupByLibrary.simpleMessage(
      "Информация о текущем пользователе",
    ),
    "developerUserCurrentLogoutDescription":
        MessageLookupByLibrary.simpleMessage("Выйти из текущей учётной записи"),
    "developerUserIDLabel": MessageLookupByLibrary.simpleMessage(
      "ID пользователя",
    ),
    "developerUserInformationDescription": MessageLookupByLibrary.simpleMessage(
      "Информация о текущем пользователе",
    ),
    "developerUserRefreshSessionDescription":
        MessageLookupByLibrary.simpleMessage(
          "Обновить текущую пользовательскую сессию",
        ),
    "developerUserRefreshSessionTitle": MessageLookupByLibrary.simpleMessage(
      "Обновить сессию",
    ),
    "editButton": MessageLookupByLibrary.simpleMessage("Изменить"),
    "emailLabel": MessageLookupByLibrary.simpleMessage("Электронная почта"),
    "emailPlaceholder": MessageLookupByLibrary.simpleMessage(
      "Введите электронную почту",
    ),
    "errorDetailsDialogLabel": MessageLookupByLibrary.simpleMessage(
      "Подробности ошибки",
    ),
    "errorInternalServerLabel": MessageLookupByLibrary.simpleMessage(
      "Внутренняя ошибка сервера",
    ),
    "errorLabel": MessageLookupByLibrary.simpleMessage("Ошибка"),
    "errorNotFoundLabel": MessageLookupByLibrary.simpleMessage("Не найдено"),
    "errorUnimplementedLabel": MessageLookupByLibrary.simpleMessage(
      "Не реализовано",
    ),
    "homeTitle": MessageLookupByLibrary.simpleMessage("Главная"),
    "localeCode": MessageLookupByLibrary.simpleMessage("ru"),
    "localeName": MessageLookupByLibrary.simpleMessage("Русский"),
    "logoutAllDevicesButton": MessageLookupByLibrary.simpleMessage(
      "Выйти на всех устройствах",
    ),
    "logoutButton": MessageLookupByLibrary.simpleMessage("Выйти"),
    "nameLabel": MessageLookupByLibrary.simpleMessage("Имя"),
    "ofSeparator": MessageLookupByLibrary.simpleMessage("из"),
    "passwordLabel": MessageLookupByLibrary.simpleMessage("Пароль"),
    "passwordPlaceholder": MessageLookupByLibrary.simpleMessage(
      "Введите пароль",
    ),
    "profileSettingsDescription": MessageLookupByLibrary.simpleMessage(
      "Изменить настройки",
    ),
    "profileSettingsTitle": MessageLookupByLibrary.simpleMessage("Настройки"),
    "profileTitle": MessageLookupByLibrary.simpleMessage("Профиль"),
    "selectedLabel": MessageLookupByLibrary.simpleMessage("Выбрано"),
    "sendLogsButton": MessageLookupByLibrary.simpleMessage("Отправить логи"),
    "shareErrorButton": MessageLookupByLibrary.simpleMessage(
      "Поделиться ошибкой",
    ),
    "shareErrorSuccessMessage": MessageLookupByLibrary.simpleMessage(
      "Сообщение об ошибке успешно отправлено!",
    ),
    "signInButton": MessageLookupByLibrary.simpleMessage("Войти"),
    "signUpButton": MessageLookupByLibrary.simpleMessage("Зарегистрироваться"),
    "sizeLabel": MessageLookupByLibrary.simpleMessage("Размер"),
    "statusLabel": MessageLookupByLibrary.simpleMessage("Статус"),
    "storageLabel": MessageLookupByLibrary.simpleMessage("Хранилище"),
    "submitReportButton": MessageLookupByLibrary.simpleMessage(
      "Отправить отчёт",
    ),
    "timeLabel": MessageLookupByLibrary.simpleMessage("Время"),
    "title": MessageLookupByLibrary.simpleMessage("Заголовок"),
    "typeLabel": MessageLookupByLibrary.simpleMessage("Тип"),
    "versionLabel": MessageLookupByLibrary.simpleMessage("Версия"),
  };
}
