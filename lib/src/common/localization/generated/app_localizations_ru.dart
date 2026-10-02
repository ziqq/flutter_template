// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get localeCode => 'ru';

  @override
  String get localeName => 'Русский';

  @override
  String get title => 'Заголовок';

  @override
  String get emailLabel => 'Электронная почта';

  @override
  String get emailPlaceholder => 'Введите электронную почту';

  @override
  String get authGeneratePasswordTooltip => 'Сгенерировать пароль';

  @override
  String get logoutButton => 'Выйти';

  @override
  String get authLogoutConfirmationMessage => 'Вы уверены, что хотите выйти?';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get passwordPlaceholder => 'Введите пароль';

  @override
  String get signInButton => 'Войти';

  @override
  String get signUpButton => 'Зарегистрироваться';

  @override
  String get authValidationEmailInvalidMessage => 'Введите корректный адрес электронной почты.';

  @override
  String get authValidationEmailRequiredMessage => 'Электронная почта обязательна.';

  @override
  String get authValidationPasswordMissingLowercaseMessage => 'Пароль должен содержать хотя бы одну строчную букву.';

  @override
  String get authValidationPasswordMissingUppercaseMessage => 'Пароль должен содержать хотя бы одну заглавную букву.';

  @override
  String get authValidationPasswordRequiredMessage => 'Пароль обязателен.';

  @override
  String get authValidationPasswordTooLongMessage => 'Пароль должен содержать не более 32 символов.';

  @override
  String get authValidationPasswordTooShortMessage => 'Пароль должен содержать не менее 8 символов.';

  @override
  String get bugReportAttachLogsHelpText => 'Прикреплённые логи помогают быстрее найти и исправить проблему.';

  @override
  String get bugReportAttachLogsToggleLabel => 'Прикрепить логи';

  @override
  String get bugReportDialogDescription => 'Опишите проблему, с которой вы столкнулись, и мы постараемся исправить её как можно скорее.';

  @override
  String get bugReportDialogTitle => 'Поделиться ошибкой';

  @override
  String get bugReportShakeToReportToggleHint => 'Отключите это, если не хотите, чтобы диалог отчёта об ошибке открывался при встряхивании устройства.';

  @override
  String get bugReportShakeToReportToggleLabel => 'Открывать диалог отчёта об ошибке при встряхивании';

  @override
  String get submitReportButton => 'Отправить отчёт';

  @override
  String get appLabel => 'Приложение';

  @override
  String get backButton => 'Назад';

  @override
  String get cancelButton => 'Отмена';

  @override
  String get clearButton => 'Очистить';

  @override
  String get copiedMessage => 'Скопировано';

  @override
  String get copyToClipboardLabel => 'Скопировать в буфер обмена';

  @override
  String get deleteButton => 'Удалить';

  @override
  String get detailsButton => 'Подробнее';

  @override
  String get editButton => 'Изменить';

  @override
  String get nameLabel => 'Имя';

  @override
  String get selectedLabel => 'Выбрано';

  @override
  String get sizeLabel => 'Размер';

  @override
  String get statusLabel => 'Статус';

  @override
  String get storageLabel => 'Хранилище';

  @override
  String get timeLabel => 'Время';

  @override
  String get typeLabel => 'Тип';

  @override
  String get versionLabel => 'Версия';

  @override
  String get ofSeparator => 'из';

  @override
  String get developerApplicationInfoTitle => 'Информация о приложении';

  @override
  String get developerApplicationInfoOpenDescription => 'Показать информацию о приложении.';

  @override
  String get developerAppVersionLabel => 'Версия приложения';

  @override
  String get developerDatabaseClearFailureMessage => 'Не удалось очистить базу данных';

  @override
  String get developerDatabaseClearSuccessMessage => 'База данных очищена';

  @override
  String get developerDatabaseDropTitle => 'Очистить базу данных';

  @override
  String get developerDatabaseDropDescription => 'Очистить содержимое базы данных.';

  @override
  String get developerDatabaseOpenTitle => 'Открыть базу данных';

  @override
  String get developerDatabaseOpenDescription => 'Показать содержимое базы данных.';

  @override
  String get developerDependenciesTitle => 'Зависимости';

  @override
  String get developerDependenciesOpenDescription => 'Показать зависимости.';

  @override
  String get developerDeveloperModeToggleLabel => 'Использовать режим разработчика';

  @override
  String get developerDevDependenciesTitle => 'Dev-зависимости';

  @override
  String get developerDevDependenciesOpenDescription => 'Показать зависимости для разработки.';

  @override
  String get developerFeatureFlagsDescription => 'Расширенные опции для разработчиков. Используйте с осторожностью: они могут вызвать непредсказуемое поведение или сбои.';

  @override
  String get developerHapticFeedbackDescription => 'Включить тактильную отдачу в приложении. Полезно для тестирования haptic feedback.';

  @override
  String get developerHapticFeedbackToggleLabel => 'Использовать тактильную отдачу';

  @override
  String get developerInfoButton => 'Информация для разработчика';

  @override
  String get clearLogsButton => 'Очистить';

  @override
  String get developerLogsEmptyStateMessage => 'Логов пока нет';

  @override
  String get developerLogsOpenDescription => 'Показать логи.';

  @override
  String get sendLogsButton => 'Отправить логи';

  @override
  String get developerLogsShareDescription => 'Поделиться логами приложения для более удобной поддержки';

  @override
  String get developerLogsTitle => 'Логи';

  @override
  String get developerNavigationResetDescription => 'Сбросить стек навигации.';

  @override
  String get developerNavigationResetTitle => 'Сбросить навигацию';

  @override
  String get developerNotificationsRefreshDescription => 'Обновить FCM-токен. Полезно для тестирования push-уведомлений в development-сборках.';

  @override
  String get developerNotificationsRefreshTitle => 'Обновить FCM-токен';

  @override
  String get developerSectionApplicationTitle => 'Приложение';

  @override
  String get developerSectionAuthenticationTitle => 'Аутентификация';

  @override
  String get developerSectionDatabaseTitle => 'База данных';

  @override
  String get developerSectionNavigationTitle => 'Навигация';

  @override
  String get developerSectionUsefulLinksTitle => 'Полезные ссылки';

  @override
  String get logoutAllDevicesButton => 'Выйти на всех устройствах';

  @override
  String get developerSessionsLogoutAllConfirmationMessage => 'Вы уверены, что хотите выйти на всех устройствах?';

  @override
  String get developerSessionsLogoutAllDescription => 'Выйти на всех устройствах. Полезно для тестирования выхода или обновления сессии на всех устройствах.';

  @override
  String get clearKVStorageButton => 'Очистить key-value хранилище';

  @override
  String get developerStorageClearDescription => 'Очистить key-value хранилище. Полезно для тестирования онбординга и промокодов.';

  @override
  String get developerStorageClearSuccessMessage => 'Key-value хранилище успешно очищено';

  @override
  String get developerTitle => 'Разработчик';

  @override
  String get developerToggleBetaFeaturesLabel => 'Использовать beta-функции';

  @override
  String get developerToggleDebugFeaturesLabel => 'Использовать debug-функции';

  @override
  String get developerToggleExperimentalFeaturesDescription => 'Экспериментальные функции. Используйте с осторожностью: они могут вызвать непредсказуемое поведение или сбои.';

  @override
  String get developerToggleExperimentalFeaturesLabel => 'Использовать экспериментальные функции';

  @override
  String get developerUserAuthenticatedLabel => 'Авторизован';

  @override
  String get developerUserCurrentInfoDescription => 'Информация о текущем пользователе';

  @override
  String get developerUserCurrentLogoutDescription => 'Выйти из текущей учётной записи';

  @override
  String get developerUserRefreshSessionTitle => 'Обновить сессию';

  @override
  String get developerUserRefreshSessionDescription => 'Обновить текущую пользовательскую сессию';

  @override
  String get errorLabel => 'Ошибка';

  @override
  String get errorNotFoundLabel => 'Не найдено';

  @override
  String get errorUnimplementedLabel => 'Не реализовано';

  @override
  String get errorDetailsDialogLabel => 'Подробности ошибки';

  @override
  String get errorInternalServerLabel => 'Внутренняя ошибка сервера';

  @override
  String get contactSupportButton => 'Написать в поддержку';

  @override
  String get shareErrorButton => 'Поделиться ошибкой';

  @override
  String get shareErrorSuccessMessage => 'Сообщение об ошибке успешно отправлено!';

  @override
  String get homeTitle => 'Главная';

  @override
  String get profileSettingsTitle => 'Настройки';

  @override
  String get profileSettingsDescription => 'Изменить настройки';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get developerAccountAndDeviceSectionTitle => 'Учетная запись и устройство';

  @override
  String get developerActivityStatusOverlayDescription => 'Предпросмотр состояний загрузки, успеха и ошибки';

  @override
  String get developerActivityStatusOverlayTitle => 'Индикатор состояния';

  @override
  String get developerAdvancedOptionsHint => 'Включите или отключите доступ к режиму отладки и настройкам разработчика';

  @override
  String get developerAdvancedOptionsUseBetaLabel => 'Бета-версия';

  @override
  String get developerAdvancedOptionsUseDebugLabel => 'Режим отладки';

  @override
  String get developerAdvancedOptionsUseDeveloperModeLabel => 'Режим разработчика';

  @override
  String get developerAdvancedOptionsUseExperementalLabel => 'Экспериментальные функции';

  @override
  String get developerAdvancedOptionsUseHapticFeedbackHint => 'Включите или отключите тактильную обратную связь (вибрацию) на поддерживаемых устройствах';

  @override
  String get developerAdvancedOptionsUseHapticFeedbackLabel => 'Тактильная обратная связь';

  @override
  String get developerAnalyticsDataSendingDescription => 'Отправлять события использования приложения';

  @override
  String get developerAnalyticsDataSendingLabel => 'Отправка аналитики';

  @override
  String get developerAppMetadataDescription => 'Сведения о среде выполнения и сборке для отладки и поддержки';

  @override
  String get developerAppMetadataTitle => 'Метаданные приложения';

  @override
  String get developerApplicationSectionTitle => 'Приложение';

  @override
  String get developerBugReportDialogDescription => 'Показать диалог отчета об ошибке';

  @override
  String get developerClearKVStorageButton => 'Очистить локальную базу данных';

  @override
  String get developerClearKVStorageHint => 'Очистите локальную базу данных, это не повлияет на основной функционал приложения';

  @override
  String get developerClearLogsButton => 'Очистить';

  @override
  String get developerConfirmationDialogDescription => 'Показать подтверждение несохраненных изменений';

  @override
  String get developerConfirmationDialogTitle => 'Диалог подтверждения';

  @override
  String get developerDarkModeDescription => 'Переключение между светлой и темной темой';

  @override
  String get developerDarkModeLabel => 'Темная тема';

  @override
  String get developerDeveloperInfoButton => 'Информация для разработчиков';

  @override
  String get developerErrorPreviewLabel => 'Ошибка';

  @override
  String get developerExperimentalHint => 'Включите или отключите доступ к экспериментальным функциям и бета версии приложения';

  @override
  String get developerFcmPushTokenDescription => 'Токен push-уведомлений';

  @override
  String get developerFcmPushTokenLabel => 'FCM Push Token';

  @override
  String get developerIOS26LiquidThemeHint => 'Стеклянное оформление панели логов. Это Flutter-эффект, а не нативный Liquid Glass.';

  @override
  String get developerIOS26LiquidThemeLabel => 'Жидкая тема iOS 26';

  @override
  String get developerInitializationHeatMapDescription => 'Цвет сектора показывает скорость: синий — самые быстрые этапы, красный — самые медленные.';

  @override
  String get developerInitializationStatsDescription => 'Длительность каждого этапа запуска';

  @override
  String get developerInitializationStatsEmptyDescription => 'Данные о времени появятся после запуска приложения с замером.';

  @override
  String get developerInitializationStatsEmptyTitle => 'Нет данных инициализации';

  @override
  String get developerInitializationStatsTitle => 'Статистика инициализации';

  @override
  String developerInitializationStatsTotalMessageOf(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count этапов',
      few: '$count этапа',
      one: '$count этап',
    );
    return 'Всего · $_temp0';
  }

  @override
  String get developerLogoutButton => 'Выйти';

  @override
  String get developerLogoutHint => 'Выйти из текущей сессии приложения.';

  @override
  String get developerLogoutSubtitle => 'Вы уверены, что хотите выйти со всех устройств?';

  @override
  String get developerLogsEmptyLabel => 'Нет логов';

  @override
  String get developerLogsLabel => 'Логи';

  @override
  String get developerMetadataApiURLLabel => 'URL API';

  @override
  String get developerMetadataBuildModeDebugLabel => 'Отладка';

  @override
  String get developerMetadataBuildModeLabel => 'Режим сборки';

  @override
  String get developerMetadataBuildModeReleaseLabel => 'Релиз';

  @override
  String get developerMetadataBuildTimestampLabel => 'Время сборки';

  @override
  String get developerMetadataCPULabel => 'Процессоры';

  @override
  String get developerMetadataCurrentLocaleLabel => 'Текущая локаль';

  @override
  String get developerMetadataDevicePixelRatioLabel => 'Коэффициент пикселей устройства';

  @override
  String get developerMetadataDeviceScreenSizeLabel => 'Размер экрана устройства';

  @override
  String get developerMetadataDisplayFeaturesLabel => 'Особенности дисплея';

  @override
  String get developerMetadataDisplaysLabel => 'Дисплеи';

  @override
  String get developerMetadataEnvironmentLabel => 'Окружение';

  @override
  String get developerMetadataGoogleMobileServicesLabel => 'Google Mobile Services';

  @override
  String get developerMetadataHuaweiMobileServicesLabel => 'Huawei Mobile Services';

  @override
  String get developerMetadataLaunchedTimestampLabel => 'Время запуска';

  @override
  String get developerMetadataLogicalSizeLabel => 'Логический размер';

  @override
  String get developerMetadataOperationSystemLabel => 'Операционная система';

  @override
  String get developerMetadataOperationSystemManufacturerLabel => 'Производитель операционной системы';

  @override
  String get developerMetadataPaddingLabel => 'Отступы';

  @override
  String get developerMetadataPhysicalSizeLabel => 'Физический размер';

  @override
  String get developerMetadataPlatformBrightnessLabel => 'Яркость платформы';

  @override
  String get developerMetadataPlatformLocaleLabel => 'Локаль платформы';

  @override
  String get developerMetadataPlatformLocalesLabel => 'Локали платформы';

  @override
  String get developerMetadataPlatformVersionLabel => 'Версия платформы';

  @override
  String get developerMetadataSentryLabel => 'Sentry';

  @override
  String get developerMetadataSupportedLocalesLabel => 'Поддерживаемые локали';

  @override
  String get developerMetadataSystemGestureInsetsLabel => 'Отступы системных жестов';

  @override
  String get developerMetadataTextScaleFactorLabel => 'Масштаб текста';

  @override
  String get developerMetadataViewInsetsLabel => 'Отступы представления';

  @override
  String get developerMetadataYandexMetricaLabel => 'Яндекс Метрика';

  @override
  String get developerNoDisplayFeaturesLabel => 'Нет';

  @override
  String get developerNoTokenAvailableLabel => 'Токен недоступен';

  @override
  String get developerPreviewSelectStateDescription => 'Выберите состояние для предпросмотра';

  @override
  String get developerProcessingPreviewLabel => 'Загрузка';

  @override
  String get developerSendLogsButton => 'Отправить логи';

  @override
  String get developerSendLogsMessage => 'Отправляем логи';

  @override
  String get developerSendLogsMessageError => 'Ошибка';

  @override
  String get developerSendLogsMessageSuccess => 'Логи отправлены!';

  @override
  String get developerShowLogsButton => 'Показать логи';

  @override
  String get developerSnackbarErrorPreviewMessage => 'Демонстрационное уведомление об ошибке';

  @override
  String get developerSnackbarGalleryDescription => 'Предпросмотр успешных уведомлений и уведомлений об ошибке';

  @override
  String get developerSnackbarGalleryTitle => 'Галерея уведомлений';

  @override
  String get developerSnackbarSuccessPreviewMessage => 'Демонстрационное успешное уведомление';

  @override
  String get developerSuccessPreviewLabel => 'Успешно';

  @override
  String get developerTotalLabel => 'Всего';

  @override
  String get developerUiFlowsSectionTitle => 'UI-сценарии';

  @override
  String get developerUserIDLabel => 'ID пользователя';

  @override
  String get developerUserInformationDescription => 'Информация о текущем пользователе';
}
