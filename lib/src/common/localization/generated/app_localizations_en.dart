// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageCode => 'en';

  @override
  String get language => 'English';

  @override
  String get title => 'Title';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get home => 'Home';

  @override
  String get error => 'Error';

  @override
  String get errorDetailsTitle => 'Error details';

  @override
  String get notFound => 'Not found';

  @override
  String get unimplemented => 'Unimplemented';

  @override
  String get internalServerError => 'Internal server error';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get emailRequiredError => 'Email is required.';

  @override
  String get emailInvalidError => 'Must be a valid email.';

  @override
  String get passwordRequiredError => 'Password is required.';

  @override
  String get passwordMinLengthError => 'Password must be 8 characters or more.';

  @override
  String get passwordMaxLengthError => 'Password must be 32 characters or less.';

  @override
  String get passwordUppercaseError => 'Password must have at least one uppercase character.';

  @override
  String get passwordLowercaseError => 'Password must have at least one lowercase character.';

  @override
  String get logOutButton => 'Log Out';

  @override
  String get signInButton => 'Sign In';

  @override
  String get signUpButton => 'Sign Up';

  @override
  String get backButton => 'Back';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteButton => 'Delete';

  @override
  String get editButton => 'Edit';

  @override
  String get detailsButton => 'Details';

  @override
  String get contactSupportButton => 'Contact support';

  @override
  String get shareErrorSuccessMessage => 'Error message has been shared successfully!';

  @override
  String get shareErrorButton => 'Share the error';

  @override
  String get sendReportButton => 'Send report';

  @override
  String get attachLogsButton => 'Attach logs';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get name => 'Name';

  @override
  String get app => 'App';

  @override
  String get authenticated => 'Authenticated';

  @override
  String get authentication => 'Authentication';

  @override
  String get database => 'Database';

  @override
  String get version => 'Version';

  @override
  String get status => 'Status';

  @override
  String get size => 'Size';

  @override
  String get time => 'Time';

  @override
  String get type => 'Type';

  @override
  String get storage => 'Storage';

  @override
  String get selected => 'Selected';

  @override
  String get generatePasswordTooltip => 'Generate password';

  @override
  String get enterPasswordHint => 'Enter your password';

  @override
  String get logoutConfirmation => 'Are you sure you want to log out?';

  @override
  String get copyToClipboardTooltip => 'Copy to clipboard';

  @override
  String get settingsDescription => 'Change your settings';

  @override
  String get developer => 'Developer';

  @override
  String get application => 'Application';

  @override
  String get navigation => 'Navigation';

  @override
  String get usefulLinks => 'Useful links';

  @override
  String get appVersion => 'App version';

  @override
  String get copied => 'Copied';

  @override
  String get databaseClearedMessage => 'Database cleared';

  @override
  String get databaseClearFailedMessage => 'Database clear failed';

  @override
  String get applicationInformation => 'Application information';

  @override
  String get showApplicationInformation => 'Show information about the application.';

  @override
  String get dependencies => 'Dependencies';

  @override
  String get showDependencies => 'Show dependencies.';

  @override
  String get devDependencies => 'Dev dependencies';

  @override
  String get showDevDependencies => 'Show developers dependencies.';

  @override
  String get logs => 'Logs';

  @override
  String get showLogs => 'Show logs.';

  @override
  String get clearButton => 'Clear';

  @override
  String get noLogsYet => 'No logs yet';

  @override
  String get shareErrorTitle => 'Share error';

  @override
  String get shareErrorDescription => 'Describe the issue you encountered and we will try to fix it as soon as possible.';

  @override
  String get attachLogsDescription => 'Attaching logs can help us identify and fix the issue faster.';

  @override
  String get shareErrorOnShakeLabel => 'Open bug report dialog on shake';

  @override
  String get shareErrorOnShakeHint => 'Disable this if you do not want the bug report dialog to appear when the device is shaken.';

  @override
  String get resetNavigation => 'Reset navigation';

  @override
  String get resetNavigationDescription => 'Reset navigation stack.';

  @override
  String get viewDatabase => 'View database';

  @override
  String get viewDatabaseDescription => 'View database content.';

  @override
  String get dropDatabase => 'Drop database';

  @override
  String get dropDatabaseDescription => 'Clear database content.';

  @override
  String get currentUserInformation => 'Information about current user';

  @override
  String get refreshSession => 'Refresh session';

  @override
  String get refreshSessionDescription => 'Refresh current user\'s session';

  @override
  String get logOutCurrentUser => 'Log out current user';

  @override
  String get advancedOptionsDescription => 'Advanced options for developers. Use with caution, as they may cause unexpected behavior or crashes.';

  @override
  String get useDebugFeatures => 'Use debug features';

  @override
  String get useDeveloperMode => 'Use developer mode';

  @override
  String get developerInfoButton => 'Developer info';

  @override
  String get experimentalFeaturesDescription => 'Experimental features. Use with caution, as they may cause unexpected behavior or crashes.';

  @override
  String get useBetaFeatures => 'Use beta features';

  @override
  String get useExperimentalFeatures => 'Use experimental features';

  @override
  String get hapticFeedbackDescription => 'Enable haptic feedback in the app. Useful for testing haptic feedback functionality.';

  @override
  String get useHapticFeedback => 'Use haptic feedback';

  @override
  String get clearKeyValueStorageDescription => 'Clear key-value storage. Useful for testing onboarding and promo code flows.';

  @override
  String get clearKeyValueStorageButton => 'Clear key-value storage';

  @override
  String get clearKeyValueStorageSuccessMessage => 'Key-value storage cleared successfully';

  @override
  String get refreshFcmTokenDescription => 'Refresh FCM token. Useful for testing push notifications in development builds.';

  @override
  String get refreshFcmTokenButton => 'Refresh FCM token';

  @override
  String get shareApplicationLogsDescription => 'Share application logs for better support';

  @override
  String get sendLogsButton => 'Send logs';

  @override
  String get logoutAllDevicesDescription => 'Log out from all devices. Useful for testing logout functionality or refreshing session on all devices.';

  @override
  String get logoutAllDevicesConfirmation => 'Are you sure you want to log out from all devices?';

  @override
  String get logoutAllDevicesButton => 'Log out from all devices';

  @override
  String get ofSeparator => 'of';
}
