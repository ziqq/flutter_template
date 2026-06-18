import 'dart:async';

import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/feature/initialization/data/initialization.dart' as initialization;
import 'package:l/l.dart';

void main() {
  // ignore: experimental_member_use
  l.capture<void>(
    () => runZonedGuarded<void>(() async {
      initialization
          .$initializeApp(
            // Handle progress updates during initialization
            onProgress: (progress, message) {
              // Update the initialization progress
            },
            onSuccess: () {
              // Show the app one everything is initialized.
              // This is where you should typically call `runApp()`.
            },
            onError: (e, st) {
              // Display fallback UI in case of an error
            },
          )
          .ignore();
    }, l.e),
    LogOptions(
      handlePrint: true,
      printColors: false,
      output: LogOutput.print,
      messageFormatting: _messageFormatting,
      outputInRelease: !Config.environment.isProduction,
    ),
  );
}

/// Formats the log message.
Object _messageFormatting(LogMessage log) {
  // LogBuffer.instance.add(log);

  // ignore: unused_local_variable
  final prefix = log.level.when(
    // Verbose and so on
    v: () => '1️⃣',
    vv: () => '2️⃣',
    vvv: () => '3️⃣',
    vvvv: () => '4️⃣',
    vvvvv: () => '5️⃣',
    vvvvvv: () => '6️⃣',

    // Standart logs levels
    debug: () => '🔍', // debug message
    info: () => 'ℹ️', // information message
    warning: () => '⚠️', // warnings
    error: () => '❌', // errors
    shout: () => '📣', // critical
  );

  /* ErrorUtil.addBreadcrumb(
    message: log.message.toString(),
    level: log.level.maybeWhen(
      orElse: () => 1,
      error: () => 4,
      warning: () => 3,
    ),
    type: log.level.maybeWhen(
      orElse: () => 'default',
      error: () => 'error',
      warning: () => 'warning',
    ),
    timestamp: log.timestamp,
  ); */

  return /* '[$prefix] ' */ '${_timeFormat(log.timestamp)} | ${log.message}';
}

/// Formats the time.
String _timeFormat(DateTime time) => '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
