import 'dart:async';
import 'dart:io' as io show Socket;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier, ValueListenable, ValueNotifier;
import 'package:l/l.dart';

/// Read-only connectivity status notifier used by UI and transport layers.
typedef ConnectivityStatusController = ValueListenable<ConnectivityStatus>;

/// TCP endpoint used by [ConnectivityService] to verify reachability.
typedef ConnectivityProbe = ({String host, int port});

/// Result of a connectivity check, including the overall status, active interfaces, and probe failures.
typedef _ConnectivityCheckResult = ({
  ConnectivityStatus status,
  List<ConnectivityResult> interfaces,
  List<String> failures,
});

/// High-level connectivity state used by the package transport layer.
enum ConnectivityStatus {
  /// Device is online (internet reachable).
  online,

  /// Device is offline (no interface or internet not reachable).
  offline,
}

/// Contract for package-owned connectivity state providers.
///
/// Implementations expose a single source of truth for `online` and `offline`
/// status that can be shared by UI widgets, Dio interceptors, and HTTP
/// middleware.
abstract interface class IConnectivityService {
  /// Connectivity status controller.
  ConnectivityStatusController get controller;

  /// Start listening (connectivity events + polling).
  void start();

  /// Force check current status (interface + reachability).
  Future<ConnectivityStatus> check();

  /// Force check current status and publish changes to [controller].
  Future<ConnectivityStatus> refresh({String reason = 'manual', bool force = false});

  /// Dispose the service.
  void dispose();
}

/// Connectivity service implementation backed by interface events and active
/// reachability checks.
///
/// The service combines `connectivity_plus` interface updates with public TCP socket
/// probe so callers are not limited to transport availability hints such as
/// Wi‑Fi or cellular presence.
final class ConnectivityService extends ChangeNotifier implements IConnectivityService {
  ConnectivityService._({
    Connectivity? connectivity,
    Iterable<ConnectivityProbe> probes = const <ConnectivityProbe>[],
    this._refreshTTL = const .new(seconds: 3),
    bool includeFallbackProbes = true,
  }) : _connectivity = connectivity ?? Connectivity(),
       _controller = ValueNotifier<ConnectivityStatus>(.online),
       _probes = _mergeProbes(probes, includeFallbackProbes: includeFallbackProbes);

  /// Get the singleton instance of [ConnectivityService].
  // ignore: prefer_constructors_over_static_methods
  static ConnectivityService get instance => _instance ??= ConnectivityService._();
  static ConnectivityService? _instance;

  /// Default reachability probes used to confirm that public internet is reachable outside the local network.
  ///
  /// A single DNS-port probe can be blocked by mobile operators, corporate networks, VPNs, or captive portals while
  /// regular HTTPS traffic still works. Keep more than one destination to reduce false offline states.
  static const _fallbackProbes = <ConnectivityProbe>[
    (host: 'ya.ru', port: 443),
    (host: 'yandex.ru', port: 443),
    (host: 'vk.com', port: 443),
    (host: 'apple.com', port: 443),
    (host: 'google.com', port: 443),
    (host: 'gstatic.com', port: 443),
    (host: '1.1.1.1', port: 443),
    (host: '8.8.8.8', port: 443),
    (host: '1.1.1.1', port: 53),
  ];

  /// Consecutive no-interface checks required before publishing `offline`.
  ///
  /// `connectivity_plus` can briefly emit `none` during Wi-Fi/mobile handoffs, so keep a small confirmation window.
  static const _noInterfaceOfflineConfirmationThreshold = 2;

  /// Consecutive failed probe checks required before publishing `offline` while an interface is still present.
  ///
  /// Wi-Fi/mobile networks can have short reachability stalls, so avoid showing the offline banner after a single
  /// failed probe cycle.
  static const _probeOfflineConfirmationThreshold = 2;

  /// Merge custom probes with fallback probes, ensuring no duplicates and valid entries.
  static List<ConnectivityProbe> _mergeProbes(
    Iterable<ConnectivityProbe> probes, {
    required bool includeFallbackProbes,
  }) {
    final candidates = includeFallbackProbes ? <ConnectivityProbe>[...probes, ..._fallbackProbes] : probes;
    final result = <ConnectivityProbe>[];
    final keys = <String>{};
    for (final probe in candidates) {
      final host = probe.host.trim();
      if (host.isEmpty || probe.port <= 0) continue;
      final key = '$host:${probe.port}';
      if (keys.add(key)) result.add((host: host, port: probe.port));
    }
    return result;
  }

