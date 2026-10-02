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
    return Intl.message(
      'Enter your email',
      name: 'emailPlaceholder',
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
  String get logoutButton {
    return Intl.message('Log Out', name: 'logoutButton', desc: '', args: []);
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
  String get passwordLabel {
    return Intl.message('Password', name: 'passwordLabel', desc: '', args: []);
  }

  /// `Enter your password`
  String get passwordPlaceholder {
    return Intl.message(
      'Enter your password',
      name: 'passwordPlaceholder',
      desc: '',
      args: [],
    );
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
  String get submitReportButton {
    return Intl.message(
      'Send report',
      name: 'submitReportButton',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Copy to clipboard',
      name: 'copyToClipboardLabel',
      desc: '',
      args: [],
    );
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

  /// `of`
  String get ofSeparator {
    return Intl.message('of', name: 'ofSeparator', desc: '', args: []);
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
  String get developerInfoButton {
    return Intl.message(
      'Developer info',
      name: 'developerInfoButton',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get clearLogsButton {
    return Intl.message('Clear', name: 'clearLogsButton', desc: '', args: []);
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
  String get sendLogsButton {
    return Intl.message(
      'Send logs',
      name: 'sendLogsButton',
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
  String get logoutAllDevicesButton {
    return Intl.message(
      'Log out from all devices',
      name: 'logoutAllDevicesButton',
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
  String get clearKVStorageButton {
    return Intl.message(
      'Clear key-value storage',
      name: 'clearKVStorageButton',
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

  /// `Error`
  String get errorLabel {
    return Intl.message('Error', name: 'errorLabel', desc: '', args: []);
  }

  /// `Not found`
  String get errorNotFoundLabel {
    return Intl.message(
      'Not found',
      name: 'errorNotFoundLabel',
      desc: '',
      args: [],
    );
  }

  /// `Unimplemented`
  String get errorUnimplementedLabel {
    return Intl.message(
      'Unimplemented',
      name: 'errorUnimplementedLabel',
      desc: '',
      args: [],
    );
  }

  /// `Error details`
  String get errorDetailsDialogLabel {
    return Intl.message(
      'Error details',
      name: 'errorDetailsDialogLabel',
      desc: '',
      args: [],
    );
  }

  /// `Internal server error`
  String get errorInternalServerLabel {
    return Intl.message(
      'Internal server error',
      name: 'errorInternalServerLabel',
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

  /// `Error message has been shared successfully!`
  String get shareErrorSuccessMessage {
    return Intl.message(
      'Error message has been shared successfully!',
      name: 'shareErrorSuccessMessage',
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

  /// `Account and device`
  String get developerAccountAndDeviceSectionTitle {
    return Intl.message(
      'Account and device',
      name: 'developerAccountAndDeviceSectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Preview loading, success, and error states`
  String get developerActivityStatusOverlayDescription {
    return Intl.message(
      'Preview loading, success, and error states',
      name: 'developerActivityStatusOverlayDescription',
      desc: '',
      args: [],
    );
  }

  /// `Status indicator`
  String get developerActivityStatusOverlayTitle {
    return Intl.message(
      'Status indicator',
      name: 'developerActivityStatusOverlayTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enable or disable access to debug mode and developer settings`
  String get developerAdvancedOptionsHint {
    return Intl.message(
      'Enable or disable access to debug mode and developer settings',
      name: 'developerAdvancedOptionsHint',
      desc: '',
      args: [],
    );
  }

  /// `Beta version`
  String get developerAdvancedOptionsUseBetaLabel {
    return Intl.message(
      'Beta version',
      name: 'developerAdvancedOptionsUseBetaLabel',
      desc: '',
      args: [],
    );
  }

  /// `Debug mode`
  String get developerAdvancedOptionsUseDebugLabel {
    return Intl.message(
      'Debug mode',
      name: 'developerAdvancedOptionsUseDebugLabel',
      desc: '',
      args: [],
    );
  }

  /// `Developer mode`
  String get developerAdvancedOptionsUseDeveloperModeLabel {
    return Intl.message(
      'Developer mode',
      name: 'developerAdvancedOptionsUseDeveloperModeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Experimental features`
  String get developerAdvancedOptionsUseExperementalLabel {
    return Intl.message(
      'Experimental features',
      name: 'developerAdvancedOptionsUseExperementalLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enable or disable haptic feedback (vibration) on supported devices`
  String get developerAdvancedOptionsUseHapticFeedbackHint {
    return Intl.message(
      'Enable or disable haptic feedback (vibration) on supported devices',
      name: 'developerAdvancedOptionsUseHapticFeedbackHint',
      desc: '',
      args: [],
    );
  }

  /// `Haptic feedback`
  String get developerAdvancedOptionsUseHapticFeedbackLabel {
    return Intl.message(
      'Haptic feedback',
      name: 'developerAdvancedOptionsUseHapticFeedbackLabel',
      desc: '',
      args: [],
    );
  }

  /// `Send app usage events`
  String get developerAnalyticsDataSendingDescription {
    return Intl.message(
      'Send app usage events',
      name: 'developerAnalyticsDataSendingDescription',
      desc: '',
      args: [],
    );
  }

  /// `Analytics data sending`
  String get developerAnalyticsDataSendingLabel {
    return Intl.message(
      'Analytics data sending',
      name: 'developerAnalyticsDataSendingLabel',
      desc: '',
      args: [],
    );
  }

  /// `Runtime and build information for debugging and support`
  String get developerAppMetadataDescription {
    return Intl.message(
      'Runtime and build information for debugging and support',
      name: 'developerAppMetadataDescription',
      desc: '',
      args: [],
    );
  }

  /// `Application metadata`
  String get developerAppMetadataTitle {
    return Intl.message(
      'Application metadata',
      name: 'developerAppMetadataTitle',
      desc: '',
      args: [],
    );
  }

  /// `Application`
  String get developerApplicationSectionTitle {
    return Intl.message(
      'Application',
      name: 'developerApplicationSectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Show error report dialog`
  String get developerBugReportDialogDescription {
    return Intl.message(
      'Show error report dialog',
      name: 'developerBugReportDialogDescription',
      desc: '',
      args: [],
    );
  }

  /// `Clear local database`
  String get developerClearKVStorageButton {
    return Intl.message(
      'Clear local database',
      name: 'developerClearKVStorageButton',
      desc: '',
      args: [],
    );
  }

  /// `Clear the local database, it will not affect the main functionality of the app`
  String get developerClearKVStorageHint {
    return Intl.message(
      'Clear the local database, it will not affect the main functionality of the app',
      name: 'developerClearKVStorageHint',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get developerClearLogsButton {
    return Intl.message(
      'Clear',
      name: 'developerClearLogsButton',
      desc: '',
      args: [],
    );
  }

  /// `Show confirmation of unsaved changes`
  String get developerConfirmationDialogDescription {
    return Intl.message(
      'Show confirmation of unsaved changes',
      name: 'developerConfirmationDialogDescription',
      desc: '',
      args: [],
    );
  }

  /// `Confirmation dialog`
  String get developerConfirmationDialogTitle {
    return Intl.message(
      'Confirmation dialog',
      name: 'developerConfirmationDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Switching between light and dark theme`
  String get developerDarkModeDescription {
    return Intl.message(
      'Switching between light and dark theme',
      name: 'developerDarkModeDescription',
      desc: '',
      args: [],
    );
  }

  /// `Dark theme`
  String get developerDarkModeLabel {
    return Intl.message(
      'Dark theme',
      name: 'developerDarkModeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Developer Information`
  String get developerDeveloperInfoButton {
    return Intl.message(
      'Developer Information',
      name: 'developerDeveloperInfoButton',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get developerErrorPreviewLabel {
    return Intl.message(
      'Error',
      name: 'developerErrorPreviewLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enable or disable access to experimental features and beta versions of the app`
  String get developerExperimentalHint {
    return Intl.message(
      'Enable or disable access to experimental features and beta versions of the app',
      name: 'developerExperimentalHint',
      desc: '',
      args: [],
    );
  }

  /// `Push notification token`
  String get developerFcmPushTokenDescription {
    return Intl.message(
      'Push notification token',
      name: 'developerFcmPushTokenDescription',
      desc: '',
      args: [],
    );
  }

  /// `FCM Push Token`
  String get developerFcmPushTokenLabel {
    return Intl.message(
      'FCM Push Token',
      name: 'developerFcmPushTokenLabel',
      desc: '',
      args: [],
    );
  }

  /// `Preview glass styling for the log toolbar. This is a Flutter effect, not native Liquid Glass.`
  String get developerIOS26LiquidThemeHint {
    return Intl.message(
      'Preview glass styling for the log toolbar. This is a Flutter effect, not native Liquid Glass.',
      name: 'developerIOS26LiquidThemeHint',
      desc: '',
      args: [],
    );
  }

  /// `Liquid Theme iOS 26`
  String get developerIOS26LiquidThemeLabel {
    return Intl.message(
      'Liquid Theme iOS 26',
      name: 'developerIOS26LiquidThemeLabel',
      desc: '',
      args: [],
    );
  }

  /// `The color of the sector indicates speed: blue is the fastest stage, red is the slowest.`
  String get developerInitializationHeatMapDescription {
    return Intl.message(
      'The color of the sector indicates speed: blue is the fastest stage, red is the slowest.',
      name: 'developerInitializationHeatMapDescription',
      desc: '',
      args: [],
    );
  }

  /// `Duration of each launch stage`
  String get developerInitializationStatsDescription {
    return Intl.message(
      'Duration of each launch stage',
      name: 'developerInitializationStatsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Time data will appear after launching the application with measurement.`
  String get developerInitializationStatsEmptyDescription {
    return Intl.message(
      'Time data will appear after launching the application with measurement.',
      name: 'developerInitializationStatsEmptyDescription',
      desc: '',
      args: [],
    );
  }

  /// `No initialization data`
  String get developerInitializationStatsEmptyTitle {
    return Intl.message(
      'No initialization data',
      name: 'developerInitializationStatsEmptyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Initialization statistics`
  String get developerInitializationStatsTitle {
    return Intl.message(
      'Initialization statistics',
      name: 'developerInitializationStatsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Total · {count, plural, =1{{count} stage} few{{count} stage} other{{count} stages}}`
  String developerInitializationStatsTotalMessageOf(num count) {
    return Intl.message(
      'Total · ${Intl.plural(count, one: '$count stage', few: '$count stage', other: '$count stages')}',
      name: 'developerInitializationStatsTotalMessageOf',
      desc: '',
      args: [count],
    );
  }

  /// `Log out`
  String get developerLogoutButton {
    return Intl.message(
      'Log out',
      name: 'developerLogoutButton',
      desc: '',
      args: [],
    );
  }

  /// `Sign out of the current application session.`
  String get developerLogoutHint {
    return Intl.message(
      'Sign out of the current application session.',
      name: 'developerLogoutHint',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out from all devices?`
  String get developerLogoutSubtitle {
    return Intl.message(
      'Are you sure you want to log out from all devices?',
      name: 'developerLogoutSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `No logs`
  String get developerLogsEmptyLabel {
    return Intl.message(
      'No logs',
      name: 'developerLogsEmptyLabel',
      desc: '',
      args: [],
    );
  }

  /// `Logs`
  String get developerLogsLabel {
    return Intl.message('Logs', name: 'developerLogsLabel', desc: '', args: []);
  }

  /// `URL API`
  String get developerMetadataApiURLLabel {
    return Intl.message(
      'URL API',
      name: 'developerMetadataApiURLLabel',
      desc: '',
      args: [],
    );
  }

  /// `Debugging`
  String get developerMetadataBuildModeDebugLabel {
    return Intl.message(
      'Debugging',
      name: 'developerMetadataBuildModeDebugLabel',
      desc: '',
      args: [],
    );
  }

  /// `Build mode`
  String get developerMetadataBuildModeLabel {
    return Intl.message(
      'Build mode',
      name: 'developerMetadataBuildModeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Release`
  String get developerMetadataBuildModeReleaseLabel {
    return Intl.message(
      'Release',
      name: 'developerMetadataBuildModeReleaseLabel',
      desc: '',
      args: [],
    );
  }

  /// `Assembly time`
  String get developerMetadataBuildTimestampLabel {
    return Intl.message(
      'Assembly time',
      name: 'developerMetadataBuildTimestampLabel',
      desc: '',
      args: [],
    );
  }

  /// `Processors`
  String get developerMetadataCPULabel {
    return Intl.message(
      'Processors',
      name: 'developerMetadataCPULabel',
      desc: '',
      args: [],
    );
  }

  /// `Current locale`
  String get developerMetadataCurrentLocaleLabel {
    return Intl.message(
      'Current locale',
      name: 'developerMetadataCurrentLocaleLabel',
      desc: '',
      args: [],
    );
  }

  /// `Device pixel ratio`
  String get developerMetadataDevicePixelRatioLabel {
    return Intl.message(
      'Device pixel ratio',
      name: 'developerMetadataDevicePixelRatioLabel',
      desc: '',
      args: [],
    );
  }

  /// `Device screen size`
  String get developerMetadataDeviceScreenSizeLabel {
    return Intl.message(
      'Device screen size',
      name: 'developerMetadataDeviceScreenSizeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Display Features`
  String get developerMetadataDisplayFeaturesLabel {
    return Intl.message(
      'Display Features',
      name: 'developerMetadataDisplayFeaturesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Displays`
  String get developerMetadataDisplaysLabel {
    return Intl.message(
      'Displays',
      name: 'developerMetadataDisplaysLabel',
      desc: '',
      args: [],
    );
  }

  /// `Environment`
  String get developerMetadataEnvironmentLabel {
    return Intl.message(
      'Environment',
      name: 'developerMetadataEnvironmentLabel',
      desc: '',
      args: [],
    );
  }

  /// `Google Mobile Services`
  String get developerMetadataGoogleMobileServicesLabel {
    return Intl.message(
      'Google Mobile Services',
      name: 'developerMetadataGoogleMobileServicesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Huawei Mobile Services`
  String get developerMetadataHuaweiMobileServicesLabel {
    return Intl.message(
      'Huawei Mobile Services',
      name: 'developerMetadataHuaweiMobileServicesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Launch time`
  String get developerMetadataLaunchedTimestampLabel {
    return Intl.message(
      'Launch time',
      name: 'developerMetadataLaunchedTimestampLabel',
      desc: '',
      args: [],
    );
  }

  /// `Logical size`
  String get developerMetadataLogicalSizeLabel {
    return Intl.message(
      'Logical size',
      name: 'developerMetadataLogicalSizeLabel',
      desc: '',
      args: [],
    );
  }

  /// `operating system`
  String get developerMetadataOperationSystemLabel {
    return Intl.message(
      'operating system',
      name: 'developerMetadataOperationSystemLabel',
      desc: '',
      args: [],
    );
  }

  /// `Operating system manufacturer`
  String get developerMetadataOperationSystemManufacturerLabel {
    return Intl.message(
      'Operating system manufacturer',
      name: 'developerMetadataOperationSystemManufacturerLabel',
      desc: '',
      args: [],
    );
  }

  /// `Indents`
  String get developerMetadataPaddingLabel {
    return Intl.message(
      'Indents',
      name: 'developerMetadataPaddingLabel',
      desc: '',
      args: [],
    );
  }

  /// `Physical size`
  String get developerMetadataPhysicalSizeLabel {
    return Intl.message(
      'Physical size',
      name: 'developerMetadataPhysicalSizeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Platform brightness`
  String get developerMetadataPlatformBrightnessLabel {
    return Intl.message(
      'Platform brightness',
      name: 'developerMetadataPlatformBrightnessLabel',
      desc: '',
      args: [],
    );
  }

  /// `Platform locale`
  String get developerMetadataPlatformLocaleLabel {
    return Intl.message(
      'Platform locale',
      name: 'developerMetadataPlatformLocaleLabel',
      desc: '',
      args: [],
    );
  }

  /// `Platform locales`
  String get developerMetadataPlatformLocalesLabel {
    return Intl.message(
      'Platform locales',
      name: 'developerMetadataPlatformLocalesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Platform version`
  String get developerMetadataPlatformVersionLabel {
    return Intl.message(
      'Platform version',
      name: 'developerMetadataPlatformVersionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Sentry`
  String get developerMetadataSentryLabel {
    return Intl.message(
      'Sentry',
      name: 'developerMetadataSentryLabel',
      desc: '',
      args: [],
    );
  }

  /// `Supported locales`
  String get developerMetadataSupportedLocalesLabel {
    return Intl.message(
      'Supported locales',
      name: 'developerMetadataSupportedLocalesLabel',
      desc: '',
      args: [],
    );
  }

  /// `System gesture indents`
  String get developerMetadataSystemGestureInsetsLabel {
    return Intl.message(
      'System gesture indents',
      name: 'developerMetadataSystemGestureInsetsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Text scale`
  String get developerMetadataTextScaleFactorLabel {
    return Intl.message(
      'Text scale',
      name: 'developerMetadataTextScaleFactorLabel',
      desc: '',
      args: [],
    );
  }

  /// `Presentation indents`
  String get developerMetadataViewInsetsLabel {
    return Intl.message(
      'Presentation indents',
      name: 'developerMetadataViewInsetsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Yandex Metrica`
  String get developerMetadataYandexMetricaLabel {
    return Intl.message(
      'Yandex Metrica',
      name: 'developerMetadataYandexMetricaLabel',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get developerNoDisplayFeaturesLabel {
    return Intl.message(
      'No',
      name: 'developerNoDisplayFeaturesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Token is unavailable`
  String get developerNoTokenAvailableLabel {
    return Intl.message(
      'Token is unavailable',
      name: 'developerNoTokenAvailableLabel',
      desc: '',
      args: [],
    );
  }

  /// `Select a state to preview`
  String get developerPreviewSelectStateDescription {
    return Intl.message(
      'Select a state to preview',
      name: 'developerPreviewSelectStateDescription',
      desc: '',
      args: [],
    );
  }

  /// `Loading`
  String get developerProcessingPreviewLabel {
    return Intl.message(
      'Loading',
      name: 'developerProcessingPreviewLabel',
      desc: '',
      args: [],
    );
  }

  /// `Send logs`
  String get developerSendLogsButton {
    return Intl.message(
      'Send logs',
      name: 'developerSendLogsButton',
      desc: '',
      args: [],
    );
  }

  /// `Sending logs`
  String get developerSendLogsMessage {
    return Intl.message(
      'Sending logs',
      name: 'developerSendLogsMessage',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get developerSendLogsMessageError {
    return Intl.message(
      'Error',
      name: 'developerSendLogsMessageError',
      desc: '',
      args: [],
    );
  }

  /// `Logs sent!`
  String get developerSendLogsMessageSuccess {
    return Intl.message(
      'Logs sent!',
      name: 'developerSendLogsMessageSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Show logs`
  String get developerShowLogsButton {
    return Intl.message(
      'Show logs',
      name: 'developerShowLogsButton',
      desc: '',
      args: [],
    );
  }

  /// `Demo error notification`
  String get developerSnackbarErrorPreviewMessage {
    return Intl.message(
      'Demo error notification',
      name: 'developerSnackbarErrorPreviewMessage',
      desc: '',
      args: [],
    );
  }

  /// `Previewing successful and error notifications`
  String get developerSnackbarGalleryDescription {
    return Intl.message(
      'Previewing successful and error notifications',
      name: 'developerSnackbarGalleryDescription',
      desc: '',
      args: [],
    );
  }

  /// `Notification Gallery`
  String get developerSnackbarGalleryTitle {
    return Intl.message(
      'Notification Gallery',
      name: 'developerSnackbarGalleryTitle',
      desc: '',
      args: [],
    );
  }

  /// `Demo successful notification`
  String get developerSnackbarSuccessPreviewMessage {
    return Intl.message(
      'Demo successful notification',
      name: 'developerSnackbarSuccessPreviewMessage',
      desc: '',
      args: [],
    );
  }

  /// `Successfully`
  String get developerSuccessPreviewLabel {
    return Intl.message(
      'Successfully',
      name: 'developerSuccessPreviewLabel',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get developerTotalLabel {
    return Intl.message(
      'Total',
      name: 'developerTotalLabel',
      desc: '',
      args: [],
    );
  }

  /// `UI scripts`
  String get developerUiFlowsSectionTitle {
    return Intl.message(
      'UI scripts',
      name: 'developerUiFlowsSectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `User ID`
  String get developerUserIDLabel {
    return Intl.message(
      'User ID',
      name: 'developerUserIDLabel',
      desc: '',
      args: [],
    );
  }

  /// `Information about the current user`
  String get developerUserInformationDescription {
    return Intl.message(
      'Information about the current user',
      name: 'developerUserInformationDescription',
      desc: '',
      args: [],
    );
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
