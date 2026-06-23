/*
 * Date: 05 May 2025
 */

// ignore_for_file: prefer_constructors_over_static_methods

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_template_name/src/common/api_client/api_exception.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/constant/generated/pubspec.yaml.g.dart';
import 'package:flutter_template_name/src/common/model/app_metadata.dart';
import 'package:flutter_template_name/src/common/model/attachment_file.dart';
import 'package:flutter_template_name/src/common/util/date_util.dart';
import 'package:flutter_template_name/src/common/util/file_util.dart';
import 'package:flutter_template_name/src/common/util/log_buffer.dart';
import 'package:flutter_template_name/src/common/util/string_util.dart';
import 'package:flutter_template_name/src/feature/authentication/model/user.dart';
import 'package:http/http.dart' as http_package show Client, MultipartFile, MultipartRequest, Response;
import 'package:intl/intl.dart';
import 'package:l/l.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// Type definition for BugReportID, representing a unique identifier for bug reports.
typedef BugReportID = String;

/// Enumiration for bug report payload types,
/// indicating whether the report is a simple message or a file attachment.
enum BugReportPayload {
  /// A file attachment, typically a CSV export of logs or other relevant data,
  /// providing detailed information for debugging.
  file,

  /// A simple text message containing the bug report details,
  /// such as error information, user actions, and context.
  message,
}

/// Enumeration for bug report transport channels,
/// defining the delivery method for bug reports.
enum BugReportTransport {
  /// Shares bug reports through the platform share sheet so the user can post
  /// them to Discord or etc channel with attached files.
  share,

  /// Sends bug reports to Sentry, a popular error tracking and monitoring platform,
  /// enabling advanced error analysis, aggregation, and alerting features for developers.
  sentry,

  /// Sends bug reports directly to a Telegram chat using a bot,
  /// allowing for real-time notifications and easy access for developers.
  telegram,
}

/// {@template bug_report_util}
/// Utility class for building and sending bug-report payloads.
/// Supports Telegram delivery with Sentry fallback and CSV log attachments.
/// {@endtemplate}
final class BugReportUtil {
  /// {@macro bug_report_util}
  BugReportUtil._({http_package.Client? client}) : _internalClient = client ?? http_package.Client();

  /// {@macro bug_report_util}
  static BugReportUtil get instance => _instance ?? BugReportUtil._();
  static BugReportUtil? _instance;

  /// HTTP client for sending bug-report payloads.
  final http_package.Client _internalClient;

  /// Telegram settings.
  /// [sendMessageURL] - URL for sending messages to Telegram.
  /// [sendDocumentURL] - URL for sending documents to Telegram.
  /// [captionLimit] - Character limit for Telegram message captions.
  /// [characterLimit] - Character limit for Telegram messages.
  static final ({Uri sendMessageURL, Uri sendDocumentURL, int captionLimit, int characterLimit}) _telegramSettings = (
    sendDocumentURL: Uri.parse('https://api.telegram.org/${Config.telegramErrorBotToken}/sendDocument'),
    sendMessageURL: Uri.parse('https://api.telegram.org/${Config.telegramErrorBotToken}/sendMessage'),
    captionLimit: 1024,
    characterLimit: 4096,
  );

  /// Truncate the given [text] to the specified [limit] characters.
  /// If the text is longer than the limit, it will be truncated and
  /// a suffix will be added to indicate truncation.
  static String _truncate(String text, int limit) {
    if (text.length <= limit) return text;
    const suffix = '\n…[truncated]';
    final cut = (limit - suffix.length).clamp(0, limit);
    return '${text.substring(0, cut)}$suffix';
  }

