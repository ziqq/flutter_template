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
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
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
    return Localizations.of<GeneratedLocalization>(context, GeneratedLocalization);
  }

  /// `en`
  String get localeCode {
    return Intl.message('en', name: 'localeCode', desc: '', args: []);
  }

  /// `English`
  String get localeName {
    return Intl.message('English', name: 'localeName', desc: '', args: []);
  }

  /// `Title`
  String get title {
    return Intl.message('Title', name: 'title', desc: '', args: []);
  }

  /// `Email`
  String get emailLabel {
    return Intl.message('Email', name: 'emailLabel', desc: '', args: []);
  }

  /// `Enter your email`
  String get emailPlaceholder {
    return Intl.message('Enter your email', name: 'emailPlaceholder', desc: '', args: []);
  }

  /// `Generate password`
  String get authGeneratePasswordTooltip {
    return Intl.message('Generate password', name: 'authGeneratePasswordTooltip', desc: '', args: []);
  }

  /// `Log Out`
  String get logoutButton {
    return Intl.message('Log Out', name: 'logoutButton', desc: '', args: []);
  }

  /// `Are you sure you want to log out?`
  String get authLogoutConfirmationMessage {
    return Intl.message('Are you sure you want to log out?', name: 'authLogoutConfirmationMessage', desc: '', args: []);
  }

  /// `Password`
  String get passwordLabel {
    return Intl.message('Password', name: 'passwordLabel', desc: '', args: []);
  }

  /// `Enter your password`
  String get passwordPlaceholder {
    return Intl.message('Enter your password', name: 'passwordPlaceholder', desc: '', args: []);
  }

  /// `Sign In`
  String get signInButton {
    return Intl.message('Sign In', name: 'signInButton', desc: '', args: []);
  }

  /// `Sign Up`
  String get signUpButton {
    return Intl.message('Sign Up', name: 'signUpButton', desc: '', args: []);
  }

  /// `Must be a valid email.`
  String get authValidationEmailInvalidMessage {
    return Intl.message('Must be a valid email.', name: 'authValidationEmailInvalidMessage', desc: '', args: []);
  }

  /// `Email is required.`
  String get authValidationEmailRequiredMessage {
    return Intl.message('Email is required.', name: 'authValidationEmailRequiredMessage', desc: '', args: []);
  }

  /// `Password must have at least one lowercase character.`
  String get authValidationPasswordMissingLowercaseMessage {
    return Intl.message(
      'Password must have at least one lowercase character.',
      name: 'authValidationPasswordMissingLowercaseMessage',
      desc: '',
      args: [],
    );
  }

  /// `Password must have at least one uppercase character.`
  String get authValidationPasswordMissingUppercaseMessage {
    return Intl.message(
      'Password must have at least one uppercase character.',
      name: 'authValidationPasswordMissingUppercaseMessage',
      desc: '',
      args: [],
    );
  }

  /// `Password is required.`
  String get authValidationPasswordRequiredMessage {
    return Intl.message('Password is required.', name: 'authValidationPasswordRequiredMessage', desc: '', args: []);
  }

  /// `Password must be 32 characters or less.`
  String get authValidationPasswordTooLongMessage {
    return Intl.message(
      'Password must be 32 characters or less.',
      name: 'authValidationPasswordTooLongMessage',
      desc: '',
      args: [],
    );
  }

  /// `Password must be 8 characters or more.`
  String get authValidationPasswordTooShortMessage {
    return Intl.message(
      'Password must be 8 characters or more.',
      name: 'authValidationPasswordTooShortMessage',
      desc: '',
      args: [],
    );
  }

  /// `Attaching logs can help us identify and fix the issue faster.`
  String get bugReportAttachLogsHelpText {
    return Intl.message(
      'Attaching logs can help us identify and fix the issue faster.',
      name: 'bugReportAttachLogsHelpText',
      desc: '',
      args: [],
    );
  }

  /// `Attach logs`
  String get bugReportAttachLogsToggleLabel {
    return Intl.message('Attach logs', name: 'bugReportAttachLogsToggleLabel', desc: '', args: []);
  }

  /// `Describe the issue you encountered and we will try to fix it as soon as possible.`
  String get bugReportDialogDescription {
    return Intl.message(
      'Describe the issue you encountered and we will try to fix it as soon as possible.',
      name: 'bugReportDialogDescription',
      desc: '',
      args: [],
    );
  }

  /// `Share error`
  String get bugReportDialogTitle {
    return Intl.message('Share error', name: 'bugReportDialogTitle', desc: '', args: []);
  }

  /// `Disable this if you do not want the bug report dialog to appear when the device is shaken.`
  String get bugReportShakeToReportToggleHint {
    return Intl.message(
      'Disable this if you do not want the bug report dialog to appear when the device is shaken.',
      name: 'bugReportShakeToReportToggleHint',
      desc: '',
      args: [],
    );
  }

  /// `Open bug report dialog on shake`
  String get bugReportShakeToReportToggleLabel {
    return Intl.message(
      'Open bug report dialog on shake',
      name: 'bugReportShakeToReportToggleLabel',
      desc: '',
      args: [],
    );
  }

  /// `Send report`
  String get submitReportButton {
    return Intl.message('Send report', name: 'submitReportButton', desc: '', args: []);
  }

  /// `App`
  String get appLabel {
    return Intl.message('App', name: 'appLabel', desc: '', args: []);
  }

  /// `Back`
  String get backButton {
    return Intl.message('Back', name: 'backButton', desc: '', args: []);
  }

  /// `Cancel`
  String get cancelButton {
    return Intl.message('Cancel', name: 'cancelButton', desc: '', args: []);
  }

  /// `Clear`
  String get clearButton {
    return Intl.message('Clear', name: 'clearButton', desc: '', args: []);
  }

  /// `Copied`
  String get copiedMessage {
    return Intl.message('Copied', name: 'copiedMessage', desc: '', args: []);
  }

  /// `Copy to clipboard`
  String get copyToClipboardLabel {
    return Intl.message('Copy to clipboard', name: 'copyToClipboardLabel', desc: '', args: []);
  }

  /// `Delete`
  String get deleteButton {
    return Intl.message('Delete', name: 'deleteButton', desc: '', args: []);
  }

  /// `Details`
  String get detailsButton {
    return Intl.message('Details', name: 'detailsButton', desc: '', args: []);
  }

  /// `Edit`
  String get editButton {
    return Intl.message('Edit', name: 'editButton', desc: '', args: []);
  }

  /// `Name`
  String get nameLabel {
    return Intl.message('Name', name: 'nameLabel', desc: '', args: []);
  }

  /// `of`
  String get ofSeparator {
    return Intl.message('of', name: 'ofSeparator', desc: '', args: []);
  }

  /// `Selected`
  String get selectedLabel {
    return Intl.message('Selected', name: 'selectedLabel', desc: '', args: []);
  }

  /// `Size`
  String get sizeLabel {
    return Intl.message('Size', name: 'sizeLabel', desc: '', args: []);
  }

  /// `Status`
  String get statusLabel {
    return Intl.message('Status', name: 'statusLabel', desc: '', args: []);
  }

  /// `Storage`
  String get storageLabel {
    return Intl.message('Storage', name: 'storageLabel', desc: '', args: []);
  }

  /// `Time`
  String get timeLabel {
    return Intl.message('Time', name: 'timeLabel', desc: '', args: []);
  }

  /// `Type`
  String get typeLabel {
    return Intl.message('Type', name: 'typeLabel', desc: '', args: []);
  }

  /// `Version`
  String get versionLabel {
    return Intl.message('Version', name: 'versionLabel', desc: '', args: []);
  }

  /// `Application information`
  String get developerApplicationInfoTitle {
    return Intl.message('Application information', name: 'developerApplicationInfoTitle', desc: '', args: []);
  }

  /// `Show information about the application.`
  String get developerApplicationInfoOpenDescription {
    return Intl.message(
      'Show information about the application.',
      name: 'developerApplicationInfoOpenDescription',
      desc: '',
      args: [],
    );
  }

  /// `App version`
  String get developerAppVersionLabel {
    return Intl.message('App version', name: 'developerAppVersionLabel', desc: '', args: []);
  }

  /// `Database clear failed`
  String get developerDatabaseClearFailureMessage {
    return Intl.message('Database clear failed', name: 'developerDatabaseClearFailureMessage', desc: '', args: []);
  }

  /// `Database cleared`
  String get developerDatabaseClearSuccessMessage {
    return Intl.message('Database cleared', name: 'developerDatabaseClearSuccessMessage', desc: '', args: []);
  }

  /// `Drop database`
  String get developerDatabaseDropTitle {
    return Intl.message('Drop database', name: 'developerDatabaseDropTitle', desc: '', args: []);
  }

  /// `Clear database content.`
  String get developerDatabaseDropDescription {
    return Intl.message('Clear database content.', name: 'developerDatabaseDropDescription', desc: '', args: []);
  }

  /// `View database`
  String get developerDatabaseOpenTitle {
    return Intl.message('View database', name: 'developerDatabaseOpenTitle', desc: '', args: []);
  }

  /// `View database content.`
  String get developerDatabaseOpenDescription {
    return Intl.message('View database content.', name: 'developerDatabaseOpenDescription', desc: '', args: []);
  }

  /// `Dependencies`
  String get developerDependenciesTitle {
    return Intl.message('Dependencies', name: 'developerDependenciesTitle', desc: '', args: []);
  }

  /// `Show dependencies.`
  String get developerDependenciesOpenDescription {
    return Intl.message('Show dependencies.', name: 'developerDependenciesOpenDescription', desc: '', args: []);
  }

  /// `Use developer mode`
  String get developerDeveloperModeToggleLabel {
    return Intl.message('Use developer mode', name: 'developerDeveloperModeToggleLabel', desc: '', args: []);
  }

  /// `Dev dependencies`
  String get developerDevDependenciesTitle {
    return Intl.message('Dev dependencies', name: 'developerDevDependenciesTitle', desc: '', args: []);
  }

  /// `Show developers dependencies.`
  String get developerDevDependenciesOpenDescription {
    return Intl.message(
      'Show developers dependencies.',
      name: 'developerDevDependenciesOpenDescription',
      desc: '',
      args: [],
    );
  }

  /// `Advanced options for developers. Use with caution, as they may cause unexpected behavior or crashes.`
  String get developerFeatureFlagsDescription {
    return Intl.message(
      'Advanced options for developers. Use with caution, as they may cause unexpected behavior or crashes.',
      name: 'developerFeatureFlagsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Enable haptic feedback in the app. Useful for testing haptic feedback functionality.`
  String get developerHapticFeedbackDescription {
    return Intl.message(
      'Enable haptic feedback in the app. Useful for testing haptic feedback functionality.',
      name: 'developerHapticFeedbackDescription',
      desc: '',
      args: [],
    );
  }

  /// `Use haptic feedback`
  String get developerHapticFeedbackToggleLabel {
    return Intl.message('Use haptic feedback', name: 'developerHapticFeedbackToggleLabel', desc: '', args: []);
  }

  /// `Developer info`
  String get developerInfoButton {
    return Intl.message('Developer info', name: 'developerInfoButton', desc: '', args: []);
  }

  /// `Clear`
  String get clearLogsButton {
    return Intl.message('Clear', name: 'clearLogsButton', desc: '', args: []);
  }

  /// `No logs yet`
  String get developerLogsEmptyStateMessage {
    return Intl.message('No logs yet', name: 'developerLogsEmptyStateMessage', desc: '', args: []);
  }

  /// `Show logs.`
  String get developerLogsOpenDescription {
    return Intl.message('Show logs.', name: 'developerLogsOpenDescription', desc: '', args: []);
  }

  /// `Send logs`
  String get sendLogsButton {
    return Intl.message('Send logs', name: 'sendLogsButton', desc: '', args: []);
  }

  /// `Share application logs for better support`
  String get developerLogsShareDescription {
    return Intl.message(
      'Share application logs for better support',
      name: 'developerLogsShareDescription',
      desc: '',
      args: [],
    );
  }

  /// `Logs`
  String get developerLogsTitle {
    return Intl.message('Logs', name: 'developerLogsTitle', desc: '', args: []);
  }

  /// `Reset navigation stack.`
  String get developerNavigationResetDescription {
    return Intl.message('Reset navigation stack.', name: 'developerNavigationResetDescription', desc: '', args: []);
  }

  /// `Reset navigation`
  String get developerNavigationResetTitle {
    return Intl.message('Reset navigation', name: 'developerNavigationResetTitle', desc: '', args: []);
  }

  /// `Refresh FCM token. Useful for testing push notifications in development builds.`
  String get developerNotificationsRefreshDescription {
    return Intl.message(
      'Refresh FCM token. Useful for testing push notifications in development builds.',
      name: 'developerNotificationsRefreshDescription',
      desc: '',
      args: [],
    );
  }

  /// `Refresh FCM token`
  String get developerNotificationsRefreshTitle {
    return Intl.message('Refresh FCM token', name: 'developerNotificationsRefreshTitle', desc: '', args: []);
  }

  /// `Application`
  String get developerSectionApplicationTitle {
    return Intl.message('Application', name: 'developerSectionApplicationTitle', desc: '', args: []);
  }

  /// `Authentication`
  String get developerSectionAuthenticationTitle {
    return Intl.message('Authentication', name: 'developerSectionAuthenticationTitle', desc: '', args: []);
  }

  /// `Database`
  String get developerSectionDatabaseTitle {
    return Intl.message('Database', name: 'developerSectionDatabaseTitle', desc: '', args: []);
  }

  /// `Navigation`
  String get developerSectionNavigationTitle {
    return Intl.message('Navigation', name: 'developerSectionNavigationTitle', desc: '', args: []);
  }

  /// `Useful links`
  String get developerSectionUsefulLinksTitle {
    return Intl.message('Useful links', name: 'developerSectionUsefulLinksTitle', desc: '', args: []);
  }

  /// `Log out from all devices`
  String get logoutAllDevicesButton {
    return Intl.message('Log out from all devices', name: 'logoutAllDevicesButton', desc: '', args: []);
  }

  /// `Are you sure you want to log out from all devices?`
  String get developerSessionsLogoutAllConfirmationMessage {
    return Intl.message(
      'Are you sure you want to log out from all devices?',
      name: 'developerSessionsLogoutAllConfirmationMessage',
      desc: '',
      args: [],
    );
  }

  /// `Log out from all devices. Useful for testing logout functionality or refreshing session on all devices.`
  String get developerSessionsLogoutAllDescription {
    return Intl.message(
      'Log out from all devices. Useful for testing logout functionality or refreshing session on all devices.',
      name: 'developerSessionsLogoutAllDescription',
      desc: '',
      args: [],
    );
  }

  /// `Clear key-value storage`
  String get clearKVStorageButton {
    return Intl.message('Clear key-value storage', name: 'clearKVStorageButton', desc: '', args: []);
  }

  /// `Clear key-value storage. Useful for testing onboarding and promo code flows.`
  String get developerStorageClearDescription {
    return Intl.message(
      'Clear key-value storage. Useful for testing onboarding and promo code flows.',
      name: 'developerStorageClearDescription',
      desc: '',
      args: [],
    );
  }

  /// `Key-value storage cleared successfully`
  String get developerStorageClearSuccessMessage {
    return Intl.message(
      'Key-value storage cleared successfully',
      name: 'developerStorageClearSuccessMessage',
      desc: '',
      args: [],
    );
  }

  /// `Developer`
  String get developerTitle {
    return Intl.message('Developer', name: 'developerTitle', desc: '', args: []);
  }

  /// `Use beta features`
  String get developerToggleBetaFeaturesLabel {
    return Intl.message('Use beta features', name: 'developerToggleBetaFeaturesLabel', desc: '', args: []);
  }

  /// `Use debug features`
  String get developerToggleDebugFeaturesLabel {
    return Intl.message('Use debug features', name: 'developerToggleDebugFeaturesLabel', desc: '', args: []);
  }

  /// `Experimental features. Use with caution, as they may cause unexpected behavior or crashes.`
  String get developerToggleExperimentalFeaturesDescription {
    return Intl.message(
      'Experimental features. Use with caution, as they may cause unexpected behavior or crashes.',
      name: 'developerToggleExperimentalFeaturesDescription',
      desc: '',
      args: [],
    );
  }

  /// `Use experimental features`
  String get developerToggleExperimentalFeaturesLabel {
    return Intl.message(
      'Use experimental features',
      name: 'developerToggleExperimentalFeaturesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Authenticated`
  String get developerUserAuthenticatedLabel {
    return Intl.message('Authenticated', name: 'developerUserAuthenticatedLabel', desc: '', args: []);
  }

  /// `Information about current user`
  String get developerUserCurrentInfoDescription {
    return Intl.message(
      'Information about current user',
      name: 'developerUserCurrentInfoDescription',
      desc: '',
      args: [],
    );
  }

  /// `Log out current user`
  String get developerUserCurrentLogoutDescription {
    return Intl.message('Log out current user', name: 'developerUserCurrentLogoutDescription', desc: '', args: []);
  }

  /// `Refresh session`
  String get developerUserRefreshSessionTitle {
    return Intl.message('Refresh session', name: 'developerUserRefreshSessionTitle', desc: '', args: []);
  }

  /// `Refresh current user's session`
  String get developerUserRefreshSessionDescription {
    return Intl.message(
      'Refresh current user\'s session',
      name: 'developerUserRefreshSessionDescription',
      desc: '',
      args: [],
    );
  }

  /// `Contact support`
  String get contactSupportButton {
    return Intl.message('Contact support', name: 'contactSupportButton', desc: '', args: []);
  }

  /// `Error details`
  String get errorDetailsDialogLabel {
    return Intl.message('Error details', name: 'errorDetailsDialogLabel', desc: '', args: []);
  }

  /// `Internal server error`
  String get errorInternalServerLabel {
    return Intl.message('Internal server error', name: 'errorInternalServerLabel', desc: '', args: []);
  }

  /// `Not found`
  String get errorNotFoundLabel {
    return Intl.message('Not found', name: 'errorNotFoundLabel', desc: '', args: []);
  }

  /// `Share the error`
  String get shareErrorButton {
    return Intl.message('Share the error', name: 'shareErrorButton', desc: '', args: []);
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

  /// `Error`
  String get errorLabel {
    return Intl.message('Error', name: 'errorLabel', desc: '', args: []);
  }

  /// `Unimplemented`
  String get errorUnimplementedLabel {
    return Intl.message('Unimplemented', name: 'errorUnimplementedLabel', desc: '', args: []);
  }

  /// `Home`
  String get homeTitle {
    return Intl.message('Home', name: 'homeTitle', desc: '', args: []);
  }

  /// `Settings`
  String get profileSettingsTitle {
    return Intl.message('Settings', name: 'profileSettingsTitle', desc: '', args: []);
  }

  /// `Change your settings`
  String get profileSettingsDescription {
    return Intl.message('Change your settings', name: 'profileSettingsDescription', desc: '', args: []);
  }

  /// `Profile`
  String get profileTitle {
    return Intl.message('Profile', name: 'profileTitle', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<GeneratedLocalization> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[Locale.fromSubtags(languageCode: 'en'), Locale.fromSubtags(languageCode: 'ru')];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<GeneratedLocalization> load(Locale locale) => GeneratedLocalization.load(locale);
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
