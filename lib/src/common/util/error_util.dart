// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:async';

import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter/cupertino.dart' show CupertinoColors, CupertinoDynamicColor;
import 'package:flutter/services.dart' show HapticFeedback, Clipboard, ClipboardData;
import 'package:flutter_template_name/src/common/api_client/api_exception.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/localization/localization.dart';
import 'package:flutter_template_name/src/common/util/platform/error_util_vm.dart'
    if (dart.library.html) 'platform/error_util_js.dart';
import 'package:l/l.dart';
import 'package:meta/meta.dart';
import 'package:ui/ui.dart';

/// {@template error_util}
/// Error util.
/// {@endtemplate}
@internal
abstract final class ErrorUtil {
  /// Log the error to the console and to Crashlytics.
  static Future<void> logError(
    Object exception,
    StackTrace stackTrace, {
    Map<String, Object?>? hints,
    bool fatal = false,
  }) async {
    if (exception is String) {
      return logMessage(exception, stackTrace: stackTrace, hints: hints, warning: true);
    }
    try {
      $captureException(exception, stackTrace, hints, fatal).ignore();
      l.e(exception, stackTrace);
      /* if (!Config.environment.isProduction) {
        l.e(
          'ErrorUtil.logError > exception: ${exception.toString()}, '
          'stackTrace: $stackTrace',
          stackTrace,
        );
      } */
    } on Object catch (error, stackTrace) {
      l.e('Error while logging error "$error" inside ErrorUtil.logError', stackTrace);
    }
  }

  /// Logs a message to the console and to Crashlytics.
  static Future<void> logMessage(
    String message, {
    StackTrace? stackTrace,
    Map<String, Object?>? hints,
    bool warning = false,
  }) async {
    try {
      $captureMessage(message, stackTrace, hints, warning).ignore();
      l.e(message, stackTrace ?? StackTrace.current);
      /* if (!Config.environment.isProduction) {
        l.e(
          'ErrorUtil.logMessage > message: $message, '
          'stackTrace: ${stackTrace ?? StackTrace.current}',
          stackTrace ?? StackTrace.current,
        );
      } */
    } on Object catch (error, stackTrace) {
      l.e('Error while logging error "$error" inside ErrorUtil.logMessage', stackTrace);
    }
  }

  /// Return formated message from [error].
  static String formatMessage(Object? error) => switch (error) {
    ApiException value => value.message.toString(),
    _ => error.toString(),
  };

  /// Converts the error to a string representation.
  static String errorToString(BuildContext context, Object? error) => switch (error) {
    String value => value,
    ApiException value => _httpExceptionToString(context, value),
    /* DioException value => _dioExceptionToString(context, value), */
    FirebaseException value => _firebaseExceptionToString(value),
    TimeoutException(:Duration? duration) =>
      duration != null ? 'The operation timed out after ${duration.inSeconds} seconds' : 'The operation timed out',
    _ => error.toString(),
  };

  /// Rethrows the error with the stack trace.
  static Never throwWithStackTrace(Object error, StackTrace stackTrace) => Error.throwWithStackTrace(error, stackTrace);

  /// Add a breadcrumb to current performance and error tracking.
  /* static void addBreadcrumb({
    /// Describes the breadcrumb.
    String? message,

    /// The time when the breadcrumb occurred.
    DateTime? timestamp,

    /// A dot-separated string describing the source of the breadcrumb, e.g. "ui.click".
    String? category,

    /// Possible values:
    /// 1 – "debug"
    /// 2 – "info"
    /// 3 – "warning"
    /// 4 – "error"
    /// 5 – "fatal"
    int? level,

    /// Possible values:
    /// "default"
    /// "debug"
    /// "info"
    /// "error"
    /// "query"
    /// "transaction"
    /// "ui"
    /// "user"
    /// "http"
    /// "navigation"
    String? type,

    /// Data associated with the breadcrumb.
    /// The contents depend on the `type` of breadcrumb.
    Map<String, Object?>? context,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        timestamp: timestamp?.toUtc(),
        category: category ?? 'default',
        level: switch (level) {
          5 => SentryLevel.fatal,
          4 => SentryLevel.error,
          3 => SentryLevel.warning,
          2 => SentryLevel.info,
          1 => SentryLevel.debug,
          _ => SentryLevel.info,
        },
        type: type ?? 'default',
        data: context,
      ),
    );
  } */

