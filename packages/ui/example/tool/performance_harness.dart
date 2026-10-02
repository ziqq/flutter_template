/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 18 August 2026
 */

import 'dart:developer' as dev;
import 'dart:io';
import 'dart:isolate';

import 'package:integration_test/integration_test.dart';
import 'package:vm_service/vm_service.dart' as vm;
import 'package:vm_service/vm_service_io.dart';

/// Point-in-time process and Dart-isolate memory counters.
final class PerformanceMemorySnapshot {
  /// Creates an immutable memory snapshot.
  const PerformanceMemorySnapshot({
    required this.heapUsageBytes,
    required this.heapCapacityBytes,
    required this.externalUsageBytes,
    required this.currentRssBytes,
    required this.maxRssBytes,
  });

  /// Current Dart heap usage.
  final int heapUsageBytes;

  /// Current Dart heap capacity reserved from the operating system.
  final int heapCapacityBytes;

  /// Native memory retained by Dart objects and reported by the embedder.
  final int externalUsageBytes;

  /// Current process resident-set size.
  final int currentRssBytes;

  /// Process resident-set high-water mark.
  final int maxRssBytes;

  /// Serializes counters for device reports.
  Map<String, int> toJson() => <String, int>{
    'heap_usage_bytes': heapUsageBytes,
    'heap_capacity_bytes': heapCapacityBytes,
    'external_usage_bytes': externalUsageBytes,
    'current_rss_bytes': currentRssBytes,
    'max_rss_bytes': maxRssBytes,
  };
}

/// Samples memory without adding VM Service work to a measured timeline window.
final class PerformanceMemorySampler {
  PerformanceMemorySampler._({required this._service, required this._isolateId, required this.reason});

  /// Connects to the app's VM Service when the profile runner exposes it.
  static Future<PerformanceMemorySampler> connect() async {
    try {
      final info = await dev.Service.getInfo();
      final serverUri = info.serverUri;
      final isolateId = dev.Service.getIsolateId(Isolate.current);
      if (serverUri == null || isolateId == null) {
        return PerformanceMemorySampler._(
          service: null,
          isolateId: null,
          reason: 'The Dart VM Service is unavailable.',
        );
      }
      final address = serverUri.replace(
        scheme: serverUri.scheme == 'https' ? 'wss' : 'ws',
        path: '${serverUri.path}ws',
      );
      final service = await vmServiceConnectUri(address.toString());
      return PerformanceMemorySampler._(service: service, isolateId: isolateId, reason: null);
    } on Object catch (error) {
      return PerformanceMemorySampler._(
        service: null,
        isolateId: null,
        reason: 'VM Service connection failed: ${error.runtimeType}.',
      );
    }
  }

  final vm.VmService? _service;
  final String? _isolateId;

  /// Why memory metrics are unavailable, or `null` when sampling is active.
  final String? reason;

  /// Whether both the VM Service and current isolate ID are available.
  bool get isAvailable => _service != null && _isolateId != null;