  /// Create a new instance of [ConnectivityService] for tests/custom usage.
  // ignore: sort_constructors_first
  factory ConnectivityService.instanceFor({
    Connectivity? connectivity,
    Iterable<ConnectivityProbe> probes = const <ConnectivityProbe>[],
    Duration refreshTTL = const .new(seconds: 3),
    bool includeFallbackProbes = true,
  }) => ConnectivityService._(
    connectivity: connectivity,
    probes: probes,
    refreshTTL: refreshTTL,
    includeFallbackProbes: includeFallbackProbes,
  );

  /// The connectivity instance.
  final Connectivity _connectivity;

  /// Reachability probes checked in order.
  final List<ConnectivityProbe> _probes;

  /// How long a successful refresh may be reused by request preflight checks.
  ///
  /// Transport error paths pass `force: true`, so this cache only removes
  /// redundant positive probes during normal request bursts.
  final Duration _refreshTTL;

  /// Socket connect timeout used for reachability check.
  ///
  /// Small value = faster UI reaction.
  /// Too small value may cause false negatives on very slow networks.
  final Duration _timeout = const .new(seconds: 2);

  /// Poll interval when status is `offline`.
  ///
  /// When offline users expect quick recovery detection.
  final Duration _pollOffline = const .new(seconds: 2);

  /// Poll interval when status is `online`.
  ///
  /// We don't want to spam reachability checks when everything is fine.
  final Duration _pollOnline = const .new(seconds: 20);

  /// Current status controller.
  ///
  /// Important: This is the only source of truth for UI and interceptors.
  @override
  ConnectivityStatusController get controller => _controller;
  final ValueNotifier<ConnectivityStatus> _controller;

  /// Subscription to connectivity interface changes.
  StreamSubscription<List<ConnectivityResult>>? _sub;

  /// Whether a check is in progress.
  Future<ConnectivityStatus>? _refreshing;

  /// Polling timer (to detect "internet lost" without interface changes).
  Timer? _timer;

  /// Whether the service has been started.
  bool _started = false;

  /// Whether the service is disposed.
  bool _disposed = false;

  /// Consecutive checks that could not confirm public internet reachability.
  int _offlineChecks = 0;

  /// Last time detailed offline probe logs were emitted.
  DateTime? _lastOfflineDetailsLogAt;

  /// Last time a refresh confirmed online status.
  DateTime? _lastSuccessfulRefreshAt;

  /// Whether detailed offline probe logs should be emitted for the current check.
  bool get _shouldLogOfflineDetails {
    if (_controller.value == .online) return true;
    final now = DateTime.now();
    final last = _lastOfflineDetailsLogAt;
    if (last != null && now.difference(last) < const .new(seconds: 30)) return false;
    _lastOfflineDetailsLogAt = now;
    return true;
  }

  /// Whether the last refresh is still valid for preflight checks.
  bool get _isSuccessfulRefresh {
    if (_controller.value != .online) return false;
    if (_refreshTTL <= Duration.zero) return false;
    final last = _lastSuccessfulRefreshAt;
    return last != null && DateTime.now().difference(last) < _refreshTTL;
  }