  static String _compactChunk(String? value, {int limit = 48}) {
    final normalized = value?.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized == null || normalized.isEmpty) return 'n/a';
    return normalized.length <= limit ? normalized : '${normalized.substring(0, limit - 1)}…';
  }

  static String _buildDetailChunk({Object? error, String? message, String? route, int limit = 72}) {
    final errorText = error?.toString().trim();
    if (errorText != null && errorText.isNotEmpty && errorText != 'N/A') {
      return _compactChunk(errorText, limit: limit);
    }

    final messageText = message?.trim();
    if (messageText != null) return _compactChunk(messageText, limit: limit);

    final routeText = route?.trim();
    if (routeText != null && routeText.isNotEmpty && routeText != 'N/A') {
      return _compactChunk(routeText, limit: limit);
    }

    return 'Manual bug report';
  }

  static String? _buildLogsDigest() {
    final allLogs = LogBuffer.instance.logs.toList(growable: false);
    if (allLogs.isEmpty) return null;

    final prioritizedLogs = <LogMessage>[
      ...allLogs.where((log) => log.level.maybeWhen(error: () => true, warning: () => true, orElse: () => false)),
    ];

    final selectedLogs = prioritizedLogs.reversed.take(250).toList(growable: false).reversed;
    if (selectedLogs.isEmpty) return null;

    String getLogLevelLabel(LogMessage log) => log.level.maybeWhen(
      debug: () => 'debug',
      info: () => 'info',
      warning: () => 'warning',
      error: () => 'error',
      shout: () => 'critical',
      orElse: () => 'info',
    );
    final digest = selectedLogs
        .map(
          (log) =>
              '[${getLogLevelLabel(log)}] [${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}] ${log.message.toString().trim()}',
        )
        .join('\n');

    return digest;
  }

  static String _buildSentryUserMessage({
    String? message,
    Object? error,
    String? route,
    String fallback = 'Manual bug report',
  }) {
    final messageText = message?.trim();
    if (messageText != null && messageText.isNotEmpty) return messageText;

    final errorText = error?.toString().trim();
    if (errorText != null && errorText.isNotEmpty && errorText != 'N/A') return errorText;

    final routeText = route?.trim();
    if (routeText != null && routeText.isNotEmpty && routeText != 'N/A') return 'Route: $routeText';

    return fallback;
  }

  static String _buildShareReportText({
    BugReportID? reportID,
    AppMetadata? metadata,
    String? message,
    String? route,
    User? user,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final now = DateTime.now().toUtc();
    final buffer = StringBuffer()
      ..writeln('${Pubspec.name.toCapitilize()} bug report${reportID != null ? ' #$reportID' : ''}')
      ..writeln()
      ..writeln('Date: ${_formatDateTimeWithUtcOffset(now)}');
    if (message != null && message.isNotEmpty) {
      buffer.writeln('Message: ${message.trim().isNotEmpty == true ? message.trim() : 'N/A'}');
    }
    buffer
      ..writeln('Environment: ${Config.environment.name}')
      ..writeln('Route: ${route?.trim().isNotEmpty == true ? route : 'N/A'}')
      ..writeln()
      ..writeln('App name: ${metadata?.appName ?? 'N/A'}')
      ..writeln('App version: ${metadata?.appVersion ?? 'N/A'}')
      ..writeln()
      ..writeln('Operating System: ${metadata?.operatingSystem ?? 'N/A'}')
      ..writeln('Locale: ${metadata?.locale ?? 'N/A'}');
    if (metadata?.operatingSystem.toLowerCase() == 'android') {
      buffer
        ..writeln()
        ..writeln('Has GMS: ${metadata?.hasGmsServices == true ? 'Yes' : 'No'}')
        ..writeln('Has HMS: ${metadata?.hasHmsServices == true ? 'Yes' : 'No'}');
    }
    buffer
      ..writeln()
      ..writeln('User id: ${user?.id ?? 'N/A'}')
    // ..writeln('User name: ${user?.name ?? 'N/A'}')
    ;
    if (error != null) {
      buffer
        ..writeln()
        ..writeln('Error:')
        ..writeln(error.toString().trim().isNotEmpty == true ? error.toString().trim() : 'N/A');
    }

    final effectiveStackTrace = switch ((stackTrace, error)) {
      (final StackTrace trace, _) => trace,
      (null, ApiException exception) => exception.stackTrace,
      _ => null,
    };

    if (effectiveStackTrace != null) {
      buffer
        ..writeln()
        ..writeln('Stack trace:')
        ..writeln(effectiveStackTrace);
    }

    return buffer.toString().trim();
  }

  static String _buildErrorKind({Object? error, String? message}) => switch ((error, message)) {
    (ApiException _, _) => 'API_EXCEPTION',
    (FormatException _, _) => 'FORMAT_EXCEPTION',
    (Exception _, _) => error.runtimeType.toString().toUpperCase(),
    (Error _, _) => error.runtimeType.toString().toUpperCase(),
    (Object _, _) => error.runtimeType.toString().toUpperCase(),
    _ => 'MANUAL',
  };

  static String _buildSentryTitle({
    required BugReportPayload payload,
    String? route,
    User? user,
    Object? error,
    String? message,
    // ignore: prefer_expression_function_bodies
  }) {
    /* final payloadType = payload.name.toUpperCase();
    final environment = Config.environment.name.toUpperCase();
    final errorKind = _buildErrorKind(error: error, message: message); */
    return '${user?.id != null ? '${user?.id}: ' : ''}BUGReport'; /* [$environment][$payloadType][$errorKind] */
  }

  static List<String> _buildSentryFingerprint(String reportTitle) => <String>['bug-report', reportTitle];

  static String _buildTimestampToken() => DateTime.now().toUtcIso8601String().replaceAll(RegExp('[^0-9A-Za-z]+'), '-');

  static String _normalizeFileName(String fileName) =>
      fileName.replaceAllMapped(RegExp('[^a-zA-Z0-9]+'), (m) => (m.start == 0 || m.end == fileName.length) ? '' : '-');

  static String _buildExportFileName(String baseName) => '${_normalizeFileName(baseName)}-${_buildTimestampToken()}';

  static Map<String, Object?> _buildReportContext({
    required BugReportTransport transport,
    required String payloadType,
    AppMetadata? metadata,
    String? route,
    User? user,
  }) => <String, Object?>{
    'transport': transport.name,
    'payload_type': payloadType,
    'environment': Config.environment.name,
    'route': route ?? 'N/A',
    'user_id': user?.id?.toString() ?? 'N/A',
    // 'user_name': user?.name ?? 'N/A',
    'app_name': metadata?.appName ?? 'N/A',
    'app_version': metadata?.appVersion ?? 'N/A',
    'locale': metadata?.locale ?? 'N/A',
    'operating_system': metadata?.operatingSystem ?? 'N/A',
  };

  /// Generates Telegram-friendly bug-report text.
  static String buildTelegramReportText({
    String? message,
    String? route,
    Object? error,
    StackTrace? stackTrace,
    User? user,
  }) {
    final now = DateTime.now();
    final timezoneOffset =
        'UTC${now.timeZoneOffset.isNegative ? '-' : '+'}${now.timeZoneOffset.inHours.abs().toString().padLeft(2, '0')}:${(now.timeZoneOffset.inMinutes.abs() % 60).toString().padLeft(2, '0')}';
    var json =
        '```json'
        '\n"date": "${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)} $timezoneOffset",'
        '\n"error": "${error?.toString() ?? 'N/A'}",'
        '\n"message": "${message ?? 'N/A'}",'
        '\n"route": "${route ?? 'N/A'}",'
        '\n"user_id": ${user?.id ?? "N/A"},'
        // '\n"user_name": "${user?.name ?? 'N/A'}"'
        ' ```';
    if (json.isEmpty) return '';
    // Telegram messages have a hard limit, so overlong payloads are trimmed.
    if (json.length > _telegramSettings.characterLimit)
      json = '${json.substring(0, _telegramSettings.characterLimit - 20)}\n\n…[truncated]';
    return json;
  }

  /// Backward-compatible alias for Telegram report text generation.
  static String generateErrorMessage({
    String? message,
    String? route,
    Object? error,
    StackTrace? stackTrace,
    User? user,
  }) => buildTelegramReportText(message: message, route: route, error: error, stackTrace: stackTrace, user: user);

  /// Appends the provided text to a local file.
  Future<void> toFile(String text, String fileName) async {
    final dir = await FileUtil.getDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString('$text\n', mode: .append);
  }

  Future<bool> _sendToTelegramMessage(String text) async {
    final response = await _internalClient.post(
      _telegramSettings.sendMessageURL,
      body: <String, Object?>{
        'chat_id': Config.telegramErrorBotChatID.toString(),
        'parse_mode': 'Markdown',
        'text': text,
      },
    );
    if (response.statusCode == 200) return true;
    l.w('Failed to send message to telegram: ${response.statusCode} | ${response.body}');
    return false;
  }

  Future<bool> _sendToSentryMessage({
    String? message,
    AppMetadata? metadata,
    User? user,
    String? route,
    Object? error,
    StackTrace? stackTrace,
    bool attachLogs = false,
  }) async {
    if (!Sentry.isEnabled) {
      l.w('Sentry transport is not enabled, message report skipped.');
      return false;
    }

    final sentryMessage = _buildSentryUserMessage(message: message, error: error, route: route);
    final logs = attachLogs ? logsToCSV(user: user, metadata: metadata) : null;
    final detailChunk = _buildDetailChunk(error: error, message: sentryMessage, route: route);
    final reportTitle = _buildSentryTitle(
      payload: BugReportPayload.message,
      message: sentryMessage,
      error: error,
      route: route,
      user: user,
    );
    final fingerprint = _buildSentryFingerprint(reportTitle);
    final effectiveStackTrace = switch ((stackTrace, error)) {
      (final StackTrace trace, _) => trace,
      (null, ApiException exception) => exception.stackTrace,
      _ => null,
    };
    final event = SentryEvent(
      logger: 'bug_report',
      level: SentryLevel.error,
      fingerprint: fingerprint,
      release: Pubspec.version.canonical,
      dist: Pubspec.version.build.join('-'),
      message: switch (_buildLogsDigest()) {
        String digest => SentryMessage(digest),
        _ when message != null && message.isNotEmpty => SentryMessage(message),
        _ => null,
      },
      exceptions: <SentryException>[SentryException(type: reportTitle, value: sentryMessage)],
      user: SentryUser(id: user?.id?.toString() /* username: user?.nickname, name: user?.name */),
    );

    void configureScope(Scope scope) {
      scope
        ..level = SentryLevel.error
        ..fingerprint = fingerprint
        ..setContexts(
          'log_report',
          _buildReportContext(
              transport: BugReportTransport.sentry,
              payloadType: 'message',
              metadata: metadata,
              route: route,
              user: user,
            )
            ..['attach_logs'] = attachLogs
            ..['error_kind'] = _buildErrorKind(error: error, message: sentryMessage)
            ..['detail_chunk'] = detailChunk
            ..['user_message'] = sentryMessage
            ..['error'] = error?.toString() ?? 'N/A'
            ..['has_stack_trace'] = effectiveStackTrace != null
            ..['stack_trace'] = effectiveStackTrace?.toString() ?? 'N/A',
        );

      if (logs != null) {
        scope.addAttachment(
          SentryAttachment.fromIntList(
            utf8.encode(logs),
            'bug-report-logs.csv',
            contentType: 'text/csv; charset=utf-8',
          ),
        );
      }
    }

    final eventID = await Sentry.captureEvent(event, withScope: configureScope);
    final success = eventID != const SentryId.empty();
    if (success) l.i('Log message sent to Sentry: $eventID');
    return success;
  }

  Future<bool> _sendToSentryFile({
    required String fileName,
    required String logs,
    AppMetadata? metadata,
    String? message,
    User? user,
    String? route,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    if (!Sentry.isEnabled) {
      l.w('Sentry transport is not enabled, file report skipped.');
      return false;
    }

    final sentryMessage = _buildSentryUserMessage(
      message: message,
      error: error,
      route: route,
      fallback: 'Log export report',
    );
    final reportTitle = _buildSentryTitle(payload: BugReportPayload.file, user: user, message: sentryMessage);
    final detailChunk = _buildDetailChunk(message: sentryMessage, error: error, route: route);
    final fingerprint = _buildSentryFingerprint(reportTitle);
    final effectiveStackTrace = switch ((stackTrace, error)) {
      (final StackTrace trace, _) => trace,
      (null, ApiException exception) => exception.stackTrace,
      _ => null,
    };
    final event = SentryEvent(
      level: .error,
      logger: 'bug_report',
      fingerprint: fingerprint,
      release: Pubspec.version.canonical,
      dist: Pubspec.version.build.join('-'),
      message: switch (_buildLogsDigest()) {
        String digest => SentryMessage(digest),
        _ when message != null && message.isNotEmpty => SentryMessage(message),
        _ => null,
      },
      user: SentryUser(id: user?.id?.toString() /* username: user?.nickname, name: user?.name */),
      exceptions: <SentryException>[SentryException(type: reportTitle, value: sentryMessage)],
    );

    final eventID = await Sentry.captureEvent(
      event,
      withScope: (scope) {
        scope
          ..level = SentryLevel.error
          ..fingerprint = fingerprint
          ..setContexts(
            'log_report',
            _buildReportContext(
                transport: BugReportTransport.sentry,
                payloadType: 'file',
                metadata: metadata,
                route: route,
                user: user,
              )
              ..['logs_count'] = LogBuffer.instance.logs.length
              ..['error_kind'] = _buildErrorKind(error: error, message: sentryMessage)
              ..['detail_chunk'] = detailChunk
              ..['user_message'] = sentryMessage
              ..['error'] = error?.toString() ?? 'N/A'
              ..['has_stack_trace'] = effectiveStackTrace != null
              ..['stack_trace'] = effectiveStackTrace?.toString() ?? 'N/A',
          )
          ..addAttachment(
            SentryAttachment.fromIntList(utf8.encode(logs), '$fileName.csv', contentType: 'text/csv; charset=utf-8'),
          );
      },
    );
    final success = eventID != const SentryId.empty();
    if (success) l.i('Log file sent to Sentry: $eventID');
    return success;
  }

  Future<bool> _shareTo({
    required String fileName,
    required String reportText,
    required List<AttachmentFile> attachments,
    bool attachLogs = false,
    AppMetadata? metadata,
    BugReportID? reportID,
    User? user,
  }) async {
    final tempFiles = <File>[];

    try {
      final dir = await FileUtil.getDirectory();
      final reportFile = File('${dir.path}/$fileName.txt');
      await reportFile.writeAsString(reportText, flush: true);
      tempFiles.add(reportFile);

      final files = <XFile>[XFile(reportFile.path, name: reportFile.uri.pathSegments.last, mimeType: 'text/plain')];

      if (attachLogs) {
        final logsFile = File('${dir.path}/$fileName-logs.csv');
        final logs = logsToCSV(user: user, metadata: metadata);
        await logsFile.writeAsString(logs, flush: true);
        tempFiles.add(logsFile);
        files.add(XFile(logsFile.path, name: logsFile.uri.pathSegments.last, mimeType: 'text/csv'));
      }

      for (final attachment in attachments) {
        final path = attachment.path;
        if (path == null || path.isEmpty) continue;

        final file = File(path);
        if (!file.existsSync()) continue;

        files.add(XFile(path, name: attachment.name, mimeType: attachment.mimeType));
      }

      final result = await SharePlus.instance.share(
        ShareParams(
          subject: '[Bug report] [${Config.environment.name}]${reportID != null ? ' #$reportID' : ''}',
          title: '${Pubspec.name.toCapitilize()} bug report${reportID != null ? ' #$reportID' : ''}',
          text: '${Pubspec.name.toCapitilize()} bug report${reportID != null ? ' #$reportID' : ''}',
          files: files,
        ),
      );

      final success = result.status == ShareResultStatus.success;
      if (!success) l.i('Discord share finished with status: ${result.status.name}');
      return success;
    } on Object catch (e, st) {
      l.w('Error sharing bug report to Discord: $e', st);
      return false;
    } finally {
      await FileUtil.deleteFiles(tempFiles);
    }
  }

  /// Sends a bug report using the selected [transport].
  Future<void> sendReport({
    required BugReportTransport transport,
    BugReportPayload payload = .message,
    BugReportID? reportID,
    String? message,
    String? route,
    User? user,
    Object? error,
    StackTrace? stackTrace,
    AppMetadata? metadata,
    List<AttachmentFile> attachments = const <AttachmentFile>[],
    bool attachLogs = false,
    void Function()? onProcess,
    void Function()? onError,
    void Function()? onSuccess,
  }) => switch ((transport, payload)) {
    (.share, .file) || (.share, .message) => shareReport(
      reportID: reportID,
      message: message,
      route: route,
      user: user,
      error: error,
      metadata: metadata,
      stackTrace: stackTrace,
      attachments: attachments,
      attachLogs: attachLogs,
      onProcess: onProcess,
      onSuccess: onSuccess,
      onError: onError,
    ),
    (.telegram, .file) => sendToTelegramAsFile(
      route: route,
      error: error,
      stackTrace: stackTrace,
      message: message,
      user: user,
      metadata: metadata,
      onProcess: onProcess,
      onSuccess: onSuccess,
      onError: onError,
    ),
    (.telegram, .message) => sendReportToTelegram(
      message: message,
      route: route,
      user: user,
      error: error,
      metadata: metadata,
      stackTrace: stackTrace,
      attachLogs: attachLogs,
      onProcess: onProcess,
      onSuccess: onSuccess,
      onError: onError,
    ),
    (.sentry, .file) => sendToSentryAsFile(
      route: route,
      error: error,
      stackTrace: stackTrace,
      message: message,
      user: user,
      metadata: metadata,
      onProcess: onProcess,
      onSuccess: onSuccess,
      onError: onError,
    ),
    (.sentry, .message) => sendReportToSentry(
      message: message,
      route: route,
      user: user,
      error: error,
      metadata: metadata,
      stackTrace: stackTrace,
      attachLogs: attachLogs,
      onProcess: onProcess,
      onSuccess: onSuccess,
      onError: onError,
    ),
  };

  /// Sends a bug-report message directly to Sentry with a CSV log attachment.
  Future<void> sendReportToSentry({
    String? message,
    String? route,
    User? user,
    Object? error,
    StackTrace? stackTrace,
    AppMetadata? metadata,
    bool attachLogs = false,
    void Function()? onProcess,
    void Function()? onError,
    void Function()? onSuccess,
  }) async => runZonedGuarded<void>(() async {
    onProcess?.call();

    final text = _buildSentryUserMessage(message: message, error: error, route: route);
    if (text.isEmpty) return;

    try {
      final success = await _sendToSentryMessage(
        message: message,
        user: user,
        metadata: metadata,
        route: route,
        error: error,
        stackTrace: stackTrace,
        attachLogs: attachLogs,
      );
      if (success) {
        onSuccess?.call();
      } else {
        onError?.call();
      }
    } on Object catch (e, st) {
      l.w('Error sending message to sentry: $e', st);
      onError?.call();
    }
  }, l.e);

  /// Opens the platform share sheet with a plain-text report, optional logs,
  /// and optional image attachments so the user can post everything to Discord.
  Future<void> shareReport({
    BugReportID? reportID,
    String? message,
    String? route,
    User? user,
    Object? error,
    StackTrace? stackTrace,
    AppMetadata? metadata,
    List<AttachmentFile> attachments = const <AttachmentFile>[],
    bool attachLogs = false,
    void Function()? onProcess,
    void Function()? onError,
    void Function()? onSuccess,
  }) async => runZonedGuarded<void>(() async {
    onProcess?.call();

    final reportText = _buildShareReportText(
      metadata: metadata,
      reportID: reportID,
      user: user,
      route: route,
      error: error,
      message: message,
      stackTrace: stackTrace,
    );
    final fileName = _buildExportFileName('${Config.storageNamespace}-bug-report');

    final success = await _shareTo(
      reportText: reportText,
      fileName: fileName,
      attachments: attachments,
      metadata: metadata,
      reportID: reportID,
      user: user,
      attachLogs: attachLogs,
    );

    if (success) {
      onSuccess?.call();
    } else {
      onError?.call();
    }
  }, l.e);

  /// Sends a bug-report message directly to Sentry with optional CSV log attachment.
  Future<void> sendToSentryAsMessage({
    String? message,
    String? route,
    User? user,
    Object? error,
    StackTrace? stackTrace,
    AppMetadata? metadata,
    bool attachLogs = false,
    void Function()? onProcess,
    void Function()? onSuccess,
    void Function()? onError,
  }) => sendReportToSentry(
    metadata: metadata,
    message: message,
    user: user,
    route: route,
    error: error,
    stackTrace: stackTrace,
    attachLogs: attachLogs,
    onProcess: onProcess,
    onSuccess: onSuccess,
    onError: onError,
  );

  /// Sends a bug-report message to Telegram and falls back to Sentry on failure.
  Future<void> sendReportToTelegram({
    String? message,
    String? route,
    User? user,
    Object? error,
    StackTrace? stackTrace,
    AppMetadata? metadata,
    bool attachLogs = false,
    void Function()? onProcess,
    void Function()? onError,
    void Function()? onSuccess,
  }) async => runZonedGuarded<void>(() async {
    onProcess?.call();

    final text = buildTelegramReportText(
      route: route,
      user: user,
      error: error,
      message: message,
      stackTrace: stackTrace,
    );
    if (text.isEmpty) return;

    try {
      final telegramSuccess = await _sendToTelegramMessage(text);
      if (telegramSuccess) {
        onSuccess?.call();
        return;
      }

      l.w('Telegram transport failed, falling back to Sentry message transport.');
      final sentrySuccess = await _sendToSentryMessage(
        message: message,
        user: user,
        metadata: metadata,
        route: route,
        error: error,
        stackTrace: stackTrace,
        attachLogs: attachLogs,
      );
      if (sentrySuccess) {
        onSuccess?.call();
        return;
      }

      onError?.call();
    } on Object catch (e, st) {
      l.w('Error sending message to telegram: $e', st);
      try {
        final sentrySuccess = await _sendToSentryMessage(
          message: message,
          user: user,
          metadata: metadata,
          route: route,
          error: error,
          stackTrace: stackTrace,
          attachLogs: attachLogs,
        );
        if (sentrySuccess) {
          onSuccess?.call();
          return;
        }
      } on Object catch (fallbackError, fallbackStackTrace) {
        l.w('Error sending message to sentry: $fallbackError', fallbackStackTrace);
      }
      onError?.call();
    }
  }, l.e);

  /// Sends a bug-report message to Telegram with Sentry fallback on failure.
  Future<void> sendToTelegramAsMessage({
    AppMetadata? metadata,
    String? message,
    User? user,
    String? route,
    Object? error,
    StackTrace? stackTrace,
    bool attachLogs = false,
    void Function()? onProcess,
    void Function()? onSuccess,
    void Function()? onError,
  }) => sendReportToTelegram(
    metadata: metadata,
    message: message,
    route: route,
    user: user,
    error: error,
    stackTrace: stackTrace,
    attachLogs: attachLogs,
    onProcess: onProcess,
    onSuccess: onSuccess,
    onError: onError,
  );

  /// Converts log buffer to `CSV` format
  /// [user] - optional user information to include in the log.
  /// [metadata] - optional app metadata to include in the log.
  /// [addHeaders] - whether to add headers to the CSV file.
  /// [addLogs] - whether to include log entries in the CSV file.
  /// [limit] - optional limit on the number of log entries to include.
  String logsToCSV({AppMetadata? metadata, User? user, bool addHeaders = true, bool addLogs = true, int? limit}) {
    const csvDelimiter = ',';
    const csvEol = '\r\n';

    final logs = LogBuffer.instance.logs.take(limit ?? LogBuffer.instance.logs.length).toList(growable: false);
    final view = PlatformDispatcher.instance.views.first;
    final now = DateTime.now().toLocal();
    final date = now.toUtc();
    final rows = <List<String>>[];

    String csvCell(Object? value) {
      final s = value?.toString() ?? 'N/A';
      final needsQuotes = s.contains(csvDelimiter) || s.contains('"') || s.contains('\n') || s.contains('\r');
      if (!needsQuotes) return s;
      return '"${s.replaceAll('"', '""')}"';
    }

    String stripQuotes(String s) => s.replaceAll('"', '');

    // Add system information header
    if (addHeaders) rows.add(['=== SYSTEM INFORMATION ===']);
    final operatingSystem = metadata?.operatingSystem;
    final isIOS = operatingSystem == 'iOS';
    rows
      ..add(['Environment', Config.environment.toString()])
      ..add(['App name', metadata?.appName ?? 'N/A'])
      ..add(['App version', metadata?.appVersion ?? 'N/A'])
      ..add(['Build timestamp', _formatDateTimeWithUtcOffset(metadata?.appBuildTimestamp)])
      ..add(['Launched timestamp', _formatDateTimeWithUtcOffset(metadata?.appLaunchedTimestamp)])
      ..add(['Current timestamp', _formatDateTimeWithUtcOffset(date)])
      ..add(['Operating system', metadata?.operatingSystem ?? 'N/A'])
      ..add([
        'Google Mobile Services',
        if (operatingSystem == null || isIOS) 'N/A' else (metadata?.hasGmsServices ?? false) ? 'YES' : 'NO',
      ])
      ..add([
        'Huawei Mobile Services',
        if (operatingSystem == null || isIOS) 'N/A' else (metadata?.hasHmsServices ?? false) ? 'YES' : 'NO',
      ])
      ..add(['Platform version', metadata?.platformVersion ?? 'N/A'])
      ..add(['Platform locale', metadata?.locale ?? 'N/A'])
      ..add(['Current locale', PlatformDispatcher.instance.locale.toString()])
      ..add(['Build mode', if (metadata?.isRelease ?? kReleaseMode) 'Release' else 'Debug'])
      ..add(['Platform brightness', if (PlatformDispatcher.instance.platformBrightness == .dark) 'Dark' else 'Light'])
      ..add(['Device version', metadata?.deviceVersion ?? 'N/A'])
      ..add(['Device screen size', metadata?.deviceScreenSize ?? 'N/A'])
      ..add(['Device pixel ratio', view.devicePixelRatio.toString()])
      ..add(['Displays', PlatformDispatcher.instance.views.length.toString()])
      ..add([
        'Physical size',
        '${view.physicalSize.width.toStringAsFixed(2)} x ${view.physicalSize.height.toStringAsFixed(2)}',
      ])
      ..add([
        'Logical size',
        '${view.physicalSize.width / view.devicePixelRatio} x ${view.physicalSize.height / view.devicePixelRatio}',
      ])
      ..add([
        'Padding',
        'l${view.viewPadding.left.toInt()} t${view.viewPadding.top.toInt()} r${view.viewPadding.right.toInt()} b${view.viewPadding.bottom.toInt()}',
      ])
      ..add([
        'View insents',
        'l${view.viewInsets.left.toInt()} t${view.viewInsets.top.toInt()} r${view.viewInsets.right.toInt()} b${view.viewInsets.bottom.toInt()}',
      ])
      ..add([
        'System gesture insets',
        'l${view.systemGestureInsets.left.toInt()} t${view.systemGestureInsets.top.toInt()} r${view.systemGestureInsets.right.toInt()} b${view.systemGestureInsets.bottom.toInt()}',
      ])
      ..add(['Text scale factor', PlatformDispatcher.instance.textScaleFactor.toString()])
      ..add(['Display fetures', 'None'])
      ..add(['CPU', metadata?.processorsCount.toString() ?? 'N/A'])
      /* ..add(['Web URL', window.location.href]) */
      ..add(['Api URL', Config.apiBaseUrl])
      /* ..add(['Sentry', $currentSentryTransaction]) */
      ..add(['App metrica', if (Config.appMetricaKey.isNotEmpty) 'Enabled' else 'Disabled'])
      ..add(['Logs', '${logs.length.toString()} / ${LogBuffer.bufferLimit.toString()}']);

    if (addHeaders) rows.add(['=== USER INFORMATION ===']);
    // ignore: avoid_single_cascade_in_expression_statements
    rows..add(['User ID', user?.id?.toString() ?? 'N/A'])
    /* ..add(['User name', user?.name ?? 'N/A']) */;

    if (addLogs) {
      // Add headers for logs
      final headers = ['Timestamp', 'Type', 'Message', 'Context'];
      if (addHeaders) rows.add(['=== LOGS (${logs.length.toString()}) ===']);
      rows.add(headers);

      // Add log entries
      for (final log in logs) {
        final rawContext = switch (log.context) {
          final Map<String, Object?> c when c.isNotEmpty =>
            (c.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))
                .map((e) {
                  final value = e.value?.toString() ?? 'null';
                  return '${e.key}=$value';
                })
                .join('; '),
          _ => 'N/A',
        };
        rows.add([
          log.timestamp.toLocalIso8601String(),
          log.level.maybeWhen(
            debug: () => 'debug',
            info: () => 'info',
            warning: () => 'warning',
            error: () => 'error',
            shout: () => 'critical',
            orElse: () => 'info',
          ),
          stripQuotes(log.message.toString()),
          stripQuotes(rawContext),
        ]);
      }
    }

    return rows.map((row) => row.map(csvCell).join(csvDelimiter)).join(csvEol);
  }

  /// Sends a CSV bug-report export to Telegram and falls back to Sentry on failure.
  Future<void> sendToTelegramAsFile({
    AppMetadata? metadata,
    String? message,
    User? user,
    String? route,
    Object? error,
    StackTrace? stackTrace,
    void Function()? onProcess,
    void Function()? onSuccess,
    void Function()? onError,
  }) async => runZonedGuarded<void>(() async {
    File? file;
    try {
      onProcess?.call();

      const fileName = '${Config.storageNamespace}-logs';
      final fileNameWithTimestamp = _buildExportFileName(fileName);
      l.i('Preparing log file to send to Telegram: $fileNameWithTimestamp.csv');

      final dir = await FileUtil.getDirectory();
      final logs = logsToCSV(user: user, metadata: metadata);
      file = File('${dir.path}/$fileNameWithTimestamp.csv');
      await file.writeAsString(logs, flush: true, mode: FileMode.append);

      if (!file.existsSync()) {
        l.i('No log file to send.');
        return;
      }

      final caption = switch (message) {
        final String m when m.trim().isNotEmpty => _truncate(m, _telegramSettings.captionLimit),
        _ => null,
      };

      final request = http_package.MultipartRequest('POST', _telegramSettings.sendDocumentURL)
        ..fields['chat_id'] = Config.telegramErrorBotChatID.toString()
        ..fields['parse_mode'] = 'Markdown'
        ..files.add(
          await http_package.MultipartFile.fromPath('document', file.path, filename: file.path.split('/').last),
        );

      if (caption != null) {
        request.fields['caption'] = caption;
      }

      l.i('Sending log file to Telegram...');
      final streamedResponse = await _internalClient.send(request);
      final response = await http_package.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        l.i('Log sended to Telegram');
        onSuccess?.call();
      } else {
        l.w(
          'Telegram transport failed, falling back to Sentry file transport, '
          'statusCode: ${response.statusCode} | body: ${response.body}',
        );
        final ok = await _sendToSentryFile(
          fileName: fileNameWithTimestamp,
          message: message,
          logs: logs,
          user: user,
          metadata: metadata,
          error: error,
          route: route,
          stackTrace: stackTrace,
        );
        if (ok) {
          onSuccess?.call();
        } else {
          onError?.call();
        }
      }
    } on Object catch (e, s) {
      l.w('Error sending file to telegram: $e', s);
      try {
        final logs = file != null && file.existsSync()
            ? await file.readAsString()
            : logsToCSV(user: user, metadata: metadata);
        final ok = await _sendToSentryFile(
          fileName: file?.uri.pathSegments.last.replaceAll('.csv', '') ?? '${Config.storageNamespace}-logs',
          logs: logs,
          message: message,
          user: user,
          metadata: metadata,
          route: route,
          error: error,
          stackTrace: stackTrace,
        );
        if (ok) {
          onSuccess?.call();
          return;
        }
      } on Object catch (fallbackError, fallbackStackTrace) {
        l.w('Error sending file to sentry: $fallbackError', fallbackStackTrace);
      }
      onError?.call();
    } finally {
      // Remove the temporary export file after the transport attempt completes.
      if (file != null && file.existsSync()) file.delete().ignore();
    }
  }, l.e);

  /// Sends a CSV bug-report export directly to Sentry.
  Future<void> sendToSentryAsFile({
    AppMetadata? metadata,
    String? message,
    User? user,
    String? route,
    Object? error,
    StackTrace? stackTrace,
    void Function()? onProcess,
    void Function()? onSuccess,
    void Function()? onError,
  }) async => runZonedGuarded<void>(() async {
    try {
      onProcess?.call();
      const fileName = '${Config.storageNamespace}-logs';
      final fileNameWithTimestamp = _buildExportFileName(fileName);
      final logs = logsToCSV(user: user, metadata: metadata);
      final ok = await _sendToSentryFile(
        fileName: fileNameWithTimestamp,
        metadata: metadata,
        message: message,
        logs: logs,
        user: user,
        route: route,
        error: error,
        stackTrace: stackTrace,
      );
      if (ok) {
        onSuccess?.call();
      } else {
        onError?.call();
      }
    } on Object catch (e, s) {
      l.w('Error sending file to sentry: $e', s);
      onError?.call();
    }
  }, l.e);

  /// Formats [DateTime] with its local UTC offset.
  static String _formatDateTimeWithUtcOffset(DateTime? value) {
    if (value == null) return 'N/A';

    final local = value.toLocal();
    final offset = local.timeZoneOffset;

    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');

    final date = DateFormat('dd.MM.yyyy HH:mm').format(local);
    return '$date UTC$sign$hours:$minutes';
  }
}
