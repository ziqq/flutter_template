import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_template_name/src/common/util/log_buffer.dart';
import 'package:l/l.dart' show LogMessageError;
import 'package:sentry_flutter/sentry_flutter.dart';

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
    return event
      ..breadcrumbs = <Breadcrumb>[
        // Exclude user and ui breadcrumbs on web
        ...?event.breadcrumbs?.where((b) => !kIsWeb || const <String>['user', 'ui'].contains(b.type)),
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
            message: log.message.toString(),
            timestamp: log.timestamp,
            data: kIsWeb
                ? null
                : switch (log) {
                    LogMessageError(stackTrace: var stackTrace) => <String, Object?>{'trace': stackTrace.toString()},
                    _ => null,
                  },
          ),
      ];
  }
}