  @override
  void dispose() {
    if (_disposed) return;
    _refreshing = null;
    _disposed = true;
    _started = false;
    _timer?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  @override
  void start() {
    if (_disposed) return;
    if (_started) return;
    _started = true;
    refresh(reason: 'start').ignore();
    _sub = _connectivity.onConnectivityChanged.listen(
      (results) => refresh(reason: 'interface changed: ${_formatConnectivityResults(results)}').ignore(),
    );
    _rescheduleTimer();
  }

  /// Reschedule polling based on current status.
  ///
  /// - `online`  -> _pollOnline
  /// - `offline` -> _pollOffline
  void _rescheduleTimer() {
    _timer?.cancel();
    final duration = _controller.value == .online && _offlineChecks == 0 ? _pollOnline : _pollOffline;
    _timer = Timer.periodic(duration, (_) => refresh(reason: 'polling').ignore());
  }

  /// Perform a connectivity check with the following steps:
  /// 1. Check active interfaces using `connectivity_plus`.
  /// 2. If interfaces are present, perform active reachability checks using TCP socket probes to public endpoints.
  /// 3. Update status and notify listeners if there are changes.
  @override
  Future<ConnectivityStatus> refresh({String reason = 'manual', bool force = false}) async {
    if (_disposed) return _controller.value;
    if (!force && _isSuccessfulRefresh) return _controller.value;
    final current = _refreshing;
    if (current != null) return current;
    final future = _refresh(reason: reason);
    _refreshing = future;
    return future.whenComplete(() => _refreshing = null);
  }

  /// Refresh that performs the actual check and status update logic.
  Future<ConnectivityStatus> _refresh({required String reason}) async {
    final stopwatch = Stopwatch()..start();
    final previous = _controller.value;
    try {
      final result = await _check();
      if (_disposed) return _controller.value;
      final next = result.status;

      final hasInterface = result.interfaces.any((interface) => interface != .none);
      final threshold = hasInterface ? _probeOfflineConfirmationThreshold : _noInterfaceOfflineConfirmationThreshold;

      if (next == .online) {
        final hadOfflineChecks = _offlineChecks > 0;
        _offlineChecks = 0;
        _lastSuccessfulRefreshAt = DateTime.now();
        if (hadOfflineChecks && previous == .online) _rescheduleTimer();
      } else {
        _offlineChecks += 1;
        _lastSuccessfulRefreshAt = null;
        if (previous == .online && _offlineChecks < threshold) {
          _rescheduleTimer();
          return previous;
        }
      }

      // Notify only on real changes.
      if (next != previous) {
        if (next == .offline) {
          l.w(
            'ConnectivityService | status changed: '
            '${previous.name} -> ${next.name}, '
            'reason: $reason, '
            'elapsed: ${stopwatch.elapsedMilliseconds} ms, '
            'interfaces: ${_formatConnectivityResults(result.interfaces)}, '
            'failures: ${result.failures.join('; ')}',
          );
        }
        _controller.value = next;
        notifyListeners();

        // Adapt polling frequency (online vs offline).
        _rescheduleTimer();
      }
      return _controller.value;
    } on Object catch (error, stackTrace) {
      l.w(
        'ConnectivityService | check failed '
        'error: $error',
        stackTrace,
      );
      return _controller.value;
    }
  }

  @override
  Future<ConnectivityStatus> check() async => (await _check()).status;

  /// Active reachability check.
  ///
  /// We connect to public endpoints to verify general internet reachability without depending on app backend status.
  Future<_ConnectivityCheckResult> _check() async {
    // Check interface presence.
    //
    // `connectivity_plus` tells only "network interface" (wifi/mobile/none),
    // not real internet availability.
    final results = await _connectivity.checkConnectivity();
    final hasInterface = results.any((r) => r != ConnectivityResult.none);
    if (!hasInterface) {
      return (status: ConnectivityStatus.offline, interfaces: results, failures: const <String>['no active interface']);
    }

    // Check actual internet reachability.
    final result = await _canReachInternet();
    return (
      status: result.online ? ConnectivityStatus.online : ConnectivityStatus.offline,
      interfaces: results,
      failures: result.failures,
    );
  }

  /// Active reachability check.
  ///
  /// We connect to public endpoints to verify general internet reachability without depending on app backend status.
  Future<({bool online, List<String> failures})> _canReachInternet() async {
    final completer = Completer<({bool online, List<String> failures})>();
    final failures = <String>[];
    var pending = _probes.length;
    for (final probe in _probes) {
      final stopwatch = Stopwatch()..start();
      io.Socket.connect(probe.host, probe.port, timeout: _timeout)
          .then<void>((socket) {
            socket.destroy();
            if (!completer.isCompleted) completer.complete((online: true, failures: const <String>[]));
          })
          .onError<Object>((error, _) {
            failures.add(
              '[${probe.host}:${probe.port} | '
              'elapsed: ${stopwatch.elapsedMilliseconds} ms, '
              'error: $error]',
            );
          })
          .whenComplete(() {
            pending -= 1;
            if (pending == 0 && !completer.isCompleted) {
              if (_shouldLogOfflineDetails && _controller.value == .offline) {
                l.w(
                  'ConnectivityService | internet is still not reachable, '
                  'failed probes: ${failures.join('; ')}',
                );
              }
              completer.complete((online: false, failures: failures));
            }
          })
          .ignore();
    }

    return completer.future;
  }

  String _formatConnectivityResults(List<ConnectivityResult> results) =>
      results.isEmpty ? 'empty' : results.map((result) => result.name).join(',');
}
