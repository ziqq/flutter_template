import 'dart:collection';

/// Admits at most [maxRequestsPerMinute] requests in a rolling minute.
///
/// Concurrent callers wait in arrival order. Admission reserves one slot;
/// callers start their request immediately after awaiting [waitIfNeeded].
/// Failed requests still consume their slot. This gate does not own requests
/// or cancel them and should be shared by callers using the same quota.
final class RateLimiter {
  RateLimiter({required this.maxRequestsPerMinute}) {
    if (maxRequestsPerMinute <= 0) {
      throw ArgumentError.value(maxRequestsPerMinute, 'maxRequestsPerMinute', 'Must be positive.');
    }
  }

  final int maxRequestsPerMinute;
  final Queue<int> _requestTimes = Queue<int>();
  final Stopwatch _stopwatch = Stopwatch()..start();
  Future<void> _pending = Future<void>.value();

  Future<void> waitIfNeeded() {
    final admission = _pending.then((_) => _wait());
    // A failed admission must not poison later callers' queue.
    _pending = admission.then<void>((_) {}, onError: (Object error, StackTrace stackTrace) {});
    return admission;
  }

  Future<void> _wait() async {
    const window = Duration.microsecondsPerMinute;
    while (true) {
      final now = _stopwatch.elapsedMicroseconds;
      while (_requestTimes.isNotEmpty && now - _requestTimes.first >= window) {
        _requestTimes.removeFirst();
      }
      if (_requestTimes.length < maxRequestsPerMinute) {
        _requestTimes.addLast(now);
        return;
      }
      await Future<void>.delayed(Duration(microseconds: window - (now - _requestTimes.first)));
    }
  }
}
