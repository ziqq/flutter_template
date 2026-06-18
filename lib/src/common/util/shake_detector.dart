import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector with ChangeNotifier {
  ShakeDetector({
    int minShakeCount = 3,
    num shakeThresholdGravity = 1.8,
    Duration minTimeBetweenShakes = const Duration(milliseconds: 150),
    Duration shakeCountResetTime = const Duration(milliseconds: 1500),
  }) : _minShakeCount = minShakeCount,
       _shakeThresholdGravity = shakeThresholdGravity,
       _minTimeBetweenShakes = minTimeBetweenShakes,
       _shakeCountResetTime = shakeCountResetTime {
    _startListening();
  }

  /// Количество встряхиваний для срабатывания уведомления
  final int _minShakeCount;

  /// Ускорение при котором движение телефона считается
  /// за встряхивание
  final num _shakeThresholdGravity;

  /// Минимальное окно между встряхиваниями
  /// Все что меньше него - игнорируется
  final Duration _minTimeBetweenShakes;

  /// Промежуток времени после которого сбрасывается прогресс
  final Duration _shakeCountResetTime;

  final _stopwatch = Stopwatch();

  StreamSubscription<num>? _streamSubscription;

  /// Приостановить подписку
  void pause() => _streamSubscription?.pause();

  /// Продолжить подписку
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
