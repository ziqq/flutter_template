import 'dart:async';
import 'dart:io' as io show Socket;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier, ValueListenable, ValueNotifier;
import 'package:l/l.dart';

/// Connectivity status controller.
typedef ConnectivityStatusController = ValueListenable<ConnectivityStatus>;

/// Connectivity status enumiration.
/// Indicates whether the device is `online` or `offline`.
enum ConnectivityStatus {
  /// Device is online (internet reachable).
  online,

  /// Device is offline (no interface or internet not reachable).
  offline,
}

/// Connectivity service.
/// Purpose:
///  - Provide a single source of truth about `online`/`offline` state.
///  - Works reliably on iOS/Android:
///      * connectivity_plus gives interface changes (wifi/mobile/none)
///      * active reachability check (Socket.connect) detects real internet access
///      * polling catches cases when interface stays the same but internet disappears
///
/// Notes:
///  - We use [ChangeNotifier] only (no [Stream] / [ValueNotifier]) to keep API minimal.
///  - UI can listen via [AnimatedBuilder] / [ListenableBuilder] etc.
///  - Network layer ([Dio] interceptor or [HTTP] midleware) can read `service.status` instantly.
abstract interface class IConnectivityService {
  /// Connectivity status controller.
  ConnectivityStatusController get controller;

  /// Start listening (connectivity events + polling).
  void start();

  /// Force check current status (interface + reachability).
  Future<ConnectivityStatus> check();

  /// Dispose the service.
  void dispose();
}

/// Connectivity service implementation (ChangeNotifier singleton).
final class ConnectivityService extends ChangeNotifier implements IConnectivityService {
  ConnectivityService._({Connectivity? connectivity}) : _connectivity = connectivity ?? Connectivity();

  /// Get the singleton instance of [ConnectivityService].
  // ignore: prefer_constructors_over_static_methods
  static ConnectivityService get instance => _instance ??= ConnectivityService._();
  static ConnectivityService? _instance;

  /// Create a new instance of [ConnectivityService] for tests/custom usage.
  // ignore: sort_constructors_first
  factory ConnectivityService.instanceFor({Connectivity? connectivity}) =>
      ConnectivityService._(connectivity: connectivity);

  /// The connectivity instance.
  final Connectivity _connectivity;

  /// Socket connect timeout used for reachability check.
  ///
  /// Small value = faster UI reaction.
  /// Too small value may cause false negatives on very slow networks.
  final _timeout = const Duration(seconds: 2);

  /// Poll interval when status is `offline`.
  ///
  /// When offline users expect quick recovery detection.
  final _pollOffline = const Duration(seconds: 2);

  /// Poll interval when status is `online`.
  ///
  /// We don't want to spam reachability checks when everything is fine.
  final _pollOnline = const Duration(seconds: 20);

  /// Current status controller.
  ///
  /// Important: This is the only source of truth for UI and interceptors.
  @override
  ConnectivityStatusController get controller => _controller;
  final ValueNotifier<ConnectivityStatus> _controller = ValueNotifier<ConnectivityStatus>(ConnectivityStatus.online);

  /// Subscription to changes.
  StreamSubscription<List<ConnectivityResult>>? _sub;

  /// Polling timer (to detect "internet lost" without interface changes).
  Timer? _timer;

  /// Whether a check is in progress.
  bool _checking = false;

  /// Whether the service is disposed.
  bool _disposed = false;

  /// Whether the service has been started.
  bool _started = false;

  @override
  void start() {
    if (_disposed) return;
    if (_started) return;
    _started = true;
    _tick();
    _sub = _connectivity.onConnectivityChanged.listen((_) => _tick());
    _rescheduleTimer();
  }

  /// Reschedule polling based on current status.
  ///
  /// - `online`  -> _pollOnline
  /// - `offline` -> _pollOffline
  void _rescheduleTimer() {
    _timer?.cancel();
    final duration = _controller.value == ConnectivityStatus.online ? _pollOnline : _pollOffline;
    _timer = Timer.periodic(duration, (_) => _tick());
  }

  /// One "iteration" that updates status (if changed) and notifies listeners.
  /* Future<void> _tick() async {
    if (_disposed) return;

    // Prevent parallel reachability checks.
    if (_checking) return;
    _checking = true;

    try {
      final next = await check();
      if (_disposed) return;

      // Notify only on real changes.
      if (next != _controller.value) {
        l.i('Connectivity status changed: $next');
        _controller.value = next;
        notifyListeners();

        // Adapt polling frequency (online vs offline).
        _rescheduleTimer();
      }
    } finally {
      _checking = false;
    }
  } */
  void _tick() {
    if (_disposed) return;
    if (_checking) return;
    _checking = true;
    check()
        .then<void>((next) {
          if (_disposed) return;

          // Notify only on real changes.
          if (next != _controller.value) {
            l.i('Connectivity status changed: $next');
            _controller.value = next;
            notifyListeners();

            // Adapt polling frequency (online vs offline).
            _rescheduleTimer();
          }
        })
        .whenComplete(() => _checking = false)
        .ignore();
  }

  @override
  Future<ConnectivityStatus> check() async {
    // Check interface presence.
    //
    // connectivity_plus tells only "network interface" (wifi/mobile/none),
    // not real internet availability.
    final results = await _connectivity.checkConnectivity();
    final hasInterface = results.any((r) => r != ConnectivityResult.none);
    if (!hasInterface) return ConnectivityStatus.offline;

    // Check actual internet reachability.
    final ok = await _canReachInternet();
    return ok ? ConnectivityStatus.online : ConnectivityStatus.offline;
  }

  /// Active reachability check.
  ///
  /// We connect to a public DNS server port (53) to ensure we have route outside LAN.
  /// This avoids DNS caching issues that may affect InternetAddress.lookup.
  Future<bool> _canReachInternet() async {
    try {
      // Cloudflare DNS (fast and stable).
      final socket = await io.Socket.connect('1.1.1.1', 53, timeout: _timeout);
      socket.destroy();
      return true;
    } on Object catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _timer?.cancel();
    _sub?.cancel();
    super.dispose();
  }
}