  /// Captures one snapshot, optionally requesting a best-effort full GC first.
  Future<PerformanceMemorySnapshot?> capture({bool collectGarbage = false}) async {
    final service = _service;
    final isolateId = _isolateId;
    if (service == null || isolateId == null) return null;
    if (collectGarbage) {
      await service.getAllocationProfile(isolateId, gc: true);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    final memory = await service.getMemoryUsage(isolateId);
    final heapUsage = memory.heapUsage;
    final heapCapacity = memory.heapCapacity;
    final externalUsage = memory.externalUsage;
    if (heapUsage == null || heapCapacity == null || externalUsage == null) {
      throw StateError('The VM Service returned incomplete memory counters.');
    }
    return PerformanceMemorySnapshot(
      heapUsageBytes: heapUsage,
      heapCapacityBytes: heapCapacity,
      externalUsageBytes: externalUsage,
      currentRssBytes: ProcessInfo.currentRss,
      maxRssBytes: ProcessInfo.maxRss,
    );
  }

  /// Closes the additional VM Service connection owned by the sampler.
  Future<void> dispose() async {
    final service = _service;
    if (service != null) await service.dispose();
  }
}

/// Collects SDK build/raster and GC metrics against an explicit frame budget.
///
/// Sample memory outside the measured window. When [enforceTargetBudget] is
/// true, any build or raster duration over budget fails the scenario, while the
/// full summary remains available to the integration driver's report callback.
/// This measures pipeline stages, not presented FPS or input latency.
Future<Map<String, Object?>> profilePerformanceScenario({
  required IntegrationTestWidgetsFlutterBinding binding,
  required String reportKey,
  required Duration targetFrameInterval,
  required Future<void> Function() action,
  PerformanceMemorySampler? memorySampler,
  bool enforceTargetBudget = true,
}) async {
  if (targetFrameInterval.inMicroseconds <= 0) {
    throw ArgumentError.value(targetFrameInterval, 'targetFrameInterval', 'Must be positive.');
  }
  final memoryBefore = await memorySampler?.capture();
  Object? actionError;
  StackTrace? actionStack;
  await binding.watchPerformance(() async {
    try {
      await action();
    } on Object catch (error, stackTrace) {
      actionError = error;
      actionStack = stackTrace;
    }
  }, reportKey: reportKey);
  final rawSummary = binding.reportData?[reportKey];
  if (rawSummary is! Map<String, Object?>) {
    throw StateError('Missing performance summary for $reportKey.');
  }
  final summary = Map<String, Object?>.of(rawSummary);
  final budget = targetFrameInterval.inMicroseconds;
  summary
    ..['target_frame_budget_millis'] = budget / Duration.microsecondsPerMillisecond
    ..['regression_gate_target_enforced'] = enforceTargetBudget
    ..['missed_target_frame_build_budget_count'] = _countOverBudget(summary['frame_build_times'], budget)
    ..['missed_target_frame_rasterizer_budget_count'] = _countOverBudget(summary['frame_rasterizer_times'], budget);
  final memoryAfter = await memorySampler?.capture();
  summary['memory'] = _memoryMeasurement(memorySampler, memoryBefore, memoryAfter);
  binding.reportData![reportKey] = summary;
  if (actionError case Object error) Error.throwWithStackTrace(error, actionStack!);
  if (enforceTargetBudget &&
      (summary['missed_target_frame_build_budget_count'] != 0 ||
          summary['missed_target_frame_rasterizer_budget_count'] != 0)) {
    throw StateError('Frame budget exceeded for $reportKey. The measured summary remains in reportData.');
  }
  return summary;
}

/// Profiles memory growth while a surface tree is mounted and after it is removed.
Future<Map<String, Object?>> profileMemoryRecovery({
  required PerformanceMemorySampler sampler,
  required Future<void> Function() mount,
  required Future<void> Function() unmount,
}) async {
  await sampler.capture(collectGarbage: true);
  final baseline = await sampler.capture(collectGarbage: true);
  PerformanceMemorySnapshot? mounted;
  try {
    await mount();
    mounted = await sampler.capture();
  } finally {
    await unmount();
  }
  await sampler.capture(collectGarbage: true);
  final released = await sampler.capture(collectGarbage: true);
  if (baseline == null || mounted == null || released == null) {
    return <String, Object?>{'available': false, 'reason': ?sampler.reason};
  }
  return <String, Object?>{
    'available': true,
    'baseline': baseline.toJson(),
    'mounted': mounted.toJson(),
    'released': released.toJson(),
    'active_growth': _memoryDifference(baseline, mounted),
    'retained_growth': _memoryDifference(baseline, released),
    'peak_rss_growth_bytes':
        (mounted.maxRssBytes > released.maxRssBytes ? mounted.maxRssBytes : released.maxRssBytes) -
        baseline.maxRssBytes,
  };
}

Map<String, Object?> _memoryMeasurement(
  PerformanceMemorySampler? sampler,
  PerformanceMemorySnapshot? before,
  PerformanceMemorySnapshot? after,
) {
  if (before == null || after == null) {
    return <String, Object?>{'available': false, 'reason': ?sampler?.reason};
  }
  return <String, Object?>{
    'available': true,
    'before': before.toJson(),
    'after': after.toJson(),
    'delta': _memoryDifference(before, after),
  };
}

Map<String, int> _memoryDifference(PerformanceMemorySnapshot before, PerformanceMemorySnapshot after) => <String, int>{
  'heap_usage_bytes': after.heapUsageBytes - before.heapUsageBytes,
  'heap_capacity_bytes': after.heapCapacityBytes - before.heapCapacityBytes,
  'external_usage_bytes': after.externalUsageBytes - before.externalUsageBytes,
  'current_rss_bytes': after.currentRssBytes - before.currentRssBytes,
  'max_rss_bytes': after.maxRssBytes - before.maxRssBytes,
};

int _countOverBudget(Object? rawTimes, int budget) {
  if (rawTimes is! List<Object?> || rawTimes.isEmpty) {
    throw StateError('Missing frame-time samples in performance summary.');
  }
  var count = 0;
  for (final time in rawTimes) {
    if (time is! int || time < 0) throw StateError('Invalid frame-time sample: $time.');
    if (time > budget) count++;
  }
  return count;
}
