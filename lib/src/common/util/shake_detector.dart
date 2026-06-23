import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// {@template shake_detector}
/// [ShakeDetector] detects shake gestures using the device's accelerometer.
/// {@endtemplate}
class ShakeDetector with ChangeNotifier {
  /// {@macro shake_detector}
  ShakeDetector({
    this._minShakeCount = 3,
    this._shakeThresholdGravity = 1.8,
    this._minTimeBetweenShakes = const Duration(milliseconds: 150),
    this._shakeCountResetTime = const Duration(milliseconds: 1500),
  }) {
    if (defaultTargetPlatform != .macOS && defaultTargetPlatform != .linux && defaultTargetPlatform != .windows) {
      _startListening();
    }
  }

  /// Minimum number of shakes required to trigger the shake event.
  final int _minShakeCount;

  /// Minimum gForce required to consider as a shake. (default is 1.8, which is a strong shake)
  final num _shakeThresholdGravity;

  /// Minimum time between shakes to prevent multiple shake events from being triggered in quick succession.
  final Duration _minTimeBetweenShakes;

  /// Time after which the shake count will be reset if no shakes are detected.
  final Duration _shakeCountResetTime;

  final _stopwatch = Stopwatch();

  StreamSubscription<num>? _streamSubscription;

  /// Pause listening to accelerometer events
  void pause() => _streamSubscription?.pause();

  /// Resume listening to accelerometer events
  void resume() => _streamSubscription?.resume();

  @override
  @mustCallSuper
  void dispose() {
    _stopListening();
    super.dispose();
  }

  /// Starts listening to accerelometer events
  void _startListening() {
    var shakeCount = 0;
    _stopwatch.start();
    _streamSubscription = accelerometerEventStream()
        .where((_) => _stopwatch.elapsed > _minTimeBetweenShakes)
        .map<num>((event) {
          final gX = event.x / 9.81;
          final gY = event.y / 9.81;
          final gZ = event.z / 9.81;

          // gForce will be close to 1 when there is no movement.
          final gForce = math.sqrt(math.pow(gX, 2) + math.pow(gY, 2) + math.pow(gZ, 2));

          return gForce;
        })
        .listen(
          (gForce) {
            if (gForce < _shakeThresholdGravity) return;

            // Reset the shake count after 1.5 seconds of no shakes
            if (_stopwatch.elapsed > _shakeCountResetTime) {
              shakeCount = 0;
            }

            _stopwatch.reset();

            if (++shakeCount >= _minShakeCount) {
              shakeCount = 0;
              notifyListeners();
            }
          },
          cancelOnError: false,
          onDone: _stopwatch.stop,
        );
  }

  /// Stops listening to accelerometer events
  void _stopListening() => _streamSubscription?.cancel();
}
