/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 29 July 2026
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_template_name/src/feature/initialization/model/initialization_stats.dart';

void main() => group('InitializationStats -', () {
  test('calculates total, percentages, and stable duration order', () {
    final stats = InitializationStats(
      steps: const [
        InitializationStepTiming(index: 0, name: 'First', duration: Duration(milliseconds: 1)),
        InitializationStepTiming(index: 1, name: 'Second', duration: Duration(milliseconds: 3)),
        InitializationStepTiming(index: 2, name: 'Third', duration: Duration(milliseconds: 1)),
      ],
    );

    expect(stats.totalDuration, const Duration(milliseconds: 5));
    expect(stats.stepsByDuration.map((step) => step.name), <String>['Second', 'First', 'Third']);
    expect(stats.percentageOf(stats.steps.first), 20);
  });

  test('returns zero percentage for an empty snapshot', () {
    const step = InitializationStepTiming(index: 0, name: 'Empty', duration: Duration.zero);
    const stats = InitializationStats.empty();

    expect(stats.steps, isEmpty);
    expect(stats.totalDuration, Duration.zero);
    expect(stats.percentageOf(step), 0);
  });

  test('keeps an immutable copy of source steps', () {
    final source = <InitializationStepTiming>[
      const InitializationStepTiming(index: 0, name: 'First', duration: Duration(milliseconds: 1)),
    ];
    final stats = InitializationStats(steps: source);

    source.add(const InitializationStepTiming(index: 1, name: 'Second', duration: Duration(milliseconds: 1)));

    expect(stats.steps, hasLength(1));
    expect(() => stats.steps.clear(), throwsUnsupportedError);
  });
});
