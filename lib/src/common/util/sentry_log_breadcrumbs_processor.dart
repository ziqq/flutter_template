import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_template_name/src/common/api_client/log_sanitizer.dart';
import 'package:flutter_template_name/src/common/util/log_buffer.dart';
import 'package:l/l.dart' show LogMessageError;
import 'package:sentry_flutter/sentry_flutter.dart';

/// Redacts transport credentials in the Sentry diagnostic representation.
/// Call in beforeSend as well, after the SDK has extracted exception causes.
/// The application's throwable and HTTP request remain untouched.
SentryEvent sanitizeSentryEventTransportDiagnostics(SentryEvent event) {
  if (event.message case final message?) {
    message.formatted = sanitizeTransportMessageForLogging(message.formatted);
    if (message.template case final template?) message.template = sanitizeTransportMessageForLogging(template);
    message.params = message.params
        ?.cast<Object?>()
        .map((value) => value is String ? sanitizeTransportMessageForLogging(value) : value)
        .toList(growable: false);
  }
  for (final exception in event.exceptions ?? const <SentryException>[]) {
    if (exception.value case final value?) exception.value = sanitizeTransportMessageForLogging(value);
  }
  for (final breadcrumb in event.breadcrumbs ?? const <Breadcrumb>[]) {
    if (breadcrumb.message case final message?) breadcrumb.message = sanitizeTransportMessageForLogging(message);
  }
  return event;
}

/// {@template sentry_log_breadcrumbs_processor}
/// A processor that adds log breadcrumbs to Sentry events.
/// {@endtemplate}
@immutable
class SentryLogBreadcrumbsProcessor implements EventProcessor {
  /// {@macro sentry_log_breadcrumbs_processor}
  const SentryLogBreadcrumbsProcessor({required LogBuffer buffer, int limit = 25})
    : _buffer = buffer,
      _maxBreadcrumbs = limit;

  final LogBuffer _buffer;
  final int _maxBreadcrumbs;

  @override
  FutureOr<SentryEvent?> apply(SentryEvent event, Hint hint) {
    final logs = _buffer.logs.toList(growable: false).reversed.take(_maxBreadcrumbs);
    return sanitizeSentryEventTransportDiagnostics(event)
      ..breadcrumbs = (<Breadcrumb>[
        // Exclude user and ui breadcrumbs on web
        ...?event.breadcrumbs?.where((b) => !kIsWeb || !const <String>['user', 'ui'].contains(b.type)),
        for (final log in logs)
          Breadcrumb.console(
            level: log.level.when(
              // verbose levels
              v: () => SentryLevel.info,
              vv: () => SentryLevel.info,
              vvv: () => SentryLevel.info,
              vvvv: () => SentryLevel.debug,
              vvvvv: () => SentryLevel.debug,
              vvvvvv: () => SentryLevel.debug,
              // standard levels
              debug: () => SentryLevel.debug,
              info: () => SentryLevel.info,
              warning: () => SentryLevel.warning,
              error: () => SentryLevel.error,
              shout: () => SentryLevel.fatal,
            ),
            message: sanitizeTransportMessageForLogging(log.message.toString()),
            timestamp: log.timestamp,
            data: kIsWeb
                ? null
                : switch (log) {
                    LogMessageError(stackTrace: var stackTrace) => <String, Object?>{'trace': stackTrace.toString()},
                    _ => null,
                  },
          ),
      ]..sort((a, b) => a.timestamp.compareTo(b.timestamp)));
  }
}
