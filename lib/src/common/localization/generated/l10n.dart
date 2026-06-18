// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class GeneratedLocalization {
  GeneratedLocalization();

  static GeneratedLocalization? _current;

  static GeneratedLocalization get current {
    assert(
      _current != null,
      'No instance of GeneratedLocalization was loaded. Try to initialize the GeneratedLocalization delegate before accessing GeneratedLocalization.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<GeneratedLocalization> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = GeneratedLocalization();
      GeneratedLocalization._current = instance;

      return instance;
    });
  }

  static GeneratedLocalization of(BuildContext context) {
    final instance = GeneratedLocalization.maybeOf(context);
    assert(
      instance != null,
      'No instance of GeneratedLocalization present in the widget tree. Did you add GeneratedLocalization.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static GeneratedLocalization? maybeOf(BuildContext context) {
    return Localizations.of<GeneratedLocalization>(
      context,
      GeneratedLocalization,
    );
  }

  /// `en`
  String get languageCode {
    return Intl.message('en', name: 'languageCode', desc: '', args: []);
  }

  /// `English`
  String get language {
    return Intl.message('English', name: 'language', desc: '', args: []);
  }

  /// `Title`
  String get title {
    return Intl.message('Title', name: 'title', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `Not found`
  String get notFound {
    return Intl.message('Not found', name: 'notFound', desc: '', args: []);
  }

  /// `Unimplemented`
  String get unimplemented {
    return Intl.message(
      'Unimplemented',
      name: 'unimplemented',
      desc: '',
      args: [],
    );
  }

  /// `Internal server error`
  String get internalServerError {
    return Intl.message(
      'Internal server error',
      name: 'internalServerError',
      desc: '',
      args: [],
    );
  }

  /// `Email is required.`
  String get emailRequiredError {
    return Intl.message(
      'Email is required.',
      name: 'emailRequiredError',
      desc: '',
      args: [],
    );
  }

  /// `Must be a valid email.`
  String get emailInvalidError {
    return Intl.message(
      'Must be a valid email.',
      name: 'emailInvalidError',
      desc: '',
      args: [],
    );
  }

  /// `Password is required.`
  String get passwordRequiredError {
    return Intl.message(
      'Password is required.',
      name: 'passwordRequiredError',
      desc: '',
      args: [],
    );
  }

  /// `Password must be 8 characters or more.`
  String get passwordMinLengthError {
    return Intl.message(
      'Password must be 8 characters or more.',
      name: 'passwordMinLengthError',
      desc: '',
      args: [],
    );
  }

  /// `Password must be 32 characters or less.`
  String get passwordMaxLengthError {
    return Intl.message(
      'Password must be 32 characters or less.',
      name: 'passwordMaxLengthError',
      desc: '',
      args: [],
    );
  }

  /// `Password must have at least one uppercase character.`
  String get passwordUppercaseError {
    return Intl.message(
      'Password must have at least one uppercase character.',
      name: 'passwordUppercaseError',
      desc: '',
      args: [],
    );
  }

  /// `Password must have at least one lowercase character.`
  String get passwordLowercaseError {
    return Intl.message(
      'Password must have at least one lowercase character.',
      name: 'passwordLowercaseError',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get logOutButton {
    return Intl.message('Log Out', name: 'logOutButton', desc: '', args: []);
  }

  /// `Sign In`
  String get signInButton {
    return Intl.message('Sign In', name: 'signInButton', desc: '', args: []);
  }

  /// `Sign Up`
  String get signUpButton {
    return Intl.message('Sign Up', name: 'signUpButton', desc: '', args: []);
  }

  /// `Back`
  String get backButton {
    return Intl.message('Back', name: 'backButton', desc: '', args: []);
  }

  /// `Cancel`
  String get cancelButton {
    return Intl.message('Cancel', name: 'cancelButton', desc: '', args: []);
  }

  /// `Delete`
  String get deleteButton {
    return Intl.message('Delete', name: 'deleteButton', desc: '', args: []);
  }

  /// `Edit`
  String get editButton {
    return Intl.message('Edit', name: 'editButton', desc: '', args: []);
  }

  /// `Details`
  String get detailsButton {
    return Intl.message('Details', name: 'detailsButton', desc: '', args: []);
  }

  /// `Attach logs`
  String get attachLogsButton {
    return Intl.message(
      'Attach logs',
      name: 'attachLogsButton',
      desc: '',
      args: [],
    );
  }

  /// `Send report`
  String get sendReportButton {
    return Intl.message(
      'Send report',
      name: 'sendReportButton',
      desc: '',
      args: [],
    );
  }

  /// `Contact support`
  String get contactSupportButton {
    return Intl.message(
      'Contact support',
      name: 'contactSupportButton',
      desc: '',
      args: [],
    );
  }

  /// `Share the error`
  String get shareErrorButton {
    return Intl.message(
      'Share the error',
      name: 'shareErrorButton',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `App`
  String get app {
    return Intl.message('App', name: 'app', desc: '', args: []);
  }

  /// `Authenticated`
  String get authenticated {
    return Intl.message(
      'Authenticated',
      name: 'authenticated',
      desc: '',
      args: [],
    );
  }

  /// `Authentication`
  String get authentication {
    return Intl.message(
      'Authentication',
      name: 'authentication',
      desc: '',
      args: [],
    );
  }

  /// `Database`
  String get database {
    return Intl.message('Database', name: 'database', desc: '', args: []);
  }

  /// `Version`
  String get version {
    return Intl.message('Version', name: 'version', desc: '', args: []);
  }

  /// `Size`
  String get size {
    return Intl.message('Size', name: 'size', desc: '', args: []);
  }

  /// `Type`
  String get type {
    return Intl.message('Type', name: 'type', desc: '', args: []);
  }

  /// `Time`
  String get time {
    return Intl.message('Time', name: 'time', desc: '', args: []);
  }

  /// `Status`
  String get status {
    return Intl.message('Status', name: 'status', desc: '', args: []);
  }

  /// `Storage`
  String get storage {
    return Intl.message('Storage', name: 'storage', desc: '', args: []);
  }

  /// `Selected`
  String get selected {
    return Intl.message('Selected', name: 'selected', desc: '', args: []);
  }

  /// `Generate password`
  String get generatePasswordTooltip {
    return Intl.message(
      'Generate password',
      name: 'generatePasswordTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email`
  String get emailHint {
    return Intl.message(
      'Enter your email',
      name: 'emailHint',
      desc: '',
      args: [],
    );
  }

  /// `Enter your password`
  String get enterPasswordHint {
    return Intl.message(
      'Enter your password',
      name: 'enterPasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out?`
  String get logoutConfirmation {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'logoutConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Error details`
  String get errorDetailsTitle {
    return Intl.message(
      'Error details',
      name: 'errorDetailsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Copy to clipboard`
  String get copyToClipboardTooltip {
    return Intl.message(
      'Copy to clipboard',
      name: 'copyToClipboardTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Error message has been shared successfully!`
  String get shareErrorSuccessMessage {
    return Intl.message(
      'Error message has been shared successfully!',
      name: 'shareErrorSuccessMessage',
      desc: '',
      args: [],
    );
  }

  /// `Change your settings`
  String get settingsDescription {
    return Intl.message(
      'Change your settings',
      name: 'settingsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Developer`
  String get developer {
    return Intl.message('Developer', name: 'developer', desc: '', args: []);
  }

  /// `Application`
  String get application {
    return Intl.message('Application', name: 'application', desc: '', args: []);
  }

  /// `Navigation`
  String get navigation {
    return Intl.message('Navigation', name: 'navigation', desc: '', args: []);
  }

  /// `Useful links`
  String get usefulLinks {
    return Intl.message(
      'Useful links',
      name: 'usefulLinks',
      desc: '',
      args: [],
    );
  }

  /// `App version`
  String get appVersion {
    return Intl.message('App version', name: 'appVersion', desc: '', args: []);
  }

  /// `Copied`
  String get copied {
    return Intl.message('Copied', name: 'copied', desc: '', args: []);
  }

  /// `Database cleared`
  String get databaseClearedMessage {
    return Intl.message(
      'Database cleared',
      name: 'databaseClearedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Database clear failed`
  String get databaseClearFailedMessage {
    return Intl.message(
      'Database clear failed',
      name: 'databaseClearFailedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Application information`
  String get applicationInformation {
    return Intl.message(
      'Application information',
      name: 'applicationInformation',
      desc: '',
      args: [],
    );
  }

  /// `Show information about the application.`
  String get showApplicationInformation {
    return Intl.message(
      'Show information about the application.',
      name: 'showApplicationInformation',
      desc: '',
      args: [],
    );
  }

  /// `Dependencies`
  String get dependencies {
    return Intl.message(
      'Dependencies',
      name: 'dependencies',
      desc: '',
      args: [],
    );
  }

  /// `Show dependencies.`
  String get showDependencies {
    return Intl.message(
      'Show dependencies.',
      name: 'showDependencies',
      desc: '',
      args: [],
    );
  }

  /// `Dev dependencies`
  String get devDependencies {
    return Intl.message(
      'Dev dependencies',
      name: 'devDependencies',
      desc: '',
      args: [],
    );
  }

  /// `Show developers dependencies.`
  String get showDevDependencies {
    return Intl.message(
      'Show developers dependencies.',
      name: 'showDevDependencies',
      desc: '',
      args: [],
    );
  }

  /// `Logs`
  String get logs {
    return Intl.message('Logs', name: 'logs', desc: '', args: []);
  }

  /// `Show logs.`
  String get showLogs {
    return Intl.message('Show logs.', name: 'showLogs', desc: '', args: []);
  }

  /// `Clear`
  String get clearButton {
    return Intl.message('Clear', name: 'clearButton', desc: '', args: []);
  }

  /// `No logs yet`
  String get noLogsYet {
    return Intl.message('No logs yet', name: 'noLogsYet', desc: '', args: []);
  }

  /// `Share error`
  String get shareErrorTitle {
    return Intl.message(
      'Share error',
      name: 'shareErrorTitle',
      desc: '',
      args: [],
    );
  }

  /// `Describe the issue you encountered and we will try to fix it as soon as possible.`
  String get shareErrorDescription {
    return Intl.message(
      'Describe the issue you encountered and we will try to fix it as soon as possible.',
      name: 'shareErrorDescription',
      desc: '',
      args: [],
    );
  }

  /// `Attaching logs can help us identify and fix the issue faster.`
  String get attachLogsDescription {
    return Intl.message(
      'Attaching logs can help us identify and fix the issue faster.',
      name: 'attachLogsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Open bug report dialog on shake`
  String get shareErrorOnShakeLabel {
    return Intl.message(
      'Open bug report dialog on shake',
      name: 'shareErrorOnShakeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Disable this if you do not want the bug report dialog to appear when the device is shaken.`
  String get shareErrorOnShakeHint {
    return Intl.message(
      'Disable this if you do not want the bug report dialog to appear when the device is shaken.',
      name: 'shareErrorOnShakeHint',
      desc: '',
      args: [],
    );
  }

  /// `Reset navigation`
  String get resetNavigation {
    return Intl.message(
      'Reset navigation',
      name: 'resetNavigation',
      desc: '',
      args: [],
    );
  }

  /// `Reset navigation stack.`
  String get resetNavigationDescription {
    return Intl.message(
      'Reset navigation stack.',
      name: 'resetNavigationDescription',
      desc: '',
      args: [],
    );
  }

  /// `View database`
  String get viewDatabase {
    return Intl.message(
      'View database',
      name: 'viewDatabase',
      desc: '',
      args: [],
    );
  }

  /// `View database content.`
  String get viewDatabaseDescription {
    return Intl.message(
      'View database content.',
      name: 'viewDatabaseDescription',
      desc: '',
      args: [],
    );
  }

  /// `Drop database`
  String get dropDatabase {
    return Intl.message(
      'Drop database',
      name: 'dropDatabase',
      desc: '',
      args: [],
    );
  }

  /// `Clear database content.`
  String get dropDatabaseDescription {
    return Intl.message(
      'Clear database content.',
      name: 'dropDatabaseDescription',
      desc: '',
      args: [],
    );
  }

  /// `Information about current user`
  String get currentUserInformation {
    return Intl.message(
      'Information about current user',
      name: 'currentUserInformation',
      desc: '',
      args: [],
    );
  }

  /// `Refresh session`
  String get refreshSession {
    return Intl.message(
      'Refresh session',
      name: 'refreshSession',
      desc: '',
      args: [],
    );
  }

  /// `Refresh current user's session`
  String get refreshSessionDescription {
    return Intl.message(
      'Refresh current user\'s session',
      name: 'refreshSessionDescription',
      desc: '',
      args: [],
    );
  }

  /// `Log out current user`
  String get logOutCurrentUser {
    return Intl.message(
      'Log out current user',
      name: 'logOutCurrentUser',
      desc: '',
      args: [],
    );
  }

  /// `Advanced options for developers. Use with caution, as they may cause unexpected behavior or crashes.`
  String get advancedOptionsDescription {
    return Intl.message(
      'Advanced options for developers. Use with caution, as they may cause unexpected behavior or crashes.',
      name: 'advancedOptionsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Use debug features`
  String get useDebugFeatures {
    return Intl.message(
      'Use debug features',
      name: 'useDebugFeatures',
      desc: '',
      args: [],
    );
  }

  /// `Use developer mode`
  String get useDeveloperMode {
    return Intl.message(
      'Use developer mode',
      name: 'useDeveloperMode',
      desc: '',
      args: [],
    );
  }

  /// `Developer info`
  String get developerInfoButton {
    return Intl.message(
      'Developer info',
      name: 'developerInfoButton',
      desc: '',
      args: [],
    );
  }

  /// `Experimental features. Use with caution, as they may cause unexpected behavior or crashes.`
  String get experimentalFeaturesDescription {
    return Intl.message(
      'Experimental features. Use with caution, as they may cause unexpected behavior or crashes.',
      name: 'experimentalFeaturesDescription',
      desc: '',
      args: [],
    );
  }

  /// `Use beta features`
  String get useBetaFeatures {
    return Intl.message(
      'Use beta features',
      name: 'useBetaFeatures',
      desc: '',
      args: [],
    );
  }

  /// `Use experimental features`
  String get useExperimentalFeatures {
    return Intl.message(
      'Use experimental features',
      name: 'useExperimentalFeatures',
      desc: '',
      args: [],
    );
  }

  /// `Enable haptic feedback in the app. Useful for testing haptic feedback functionality.`
  String get hapticFeedbackDescription {
    return Intl.message(
      'Enable haptic feedback in the app. Useful for testing haptic feedback functionality.',
      name: 'hapticFeedbackDescription',
      desc: '',
      args: [],
    );
  }

  /// `Use haptic feedback`
  String get useHapticFeedback {
    return Intl.message(
      'Use haptic feedback',
      name: 'useHapticFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Clear key-value storage. Useful for testing onboarding and promo code flows.`
  String get clearKeyValueStorageDescription {
    return Intl.message(
      'Clear key-value storage. Useful for testing onboarding and promo code flows.',
      name: 'clearKeyValueStorageDescription',
      desc: '',
      args: [],
    );
  }

  /// `Clear key-value storage`
  String get clearKeyValueStorageButton {
    return Intl.message(
      'Clear key-value storage',
      name: 'clearKeyValueStorageButton',
      desc: '',
      args: [],
    );
  }

  /// `Key-value storage cleared successfully`
  String get clearKeyValueStorageSuccessMessage {
    return Intl.message(
      'Key-value storage cleared successfully',
      name: 'clearKeyValueStorageSuccessMessage',
      desc: '',
      args: [],
    );
  }

  /// `Refresh FCM token. Useful for testing push notifications in development builds.`
  String get refreshFcmTokenDescription {
    return Intl.message(
      'Refresh FCM token. Useful for testing push notifications in development builds.',
      name: 'refreshFcmTokenDescription',
      desc: '',
      args: [],
    );
  }

  /// `Refresh FCM token`
  String get refreshFcmTokenButton {
    return Intl.message(
      'Refresh FCM token',
      name: 'refreshFcmTokenButton',
      desc: '',
      args: [],
    );
  }

  /// `Share application logs for better support`
  String get shareApplicationLogsDescription {
    return Intl.message(
      'Share application logs for better support',
      name: 'shareApplicationLogsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Send logs`
  String get sendLogsButton {
    return Intl.message(
      'Send logs',
      name: 'sendLogsButton',
      desc: '',
      args: [],
    );
  }

  /// `Log out from all devices. Useful for testing logout functionality or refreshing session on all devices.`
  String get logoutAllDevicesDescription {
    return Intl.message(
      'Log out from all devices. Useful for testing logout functionality or refreshing session on all devices.',
      name: 'logoutAllDevicesDescription',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out from all devices?`
  String get logoutAllDevicesConfirmation {
    return Intl.message(
      'Are you sure you want to log out from all devices?',
      name: 'logoutAllDevicesConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Log out from all devices`
  String get logoutAllDevicesButton {
    return Intl.message(
      'Log out from all devices',
      name: 'logoutAllDevicesButton',
      desc: '',
      args: [],
    );
  }

  /// `of`
  String get ofSeparator {
    return Intl.message('of', name: 'ofSeparator', desc: '', args: []);
  }
}

class AppLocalizationDelegate
    extends LocalizationsDelegate<GeneratedLocalization> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<GeneratedLocalization> load(Locale locale) =>
      GeneratedLocalization.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