  /// Displays an error message in a SnackBar.
  /// This method is used to display error messages in the UI.
  static void displayErrorSnackBar(BuildContext context, Object error, [StackTrace? stackTrace]) {
    if (!context.mounted) return;

    try {
      final messenger = ScaffoldMessenger.maybeOf(context);
      final theme = Theme.of(context);
      if (messenger == null) return;

      // In non-production builds, add a “Details” action that opens a dialog
      final detailsAction = !Config.environment.isProduction
          ? (() {
              final navigator = Navigator.maybeOf(context);
              if (navigator == null) return null;
              return SnackBarAction(
                label: Localization.of(context).detailsButton,
                textColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: .2),
                onPressed: () {
                  if (!navigator.mounted) return;
                  HapticFeedback.heavyImpact().ignore();
                  showAdaptiveDialog<void>(
                    context: navigator.context,
                    barrierDismissible: true,
                    useSafeArea: true,
                    builder: (ctx) => AlertDialog(
                      title: Text(Localization.of(ctx).errorDetailsDialogLabel),
                      icon: Icon(Icons.error, color: CupertinoDynamicColor.resolve(CupertinoColors.systemRed, ctx)),
                      iconPadding: .all(theme.uiTheme.size.offset.medium),
                      titlePadding: .only(
                        left: theme.uiTheme.size.offset.medium,
                        right: theme.uiTheme.size.offset.medium,
                        bottom: theme.uiTheme.size.offset.regular,
                      ),
                      contentPadding: .only(
                        left: theme.uiTheme.size.offset.medium,
                        right: theme.uiTheme.size.offset.medium,
                        bottom: theme.uiTheme.size.offset.regular,
                        top: theme.uiTheme.size.offset.extraExtraSmall,
                      ),
                      actionsPadding: .only(
                        top: 0,
                        left: theme.uiTheme.size.offset.medium,
                        right: theme.uiTheme.size.offset.medium,
                        bottom: theme.uiTheme.size.offset.regular,
                      ),
                      content: SizedBox(
                        width: 420,
                        height: 280,
                        child: Stack(
                          children: <Widget>[
                            SingleChildScrollView(
                              padding: .fromLTRB(
                                theme.uiTheme.size.offset.regular,
                                theme.uiTheme.size.offset.regular,
                                theme.uiTheme.size.offset.regular,
                                40,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(errorToString(ctx, error)),
                                  const Divider(),
                                  Text(error.toString()),
                                  if (stackTrace != null) ...[const Divider(), Text('$stackTrace')],
                                ],
                              ),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                  tooltip: Localization.of(ctx).copyToClipboardLabel,
                                  icon: const Icon(Icons.copy_all),
                                  onPressed: () {
                                    final buffer = StringBuffer()
                                      ..writeln(
                                        errorToString(ctx, error).replaceAll('```json', '').replaceAll('```', ''),
                                      )
                                      ..writeln('------')
                                      ..writeln(error);
                                    if (stackTrace != null) {
                                      buffer
                                        ..writeln('------')
                                        ..writeln(stackTrace);
                                    }
                                    Clipboard.setData(ClipboardData(text: buffer.toString())).ignore();
                                    HapticFeedback.heavyImpact().ignore();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            })()
          : null;

      messenger.showSnackBar(
        SnackBar(
          backgroundColor: CupertinoDynamicColor.resolve(CupertinoColors.systemRed, context),
          content: Text(errorToString(context, error)),
          action: detailsAction,
        ),
      );
    } on Object catch (e, s) {
      l.w('Failed to show error SnackBar: $e', s);
    }
  }
}

/// Converts a [DioException] to a user-friendly string message.
// ignore: prefer_expression_function_bodies
/* String _dioExceptionToString(BuildContext context, DioException error) {
  // final l = ErrorsLocalization.of(context);
  return switch ((error.response?.statusCode, error.type)) {
    // HTTP status code mappings
    (400, _) => /* l.badRequestError */ '',
    (401, _) => /* l.unauthorizedError */ '',
    (403, _) => /* l.forbiddenError */ '',
    (404, _) => /* l.notFoundError */ '',
    (408, _) => /* l.requestTimeoutError */ '',
    (409, _) => /* l.conflictError */ '',
    (422, _) => /* l.validationError */ '',
    (429, _) => /* l.tooManyRequestsError */ '',
    (500, _) => /* l.internalServerError */ '',
    (502, _) => /* l.badGatewayError */ '',
    (503, _) => /* l.serviceUnavailableError */ '',
    (504, _) => /* l.gatewayTimeoutError */ '',

    // Dio error types
    (_, DioExceptionType.connectionTimeout) => /* l.timeoutError */ '',
    (_, DioExceptionType.receiveTimeout) => /* l.timeoutError */ '',
    (_, DioExceptionType.sendTimeout) => /* l.timeoutError */ '',
    (_, DioExceptionType.badCertificate) => 'Bad certificate',
    (_, DioExceptionType.badResponse) => 'Bad response',
    (_, DioExceptionType.cancel) => 'Request cancelled',
    (_, DioExceptionType.connectionError) =>
      Config.environment.isProduction ? /* l.networkError */ '' : (error.message ?? /* l.networkError */ ''),
    (_, DioExceptionType.unknown) => error.message ??/*  l.unknownError */ '',

    // Fallback for any other case
    _ => /* l.defaultError */ 'Received invalid status: ${error.response?.statusCode}',
  };
} */

/// Converts an [ApiException] to a user-friendly string message.
// ignore: prefer_expression_function_bodies
String _httpExceptionToString(BuildContext context, ApiException error) {
  // final l = ErrorsLocalization.of(context);
  return switch (error.code) {
    'network_error' => /* l.networkError */ '',
    'timeout_error' => /* l.timeoutError */ '',
    'unknown_error' => /* l.unknownError */ '',
    /* 509 */ 'bandwidth_limit_exceeded' => /* l.bandwidthLimitExceededError */ '',
    /* 504 */ 'gateway_timeout' => /* l.gatewayTimeoutError */ '',
    /* 503 */ 'service_unavailable' => /* l.serviceUnavailableError */ '',
    /* 502 */ 'bad_gateway' => /* l.badGatewayError */ '',
    /* 501 */ 'not_implemented' => /* l.notImplementedError */ '',
    /* 500 */ 'internal_server_error' => /* l.internalServerError */ '',
    /* 5xx */ 'server_error' => /* l.serverError */ '',
    /* 429 */ 'too_many_requests' => /* l.tooManyRequestsError */ '',
    /* 422 */ 'validation_error' || 'unprocessable_entity' => /* l.validationError */ '',
    /* 409 */ 'conflict' => /* l.conflictError */ '',
    /* 408 */ 'request_timeout' => /* l.requestTimeoutError */ '',
    /* 404 */ 'not_found' => /* l.notFoundError */ '',
    /* 403 */ 'forbidden' => /* l.forbiddenError */ '',
    /* 401 */ 'unauthorized' => /* l.unauthorizedError */ '',
    /* 400 */ 'bad_request' => /* l.badRequestError */ '',
    /* 4xx */ 'client_error' => /* l.clientError */ '',
    /* 3xx */ 'redirection' => /* l.redirectionError */ '',

    _ => /* l.defaultError */ '',
  };
}

/// Converts a [FirebaseException] to a user-friendly string message.
String _firebaseExceptionToString(FirebaseException error) => switch (error.code.split('/').last.trim().toLowerCase()) {
  'admin-restricted-operation' => 'This operation is restricted to administrators only.',
  'argument-error' => 'The argument provided is invalid.',
  'app-not-authorized' =>
    "This app, identified by the domain where it's hosted, is not authorized to use with the provided API key.",
  'app-not-installed' =>
    'The requested mobile application corresponding to the identifier (Android package name or iOS bundle ID) provided is not installed.',
  'captcha-check-failed' =>
    'The reCAPTCHA response token provided is either invalid, expired, already used or the domain associated with it does not match the current domain.',
  'code-expired' => 'The SMS code has expired. Please re-send the verification code to try again.',
  'cordova-not-ready' => 'Cordova framework is not ready.',
  'cors-unsupported' => 'This browser is not supported.',
  'credential-already-in-use' => 'This credential is already associated with a different user account.',
  'custom-token-mismatch' => 'The custom token corresponds to a different audience.',
  'requires-recent-login' =>
    'This operation is sensitive and requires recent authentication. Log in again before retrying this request.',
  'dynamic-link-not-activated' => 'Please activate Dynamic Links and agree to the terms and conditions.',
  'email-change-needs-verification' => 'Multi-factor users must always have a verified email.',
  'email-already-in-use' =>
    'Email is either in use or the password is incorrect. You can reset your password or try again.',
  'expired-action-code' => 'The action code has expired.',
  'cancelled-popup-request' => 'This operation has been cancelled due to another conflicting popup being opened.',
  'internal-error' => 'An internal error has occurred.',
  'invalid-app-credential' =>
    'The phone verification request contains an invalid application verifier. The reCAPTCHA token response is either invalid or expired.',
  'invalid-app-id' => 'The mobile app identifier is not registered for the current project.',
  'invalid-user-token' =>
    "This user's credential isn't valid for this project. This can happen if the user's token has been tampered with, or if the user is no longer valid.",
  'invalid-auth-event' => 'An internal error has occurred.',
  'invalid-verification-code' =>
    'The SMS verification code used to create the phone auth credential is invalid. Please resend the verification code and try again.',
  'invalid-continue-uri' => 'The continue URL provided in the request is invalid.',
  'invalid-cordova-configuration' => 'The plugins must be installed to enable OAuth sign-in.',
  'invalid-custom-token' => 'The custom token format is incorrect. Please check the documentation.',
  'invalid-dynamic-link-domain' =>
    'The provided dynamic link domain is not configured or authorized for the current project.',
  'invalid-email' => 'The email address is badly formatted.',
  'invalid-api-key' => 'Your API key is invalid, please check you have copied it correctly.',
  'invalid-cert-hash' => 'The SHA-1 certificate hash provided is invalid.',
  'invalid-credential' => 'The supplied auth credential is malformed or has expired.',
  'invalid-message-payload' =>
    'The email template corresponding to this action contains invalid characters in its message.',
  'invalid-multi-factor-session' => 'The request does not contain a valid proof of first factor successful sign-in.',
  'invalid-tenant-id' => "The Auth instance's tenant ID is invalid.",
  'multi-factor-auth-required' => 'Proof of ownership of a second factor is required to complete sign-in.',
  'missing-android-pkg-name' =>
    'An Android Package Name must be provided if the Android App is required to be installed.',
  'missing-continue-uri' => 'A continue URL must be provided in the request.',
  'missing-ios-bundle-id' => 'An iOS Bundle ID must be provided if an App Store ID is provided.',
  'missing-verification-code' => 'The phone auth credential was created with an empty SMS verification code.',
  'missing-verification-id' => 'The phone auth credential was created with an empty verification ID.',
  'quota-exceeded' => "The project's quota for this operation has been exceeded.",
  'session-expired' => 'This session has expired, please sign in again.',
  'second-factor-already-in-use' => 'The second factor is already enrolled on this account.',
  'second-factor-failed' => 'The provided second factor is incorrect.',
  'too-many-requests' => 'We have blocked all requests from this device due to unusual activity. Try again later.',
  'user-disabled' => 'The user account has been disabled by an administrator.',
  'user-token-expired' => "The user's credential has expired. Please sign in again.",
  'weak-password' => 'The password must be 6 characters long or more.',
  'wrong-password' => 'The password is invalid or the user does not have a password.',
  _ => error.message ?? 'An unknown Firebase error occurred.',
};
