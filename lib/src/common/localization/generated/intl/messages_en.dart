// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "appLabel": MessageLookupByLibrary.simpleMessage("App"),
    "localeCode": MessageLookupByLibrary.simpleMessage("en"),
    "localeName": MessageLookupByLibrary.simpleMessage("English"),
    "title": MessageLookupByLibrary.simpleMessage("Title"),
    "authGeneratePasswordTooltip": MessageLookupByLibrary.simpleMessage("Generate password"),
    "authLogoutConfirmationMessage": MessageLookupByLibrary.simpleMessage("Are you sure you want to log out?"),
    "authValidationEmailInvalidMessage": MessageLookupByLibrary.simpleMessage("Must be a valid email."),
    "authValidationEmailRequiredMessage": MessageLookupByLibrary.simpleMessage("Email is required."),
    "authValidationPasswordMissingLowercaseMessage": MessageLookupByLibrary.simpleMessage(
      "Password must have at least one lowercase character.",
    ),
    "authValidationPasswordMissingUppercaseMessage": MessageLookupByLibrary.simpleMessage(
      "Password must have at least one uppercase character.",
    ),
    "authValidationPasswordRequiredMessage": MessageLookupByLibrary.simpleMessage("Password is required."),
    "authValidationPasswordTooLongMessage": MessageLookupByLibrary.simpleMessage(
      "Password must be 32 characters or less.",
    ),
    "authValidationPasswordTooShortMessage": MessageLookupByLibrary.simpleMessage(
      "Password must be 8 characters or more.",
    ),
    "backButton": MessageLookupByLibrary.simpleMessage("Back"),
    "bugReportAttachLogsHelpText": MessageLookupByLibrary.simpleMessage(
      "Attaching logs can help us identify and fix the issue faster.",
    ),
    "bugReportAttachLogsToggleLabel": MessageLookupByLibrary.simpleMessage("Attach logs"),
    "bugReportDialogDescription": MessageLookupByLibrary.simpleMessage(
      "Describe the issue you encountered and we will try to fix it as soon as possible.",
    ),
    "bugReportDialogTitle": MessageLookupByLibrary.simpleMessage("Share error"),
    "bugReportShakeToReportToggleHint": MessageLookupByLibrary.simpleMessage(
      "Disable this if you do not want the bug report dialog to appear when the device is shaken.",
    ),
    "bugReportShakeToReportToggleLabel": MessageLookupByLibrary.simpleMessage("Open bug report dialog on shake"),
    "cancelButton": MessageLookupByLibrary.simpleMessage("Cancel"),
    "clearButton": MessageLookupByLibrary.simpleMessage("Clear"),
    "clearKVStorageButton": MessageLookupByLibrary.simpleMessage("Clear key-value storage"),
    "clearLogsButton": MessageLookupByLibrary.simpleMessage("Clear"),
    "copiedMessage": MessageLookupByLibrary.simpleMessage("Copied"),
    "copyToClipboardLabel": MessageLookupByLibrary.simpleMessage("Copy to clipboard"),
    "ofSeparator": MessageLookupByLibrary.simpleMessage("of"),
    "contactSupportButton": MessageLookupByLibrary.simpleMessage("Contact support"),
    "deleteButton": MessageLookupByLibrary.simpleMessage("Delete"),
    "detailsButton": MessageLookupByLibrary.simpleMessage("Details"),
    "developerAppVersionLabel": MessageLookupByLibrary.simpleMessage("App version"),
    "developerApplicationInfoOpenDescription": MessageLookupByLibrary.simpleMessage(
      "Show information about the application.",
    ),
    "developerApplicationInfoTitle": MessageLookupByLibrary.simpleMessage("Application information"),
    "developerDatabaseClearFailureMessage": MessageLookupByLibrary.simpleMessage("Database clear failed"),
    "developerDatabaseClearSuccessMessage": MessageLookupByLibrary.simpleMessage("Database cleared"),
    "developerDatabaseDropDescription": MessageLookupByLibrary.simpleMessage("Clear database content."),
    "developerDatabaseDropTitle": MessageLookupByLibrary.simpleMessage("Drop database"),
    "developerDatabaseOpenDescription": MessageLookupByLibrary.simpleMessage("View database content."),
    "developerDatabaseOpenTitle": MessageLookupByLibrary.simpleMessage("View database"),
    "developerDependenciesOpenDescription": MessageLookupByLibrary.simpleMessage("Show dependencies."),
    "developerDependenciesTitle": MessageLookupByLibrary.simpleMessage("Dependencies"),
    "developerDevDependenciesOpenDescription": MessageLookupByLibrary.simpleMessage("Show developers dependencies."),
    "developerDevDependenciesTitle": MessageLookupByLibrary.simpleMessage("Dev dependencies"),
    "developerDeveloperModeToggleLabel": MessageLookupByLibrary.simpleMessage("Use developer mode"),
    "developerFeatureFlagsDescription": MessageLookupByLibrary.simpleMessage(
      "Advanced options for developers. Use with caution, as they may cause unexpected behavior or crashes.",
    ),
    "developerHapticFeedbackDescription": MessageLookupByLibrary.simpleMessage(
      "Enable haptic feedback in the app. Useful for testing haptic feedback functionality.",
    ),
    "developerHapticFeedbackToggleLabel": MessageLookupByLibrary.simpleMessage("Use haptic feedback"),
    "developerInfoButton": MessageLookupByLibrary.simpleMessage("Developer info"),
    "developerLogsEmptyStateMessage": MessageLookupByLibrary.simpleMessage("No logs yet"),
    "developerLogsOpenDescription": MessageLookupByLibrary.simpleMessage("Show logs."),
    "developerLogsShareDescription": MessageLookupByLibrary.simpleMessage("Share application logs for better support"),
    "developerLogsTitle": MessageLookupByLibrary.simpleMessage("Logs"),
    "developerNavigationResetDescription": MessageLookupByLibrary.simpleMessage("Reset navigation stack."),
    "developerNavigationResetTitle": MessageLookupByLibrary.simpleMessage("Reset navigation"),
    "developerNotificationsRefreshDescription": MessageLookupByLibrary.simpleMessage(
      "Refresh FCM token. Useful for testing push notifications in development builds.",
    ),
    "developerNotificationsRefreshTitle": MessageLookupByLibrary.simpleMessage("Refresh FCM token"),
    "developerSectionApplicationTitle": MessageLookupByLibrary.simpleMessage("Application"),
    "developerSectionAuthenticationTitle": MessageLookupByLibrary.simpleMessage("Authentication"),
    "developerSectionDatabaseTitle": MessageLookupByLibrary.simpleMessage("Database"),
    "developerSectionNavigationTitle": MessageLookupByLibrary.simpleMessage("Navigation"),
    "developerSectionUsefulLinksTitle": MessageLookupByLibrary.simpleMessage("Useful links"),
    "developerSessionsLogoutAllConfirmationMessage": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to log out from all devices?",
    ),
    "developerSessionsLogoutAllDescription": MessageLookupByLibrary.simpleMessage(
      "Log out from all devices. Useful for testing logout functionality or refreshing session on all devices.",
    ),
    "developerStorageClearDescription": MessageLookupByLibrary.simpleMessage(
      "Clear key-value storage. Useful for testing onboarding and promo code flows.",
    ),
    "developerStorageClearSuccessMessage": MessageLookupByLibrary.simpleMessage(
      "Key-value storage cleared successfully",
    ),
    "developerTitle": MessageLookupByLibrary.simpleMessage("Developer"),
    "developerToggleBetaFeaturesLabel": MessageLookupByLibrary.simpleMessage("Use beta features"),
    "developerToggleDebugFeaturesLabel": MessageLookupByLibrary.simpleMessage("Use debug features"),
    "developerToggleExperimentalFeaturesDescription": MessageLookupByLibrary.simpleMessage(
      "Experimental features. Use with caution, as they may cause unexpected behavior or crashes.",
    ),
    "developerToggleExperimentalFeaturesLabel": MessageLookupByLibrary.simpleMessage("Use experimental features"),
    "developerUserAuthenticatedLabel": MessageLookupByLibrary.simpleMessage("Authenticated"),
    "developerUserCurrentInfoDescription": MessageLookupByLibrary.simpleMessage("Information about current user"),
    "developerUserCurrentLogoutDescription": MessageLookupByLibrary.simpleMessage("Log out current user"),
    "developerUserRefreshSessionDescription": MessageLookupByLibrary.simpleMessage("Refresh current user\'s session"),
    "developerUserRefreshSessionTitle": MessageLookupByLibrary.simpleMessage("Refresh session"),
    "editButton": MessageLookupByLibrary.simpleMessage("Edit"),
    "emailPlaceholder": MessageLookupByLibrary.simpleMessage("Enter your email"),
    "emailLabel": MessageLookupByLibrary.simpleMessage("Email"),
    "errorDetailsDialogLabel": MessageLookupByLibrary.simpleMessage("Error details"),
    "errorInternalServerLabel": MessageLookupByLibrary.simpleMessage("Internal server error"),
    "errorNotFoundLabel": MessageLookupByLibrary.simpleMessage("Not found"),
    "shareErrorSuccessMessage": MessageLookupByLibrary.simpleMessage("Error message has been shared successfully!"),
    "errorLabel": MessageLookupByLibrary.simpleMessage("Error"),
    "errorUnimplementedLabel": MessageLookupByLibrary.simpleMessage("Unimplemented"),
    "homeTitle": MessageLookupByLibrary.simpleMessage("Home"),
    "logoutAllDevicesButton": MessageLookupByLibrary.simpleMessage("Log out from all devices"),
    "logoutButton": MessageLookupByLibrary.simpleMessage("Log Out"),
    "nameLabel": MessageLookupByLibrary.simpleMessage("Name"),
    "passwordPlaceholder": MessageLookupByLibrary.simpleMessage("Enter your password"),
    "passwordLabel": MessageLookupByLibrary.simpleMessage("Password"),
    "profileSettingsDescription": MessageLookupByLibrary.simpleMessage("Change your settings"),
    "profileSettingsTitle": MessageLookupByLibrary.simpleMessage("Settings"),
    "profileTitle": MessageLookupByLibrary.simpleMessage("Profile"),
    "selectedLabel": MessageLookupByLibrary.simpleMessage("Selected"),
    "sendLogsButton": MessageLookupByLibrary.simpleMessage("Send logs"),
    "shareErrorButton": MessageLookupByLibrary.simpleMessage("Share the error"),
    "signInButton": MessageLookupByLibrary.simpleMessage("Sign In"),
    "signUpButton": MessageLookupByLibrary.simpleMessage("Sign Up"),
    "sizeLabel": MessageLookupByLibrary.simpleMessage("Size"),
    "statusLabel": MessageLookupByLibrary.simpleMessage("Status"),
    "storageLabel": MessageLookupByLibrary.simpleMessage("Storage"),
    "submitReportButton": MessageLookupByLibrary.simpleMessage("Send report"),
    "timeLabel": MessageLookupByLibrary.simpleMessage("Time"),
    "typeLabel": MessageLookupByLibrary.simpleMessage("Type"),
    "versionLabel": MessageLookupByLibrary.simpleMessage("Version"),
  };
}
