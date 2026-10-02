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

  static String m0(count) =>
      "Total · ${Intl.plural(count, one: '${count} stage', few: '${count} stage', other: '${count} stages')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "appLabel": MessageLookupByLibrary.simpleMessage("App"),
    "authGeneratePasswordTooltip": MessageLookupByLibrary.simpleMessage(
      "Generate password",
    ),
    "authLogoutConfirmationMessage": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to log out?",
    ),
    "authValidationEmailInvalidMessage": MessageLookupByLibrary.simpleMessage(
      "Must be a valid email.",
    ),
    "authValidationEmailRequiredMessage": MessageLookupByLibrary.simpleMessage(
      "Email is required.",
    ),
    "authValidationPasswordMissingLowercaseMessage":
        MessageLookupByLibrary.simpleMessage(
          "Password must have at least one lowercase character.",
        ),
    "authValidationPasswordMissingUppercaseMessage":
        MessageLookupByLibrary.simpleMessage(
          "Password must have at least one uppercase character.",
        ),
    "authValidationPasswordRequiredMessage":
        MessageLookupByLibrary.simpleMessage("Password is required."),
    "authValidationPasswordTooLongMessage":
        MessageLookupByLibrary.simpleMessage(
          "Password must be 32 characters or less.",
        ),
    "authValidationPasswordTooShortMessage":
        MessageLookupByLibrary.simpleMessage(
          "Password must be 8 characters or more.",
        ),
    "backButton": MessageLookupByLibrary.simpleMessage("Back"),
    "bugReportAttachLogsHelpText": MessageLookupByLibrary.simpleMessage(
      "Attaching logs can help us identify and fix the issue faster.",
    ),
    "bugReportAttachLogsToggleLabel": MessageLookupByLibrary.simpleMessage(
      "Attach logs",
    ),
    "bugReportDialogDescription": MessageLookupByLibrary.simpleMessage(
      "Describe the issue you encountered and we will try to fix it as soon as possible.",
    ),
    "bugReportDialogTitle": MessageLookupByLibrary.simpleMessage("Share error"),
    "bugReportShakeToReportToggleHint": MessageLookupByLibrary.simpleMessage(
      "Disable this if you do not want the bug report dialog to appear when the device is shaken.",
    ),
    "bugReportShakeToReportToggleLabel": MessageLookupByLibrary.simpleMessage(
      "Open bug report dialog on shake",
    ),
    "cancelButton": MessageLookupByLibrary.simpleMessage("Cancel"),
    "clearButton": MessageLookupByLibrary.simpleMessage("Clear"),
    "clearKVStorageButton": MessageLookupByLibrary.simpleMessage(
      "Clear key-value storage",
    ),
    "clearLogsButton": MessageLookupByLibrary.simpleMessage("Clear"),
    "contactSupportButton": MessageLookupByLibrary.simpleMessage(
      "Contact support",
    ),
    "copiedMessage": MessageLookupByLibrary.simpleMessage("Copied"),
    "copyToClipboardLabel": MessageLookupByLibrary.simpleMessage(
      "Copy to clipboard",
    ),
    "deleteButton": MessageLookupByLibrary.simpleMessage("Delete"),
    "detailsButton": MessageLookupByLibrary.simpleMessage("Details"),
    "developerAccountAndDeviceSectionTitle":
        MessageLookupByLibrary.simpleMessage("Account and device"),
    "developerActivityStatusOverlayDescription":
        MessageLookupByLibrary.simpleMessage(
          "Preview loading, success, and error states",
        ),
    "developerActivityStatusOverlayTitle": MessageLookupByLibrary.simpleMessage(
      "Status indicator",
    ),
    "developerAdvancedOptionsHint": MessageLookupByLibrary.simpleMessage(
      "Enable or disable access to debug mode and developer settings",
    ),
    "developerAdvancedOptionsUseBetaLabel":
        MessageLookupByLibrary.simpleMessage("Beta version"),
    "developerAdvancedOptionsUseDebugLabel":
        MessageLookupByLibrary.simpleMessage("Debug mode"),
    "developerAdvancedOptionsUseDeveloperModeLabel":
        MessageLookupByLibrary.simpleMessage("Developer mode"),
    "developerAdvancedOptionsUseExperementalLabel":
        MessageLookupByLibrary.simpleMessage("Experimental features"),
    "developerAdvancedOptionsUseHapticFeedbackHint":
        MessageLookupByLibrary.simpleMessage(
          "Enable or disable haptic feedback (vibration) on supported devices",
        ),
    "developerAdvancedOptionsUseHapticFeedbackLabel":
        MessageLookupByLibrary.simpleMessage("Haptic feedback"),
    "developerAnalyticsDataSendingDescription":
        MessageLookupByLibrary.simpleMessage("Send app usage events"),
    "developerAnalyticsDataSendingLabel": MessageLookupByLibrary.simpleMessage(
      "Analytics data sending",
    ),
    "developerAppMetadataDescription": MessageLookupByLibrary.simpleMessage(
      "Runtime and build information for debugging and support",
    ),
    "developerAppMetadataTitle": MessageLookupByLibrary.simpleMessage(
      "Application metadata",
    ),
    "developerAppVersionLabel": MessageLookupByLibrary.simpleMessage(
      "App version",
    ),
    "developerApplicationInfoOpenDescription":
        MessageLookupByLibrary.simpleMessage(
          "Show information about the application.",
        ),
    "developerApplicationInfoTitle": MessageLookupByLibrary.simpleMessage(
      "Application information",
    ),
    "developerApplicationSectionTitle": MessageLookupByLibrary.simpleMessage(
      "Application",
    ),
    "developerBugReportDialogDescription": MessageLookupByLibrary.simpleMessage(
      "Show error report dialog",
    ),
    "developerClearKVStorageButton": MessageLookupByLibrary.simpleMessage(
      "Clear local database",
    ),
    "developerClearKVStorageHint": MessageLookupByLibrary.simpleMessage(
      "Clear the local database, it will not affect the main functionality of the app",
    ),
    "developerClearLogsButton": MessageLookupByLibrary.simpleMessage("Clear"),
    "developerConfirmationDialogDescription":
        MessageLookupByLibrary.simpleMessage(
          "Show confirmation of unsaved changes",
        ),
    "developerConfirmationDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Confirmation dialog",
    ),
    "developerDarkModeDescription": MessageLookupByLibrary.simpleMessage(
      "Switching between light and dark theme",
    ),
    "developerDarkModeLabel": MessageLookupByLibrary.simpleMessage(
      "Dark theme",
    ),
    "developerDatabaseClearFailureMessage":
        MessageLookupByLibrary.simpleMessage("Database clear failed"),
    "developerDatabaseClearSuccessMessage":
        MessageLookupByLibrary.simpleMessage("Database cleared"),
    "developerDatabaseDropDescription": MessageLookupByLibrary.simpleMessage(
      "Clear database content.",
    ),
    "developerDatabaseDropTitle": MessageLookupByLibrary.simpleMessage(
      "Drop database",
    ),
    "developerDatabaseOpenDescription": MessageLookupByLibrary.simpleMessage(
      "View database content.",
    ),
    "developerDatabaseOpenTitle": MessageLookupByLibrary.simpleMessage(
      "View database",
    ),
    "developerDependenciesOpenDescription":
        MessageLookupByLibrary.simpleMessage("Show dependencies."),
    "developerDependenciesTitle": MessageLookupByLibrary.simpleMessage(
      "Dependencies",
    ),
    "developerDevDependenciesOpenDescription":
        MessageLookupByLibrary.simpleMessage("Show developers dependencies."),
    "developerDevDependenciesTitle": MessageLookupByLibrary.simpleMessage(
      "Dev dependencies",
    ),
    "developerDeveloperInfoButton": MessageLookupByLibrary.simpleMessage(
      "Developer Information",
    ),
    "developerDeveloperModeToggleLabel": MessageLookupByLibrary.simpleMessage(
      "Use developer mode",
    ),
    "developerErrorPreviewLabel": MessageLookupByLibrary.simpleMessage("Error"),
    "developerExperimentalHint": MessageLookupByLibrary.simpleMessage(
      "Enable or disable access to experimental features and beta versions of the app",
    ),
    "developerFcmPushTokenDescription": MessageLookupByLibrary.simpleMessage(
      "Push notification token",
    ),
    "developerFcmPushTokenLabel": MessageLookupByLibrary.simpleMessage(
      "FCM Push Token",
    ),
    "developerFeatureFlagsDescription": MessageLookupByLibrary.simpleMessage(
      "Advanced options for developers. Use with caution, as they may cause unexpected behavior or crashes.",
    ),
    "developerHapticFeedbackDescription": MessageLookupByLibrary.simpleMessage(
      "Enable haptic feedback in the app. Useful for testing haptic feedback functionality.",
    ),
    "developerHapticFeedbackToggleLabel": MessageLookupByLibrary.simpleMessage(
      "Use haptic feedback",
    ),
    "developerIOS26LiquidThemeHint": MessageLookupByLibrary.simpleMessage(
      "Preview glass styling for the log toolbar. This is a Flutter effect, not native Liquid Glass.",
    ),
    "developerIOS26LiquidThemeLabel": MessageLookupByLibrary.simpleMessage(
      "Liquid Theme iOS 26",
    ),
    "developerInfoButton": MessageLookupByLibrary.simpleMessage(
      "Developer info",
    ),
    "developerInitializationHeatMapDescription":
        MessageLookupByLibrary.simpleMessage(
          "The color of the sector indicates speed: blue is the fastest stage, red is the slowest.",
        ),
    "developerInitializationStatsDescription":
        MessageLookupByLibrary.simpleMessage("Duration of each launch stage"),
    "developerInitializationStatsEmptyDescription":
        MessageLookupByLibrary.simpleMessage(
          "Time data will appear after launching the application with measurement.",
        ),
    "developerInitializationStatsEmptyTitle":
        MessageLookupByLibrary.simpleMessage("No initialization data"),
    "developerInitializationStatsTitle": MessageLookupByLibrary.simpleMessage(
      "Initialization statistics",
    ),
    "developerInitializationStatsTotalMessageOf": m0,
    "developerLogoutButton": MessageLookupByLibrary.simpleMessage("Log out"),
    "developerLogoutHint": MessageLookupByLibrary.simpleMessage(
      "Sign out of the current application session.",
    ),
    "developerLogoutSubtitle": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to log out from all devices?",
    ),
    "developerLogsEmptyLabel": MessageLookupByLibrary.simpleMessage("No logs"),
    "developerLogsEmptyStateMessage": MessageLookupByLibrary.simpleMessage(
      "No logs yet",
    ),
    "developerLogsLabel": MessageLookupByLibrary.simpleMessage("Logs"),
    "developerLogsOpenDescription": MessageLookupByLibrary.simpleMessage(
      "Show logs.",
    ),
    "developerLogsShareDescription": MessageLookupByLibrary.simpleMessage(
      "Share application logs for better support",
    ),
    "developerLogsTitle": MessageLookupByLibrary.simpleMessage("Logs"),
    "developerMetadataApiURLLabel": MessageLookupByLibrary.simpleMessage(
      "URL API",
    ),
    "developerMetadataBuildModeDebugLabel":
        MessageLookupByLibrary.simpleMessage("Debugging"),
    "developerMetadataBuildModeLabel": MessageLookupByLibrary.simpleMessage(
      "Build mode",
    ),
    "developerMetadataBuildModeReleaseLabel":
        MessageLookupByLibrary.simpleMessage("Release"),
    "developerMetadataBuildTimestampLabel":
        MessageLookupByLibrary.simpleMessage("Assembly time"),
    "developerMetadataCPULabel": MessageLookupByLibrary.simpleMessage(
      "Processors",
    ),
    "developerMetadataCurrentLocaleLabel": MessageLookupByLibrary.simpleMessage(
      "Current locale",
    ),
    "developerMetadataDevicePixelRatioLabel":
        MessageLookupByLibrary.simpleMessage("Device pixel ratio"),
    "developerMetadataDeviceScreenSizeLabel":
        MessageLookupByLibrary.simpleMessage("Device screen size"),
    "developerMetadataDisplayFeaturesLabel":
        MessageLookupByLibrary.simpleMessage("Display Features"),
    "developerMetadataDisplaysLabel": MessageLookupByLibrary.simpleMessage(
      "Displays",
    ),
    "developerMetadataEnvironmentLabel": MessageLookupByLibrary.simpleMessage(
      "Environment",
    ),
    "developerMetadataGoogleMobileServicesLabel":
        MessageLookupByLibrary.simpleMessage("Google Mobile Services"),
    "developerMetadataHuaweiMobileServicesLabel":
        MessageLookupByLibrary.simpleMessage("Huawei Mobile Services"),
    "developerMetadataLaunchedTimestampLabel":
        MessageLookupByLibrary.simpleMessage("Launch time"),
    "developerMetadataLogicalSizeLabel": MessageLookupByLibrary.simpleMessage(
      "Logical size",
    ),
    "developerMetadataOperationSystemLabel":
        MessageLookupByLibrary.simpleMessage("operating system"),
    "developerMetadataOperationSystemManufacturerLabel":
        MessageLookupByLibrary.simpleMessage("Operating system manufacturer"),
    "developerMetadataPaddingLabel": MessageLookupByLibrary.simpleMessage(
      "Indents",
    ),
    "developerMetadataPhysicalSizeLabel": MessageLookupByLibrary.simpleMessage(
      "Physical size",
    ),
    "developerMetadataPlatformBrightnessLabel":
        MessageLookupByLibrary.simpleMessage("Platform brightness"),
    "developerMetadataPlatformLocaleLabel":
        MessageLookupByLibrary.simpleMessage("Platform locale"),
    "developerMetadataPlatformLocalesLabel":
        MessageLookupByLibrary.simpleMessage("Platform locales"),
    "developerMetadataPlatformVersionLabel":
        MessageLookupByLibrary.simpleMessage("Platform version"),
    "developerMetadataSentryLabel": MessageLookupByLibrary.simpleMessage(
      "Sentry",
    ),
    "developerMetadataSupportedLocalesLabel":
        MessageLookupByLibrary.simpleMessage("Supported locales"),
    "developerMetadataSystemGestureInsetsLabel":
        MessageLookupByLibrary.simpleMessage("System gesture indents"),
    "developerMetadataTextScaleFactorLabel":
        MessageLookupByLibrary.simpleMessage("Text scale"),
    "developerMetadataViewInsetsLabel": MessageLookupByLibrary.simpleMessage(
      "Presentation indents",
    ),
    "developerMetadataYandexMetricaLabel": MessageLookupByLibrary.simpleMessage(
      "Yandex Metrica",
    ),
    "developerNavigationResetDescription": MessageLookupByLibrary.simpleMessage(
      "Reset navigation stack.",
    ),
    "developerNavigationResetTitle": MessageLookupByLibrary.simpleMessage(
      "Reset navigation",
    ),
    "developerNoDisplayFeaturesLabel": MessageLookupByLibrary.simpleMessage(
      "No",
    ),
    "developerNoTokenAvailableLabel": MessageLookupByLibrary.simpleMessage(
      "Token is unavailable",
    ),
    "developerNotificationsRefreshDescription":
        MessageLookupByLibrary.simpleMessage(
          "Refresh FCM token. Useful for testing push notifications in development builds.",
        ),
    "developerNotificationsRefreshTitle": MessageLookupByLibrary.simpleMessage(
      "Refresh FCM token",
    ),
    "developerPreviewSelectStateDescription":
        MessageLookupByLibrary.simpleMessage("Select a state to preview"),
    "developerProcessingPreviewLabel": MessageLookupByLibrary.simpleMessage(
      "Loading",
    ),
    "developerSectionApplicationTitle": MessageLookupByLibrary.simpleMessage(
      "Application",
    ),
    "developerSectionAuthenticationTitle": MessageLookupByLibrary.simpleMessage(
      "Authentication",
    ),
    "developerSectionDatabaseTitle": MessageLookupByLibrary.simpleMessage(
      "Database",
    ),
    "developerSectionNavigationTitle": MessageLookupByLibrary.simpleMessage(
      "Navigation",
    ),
    "developerSectionUsefulLinksTitle": MessageLookupByLibrary.simpleMessage(
      "Useful links",
    ),
    "developerSendLogsButton": MessageLookupByLibrary.simpleMessage(
      "Send logs",
    ),
    "developerSendLogsMessage": MessageLookupByLibrary.simpleMessage(
      "Sending logs",
    ),
    "developerSendLogsMessageError": MessageLookupByLibrary.simpleMessage(
      "Error",
    ),
    "developerSendLogsMessageSuccess": MessageLookupByLibrary.simpleMessage(
      "Logs sent!",
    ),
    "developerSessionsLogoutAllConfirmationMessage":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to log out from all devices?",
        ),
    "developerSessionsLogoutAllDescription":
        MessageLookupByLibrary.simpleMessage(
          "Log out from all devices. Useful for testing logout functionality or refreshing session on all devices.",
        ),
    "developerShowLogsButton": MessageLookupByLibrary.simpleMessage(
      "Show logs",
    ),
    "developerSnackbarErrorPreviewMessage":
        MessageLookupByLibrary.simpleMessage("Demo error notification"),
    "developerSnackbarGalleryDescription": MessageLookupByLibrary.simpleMessage(
      "Previewing successful and error notifications",
    ),
    "developerSnackbarGalleryTitle": MessageLookupByLibrary.simpleMessage(
      "Notification Gallery",
    ),
    "developerSnackbarSuccessPreviewMessage":
        MessageLookupByLibrary.simpleMessage("Demo successful notification"),
    "developerStorageClearDescription": MessageLookupByLibrary.simpleMessage(
      "Clear key-value storage. Useful for testing onboarding and promo code flows.",
    ),
    "developerStorageClearSuccessMessage": MessageLookupByLibrary.simpleMessage(
      "Key-value storage cleared successfully",
    ),
    "developerSuccessPreviewLabel": MessageLookupByLibrary.simpleMessage(
      "Successfully",
    ),
    "developerTitle": MessageLookupByLibrary.simpleMessage("Developer"),
    "developerToggleBetaFeaturesLabel": MessageLookupByLibrary.simpleMessage(
      "Use beta features",
    ),
    "developerToggleDebugFeaturesLabel": MessageLookupByLibrary.simpleMessage(
      "Use debug features",
    ),
    "developerToggleExperimentalFeaturesDescription":
        MessageLookupByLibrary.simpleMessage(
          "Experimental features. Use with caution, as they may cause unexpected behavior or crashes.",
        ),
    "developerToggleExperimentalFeaturesLabel":
        MessageLookupByLibrary.simpleMessage("Use experimental features"),
    "developerTotalLabel": MessageLookupByLibrary.simpleMessage("Total"),
    "developerUiFlowsSectionTitle": MessageLookupByLibrary.simpleMessage(
      "UI scripts",
    ),
    "developerUserAuthenticatedLabel": MessageLookupByLibrary.simpleMessage(
      "Authenticated",
    ),
    "developerUserCurrentInfoDescription": MessageLookupByLibrary.simpleMessage(
      "Information about current user",
    ),
    "developerUserCurrentLogoutDescription":
        MessageLookupByLibrary.simpleMessage("Log out current user"),
    "developerUserIDLabel": MessageLookupByLibrary.simpleMessage("User ID"),
    "developerUserInformationDescription": MessageLookupByLibrary.simpleMessage(
      "Information about the current user",
    ),
    "developerUserRefreshSessionDescription":
        MessageLookupByLibrary.simpleMessage("Refresh current user\'s session"),
    "developerUserRefreshSessionTitle": MessageLookupByLibrary.simpleMessage(
      "Refresh session",
    ),
    "editButton": MessageLookupByLibrary.simpleMessage("Edit"),
    "emailLabel": MessageLookupByLibrary.simpleMessage("Email"),
    "emailPlaceholder": MessageLookupByLibrary.simpleMessage(
      "Enter your email",
    ),
    "errorDetailsDialogLabel": MessageLookupByLibrary.simpleMessage(
      "Error details",
    ),
    "errorInternalServerLabel": MessageLookupByLibrary.simpleMessage(
      "Internal server error",
    ),
    "errorLabel": MessageLookupByLibrary.simpleMessage("Error"),
    "errorNotFoundLabel": MessageLookupByLibrary.simpleMessage("Not found"),
    "errorUnimplementedLabel": MessageLookupByLibrary.simpleMessage(
      "Unimplemented",
    ),
    "homeTitle": MessageLookupByLibrary.simpleMessage("Home"),
    "localeCode": MessageLookupByLibrary.simpleMessage("en"),
    "localeName": MessageLookupByLibrary.simpleMessage("English"),
    "logoutAllDevicesButton": MessageLookupByLibrary.simpleMessage(
      "Log out from all devices",
    ),
    "logoutButton": MessageLookupByLibrary.simpleMessage("Log Out"),
    "nameLabel": MessageLookupByLibrary.simpleMessage("Name"),
    "ofSeparator": MessageLookupByLibrary.simpleMessage("of"),
    "passwordLabel": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordPlaceholder": MessageLookupByLibrary.simpleMessage(
      "Enter your password",
    ),
    "profileSettingsDescription": MessageLookupByLibrary.simpleMessage(
      "Change your settings",
    ),
    "profileSettingsTitle": MessageLookupByLibrary.simpleMessage("Settings"),
    "profileTitle": MessageLookupByLibrary.simpleMessage("Profile"),
    "selectedLabel": MessageLookupByLibrary.simpleMessage("Selected"),
    "sendLogsButton": MessageLookupByLibrary.simpleMessage("Send logs"),
    "shareErrorButton": MessageLookupByLibrary.simpleMessage("Share the error"),
    "shareErrorSuccessMessage": MessageLookupByLibrary.simpleMessage(
      "Error message has been shared successfully!",
    ),
    "signInButton": MessageLookupByLibrary.simpleMessage("Sign In"),
    "signUpButton": MessageLookupByLibrary.simpleMessage("Sign Up"),
    "sizeLabel": MessageLookupByLibrary.simpleMessage("Size"),
    "statusLabel": MessageLookupByLibrary.simpleMessage("Status"),
    "storageLabel": MessageLookupByLibrary.simpleMessage("Storage"),
    "submitReportButton": MessageLookupByLibrary.simpleMessage("Send report"),
    "timeLabel": MessageLookupByLibrary.simpleMessage("Time"),
    "title": MessageLookupByLibrary.simpleMessage("Title"),
    "typeLabel": MessageLookupByLibrary.simpleMessage("Type"),
    "versionLabel": MessageLookupByLibrary.simpleMessage("Version"),
  };
}
