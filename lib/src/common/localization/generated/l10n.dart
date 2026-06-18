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
  String get appLocaleCode {
    return Intl.message('en', name: 'appLocaleCode', desc: '', args: []);
  }

  /// `English`
  String get appLocaleName {
    return Intl.message('English', name: 'appLocaleName', desc: '', args: []);
  }

  /// `Title`
  String get appTitle {
    return Intl.message('Title', name: 'appTitle', desc: '', args: []);
  }

  /// `Email`
  String get authEmailFieldLabel {
    return Intl.message(
      'Email',
      name: 'authEmailFieldLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email`
  String get authEmailFieldHint {
    return Intl.message(
      'Enter your email',
      name: 'authEmailFieldHint',
      desc: '',
      args: [],
    );
  }

  /// `Generate password`
  String get authGeneratePasswordTooltip {
    return Intl.message(
      'Generate password',
      name: 'authGeneratePasswordTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get authLogoutActionLabel {
    return Intl.message(
      'Log Out',
      name: 'authLogoutActionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out?`
  String get authLogoutConfirmationMessage {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'authLogoutConfirmationMessage',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get authPasswordFieldLabel {
    return Intl.message(
      'Password',
      name: 'authPasswordFieldLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter your password`
  String get authPasswordFieldHint {
    return Intl.message(
      'Enter your password',
      name: 'authPasswordFieldHint',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get authSignInActionLabel {
    return Intl.message(
      'Sign In',
      name: 'authSignInActionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get authSignUpActionLabel {
    return Intl.message(
      'Sign Up',
      name: 'authSignUpActionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Must be a valid email.`
  String get authValidationEmailInvalidMessage {
    return Intl.message(
      'Must be a valid email.',
      name: 'authValidationEmailInvalidMessage',
      desc: '',
      args: [],
    );
  }

  /// `Email is required.`
  String get authValidationEmailRequiredMessage {
    return Intl.message(
      'Email is required.',
      name: 'authValidationEmailRequiredMessage',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Password is required.',
      name: 'authValidationPasswordRequiredMessage',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Attach logs',
      name: 'bugReportAttachLogsToggleLabel',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Share error',
      name: 'bugReportDialogTitle',
      desc: '',
      args: [],
    );
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
  String get bugReportSubmitActionLabel {
    return Intl.message(
      'Send report',
      name: 'bugReportSubmitActionLabel',
      desc: '',
      args: [],
    );
  }

  /// `App`
  String get commonAppLabel {
    return Intl.message('App', name: 'commonAppLabel', desc: '', args: []);
  }

  /// `Back`
  String get commonBackActionLabel {
    return Intl.message(
      'Back',
      name: 'commonBackActionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get commonCancelActionLabel {
    return Intl.message(
      'Cancel',
      name: 'commonCancelActionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get commonClearActionLabel {
    return Intl.message(
      'Clear',
      name: 'commonClearActionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Copied`
  String get commonCopiedMessage {
    return Intl.message(
      'Copied',
      name: 'commonCopiedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Copy to clipboard`
  String get commonCopyToClipboardTooltip {
    return Intl.message(
      'Copy to clipboard',
      name: 'commonCopyToClipboardTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get commonDeleteActionLabel {
    return Intl.message(
      'Delete',
      name: 'commonDeleteActionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get commonDetailsActionLabel {
    return Intl.message(
      'Details',
      name: 'commonDetailsActionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get commonEditActionLabel {
    return Intl.message(
      'Edit',
      name: 'commonEditActionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get commonNameLabel {
    return Intl.message('Name', name: 'commonNameLabel', desc: '', args: []);
  }

  /// `of`
  String get commonOfSeparator {
    return Intl.message('of', name: 'commonOfSeparator', desc: '', args: []);
  }

  /// `Selected`
  String get commonSelectedLabel {
    return Intl.message(
      'Selected',
      name: 'commonSelectedLabel',
      desc: '',
      args: [],
    );
  }

  /// `Size`
  String get commonSizeLabel {
    return Intl.message('Size', name: 'commonSizeLabel', desc: '', args: []);
  }

  /// `Status`
  String get commonStatusLabel {
    return Intl.message(
      'Status',
      name: 'commonStatusLabel',
      desc: '',
      args: [],
    );
  }

  /// `Storage`
  String get commonStorageLabel {
    return Intl.message(
      'Storage',
      name: 'commonStorageLabel',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get commonTimeLabel {
    return Intl.message('Time', name: 'commonTimeLabel', desc: '', args: []);
  }

  /// `Type`
  String get commonTypeLabel {
    return Intl.message('Type', name: 'commonTypeLabel', desc: '', args: []);
  }

  /// `Version`
  String get commonVersionLabel {
    return Intl.message(
      'Version',
      name: 'commonVersionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Application information`
  String get developerApplicationInfoTitle {
    return Intl.message(
      'Application information',
      name: 'developerApplicationInfoTitle',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'App version',
      name: 'developerAppVersionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Database clear failed`
  String get developerDatabaseClearFailureMessage {
    return Intl.message(
      'Database clear failed',
      name: 'developerDatabaseClearFailureMessage',
      desc: '',
      args: [],
    );
  }

  /// `Database cleared`
  String get developerDatabaseClearSuccessMessage {
    return Intl.message(
      'Database cleared',
      name: 'developerDatabaseClearSuccessMessage',
      desc: '',
      args: [],
    );
  }

  /// `Drop database`
  String get developerDatabaseDropTitle {
    return Intl.message(
      'Drop database',
      name: 'developerDatabaseDropTitle',
      desc: '',
      args: [],
    );
  }

  /// `Clear database content.`
  String get developerDatabaseDropDescription {
    return Intl.message(
      'Clear database content.',
      name: 'developerDatabaseDropDescription',
      desc: '',
      args: [],
    );
  }

  /// `View database`
  String get developerDatabaseOpenTitle {
    return Intl.message(
      'View database',
      name: 'developerDatabaseOpenTitle',
      desc: '',
      args: [],
    );
  }

  /// `View database content.`
  String get developerDatabaseOpenDescription {
    return Intl.message(
      'View database content.',
      name: 'developerDatabaseOpenDescription',
      desc: '',
      args: [],
    );
  }

  /// `Dependencies`
  String get developerDependenciesTitle {
    return Intl.message(
      'Dependencies',
      name: 'developerDependenciesTitle',
      desc: '',
      args: [],
    );
  }

  /// `Show dependencies.`
  String get developerDependenciesOpenDescription {
    return Intl.message(
      'Show dependencies.',
      name: 'developerDependenciesOpenDescription',
      desc: '',
      args: [],
    );
  }

  /// `Use developer mode`
  String get developerDeveloperModeToggleLabel {
    return Intl.message(
      'Use developer mode',
      name: 'developerDeveloperModeToggleLabel',
      desc: '',
      args: [],
    );
  }

  /// `Dev dependencies`
  String get developerDevDependenciesTitle {
    return Intl.message(
      'Dev dependencies',
      name: 'developerDevDependenciesTitle',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Use haptic feedback',
      name: 'developerHapticFeedbackToggleLabel',
      desc: '',
      args: [],
    );
  }

  /// `Developer info`
  String get developerInfoOpenActionLabel {
    return Intl.message(
      'Developer info',
      name: 'developerInfoOpenActionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get developerLogsClearActionLabel {
    return Intl.message(
      'Clear',
      name: 'developerLogsClearActionLabel',
      desc: '',
      args: [],
    );
  }

  /// `No logs yet`
  String get developerLogsEmptyStateMessage {
    return Intl.message(
      'No logs yet',
      name: 'developerLogsEmptyStateMessage',
      desc: '',
      args: [],
    );
  }

  /// `Show logs.`
  String get developerLogsOpenDescription {
    return Intl.message(
      'Show logs.',
      name: 'developerLogsOpenDescription',
      desc: '',
      args: [],
    );
  }

  /// `Send logs`
  String get developerLogsShareActionLabel {
    return Intl.message(
      'Send logs',
      name: 'developerLogsShareActionLabel',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Reset navigation stack.',
      name: 'developerNavigationResetDescription',
      desc: '',
      args: [],
    );
  }

  /// `Reset navigation`
  String get developerNavigationResetTitle {
    return Intl.message(
      'Reset navigation',
      name: 'developerNavigationResetTitle',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Refresh FCM token',
      name: 'developerNotificationsRefreshTitle',
      desc: '',
      args: [],
    );
  }

  /// `Application`
  String get developerSectionApplicationTitle {
    return Intl.message(
      'Application',
      name: 'developerSectionApplicationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Authentication`
  String get developerSectionAuthenticationTitle {
    return Intl.message(
      'Authentication',
      name: 'developerSectionAuthenticationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Database`
  String get developerSectionDatabaseTitle {
    return Intl.message(
      'Database',
      name: 'developerSectionDatabaseTitle',
      desc: '',
      args: [],
    );
  }

  /// `Navigation`
  String get developerSectionNavigationTitle {
    return Intl.message(
      'Navigation',
      name: 'developerSectionNavigationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Useful links`
  String get developerSectionUsefulLinksTitle {
    return Intl.message(
      'Useful links',
      name: 'developerSectionUsefulLinksTitle',
      desc: '',
      args: [],
    );
  }

  /// `Log out from all devices`
  String get developerSessionsLogoutAllActionLabel {
    return Intl.message(
      'Log out from all devices',
      name: 'developerSessionsLogoutAllActionLabel',
      desc: '',
      args: [],
    );
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
  String get developerStorageClearActionLabel {
    return Intl.message(
      'Clear key-value storage',
      name: 'developerStorageClearActionLabel',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Developer',
      name: 'developerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Use beta features`
  String get developerToggleBetaFeaturesLabel {
    return Intl.message(
      'Use beta features',
      name: 'developerToggleBetaFeaturesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Use debug features`
  String get developerToggleDebugFeaturesLabel {
    return Intl.message(
      'Use debug features',
      name: 'developerToggleDebugFeaturesLabel',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Authenticated',
      name: 'developerUserAuthenticatedLabel',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Log out current user',
      name: 'developerUserCurrentLogoutDescription',
      desc: '',
      args: [],
    );
  }

  /// `Refresh session`
  String get developerUserRefreshSessionTitle {
    return Intl.message(
      'Refresh session',
      name: 'developerUserRefreshSessionTitle',
      desc: '',
      args: [],
    );
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
  String get errorContactSupportActionLabel {
    return Intl.message(
      'Contact support',
      name: 'errorContactSupportActionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Error details`
  String get errorDetailsDialogTitle {
    return Intl.message(
      'Error details',
      name: 'errorDetailsDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Internal server error`
  String get errorInternalServerTitle {
    return Intl.message(
      'Internal server error',
      name: 'errorInternalServerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Not found`
  String get errorNotFoundTitle {
    return Intl.message(
      'Not found',
      name: 'errorNotFoundTitle',
      desc: '',
      args: [],
    );
  }

  /// `Share the error`
  String get errorShareActionLabel {
    return Intl.message(
      'Share the error',
      name: 'errorShareActionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Error message has been shared successfully!`
  String get errorShareSuccessMessage {
    return Intl.message(
      'Error message has been shared successfully!',
      name: 'errorShareSuccessMessage',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get errorTitle {
    return Intl.message('Error', name: 'errorTitle', desc: '', args: []);
  }

  /// `Unimplemented`
  String get errorUnimplementedTitle {
    return Intl.message(
      'Unimplemented',
      name: 'errorUnimplementedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get homeTitle {
    return Intl.message('Home', name: 'homeTitle', desc: '', args: []);
  }

  /// `Settings`
  String get profileSettingsTitle {
    return Intl.message(
      'Settings',
      name: 'profileSettingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Change your settings`
  String get profileSettingsDescription {
    return Intl.message(
      'Change your settings',
      name: 'profileSettingsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profileTitle {
    return Intl.message('Profile', name: 'profileTitle', desc: '', args: []);
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
