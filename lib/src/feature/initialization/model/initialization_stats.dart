/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 29 July 2026
 */

import 'package:flutter/foundation.dart';

/// {@template initialization_step_timing}
/// A measured initialization step from the current app launch.
/// {@endtemplate}
@immutable
final class InitializationStepTiming {
  /// Creates an initialization step timing.
  const InitializationStepTiming({required this.index, required this.name, required this.duration});

  /// The zero-based execution order of the step.
  final int index;

  /// The diagnostic name of the step.
  final String name;

  /// The time spent executing the step.
  final Duration duration;
}

/// {@template initialization_stats}
/// An immutable timing snapshot for the current app launch.
/// {@endtemplate}
@immutable
final class InitializationStats {
  /// Creates a snapshot from the measured [steps].
  factory InitializationStats({required Iterable<InitializationStepTiming> steps}) {
    final snapshot = List<InitializationStepTiming>.unmodifiable(steps);
    return InitializationStats._(
      steps: snapshot,
      totalDuration: Duration(
        microseconds: snapshot.fold<int>(0, (total, step) => total + step.duration.inMicroseconds),
      ),
    );
  }

  /// {@macro initialization_stats}
  const InitializationStats._({required this.steps, required this.totalDuration});

  /// Creates an empty snapshot.
  /// {@macro initialization_stats}
  const InitializationStats.empty() : this._(steps: const <InitializationStepTiming>[], totalDuration: Duration.zero);

  /// Timings in their original execution order.
  final List<InitializationStepTiming> steps;

  /// The sum of all measured step durations.
  final Duration totalDuration;

  /// Timings ordered from the slowest to the fastest.
  List<InitializationStepTiming> get stepsByDuration {
    final sorted = steps.toList(growable: false)
      ..sort((a, b) {
        final durationComparison = b.duration.compareTo(a.duration);
        return durationComparison == 0 ? a.index.compareTo(b.index) : durationComparison;
      });
    return List<InitializationStepTiming>.unmodifiable(sorted);
  }

  /// Returns the percentage of the total initialization time spent in [step].
  double percentageOf(InitializationStepTiming step) {
    final totalMicroseconds = totalDuration.inMicroseconds;
    if (totalMicroseconds <= 0) return 0;
    return step.duration.inMicroseconds / totalMicroseconds * 100;
  }
}
