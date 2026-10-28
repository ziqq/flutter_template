import 'dart:async';

import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/feature/initialization/data/initialization.dart';
import 'package:flutter_template_name/src/feature/initialization/data/initialize_dependencies.dart';
import 'package:test/test.dart';

void main() => group('Application lifecycle -', () {
  test('awaits cleanup in reverse order and shares one disposal future', () async {
    final dependencies = Dependencies();
    final gate = Completer<void>();
    final events = <String>[];
    dependencies.disposable(() => events.add('first'));
    dependencies.disposable(() async {
      events.add('second-start');
      await gate.future;
      events.add('second-end');
    });
    dependencies.disposable(() => events.add('third'));

    final disposal = $disposeApp(dependencies);
    expect($disposeApp(dependencies), same(disposal));
    await Future<void>.delayed(Duration.zero);
    expect(events, ['third', 'second-start']);
    gate.complete();
    await disposal;
    await $disposeApp(dependencies);
    expect(events, ['third', 'second-start', 'second-end', 'first']);
    expect(() => dependencies.disposable(() {}), throwsStateError);
  });

  test('continues after cleanup failures and preserves the first error and stack', () async {
    final dependencies = Dependencies();
    final firstError = StateError('latest resource failed');
    final firstStack = StackTrace.fromString('original cleanup stack');
    final events = <String>[];
    dependencies.disposable(() {
      events.add('oldest');
      throw StateError('oldest resource failed');
    });
    dependencies.disposable(() => events.add('middle'));
    dependencies.disposable(() {
      events.add('latest');
      Error.throwWithStackTrace(firstError, firstStack);
    });

    Object? reportedError;
    StackTrace? reportedStack;
    try {
      await $disposeApp(dependencies);
    } on Object catch (error, stackTrace) {
      reportedError = error;
      reportedStack = stackTrace;
    }
    expect(events, ['latest', 'middle', 'oldest']);
    expect(reportedError, same(firstError));
    expect(reportedStack.toString(), firstStack.toString());
  });

  test('keeps cleanup isolated between dependency graphs', () async {
    final first = Dependencies();
    final second = Dependencies();
    final events = <String>[];
    first.disposable(() => events.add('first'));
    second.disposable(() => events.add('second'));
    await $disposeApp(first);
    expect(events, ['first']);
    await $disposeApp(second);
    expect(events, ['first', 'second']);
  });

  test('propagates the original startup failure and its stack trace', () async {
    final failure = StateError('progress callback failed');
    final failureStack = StackTrace.fromString('original startup stack');
    Object? reportedError;
    StackTrace? reportedStack;
    try {
      await $initializeDependencies(onProgress: (_, _) => Error.throwWithStackTrace(failure, failureStack));
    } on Object catch (error, stackTrace) {
      reportedError = error;
      reportedStack = stackTrace;
    }
    expect(reportedError, same(failure));
    expect(reportedStack.toString(), failureStack.toString());
  });
}, tags: ['data']);
