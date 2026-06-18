// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appLocaleCode => 'ru';

  @override
  String get appLocaleName => 'Русский';

  @override
  String get appTitle => 'Заголовок';

  @override
  String get authEmailFieldLabel => 'Электронная почта';

  @override
  String get authEmailFieldHint => 'Введите электронную почту';

  @override
  String get authGeneratePasswordTooltip => 'Сгенерировать пароль';

  @override
  String get authLogoutActionLabel => 'Выйти';

  @override
  String get authLogoutConfirmationMessage => 'Вы уверены, что хотите выйти?';

  @override
  String get authPasswordFieldLabel => 'Пароль';

  @override
  String get authPasswordFieldHint => 'Введите пароль';

  @override
  String get authSignInActionLabel => 'Войти';

  @override
  String get authSignUpActionLabel => 'Зарегистрироваться';

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
  String get bugReportSubmitActionLabel => 'Отправить отчёт';

  @override
  String get commonAppLabel => 'Приложение';

  @override
  String get commonBackActionLabel => 'Назад';

  @override
  String get commonCancelActionLabel => 'Отмена';

  @override
  String get commonClearActionLabel => 'Очистить';

  @override
  String get commonCopiedMessage => 'Скопировано';

  @override
  String get commonCopyToClipboardTooltip => 'Скопировать в буфер обмена';

  @override
  String get commonDeleteActionLabel => 'Удалить';

  @override
  String get commonDetailsActionLabel => 'Подробнее';

  @override
  String get commonEditActionLabel => 'Изменить';

  @override
  String get commonNameLabel => 'Имя';

  @override
  String get commonOfSeparator => 'из';

  @override
  String get commonSelectedLabel => 'Выбрано';

  @override
  String get commonSizeLabel => 'Размер';

  @override
  String get commonStatusLabel => 'Статус';

  @override
  String get commonStorageLabel => 'Хранилище';

  @override
  String get commonTimeLabel => 'Время';

  @override
  String get commonTypeLabel => 'Тип';

  @override
  String get commonVersionLabel => 'Версия';

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
  String get developerInfoOpenActionLabel => 'Информация для разработчика';

  @override
  String get developerLogsClearActionLabel => 'Очистить';

  @override
  String get developerLogsEmptyStateMessage => 'Логов пока нет';

  @override
  String get developerLogsOpenDescription => 'Показать логи.';

  @override
  String get developerLogsShareActionLabel => 'Отправить логи';

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
  String get developerSessionsLogoutAllActionLabel => 'Выйти на всех устройствах';

  @override
  String get developerSessionsLogoutAllConfirmationMessage => 'Вы уверены, что хотите выйти на всех устройствах?';

  @override
  String get developerSessionsLogoutAllDescription => 'Выйти на всех устройствах. Полезно для тестирования выхода или обновления сессии на всех устройствах.';

  @override
  String get developerStorageClearActionLabel => 'Очистить key-value хранилище';

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
  String get errorContactSupportActionLabel => 'Написать в поддержку';

  @override
  String get errorDetailsDialogTitle => 'Подробности ошибки';

  @override
  String get errorInternalServerTitle => 'Внутренняя ошибка сервера';

  @override
  String get errorNotFoundTitle => 'Не найдено';

  @override
  String get errorShareActionLabel => 'Поделиться ошибкой';

  @override
  String get errorShareSuccessMessage => 'Сообщение об ошибке успешно отправлено!';

  @override
  String get errorTitle => 'Ошибка';

  @override
  String get errorUnimplementedTitle => 'Не реализовано';

  @override
  String get homeTitle => 'Главная';

  @override
  String get profileSettingsTitle => 'Настройки';

  @override
  String get profileSettingsDescription => 'Изменить настройки';

  @override
  String get profileTitle => 'Профиль';
}
