// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get localeCode => 'en';

  @override
  String get localeName => 'English';

  @override
  String get title => 'Title';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailPlaceholder => 'Enter your email';

  @override
  String get authGeneratePasswordTooltip => 'Generate password';

  @override
  String get logoutButton => 'Log Out';

  @override
  String get authLogoutConfirmationMessage => 'Are you sure you want to log out?';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordPlaceholder => 'Enter your password';

  @override
  String get signInButton => 'Sign In';

  @override
  String get signUpButton => 'Sign Up';

  @override
  String get authValidationEmailInvalidMessage => 'Must be a valid email.';

  @override
  String get authValidationEmailRequiredMessage => 'Email is required.';

  @override
  String get authValidationPasswordMissingLowercaseMessage => 'Password must have at least one lowercase character.';

  @override
  String get authValidationPasswordMissingUppercaseMessage => 'Password must have at least one uppercase character.';

  @override
  String get authValidationPasswordRequiredMessage => 'Password is required.';

  @override
  String get authValidationPasswordTooLongMessage => 'Password must be 32 characters or less.';

  @override
  String get authValidationPasswordTooShortMessage => 'Password must be 8 characters or more.';

  @override
  String get bugReportAttachLogsHelpText => 'Attaching logs can help us identify and fix the issue faster.';

  @override
  String get bugReportAttachLogsToggleLabel => 'Attach logs';

  @override
  String get bugReportDialogDescription =>
      'Describe the issue you encountered and we will try to fix it as soon as possible.';

  @override
  String get bugReportDialogTitle => 'Share error';

  @override
  String get bugReportShakeToReportToggleHint =>
      'Disable this if you do not want the bug report dialog to appear when the device is shaken.';

  @override
  String get bugReportShakeToReportToggleLabel => 'Open bug report dialog on shake';

  @override
  String get submitReportButton => 'Send report';

  @override
  String get appLabel => 'App';

  @override
  String get backButton => 'Back';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get clearButton => 'Clear';

  @override
  String get copiedMessage => 'Copied';

  @override
  String get copyToClipboardLabel => 'Copy to clipboard';

  @override
  String get deleteButton => 'Delete';

  @override
  String get detailsButton => 'Details';

  @override
  String get editButton => 'Edit';

  @override
  String get nameLabel => 'Name';

  @override
  String get ofSeparator => 'of';

  @override
  String get selectedLabel => 'Selected';

  @override
  String get sizeLabel => 'Size';

  @override
  String get statusLabel => 'Status';

  @override
  String get storageLabel => 'Storage';

  @override
  String get timeLabel => 'Time';

  @override
  String get typeLabel => 'Type';

  @override
  String get versionLabel => 'Version';

  @override
  String get developerApplicationInfoTitle => 'Application information';

  @override
  String get developerApplicationInfoOpenDescription => 'Show information about the application.';

  @override
  String get developerAppVersionLabel => 'App version';

  @override
  String get developerDatabaseClearFailureMessage => 'Database clear failed';

  @override
  String get developerDatabaseClearSuccessMessage => 'Database cleared';

  @override
  String get developerDatabaseDropTitle => 'Drop database';

  @override
  String get developerDatabaseDropDescription => 'Clear database content.';

  @override
  String get developerDatabaseOpenTitle => 'View database';

  @override
  String get developerDatabaseOpenDescription => 'View database content.';

  @override
  String get developerDependenciesTitle => 'Dependencies';

  @override
  String get developerDependenciesOpenDescription => 'Show dependencies.';

  @override
  String get developerDeveloperModeToggleLabel => 'Use developer mode';

  @override
  String get developerDevDependenciesTitle => 'Dev dependencies';

  @override
  String get developerDevDependenciesOpenDescription => 'Show developers dependencies.';

  @override
  String get developerFeatureFlagsDescription =>
      'Advanced options for developers. Use with caution, as they may cause unexpected behavior or crashes.';

  @override
  String get developerHapticFeedbackDescription =>
      'Enable haptic feedback in the app. Useful for testing haptic feedback functionality.';

  @override
  String get developerHapticFeedbackToggleLabel => 'Use haptic feedback';

  @override
  String get developerInfoButton => 'Developer info';

  @override
  String get clearLogsButton => 'Clear';

  @override
  String get developerLogsEmptyStateMessage => 'No logs yet';

  @override
  String get developerLogsOpenDescription => 'Show logs.';

  @override
  String get sendLogsButton => 'Send logs';

  @override
  String get developerLogsShareDescription => 'Share application logs for better support';

  @override
  String get developerLogsTitle => 'Logs';

  @override
  String get developerNavigationResetDescription => 'Reset navigation stack.';

  @override
  String get developerNavigationResetTitle => 'Reset navigation';

  @override
  String get developerNotificationsRefreshDescription =>
      'Refresh FCM token. Useful for testing push notifications in development builds.';

  @override
  String get developerNotificationsRefreshTitle => 'Refresh FCM token';

  @override
  String get developerSectionApplicationTitle => 'Application';

  @override
  String get developerSectionAuthenticationTitle => 'Authentication';

  @override
  String get developerSectionDatabaseTitle => 'Database';

  @override
  String get developerSectionNavigationTitle => 'Navigation';

  @override
  String get developerSectionUsefulLinksTitle => 'Useful links';

  @override
  String get logoutAllDevicesButton => 'Log out from all devices';

  @override
  String get developerSessionsLogoutAllConfirmationMessage => 'Are you sure you want to log out from all devices?';

  @override
  String get developerSessionsLogoutAllDescription =>
      'Log out from all devices. Useful for testing logout functionality or refreshing session on all devices.';

  @override
  String get clearKVStorageButton => 'Clear key-value storage';

  @override
  String get developerStorageClearDescription =>
      'Clear key-value storage. Useful for testing onboarding and promo code flows.';

  @override
  String get developerStorageClearSuccessMessage => 'Key-value storage cleared successfully';

  @override
  String get developerTitle => 'Developer';

  @override
  String get developerToggleBetaFeaturesLabel => 'Use beta features';

  @override
  String get developerToggleDebugFeaturesLabel => 'Use debug features';

  @override
  String get developerToggleExperimentalFeaturesDescription =>
      'Experimental features. Use with caution, as they may cause unexpected behavior or crashes.';

  @override
  String get developerToggleExperimentalFeaturesLabel => 'Use experimental features';

  @override
  String get developerUserAuthenticatedLabel => 'Authenticated';

  @override
  String get developerUserCurrentInfoDescription => 'Information about current user';

  @override
  String get developerUserCurrentLogoutDescription => 'Log out current user';

  @override
  String get developerUserRefreshSessionTitle => 'Refresh session';

  @override
  String get developerUserRefreshSessionDescription => 'Refresh current user\'s session';

  @override
  String get contactSupportButton => 'Contact support';

  @override
  String get errorDetailsDialogLabel => 'Error details';

  @override
  String get errorInternalServerLabel => 'Internal server error';

  @override
  String get errorNotFoundLabel => 'Not found';

  @override
  String get shareErrorButton => 'Share the error';

  @override
  String get shareErrorSuccessMessage => 'Error message has been shared successfully!';

  @override
  String get errorLabel => 'Error';

  @override
  String get errorUnimplementedLabel => 'Unimplemented';

  @override
  String get homeTitle => 'Home';

  @override
  String get profileSettingsTitle => 'Settings';

  @override
  String get profileSettingsDescription => 'Change your settings';

  @override
  String get profileTitle => 'Profile';
}
